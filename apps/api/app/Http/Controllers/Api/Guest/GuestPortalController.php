<?php

namespace App\Http\Controllers\Api\Guest;

use App\Http\Controllers\Controller;
use App\Jobs\SendRsvpConfirmationSms;
use App\Jobs\SendRsvpNotification;
use App\Models\Guest;
use App\Models\GalleryItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Stripe\Checkout\Session as StripeSession;
use Stripe\Stripe;

/**
 * Public guest-portal endpoints — no auth, resolved via guest token.
 * All routes: /guest-portal/{token}/*
 */
class GuestPortalController extends Controller
{
    private function resolveGuest(string $token): Guest
    {
        return Guest::where('token', $token)
            ->with('wedding')
            ->firstOrFail();
    }

    // GET /guest-portal/{token}
    // Returns everything the guest landing page needs in one shot.
    public function show(string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $timeline = $wedding->timelineEvents()
            ->where('event_date', $wedding->wedding_date)
            ->orderBy('sort_order')
            ->get();

        $experience = $wedding->experienceConfig;

        $isLive = $wedding->status === 'live';

        return response()->json([
            'guest' => [
                'id'               => $guest->id,
                'first_name'       => $guest->first_name,
                'full_name'        => $guest->full_name,
                'rsvp_status'      => $guest->rsvp_status,
                'plus_one_allowed' => $guest->plus_one_allowed,
                'plus_one_name'    => $guest->plus_one_name,
                'dietary_requirements' => $guest->dietary_requirements,
                'needs_transport'  => $guest->needs_transport,
                'needs_accommodation' => $guest->needs_accommodation,
                'checked_in_at'    => $guest->checked_in_at?->toIso8601String(),
            ],
            'wedding' => [
                'partner_one_name' => $wedding->partner_one_name,
                'partner_two_name' => $wedding->partner_two_name,
                'wedding_date'     => $wedding->wedding_date?->toDateString(),
                'venue_name'       => $wedding->venue_name,
                'venue_address'    => $wedding->venue_address,
                'venue_city'       => $wedding->venue_city ?? null,
                'cover_photo_url'  => $wedding->cover_photo_url,
                'status'           => $wedding->status,
                'timezone'         => $wedding->timezone,
                'is_live'          => $isLive,
            ],
            'experience' => $experience ? [
                'is_published'      => $experience->is_published,
                'welcome_message'   => $experience->welcome_message,
                'show_schedule'     => $experience->show_schedule,
                'show_venue'        => $experience->show_venue,
                'show_registry'     => $experience->show_registry,
                'show_gallery'      => $experience->show_gallery,
                'show_messages'     => $experience->show_messages,
                'theme_color'       => $experience->theme_color,
            ] : null,
            'day_schedule' => $timeline->map(fn ($e) => [
                'id'          => $e->id,
                'title'       => $e->title,
                'description' => $e->description,
                'event_date'  => $e->event_date?->toDateString(),
                'start_time'  => $e->start_time,
                'end_time'    => $e->end_time,
                'location'    => $e->location,
                'type'        => $e->type,
            ])->values(),
        ]);
    }

    // POST /guest-portal/{token}/rsvp
    public function rsvp(Request $request, string $token): JsonResponse
    {
        $guest = $this->resolveGuest($token);

        $data = $request->validate([
            'status'               => 'required|in:attending,declined,maybe',
            'dietary_requirements' => 'nullable|string|max:500',
            'plus_one_attending'   => 'boolean',
            'plus_one_name'        => 'nullable|string|max:200',
            'song_request'         => 'nullable|string|max:200',
            'message_to_couple'    => 'nullable|string|max:1000',
        ]);

        $guest->update([
            'rsvp_status'             => $data['status'],
            'rsvp_responded_at'       => now(),
            'dietary_requirements'    => $data['dietary_requirements'] ?? $guest->dietary_requirements,
            'plus_one_rsvp_attending' => $data['plus_one_attending'] ?? false,
            'plus_one_name'           => $data['plus_one_name'] ?? $guest->plus_one_name,
            'notes'                   => isset($data['message_to_couple'])
                ? ($guest->notes ? $guest->notes . "\n\n[Guest message]: " . $data['message_to_couple']
                    : "[Guest message]: " . $data['message_to_couple'])
                : $guest->notes,
        ]);

        $fresh = $guest->fresh();
        SendRsvpNotification::dispatch($fresh, $guest->wedding);
        SendRsvpConfirmationSms::dispatch($fresh);

        return response()->json([
            'success'     => true,
            'rsvp_status' => $guest->rsvp_status,
            'message'     => match ($data['status']) {
                'attending' => "We can't wait to celebrate with you!",
                'declined'  => "Sorry you can't make it — you'll be missed.",
                default     => "Thanks for letting us know!",
            },
        ]);
    }

    // GET /guest-portal/{token}/schedule
    public function schedule(string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $events = $wedding->timelineEvents()
            ->orderBy('event_date')
            ->orderBy('sort_order')
            ->get();

        return response()->json([
            'wedding_date' => $wedding->wedding_date?->toDateString(),
            'timezone'     => $wedding->timezone,
            'events'       => $events->map(fn ($e) => [
                'id'          => $e->id,
                'title'       => $e->title,
                'description' => $e->description,
                'event_date'  => $e->event_date?->toDateString(),
                'start_time'  => $e->start_time,
                'end_time'    => $e->end_time,
                'location'    => $e->location,
                'type'        => $e->type,
            ])->values(),
        ]);
    }

