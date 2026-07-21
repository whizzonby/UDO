<?php

namespace App\Console\Commands;

use App\Models\Message;
use App\Services\MessageDispatchService;
use Illuminate\Console\Command;

class DispatchScheduledMessagesCommand extends Command
{
    protected $signature = 'messages:dispatch-scheduled {--limit=100 : Maximum due messages to dispatch}';

    protected $description = 'Dispatch scheduled wedding messages that are due for delivery.';

    public function handle(MessageDispatchService $dispatcher): int
    {
        $limit = max(1, (int) $this->option('limit'));
        $dispatched = 0;

        Message::with('wedding')
            ->where('status', 'scheduled')
            ->whereNotNull('scheduled_at')
            ->where('scheduled_at', '<=', now())
            ->orderBy('scheduled_at')
            ->limit($limit)
            ->get()
            ->each(function (Message $message) use ($dispatcher, &$dispatched) {
                if ($dispatcher->dispatch($message) > 0 || $message->fresh()->status === 'sent') {
                    $dispatched++;
                }
            });

        $this->info("Dispatched {$dispatched} scheduled message(s).");

        return self::SUCCESS;
    }
}
