<?php

namespace App\Mail;

use App\Models\Guest;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class GuestInvitationMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly Guest $guest,
    ) {}

    public function envelope(): Envelope
    {
        $wedding = $this->guest->wedding;
        $names   = $wedding->partner_two_name
            ? "{$wedding->partner_one_name} & {$wedding->partner_two_name}"
            : $wedding->partner_one_name;

        return new Envelope(
            subject: "You're invited to {$names}'s wedding 💌",
        );
    }

    public function content(): Content
    {
        $wedding = $this->guest->wedding;
        $names   = $wedding->partner_two_name
            ? "{$wedding->partner_one_name} & {$wedding->partner_two_name}"
            : $wedding->partner_one_name;

        $guestLink = rtrim(config('app.guest_web_url', 'https://udo.app'), '/')
            . '/g/' . $this->guest->token;

        return new Content(
            htmlView: 'emails.invitation',
            with: [
                'guest'      => $this->guest,
                'wedding'    => $wedding,
                'names'      => $names,
                'guestLink'  => $guestLink,
                'weddingDate' => $wedding->wedding_date?->format('l, F j, Y'),
            ],
        );
    }
}
