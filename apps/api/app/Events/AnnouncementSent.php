<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AnnouncementSent implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly string $weddingId,
        public readonly string $id,
        public readonly ?string $subject,
        public readonly string $body,
        public readonly string $sentAt,
    ) {}

    // Public channel — guests subscribe without auth
    public function broadcastOn(): array
    {
        return [new Channel("wedding.{$this->weddingId}")];
    }

    public function broadcastAs(): string
    {
        return 'announcement.sent';
    }

    public function broadcastWith(): array
    {
        return [
            'id'      => $this->id,
            'subject' => $this->subject,
            'body'    => $this->body,
            'sent_at' => $this->sentAt,
        ];
    }
}
