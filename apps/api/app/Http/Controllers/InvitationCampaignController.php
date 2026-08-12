<?php

namespace App\Http\Controllers;

use App\Models\GuestToken;
use App\Models\Message;
use App\Services\GuestAudienceFilterService;
use App\Services\MessageAnalyticsService;
use App\Services\MessageDispatchService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InvitationCampaignController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'manage_guests'), 403);
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $campaigns = $this->wedding($request)
            ->messages()
            ->whereIn('message_type', ['invitation', 'rsvp_reminder'])
            ->orderByDesc('created_at')
            ->get();

        $summaries = app(MessageAnalyticsService::class)->summariesFor($campaigns);

        return response()->json([
            'data' => $campaigns
                ->map(fn (Message $campaign) => $this->campaignPayload($campaign, $summaries[$campaign->id] ?? null))
                ->values()
                ->all(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $data = $this->validatedCampaign($request);
        $preview = $this->previewFor($wedding, $data['audience_filter'] ?? []);

        $campaign = $wedding->messages()->create([
            'campaign_name' => $data['campaign_name'],
            'campaign_type' => $data['campaign_type'],
            'template_id' => $data['template_id'] ?? null,
            'subject' => $data['subject'],
            'body' => $data['body'],
            'channel' => $data['channel'],
            'audience_filter' => $data['audience_filter'] ?? [],
            'recipient_count' => $preview['recipient_count'],
            'scheduled_at' => $data['scheduled_at'] ?? null,
            'status' => ($data['scheduled_at'] ?? null) ? 'scheduled' : 'draft',
            'message_type' => $data['campaign_type'],
            'created_by' => $request->user()->id,
        ]);

        return response()->json([
            'data' => $this->campaignPayload($campaign),
            'preview' => $preview,
        ], 201);
    }

    public function show(Request $request, Message $campaign): JsonResponse
    {
        $this->authorizeCampaign($request, $campaign);

        return response()->json([
            'data' => $this->campaignPayload($campaign->load('deliveries.guest')),
            'preview' => $this->previewFor($campaign->wedding, $campaign->audience_filter ?? [], $campaign),
        ]);
    }

    public function update(Request $request, Message $campaign): JsonResponse
    {
        $this->authorizeCampaign($request, $campaign);
        abort_if(in_array($campaign->status, ['sending', 'sent'], true), 422, 'Cannot edit a campaign after sending starts.');

        $data = $this->validatedCampaign($request, true);
        $nextFilter = $data['audience_filter'] ?? $campaign->audience_filter ?? [];
        $preview = $this->previewFor($campaign->wedding, $nextFilter);

        $campaign->update([
            ...$data,
            'message_type' => $data['campaign_type'] ?? $campaign->message_type,
            'recipient_count' => $preview['recipient_count'],
            'status' => array_key_exists('scheduled_at', $data) && $data['scheduled_at']
                ? 'scheduled'
                : ($campaign->status === 'scheduled' ? 'draft' : $campaign->status),
        ]);

        return response()->json([
            'data' => $this->campaignPayload($campaign->fresh()),
            'preview' => $preview,
        ]);
    }

    public function preview(Request $request, ?Message $campaign = null): JsonResponse
    {
        if ($campaign) {
            $this->authorizeCampaign($request, $campaign);
        }

        $wedding = $campaign?->wedding ?? $this->wedding($request);
        $data = $request->isMethod('post')
            ? $this->validatedCampaign($request, true)
            : [];

        return response()->json([
            'data' => $this->previewFor(
                $wedding,
                $data['audience_filter'] ?? $campaign?->audience_filter ?? [],
                $campaign,
                $data['body'] ?? $campaign?->body,
                $data['subject'] ?? $campaign?->subject
            ),
        ]);
    }

    public function send(Request $request, Message $campaign): JsonResponse
    {
        $this->authorizeCampaign($request, $campaign);
        abort_if(in_array($campaign->status, ['sending', 'sent'], true), 422, 'Campaign is already sent or sending.');

        if ($campaign->message_type === 'invitation') {
            $wedding = $this->wedding($request);
            $recipientCount = app(GuestAudienceFilterService::class)
                ->apply($wedding->guests(), $campaign->audience_filter ?? [])
                ->count();
            app(SubscriptionEntitlementService::class)->ensureWithinLimit($wedding, 'invitations_sent', $recipientCount);
        }

        $recipients = app(MessageDispatchService::class)->dispatch($campaign->load('wedding'), $request->boolean('force'));

        return response()->json([
            'data' => $this->campaignPayload($campaign->fresh()),
            'recipients' => $recipients,
        ]);
    }

    private function validatedCampaign(Request $request, bool $partial = false): array
    {
        $required = $partial ? 'sometimes' : 'required';

        return $request->validate([
            'campaign_name' => "{$required}|string|max:255",
            'campaign_type' => "{$required}|in:invitation,rsvp_reminder",
            'template_id' => 'nullable|string|max:255',
            'subject' => "{$required}|string|max:255",
            'body' => "{$required}|string",
            'channel' => "{$required}|in:email,sms,whatsapp",
            'audience_filter' => 'nullable|array',
            'audience_filter.attending_status' => 'nullable|in:pending,yes,no',
            'audience_filter.guest_group' => 'nullable|string|max:255',
            'audience_filter.invite_status' => 'nullable|string|max:255',
            'audience_filter.vip_flag' => 'nullable|boolean',
            'audience_filter.has_email' => 'nullable|boolean',
            'audience_filter.has_phone' => 'nullable|boolean',
            'audience_filter.travel_required' => 'nullable|boolean',
            'audience_filter.added_after' => 'nullable|date',
            'audience_filter.guest_ids' => 'nullable|array',
            'audience_filter.guest_ids.*' => 'integer',
            'scheduled_at' => 'nullable|date',
        ]);
    }

    private function previewFor($wedding, array $filter, ?Message $campaign = null, ?string $body = null, ?string $subject = null): array
    {
        $filterService = app(GuestAudienceFilterService::class);
        $query = $filterService->apply($wedding->guests(), $filter);

        $recipientCount = (clone $query)->count();
        $sample = (clone $query)->orderBy('last_name')->orderBy('first_name')->first();

        return [
            'recipient_count' => $recipientCount,
            'contact_breakdown' => $filterService->contactBreakdown(clone $query),
            'sample_guest' => $sample ? [
                'id' => $sample->id,
                'name' => trim(implode(' ', array_filter([$sample->first_name, $sample->last_name]))),
                'email' => $sample->email,
                'attending_status' => $sample->attending_status,
                'invite_status' => $sample->invite_status,
            ] : null,
            'sample_subject' => $this->renderSample($wedding, $sample, $subject ?? $campaign?->subject ?? ''),
            'sample_body' => $this->renderSample($wedding, $sample, $body ?? $campaign?->body ?? ''),
            'delivery_summary' => $campaign ? app(MessageAnalyticsService::class)->summaryFor($campaign) : null,
        ];
    }

    public function guestLinks(Request $request, Message $campaign): JsonResponse
    {
        $this->authorizeCampaign($request, $campaign);

        $wedding = $campaign->wedding;
        $filterService = app(GuestAudienceFilterService::class);
        $guests = $filterService->apply($wedding->guests(), $campaign->audience_filter ?? [])
            ->orderBy('last_name')->orderBy('first_name')->get();

        app(MessageDispatchService::class)->ensureGuestTokens($wedding->id, $guests);

        $tokens = GuestToken::where('wedding_id', $wedding->id)
            ->whereIn('guest_id', $guests->pluck('id'))
            ->get()
            ->keyBy('guest_id');

        $frontendUrl = rtrim((string) config('app.frontend_url', config('app.url')), '/');

        return response()->json([
            'data' => $guests->map(function ($guest) use ($tokens, $frontendUrl) {
                $token = $tokens->get($guest->id);
                return [
                    'guest_id' => $guest->id,
                    'name' => trim(implode(' ', array_filter([$guest->first_name, $guest->last_name]))),
                    'link' => $token ? "{$frontendUrl}/g/{$token->token}" : null,
                ];
            })->values()->all(),
        ]);
    }

    private function renderSample($wedding, $guest, string $content): string
    {
        $guestName = $guest
            ? trim(implode(' ', array_filter([$guest->first_name, $guest->last_name])))
            : 'Sample Guest';
        $coupleNames = trim(implode(' & ', array_filter([$wedding->couple_name_primary, $wedding->couple_name_secondary])));

        return strtr($content, [
            '{{first_name}}' => $guest?->first_name ?: 'Sample',
            '{{guest_name}}' => $guestName ?: 'Sample Guest',
            '{{rsvp_url}}' => 'https://example.test/g/sample-token',
            '{{guest_portal_url}}' => 'https://example.test/g/sample-token',
            '{{couple_names}}' => $coupleNames,
            '{{wedding_title}}' => $wedding->title ?: ($coupleNames ? "{$coupleNames}'s wedding" : 'our wedding'),
        ]);
    }

    private function authorizeCampaign(Request $request, Message $campaign): void
    {
        abort_unless($campaign->wedding_id === $this->wedding($request)->id, 403);
        abort_unless(in_array($campaign->message_type, ['invitation', 'rsvp_reminder'], true), 404);
    }

    private function campaignPayload(Message $campaign, ?array $summary = null): array
    {
        $data = $campaign->toArray();
        $data['delivery_summary'] = $summary ?? app(MessageAnalyticsService::class)->summaryFor($campaign);

        return $data;
    }
}