    // GET /guest-portal/{token}/registry
    public function registry(string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $experience = $wedding->experienceConfig;
        if ($experience && !$experience->show_registry) {
            return response()->json(['visible' => false, 'items' => [], 'fund' => null]);
        }

        $items = $wedding->registryItems()->get();
        $fund  = $wedding->registryCashFund;

        return response()->json([
            'visible' => true,
            'items'   => $items->map(fn ($i) => [
                'id'             => $i->id,
                'title'          => $i->title,
                'description'    => $i->description,
                'price'          => $i->price,
                'url'            => $i->url,
                'image_url'      => $i->image_url,
                'category'       => $i->category,
                'is_claimed'     => $i->is_claimed,
                'claimed_by_name'=> $i->claimed_by_name,
            ])->values(),
            'fund' => ($fund && $fund->is_active) ? [
                'id'            => $fund->id,
                'title'         => $fund->title,
                'description'   => $fund->description,
                'target_amount' => $fund->target_amount,
                'raised_amount' => (float) $fund->raised_amount,
                'share_token'   => $fund->share_token,
            ] : null,
        ]);
    }

    // GET /guest-portal/{token}/gallery
    public function gallery(string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $experience = $wedding->experienceConfig;
        if ($experience && !$experience->show_gallery) {
            return response()->json(['visible' => false, 'items' => []]);
        }

        $items = $wedding->galleryItems()
            ->where('type', 'memory')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'visible' => true,
            'items'   => $items->map(fn ($i) => [
                'id'          => $i->id,
                'image_url'   => $i->image_url,
                'caption'     => $i->caption,
                'uploaded_by' => $i->uploaded_by,
                'is_featured' => $i->is_featured,
                'created_at'  => $i->created_at?->toIso8601String(),
            ])->values(),
        ]);
    }

    // POST /guest-portal/{token}/gallery
    public function uploadPhoto(Request $request, string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $request->validate([
            'image'    => 'required|image|max:10240',
            'caption'  => 'nullable|string|max:500',
        ]);

        $path     = $request->file('image')->store("weddings/{$wedding->id}/memories", 'public');
        $imageUrl = Storage::disk('public')->url($path);

        $item = $wedding->galleryItems()->create([
            'type'        => 'memory',
            'image_url'   => $imageUrl,
            'caption'     => $request->caption,
            'uploaded_by' => $guest->full_name,
            'sort_order'  => 0,
        ]);

        return response()->json([
            'id'        => $item->id,
            'image_url' => $item->image_url,
            'caption'   => $item->caption,
        ], 201);
    }

    // POST /guest-portal/{token}/fund/contribute
    public function contribute(Request $request, string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $data = $request->validate([
            'amount'   => 'required|numeric|min:1|max:100000',
            'name'     => 'nullable|string|max:200',
            'message'  => 'nullable|string|max:500',
        ]);

        $fund = $wedding->registryCashFund;
        if (!$fund || !$fund->is_active) {
            return response()->json(['error' => 'Cash fund is not available'], 422);
        }

        $currency      = strtolower($wedding->currency ?? 'usd');
        $amountInCents = (int) round((float) $data['amount'] * 100);
        $guestWebUrl   = rtrim(config('app.guest_web_url', 'https://udo.app'), '/');

        Stripe::setApiKey(config('services.stripe.secret'));

        $session = StripeSession::create([
            'mode'        => 'payment',
            'line_items'  => [[
                'price_data' => [
                    'currency'     => $currency,
                    'unit_amount'  => $amountInCents,
                    'product_data' => ['name' => $fund->title],
                ],
                'quantity' => 1,
            ]],
            'success_url'    => "{$guestWebUrl}/g/{$token}/registry/success?session_id={CHECKOUT_SESSION_ID}",
            'cancel_url'     => "{$guestWebUrl}/g/{$token}/registry",
            'customer_email' => $guest->email,
            'metadata'       => [
                'cash_fund_id'     => $fund->id,
                'guest_token'      => $token,
                'contributor_name' => $data['name'] ?? $guest->full_name,
            ],
        ]);

        $fund->contributions()->create([
            'stripe_session_id' => $session->id,
            'amount'            => $data['amount'],
            'currency'          => $currency,
            'status'            => 'pending',
            'contributor_name'  => $data['name'] ?? null,
            'message'           => $data['message'] ?? null,
        ]);

        return response()->json(['checkout_url' => $session->url]);
    }

    // GET /guest-portal/{token}/messages
    public function messages(string $token): JsonResponse
    {
        $guest   = $this->resolveGuest($token);
        $wedding = $guest->wedding;

        $msgs = $wedding->guestMessages()
            ->where('channel', 'in_app')
            ->whereIn('recipient_filter->type', ['all', 'attending'])
            ->orderByDesc('created_at')
            ->take(20)
            ->get();

        return response()->json([
            'messages' => $msgs->map(fn ($m) => [
                'id'         => $m->id,
                'subject'    => $m->subject,
                'body'       => $m->body,
                'sent_at'    => $m->created_at?->toIso8601String(),
            ])->values(),
        ]);
    }
}
