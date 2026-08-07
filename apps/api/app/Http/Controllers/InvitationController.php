<?php

namespace App\Http\Controllers;

use App\Models\Invitation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

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

    /**
     * Lets a couple who already had an invitation designed elsewhere (e.g. a
     * Canva export) upload it directly instead of using the in-app template
     * builder. Setting imported_asset_url switches the wizard's Design/
     * Wording/Preview steps to render this file instead of the templated
     * card — the wording fields are left untouched underneath in case the
     * couple later removes the import and goes back to the template.
     */
    public function importAsset(Request $request): JsonResponse
    {
        $wedding    = $this->wedding($request);
        $invitation = $wedding->invitation ?? Invitation::create(['wedding_id' => $wedding->id]);

        $data = $request->validate([
            'file' => 'required|file|max:20480|mimes:jpg,jpeg,png,webp,pdf',
        ]);

        $uploaded = $request->file('file');
        $path = $uploaded->store("weddings/{$wedding->id}/invitation", 'public');
        $type = strtolower($uploaded->getClientOriginalExtension()) === 'pdf' ? 'pdf' : 'image';

        $invitation->update([
            'imported_asset_url' => Storage::url($path),
            'imported_asset_type' => $type,
        ]);

        return response()->json(['data' => $invitation->fresh()]);
    }

    public function removeImportedAsset(Request $request): JsonResponse
    {
        $wedding    = $this->wedding($request);
        $invitation = $wedding->invitation;
        abort_unless($invitation, 404);

        $invitation->update([
            'imported_asset_url' => null,
            'imported_asset_type' => null,
        ]);

        return response()->json(['data' => $invitation->fresh()]);
    }
}
