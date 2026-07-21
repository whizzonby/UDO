<?php

namespace App\Services;

use App\Models\GuestMessageDelivery;
use App\Models\Message;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class MessageAnalyticsService
{
    private const STATUSES = ['pending', 'sent', 'delivered', 'opened', 'failed', 'bounced'];

    public function summaryFor(Message $message): array
    {
        return $this->summariesFor(new EloquentCollection([$message]))[$message->id];
    }

    public function summariesFor(iterable $messages): array
    {
        $messages = collect($messages);
        $ids = $messages->pluck('id')->filter()->values();

        if ($ids->isEmpty()) {
            return [];
        }

        $statusRows = GuestMessageDelivery::query()
            ->selectRaw('message_id, status, COUNT(*) as aggregate, MAX(updated_at) as last_event_at')
            ->whereIn('message_id', $ids)
            ->groupBy('message_id', 'status')
            ->get()
            ->groupBy('message_id');

        $failureRows = GuestMessageDelivery::query()
            ->selectRaw('message_id, error_message, COUNT(*) as aggregate')
            ->whereIn('message_id', $ids)
            ->whereIn('status', ['failed', 'bounced'])
            ->whereNotNull('error_message')
            ->groupBy('message_id', 'error_message')
            ->orderByDesc('aggregate')
            ->get()
            ->groupBy('message_id');

        return $messages
            ->mapWithKeys(fn (Message $message) => [
                $message->id => $this->buildSummary(
                    $message,
                    $statusRows->get($message->id, collect()),
                    $failureRows->get($message->id, collect())
                ),
            ])
            ->all();
    }

    private function buildSummary(Message $message, Collection $statusRows, Collection $failureRows): array
    {
        $counts = array_fill_keys(self::STATUSES, 0);
        $lastEventAt = null;

        foreach ($statusRows as $row) {
            $status = $row->status ?: 'pending';
            $counts[$status] = ($counts[$status] ?? 0) + (int) $row->aggregate;
            $eventAt = $row->last_event_at ? (string) $row->last_event_at : null;

            if ($eventAt && (!$lastEventAt || $eventAt > $lastEventAt)) {
                $lastEventAt = $eventAt;
            }
        }

        $total = array_sum($counts);
        $attempted = $counts['sent'] + $counts['delivered'] + $counts['opened'] + $counts['failed'] + $counts['bounced'];
        $deliveredOrOpened = $counts['delivered'] + $counts['opened'];
        $failed = $counts['failed'] + $counts['bounced'];

        return [
            'total' => $total,
            'recipient_count' => (int) $message->recipient_count,
            'counts' => $counts,
            'attempted_count' => $attempted,
            'delivered_count' => $deliveredOrOpened,
            'failed_count' => $failed,
            'retryable_count' => $failed,
            'send_rate' => $this->rate($attempted, $total),
            'delivery_rate' => $this->rate($deliveredOrOpened, $total),
            'failure_rate' => $this->rate($failed, $total),
            'last_event_at' => $lastEventAt ? Carbon::parse($lastEventAt)->toJSON() : null,
            'failure_reasons' => $failureRows
                ->take(5)
                ->map(fn ($row) => [
                    'message' => $row->error_message,
                    'count' => (int) $row->aggregate,
                ])
                ->values()
                ->all(),
        ];
    }

    private function rate(int $count, int $total): float
    {
        if ($total === 0) {
            return 0.0;
        }

        return round(($count / $total) * 100, 1);
    }
}
