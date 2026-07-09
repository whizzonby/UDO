<?php

namespace App\Http\Controllers\WeddingParty;

use App\Http\Controllers\Controller;
use App\Models\WeddingPartyEmergencyContact;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;

class EmergencyContactController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $items = $this->wedding($request)->weddingPartyEmergencyContacts()->get();
        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'name'         => 'required|string|max:255',
            'relationship' => 'nullable|string|max:100',
            'phone'        => 'required|string|max:50',
            'is_primary'   => 'boolean',
            'sort_order'   => 'nullable|integer',
        ]);

        $item = $wedding->weddingPartyEmergencyContacts()->create($data);

        return response()->json(['data' => $item], 201);
    }

    public function update(Request $request, WeddingPartyEmergencyContact $emergencyContact): JsonResponse
    {
        $this->authorize($request, $emergencyContact);

        $data = $request->validate([
            'name'         => 'sometimes|string|max:255',
            'relationship' => 'nullable|string|max:100',
            'phone'        => 'sometimes|string|max:50',
            'is_primary'   => 'boolean',
            'sort_order'   => 'nullable|integer',
        ]);

        $emergencyContact->update($data);

        return response()->json(['data' => $emergencyContact->fresh()]);
    }

    public function destroy(Request $request, WeddingPartyEmergencyContact $emergencyContact): JsonResponse
    {
        $this->authorize($request, $emergencyContact);
        $emergencyContact->delete();
        return response()->json(null, 204);
    }

    public function broadcast(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'message' => 'required|string|max:2000',
        ]);

        $recipients = $wedding->guests()
            ->where('guest_group', 'wedding_party')
            ->whereNotNull('email')
            ->get(['id', 'first_name', 'email']);

        foreach ($recipients as $guest) {
            Mail::raw($data['message'], function ($mail) use ($guest, $wedding) {
                $mail->to($guest->email)
                    ->subject("Emergency Alert — {$wedding->title}");
            });
        }

        return response()->json([
            'recipients' => $recipients->count(),
            'sent_at'    => now()->toIso8601String(),
        ]);
    }

    private function authorize(Request $request, WeddingPartyEmergencyContact $emergencyContact): void
    {
        abort_unless($emergencyContact->wedding_id === $this->wedding($request)->id, 403);
    }
}
