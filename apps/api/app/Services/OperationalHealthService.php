<?php

namespace App\Services;

use App\Models\GuestMessageDelivery;
use App\Models\GuestToken;
use App\Models\Message;
use App\Models\Wedding;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class OperationalHealthService
{
    public function snapshot(?Wedding $wedding = null): array
    {
        if (app()->environment('testing')) {
            return $this->buildSnapshot($wedding);
        }

        $cacheKey = 'operational-health:' . ($wedding?->id ?? 'global');

        return Cache::remember($cacheKey, now()->addSeconds(30), fn () => $this->buildSnapshot($wedding));
    }

    private function buildSnapshot(?Wedding $wedding = null): array
    {
            $deliveryQuery = GuestMessageDelivery::query();
            $messageQuery = Message::query();
            $tokenQuery = GuestToken::query();

            if ($wedding) {
                $messageIds = $wedding->messages()->pluck('id');
                $deliveryQuery->whereIn('message_id', $messageIds);
                $messageQuery->where('wedding_id', $wedding->id);
                $tokenQuery->where('wedding_id', $wedding->id);
            }

            $pendingDeliveries = (clone $deliveryQuery)->where('status', 'pending')->count();
            $failedDeliveries = (clone $deliveryQuery)->where('status', 'failed')->count();
            $staleSendingMessages = (clone $messageQuery)
                ->where('status', 'sending')
                ->where('updated_at', '<', now()->subMinutes(15))
                ->count();
            $expiredActiveTokens = (clone $tokenQuery)
                ->where('revoked', false)
                ->whereNotNull('expires_at')
                ->where('expires_at', '<', now())
                ->count();
            $tokensExpiringSoon = (clone $tokenQuery)
                ->where('revoked', false)
                ->whereBetween('expires_at', [now(), now()->addDays(7)])
                ->count();
            $failedJobs = $this->failedJobCount();

            $score = 100;
            $score -= min(30, $failedDeliveries * 5);
            $score -= min(25, $staleSendingMessages * 10);
            $score -= min(20, $failedJobs * 5);
            $score -= min(15, $expiredActiveTokens * 3);
            $score = max(0, $score);

            return [
                'status' => $this->statusLabel($score, $failedDeliveries, $staleSendingMessages, $failedJobs),
                'score' => $score,
                'checked_at' => now()->toISOString(),
                'queue' => [
                    'connection' => config('queue.default'),
                    'failed_jobs' => $failedJobs,
                    'pending_deliveries' => $pendingDeliveries,
                    'failed_deliveries' => $failedDeliveries,
                    'stale_sending_messages' => $staleSendingMessages,
                ],
                'tokens' => [
                    'expired_active' => $expiredActiveTokens,
                    'expiring_soon' => $tokensExpiringSoon,
                ],
                'cache' => [
                    'driver' => config('cache.default'),
                    'ttl_seconds' => 30,
                ],
            ];
    }

    private function failedJobCount(): int
    {
        if (! Schema::hasTable('failed_jobs')) {
            return 0;
        }

        return (int) DB::table('failed_jobs')->count();
    }

    private function statusLabel(int $score, int $failedDeliveries, int $staleSendingMessages, int $failedJobs): string
    {
        if ($failedJobs > 0 || $staleSendingMessages > 0 || $failedDeliveries > 0 || $score < 70) {
            return 'attention';
        }

        if ($score < 90) {
            return 'watch';
        }

        return 'healthy';
    }
}
