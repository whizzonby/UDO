<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\EmailVerificationController;
use App\Http\Controllers\Auth\MobileSocialAuthController;
use App\Http\Controllers\Auth\SocialAuthController;
use App\Http\Controllers\Auth\PasswordResetController;
use App\Http\Controllers\AiAssistantController;
use App\Http\Controllers\ApprovalController;
use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\BillingController;
use App\Http\Controllers\CheckoutController;
use App\Http\Controllers\ContentPageController;
use App\Http\Controllers\GuestController;
use App\Http\Controllers\IapController;
use App\Http\Controllers\MoodController;
use App\Http\Controllers\GuestExperienceController;
use App\Http\Controllers\GuestPortalController;
use App\Http\Controllers\GalleryController;
use App\Http\Controllers\GalleryAlbumController;
use App\Http\Controllers\GalleryUploadController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\InvitationController;
use App\Http\Controllers\InvitationCampaignController;
use App\Http\Controllers\InternalOpsController;
use App\Http\Controllers\LiveController;
use App\Http\Controllers\LogisticsController;
use App\Http\Controllers\MessagesController;
use App\Http\Controllers\OnboardingController;
use App\Http\Controllers\OperationalHealthController;
use App\Http\Controllers\PinterestController;
use App\Http\Controllers\PlaceSearchController;
use App\Http\Controllers\RegistryController;
use App\Http\Controllers\ReleaseNoteController;
use App\Http\Controllers\SeatingController;
use App\Http\Controllers\SavedFilterController;
use App\Http\Controllers\SmartAlertController;
use App\Http\Controllers\SupportTicketController;
use App\Http\Controllers\VenueController;
use App\Http\Controllers\WeatherController;
use App\Http\Controllers\WeddingTeamController;
use App\Http\Controllers\WeddingController;
use App\Http\Controllers\WeddingStoryController;
use App\Http\Controllers\Plan\BudgetController;
use App\Http\Controllers\Plan\FoodController;
use App\Http\Controllers\Plan\FoodServiceItemController;
use App\Http\Controllers\Plan\HoneymoonController;
use App\Http\Controllers\Plan\HoneymoonItemController;
use App\Http\Controllers\Plan\HoneymoonTravelerController;
use App\Http\Controllers\Plan\InsuranceController;
use App\Http\Controllers\Plan\InsuranceDocumentController;
use App\Http\Controllers\Plan\WeddingDocumentController;
use App\Http\Controllers\Plan\MemoryGuestbookController;
use App\Http\Controllers\Plan\MemoryGuestbookEntryController;
use App\Http\Controllers\Plan\MemoryMusicController;
use App\Http\Controllers\Plan\MemoryPhotoBoothController;
use App\Http\Controllers\Plan\MemorySpeechController;
use App\Http\Controllers\Plan\MemoryTraditionController;
use App\Http\Controllers\Plan\MemoryVowController;
use App\Http\Controllers\Plan\RecipeSearchController;
use App\Http\Controllers\Plan\RehearsalController;
use App\Http\Controllers\Plan\ReminderController;
use App\Http\Controllers\Plan\TaskController;
use App\Http\Controllers\Plan\TimelineController;
use App\Http\Controllers\Plan\VendorController;
use App\Http\Controllers\Plan\WeddingWeekendController;
use App\Http\Controllers\WeddingParty\EmergencyContactController;
use App\Http\Controllers\WeddingParty\FileController as WeddingPartyFileController;
use App\Http\Controllers\WeddingParty\ResponsibilityController;
use App\Http\Controllers\Webhooks\TwilioMessageStatusController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public auth routes
|--------------------------------------------------------------------------
*/
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register'])->middleware('throttle:6,1');
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:10,1');
    Route::post('forgot-password', [PasswordResetController::class, 'sendLink'])->middleware('throttle:5,1');
    Route::post('reset-password', [PasswordResetController::class, 'reset'])->middleware('throttle:10,1');
    Route::post('two-factor/verify', [AuthController::class, 'twoFactorVerify'])->middleware('throttle:10,1');
    Route::post('two-factor/resend', [AuthController::class, 'twoFactorResend'])->middleware('throttle:3,1');
    // Web OAuth redirect flow (for Next.js)
    Route::get('{provider}/redirect', [SocialAuthController::class, 'redirect']);
    Route::get('{provider}/callback', [SocialAuthController::class, 'callback']);
    // Mobile token exchange (Flutter passes native SDK token)
    Route::post('mobile/google', [MobileSocialAuthController::class, 'google'])->middleware('throttle:10,1');
    Route::post('mobile/apple', [MobileSocialAuthController::class, 'apple'])->middleware('throttle:10,1');
    // Signed link from the verification email — no Sanctum guard, the signature is the proof.
    Route::get('email/verify/{id}/{hash}', [EmailVerificationController::class, 'verify'])
        ->middleware('signed')
        ->name('verification.verify');
});

