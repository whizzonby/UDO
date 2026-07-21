<?php

namespace Tests\Feature;

use App\Mail\TemplatedMail;
use App\Filament\Resources\BlogPostResource\Pages\EditBlogPost;
use App\Filament\Resources\EmailTemplateResource\Pages\EditEmailTemplate;
use App\Filament\Resources\FailedJobResource\Pages\ListFailedJobs;
use App\Filament\Resources\GuestResource\Pages\ListGuests;
use App\Filament\Resources\IdempotencyKeyResource\Pages\ViewIdempotencyKey;
use App\Filament\Resources\TaskResource\Pages\ListTasks;
use App\Filament\Resources\VendorResource\Pages\ListVendors;
use App\Filament\Pages\ReliabilityConsole;
use App\Filament\Widgets\LiveCommandCenterWeddingsWidget;
use App\Filament\Widgets\ReliabilityStatsWidget;
use App\Filament\Widgets\StaleMessagesWidget;
use App\Filament\Widgets\TokenExpiryRiskWidget;
use App\Filament\Widgets\UnresolvedLiveIncidentsWidget;
use App\Filament\Widgets\VipReadinessWidget;
use App\Jobs\SendGuestInviteJob;
use App\Jobs\SendGuestMessageDeliveryJob;
use App\Models\EmailTemplate;
use App\Models\AuditLog;
use App\Models\BlogPost;
use App\Models\FailedJob;
use App\Models\GalleryAsset;
use App\Models\Guest;
use App\Models\GuestToken;
use App\Models\IdempotencyKey;
use App\Models\LiveUpdate;
use App\Models\Message;
use App\Models\AccommodationOption;
use App\Models\BudgetPaymentSchedule;
use App\Models\RegistryContribution;
use App\Models\Subscription;
use App\Models\SupportTicket;
use App\Models\Task;
use App\Models\ThankYouRecord;
use App\Models\TransportGroup;
use App\Models\User;
use App\Models\Vendor;
use App\Models\VendorContactLog;
use App\Models\Wedding;
use Database\Seeders\RolesSeeder;
use App\Services\AdminAccountSafetyService;
use App\Services\AdminBudgetPaymentOpsService;
use App\Services\AdminBulkOpsService;
use App\Services\AdminGalleryModerationService;
use App\Services\AdminLiveOpsService;
use App\Services\AdminLogisticsOpsService;
use App\Services\AdminRegistryOpsService;
use App\Services\AdminReliabilityOpsService;
use App\Services\AdminSubscriptionOpsService;
use App\Services\AdminSupportOpsService;
use App\Services\AdminVendorOpsService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Livewire\Livewire;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class WeddingFlowBugFixTest extends TestCase
{
    use RefreshDatabase;

    public function test_dashboard_counts_rsvps_saved_as_yes_and_no(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $wedding->guests()->create(['first_name' => 'Ada', 'attending_status' => 'yes']);
        $wedding->guests()->create(['first_name' => 'Grace', 'attending_status' => 'no']);
        $wedding->guests()->create(['first_name' => 'Maya', 'attending_status' => 'pending']);

        $this->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('stats.confirmed_guests', 1)
            ->assertJsonPath('stats.declined_guests', 1)
            ->assertJsonPath('stats.pending_guests', 1);
    }

    public function test_dashboard_command_center_aggregates_real_readiness_signals(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $wedding->update([
            'event_date' => now()->addDays(30)->toDateString(),
            'rsvp_deadline' => now()->addDays(10)->toDateString(),
            'settings' => ['total_budget' => 10000],
        ]);

        $wedding->guests()->create(['first_name' => 'Ada', 'attending_status' => 'yes', 'meal_preference' => null]);
        $wedding->guests()->create(['first_name' => 'Grace', 'attending_status' => 'pending']);
        $wedding->guests()->create([
            'first_name' => 'Nora',
            'last_name' => 'VIP',
            'attending_status' => 'yes',
            'vip_flag' => true,
            'travel_required' => true,
        ]);
        $wedding->tasks()->create([
            'created_by' => $user->id,
            'title' => 'Overdue task',
            'due_date' => now()->subDay()->toDateString(),
            'priority' => 'high',
            'completed' => false,
        ]);
        $wedding->tasks()->create([
            'created_by' => $user->id,
            'title' => 'Completed task',
            'completed' => true,
        ]);
        $wedding->budgetItems()->create([
            'category' => 'Venue',
            'name' => 'Venue balance',
            'estimated_amount' => 9000,
            'actual_amount' => 9500,
            'paid_amount' => 3000,
            'payment_status' => 'partial',
            'due_date' => now()->addWeek()->toDateString(),
        ]);
        $wedding->vendors()->create([
            'name' => 'Main Venue',
            'category' => 'Venue',
            'booking_status' => 'confirmed',
            'contract_signed' => false,
        ]);
        $wedding->liveUpdates()->create([
            'created_by' => $user->id,
            'type' => 'incident',
            'severity' => 'high',
            'audience' => 'team',
            'status' => 'open',
            'title' => 'Power check',
            'body' => 'Generator confirmation needed.',
        ]);

        $this->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('stats.overdue_tasks', 1)
            ->assertJsonPath('command_center.rsvp_health.pending', 1)
            ->assertJsonPath('command_center.budget_status.usage', 95)
            ->assertJsonPath('command_center.budget_status.unpaid_balance', 6500)
            ->assertJsonPath('command_center.guest_issues.missing_meals', 2)
            ->assertJsonPath('command_center.guest_issues.vip_needs_attention', 1)
            ->assertJsonPath('command_center.live_readiness.open_incidents', 1)
            ->assertJsonPath('command_center.live_readiness.vendor_readiness.missing_contracts', 1)
            ->assertJsonPath('command_center.upcoming_actions.0.id', 'live-incidents');
    }

    public function test_invite_email_uses_guest_portal_route(): void
    {
        config(['app.frontend_url' => 'https://example.test']);
        Queue::fake();

        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        EmailTemplate::updateOrCreate(
            ['key' => 'guest_invite'],
            [
                'name' => 'Guest invite',
                'subject' => 'You are invited',
                'body' => 'RSVP here: {{rsvp_url}}',
            ]
        );

        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'email' => 'ava@example.test',
        ]);

        $this->postJson("/api/guests/{$guest->id}/invite")
            ->assertOk()
            ->assertJsonPath('data.invite_status', 'queued');

        $guest->refresh()->load('token');

        Queue::assertPushed(SendGuestInviteJob::class, fn (SendGuestInviteJob $job) => $job->guestId === $guest->id);
    }

    public function test_invite_job_uses_guest_portal_route(): void
    {
        config(['app.frontend_url' => 'https://example.test']);
        Mail::fake();

        [, $wedding] = $this->userWithWedding();
        EmailTemplate::updateOrCreate(
            ['key' => 'guest_invite'],
            [
                'name' => 'Guest invite',
                'subject' => 'You are invited',
                'body' => 'RSVP here: {{rsvp_url}}',
            ]
        );

        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'email' => 'ava@example.test',
        ]);
        GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'attending',
        ]);

        (new SendGuestInviteJob($guest->id))->handle();

        Mail::assertQueued(TemplatedMail::class, function (TemplatedMail $mail) use ($guest) {
            $guest->refresh()->load('token');
            return str_contains($mail->renderedBody, "https://example.test/g/{$guest->token->token}");
        });

        $this->assertDatabaseHas('guests', [
            'id' => $guest->id,
            'invite_status' => 'sent',
        ]);
    }

    public function test_guest_can_upload_photo_from_token_portal(): void
    {
        Storage::fake('public');
        [, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Nia']);
        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'attending',
        ]);
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'allow_photo_uploads' => true,
        ]);

        $response = $this->post("/api/g/{$token->token}/gallery", [
            'file' => UploadedFile::fake()->create('toast.jpg', 64, 'image/jpeg'),
            'caption' => 'A beautiful toast',
        ], ['Accept' => 'application/json']);

        $response
            ->assertCreated()
            ->assertJsonPath('data.uploaded_by_guest_id', $guest->id)
            ->assertJsonPath('data.album', 'guest_uploads')
            ->assertJsonPath('data.approved', false);

        $this->assertDatabaseHas('gallery_assets', [
            'wedding_id' => $wedding->id,
            'uploaded_by_guest_id' => $guest->id,
            'album' => 'guest_uploads',
            'caption' => 'A beautiful toast',
            'approved' => false,
        ]);
    }

    public function test_guest_rsvp_updates_values_dashboard_uses(): void
    {
        [, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Lina']);
        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'attending',
        ]);

        $this->postJson("/api/g/{$token->token}/rsvp", [
            'attending_status' => 'yes',
            'meal_preference' => 'vegetarian',
        ])->assertOk();

        $this->assertDatabaseHas('guests', [
            'id' => $guest->id,
            'attending_status' => 'yes',
            'meal_preference' => 'vegetarian',
        ]);
    }

    public function test_guest_can_update_communication_preferences_from_token_portal(): void
    {
        [, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Lina']);
        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'attending',
        ]);

        $this->patchJson("/api/g/{$token->token}/preferences", [
            'email_opt_out' => true,
            'sms_opt_out' => true,
            'whatsapp_opt_out' => false,
        ])
            ->assertOk()
            ->assertJsonPath('communication_preferences.email_opt_out', true)
            ->assertJsonPath('communication_preferences.sms_opt_out', true)
            ->assertJsonPath('communication_preferences.whatsapp_opt_out', false);

        $this->assertDatabaseHas('guests', [
            'id' => $guest->id,
            'email_opt_out' => true,
            'sms_opt_out' => true,
            'whatsapp_opt_out' => false,
        ]);
    }

    public function test_admin_can_update_guest_experience_builder_config(): void
    {
        [$user] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $this->patchJson('/api/experience', [
            'publish_state' => 'published',
            'theme_color' => '#123456',
            'welcome_message' => 'Welcome to our weekend.',
            'dress_code' => 'Garden formal',
            'dress_code_details' => 'Comfortable shoes recommended.',
            'layout_order' => ['details', 'rsvp', 'schedule', 'gallery'],
            'access_rules' => ['vip' => ['show_live_feed']],
            'show_gallery' => true,
            'show_live_feed' => true,
            'allow_photo_uploads' => true,
        ])
            ->assertOk()
            ->assertJsonPath('data.publish_state', 'published')
            ->assertJsonPath('data.theme_color', '#123456')
            ->assertJsonPath('data.show_gallery', true)
            ->assertJsonPath('data.layout_order.2', 'schedule')
            ->assertJsonPath('data.access_rules.vip.0', 'show_live_feed');
    }

    public function test_guest_portal_respects_experience_builder_sections(): void
    {
        [, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Lina']);
        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'attending',
        ]);

        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'welcome_message' => 'Welcome friends.',
            'show_schedule' => true,
            'show_registry' => false,
            'show_gallery' => true,
            'show_live_feed' => false,
            'rsvp_enabled' => true,
            'meal_selection_enabled' => false,
            'allow_photo_uploads' => false,
        ]);
        $wedding->timelineItems()->create([
            'title' => 'Ceremony',
            'visible_to_guests' => true,
        ]);
        $wedding->registryItems()->create([
            'name' => 'Honeymoon fund',
            'type' => 'cash_fund',
            'is_visible' => true,
        ]);
        $wedding->galleryAssets()->create([
            'type' => 'photo',
            'source' => 'upload',
            'url' => '/storage/weddings/photo.jpg',
            'approved' => true,
        ]);
        $wedding->liveUpdates()->create([
            'created_by' => $wedding->owner_user_id,
            'title' => 'Shuttle delayed',
            'visible_to_guests' => true,
            'bride_only' => false,
        ]);

        $this->getJson("/api/g/{$token->token}")
            ->assertOk()
            ->assertJsonPath('experience.welcome_message', 'Welcome friends.')
            ->assertJsonPath('experience.sections.registry', false)
            ->assertJsonCount(1, 'sections.schedule')
            ->assertJsonCount(0, 'sections.registry')
            ->assertJsonCount(1, 'sections.gallery')
            ->assertJsonCount(0, 'sections.live_updates');

        $this->postJson("/api/g/{$token->token}/rsvp", [
            'attending_status' => 'yes',
            'meal_preference' => 'vegan',
        ])->assertOk();

        $this->assertNull($guest->fresh()->meal_preference);
    }

    public function test_admin_can_preview_and_schedule_invitation_campaign(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $wedding->guests()->create([
            'first_name' => 'Ava',
            'last_name' => 'Stone',
            'email' => 'ava@example.test',
            'attending_status' => 'pending',
            'invite_status' => 'not_sent',
        ]);
        $wedding->guests()->create([
            'first_name' => 'Noah',
            'email' => 'noah@example.test',
            'attending_status' => 'yes',
            'invite_status' => 'sent',
        ]);

        $payload = [
            'campaign_name' => 'Launch invitations',
            'campaign_type' => 'invitation',
            'subject' => 'Hi {{first_name}}, you are invited',
            'body' => 'Open your invitation: {{rsvp_url}}',
            'channel' => 'email',
            'audience_filter' => [
                'attending_status' => 'pending',
                'has_email' => true,
            ],
            'scheduled_at' => now()->addDay()->toISOString(),
        ];

        $this->postJson('/api/invitation/campaigns/preview', $payload)
            ->assertOk()
            ->assertJsonPath('data.recipient_count', 1)
            ->assertJsonPath('data.sample_guest.name', 'Ava Stone')
            ->assertJsonPath('data.sample_subject', 'Hi Ava, you are invited');

        $this->postJson('/api/invitation/campaigns', $payload)
            ->assertCreated()
            ->assertJsonPath('data.campaign_name', 'Launch invitations')
            ->assertJsonPath('data.message_type', 'invitation')
            ->assertJsonPath('data.status', 'scheduled')
            ->assertJsonPath('preview.recipient_count', 1);

        $this->assertDatabaseHas('messages', [
            'wedding_id' => $wedding->id,
            'campaign_name' => 'Launch invitations',
            'campaign_type' => 'invitation',
            'status' => 'scheduled',
            'recipient_count' => 1,
        ]);
    }

    public function test_sending_invitation_campaign_generates_guest_tokens_and_deliveries(): void
    {
        Queue::fake();
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'email' => 'ava@example.test',
            'attending_status' => 'pending',
            'invite_status' => 'not_sent',
        ]);

        $campaign = $wedding->messages()->create([
            'created_by' => $user->id,
            'campaign_name' => 'Send invitations',
            'campaign_type' => 'invitation',
            'subject' => 'You are invited',
            'body' => 'Open {{rsvp_url}}',
            'channel' => 'email',
            'audience_filter' => ['has_email' => true],
            'message_type' => 'invitation',
            'status' => 'draft',
        ]);

        $this->postJson("/api/invitation/campaigns/{$campaign->id}/send", ['force' => true])
            ->assertOk()
            ->assertJsonPath('recipients', 1)
            ->assertJsonPath('data.recipient_count', 1);

        $this->assertDatabaseHas('guest_tokens', [
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
        ]);
        $this->assertDatabaseHas('guest_message_deliveries', [
            'message_id' => $campaign->id,
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'email',
        ]);
    }

    public function test_logistics_summary_and_assignments_track_guest_completeness(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'travel_required' => true,
            'arrival_date' => now()->addDay()->toDateString(),
            'departure_date' => now()->addDays(3)->toDateString(),
        ]);
        $hotel = $wedding->accommodationOptions()->create([
            'name' => 'Harbor Hotel',
            'total_rooms_blocked' => 10,
        ]);
        $transport = $wedding->transportGroups()->create([
            'name' => 'Airport shuttle',
            'capacity' => 12,
        ]);

        $this->getJson('/api/logistics/summary')
            ->assertOk()
            ->assertJsonPath('data.travelling_guests', 1)
            ->assertJsonPath('data.missing_arrival_info', 1)
            ->assertJsonPath('data.missing_accommodation', 1)
            ->assertJsonPath('data.missing_transport', 1);

        $this->postJson("/api/logistics/accommodation/{$hotel->id}/assign", ['guest_id' => $guest->id])
            ->assertOk()
            ->assertJsonPath('data.rooms_assigned', 1);
        $this->postJson("/api/logistics/transport/{$transport->id}/assign", ['guest_id' => $guest->id])
            ->assertOk()
            ->assertJsonPath('data.assigned_count', 1);

        $this->assertSame($hotel->id, $guest->fresh()->hotel_assignment_id);
        $this->assertSame($transport->id, $guest->fresh()->transport_assignment_id);

        $this->getJson('/api/logistics/summary')
            ->assertOk()
            ->assertJsonPath('data.accommodation_assigned', 1)
            ->assertJsonPath('data.transport_assigned', 1)
            ->assertJsonPath('data.missing_accommodation', 0)
            ->assertJsonPath('data.missing_transport', 0)
            ->assertJsonPath('data.transport_seats_remaining', 11);
    }

    public function test_seating_summary_assignment_integrity_and_guest_portal_visibility(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guestA = $wedding->guests()->create([
            'first_name' => 'Ava',
            'last_name' => 'Stone',
            'attending_status' => 'yes',
        ]);
        $guestB = $wedding->guests()->create([
            'first_name' => 'Milo',
            'last_name' => 'Reed',
            'attending_status' => 'yes',
        ]);

        $created = $this->postJson('/api/seating/tables', [
            'name' => 'Table 1',
            'shape' => 'round',
            'capacity' => 2,
            'event_section' => 'Main room',
            'notes' => 'Near the couple.',
        ])
            ->assertCreated()
            ->assertJsonPath('data.name', 'Table 1')
            ->assertJsonCount(2, 'data.seats');

        $tableId = $created->json('data.id');

        $this->postJson("/api/seating/tables/{$tableId}/assign", [
            'seat_number' => 1,
            'guest_id' => $guestA->id,
        ])
            ->assertOk()
            ->assertJsonPath('data.guest_id', $guestA->id);
        $this->postJson("/api/seating/tables/{$tableId}/assign", [
            'seat_number' => 2,
            'guest_id' => $guestB->id,
        ])
            ->assertOk()
            ->assertJsonPath('data.guest_id', $guestB->id);

        $this->getJson('/api/seating/summary')
            ->assertOk()
            ->assertJsonPath('data.table_count', 1)
            ->assertJsonPath('data.assigned_count', 2)
            ->assertJsonPath('data.unassigned_attending_count', 0)
            ->assertJsonPath('data.open_seats', 0);

        $this->patchJson("/api/seating/tables/{$tableId}", ['capacity' => 1])
            ->assertStatus(422);

        $secondTable = $this->postJson('/api/seating/tables', [
            'name' => 'Table 2',
            'capacity' => 2,
        ])
            ->assertCreated()
            ->json('data');

        $this->postJson("/api/seating/tables/{$secondTable['id']}/assign", [
            'seat_number' => 1,
            'guest_id' => $guestA->id,
        ])
            ->assertOk()
            ->assertJsonPath('data.guest_id', $guestA->id);

        $this->assertDatabaseMissing('seating_seats', [
            'seating_table_id' => $tableId,
            'guest_id' => $guestA->id,
        ]);
        $this->assertDatabaseHas('seating_tables', [
            'id' => $tableId,
            'assigned_count' => 1,
        ]);
        $this->assertDatabaseHas('seating_tables', [
            'id' => $secondTable['id'],
            'assigned_count' => 1,
        ]);

        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guestA->id,
            'view_type' => 'invite',
        ]);
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'show_seating' => true,
        ]);

        $this->getJson("/api/g/{$token->token}")
            ->assertOk()
            ->assertJsonPath('experience.sections.seating', true)
            ->assertJsonPath('sections.seating.table_name', 'Table 2')
            ->assertJsonPath('sections.seating.seat_number', 1);
    }

    public function test_live_today_surfaces_incidents_vip_attention_and_resolution(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $wedding->guests()->create([
            'first_name' => 'Nora',
            'last_name' => 'VIP',
            'attending_status' => 'yes',
            'vip_flag' => true,
            'travel_required' => true,
        ]);

        $incident = $this->postJson('/api/live', [
            'type' => 'incident',
            'severity' => 'high',
            'audience' => 'team',
            'title' => 'Shuttle delay',
            'body' => 'Second shuttle is ten minutes behind.',
            'requires_action' => true,
            'visible_to_guests' => false,
        ])
            ->assertCreated()
            ->assertJsonPath('data.type', 'incident')
            ->assertJsonPath('data.severity', 'high')
            ->assertJsonPath('data.requires_action', true)
            ->json('data');

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.status.state', 'attention')
            ->assertJsonPath('data.status.unresolved_incidents', 1)
            ->assertJsonPath('data.incidents.0.title', 'Shuttle delay')
            ->assertJsonPath('data.arrivals.missing_arrival_info', 1);

        $today = $this->getJson('/api/live/today')->json('data');
        $this->assertSame(1, $today['arrivals']['vip_attention_count']);
        $this->assertSame('Nora VIP', $today['vip_attention'][0]['name']);

        $this->postJson("/api/live/{$incident['id']}/resolve")
            ->assertOk()
            ->assertJsonPath('data.status', 'resolved')
            ->assertJsonPath('data.requires_action', false);

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.status.unresolved_incidents', 0)
            ->assertJsonPath('data.incidents', []);
    }

    public function test_registry_contributions_create_thank_you_work_and_guest_portal_contributions(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'last_name' => 'Stone',
            'email' => 'ava@example.test',
        ]);

        $fund = $this->postJson('/api/registry', [
            'name' => 'Honeymoon Fund',
            'type' => 'cash_fund',
            'fund_goal' => 5000,
            'description' => 'Flights and memories.',
        ])
            ->assertCreated()
            ->assertJsonPath('data.name', 'Honeymoon Fund')
            ->json('data');

        $contribution = $this->postJson("/api/registry/{$fund['id']}/contributions", [
            'guest_id' => $guest->id,
            'contributor_name' => 'Ava Stone',
            'contributor_email' => 'ava@example.test',
            'amount' => 250,
            'payment_status' => 'completed',
            'message' => 'With love.',
        ])
            ->assertCreated()
            ->assertJsonPath('data.amount', '250.00')
            ->assertJsonPath('data.item.fund_raised', '250.00')
            ->json('data');

        $this->assertDatabaseHas('thank_you_records', [
            'contribution_id' => $contribution['id'],
            'recipient_name' => 'Ava Stone',
            'status' => 'pending',
        ]);

        $this->getJson('/api/registry/summary')
            ->assertOk()
            ->assertJsonPath('data.contribution_count', 1)
            ->assertJsonPath('data.total_contributed', 250)
            ->assertJsonPath('data.pending_thank_yous', 1);

        $this->postJson("/api/registry/contributions/{$contribution['id']}/thank-you", [
            'note' => 'Thank you for helping us travel.',
            'channel' => 'email',
        ])
            ->assertOk()
            ->assertJsonPath('data.status', 'sent')
            ->assertJsonPath('data.note', 'Thank you for helping us travel.');

        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'invite',
        ]);
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'show_registry' => true,
        ]);

        $this->postJson("/api/g/{$token->token}/registry/{$fund['id']}/contribute", [
            'amount' => 100,
            'message' => 'Guest portal gift.',
        ])
            ->assertCreated()
            ->assertJsonPath('message', 'Contribution recorded.')
            ->assertJsonPath('data.guest_id', $guest->id);

        $this->assertDatabaseHas('registry_items', [
            'id' => $fund['id'],
            'fund_raised' => 350,
        ]);
    }

    public function test_gallery_moderation_memories_saved_and_archive_flow(): void
    {
        Storage::fake('public');
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'last_name' => 'Stone',
        ]);
        $token = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'view_type' => 'invite',
        ]);
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'show_gallery' => true,
            'allow_photo_uploads' => true,
        ]);

        $this->post("/api/g/{$token->token}/gallery", [
            'file' => UploadedFile::fake()->create('dance.jpg', 64, 'image/jpeg'),
            'caption' => 'First dance',
        ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('data.approved', false)
            ->assertJsonPath('data.album', 'guest_uploads');

        $asset = $wedding->galleryAssets()->firstOrFail();

        $this->getJson('/api/gallery/summary')
            ->assertOk()
            ->assertJsonPath('data.pending_assets', 1)
            ->assertJsonPath('data.albums.guest_uploads_pending.0.uploaded_by_guest_name', 'Ava Stone');

        $this->postJson("/api/gallery/{$asset->id}/approve")
            ->assertOk()
            ->assertJsonPath('data.approved', true);
        $this->postJson("/api/gallery/{$asset->id}/feature", ['is_featured' => true])
            ->assertOk()
            ->assertJsonPath('data.is_featured', true);
        $this->patchJson("/api/gallery/{$asset->id}", ['is_saved' => true])
            ->assertOk()
            ->assertJsonPath('data.is_saved', true);

        $this->getJson('/api/gallery/summary')
            ->assertOk()
            ->assertJsonPath('data.pending_assets', 0)
            ->assertJsonPath('data.featured_assets', 1)
            ->assertJsonPath('data.saved_assets', 1)
            ->assertJsonPath('data.albums.featured.0.caption', 'First dance');

        $this->postJson("/api/gallery/{$asset->id}/archive")
            ->assertOk()
            ->assertJsonPath('data.album', 'archive')
            ->assertJsonPath('data.is_featured', false);

        $this->getJson('/api/gallery/summary')
            ->assertOk()
            ->assertJsonPath('data.archived_assets', 1);
    }

    public function test_vendor_crm_summary_contact_logs_and_task_linkage(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $vendor = $wedding->vendors()->create([
            'name' => 'Evergreen Florals',
            'category' => 'Florist',
            'contact_person' => 'Maya Bloom',
            'email' => 'maya@example.test',
            'phone' => '555-0100',
            'quoted_price' => 4200,
            'deposit_paid' => 1200,
            'balance_due' => 3000,
            'balance_due_date' => now()->addDays(5)->toDateString(),
            'booking_status' => 'confirmed',
            'contract_signed' => false,
            'on_timeline' => true,
        ]);

        $wedding->budgetItems()->create([
            'vendor_id' => $vendor->id,
            'category' => 'Florals',
            'name' => 'Final floral balance',
            'estimated_amount' => 4200,
            'actual_amount' => 4200,
            'paid_amount' => 1200,
            'payment_status' => 'partial',
            'due_date' => now()->addDays(5)->toDateString(),
        ]);

        $this->postJson('/api/plan/tasks', [
            'vendor_id' => $vendor->id,
            'title' => 'Send final floral layout',
            'category' => 'vendors',
            'due_date' => now()->addDays(2)->toDateString(),
            'priority' => 'high',
        ])->assertCreated()
            ->assertJsonPath('data.vendor_id', $vendor->id);

        $this->postJson("/api/plan/vendors/{$vendor->id}/contact-logs", [
            'contact_type' => 'email',
            'subject' => 'Confirmed centerpiece revisions',
            'outcome' => 'Waiting on final stem count',
            'follow_up_at' => now()->addDay()->toISOString(),
        ])->assertCreated()
            ->assertJsonPath('data.vendor_id', $vendor->id)
            ->assertJsonPath('data.subject', 'Confirmed centerpiece revisions');

        $this->getJson('/api/plan/vendors/summary')
            ->assertOk()
            ->assertJsonPath('data.vendor_count', 1)
            ->assertJsonPath('data.confirmed_count', 1)
            ->assertJsonPath('data.missing_contracts', 1)
            ->assertJsonPath('data.unpaid_balance', 3000)
            ->assertJsonPath('data.balances_due_soon.0.name', 'Evergreen Florals')
            ->assertJsonPath('data.day_of_contact_sheet.0.contact_person', 'Maya Bloom')
            ->assertJsonPath('data.day_of_contact_sheet.0.open_task_count', 1)
            ->assertJsonPath('data.recent_contact_logs.0.subject', 'Confirmed centerpiece revisions');

        $this->getJson("/api/plan/vendors/{$vendor->id}/contact-logs")
            ->assertOk()
            ->assertJsonPath('data.0.subject', 'Confirmed centerpiece revisions');
    }

    public function test_budget_payment_depth_tracks_schedules_categories_and_paid_rollups(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $wedding->update(['settings' => ['total_budget' => 15000]]);

        $vendor = $wedding->vendors()->create([
            'name' => 'Gourmet Affairs',
            'category' => 'Catering',
            'booking_status' => 'confirmed',
        ]);

        $itemResponse = $this->postJson('/api/plan/budget', [
            'vendor_id' => $vendor->id,
            'name' => 'Catering package',
            'category' => 'Food & drink',
            'estimated_amount' => 8000,
            'actual_amount' => 8200,
            'paid_amount' => 2000,
            'payment_status' => 'partial',
            'payment_schedule' => [
                [
                    'label' => 'Final catering balance',
                    'amount' => 6200,
                    'due_date' => now()->addDays(10)->toDateString(),
                    'status' => 'scheduled',
                ],
            ],
        ])->assertCreated()
            ->assertJsonPath('data.vendor_id', $vendor->id)
            ->assertJsonPath('data.payment_schedules.0.label', 'Final catering balance');

        $itemId = $itemResponse->json('data.id');
        $scheduleId = $itemResponse->json('data.payment_schedules.0.id');

        $this->postJson("/api/plan/budget/{$itemId}/payment-schedules", [
            'label' => 'Late tasting invoice',
            'amount' => 500,
            'due_date' => now()->subDay()->toDateString(),
        ])->assertCreated()
            ->assertJsonPath('data.status', 'overdue');

        $this->getJson('/api/plan/budget/summary')
            ->assertOk()
            ->assertJsonPath('data.total_budget', 15000)
            ->assertJsonPath('data.total_actual', 8200)
            ->assertJsonPath('data.total_paid', 2000)
            ->assertJsonPath('data.balance_due', 6200)
            ->assertJsonPath('data.due_within_30_days', 6200)
            ->assertJsonPath('data.overdue_amount', 500)
            ->assertJsonPath('data.categories.0.category', 'Food & drink')
            ->assertJsonPath('data.next_payments.0.label', 'Final catering balance')
            ->assertJsonPath('data.overdue_payments.0.label', 'Late tasting invoice');

        $this->postJson("/api/plan/budget/payment-schedules/{$scheduleId}/mark-paid")
            ->assertOk()
            ->assertJsonPath('data.status', 'paid');

        $this->assertDatabaseHas('budget_items', [
            'id' => $itemId,
            'paid_amount' => 6200,
            'payment_status' => 'partial',
        ]);
    }

    public function test_smart_alerts_generate_from_real_wedding_risks(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $wedding->update([
            'event_date' => now()->subDays(2)->toDateString(),
            'rsvp_deadline' => now()->addDays(3)->toDateString(),
        ]);

        $pendingGuest = $wedding->guests()->create([
            'first_name' => 'Pending',
            'attending_status' => 'pending',
        ]);
        $wedding->guests()->create([
            'first_name' => 'VIP',
            'attending_status' => 'yes',
            'vip_flag' => true,
            'travel_required' => true,
            'meal_preference' => null,
        ]);

        $vendor = $wedding->vendors()->create([
            'name' => 'Sound House',
            'category' => 'Music',
            'booking_status' => 'confirmed',
        ]);
        $budgetItem = $wedding->budgetItems()->create([
            'vendor_id' => $vendor->id,
            'category' => 'Music',
            'name' => 'DJ balance',
            'estimated_amount' => 1500,
            'actual_amount' => 1500,
            'paid_amount' => 0,
            'payment_status' => 'pending',
        ]);
        $budgetItem->paymentSchedules()->create([
            'wedding_id' => $wedding->id,
            'vendor_id' => $vendor->id,
            'label' => 'Final DJ payment',
            'amount' => 1500,
            'due_date' => now()->subDay()->toDateString(),
            'status' => 'pending',
        ]);
        $wedding->registryItems()->create([
            'name' => 'Honeymoon Fund',
            'type' => 'cash_fund',
        ])->contributions()->create([
            'wedding_id' => $wedding->id,
            'guest_id' => $pendingGuest->id,
            'contributor_name' => 'Pending Guest',
            'amount' => 100,
            'payment_status' => 'completed',
        ]);
        $wedding->thankYouRecords()->create([
            'guest_id' => $pendingGuest->id,
            'recipient_name' => 'Pending Guest',
            'reason' => 'gift',
            'status' => 'pending',
        ]);

        $this->postJson('/api/smart-alerts/refresh')
            ->assertOk()
            ->assertJsonPath('data.total_active', 5)
            ->assertJsonPath('data.critical', 2);

        $response = $this->getJson('/api/smart-alerts')
            ->assertOk()
            ->assertJsonPath('summary.total_active', 5)
            ->assertJsonPath('data.0.status', 'active');

        $keys = collect($response->json('data'))->pluck('key')->all();
        $this->assertContains('rsvp-deadline', $keys);
        $this->assertContains('logistics-missing', $keys);
        $this->assertContains('vendor-payments-due', $keys);
        $this->assertContains('guest-readiness', $keys);
        $this->assertContains('post-wedding-thank-yous', $keys);

        $alertId = $response->json('data.0.id');
        $this->postJson("/api/smart-alerts/{$alertId}/resolve")
            ->assertOk()
            ->assertJsonPath('data.status', 'resolved');

        $this->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('command_center.smart_alerts.total_active', 5);
    }

    public function test_saved_filters_search_and_guarded_bulk_updates_across_core_records(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $guestA = $wedding->guests()->create([
            'first_name' => 'Ava',
            'last_name' => 'Stone',
            'email' => 'ava@example.test',
            'attending_status' => 'pending',
        ]);
        $guestB = $wedding->guests()->create([
            'first_name' => 'Bo',
            'last_name' => 'Ray',
            'attending_status' => 'yes',
            'meal_preference' => null,
        ]);
        $vendor = $wedding->vendors()->create([
            'name' => 'Sound House',
            'category' => 'Music',
            'booking_status' => 'negotiating',
            'contract_signed' => false,
        ]);
        $task = $wedding->tasks()->create([
            'created_by' => $user->id,
            'vendor_id' => $vendor->id,
            'title' => 'Confirm music timeline',
            'category' => 'Music',
            'priority' => 'medium',
            'completed' => false,
        ]);

        $filterId = $this->postJson('/api/saved-filters', [
            'resource_type' => 'guests',
            'name' => 'Pending RSVP with email',
            'criteria' => ['status' => 'pending', 'has_email' => true],
            'is_default' => true,
        ])->assertCreated()
            ->assertJsonPath('data.resource_type', 'guests')
            ->json('data.id');

        $this->getJson('/api/saved-filters?resource_type=guests')
            ->assertOk()
            ->assertJsonPath('data.0.id', $filterId);

        $this->getJson('/api/guests?search=ava&status=pending&has_email=1')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $guestA->id);

        $this->get('/api/guests/export?status=pending&has_email=1')
            ->assertOk()
            ->assertSee('first_name', false)
            ->assertSee('Ava', false);

        $this->postJson('/api/guests/bulk-update', [
            'ids' => [$guestA->id, $guestB->id],
            'updates' => ['vip_flag' => true],
        ])->assertStatus(422);

        $this->postJson('/api/guests/bulk-update', [
            'ids' => [$guestA->id, $guestB->id],
            'updates' => ['vip_flag' => true, 'guest_group' => 'Family'],
            'confirm' => true,
        ])->assertOk()
            ->assertJsonPath('updated', 2);

        $this->assertDatabaseHas('guests', ['id' => $guestA->id, 'vip_flag' => true, 'guest_group' => 'Family']);
        $this->assertDatabaseHas('guests', ['id' => $guestB->id, 'vip_flag' => true, 'guest_group' => 'Family']);

        $this->getJson('/api/plan/tasks?search=music&status=pending&vendor_id=' . $vendor->id)
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $task->id);

        $this->get('/api/plan/tasks/export?search=music&status=pending&vendor_id=' . $vendor->id)
            ->assertOk()
            ->assertSee('title', false)
            ->assertSee('Confirm music timeline', false);

        $this->postJson('/api/plan/tasks/bulk-update', [
            'ids' => [$task->id],
            'updates' => ['completed' => true, 'priority' => 'high'],
            'confirm' => true,
        ])->assertOk()
            ->assertJsonPath('data.0.completed', true)
            ->assertJsonPath('data.0.priority', 'high');

        $this->getJson('/api/plan/vendors?search=sound&status=negotiating&contract_signed=0')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $vendor->id);

        $this->get('/api/plan/vendors/export?search=sound&status=negotiating&contract_signed=0')
            ->assertOk()
            ->assertSee('name', false)
            ->assertSee('Sound House', false);

        $this->postJson('/api/plan/vendors/bulk-update', [
            'ids' => [$vendor->id],
            'updates' => ['booking_status' => 'confirmed', 'contract_signed' => true],
            'confirm' => true,
        ])->assertOk()
            ->assertJsonPath('data.0.booking_status', 'confirmed')
            ->assertJsonPath('data.0.contract_signed', true);
    }

    public function test_idempotency_and_operational_health_protect_reliability_paths(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $payload = [
            'first_name' => 'Mina',
            'last_name' => 'Reed',
            'email' => 'mina@example.test',
        ];

        $first = $this->withHeader('Idempotency-Key', 'guest-create-mina')
            ->postJson('/api/guests', $payload)
            ->assertCreated()
            ->json('data.id');

        $this->withHeader('Idempotency-Key', 'guest-create-mina')
            ->postJson('/api/guests', $payload)
            ->assertCreated()
            ->assertHeader('Idempotency-Replayed', 'true')
            ->assertJsonPath('data.id', $first);

        $this->assertDatabaseCount('guests', 1);

        $this->withHeader('Idempotency-Key', 'guest-create-mina')
            ->postJson('/api/guests', [...$payload, 'email' => 'other@example.test'])
            ->assertStatus(409);

        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Wedding update',
            'body' => 'A real operational message.',
            'channel' => 'email',
            'status' => 'sending',
        ]);
        $message->forceFill(['updated_at' => now()->subHour()])->save();
        $message->deliveries()->create([
            'guest_id' => $wedding->guests()->first()->id,
            'status' => 'failed',
            'channel' => 'email',
            'error_message' => 'Provider timeout',
        ]);
        GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $wedding->guests()->first()->id,
            'expires_at' => now()->subDay(),
        ]);

        $this->getJson('/api/reliability/health')
            ->assertOk()
            ->assertJsonPath('data.status', 'attention')
            ->assertJsonPath('data.queue.failed_deliveries', 1)
            ->assertJsonPath('data.queue.stale_sending_messages', 1)
            ->assertJsonPath('data.tokens.expired_active', 1);

        $this->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('command_center.platform_health.status', 'attention')
            ->assertJsonPath('command_center.platform_health.queue.failed_deliveries', 1);
    }

    public function test_internal_ops_requires_admin_and_can_override_entitlements(): void
    {
        [$normalUser] = $this->userWithWedding();
        Sanctum::actingAs($normalUser);

        $this->getJson('/api/internal/ops')->assertForbidden();

        (new RolesSeeder())->run();
        $admin = User::factory()->create(['email' => 'ops@example.test']);
        $admin->assignRole('admin');
        $target = User::factory()->create([
            'first_name' => 'Support',
            'last_name' => 'Target',
            'email' => 'target@example.test',
        ]);
        Wedding::create([
            'couple_name_primary' => 'Target',
            'couple_name_secondary' => 'Couple',
            'owner_user_id' => $target->id,
        ]);

        Sanctum::actingAs($admin);

        $this->getJson('/api/internal/ops?q=target@example.test')
            ->assertOk()
            ->assertJsonPath('data.users.0.email', 'target@example.test')
            ->assertJsonStructure(['data' => ['summary', 'health', 'users', 'weddings', 'delivery_diagnostics', 'plans']]);

        $this->patchJson("/api/internal/ops/users/{$target->id}/entitlement", [
            'plan' => 'elite',
            'status' => 'trialing',
            'billing_cycle' => 'annual',
            'note' => 'Wedding day support escalation.',
            'confirm' => true,
        ])->assertOk()
            ->assertJsonPath('data.plan', 'elite')
            ->assertJsonPath('data.status', 'trialing')
            ->assertJsonPath('data.metadata.last_ops_override.by_user_id', $admin->id);

        $this->assertDatabaseHas('subscriptions', [
            'user_id' => $target->id,
            'plan' => 'elite',
            'status' => 'trialing',
            'billing_cycle' => 'annual',
        ]);
    }

    public function test_admin_bootstrap_command_creates_staff_user_with_role(): void
    {
        $this->artisan('admin:ensure', [
            'email' => 'ops-admin@example.test',
            '--name' => 'Ops Admin',
            '--password' => 'CorrectHorse123!',
            '--role' => 'ops_admin',
        ])->assertSuccessful();

        $admin = User::where('email', 'ops-admin@example.test')->firstOrFail();

        $this->assertTrue($admin->hasRole('ops_admin'));
        $this->assertNotNull($admin->email_verified_at);
        $this->assertTrue($admin->onboarding_completed);
        $this->assertTrue($admin->canAccessPanel(app(\Filament\Panel::class)));
        $this->assertDatabaseHas('permissions', [
            'name' => 'admin.operations',
            'guard_name' => 'web',
        ]);
    }

    public function test_message_send_creates_pending_deliveries_and_dispatches_jobs(): void
    {
        Queue::fake();
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guestA = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $guestB = $wedding->guests()->create(['first_name' => 'Bo', 'email' => 'bo@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'draft',
        ]);

        $this->postJson("/api/messages/{$message->id}/send")
            ->assertOk()
            ->assertJsonPath('data.status', 'sending')
            ->assertJsonPath('recipients', 2);

        $this->assertDatabaseHas('guest_message_deliveries', [
            'message_id' => $message->id,
            'guest_id' => $guestA->id,
            'status' => 'pending',
            'channel' => 'email',
        ]);
        $this->assertDatabaseHas('guest_message_deliveries', [
            'message_id' => $message->id,
            'guest_id' => $guestB->id,
            'status' => 'pending',
            'channel' => 'email',
        ]);
        Queue::assertPushed(SendGuestMessageDeliveryJob::class, 2);
    }

    public function test_scheduled_message_command_dispatches_due_messages(): void
    {
        Queue::fake();
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Reminder',
            'body' => 'RSVP closes tonight.',
            'channel' => 'email',
            'status' => 'scheduled',
            'scheduled_at' => now()->subMinute(),
        ]);

        $this->artisan('messages:dispatch-scheduled')
            ->expectsOutput('Dispatched 1 scheduled message(s).')
            ->assertExitCode(0);

        $this->assertDatabaseHas('messages', [
            'id' => $message->id,
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $this->assertDatabaseHas('guest_message_deliveries', [
            'message_id' => $message->id,
            'guest_id' => $guest->id,
            'status' => 'pending',
        ]);
        Queue::assertPushed(SendGuestMessageDeliveryJob::class, 1);
    }

    public function test_scheduled_message_command_leaves_future_messages_pending(): void
    {
        Queue::fake();
        [$user, $wedding] = $this->userWithWedding();
        $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Reminder',
            'body' => 'RSVP closes tonight.',
            'channel' => 'email',
            'status' => 'scheduled',
            'scheduled_at' => now()->addHour(),
        ]);

        $this->artisan('messages:dispatch-scheduled')
            ->expectsOutput('Dispatched 0 scheduled message(s).')
            ->assertExitCode(0);

        $this->assertDatabaseHas('messages', [
            'id' => $message->id,
            'status' => 'scheduled',
        ]);
        Queue::assertNothingPushed();
    }

    public function test_email_message_delivery_job_marks_delivery_sent(): void
    {
        Mail::fake();
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'email',
        ]);

        (new SendGuestMessageDeliveryJob($delivery->id))->handle();

        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'sent',
        ]);
        $this->assertDatabaseHas('messages', [
            'id' => $message->id,
            'status' => 'sent',
        ]);
    }

    public function test_email_delivery_fails_cleanly_when_guest_opted_out(): void
    {
        Mail::fake();
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'email' => 'ava@example.test',
            'email_opt_out' => true,
        ]);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'email',
        ]);

        try {
            (new SendGuestMessageDeliveryJob($delivery->id))->handle();
        } catch (\Throwable) {
            // The job rethrows provider failures so the queue can retry them.
        }

        Mail::assertNothingSent();
        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'failed',
            'error_message' => 'Guest has opted out of email messages.',
        ]);
    }

    public function test_message_retry_failed_requeues_only_failed_deliveries(): void
    {
        Queue::fake();
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $failedGuest = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $sentGuest = $wedding->guests()->create(['first_name' => 'Bo', 'email' => 'bo@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'failed',
            'recipient_count' => 2,
        ]);
        $failedDelivery = $message->deliveries()->create([
            'guest_id' => $failedGuest->id,
            'status' => 'failed',
            'channel' => 'email',
            'external_id' => 'old-provider-id',
            'sent_at' => now(),
            'error_message' => 'Temporary provider failure.',
        ]);
        $message->deliveries()->create([
            'guest_id' => $sentGuest->id,
            'status' => 'sent',
            'channel' => 'email',
            'sent_at' => now(),
        ]);

        $this->postJson("/api/messages/{$message->id}/retry-failed")
            ->assertOk()
            ->assertJsonPath('queued', 1)
            ->assertJsonPath('data.status', 'sending');

        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $failedDelivery->id,
            'status' => 'pending',
            'external_id' => null,
            'error_message' => null,
        ]);
        Queue::assertPushed(SendGuestMessageDeliveryJob::class, 1);
    }

    public function test_message_retry_failed_noops_when_there_are_no_failed_deliveries(): void
    {
        Queue::fake();
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'sent',
            'recipient_count' => 1,
            'sent_at' => now(),
        ]);
        $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'sent',
            'channel' => 'email',
            'sent_at' => now(),
        ]);

        $this->postJson("/api/messages/{$message->id}/retry-failed")
            ->assertOk()
            ->assertJsonPath('queued', 0)
            ->assertJsonPath('data.status', 'sent');

        Queue::assertNothingPushed();
    }

    public function test_message_index_includes_delivery_summary(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guestA = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $guestB = $wedding->guests()->create(['first_name' => 'Bo', 'email' => 'bo@example.test']);
        $guestC = $wedding->guests()->create(['first_name' => 'Cy', 'email' => 'cy@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'failed',
            'recipient_count' => 3,
        ]);
        $message->deliveries()->create([
            'guest_id' => $guestA->id,
            'status' => 'delivered',
            'channel' => 'email',
            'sent_at' => now(),
            'delivered_at' => now(),
        ]);
        $message->deliveries()->create([
            'guest_id' => $guestB->id,
            'status' => 'opened',
            'channel' => 'email',
            'sent_at' => now(),
            'delivered_at' => now(),
            'opened_at' => now(),
        ]);
        $message->deliveries()->create([
            'guest_id' => $guestC->id,
            'status' => 'failed',
            'channel' => 'email',
            'error_message' => 'Mailbox unavailable.',
        ]);

        $this->getJson('/api/messages')
            ->assertOk()
            ->assertJsonPath('data.0.delivery_summary.total', 3)
            ->assertJsonPath('data.0.delivery_summary.counts.delivered', 1)
            ->assertJsonPath('data.0.delivery_summary.counts.opened', 1)
            ->assertJsonPath('data.0.delivery_summary.counts.failed', 1)
            ->assertJsonPath('data.0.delivery_summary.delivered_count', 2)
            ->assertJsonPath('data.0.delivery_summary.retryable_count', 1)
            ->assertJsonPath('data.0.delivery_summary.delivery_rate', 66.7);
    }

    public function test_message_delivery_summary_endpoint_groups_failure_reasons(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);
        $guestA = $wedding->guests()->create(['first_name' => 'Ava', 'email' => 'ava@example.test']);
        $guestB = $wedding->guests()->create(['first_name' => 'Bo', 'email' => 'bo@example.test']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'email',
            'status' => 'failed',
            'recipient_count' => 2,
        ]);
        $message->deliveries()->create([
            'guest_id' => $guestA->id,
            'status' => 'failed',
            'channel' => 'email',
            'error_message' => 'Guest has opted out of email messages.',
        ]);
        $message->deliveries()->create([
            'guest_id' => $guestB->id,
            'status' => 'bounced',
            'channel' => 'email',
            'error_message' => 'Guest has opted out of email messages.',
        ]);

        $this->getJson("/api/messages/{$message->id}/delivery-summary")
            ->assertOk()
            ->assertJsonPath('data.failed_count', 2)
            ->assertJsonPath('data.failure_rate', 100)
            ->assertJsonPath('data.failure_reasons.0.message', 'Guest has opted out of email messages.')
            ->assertJsonPath('data.failure_reasons.0.count', 2);
    }

    public function test_sms_message_delivery_job_uses_twilio_and_stores_provider_id(): void
    {
        config([
            'services.twilio.account_sid' => 'AC123',
            'services.twilio.auth_token' => 'secret',
            'services.twilio.sms_from' => '+15550001111',
        ]);
        Http::fake([
            'api.twilio.com/*' => Http::response(['sid' => 'SM123'], 201),
        ]);
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'phone' => '+15550002222']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'sms',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'sms',
        ]);

        (new SendGuestMessageDeliveryJob($delivery->id))->handle();

        Http::assertSent(fn ($request) =>
            $request->url() === 'https://api.twilio.com/2010-04-01/Accounts/AC123/Messages.json'
            && $request['From'] === '+15550001111'
            && $request['To'] === '+15550002222'
            && $request['Body'] === 'Ceremony starts at 4.'
            && str_ends_with($request['StatusCallback'], '/api/webhooks/twilio/messages')
        );
        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'sent',
            'external_id' => 'SM123',
        ]);
    }

    public function test_whatsapp_message_delivery_job_prefixes_twilio_addresses(): void
    {
        config([
            'services.twilio.account_sid' => 'AC123',
            'services.twilio.auth_token' => 'secret',
            'services.twilio.whatsapp_from' => '+15550001111',
        ]);
        Http::fake([
            'api.twilio.com/*' => Http::response(['sid' => 'WM123'], 201),
        ]);
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'phone' => '+15550002222']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'whatsapp',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'whatsapp',
        ]);

        (new SendGuestMessageDeliveryJob($delivery->id))->handle();

        Http::assertSent(fn ($request) =>
            $request['From'] === 'whatsapp:+15550001111'
            && $request['To'] === 'whatsapp:+15550002222'
        );
        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'sent',
            'external_id' => 'WM123',
        ]);
    }

    public function test_sms_delivery_fails_cleanly_when_twilio_is_not_configured(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'phone' => '+15550002222']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'sms',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'sms',
        ]);

        try {
            (new SendGuestMessageDeliveryJob($delivery->id))->handle();
        } catch (\Throwable) {
            // The job rethrows provider failures so the queue can retry them.
        }

        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'failed',
            'error_message' => 'Twilio SMS credentials are not configured.',
        ]);
    }

    public function test_sms_delivery_fails_cleanly_when_guest_opted_out(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'phone' => '+15550002222',
            'sms_opt_out' => true,
        ]);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'sms',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'pending',
            'channel' => 'sms',
        ]);

        try {
            (new SendGuestMessageDeliveryJob($delivery->id))->handle();
        } catch (\Throwable) {
            // The job rethrows provider failures so the queue can retry them.
        }

        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'failed',
            'error_message' => 'Guest has opted out of SMS messages.',
        ]);
    }

    public function test_twilio_webhook_marks_delivery_delivered(): void
    {
        config(['services.twilio.validate_webhooks' => false]);
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'phone' => '+15550002222']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'sms',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'sent',
            'channel' => 'sms',
            'external_id' => 'SM123',
            'sent_at' => now(),
        ]);

        $this->postJson('/api/webhooks/twilio/messages', [
            'MessageSid' => 'SM123',
            'MessageStatus' => 'delivered',
        ])->assertOk();

        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'delivered',
        ]);
        $this->assertDatabaseHas('messages', [
            'id' => $message->id,
            'status' => 'sent',
        ]);
    }

    public function test_twilio_webhook_marks_delivery_failed(): void
    {
        config(['services.twilio.validate_webhooks' => false]);
        [$user, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'phone' => '+15550002222']);
        $message = $wedding->messages()->create([
            'created_by' => $user->id,
            'subject' => 'Schedule update',
            'body' => 'Ceremony starts at 4.',
            'channel' => 'sms',
            'status' => 'sending',
            'recipient_count' => 1,
        ]);
        $delivery = $message->deliveries()->create([
            'guest_id' => $guest->id,
            'status' => 'sent',
            'channel' => 'sms',
            'external_id' => 'SM123',
            'sent_at' => now(),
        ]);

        $this->postJson('/api/webhooks/twilio/messages', [
            'MessageSid' => 'SM123',
            'MessageStatus' => 'undelivered',
            'ErrorMessage' => 'Carrier rejected message.',
        ])->assertOk();

        $this->assertDatabaseHas('guest_message_deliveries', [
            'id' => $delivery->id,
            'status' => 'failed',
            'error_message' => 'Carrier rejected message.',
        ]);
        $this->assertDatabaseHas('messages', [
            'id' => $message->id,
            'status' => 'failed',
        ]);
    }

    public function test_twilio_webhook_rejects_missing_signature_when_validation_enabled(): void
    {
        config([
            'services.twilio.validate_webhooks' => true,
            'services.twilio.auth_token' => 'secret',
        ]);

        $this->postJson('/api/webhooks/twilio/messages', [
            'MessageSid' => 'SM123',
            'MessageStatus' => 'delivered',
        ])->assertForbidden();
    }

    public function test_owner_can_add_wedding_team_member_with_role_permissions(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create(['email' => 'planner@example.test']);
        Sanctum::actingAs($owner);

        $this->postJson('/api/wedding/team', [
            'email' => 'planner@example.test',
            'role' => 'planner',
            'permissions' => ['manage_guests', 'manage_messages'],
        ])
            ->assertCreated()
            ->assertJsonPath('data.email', 'planner@example.test')
            ->assertJsonPath('data.role', 'planner')
            ->assertJsonPath('data.permissions.0', 'manage_guests')
            ->assertJsonPath('data.permissions.1', 'manage_messages')
            ->assertJsonPath('data.is_owner', false);

        $this->assertDatabaseHas('wedding_collaborators', [
            'wedding_id' => $wedding->id,
            'user_id' => $planner->id,
            'role' => 'planner',
        ]);
        $this->assertDatabaseHas('users', [
            'id' => $planner->id,
            'active_wedding_id' => $wedding->id,
        ]);
    }

    public function test_team_index_includes_owner_and_available_role_presets(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create(['email' => 'viewer@example.test']);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($owner);

        $this->getJson('/api/wedding/team')
            ->assertOk()
            ->assertJsonPath('data.0.email', $owner->email)
            ->assertJsonPath('data.0.role', 'owner')
            ->assertJsonPath('data.0.is_owner', true)
            ->assertJsonPath('data.1.email', 'viewer@example.test')
            ->assertJsonPath('data.1.role', 'viewer')
            ->assertJsonPath('roles.0.role', 'owner')
            ->assertJsonPath('permissions.0', 'manage_wedding');
    }

    public function test_collaborator_auth_payload_includes_wedding_access(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create([
            'email' => 'planner@example.test',
            'active_wedding_id' => $wedding->id,
        ]);
        $wedding->collaborators()->create([
            'user_id' => $planner->id,
            'role' => 'planner',
            'permissions' => ['manage_guests', 'manage_messages'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($planner);

        $this->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('wedding_role', 'planner')
            ->assertJsonPath('wedding_permissions.0', 'manage_guests')
            ->assertJsonPath('wedding_permissions.1', 'manage_messages')
            ->assertJsonPath('is_wedding_owner', false);
    }

    public function test_authenticated_user_can_update_profile(): void
    {
        [$user] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $this->patchJson('/api/auth/me', [
            'first_name' => 'Updated',
            'last_name' => 'Planner',
            'email' => 'updated@example.test',
            'avatar_url' => 'https://example.test/avatar.jpg',
        ])
            ->assertOk()
            ->assertJsonPath('first_name', 'Updated')
            ->assertJsonPath('last_name', 'Planner')
            ->assertJsonPath('email', 'updated@example.test')
            ->assertJsonPath('avatar_url', 'https://example.test/avatar.jpg');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Updated Planner',
            'email' => 'updated@example.test',
        ]);
    }

    public function test_authenticated_user_can_update_preferences(): void
    {
        [$user] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $this->patchJson('/api/auth/preferences', [
            'notification_preferences' => [
                'rsvp_updates' => false,
                'task_reminders' => true,
                'guest_messages' => false,
                'live_mode' => true,
                'vendor_updates' => true,
            ],
            'support_preferences' => [
                'email_support' => false,
                'chat_support' => true,
                'proactive_checkins' => false,
                'response_time' => 'within-1h',
            ],
        ])
            ->assertOk()
            ->assertJsonPath('notification_preferences.rsvp_updates', false)
            ->assertJsonPath('notification_preferences.vendor_updates', true)
            ->assertJsonPath('support_preferences.chat_support', true)
            ->assertJsonPath('support_preferences.response_time', 'within-1h');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
        ]);
        $this->assertFalse($user->fresh()->notification_preferences['rsvp_updates']);
        $this->assertSame('within-1h', $user->fresh()->support_preferences['response_time']);
    }

    public function test_authenticated_user_can_export_privacy_data(): void
    {
        [$user, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($user);

        $this->getJson('/api/auth/privacy/export')
            ->assertOk()
            ->assertJsonPath('user.id', $user->id)
            ->assertJsonPath('user.email', $user->email)
            ->assertJsonPath('owned_weddings.0.id', $wedding->id)
            ->assertJsonMissingPath('user.password');
    }

    public function test_authenticated_user_can_revoke_all_api_tokens(): void
    {
        [$user] = $this->userWithWedding();
        $user->createToken('api');
        $user->createToken('mobile');
        Sanctum::actingAs($user);

        $this->postJson('/api/auth/logout-all')
            ->assertOk()
            ->assertJsonPath('message', 'All sessions have been logged out.');

        $this->assertSame(0, $user->tokens()->count());
    }

    public function test_authenticated_user_can_delete_account_by_anonymizing_profile(): void
    {
        [$user] = $this->userWithWedding();
        $user->createToken('api');
        Sanctum::actingAs($user);

        $this->deleteJson('/api/auth/me', [
            'confirmation' => 'DELETE',
            'current_password' => 'password',
        ])
            ->assertOk()
            ->assertJsonPath('message', 'Account deleted and personal profile data anonymized.');

        $fresh = $user->fresh();
        $this->assertSame("deleted-user-{$user->id}@udo.invalid", $fresh->email);
        $this->assertNull($fresh->active_wedding_id);
        $this->assertNull($fresh->phone);
        $this->assertSame(0, $fresh->tokens()->count());
        $this->assertNotNull($fresh->support_preferences['account_deleted_at']);
    }

    public function test_admin_account_safety_service_exports_revokes_and_anonymizes_with_audit(): void
    {
        [$target, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $originalEmail = $target->email;
        $target->createToken('api');
        $target->createToken('mobile');

        $service = app(AdminAccountSafetyService::class);

        $export = $service->privacyExport($target, $admin);

        $this->assertSame($target->id, $export['user']['id']);
        $this->assertSame($originalEmail, $export['user']['email']);
        $this->assertSame($wedding->id, $export['owned_weddings'][0]['id']);
        $this->assertArrayNotHasKey('password', $export['user']);
        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $admin->id,
            'action' => 'admin.privacy_exported',
            'auditable_type' => User::class,
            'auditable_id' => $target->id,
        ]);

        $revoked = $service->revokeTokens($target, $admin);

        $this->assertSame(2, $revoked);
        $this->assertSame(0, $target->tokens()->count());
        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $admin->id,
            'action' => 'admin.tokens_revoked',
            'auditable_type' => User::class,
            'auditable_id' => $target->id,
        ]);

        $target->createToken('replacement');
        $summary = $service->anonymize($target, $admin);
        $fresh = $target->fresh();

        $this->assertSame(1, $summary['revoked_api_tokens']);
        $this->assertSame("deleted-user-{$target->id}@udo.invalid", $fresh->email);
        $this->assertSame('deleted', $fresh->auth_provider);
        $this->assertNull($fresh->active_wedding_id);
        $this->assertSame(0, $fresh->tokens()->count());
        $this->assertNotNull($fresh->support_preferences['account_deleted_at']);
        $this->assertSame($admin->id, $fresh->support_preferences['account_deleted_by_admin_id']);

        $auditLog = AuditLog::where('action', 'admin.user_anonymized')
            ->where('auditable_type', User::class)
            ->where('auditable_id', $target->id)
            ->first();

        $this->assertNotNull($auditLog);
        $this->assertSame($originalEmail, $auditLog->before['email']);
        $this->assertSame($fresh->email, $auditLog->after['email']);
    }

    public function test_viewer_cannot_update_wedding_or_manage_team(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create([
            'email' => 'viewer@example.test',
            'active_wedding_id' => $wedding->id,
        ]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($viewer);

        $this->patchJson('/api/wedding', [
            'city' => 'Accra',
        ])->assertForbidden();

        $this->getJson('/api/wedding/team')
            ->assertForbidden();
    }

    public function test_collaborator_can_list_and_switch_accessible_weddings(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create(['email' => 'planner@example.test']);
        $ownWedding = Wedding::create([
            'couple_name_primary' => 'Planner',
            'couple_name_secondary' => 'Home',
            'owner_user_id' => $planner->id,
        ]);
        $planner->update(['active_wedding_id' => $ownWedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $planner->id,
            'role' => 'planner',
            'permissions' => ['manage_guests', 'manage_messages'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($planner);

        $this->getJson('/api/weddings')
            ->assertOk()
            ->assertJsonPath('data.0.access.role', 'owner')
            ->assertJsonPath('data.0.is_active', true)
            ->assertJsonPath('data.1.access.role', 'planner')
            ->assertJsonPath('data.1.is_active', false);

        $this->postJson('/api/weddings/switch', [
            'wedding_id' => $wedding->id,
        ])
            ->assertOk()
            ->assertJsonPath('id', $wedding->id)
            ->assertJsonPath('access.role', 'planner');

        $this->assertDatabaseHas('users', [
            'id' => $planner->id,
            'active_wedding_id' => $wedding->id,
        ]);
    }

    public function test_user_can_create_additional_active_wedding_workspace(): void
    {
        [$owner, $firstWedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $weddingId = $this->postJson('/api/weddings', [
            'title' => 'Destination celebration',
            'couple_name_primary' => 'Nora',
            'couple_name_secondary' => 'Kai',
            'event_date' => '2027-06-12',
            'city' => 'Lisbon',
            'country' => 'Portugal',
        ])
            ->assertCreated()
            ->assertJsonPath('title', 'Destination celebration')
            ->assertJsonPath('couple_name_primary', 'Nora')
            ->assertJsonPath('access.role', 'owner')
            ->assertJsonPath('is_active', true)
            ->json('id');

        $this->assertDatabaseHas('weddings', [
            'id' => $weddingId,
            'owner_user_id' => $owner->id,
            'city' => 'Lisbon',
        ]);
        $this->assertDatabaseHas('users', [
            'id' => $owner->id,
            'active_wedding_id' => $weddingId,
            'onboarding_completed' => true,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $weddingId,
            'user_id' => $owner->id,
            'action' => 'wedding.created',
        ]);

        $weddings = collect($this->getJson('/api/weddings')
            ->assertOk()
            ->json('data'));

        $this->assertFalse($weddings->firstWhere('id', $firstWedding->id)['is_active']);
        $this->assertTrue($weddings->firstWhere('id', $weddingId)['is_active']);
    }

    public function test_billing_entitlements_include_plan_limits_and_usage(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $wedding->guests()->create(['first_name' => 'Ava']);
        $wedding->collaborators()->create([
            'user_id' => User::factory()->create()->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);

        $this->getJson('/api/billing/entitlements')
            ->assertOk()
            ->assertJsonPath('data.plan', 'free')
            ->assertJsonPath('data.limits.guests', 50)
            ->assertJsonPath('data.limits.team_members', 1)
            ->assertJsonPath('data.usage.guests', 1)
            ->assertJsonPath('data.usage.team_members', 1);
    }

    public function test_admin_subscription_ops_override_sets_price_metadata_and_audit_log(): void
    {
        config(['services.billing.stripe_prices.pro.annual' => 'price_pro_annual_test']);
        [$owner] = $this->userWithWedding();
        $admin = User::factory()->create();
        $subscription = Subscription::create([
            'user_id' => $owner->id,
            'plan' => 'free',
            'status' => 'active',
            'billing_cycle' => 'monthly',
            'amount' => 0,
            'currency' => 'USD',
        ]);

        $updated = app(AdminSubscriptionOpsService::class)->override($subscription, $admin, [
            'plan' => 'pro',
            'status' => 'trialing',
            'billing_cycle' => 'annual',
            'note' => 'Planner migration credit approved.',
        ]);

        $this->assertSame('pro', $updated->plan);
        $this->assertSame('trialing', $updated->status);
        $this->assertSame('annual', $updated->billing_cycle);
        $this->assertEquals(790, (float) $updated->amount);
        $this->assertSame('price_pro_annual_test', $updated->stripe_price_id);
        $this->assertSame($admin->id, $updated->metadata['last_admin_override']['by_user_id']);
        $this->assertSame('Planner migration credit approved.', $updated->metadata['last_admin_override']['note']);

        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $admin->id,
            'action' => 'admin.subscription_overridden',
            'auditable_type' => Subscription::class,
            'auditable_id' => $subscription->id,
        ]);
    }

    public function test_admin_budget_payment_ops_marks_schedule_paid_and_audits_balance_rollup(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $budgetItem = $wedding->budgetItems()->create([
            'category' => 'venue',
            'name' => 'Venue balance',
            'estimated_amount' => 1000,
            'actual_amount' => 1200,
            'paid_amount' => 0,
            'payment_status' => 'pending',
        ]);
        $schedule = $budgetItem->paymentSchedules()->create([
            'wedding_id' => $wedding->id,
            'label' => 'Final installment',
            'amount' => 1200,
            'due_date' => now()->subDay()->toDateString(),
            'status' => 'pending',
        ]);

        $updated = app(AdminBudgetPaymentOpsService::class)->markPaid($schedule, $admin, 'Wire confirmed.');
        $freshItem = $budgetItem->fresh();

        $this->assertSame('paid', $updated->status);
        $this->assertNotNull($updated->paid_at);
        $this->assertStringContainsString('Wire confirmed.', $updated->notes);
        $this->assertEquals(1200, (float) $freshItem->paid_amount);
        $this->assertSame('paid', $freshItem->payment_status);

        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.budget_payment_marked_paid',
            'auditable_type' => BudgetPaymentSchedule::class,
            'auditable_id' => $schedule->id,
        ]);
    }

    public function test_admin_vendor_ops_logs_contact_marks_contract_and_flags_risk(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $vendor = $wedding->vendors()->create([
            'name' => 'Golden Hall',
            'category' => 'venue',
            'booking_status' => 'booked',
            'contract_signed' => false,
            'balance_due' => 500,
            'balance_due_date' => now()->subDay()->toDateString(),
        ]);

        $service = app(AdminVendorOpsService::class);
        $this->assertSame('attention', $service->riskScore($vendor));

        $log = $service->logContact($vendor, $admin, [
            'contact_type' => 'email',
            'subject' => 'Contract follow-up',
            'outcome' => 'Awaiting countersignature',
            'follow_up_at' => now()->addDays(2),
        ]);

        $this->assertSame($vendor->id, $log->vendor_id);
        $this->assertSame($admin->id, $log->created_by);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.vendor_contact_logged',
            'auditable_type' => VendorContactLog::class,
            'auditable_id' => $log->id,
        ]);

        $updated = $service->markContractSigned($vendor, $admin, 'https://example.com/contract.pdf');

        $this->assertTrue($updated->contract_signed);
        $this->assertSame('https://example.com/contract.pdf', $updated->contract_file_url);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.vendor_contract_signed',
            'auditable_type' => Vendor::class,
            'auditable_id' => $vendor->id,
        ]);
    }

    public function test_admin_gallery_moderation_service_moderates_and_audits_assets(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'last_name' => 'Stone',
            'email' => 'ava@example.com',
        ]);
        $asset = $wedding->galleryAssets()->create([
            'uploaded_by_guest_id' => $guest->id,
            'type' => 'photo',
            'source' => 'upload',
            'url' => 'https://example.com/photo.jpg',
            'album' => 'guest_uploads',
            'approved' => false,
            'is_featured' => false,
        ]);

        $service = app(AdminGalleryModerationService::class);
        $approved = $service->moderate($asset, $admin, 'approve', 'Looks good.');
        $featured = $service->moderate($approved, $admin, 'feature');

        $this->assertTrue($approved->approved);
        $this->assertTrue($featured->is_featured);

        $archived = $service->moderate($featured, $admin, 'archive');

        $this->assertSame('archive', $archived->album);
        $this->assertFalse($archived->is_featured);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.gallery_asset_approve',
            'auditable_type' => GalleryAsset::class,
            'auditable_id' => $asset->id,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.gallery_asset_archive',
            'auditable_type' => GalleryAsset::class,
            'auditable_id' => $asset->id,
        ]);
    }

    public function test_admin_registry_ops_marks_contribution_paid_and_thank_you_sent_with_audit(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'last_name' => 'Stone']);
        $item = $wedding->registryItems()->create([
            'name' => 'Honeymoon Fund',
            'type' => 'cash_fund',
        ]);
        $contribution = $item->contributions()->create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'contributor_name' => 'Ava Stone',
            'amount' => 150,
            'payment_status' => 'pending',
        ]);
        $thankYou = $wedding->thankYouRecords()->create([
            'guest_id' => $guest->id,
            'contribution_id' => $contribution->id,
            'recipient_name' => 'Ava Stone',
            'reason' => 'gift',
            'status' => 'pending',
        ]);

        $service = app(AdminRegistryOpsService::class);
        $paid = $service->markContributionPaid($contribution, $admin);
        $sent = $service->markThankYouSent($thankYou, $admin, 'Thank you so much.', 'email');

        $this->assertSame('completed', $paid->payment_status);
        $this->assertNotNull($paid->paid_at);
        $this->assertSame('sent', $sent->status);
        $this->assertNotNull($sent->sent_at);
        $this->assertTrue($contribution->fresh()->thank_you_sent);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.registry_contribution_marked_paid',
            'auditable_type' => RegistryContribution::class,
            'auditable_id' => $contribution->id,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.thank_you_marked_sent',
            'auditable_type' => ThankYouRecord::class,
            'auditable_id' => $thankYou->id,
        ]);
    }

    public function test_admin_logistics_ops_assigns_accommodation_and_transport_with_audit(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $guest = $wedding->guests()->create([
            'first_name' => 'Ava',
            'travel_required' => true,
        ]);
        $hotel = $wedding->accommodationOptions()->create([
            'name' => 'Harbor Hotel',
            'total_rooms_blocked' => 2,
        ]);
        $transport = $wedding->transportGroups()->create([
            'name' => 'Airport shuttle',
            'capacity' => 2,
        ]);

        $service = app(AdminLogisticsOpsService::class);
        $assignedHotel = $service->assignAccommodation($hotel, $guest, $admin);
        $assignedTransport = $service->assignTransport($transport, $guest->fresh(), $admin);

        $this->assertSame($hotel->id, $guest->fresh()->hotel_assignment_id);
        $this->assertSame(1, $assignedHotel->rooms_assigned);
        $this->assertSame($transport->id, $guest->fresh()->transport_assignment_id);
        $this->assertSame(1, $assignedTransport->assigned_count);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.logistics_accommodation_assigned',
            'auditable_type' => AccommodationOption::class,
            'auditable_id' => $hotel->id,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.logistics_transport_assigned',
            'auditable_type' => TransportGroup::class,
            'auditable_id' => $transport->id,
        ]);
    }

    public function test_admin_live_ops_starts_live_and_resolves_update_with_audit(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $update = $wedding->liveUpdates()->create([
            'created_by' => $owner->id,
            'type' => 'incident',
            'title' => 'Shuttle delay',
            'body' => 'Driver is late.',
            'status' => 'open',
            'requires_action' => true,
        ]);

        $service = app(AdminLiveOpsService::class);
        $liveWedding = $service->startLive($wedding, $admin);
        $resolved = $service->resolveUpdate($update, $admin);

        $this->assertSame('live', $liveWedding->status);
        $this->assertSame('resolved', $resolved->status);
        $this->assertFalse($resolved->requires_action);
        $this->assertNotNull($resolved->resolved_at);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.live_wedding_started',
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.live_update_resolved',
            'auditable_type' => LiveUpdate::class,
            'auditable_id' => $update->id,
        ]);
    }

    public function test_admin_live_ops_marks_final_week_with_audit(): void
    {
        [, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();

        $service = app(AdminLiveOpsService::class);
        $updated = $service->markFinalWeek($wedding, $admin);

        $this->assertSame('final_week', $updated->status);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.wedding_marked_final_week',
            'auditable_type' => Wedding::class,
            'auditable_id' => $wedding->id,
        ]);
    }

    public function test_live_command_center_page_and_widgets_surface_live_ops_data(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        [$owner, $wedding] = $this->userWithWedding();
        $wedding->update(['status' => 'live', 'event_date' => now()->toDateString()]);
        $wedding->guests()->create([
            'first_name' => 'Nora',
            'last_name' => 'VIP',
            'vip_flag' => true,
            'attending_status' => 'yes',
            'travel_required' => true,
        ]);
        $incident = $wedding->liveUpdates()->create([
            'created_by' => $owner->id,
            'type' => 'incident',
            'title' => 'Shuttle delay',
            'status' => 'open',
            'requires_action' => true,
        ]);

        $this->actingAs($admin)
            ->get('/admin/live-command-center')
            ->assertOk()
            ->assertSee('Live Command Center');

        Livewire::test(LiveCommandCenterWeddingsWidget::class)
            ->call('loadTable')
            ->assertSuccessful()
            ->assertSee('Amara');

        Livewire::test(UnresolvedLiveIncidentsWidget::class)
            ->call('loadTable')
            ->assertSuccessful()
            ->assertSee('Shuttle delay');

        Livewire::test(VipReadinessWidget::class)
            ->call('loadTable')
            ->assertSuccessful()
            ->assertSee('Nora VIP');

        Livewire::actingAs($admin);
        Livewire::test(UnresolvedLiveIncidentsWidget::class)
            ->callTableAction('resolve', $incident)
            ->assertSuccessful();

        $this->assertDatabaseHas('live_updates', [
            'id' => $incident->id,
            'status' => 'resolved',
            'requires_action' => false,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'admin.live_update_resolved',
            'auditable_type' => LiveUpdate::class,
            'auditable_id' => $incident->id,
        ]);

        $wedding->update(['status' => 'planning']);
        Livewire::test(LiveCommandCenterWeddingsWidget::class)
            ->callTableAction('markFinalWeek', $wedding)
            ->assertSuccessful();

        $this->assertSame('final_week', $wedding->fresh()->status);
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'admin.wedding_marked_final_week',
            'auditable_type' => Wedding::class,
            'auditable_id' => $wedding->id,
        ]);
    }

    public function test_support_ticket_status_changes_auto_track_response_and_resolution_timestamps(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $ticket = SupportTicket::create([
            'user_id' => $owner->id,
            'wedding_id' => $wedding->id,
            'subject' => 'Guest portal not loading',
            'body' => 'A guest says the RSVP link is broken.',
            'status' => 'open',
            'priority' => 'high',
        ]);

        $this->assertNull($ticket->first_responded_at);

        $ticket->update(['status' => 'in_progress']);
        $ticket->refresh();
        $this->assertNotNull($ticket->first_responded_at);
        $this->assertNull($ticket->resolved_at);

        $firstResponse = $ticket->first_responded_at;

        $ticket->update(['status' => 'resolved']);
        $ticket->refresh();
        $this->assertNotNull($ticket->resolved_at);
        $this->assertEquals($firstResponse, $ticket->first_responded_at);

        $ticket->update(['status' => 'open']);
        $ticket->refresh();
        $this->assertNull($ticket->resolved_at);
    }

    public function test_admin_support_ops_assigns_and_resolves_ticket_with_audit(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $admin = User::factory()->create();
        $ticket = SupportTicket::create([
            'user_id' => $owner->id,
            'wedding_id' => $wedding->id,
            'subject' => 'Billing question',
            'body' => 'Why was I charged twice?',
            'status' => 'open',
            'priority' => 'normal',
        ]);

        $service = app(AdminSupportOpsService::class);
        $assigned = $service->assignToMe($ticket, $admin);

        $this->assertSame($admin->id, $assigned->assigned_to);
        $this->assertSame('in_progress', $assigned->status);
        $this->assertNotNull($assigned->first_responded_at);

        $resolved = $service->resolve($assigned, $admin);

        $this->assertSame('resolved', $resolved->status);
        $this->assertNotNull($resolved->resolved_at);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.support_ticket_assigned',
            'auditable_type' => SupportTicket::class,
            'auditable_id' => $ticket->id,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.support_ticket_resolved',
            'auditable_type' => SupportTicket::class,
            'auditable_id' => $ticket->id,
        ]);
    }

    public function test_admin_can_preview_and_send_test_email_template(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('content_admin');
        Sanctum::actingAs($admin);
        Mail::fake();

        $template = EmailTemplate::create([
            'key' => 'admin_preview_test_' . uniqid(),
            'name' => 'Preview test template',
            'subject' => 'Hello {{first_name}}',
            'body' => '<p>Hi {{first_name}}, welcome!</p>',
            'available_variables' => ['first_name'],
        ]);

        Livewire::actingAs($admin);
        Livewire::test(EditEmailTemplate::class, ['record' => $template->getRouteKey()])
            ->mountAction('preview')
            ->assertSuccessful()
            ->assertActionMounted('preview');

        Livewire::test(EditEmailTemplate::class, ['record' => $template->getRouteKey()])
            ->mountAction('sendTest')
            ->setActionData(['email' => 'ops@example.test'])
            ->callMountedAction()
            ->assertSuccessful();

        Mail::assertQueued(TemplatedMail::class, function (TemplatedMail $mail) {
            return str_contains($mail->renderedSubject, 'Alex')
                && str_contains($mail->renderedBody, 'Alex');
        });
    }

    public function test_admin_can_preview_blog_post(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('content_admin');
        Livewire::actingAs($admin);

        $post = BlogPost::create([
            'title' => 'Ten tips for a stress-free wedding day',
            'excerpt' => 'Practical advice from real couples.',
            'body' => '<p>Start early and delegate.</p>',
            'category' => 'Planning',
            'status' => 'draft',
        ]);

        Livewire::test(EditBlogPost::class, ['record' => $post->getRouteKey()])
            ->mountAction('preview')
            ->assertSuccessful()
            ->assertActionMounted('preview');
    }

    public function test_admin_bulk_ops_service_applies_updates_and_blocks_cross_wedding_leakage(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        [, $otherWedding] = $this->userWithWedding();
        $admin = User::factory()->create();

        $guestA = $wedding->guests()->create(['first_name' => 'Ava']);
        $guestB = $wedding->guests()->create(['first_name' => 'Bo']);
        $guestOther = $otherWedding->guests()->create(['first_name' => 'Cy']);

        $service = app(AdminBulkOpsService::class);

        $count = $service->applyUpdate(
            'admin.guests_bulk_updated',
            Guest::whereIn('id', [$guestA->id, $guestB->id])->get(),
            ['vip_flag' => true, 'guest_group' => 'Family'],
            $admin,
        );

        $this->assertSame(2, $count);
        $this->assertDatabaseHas('guests', ['id' => $guestA->id, 'vip_flag' => true, 'guest_group' => 'Family']);
        $this->assertDatabaseHas('guests', ['id' => $guestB->id, 'vip_flag' => true, 'guest_group' => 'Family']);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $admin->id,
            'action' => 'admin.guests_bulk_updated',
        ]);

        $this->expectException(\RuntimeException::class);
        $service->applyUpdate(
            'admin.guests_bulk_updated',
            Guest::whereIn('id', [$guestA->id, $guestOther->id])->get(),
            ['vip_flag' => true],
            $admin,
        );
    }

    public function test_admin_bulk_update_stays_blocked_and_unapplied_when_selection_spans_weddings(): void
    {
        [, $wedding] = $this->userWithWedding();
        [, $otherWedding] = $this->userWithWedding();
        $admin = User::factory()->create();

        $guestA = $wedding->guests()->create(['first_name' => 'Ava', 'vip_flag' => false]);
        $guestOther = $otherWedding->guests()->create(['first_name' => 'Cy', 'vip_flag' => false]);

        try {
            app(AdminBulkOpsService::class)->applyUpdate(
                'admin.guests_bulk_updated',
                Guest::whereIn('id', [$guestA->id, $guestOther->id])->get(),
                ['vip_flag' => true],
                $admin,
            );
            $this->fail('Expected cross-wedding bulk update to be blocked.');
        } catch (\RuntimeException) {
            // expected
        }

        $this->assertDatabaseHas('guests', ['id' => $guestA->id, 'vip_flag' => false]);
        $this->assertDatabaseHas('guests', ['id' => $guestOther->id, 'vip_flag' => false]);
        $this->assertDatabaseMissing('audit_logs', ['action' => 'admin.guests_bulk_updated']);
    }

    public function test_admin_can_bulk_update_guests_tasks_and_vendors_from_admin_tables(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');
        Livewire::actingAs($admin);

        [$owner, $wedding] = $this->userWithWedding();
        $guestA = $wedding->guests()->create(['first_name' => 'Ava']);
        $guestB = $wedding->guests()->create(['first_name' => 'Bo']);

        Livewire::test(ListGuests::class)
            ->callTableBulkAction('bulkUpdate', [$guestA->id, $guestB->id], ['vip_flag' => '1', 'guest_group' => 'Family'])
            ->assertSuccessful();

        $this->assertDatabaseHas('guests', ['id' => $guestA->id, 'vip_flag' => true, 'guest_group' => 'Family']);
        $this->assertDatabaseHas('guests', ['id' => $guestB->id, 'vip_flag' => true, 'guest_group' => 'Family']);

        $task = $wedding->tasks()->create([
            'created_by' => $owner->id,
            'title' => 'Confirm florals',
            'priority' => 'low',
            'completed' => false,
        ]);

        Livewire::test(ListTasks::class)
            ->callTableBulkAction('bulkUpdate', [$task->id], ['completed' => '1', 'priority' => 'urgent'])
            ->assertSuccessful();

        $this->assertDatabaseHas('tasks', ['id' => $task->id, 'completed' => true, 'priority' => 'urgent']);

        $vendor = $wedding->vendors()->create([
            'name' => 'Sound House',
            'category' => 'Music',
            'booking_status' => 'negotiating',
            'contract_signed' => false,
        ]);

        Livewire::test(ListVendors::class)
            ->callTableBulkAction('bulkUpdate', [$vendor->id], ['booking_status' => 'confirmed', 'contract_signed' => '1'])
            ->assertSuccessful();

        $this->assertDatabaseHas('vendors', ['id' => $vendor->id, 'booking_status' => 'confirmed', 'contract_signed' => true]);

        [, $otherWedding] = $this->userWithWedding();
        $guestOther = $otherWedding->guests()->create(['first_name' => 'Cy']);

        Livewire::test(ListGuests::class)
            ->callTableBulkAction('bulkUpdate', [$guestA->id, $guestOther->id], ['vip_flag' => '0'])
            ->assertSuccessful();

        $this->assertDatabaseHas('guests', ['id' => $guestA->id, 'vip_flag' => true]);
        $this->assertDatabaseHas('guests', ['id' => $guestOther->id, 'vip_flag' => false]);
    }

    public function test_admin_can_inspect_saved_filters(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');
        [$owner, $wedding] = $this->userWithWedding();

        $filter = \App\Models\SavedFilter::create([
            'wedding_id' => $wedding->id,
            'user_id' => $owner->id,
            'resource_type' => 'guests',
            'name' => 'Pending RSVP with email',
            'criteria' => ['status' => 'pending', 'has_email' => true],
            'is_default' => true,
        ]);

        $this->actingAs($admin)
            ->get('/admin/saved-filters')
            ->assertOk()
            ->assertSee('Pending RSVP with email');

        $this->actingAs($admin)
            ->get("/admin/saved-filters/{$filter->id}")
            ->assertOk()
            ->assertSee('Pending RSVP with email')
            ->assertSee('pending');
    }

    public function test_admin_reliability_ops_retries_and_forgets_failed_jobs_with_audit(): void
    {
        $admin = User::factory()->create();
        $service = app(AdminReliabilityOpsService::class);

        $toRetry = FailedJob::create([
            'uuid' => (string) \Illuminate\Support\Str::uuid(),
            'connection' => 'database',
            'queue' => 'default',
            'payload' => json_encode(['displayName' => 'App\\Jobs\\SendGuestInviteJob', 'job' => 'Illuminate\\Queue\\CallQueuedHandler@call', 'data' => []]),
            'exception' => "RuntimeException: Provider timeout\n#0 test",
            'failed_at' => now(),
        ]);

        $service->retryFailedJob($toRetry, $admin);

        $this->assertDatabaseMissing('failed_jobs', ['id' => $toRetry->id]);
        $this->assertDatabaseHas('jobs', ['queue' => 'default']);
        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $admin->id,
            'action' => 'admin.failed_job_retried',
        ]);

        $toForget = FailedJob::create([
            'uuid' => (string) \Illuminate\Support\Str::uuid(),
            'connection' => 'database',
            'queue' => 'default',
            'payload' => json_encode(['displayName' => 'App\\Jobs\\SendGuestInviteJob']),
            'exception' => "RuntimeException: Bad payload\n#0 test",
            'failed_at' => now(),
        ]);

        $service->forgetFailedJob($toForget, $admin);

        $this->assertDatabaseMissing('failed_jobs', ['id' => $toForget->id]);
        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $admin->id,
            'action' => 'admin.failed_job_forgotten',
        ]);
    }

    public function test_admin_can_retry_failed_job_from_the_admin_table(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');
        Livewire::actingAs($admin);

        $failed = FailedJob::create([
            'uuid' => (string) \Illuminate\Support\Str::uuid(),
            'connection' => 'database',
            'queue' => 'default',
            'payload' => json_encode(['displayName' => 'App\\Jobs\\SendGuestMessageDeliveryJob']),
            'exception' => "RuntimeException: Twilio unavailable\n#0 test",
            'failed_at' => now(),
        ]);

        Livewire::test(ListFailedJobs::class)
            ->assertSee('App\\Jobs\\SendGuestMessageDeliveryJob')
            ->callTableAction('retry', $failed)
            ->assertSuccessful();

        $this->assertDatabaseMissing('failed_jobs', ['id' => $failed->id]);
    }

    public function test_admin_can_inspect_idempotency_key_replay_metadata(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');
        [$owner] = $this->userWithWedding();

        $key = IdempotencyKey::create([
            'user_id' => $owner->id,
            'key' => 'guest-create-mina',
            'method' => 'POST',
            'path' => '/api/guests',
            'request_hash' => hash('sha256', 'test'),
            'status_code' => 201,
            'response_body' => ['data' => ['id' => 42, 'first_name' => 'Mina']],
            'expires_at' => now()->addHours(24),
        ]);

        Livewire::actingAs($admin);
        Livewire::test(ViewIdempotencyKey::class, ['record' => $key->getRouteKey()])
            ->assertSuccessful()
            ->assertSee('guest-create-mina')
            ->assertSee('Mina');
    }

    public function test_reliability_console_page_and_widgets_surface_stale_messages_and_token_risk(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        [$owner, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Ava']);

        $staleMessage = $wedding->messages()->create([
            'created_by' => $owner->id,
            'subject' => 'Stuck newsletter',
            'body' => 'Body',
            'channel' => 'email',
            'status' => 'sending',
        ]);
        $staleMessage->forceFill(['updated_at' => now()->subMinutes(30)])->save();

        $riskyToken = GuestToken::create([
            'wedding_id' => $wedding->id,
            'guest_id' => $guest->id,
            'expires_at' => now()->addDays(2),
        ]);

        FailedJob::create([
            'uuid' => (string) \Illuminate\Support\Str::uuid(),
            'connection' => 'database',
            'queue' => 'default',
            'payload' => json_encode(['displayName' => 'App\\Jobs\\SendGuestInviteJob']),
            'exception' => "RuntimeException: Boom\n#0 test",
            'failed_at' => now(),
        ]);

        $this->actingAs($admin)
            ->get('/admin/reliability-console')
            ->assertOk()
            ->assertSee('Reliability Console');

        Livewire::actingAs($admin);
        Livewire::test(ReliabilityStatsWidget::class)->assertSuccessful();

        Livewire::test(StaleMessagesWidget::class)
            ->call('loadTable')
            ->assertSuccessful()
            ->assertSee('Stuck newsletter');

        Livewire::test(TokenExpiryRiskWidget::class)
            ->call('loadTable')
            ->assertSuccessful()
            ->assertSee('expiring soon');
    }

    public function test_admin_dashboard_navigation_renders_unified_finance_and_support_group(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $this->actingAs($admin)
            ->get('/admin')
            ->assertOk()
            ->assertSee('Finance &amp; Support', false)
            ->assertDontSee('Business');

        $this->actingAs($admin)->get('/admin/support-tickets')->assertOk();
        $this->actingAs($admin)->get('/admin/failed-jobs')->assertOk()->assertSee('No failed jobs');
    }

    public function test_non_staff_user_cannot_access_admin_panel(): void
    {
        (new RolesSeeder())->run();
        [$owner] = $this->userWithWedding();

        $this->actingAs($owner)->get('/admin')->assertForbidden();
        $this->actingAs($owner)->get('/admin/weddings')->assertForbidden();
    }

    public function test_admin_dashboard_renders_operational_widgets_for_authorized_staff(): void
    {
        (new RolesSeeder())->run();
        $admin = User::factory()->create();
        $admin->assignRole('super_admin');

        $this->actingAs($admin)
            ->get('/admin')
            ->assertOk()
            ->assertSee('Udo Admin');

        Livewire::actingAs($admin);
        Livewire::test(\App\Filament\Widgets\OperationsHealthWidget::class)
            ->assertSuccessful()
            ->assertSee('Platform health')
            ->assertSee('Guest token risk')
            ->assertSee('Support load');
    }

    public function test_admin_role_boundaries_restrict_access_to_permitted_domains_only(): void
    {
        (new RolesSeeder())->run();

        $contentAdmin = User::factory()->create();
        $contentAdmin->assignRole('content_admin');
        $this->actingAs($contentAdmin)->get('/admin/blog-posts')->assertOk();
        $this->actingAs($contentAdmin)->get('/admin/email-templates')->assertOk();
        $this->actingAs($contentAdmin)->get('/admin/users')->assertForbidden();
        $this->actingAs($contentAdmin)->get('/admin/weddings')->assertForbidden();
        $this->actingAs($contentAdmin)->get('/admin/vendors')->assertForbidden();
        $this->actingAs($contentAdmin)->get('/admin/subscriptions')->assertForbidden();
        $this->actingAs($contentAdmin)->get('/admin/support-tickets')->assertForbidden();

        $financeAdmin = User::factory()->create();
        $financeAdmin->assignRole('finance_admin');
        $this->actingAs($financeAdmin)->get('/admin/subscriptions')->assertOk();
        $this->actingAs($financeAdmin)->get('/admin/support-tickets')->assertOk();
        $this->actingAs($financeAdmin)->get('/admin/users')->assertOk();
        $this->actingAs($financeAdmin)->get('/admin/vendors')->assertForbidden();
        $this->actingAs($financeAdmin)->get('/admin/blog-posts')->assertForbidden();

        $opsAdmin = User::factory()->create();
        $opsAdmin->assignRole('ops_admin');
        $this->actingAs($opsAdmin)->get('/admin/vendors')->assertOk();
        $this->actingAs($opsAdmin)->get('/admin/weddings')->assertOk();
        $this->actingAs($opsAdmin)->get('/admin/live-command-center')->assertOk();
        $this->actingAs($opsAdmin)->get('/admin/reliability-console')->assertOk();
        $this->actingAs($opsAdmin)->get('/admin/subscriptions')->assertForbidden();
        $this->actingAs($opsAdmin)->get('/admin/blog-posts')->assertForbidden();
        $this->actingAs($opsAdmin)->get('/admin/users')->assertForbidden();

        $superAdmin = User::factory()->create();
        $superAdmin->assignRole('super_admin');
        $this->actingAs($superAdmin)->get('/admin/users')->assertOk();
        $this->actingAs($superAdmin)->get('/admin/vendors')->assertOk();
        $this->actingAs($superAdmin)->get('/admin/subscriptions')->assertOk();
        $this->actingAs($superAdmin)->get('/admin/blog-posts')->assertOk();
        $this->actingAs($superAdmin)->get('/admin/support-tickets')->assertOk();
    }

    public function test_billing_plan_catalog_marks_current_plan_and_change_eligibility(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $wedding->guests()->create(['first_name' => 'Ava']);

        $this->getJson('/api/billing/plans')
            ->assertOk()
            ->assertJsonPath('data.0.plan', 'free')
            ->assertJsonPath('data.0.current', true)
            ->assertJsonPath('data.2.plan', 'pro')
            ->assertJsonPath('data.2.recommended', true)
            ->assertJsonPath('data.2.monthly_price', 79);
    }

    public function test_wedding_owner_can_change_plan_locally(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/plan', [
            'plan' => 'pro',
            'billing_cycle' => 'annual',
            'confirm' => true,
        ])
            ->assertOk()
            ->assertJsonPath('data.plan', 'pro')
            ->assertJsonPath('data.billing_cycle', 'annual')
            ->assertJsonPath('data.prices.annual', 790)
            ->assertJsonPath('message', 'Plan updated.');

        $this->assertDatabaseHas('subscriptions', [
            'user_id' => $owner->id,
            'plan' => 'pro',
            'status' => 'active',
            'billing_cycle' => 'annual',
            'amount' => 790,
            'currency' => 'USD',
        ]);
    }

    public function test_collaborator_cannot_change_wedding_plan(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $planner->id,
            'role' => 'planner',
            'permissions' => ['manage_wedding'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($planner);

        $this->postJson('/api/billing/plan', [
            'plan' => 'pro',
            'confirm' => true,
        ])->assertForbidden();
    }

    public function test_free_plan_guest_limit_blocks_additional_guests(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        for ($i = 0; $i < 50; $i++) {
            $wedding->guests()->create(['first_name' => "Guest {$i}"]);
        }

        $this->postJson('/api/guests', [
            'first_name' => 'Over',
        ])
            ->assertStatus(402)
            ->assertJsonPath('message', 'Your Free plan limit for guests has been reached.');
    }

    public function test_paid_plan_allows_more_guests_than_free_limit(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $owner->subscriptions()->create([
            'plan' => 'starter',
            'status' => 'active',
            'billing_cycle' => 'monthly',
        ]);

        for ($i = 0; $i < 50; $i++) {
            $wedding->guests()->create(['first_name' => "Guest {$i}"]);
        }

        $this->postJson('/api/guests', [
            'first_name' => 'Allowed',
        ])
            ->assertCreated()
            ->assertJsonPath('data.first_name', 'Allowed');
    }

    public function test_free_plan_team_limit_blocks_second_collaborator(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $existing = User::factory()->create(['email' => 'existing@example.test']);
        $newUser = User::factory()->create(['email' => 'new@example.test']);
        $wedding->collaborators()->create([
            'user_id' => $existing->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($owner);

        $this->postJson('/api/wedding/team', [
            'email' => $newUser->email,
            'role' => 'viewer',
        ])
            ->assertStatus(402)
            ->assertJsonPath('message', 'Your Free plan limit for team_members has been reached.');
    }

    public function test_guest_create_update_and_delete_are_audited(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $guestId = $this->postJson('/api/guests', [
            'first_name' => 'Ava',
            'email' => 'ava@example.test',
        ])
            ->assertCreated()
            ->json('data.id');

        $this->patchJson("/api/guests/{$guestId}", [
            'first_name' => 'Avery',
        ])->assertOk();

        $this->deleteJson("/api/guests/{$guestId}")
            ->assertNoContent();

        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $owner->id,
            'action' => 'guest.created',
            'auditable_id' => $guestId,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $owner->id,
            'action' => 'guest.updated',
            'auditable_id' => $guestId,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'user_id' => $owner->id,
            'action' => 'guest.deleted',
            'auditable_id' => $guestId,
        ]);
    }

    public function test_team_member_changes_are_audited(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create(['email' => 'planner@example.test']);
        Sanctum::actingAs($owner);

        $collaboratorId = $this->postJson('/api/wedding/team', [
            'email' => $planner->email,
            'role' => 'viewer',
        ])
            ->assertCreated()
            ->json('data.id');

        $this->patchJson("/api/wedding/team/{$collaboratorId}", [
            'role' => 'planner',
        ])->assertOk();

        $this->deleteJson("/api/wedding/team/{$collaboratorId}")
            ->assertNoContent();

        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'action' => 'team.member_added',
            'auditable_id' => $collaboratorId,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'action' => 'team.member_updated',
            'auditable_id' => $collaboratorId,
        ]);
        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'action' => 'team.member_removed',
            'auditable_id' => $collaboratorId,
        ]);
    }

    public function test_audit_log_index_requires_report_access(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create([
            'active_wedding_id' => $wedding->id,
        ]);
        $noReports = User::factory()->create([
            'active_wedding_id' => $wedding->id,
        ]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->collaborators()->create([
            'user_id' => $noReports->id,
            'role' => 'vendor',
            'permissions' => ['manage_plan'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->guests()->create(['first_name' => 'Ava']);
        $wedding->auditLogs()->create([
            'user_id' => $owner->id,
            'action' => 'guest.created',
        ]);

        Sanctum::actingAs($viewer);
        $this->getJson('/api/audit-logs')
            ->assertOk()
            ->assertJsonPath('data.0.action', 'guest.created');

        Sanctum::actingAs($noReports);
        $this->getJson('/api/audit-logs')
            ->assertForbidden();
    }

    public function test_guest_writes_require_manage_guests_permission(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $manager = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->collaborators()->create([
            'user_id' => $manager->id,
            'role' => 'day_of_coordinator',
            'permissions' => ['manage_guests'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);

        Sanctum::actingAs($viewer);
        $this->postJson('/api/guests', [
            'first_name' => 'Blocked',
        ])->assertForbidden();

        Sanctum::actingAs($manager);
        $this->postJson('/api/guests', [
            'first_name' => 'Allowed',
        ])
            ->assertCreated()
            ->assertJsonPath('data.first_name', 'Allowed');
    }

    public function test_messages_require_manage_messages_permission(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $messenger = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->collaborators()->create([
            'user_id' => $messenger->id,
            'role' => 'day_of_coordinator',
            'permissions' => ['manage_messages'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->messages()->create([
            'created_by' => $owner->id,
            'subject' => 'Existing',
            'body' => 'Already here.',
            'channel' => 'email',
            'status' => 'draft',
        ]);

        Sanctum::actingAs($viewer);
        $this->getJson('/api/messages')
            ->assertForbidden();

        Sanctum::actingAs($messenger);
        $this->getJson('/api/messages')
            ->assertOk()
            ->assertJsonPath('data.0.subject', 'Existing');
    }

    public function test_budget_requires_manage_budget_permission(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $finance = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $planner->id,
            'role' => 'day_of_coordinator',
            'permissions' => ['manage_plan'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->collaborators()->create([
            'user_id' => $finance->id,
            'role' => 'finance',
            'permissions' => ['manage_budget'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);

        Sanctum::actingAs($planner);
        $this->getJson('/api/plan/budget')
            ->assertForbidden();

        Sanctum::actingAs($finance);
        $this->getJson('/api/plan/budget')
            ->assertOk();
    }

    public function test_plan_writes_require_manage_plan_permission(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $planner = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        $wedding->collaborators()->create([
            'user_id' => $planner->id,
            'role' => 'day_of_coordinator',
            'permissions' => ['manage_plan'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);

        Sanctum::actingAs($viewer);
        $this->postJson('/api/plan/tasks', [
            'title' => 'Blocked task',
        ])->assertForbidden();

        Sanctum::actingAs($planner);
        $this->postJson('/api/plan/tasks', [
            'title' => 'Allowed task',
        ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Allowed task');
    }

    private function userWithWedding(): array
    {
        $user = User::factory()->create();
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => $user->id,
        ]);
        $user->update(['active_wedding_id' => $wedding->id]);

        return [$user->fresh(), $wedding];
    }
}
