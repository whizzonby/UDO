<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class GuestMessageMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        private readonly string $messageSubject,
        private readonly string $messageBody,
    ) {
    }

    public function envelope(): Envelope
    {
        return new Envelope(subject: $this->messageSubject);
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.layout',
            with: ['bodyHtml' => nl2br(e($this->messageBody))],
        );
    }
}
