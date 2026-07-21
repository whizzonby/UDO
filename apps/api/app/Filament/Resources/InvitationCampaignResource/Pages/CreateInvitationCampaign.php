<?php

namespace App\Filament\Resources\InvitationCampaignResource\Pages;

use App\Filament\Resources\InvitationCampaignResource;
use App\Models\Message;
use Filament\Resources\Pages\CreateRecord;

class CreateInvitationCampaign extends CreateRecord
{
    protected static string $resource = InvitationCampaignResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['message_type'] = $data['campaign_type'] ?? 'invitation';
        $data['created_by'] = auth()->id();
        $data['audience_filter'] = array_filter($data['audience_filter'] ?? [], fn ($value) => $value !== null && $value !== false && $value !== '');

        if (($data['status'] ?? 'draft') === 'scheduled' && empty($data['scheduled_at'])) {
            $data['status'] = 'draft';
        }

        return $data;
    }

    protected function afterCreate(): void
    {
        $this->refreshRecipientCount($this->record);
    }

    private function refreshRecipientCount(Message $campaign): void
    {
        $query = $campaign->wedding->guests();
        $filter = $campaign->audience_filter ?? [];

        if (! empty($filter['attending_status'])) {
            $query->where('attending_status', $filter['attending_status']);
        }
        if (! empty($filter['guest_group'])) {
            $query->where('guest_group', $filter['guest_group']);
        }
        if (! empty($filter['invite_status'])) {
            $query->where('invite_status', $filter['invite_status']);
        }
        if (! empty($filter['vip_flag'])) {
            $query->where('vip_flag', true);
        }
        if (! empty($filter['has_email'])) {
            $query->whereNotNull('email')->where('email', '!=', '');
        }

        $campaign->update(['recipient_count' => $query->count()]);
    }
}
