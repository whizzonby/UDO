<?php

namespace App\Jobs;

use App\Mail\RsvpReceivedMail;
use App\Models\Guest;
use App\Models\Wedding;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendRsvpNotification implements ShouldQueue
{
    use Dispatchable, Queueable, InteractsWithQueue, SerializesModels;

    public int $tries  = 3;
    public int $backoff = 60;

    public function __construct(
        public readonly Guest   $guest,
        public readonly Wedding $wedding,
    ) {}

    public function handle(): void
    {
        $owners = $this->wedding->users()->get();

        foreach ($owners as $user) {
            if (empty($user->email)) {
                continue;
            }

            Mail::to($user->email, $user->name)
                ->send(new RsvpReceivedMail($this->guest, $this->wedding));
        }
    }

    public function tags(): array
    {
        return [
            'rsvp-notification',
            "guest:{$this->guest->id}",
            "wedding:{$this->wedding->id}",
        ];
    }
}
