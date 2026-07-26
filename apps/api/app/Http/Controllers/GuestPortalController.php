<?php

namespace App\Http\Controllers;

use App\Models\GalleryAsset;
use App\Models\GuestToken;
use App\Models\GuestExperienceConfig;
use App\Models\RegistryContribution;
use App\Models\RegistryItem;
use App\Models\ThankYouRecord;
use App\Services\AuditLogService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GuestPortalController extends Controller
{
    public function show(string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with(['guest', 'wedding.experienceConfig'])->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');

        $guest   = $guestToken->guest;
        $wedding = $guestToken->wedding;
        $config = $this->experienceConfig($wedding);
        $isPublished = $config->publish_state === 'published';

        return response()->json([
            'view_type' => $guestToken->view_type,
            'experience' => $this->experiencePayload($config),
            'guest'     => [
                'id'               => $guest->id,
                'first_name'       => $guest->first_name,
                'last_name'        => $guest->last_name,
                'attending_status' => $guest->attending_status,
                'plus_one_allowed' => $guest->plus_one_allowed,
                'plus_one_count'   => $guest->plus_one_count,
                'meal_preference'  => $guest->meal_preference,
                'travel_required'  => $guest->travel_required,
                'arrival_date'     => $guest->arrival_date?->toDateString(),
                'arrival_time'     => $guest->arrival_time,
                'departure_date'   => $guest->departure_date?->toDateString(),
                'departure_time'   => $guest->departure_time,
                'arrival_airport'  => $guest->arrival_airport,
                'communication_preferences' => [
                    'email_opt_out' => $guest->email_opt_out,
                    'sms_opt_out' => $guest->sms_opt_out,
                    'whatsapp_opt_out' => $guest->whatsapp_opt_out,
                    'updated_at' => $guest->communication_preferences_updated_at?->toISOString(),
                ],
            ],
            'wedding' => [
                'title'                => $wedding->title,
                'couple_name_primary'  => $wedding->couple_name_primary,
                'couple_name_secondary' => $wedding->couple_name_secondary,
                'event_date'           => $wedding->event_date?->toDateString(),
                'city'                 => $wedding->city,
                'country'              => $wedding->country,
                'venue'                => $wedding->primary_venue_name,
                'venue_address'        => $wedding->primary_venue_address,
                'rsvp_deadline'        => $wedding->rsvp_deadline?->toDateString(),
            ],
            'sections' => $isPublished ? $this->sectionPayload($wedding, $config, $guest) : [
                'schedule' => [],
                'accommodation' => [],
                'transport' => [],
                'seating' => null,
                'registry' => [],
                'gallery' => [],
                'live_updates' => [],
            ],
        ]);
    }

    public function rsvp(Request $request, string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with(['guest', 'wedding.experienceConfig'])->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');
        $config = $this->experienceConfig($guestToken->wedding);
        abort_unless($config->publish_state === 'published' && $config->rsvp_enabled, 403, 'RSVPs are not currently open.');

        $data = $request->validate([
            'attending_status' => 'required|in:yes,no',
            'plus_one_count'   => 'nullable|integer|min:0|max:5',
            'meal_preference'  => 'nullable|string',
            'dietary_note'     => 'nullable|string',
        ]);

        $guest = $guestToken->guest;

        $update = ['attending_status' => $data['attending_status']];

        if (isset($data['plus_one_count']) && $guest->plus_one_allowed && $config->plus_one_enabled) {
            $update['plus_one_count'] = $data['plus_one_count'];
        }

        if (isset($data['meal_preference']) && $config->meal_selection_enabled) {
            $update['meal_preference'] = $data['meal_preference'];
        }

        if (isset($data['dietary_note'])) {
            $update['dietary_note'] = $data['dietary_note'];
        }

        $guest->update($update);

        app(AuditLogService::class)->record(
            'guest.rsvp_submitted',
            $guestToken->wedding,
            null,
            $guest->fresh(),
            null,
            ['attending_status' => $data['attending_status']],
            request: $request,
        );

        return response()->json(['message' => 'RSVP saved.', 'status' => $data['attending_status']]);
    }

    public function updatePreferences(Request $request, string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with('guest')->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');

        $data = $request->validate([
            'email_opt_out' => 'nullable|boolean',
            'sms_opt_out' => 'nullable|boolean',
            'whatsapp_opt_out' => 'nullable|boolean',
        ]);

        $guest = $guestToken->guest;
        $guest->update([
            ...$data,
            'communication_preferences_updated_at' => now(),
        ]);
        $guest = $guest->fresh();

        return response()->json([
            'message' => 'Communication preferences updated.',
            'communication_preferences' => [
                'email_opt_out' => $guest->email_opt_out,
                'sms_opt_out' => $guest->sms_opt_out,
                'whatsapp_opt_out' => $guest->whatsapp_opt_out,
                'updated_at' => $guest->communication_preferences_updated_at?->toISOString(),
            ],
        ]);
    }

    public function uploadPhoto(Request $request, string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with(['guest', 'wedding'])->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');
        $config = $this->experienceConfig($guestToken->wedding);
        abort_unless($config->publish_state === 'published' && $config->allow_photo_uploads, 403, 'Photo uploads are not currently open.');

        $data = $request->validate([
            'file' => 'required|file|mimes:jpg,jpeg,png,gif,webp,mp4,mov,webm,mp3,wav,m4a,aac,ogg|max:51200',
            'caption' => 'nullable|string|max:255',
        ]);

        $file = $data['file'];
        $wedding = $guestToken->wedding;
        $guest = $guestToken->guest;
        $path = $file->store("weddings/{$wedding->id}/guest-uploads", 'public');
        $url = Storage::url($path);
        $mimeType = (string) $file->getMimeType();

        $asset = $wedding->galleryAssets()->create([
            'uploaded_by_guest_id' => $guest->id,
            'type' => GalleryAsset::resolveTypeFromMime($mimeType),
            'source' => 'upload',
            'url' => $url,
            'thumbnail_url' => $url,
            'original_filename' => $file->getClientOriginalName(),
            'file_size_bytes' => $file->getSize(),
            'album' => 'guest_uploads',
            'caption' => $data['caption'] ?? null,
            'approved' => false,
        ]);

        return response()->json(['data' => $asset, 'message' => 'Photo uploaded for review.'], 201);
    }

    public function submitGuestbookMessage(Request $request, string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with(['guest', 'wedding'])->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');
        $config = $this->experienceConfig($guestToken->wedding);
        abort_unless($config->publish_state === 'published' && $config->allow_messages, 403, 'The guestbook is not currently open.');

        $data = $request->validate([
            'message' => 'required|string|max:2000',
        ]);

        $wedding = $guestToken->wedding;
        $guestbook = $wedding->memoryGuestbook()->firstOrCreate([]);

        $entry = $guestbook->entries()->create([
            'guest_id' => $guestToken->guest->id,
            'guest_name' => $guestToken->guest->full_name,
            'message' => $data['message'],
            'approved' => false,
        ]);

        return response()->json(['data' => $entry, 'message' => 'Thank you for signing the guestbook.'], 201);
    }

    public function contributeRegistry(Request $request, string $token, RegistryItem $registryItem): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with(['guest', 'wedding.experienceConfig'])->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');
        abort_unless($registryItem->wedding_id === $guestToken->wedding_id && $registryItem->is_visible, 403);
        $config = $this->experienceConfig($guestToken->wedding);
        abort_unless($config->publish_state === 'published' && $config->show_registry, 403, 'Registry is not currently available.');

        $data = $request->validate([
            'contributor_name' => 'nullable|string|max:255',
            'contributor_email' => 'nullable|email|max:255',
            'amount' => 'nullable|numeric|min:0',
            'quantity' => 'nullable|integer|min:1',
            'message' => 'nullable|string',
        ]);
        $guest = $guestToken->guest;
        $contribution = $registryItem->contributions()->create([
            'wedding_id' => $guestToken->wedding_id,
            'guest_id' => $guest->id,
            'contributor_name' => ($data['contributor_name'] ?? null) ?: ($guest->full_name ?: 'Guest'),
            'contributor_email' => $data['contributor_email'] ?? $guest->email,
            'amount' => $data['amount'] ?? ($registryItem->type === 'cash_fund' ? 0 : $registryItem->price),
            'quantity' => $data['quantity'] ?? 1,
            'payment_status' => 'completed',
            'message' => $data['message'] ?? null,
            'paid_at' => now(),
        ]);
        $this->refreshRegistryItemTotals($registryItem);
        $this->ensureThankYouRecord($contribution);

        return response()->json(['message' => 'Contribution recorded.', 'data' => $contribution], 201);
    }

    private function experienceConfig($wedding): GuestExperienceConfig
    {
        return $wedding->experienceConfig ?? $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'published_at' => now(),
            'show_schedule' => true,
            'show_venue_map' => true,
            'show_accommodation' => true,
            'show_transport' => true,
            'show_dress_code' => true,
            'show_registry' => true,
            'rsvp_enabled' => true,
            'meal_selection_enabled' => true,
            'plus_one_enabled' => true,
        ]);
    }

    private function experiencePayload(GuestExperienceConfig $config): array
    {
        return [
            'publish_state' => $config->publish_state,
            'published' => $config->publish_state === 'published',
            'welcome_message' => $config->welcome_message,
            'dress_code' => $config->dress_code,
            'dress_code_details' => $config->dress_code_details,
            'cover_image_url' => $config->cover_image_url,
            'theme_color' => $config->theme_color ?: '#285301',
            'layout_order' => $config->layout_order ?: [
                'details',
                'rsvp',
                'schedule',
                'seating',
                'dress_code',
                'registry',
                'gallery',
                'live_feed',
                'preferences',
            ],
            'access_rules' => $config->access_rules ?: [],
            'sections' => [
                'schedule' => $config->show_schedule,
                'venue_map' => $config->show_venue_map,
                'accommodation' => $config->show_accommodation,
                'transport' => $config->show_transport,
                'seating' => $config->show_seating,
                'dress_code' => $config->show_dress_code,
                'registry' => $config->show_registry,
                'gallery' => $config->show_gallery,
                'live_feed' => $config->show_live_feed,
                'photo_uploads' => $config->allow_photo_uploads,
                'messages' => $config->allow_messages,
                'rsvp' => $config->rsvp_enabled,
                'meal_selection' => $config->meal_selection_enabled,
                'plus_one' => $config->plus_one_enabled,
            ],
        ];
    }

    private function sectionPayload($wedding, GuestExperienceConfig $config, $guest): array
    {
        return [
            'schedule' => $config->show_schedule
                ? $wedding->timelineItems()
                    ->where('visible_to_guests', true)
                    ->orderBy('event_date')
                    ->orderBy('start_time')
                    ->get(['id', 'title', 'description', 'event_type', 'event_date', 'start_time', 'end_time', 'location'])
                : [],
            'accommodation' => $config->show_accommodation
                ? $wedding->accommodationOptions()
                    ->orderBy('distance_from_venue_km')
                    ->get(['id', 'name', 'type', 'address', 'city', 'country', 'price_per_night', 'currency', 'booking_code', 'website', 'distance_from_venue_km', 'check_in_date', 'check_out_date', 'notes'])
                    ->map(fn ($option) => [
                        ...$option->toArray(),
                        'assigned_to_guest' => (int) $guest->hotel_assignment_id === (int) $option->id,
                    ])
                : [],
            'transport' => $config->show_transport
                ? $wedding->transportGroups()
                    ->where(function ($query) use ($guest) {
                        $query
                            ->where('id', $guest->transport_assignment_id)
                            ->orWhereHas('assignments', fn ($assignmentQuery) => $assignmentQuery->where('guest_id', $guest->id));
                    })
                    ->orderBy('departure_time')
                    ->get(['id', 'name', 'type', 'pickup_location', 'dropoff_location', 'departure_time', 'driver_name', 'driver_phone', 'notes'])
                : [],
            'seating' => $config->show_seating && $guest->seating_assignment_id
                ? $this->seatingPayload($guest)
                : null,
            'registry' => $config->show_registry
                ? $wedding->registryItems()
                    ->where('is_visible', true)
                    ->orderBy('sort_order')
                    ->get(['id', 'type', 'name', 'description', 'image_url', 'store_name', 'store_url', 'price', 'currency', 'fund_goal', 'fund_raised', 'is_priority'])
                : [],
            'gallery' => $config->show_gallery
                ? $wedding->galleryAssets()
                    ->where('approved', true)
                    ->orderByDesc('is_featured')
                    ->orderByDesc('created_at')
                    ->limit(12)
                    ->get(['id', 'type', 'url', 'thumbnail_url', 'caption', 'album', 'is_featured'])
                : [],
            'live_updates' => $config->show_live_feed
                ? $wedding->liveUpdates()
                    ->where('visible_to_guests', true)
                    ->where('bride_only', false)
                    ->orderByDesc('pinned')
                    ->orderByDesc('event_time')
                    ->limit(10)
                    ->get(['id', 'type', 'title', 'body', 'image_url', 'pinned', 'event_time'])
                : [],
            'guestbook' => $config->allow_messages
                ? ($wedding->memoryGuestbook?->entries()->where('approved', true)->limit(50)->get(['guest_name', 'message', 'created_at']) ?? [])
                : [],
        ];
    }

    private function seatingPayload($guest): ?array
    {
        $seat = $guest->seating_assignment_id
            ? $guest->wedding->seatingTables()
                ->with(['seats' => fn ($query) => $query->where('id', $guest->seating_assignment_id)])
                ->whereHas('seats', fn ($query) => $query->where('id', $guest->seating_assignment_id))
                ->first()
            : null;

        if (! $seat || $seat->seats->isEmpty()) {
            return null;
        }

        $assignedSeat = $seat->seats->first();

        return [
            'table_id' => $seat->id,
            'table_name' => $seat->name,
            'table_shape' => $seat->shape,
            'event_section' => $seat->event_section,
            'seat_number' => $assignedSeat->seat_number,
            'seat_label' => $assignedSeat->label,
            'notes' => $seat->notes,
        ];
    }

    private function refreshRegistryItemTotals(RegistryItem $item): void
    {
        $completed = $item->contributions()->where('payment_status', 'completed');
        $item->update([
            'fund_raised' => (float) $completed->sum('amount'),
            'quantity_purchased' => (int) $completed->sum('quantity'),
        ]);
    }

    private function ensureThankYouRecord(RegistryContribution $contribution): ThankYouRecord
    {
        return ThankYouRecord::firstOrCreate(
            ['contribution_id' => $contribution->id],
            [
                'wedding_id' => $contribution->wedding_id,
                'guest_id' => $contribution->guest_id,
                'recipient_name' => $contribution->contributor_name,
                'recipient_email' => $contribution->contributor_email,
                'reason' => 'gift',
                'channel' => $contribution->contributor_email ? 'email' : 'card',
                'status' => $contribution->thank_you_sent ? 'sent' : 'pending',
                'sent_at' => $contribution->thank_you_sent ? now() : null,
            ]
        );
    }
}
