<?php

namespace App\Http\Controllers\Api\Messages;

use App\Events\ActivityRecorded;
use App\Events\AnnouncementSent;
use App\Http\Controllers\Controller;
use App\Models\GuestMessage;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MessagesController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        return $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();
    }

    // GET /messages
    public function index(Request $request): JsonResponse
    {
        $wedding  = $this->wedding($request);
        $messages = $wedding->guestMessages()->get();

        return response()->json([
            'messages' => $messages->map(fn ($m) => $this->format($m)),
        ]);
    }

    // POST /messages
    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'subject'          => 'nullable|string|max:255',
            'body'             => 'required|string|max:5000',
            'channel'          => ['required', Rule::in(['in_app', 'email', 'sms'])],
            'recipient_filter' => 'nullable|array',
            'recipient_filter.type' => ['nullable', Rule::in(['all', 'rsvp_status', 'group', 'vip', 'not_invited', 'awaiting'])],
            'recipient_filter.value' => 'nullable|string',
        ]);

        $recipientCount = $this->countRecipients($wedding, $data['recipient_filter'] ?? ['type' => 'all']);

        $message = $wedding->guestMessages()->create([
            'subject'          => $data['subject'] ?? null,
            'body'             => $data['body'],
            'channel'          => $data['channel'],
            'recipient_filter' => $data['recipient_filter'] ?? ['type' => 'all'],
            'recipient_count'  => $recipientCount,
            'status'           => 'sent',
            'sent_at'          => now(),
        ]);

        // Push to the admin activity feed (private channel)
        ActivityRecorded::dispatch(
            $wedding->id,
            'announcement',
            'You',
            $message->body,
            $message->created_at->toIso8601String(),
        );

        // Push to the guest portal (public channel) for in-app messages only
        if ($data['channel'] === 'in_app') {
            AnnouncementSent::dispatch(
                $wedding->id,
                $message->id,
                $message->subject,
                $message->body,
                $message->sent_at->toIso8601String(),
            );
        }

        return response()->json(['message' => $this->format($message)], 201);
    }

    // DELETE /messages/{message}
    public function destroy(Request $request, GuestMessage $message): JsonResponse
    {
        abort_unless($message->wedding_id === $this->wedding($request)->id, 403);
        $message->delete();
        return response()->json(['message' => 'Deleted']);
    }

    private function countRecipients(Wedding $wedding, array $filter): int
    {
        $query = $wedding->guests();

        return match ($filter['type'] ?? 'all') {
            'rsvp_status' => $query->where('rsvp_status', $filter['value'] ?? 'pending')->count(),
            'group'       => $query->where('group', $filter['value'] ?? '')->count(),
            'vip'         => $query->where('is_vip', true)->count(),
            'not_invited' => $query->whereNull('invitation_sent_at')->count(),
            'awaiting'    => $query->whereNotNull('invitation_sent_at')
                                   ->whereNull('rsvp_responded_at')->count(),
            default       => $query->count(),
        };
    }

    private function format(GuestMessage $m): array
    {
        return [
            'id'               => $m->id,
            'subject'          => $m->subject,
            'body'             => $m->body,
            'channel'          => $m->channel,
            'recipient_filter' => $m->recipient_filter,
            'recipient_count'  => $m->recipient_count,
            'status'           => $m->status,
            'sent_at'          => $m->sent_at?->toIso8601String(),
            'created_at'       => $m->created_at?->toIso8601String(),
        ];
    }
}
