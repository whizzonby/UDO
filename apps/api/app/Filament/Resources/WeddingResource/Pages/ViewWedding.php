<?php

namespace App\Filament\Resources\WeddingResource\Pages;

use App\Filament\Resources\WeddingResource;
use App\Services\AdminLiveOpsService;
use App\Services\SmartAlertService;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;

class ViewWedding extends ViewRecord
{
    protected static string $resource = WeddingResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('refreshAlerts')
                ->label('Refresh alerts')
                ->icon('heroicon-o-arrow-path')
                ->color('info')
                ->action(function (SmartAlertService $alerts): void {
                    $count = $alerts->refresh($this->record)->count();

                    Notification::make()
                        ->title("Refreshed {$count} active alert(s)")
                        ->success()
                        ->send();
                }),
            Actions\Action::make('markFinalWeek')
                ->label('Mark final week')
                ->icon('heroicon-o-calendar-days')
                ->color('warning')
                ->requiresConfirmation()
                ->visible(fn () => $this->record->status !== 'final_week')
                ->action(function (AdminLiveOpsService $liveOps): void {
                    $this->record = $liveOps->markFinalWeek($this->record, auth()->user());

                    Notification::make()
                        ->title('Wedding marked final week')
                        ->success()
                        ->send();
                }),
            Actions\Action::make('markLive')
                ->label('Mark live')
                ->icon('heroicon-o-bolt')
                ->color('danger')
                ->requiresConfirmation()
                ->visible(fn () => $this->record->status !== 'live')
                ->action(function (AdminLiveOpsService $liveOps): void {
                    $this->record = $liveOps->startLive($this->record, auth()->user());

                    Notification::make()
                        ->title('Wedding marked live')
                        ->success()
                        ->send();
                }),
            Actions\EditAction::make(),
        ];
    }
}
