<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ActivityRecorded implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly string $weddingId,
        public readonly string $type,
        public readonly string $actorName,
        public readonly string $description,
        public readonly string $occurredAt,
    ) {}

    public function broadcastOn(): array
    {
        return [new PrivateChannel("wedding.{$this->weddingId}")];
    }

    public function broadcastAs(): string
    {
        return 'activity.recorded';
    }

    public function broadcastWith(): array
    {
        return [
            'type'        => $this->type,
            'actor_name'  => $this->actorName,
            'description' => $this->description,
            'occurred_at' => $this->occurredAt,
        ];
    }
}
