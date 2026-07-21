<?php

namespace App\Http\Controllers\Webhooks;

use App\Http\Controllers\Controller;
use App\Models\GuestMessageDelivery;
use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Symfony\Component\HttpFoundation\Response;

class TwilioMessageStatusController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        if (! $this->hasValidSignature($request)) {
            return response()->json(['message' => 'Invalid Twilio signature.'], Response::HTTP_FORBIDDEN);
        }

        $data = $request->validate([
            'MessageSid' => 'required|string',
            'MessageStatus' => 'required|string',
            'ErrorMessage' => 'nullable|string',
        ]);

        $delivery = GuestMessageDelivery::with('message')
            ->where('external_id', $data['MessageSid'])
            ->first();

        if (! $delivery) {
            return response()->json(['message' => 'Delivery not found.'], Response::HTTP_NOT_FOUND);
        }

        $mapped = $this->mapStatus($data['MessageStatus']);
        $updates = [
            'status' => $mapped,
            'error_message' => $data['ErrorMessage'] ?? null,
        ];

        if ($mapped === 'sent' && ! $delivery->sent_at) {
            $updates['sent_at'] = now();
        }

        if ($mapped === 'delivered') {
            $updates['delivered_at'] = now();
        }

        if ($mapped === 'opened') {
            $updates['opened_at'] = now();
        }

        $delivery->update($updates);
        $this->updateMessageStatus($delivery->message);

        return response()->json(['message' => 'Delivery status updated.']);
    }

    private function mapStatus(string $status): string
    {
        return match ($status) {
            'delivered' => 'delivered',
            'failed', 'undelivered' => 'failed',
            'read' => 'opened',
            'queued', 'accepted', 'scheduled', 'sending', 'sent' => 'sent',
            default => 'sent',
        };
    }

    private function hasValidSignature(Request $request): bool
    {
        if (! config('services.twilio.validate_webhooks')) {
            return true;
        }

        $authToken = config('services.twilio.auth_token');
        $signature = $request->header('X-Twilio-Signature');

        if (! $authToken || ! $signature) {
            return false;
        }

        $url = $request->fullUrl();
        $payload = $url;
        foreach (Arr::sortRecursive($request->post()) as $key => $value) {
            $payload .= $key.$value;
        }

        $expected = base64_encode(hash_hmac('sha1', $payload, $authToken, true));

        return hash_equals($expected, $signature);
    }

    private function updateMessageStatus(Message $message): void
    {
        $message->loadCount([
            'deliveries as pending_deliveries_count' => fn ($query) => $query->whereIn('status', ['pending', 'queued']),
            'deliveries as failed_deliveries_count' => fn ($query) => $query->where('status', 'failed'),
        ]);

        if ($message->pending_deliveries_count > 0) {
            return;
        }

        $message->update([
            'status' => $message->failed_deliveries_count > 0 ? 'failed' : 'sent',
            'sent_at' => $message->sent_at ?? now(),
        ]);
    }
}
