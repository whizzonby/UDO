<?php

namespace App\Filament\Resources\InvitationCampaignResource\Pages;

use App\Filament\Resources\InvitationCampaignResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListInvitationCampaigns extends ListRecords
{
    protected static string $resource = InvitationCampaignResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
