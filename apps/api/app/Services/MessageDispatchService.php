<?php

namespace App\Services;

use App\Jobs\SendGuestMessageDeliveryJob;
use App\Models\GuestToken;
use App\Models\Message;

class MessageDispatchService
{
    public function dispatch(Message $message, bool $force = false, bool $defer = false): int
    {
        if (in_array($message->status, ['sending', 'sent'], true)) {
            return 0;
        }

        if (! $force && $message->scheduled_at && $message->scheduled_at->isFuture()) {
            return 0;
        }

        $filter = $message->audience_filter ?? [];
        $query = app(GuestAudienceFilterService::class)->apply($message->wedding->guests(), $filter);

        $guests = $query->get();
        if ($message->message_type === 'invitation') {
            $this->ensureGuestTokens($message->wedding_id, $guests);
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
            $defer ? $this->runDeferred($deliveryId) : $this->runSync($deliveryId);
        }

        return $guests->count();
    }

    /**
     * Runs a delivery job inline (no queue worker dependency) without letting
     * one recipient's failure (e.g. missing email, opted out) abort delivery
     * to the rest of the batch. SendGuestMessageDeliveryJob already records
     * the failure on the delivery row before rethrowing; the rethrow only
     * matters for real queue-worker retry bookkeeping, which dispatchSync
     * bypasses anyway.
     */
    private function runSync(int $deliveryId): void
    {
        try {
            SendGuestMessageDeliveryJob::dispatchSync($deliveryId);
        } catch (\Throwable $e) {
            // Failure already recorded on the delivery by the job itself.
        }
    }

    private function runDeferred(int $deliveryId): void
    {
        if (app()->runningInConsole()) {
            $this->runSync($deliveryId);
            return;
        }

        app()->terminating(fn () => $this->runSync($deliveryId));
    }

    public function ensureGuestTokens(int $weddingId, $guests): void
    {
        $existingGuestIds = GuestToken::where('wedding_id', $weddingId)
            ->whereIn('guest_id', $guests->pluck('id'))
            ->pluck('guest_id')
            ->all();

        $missingGuests = $guests->whereNotIn('id', $existingGuestIds);

        foreach ($missingGuests as $guest) {
            GuestToken::create([
                'wedding_id' => $weddingId,
                'guest_id' => $guest->id,
                'view_type' => $guest->guest_view_type,
            ]);
        }
    }

    public function retryFailed(Message $message, bool $defer = false): int
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
            $defer ? $this->runDeferred($delivery->id) : $this->runSync($delivery->id);
        }

        return $deliveries->count();
    }
}
