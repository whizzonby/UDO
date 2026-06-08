<?php

namespace App\Jobs;

use App\Mail\GuestInvitationMail;
use App\Models\Guest;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendGuestInvitation implements ShouldQueue
{
    use Queueable, InteractsWithQueue, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60;

    public function __construct(
        public readonly Guest $guest,
    ) {}

    public function handle(): void
    {
        if (empty($this->guest->email)) {
            return;
        }

        Mail::to($this->guest->email, $this->guest->full_name)
            ->send(new GuestInvitationMail($this->guest));
    }

    public function tags(): array
    {
        return ['invitation', "guest:{$this->guest->id}", "wedding:{$this->guest->wedding_id}"];
    }
}
