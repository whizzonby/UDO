<?php

namespace App\Filament\Resources\SubscriptionResource\Pages;

use App\Filament\Resources\SubscriptionResource;
use App\Services\AdminSubscriptionOpsService;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;

class ViewSubscription extends ViewRecord
{
    protected static string $resource = SubscriptionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('overrideEntitlement')
                ->label('Override entitlement')
                ->icon('heroicon-o-adjustments-horizontal')
                ->color('warning')
                ->requiresConfirmation()
                ->modalHeading('Override subscription entitlement')
                ->modalDescription('This updates billing entitlement state and writes an audit log. Use only for support, billing correction, or approved operational exceptions.')
                ->form([
                    Forms\Components\Select::make('plan')
                        ->options(SubscriptionResource::planOptions())
                        ->default(fn () => $this->record->plan)
                        ->required(),
                    Forms\Components\Select::make('status')
                        ->options(SubscriptionResource::statusOptions())
                        ->default(fn () => $this->record->status)
                        ->required(),
                    Forms\Components\Select::make('billing_cycle')
                        ->options(SubscriptionResource::billingCycleOptions())
                        ->default(fn () => $this->record->billing_cycle ?: 'monthly')
                        ->required(),
                    Forms\Components\DateTimePicker::make('current_period_end')
                        ->native(false)
                        ->label('Period ends')
                        ->default(fn () => $this->record->current_period_end),
                    Forms\Components\Textarea::make('note')
                        ->label('Admin note')
                        ->required()
                        ->maxLength(500)
                        ->helperText('Explain why this override is being applied.'),
                    Forms\Components\TextInput::make('confirmation')
                        ->label('Confirmation phrase')
                        ->required()
                        ->rules(['in:OVERRIDE'])
                        ->helperText('Type OVERRIDE exactly.'),
                ])
                ->action(function (array $data, AdminSubscriptionOpsService $subscriptionOps): void {
                    if (($data['confirmation'] ?? null) !== 'OVERRIDE') {
                        Notification::make()
                            ->title('Confirmation phrase did not match')
                            ->danger()
                            ->send();

                        return;
                    }

                    unset($data['confirmation']);
                    $subscription = $subscriptionOps->override($this->record, auth()->user(), $data);
                    $this->record = $subscription;

                    Notification::make()
                        ->title('Subscription entitlement overridden')
                        ->body("Plan is now {$subscription->plan} / {$subscription->status}.")
                        ->success()
                        ->send();
                }),
            Actions\EditAction::make(),
        ];
    }
}
