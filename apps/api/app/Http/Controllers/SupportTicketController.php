<?php

namespace App\Http\Controllers;

use App\Models\SupportTicket;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class SupportTicketController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $weddingId = $user->active_wedding_id;

        $tickets = SupportTicket::query()
            ->where('user_id', $user->id)
            ->when($weddingId, fn ($query) => $query->where(function ($scoped) use ($weddingId) {
                $scoped->where('wedding_id', $weddingId)->orWhereNull('wedding_id');
            }))
            ->latest()
            ->limit(50)
            ->get()
            ->map(fn (SupportTicket $ticket) => $this->serialize($ticket));

        return response()->json(['data' => $tickets]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'subject' => ['required', 'string', 'max:255'],
            'body' => ['required', 'string', 'max:5000'],
            'priority' => ['nullable', Rule::in(['low', 'normal', 'high', 'urgent'])],
            'channel' => ['nullable', Rule::in(['in_app', 'email', 'whatsapp', 'chat'])],
        ]);

        $ticket = SupportTicket::create([
            'user_id' => $request->user()->id,
            'wedding_id' => $request->user()->active_wedding_id,
            'subject' => $data['subject'],
            'body' => $data['body'],
            'priority' => $data['priority'] ?? 'normal',
            'channel' => $data['channel'] ?? 'in_app',
            'status' => 'open',
        ]);

        return response()->json(['data' => $this->serialize($ticket)], 201);
    }

    private function serialize(SupportTicket $ticket): array
    {
        return [
            'id' => $ticket->id,
            'reference' => $ticket->reference,
            'subject' => $ticket->subject,
            'body' => $ticket->body,
            'status' => $ticket->status,
            'priority' => $ticket->priority,
            'channel' => $ticket->channel,
            'created_at' => optional($ticket->created_at)->toIso8601String(),
            'updated_at' => optional($ticket->updated_at)->toIso8601String(),
            'first_responded_at' => optional($ticket->first_responded_at)->toIso8601String(),
            'resolved_at' => optional($ticket->resolved_at)->toIso8601String(),
        ];
    }
}