/*
|--------------------------------------------------------------------------
| Guest portal (token-based, no Sanctum)
|--------------------------------------------------------------------------
*/
Route::prefix('g')->group(function () {
    Route::get('{token}', [GuestPortalController::class, 'show'])->middleware('throttle:120,1');
    Route::post('{token}/rsvp', [GuestPortalController::class, 'rsvp'])->middleware('throttle:20,1');
    Route::patch('{token}/preferences', [GuestPortalController::class, 'updatePreferences'])->middleware('throttle:20,1');
    Route::post('{token}/gallery', [GuestPortalController::class, 'uploadPhoto'])->middleware('throttle:10,1');
    Route::post('{token}/guestbook', [GuestPortalController::class, 'submitGuestbookMessage'])->middleware('throttle:10,1');
    Route::post('{token}/registry/{registryItem}/contribute', [GuestPortalController::class, 'contributeRegistry'])->middleware('throttle:10,1');
});

Route::prefix('w')->group(function () {
    Route::get('{slug}', [GuestPortalController::class, 'wedding'])->middleware('throttle:120,1');
});

// Wedding-wide QR upload link — not tied to any one guest's invite token.
Route::prefix('upload')->group(function () {
    Route::get('{token}', [GalleryUploadController::class, 'show'])->middleware('throttle:120,1');
    Route::post('{token}/gallery', [GalleryUploadController::class, 'store'])->middleware('throttle:10,1');
});

Route::post('webhooks/twilio/messages', TwilioMessageStatusController::class)
    ->name('twilio.messages.status')
    ->middleware('throttle:120,1');

// Stripe's webhook carries no app session and must verify by signature only.
Route::post('webhooks/stripe', [CheckoutController::class, 'webhook'])->middleware('throttle:120,1');

// Pinterest redirects the user's browser here with no app session — must
// stay outside the authenticated group; the wedding is resolved from the
// signed `state` value generated by the authenticated connect() call.
Route::get('pinterest/callback', [PinterestController::class, 'callback'])->middleware('throttle:30,1');

