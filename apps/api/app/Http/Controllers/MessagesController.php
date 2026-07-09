<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Guest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessagesController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $messages = $this->wedding($request)
            ->messages()
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['data' => $messages]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'subject'         => 'required|string|max:255',
            'body'            => 'required|string',
            'channel'         => 'required|in:email,sms,whatsapp,in_app',
            'message_type'    => 'nullable|in:general,rsvp_reminder,logistics,day_of,thank_you',
            'audience_filter' => 'nullable|array',
            'scheduled_at'    => 'nullable|date',
        ]);

        $message = $wedding->messages()->create([
            ...$data,
            'status' => ($data['scheduled_at'] ?? null) ? 'scheduled' : 'draft',
            'created_by' => $request->user()->id,
        ]);

        return response()->json(['data' => $message], 201);
    }

    public function show(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        return response()->json(['data' => $message->load('deliveries')]);
    }

    public function update(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        abort_if($message->status === 'sent', 422, 'Cannot edit a sent message.');

        $data = $request->validate([
            'subject'         => 'sometimes|string|max:255',
            'body'            => 'sometimes|string',
            'channel'         => 'nullable|in:email,sms,whatsapp,in_app',
            'message_type'    => 'nullable|in:general,rsvp_reminder,logistics,day_of,thank_you',
            'audience_filter' => 'nullable|array',
            'scheduled_at'    => 'nullable|date',
        ]);

        $message->update($data);

        return response()->json(['data' => $message->fresh()]);
    }

    public function send(Request $request, Message $message): JsonResponse
    {
        $this->authorizeMessage($request, $message);
        abort_if($message->status === 'sent', 422, 'Already sent.');

        $wedding = $this->wedding($request);
        $filter  = $message->audience_filter ?? [];

        $query = $wedding->guests();
        if (!empty($filter['attending_status'])) {
            $query->where('attending_status', $filter['attending_status']);
        }
        if (!empty($filter['guest_group'])) {
            $query->where('guest_group', $filter['guest_group']);
        }
        $guests = $query->get();

        foreach ($guests as $guest) {
            $message->deliveries()->create([
                'guest_id' => $guest->id,
                'status'   => 'queued',
                'channel'  => $message->channel,
            ]);
        }

        $message->update([
            'status'           => 'sent',
            'sent_at'          => now(),
            'recipient_count'  => $guests->count(),
        ]);

        return response()->json(['data' => $message->fresh(), 'recipients' => $guests->count()]);
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
}
