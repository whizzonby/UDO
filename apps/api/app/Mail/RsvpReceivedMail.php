<?php

namespace App\Mail;

use App\Models\Guest;
use App\Models\Wedding;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class RsvpReceivedMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly Guest   $guest,
        public readonly Wedding $wedding,
    ) {}

    public function envelope(): Envelope
    {
        $emoji = match ($this->guest->rsvp_status) {
            'attending' => '🎉',
            'declined'  => '😢',
            default     => '💌',
        };

        return new Envelope(
            subject: "{$emoji} {$this->guest->full_name} just responded to your invitation",
        );
    }

    public function content(): Content
    {
        $label = match ($this->guest->rsvp_status) {
            'attending' => 'is attending',
            'declined'  => 'can\'t make it',
            'maybe'     => 'is still deciding',
            default     => 'responded',
        };

        return new Content(
            htmlView: 'emails.rsvp-received',
            with: [
                'guest'   => $this->guest,
                'wedding' => $this->wedding,
                'label'   => $label,
            ],
        );
    }
}
