<?php

namespace App\Http\Controllers;

use App\Models\Invitation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InvitationController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function show(Request $request): JsonResponse
    {
        $wedding    = $this->wedding($request);
        $invitation = $wedding->invitation;

        return response()->json(['data' => $invitation]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'title_line'       => 'nullable|string',
            'invitation_text'  => 'nullable|string',
            'date_text'        => 'nullable|string',
            'venue_text'       => 'nullable|string',
            'optional_quote'   => 'nullable|string',
            'rsvp_deadline_text' => 'nullable|string',
            'cover_image_url'  => 'nullable|url',
            'template_id'      => 'nullable|string',
            'theme_id'         => 'nullable|string',
        ]);

        $invitation = $wedding->invitation()->updateOrCreate(['wedding_id' => $wedding->id], $data);

        return response()->json(['data' => $invitation], 201);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding    = $this->wedding($request);
        $invitation = $wedding->invitation ?? Invitation::create(['wedding_id' => $wedding->id]);

        $data = $request->validate([
            'title_line'         => 'nullable|string',
            'invitation_text'    => 'nullable|string',
            'date_text'          => 'nullable|string',
            'venue_text'         => 'nullable|string',
            'optional_quote'     => 'nullable|string',
            'rsvp_deadline_text' => 'nullable|string',
            'cover_image_url'    => 'nullable|url',
            'template_id'        => 'nullable|string',
            'theme_id'           => 'nullable|string',
        ]);

        $invitation->update($data);

        return response()->json(['data' => $invitation->fresh()]);
    }

    public function publish(Request $request): JsonResponse
    {
        $wedding    = $this->wedding($request);
        $invitation = $wedding->invitation ?? Invitation::create(['wedding_id' => $wedding->id]);

        $invitation->update(['published_at' => now()]);

        return response()->json(['data' => $invitation, 'message' => 'Invitation published.']);
    }
}
