<?php

namespace App\Services;

use App\Jobs\SendGuestMessageDeliveryJob;
use App\Models\GuestToken;
use App\Models\Message;

class MessageDispatchService
{
    public function dispatch(Message $message, bool $force = false): int
    {
        if (in_array($message->status, ['sending', 'sent'], true)) {
            return 0;
        }

        if (! $force && $message->scheduled_at && $message->scheduled_at->isFuture()) {
            return 0;
        }

        $filter = $message->audience_filter ?? [];
        $query = $message->wedding->guests();

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
        if (! empty($filter['guest_ids']) && is_array($filter['guest_ids'])) {
            $query->whereIn('id', $filter['guest_ids']);
        }

        $guests = $query->get();
        if ($message->message_type === 'invitation') {
            $this->ensureInvitationTokens($message, $guests);
        }
        $message->deliveries()->delete();

        $deliveryIds = [];
        foreach ($guests as $guest) {
            $delivery = $message->deliveries()->create([
                'guest_id' => $guest->id,
                'status' => 'pending',
                'channel' => $message->channel,
            ]);
            $deliveryIds[] = $delivery->id;
        }

        $message->update([
            'status' => $guests->isEmpty() ? 'sent' : 'sending',
            'sent_at' => $guests->isEmpty() ? now() : null,
            'recipient_count' => $guests->count(),
        ]);

        foreach ($deliveryIds as $deliveryId) {
            SendGuestMessageDeliveryJob::dispatch($deliveryId);
        }

        return $guests->count();
    }

    private function ensureInvitationTokens(Message $message, $guests): void
    {
        $existingGuestIds = $message->wedding->guestTokens()
            ->whereIn('guest_id', $guests->pluck('id'))
            ->pluck('guest_id')
            ->all();

        $missingGuests = $guests->whereNotIn('id', $existingGuestIds);

        foreach ($missingGuests as $guest) {
            GuestToken::create([
                'wedding_id' => $message->wedding_id,
                'guest_id' => $guest->id,
                'view_type' => $guest->guest_view_type,
            ]);
        }
    }

    public function retryFailed(Message $message): int
    {
        if ($message->status === 'sending') {
            return 0;
        }

        $deliveries = $message->deliveries()
            ->where('status', 'failed')
            ->get();

        foreach ($deliveries as $delivery) {
            $delivery->update([
                'status' => 'pending',
                'external_id' => null,
                'sent_at' => null,
                'delivered_at' => null,
                'opened_at' => null,
                'error_message' => null,
            ]);
        }

        if ($deliveries->isNotEmpty()) {
            $message->update(['status' => 'sending']);
        }

        foreach ($deliveries as $delivery) {
            SendGuestMessageDeliveryJob::dispatch($delivery->id);
        }

        return $deliveries->count();
    }
}
