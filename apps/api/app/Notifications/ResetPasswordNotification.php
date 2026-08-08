<?php

namespace App\Notifications;

use App\Mail\TemplatedMail;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public string $token)
    {
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): TemplatedMail
    {
        $frontendUrl = rtrim(config('app.frontend_url', 'http://localhost:3000'), '/');
        $resetUrl = "{$frontendUrl}/reset-password?token={$this->token}&email=" . urlencode($notifiable->getEmailForPasswordReset());

        return (new TemplatedMail('password_reset', [
            'first_name' => $notifiable->first_name ?? 'there',
            'reset_url' => $resetUrl,
        ]))->to($notifiable->getEmailForPasswordReset());
    }
}
