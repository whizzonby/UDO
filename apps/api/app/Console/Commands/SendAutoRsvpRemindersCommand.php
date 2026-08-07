<?php

namespace App\Console\Commands;

use App\Models\AuditLog;
use App\Models\Guest;
use App\Models\GuestExperienceConfig;
use App\Services\MessageDispatchService;
use Illuminate\Console\Command;

class SendAutoRsvpRemindersCommand extends Command
{
    protected $signature = 'automations:send-rsvp-reminders';

    protected $description = 'Sends a one-time automatic RSVP reminder to guests who have not responded, for weddings with this automation enabled.';

    public function handle(MessageDispatchService $dispatcher): int
    {
        $sent = 0;

        GuestExperienceConfig::where('auto_rsvp_reminder_enabled', true)
            ->with('wedding')
            ->get()
            ->each(function (GuestExperienceConfig $config) use ($dispatcher, &$sent) {
                $wedding = $config->wedding;
                if (! $wedding || ! $wedding->owner_user_id) {
                    return;
                }

                $cutoff = now()->subDays($config->auto_rsvp_reminder_days);

                $guests = $wedding->guests()
                    ->whereIn('attending_status', [null, 'pending'])
                    ->where('invite_status', 'sent')
                    ->whereNull('last_auto_reminder_at')
                    ->get()
                    ->filter(function (Guest $guest) use ($cutoff) {
                        $invitedAt = AuditLog::where('auditable_type', Guest::class)
                            ->where('auditable_id', $guest->id)
                            ->where('action', 'guest.invite_queued')
                            ->latest()
                            ->value('created_at');

                        return $invitedAt && $invitedAt <= $cutoff;
                    });

                foreach ($guests as $guest) {
                    $channel = $guest->email && ! $guest->email_opt_out
                        ? 'email'
                        : (($guest->phone && ! $guest->sms_opt_out) ? 'sms' : null);

                    if (! $channel) {
                        continue;
                    }

                    $message = $wedding->messages()->create([
                        'campaign_name' => 'Automatic RSVP reminder',
                        'subject' => "Don't forget to RSVP!",
                        'body' => "We'd love to know if you're joining us — please RSVP when you get a chance.",
                        'channel' => $channel,
                        'message_type' => 'rsvp_reminder',
                        'audience_filter' => ['guest_ids' => [$guest->id]],
                        'status' => 'draft',
                        'created_by' => $wedding->owner_user_id,
                    ]);

                    $dispatcher->dispatch($message->load('wedding'));
                    $guest->update(['last_auto_reminder_at' => now()]);
                    $sent++;
                }
            });

        $this->info("Sent {$sent} automatic RSVP reminder(s).");

        return self::SUCCESS;
    }
}
