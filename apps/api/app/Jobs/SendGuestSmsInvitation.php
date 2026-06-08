<?php

namespace App\Jobs;

use App\Models\Guest;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Twilio\Rest\Client as TwilioClient;

class SendGuestSmsInvitation implements ShouldQueue
{
    use Dispatchable, Queueable, InteractsWithQueue, SerializesModels;

    public int $tries  = 3;
    public int $backoff = 120;

    public function __construct(public readonly Guest $guest) {}

    public function handle(): void
    {
        if (empty($this->guest->phone) || empty($this->guest->token)) {
            return;
        }

        $wedding  = $this->guest->wedding;
        $names    = $wedding->partner_two_name
            ? "{$wedding->partner_one_name} & {$wedding->partner_two_name}"
            : $wedding->partner_one_name;

        $guestLink = rtrim(config('app.guest_web_url', 'https://udo.app'), '/') . '/g/' . $this->guest->token;

        $body = "Hi {$this->guest->first_name}! You're invited to {$names}'s wedding 💌\n{$guestLink}";

        $twilio = new TwilioClient(
            config('services.twilio.sid'),
            config('services.twilio.token'),
        );

        $twilio->messages->create($this->guest->phone, [
            'from' => config('services.twilio.from'),
            'body' => $body,
        ]);
    }

    public function tags(): array
    {
        return ['sms-invitation', "guest:{$this->guest->id}", "wedding:{$this->guest->wedding_id}"];
    }
}
