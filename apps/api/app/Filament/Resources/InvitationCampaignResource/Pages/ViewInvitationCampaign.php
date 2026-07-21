<?php

namespace App\Filament\Resources\InvitationCampaignResource\Pages;

use App\Filament\Resources\InvitationCampaignResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewInvitationCampaign extends ViewRecord
{
    protected static string $resource = InvitationCampaignResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->visible(fn () => ! in_array($this->record->status, ['sending', 'sent'], true)),
        ];
    }
}
