<?php

namespace App\Jobs;

use App\Models\GuestMessageDelivery;
use App\Models\Message;
use App\Services\MessageDeliveryService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendGuestMessageDeliveryJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;

    public function __construct(public readonly int $deliveryId)
    {
    }

    public function handle(): void
    {
        $delivery = GuestMessageDelivery::with(['guest.token', 'message.wedding'])->findOrFail($this->deliveryId);

        if (in_array($delivery->status, ['sent', 'delivered'], true)) {
            return;
        }

        try {
            $result = app(MessageDeliveryService::class)->send($delivery);

            $delivery->update([
                'status' => 'sent',
                'sent_at' => now(),
                'external_id' => $result['external_id'] ?? null,
                'error_message' => null,
            ]);
        } catch (\Throwable $exception) {
            $delivery->update([
                'status' => 'failed',
                'error_message' => $exception->getMessage(),
            ]);
            $this->updateMessageStatus($delivery->message);
            throw $exception;
        }

        $this->updateMessageStatus($delivery->message);
    }

    public function failed(?\Throwable $exception = null): void
    {
        $delivery = GuestMessageDelivery::with('message')->find($this->deliveryId);

        if (! $delivery) {
            return;
        }

        $delivery->update([
            'status' => 'failed',
            'error_message' => $exception?->getMessage(),
        ]);
        $this->updateMessageStatus($delivery->message);
    }

    private function updateMessageStatus(Message $message): void
    {
        $message->loadCount([
            'deliveries as pending_deliveries_count' => fn ($query) => $query->whereIn('status', ['pending', 'queued']),
            'deliveries as failed_deliveries_count' => fn ($query) => $query->where('status', 'failed'),
        ]);

        if ($message->pending_deliveries_count > 0) {
            return;
        }

        $message->update([
            'status' => $message->failed_deliveries_count > 0 ? 'failed' : 'sent',
            'sent_at' => $message->sent_at ?? now(),
        ]);
    }
}
