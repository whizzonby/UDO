<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use App\Services\AdminAccountSafetyService;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;

class ViewUser extends ViewRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('privacyExport')
                ->label('Download privacy export')
                ->icon('heroicon-o-document-arrow-down')
                ->color('gray')
                ->action(function (AdminAccountSafetyService $accountSafetyService) {
                    $payload = $accountSafetyService->privacyExport($this->record, auth()->user());
                    $filename = 'udo-privacy-export-user-' . $this->record->id . '.json';

                    return response()->streamDownload(function () use ($payload): void {
                        echo json_encode($payload, JSON_PRETTY_PRINT);
                    }, $filename, ['Content-Type' => 'application/json']);
                }),
            Actions\Action::make('verifyEmail')
                ->label('Mark email verified')
                ->icon('heroicon-o-check-badge')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn () => ! $this->record->email_verified_at)
                ->action(function (): void {
                    $this->record->forceFill(['email_verified_at' => now()])->save();

                    Notification::make()
                        ->title('Email marked as verified')
                        ->success()
                        ->send();
                }),
            Actions\Action::make('revokeTokens')
                ->label('Revoke API tokens')
                ->icon('heroicon-o-key')
                ->color('danger')
                ->requiresConfirmation()
                ->modalDescription('This logs the user out of all token-based API and mobile sessions. It does not delete the account.')
                ->action(function (AdminAccountSafetyService $accountSafetyService): void {
                    $count = $accountSafetyService->revokeTokens($this->record, auth()->user());

                    Notification::make()
                        ->title("Revoked {$count} API token(s)")
                        ->success()
                        ->send();
                }),
            Actions\Action::make('anonymizeAccount')
                ->label('Anonymize account')
                ->icon('heroicon-o-shield-exclamation')
                ->color('danger')
                ->requiresConfirmation()
                ->modalHeading('Anonymize this account')
                ->modalDescription('This permanently removes personal profile data, revokes API tokens, removes collaborations, and marks the account as deleted. Type ANONYMIZE to continue.')
                ->visible(fn () => $this->record->auth_provider !== 'deleted' && auth()->user()?->hasAnyRole(['super_admin', 'admin']))
                ->form([
                    Forms\Components\TextInput::make('confirmation')
                        ->label('Confirmation phrase')
                        ->required()
                        ->rules(['in:ANONYMIZE'])
                        ->helperText('Type ANONYMIZE exactly.'),
                ])
                ->action(function (array $data, AdminAccountSafetyService $accountSafetyService): void {
                    if (($data['confirmation'] ?? null) !== 'ANONYMIZE') {
                        Notification::make()
                            ->title('Confirmation phrase did not match')
                            ->danger()
                            ->send();

                        return;
                    }

                    $summary = $accountSafetyService->anonymize($this->record, auth()->user());

                    Notification::make()
                        ->title('Account anonymized')
                        ->body("Revoked {$summary['revoked_api_tokens']} token(s) and removed {$summary['removed_collaborations']} collaboration(s).")
                        ->success()
                        ->send();
                }),
            Actions\EditAction::make(),
        ];
    }
}
