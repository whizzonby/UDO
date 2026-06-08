<?php

namespace App\Jobs;

use App\Models\Guest;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Twilio\Rest\Client as TwilioClient;

class SendRsvpConfirmationSms implements ShouldQueue
{
    use Dispatchable, Queueable, InteractsWithQueue, SerializesModels;

    public int $tries  = 3;
    public int $backoff = 60;

    public function __construct(public readonly Guest $guest) {}

    public function handle(): void
    {
        if (empty($this->guest->phone)) {
            return;
        }

        $body = match ($this->guest->rsvp_status) {
            'attending' => "You're confirmed for the wedding, {$this->guest->first_name}! We can't wait to celebrate with you 🎉",
            'declined'  => "Thanks for letting us know, {$this->guest->first_name}. You'll be missed 💙",
            'maybe'     => "Thanks for responding, {$this->guest->first_name}! Let us know when you've decided 💌",
            default     => "Thanks for your response, {$this->guest->first_name}!",
        };

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
        return ['sms-rsvp-confirm', "guest:{$this->guest->id}"];
    }
}
