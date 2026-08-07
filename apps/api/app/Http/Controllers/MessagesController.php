<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Services\MessageAnalyticsService;
use App\Services\MessageDispatchService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessagesController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'manage_messages'), 403);
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $messages = $this->wedding($request)
            ->messages()
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['data' => $this->withDeliverySummaries($messages)]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'subject'         => 'required|string|max:255',
            'body'            => 'required|string',
            'channel'         => 'required|in:email,sms,whatsapp,in_app',
            'message_type'    => 'nullable|in:general,invitation,rsvp_reminder,logistics,day_of,thank_you,emergency',
            'audience_filter' => 'nullable|array',
            'scheduled_at'    => 'nullable|date',
        ]);

        $message = $wedding->messages()->create([
            ...$data,
            'status' => ($data['scheduled_at'] ?? null) ? 'scheduled' : 'draft',
            'created_by' => $request->user()->id,
        ]);

        return response()->json(['data' => $this->withDeliverySummary($message)], 201);
    }

    public function show(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        return response()->json(['data' => $this->withDeliverySummary($message->load('deliveries.guest'))]);
    }

    public function update(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        abort_if($message->status === 'sent', 422, 'Cannot edit a sent message.');

        $data = $request->validate([
            'subject'         => 'sometimes|string|max:255',
            'body'            => 'sometimes|string',
            'channel'         => 'nullable|in:email,sms,whatsapp,in_app',
            'message_type'    => 'nullable|in:general,invitation,rsvp_reminder,logistics,day_of,thank_you,emergency',
            'audience_filter' => 'nullable|array',
            'scheduled_at'    => 'nullable|date',
        ]);

        $message->update($data);

        return response()->json(['data' => $this->withDeliverySummary($message->fresh())]);
    }

    public function send(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        abort_if(in_array($message->status, ['sending', 'sent'], true), 422, 'Already sent or currently sending.');

        $recipients = app(MessageDispatchService::class)->dispatch(
            $message->load('wedding'),
            $request->boolean('force')
        );

        return response()->json([
            'data' => $this->withDeliverySummary($message->fresh()),
            'recipients' => $recipients,
        ]);
    }

    public function retryFailed(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);

        $queued = app(MessageDispatchService::class)->retryFailed($message);

        return response()->json([
            'data' => $this->withDeliverySummary($message->fresh('deliveries')),
            'queued' => $queued,
            'message' => $queued > 0
                ? 'Failed deliveries queued for retry.'
                : 'No failed deliveries were available to retry.',
        ]);
    }

    public function deliverySummary(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);

        return response()->json([
            'data' => app(MessageAnalyticsService::class)->summaryFor($message),
        ]);
    }

    public function destroy(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        abort_if($message->status === 'sent', 422, 'Cannot delete a sent message.');
        $message->delete();
        return response()->json(null, 204);
    }

    private function authorizeMessage(Request $request, Message $message): void
    {
        abort_unless($message->wedding_id === $this->wedding($request)->id, 403);
    }

    private function withDeliverySummary(Message $message): array
    {
        $data = $message->toArray();
        $data['delivery_summary'] = app(MessageAnalyticsService::class)->summaryFor($message);

        return $data;
    }

    private function withDeliverySummaries($messages): array
    {
        $summaries = app(MessageAnalyticsService::class)->summariesFor($messages);

        return $messages
            ->map(function (Message $message) use ($summaries) {
                $data = $message->toArray();
                $data['delivery_summary'] = $summaries[$message->id];

                return $data;
            })
            ->values()
            ->all();
    }
}