/*
|--------------------------------------------------------------------------
| Authenticated routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth:sanctum', 'idempotency'])->group(function () {

    // Auth utilities
    Route::get('auth/me', [AuthController::class, 'me']);
    Route::patch('auth/me', [AuthController::class, 'update']);
    Route::patch('auth/preferences', [AuthController::class, 'updatePreferences']);
    Route::post('auth/change-password', [AuthController::class, 'changePassword']);
    Route::post('auth/two-factor/enable', [AuthController::class, 'twoFactorEnable']);
    Route::post('auth/two-factor/disable', [AuthController::class, 'twoFactorDisable']);
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::post('auth/logout-all', [AuthController::class, 'logoutAll']);
    Route::get('auth/privacy/export', [AuthController::class, 'privacyExport']);
    Route::delete('auth/me', [AuthController::class, 'destroy']);
    Route::post('auth/email/resend', [EmailVerificationController::class, 'resend'])->middleware('throttle:6,1');

    // Onboarding
    Route::post('onboarding', [OnboardingController::class, 'store']);

    // About / static content
    Route::get('content-pages/{slug}', [ContentPageController::class, 'show']);
    Route::get('release-notes', [ReleaseNoteController::class, 'index']);

    // Dashboard
    Route::get('dashboard', [HomeController::class, 'index']);
    Route::get('reliability/health', [OperationalHealthController::class, 'show']);
    Route::get('weather/debug', [WeatherController::class, 'debug']);
    Route::get('internal/ops', [InternalOpsController::class, 'index']);
    Route::patch('internal/ops/users/{user}/entitlement', [InternalOpsController::class, 'overrideEntitlement']);
    Route::get('smart-alerts', [SmartAlertController::class, 'index']);
    Route::post('smart-alerts/refresh', [SmartAlertController::class, 'refresh']);
    Route::post('smart-alerts/{smartAlert}/resolve', [SmartAlertController::class, 'resolve']);
    Route::get('approvals', [ApprovalController::class, 'index']);
    Route::post('approvals/{approvalRequest}/vote', [ApprovalController::class, 'vote']);
    Route::apiResource('saved-filters', SavedFilterController::class)->only(['index', 'store', 'update', 'destroy']);
    Route::get('billing/entitlements', [BillingController::class, 'entitlements']);
    Route::get('billing/plans', [BillingController::class, 'plans']);
    Route::post('billing/plan', [BillingController::class, 'changePlan']);
    Route::post('billing/checkout-session', [CheckoutController::class, 'store']);
    Route::get('billing/checkout-session/{sessionId}', [CheckoutController::class, 'show']);
    Route::post('billing/verify-purchase', [IapController::class, 'verifyPurchase']);
    Route::post('mood-checkins', [MoodController::class, 'store']);
    Route::get('mood-checkins/insights', [MoodController::class, 'insights']);
    Route::get('audit-logs', [AuditLogController::class, 'index']);
    Route::get('support-tickets', [SupportTicketController::class, 'index']);
    Route::post('support-tickets', [SupportTicketController::class, 'store']);

    // Wedding settings
    Route::get('weddings', [WeddingController::class, 'index']);
    Route::post('weddings', [WeddingController::class, 'store']);
    Route::post('weddings/switch', [WeddingController::class, 'switchActive']);
    Route::prefix('wedding')->group(function () {
        Route::get('/', [WeddingController::class, 'show']);
        Route::patch('/', [WeddingController::class, 'update']);
        Route::post('cover-photo', [WeddingController::class, 'uploadCoverPhoto']);
        Route::get('team', [WeddingTeamController::class, 'index']);
        Route::post('team', [WeddingTeamController::class, 'store']);
        Route::patch('team/{collaborator}', [WeddingTeamController::class, 'update']);
        Route::delete('team/{collaborator}', [WeddingTeamController::class, 'destroy']);
    });

    // AI Wedding Assistant
    Route::get('ai-assistant', [AiAssistantController::class, 'index']);
    Route::get('ai-assistant/health', [AiAssistantController::class, 'health']);
    Route::post('ai-assistant/chat', [AiAssistantController::class, 'chat']);

    // Guests
    Route::get('guests/export', [GuestController::class, 'export']);
    Route::get('guests/activity', [GuestController::class, 'activity']);
    Route::post('guests/bulk-update', [GuestController::class, 'bulkUpdate']);
    Route::apiResource('guests', GuestController::class);
    Route::get('guests/{guest}/activity', [GuestController::class, 'guestActivity']);
    Route::post('guests/{guest}/invite', [GuestController::class, 'sendInvite']);
    Route::post('guests/bulk-import', [GuestController::class, 'bulkImport']);
    Route::post('guests/{guest}/token', [GuestController::class, 'generateToken']);

    // Plan
    Route::prefix('plan')->group(function () {
        Route::get('tasks/export', [TaskController::class, 'export']);
        Route::post('tasks/bulk-update', [TaskController::class, 'bulkUpdate']);
        Route::apiResource('tasks', TaskController::class);
        Route::get('vendors/export', [VendorController::class, 'export']);
        Route::get('vendors/summary', [VendorController::class, 'summary']);
        Route::get('vendors/day-of-contact-sheet', [VendorController::class, 'dayOfContactSheet']);
        Route::get('vendors/{vendor}/contact-logs', [VendorController::class, 'contactLogs']);
        Route::post('vendors/{vendor}/contact-logs', [VendorController::class, 'storeContactLog']);
        Route::post('vendors/bulk-update', [VendorController::class, 'bulkUpdate']);
        Route::apiResource('vendors', VendorController::class);
        Route::get('budget/summary', [BudgetController::class, 'summary']);
        Route::post('budget/{budgetItem}/payment-schedules', [BudgetController::class, 'storePaymentSchedule']);
        Route::patch('budget/payment-schedules/{budgetPaymentSchedule}', [BudgetController::class, 'updatePaymentSchedule']);
        Route::post('budget/payment-schedules/{budgetPaymentSchedule}/mark-paid', [BudgetController::class, 'markPaymentPaid']);
        Route::apiResource('budget', BudgetController::class)->parameters(['budget' => 'budgetItem']);
        Route::apiResource('timeline', TimelineController::class)->parameters(['timeline' => 'timelineItem']);

        Route::post('reminders/refresh', [ReminderController::class, 'refresh']);
        Route::apiResource('reminders', ReminderController::class)->only(['index', 'store', 'update', 'destroy']);
        Route::apiResource('insurance', InsuranceController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['insurance' => 'insurancePolicy']);
        Route::apiResource('insurance/documents', InsuranceDocumentController::class)->only(['index', 'store', 'destroy'])->parameters(['documents' => 'insuranceDocument']);
        Route::apiResource('documents', WeddingDocumentController::class)->only(['index', 'store', 'destroy'])->parameters(['documents' => 'weddingDocument']);
        Route::apiResource('wedding-weekend', WeddingWeekendController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['wedding-weekend' => 'weddingWeekendEvent']);
        Route::apiResource('rehearsals', RehearsalController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['rehearsals' => 'rehearsal']);
        Route::get('food', [FoodController::class, 'index']);
        Route::post('food/courses', [FoodController::class, 'storeCourse']);
        Route::patch('food/courses/{menuCourse}', [FoodController::class, 'updateCourse']);
        Route::delete('food/courses/{menuCourse}', [FoodController::class, 'destroyCourse']);
        Route::post('food/courses/{menuCourse}/options', [FoodController::class, 'storeOption']);
        Route::patch('food/options/{menuCourseOption}', [FoodController::class, 'updateOption']);
        Route::delete('food/options/{menuCourseOption}', [FoodController::class, 'destroyOption']);
        Route::post('food/options/{menuCourseOption}/select', [FoodController::class, 'selectForGuest']);
        Route::delete('food/guests/{guest}/courses/{menuCourse}', [FoodController::class, 'removeSelection']);
        Route::apiResource('food-service-items', FoodServiceItemController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['food-service-items' => 'foodServiceItem']);
        Route::get('food/recipe-search', [RecipeSearchController::class, 'search']);
        Route::get('food/recipes/{recipeId}', [RecipeSearchController::class, 'show']);
        Route::get('honeymoon', [HoneymoonController::class, 'show']);
        Route::patch('honeymoon', [HoneymoonController::class, 'update']);
        Route::post('honeymoon/cover-photo', [HoneymoonController::class, 'uploadCoverPhoto']);
        Route::apiResource('honeymoon/items', HoneymoonItemController::class)->only(['store', 'update', 'destroy'])->parameters(['items' => 'honeymoonItem']);
        Route::apiResource('honeymoon/travelers', HoneymoonTravelerController::class)->only(['store', 'update', 'destroy'])->parameters(['travelers' => 'honeymoonTraveler']);

        Route::apiResource('memories/speeches', MemorySpeechController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['speeches' => 'memorySpeech']);
        Route::apiResource('memories/vows', MemoryVowController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['vows' => 'memoryVow']);
        Route::post('memories/vows/{memoryVow}/mark-viewed', [MemoryVowController::class, 'markViewed']);
        Route::apiResource('memories/traditions', MemoryTraditionController::class)->only(['index', 'store', 'update', 'destroy'])->parameters(['traditions' => 'memoryTradition']);
        Route::get('memories/guestbook', [MemoryGuestbookController::class, 'show']);
        Route::patch('memories/guestbook', [MemoryGuestbookController::class, 'update']);
        Route::apiResource('memories/guestbook/entries', MemoryGuestbookEntryController::class)->only(['update', 'destroy'])->parameters(['entries' => 'entry']);
        Route::get('memories/photo-booth', [MemoryPhotoBoothController::class, 'show']);
        Route::patch('memories/photo-booth', [MemoryPhotoBoothController::class, 'update']);
        Route::get('memories/music', [MemoryMusicController::class, 'show']);
        Route::patch('memories/music', [MemoryMusicController::class, 'update']);
    });

    // Invitation studio
    Route::prefix('invitation')->group(function () {
        Route::get('/', [InvitationController::class, 'show']);
        Route::post('/', [InvitationController::class, 'store']);
        Route::patch('/', [InvitationController::class, 'update']);
        Route::post('publish', [InvitationController::class, 'publish']);
        Route::post('import', [InvitationController::class, 'importAsset']);
        Route::delete('import', [InvitationController::class, 'removeImportedAsset']);
        Route::get('campaigns', [InvitationCampaignController::class, 'index']);
        Route::post('campaigns', [InvitationCampaignController::class, 'store']);
        Route::post('campaigns/preview', [InvitationCampaignController::class, 'preview']);
        Route::get('campaigns/{campaign}', [InvitationCampaignController::class, 'show']);
        Route::patch('campaigns/{campaign}', [InvitationCampaignController::class, 'update']);
        Route::get('campaigns/{campaign}/preview', [InvitationCampaignController::class, 'preview']);
        Route::post('campaigns/{campaign}/send', [InvitationCampaignController::class, 'send']);
        Route::get('campaigns/{campaign}/guest-links', [InvitationCampaignController::class, 'guestLinks']);
    });

    // Live feed
    Route::get('live/today', [LiveController::class, 'today']);
    Route::get('live', [LiveController::class, 'index']);
    Route::post('live', [LiveController::class, 'store']);
    Route::patch('live/{liveUpdate}', [LiveController::class, 'update']);
    Route::post('live/{liveUpdate}/resolve', [LiveController::class, 'resolve']);
    Route::delete('live/{liveUpdate}', [LiveController::class, 'destroy']);

    // Venue & weather
    Route::get('venue/location', [VenueController::class, 'location']);
    Route::get('weather', [WeatherController::class, 'show']);

    // Gallery
    Route::get('gallery/summary', [GalleryController::class, 'summary']);
    Route::get('pinterest/status', [PinterestController::class, 'status']);
    Route::get('pinterest/connect', [PinterestController::class, 'connect']);
    Route::get('pinterest/boards', [PinterestController::class, 'boards']);
    Route::post('pinterest/boards/{boardId}/import', [PinterestController::class, 'importBoard']);
    Route::post('pinterest/disconnect', [PinterestController::class, 'disconnect']);
    Route::get('wedding-story', [WeddingStoryController::class, 'show']);
    Route::get('gallery/upload-link', [GalleryController::class, 'uploadLink']);
    Route::apiResource('gallery/albums', GalleryAlbumController::class)->only(['index', 'store', 'update', 'destroy']);
    Route::get('gallery', [GalleryController::class, 'index']);
    Route::post('gallery', [GalleryController::class, 'store']);
    Route::get('gallery/{galleryAsset}', [GalleryController::class, 'show']);
    Route::patch('gallery/{galleryAsset}', [GalleryController::class, 'update']);
    Route::post('gallery/{galleryAsset}/approve', [GalleryController::class, 'approve']);
    Route::post('gallery/{galleryAsset}/reject', [GalleryController::class, 'reject']);
    Route::post('gallery/{galleryAsset}/feature', [GalleryController::class, 'feature']);
    Route::post('gallery/{galleryAsset}/archive', [GalleryController::class, 'archive']);
    Route::delete('gallery/{galleryAsset}', [GalleryController::class, 'destroy']);

    // Registry
    Route::get('registry/summary', [RegistryController::class, 'summary']);
    Route::get('registry/thank-yous', [RegistryController::class, 'thankYous']);
    Route::apiResource('registry', RegistryController::class)->parameters(['registry' => 'registryItem']);
    Route::get('registry/{registryItem}/contributions', [RegistryController::class, 'contributions']);
    Route::post('registry/{registryItem}/contributions', [RegistryController::class, 'contribute']);
    Route::post('registry/contributions/{contribution}/thank-you', [RegistryController::class, 'markThanked']);

    // Messages
    Route::get('messages/{message}/delivery-summary', [MessagesController::class, 'deliverySummary']);
    Route::apiResource('messages', MessagesController::class);
    Route::post('messages/{message}/send', [MessagesController::class, 'send']);
    Route::post('messages/{message}/retry-failed', [MessagesController::class, 'retryFailed']);

    // Seating
    Route::get('seating', [SeatingController::class, 'index']);
    Route::get('seating/summary', [SeatingController::class, 'summary']);
    Route::get('seating/pairings', [SeatingController::class, 'pairings']);
    Route::post('seating/pairings', [SeatingController::class, 'storePairing']);
    Route::delete('seating/pairings/{guestPairing}', [SeatingController::class, 'destroyPairing']);
    Route::post('seating/auto-assign', [SeatingController::class, 'autoAssign']);
    Route::post('seating/tables', [SeatingController::class, 'storeTable']);
    Route::patch('seating/tables/{seatingTable}', [SeatingController::class, 'updateTable']);
    Route::delete('seating/tables/{seatingTable}', [SeatingController::class, 'destroyTable']);
    Route::post('seating/tables/{seatingTable}/assign', [SeatingController::class, 'assignSeat']);
    Route::delete('seating/tables/{seatingTable}/seats/{seatingSeat}', [SeatingController::class, 'clearSeat']);

    // Places (Google Places Autocomplete — hotel/lodging name search)
    Route::get('places/search', [PlaceSearchController::class, 'search']);
    Route::get('places/{placeId}', [PlaceSearchController::class, 'show']);

    // Logistics
    Route::get('logistics/summary', [LogisticsController::class, 'summary']);
    Route::get('logistics/accommodation', [LogisticsController::class, 'accommodations']);
    Route::post('logistics/accommodation', [LogisticsController::class, 'storeAccommodation']);
    Route::patch('logistics/accommodation/{accommodationOption}', [LogisticsController::class, 'updateAccommodation']);
    Route::delete('logistics/accommodation/{accommodationOption}', [LogisticsController::class, 'destroyAccommodation']);
    Route::post('logistics/accommodation/{accommodationOption}/assign', [LogisticsController::class, 'assignAccommodation']);
    Route::delete('logistics/accommodation/{accommodationOption}/guests/{guestId}', [LogisticsController::class, 'removeAccommodation']);
    Route::get('logistics/transport', [LogisticsController::class, 'transportGroups']);
    Route::post('logistics/transport', [LogisticsController::class, 'storeTransportGroup']);
    Route::patch('logistics/transport/{transportGroup}', [LogisticsController::class, 'updateTransportGroup']);
    Route::delete('logistics/transport/{transportGroup}', [LogisticsController::class, 'destroyTransportGroup']);
    Route::post('logistics/transport/{transportGroup}/assign', [LogisticsController::class, 'assignTransport']);
    Route::delete('logistics/transport/{transportGroup}/guests/{guestId}', [LogisticsController::class, 'removeTransport']);

    // Wedding party
    Route::prefix('wedding-party')->group(function () {
        Route::get('responsibilities', [ResponsibilityController::class, 'index']);
        Route::post('responsibilities', [ResponsibilityController::class, 'store']);
        Route::post('responsibilities/bulk-update', [ResponsibilityController::class, 'bulkUpdate']);
        Route::patch('responsibilities/{responsibility}', [ResponsibilityController::class, 'update']);
        Route::delete('responsibilities/{responsibility}', [ResponsibilityController::class, 'destroy']);

        Route::get('emergency-contacts', [EmergencyContactController::class, 'index']);
        Route::post('emergency-contacts', [EmergencyContactController::class, 'store']);
        Route::patch('emergency-contacts/{emergencyContact}', [EmergencyContactController::class, 'update']);
        Route::delete('emergency-contacts/{emergencyContact}', [EmergencyContactController::class, 'destroy']);
        Route::post('emergency-contacts/broadcast', [EmergencyContactController::class, 'broadcast']);

        Route::get('files', [WeddingPartyFileController::class, 'index']);
        Route::post('files', [WeddingPartyFileController::class, 'store']);
        Route::delete('files/{file}', [WeddingPartyFileController::class, 'destroy']);
    });

    // Guest portal builder
    Route::get('experience', [GuestExperienceController::class, 'show']);
    Route::patch('experience', [GuestExperienceController::class, 'update']);
    Route::get('experience/preview', [GuestExperienceController::class, 'preview']);
});
