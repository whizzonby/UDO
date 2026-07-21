<?php

namespace App\Jobs;

use App\Mail\TemplatedMail;
use App\Models\Guest;
use App\Models\GuestToken;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendGuestInviteJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;

    public function __construct(public readonly int $guestId)
    {
    }

    public function handle(): void
    {
        $guest = Guest::with(['token', 'wedding'])->findOrFail($this->guestId);
        $wedding = $guest->wedding;

        if (! $guest->token) {
            GuestToken::create([
                'wedding_id' => $guest->wedding_id,
                'guest_id' => $guest->id,
                'view_type' => $guest->guest_view_type,
            ]);
            $guest->load('token');
        }

        if (! $guest->email) {
            $guest->update(['invite_status' => 'failed']);
            return;
        }

        $coupleNames = trim(implode(' & ', array_filter([
            $wedding->couple_name_primary,
            $wedding->couple_name_secondary,
        ]))) ?: 'We';
        $venueLine = $wedding->primary_venue_name
            ? " at {$wedding->primary_venue_name}"
            : ($wedding->city ? " in {$wedding->city}" : '');
        $frontendUrl = rtrim(config('app.frontend_url'), '/');

        Mail::to($guest->email)->send(new TemplatedMail('guest_invite', [
            'first_name' => $guest->first_name,
            'couple_names' => $coupleNames,
            'event_date' => $wedding->event_date?->format('F j, Y') ?? 'a date to be confirmed',
            'venue_line' => $venueLine,
            'rsvp_url' => "{$frontendUrl}/g/{$guest->token->token}",
        ]));

        $guest->update(['invite_status' => 'sent']);
    }

    public function failed(?\Throwable $exception = null): void
    {
        Guest::whereKey($this->guestId)->update(['invite_status' => 'failed']);
    }
}
