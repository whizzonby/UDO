<?php

use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\LogoutController;
use App\Http\Controllers\Api\Auth\MeController;
use App\Http\Controllers\Api\Auth\RegisterController;
use App\Http\Controllers\Api\Auth\SocialAuthController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\OnboardingController;
use App\Http\Controllers\Api\Guests\GuestController;
use App\Http\Controllers\Api\Experience\ExperienceController;
use App\Http\Controllers\Api\Live\LiveController;
use App\Http\Controllers\Api\Gallery\GalleryController;
use App\Http\Controllers\Api\Guest\GuestPortalController;
use App\Http\Controllers\Api\Registry\RegistryController;
use App\Http\Controllers\Api\Messages\MessagesController;
use App\Http\Controllers\Api\Plan\BudgetController;
use App\Http\Controllers\Api\Plan\SeatingController;
use App\Http\Controllers\Api\Plan\TaskController;
use App\Http\Controllers\Api\Plan\TimelineController;
use App\Http\Controllers\Api\Plan\VendorController;
use App\Http\Controllers\Api\Stripe\StripeWebhookController;
use Illuminate\Support\Facades\Route;

// ── Stripe webhook (public — verified via Stripe-Signature header) ────────────
Route::post('/stripe/webhook', [StripeWebhookController::class, 'handle']);

// ── Guest Portal (public — token-based, no auth) ──────────────────────────────
Route::prefix('guest-portal/{token}')->group(function () {
    Route::get('/',                   [GuestPortalController::class, 'show']);
    Route::post('/rsvp',              [GuestPortalController::class, 'rsvp']);
    Route::get('/schedule',           [GuestPortalController::class, 'schedule']);
    Route::get('/registry',           [GuestPortalController::class, 'registry']);
    Route::get('/gallery',            [GuestPortalController::class, 'gallery']);
    Route::post('/gallery',           [GuestPortalController::class, 'uploadPhoto']);
    Route::get('/messages',           [GuestPortalController::class, 'messages']);
    Route::post('/fund/contribute',   [GuestPortalController::class, 'contribute']);
});

// ── Auth (public) ─────────────────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/register',       RegisterController::class);
    Route::post('/login',          LoginController::class);
    Route::post('/social/google',  [SocialAuthController::class, 'google']);
    Route::post('/social/apple',   [SocialAuthController::class, 'apple']);
});

// ── Authenticated ─────────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/auth/logout', LogoutController::class);
    Route::get('/auth/me',      MeController::class);

    // Onboarding — create wedding + store preferences
    Route::get('/onboarding',  [OnboardingController::class, 'show']);
    Route::post('/onboarding', [OnboardingController::class, 'store']);

    // Home — aggregated dashboard stats
    Route::get('/home', HomeController::class);

    // Guests — named routes before wildcard to avoid capture of 'overview' etc.
    Route::prefix('guests')->group(function () {
        Route::get('/overview',                  [GuestController::class, 'overview']);
        Route::post('/bulk-invite',              [GuestController::class, 'bulkInvite']);
        Route::get('/',                          [GuestController::class, 'index']);
        Route::post('/',                         [GuestController::class, 'store']);
        Route::get('/{guest}',                   [GuestController::class, 'show']);
        Route::put('/{guest}',                   [GuestController::class, 'update']);
        Route::patch('/{guest}',                 [GuestController::class, 'update']);
        Route::delete('/{guest}',                [GuestController::class, 'destroy']);
        Route::post('/{guest}/check-in',         [GuestController::class, 'checkIn']);
        Route::post('/{guest}/mark-invited',     [GuestController::class, 'markInvited']);
        Route::post('/{guest}/regenerate-token', [GuestController::class, 'regenerateToken']);
    });

    // Registry
    Route::prefix('registry')->group(function () {
        Route::get('/',                        [RegistryController::class, 'index']);
        Route::get('/fund',                    [RegistryController::class, 'getFund']);
        Route::put('/fund',                    [RegistryController::class, 'updateFund']);
        Route::post('/items',                  [RegistryController::class, 'store']);
        Route::put('/items/{item}',            [RegistryController::class, 'update']);
        Route::delete('/items/{item}',         [RegistryController::class, 'destroy']);
        Route::patch('/items/{item}/claim',    [RegistryController::class, 'claim']);
        Route::patch('/items/{item}/unclaim',  [RegistryController::class, 'unclaim']);
        Route::patch('/items/{item}/thank',    [RegistryController::class, 'markThanked']);
    });

    // Live — day-of coordination
    Route::prefix('live')->group(function () {
        Route::get('/status',       [LiveController::class, 'status']);
        Route::get('/activity',     [LiveController::class, 'activity']);
        Route::post('/activate',    [LiveController::class, 'activate']);
        Route::post('/deactivate',  [LiveController::class, 'deactivate']);
    });

    // Guest messages (broadcast)
    Route::prefix('messages')->group(function () {
        Route::get('/',           [MessagesController::class, 'index']);
        Route::post('/',          [MessagesController::class, 'store']);
        Route::delete('/{message}', [MessagesController::class, 'destroy']);
    });

    // Guest Experience config
    Route::prefix('experience')->group(function () {
        Route::get('/',  [ExperienceController::class, 'show']);
        Route::put('/',  [ExperienceController::class, 'update']);
    });

    // Gallery
    Route::prefix('gallery')->group(function () {
        Route::get('/',                     [GalleryController::class, 'index']);
        Route::post('/',                    [GalleryController::class, 'store']);
        Route::post('/reorder',             [GalleryController::class, 'reorder']);
        Route::put('/{item}',              [GalleryController::class, 'update']);
        Route::delete('/{item}',           [GalleryController::class, 'destroy']);
        Route::patch('/{item}/feature',    [GalleryController::class, 'feature']);
    });

    // Plan
    Route::prefix('plan')->group(function () {
        Route::apiResource('tasks',    TaskController::class)->except(['show']);
        Route::apiResource('timeline', TimelineController::class)->except(['show']);
        Route::apiResource('vendors',  VendorController::class)->except(['show']);
        Route::apiResource('budget',   BudgetController::class)
            ->parameters(['budget' => 'budgetItem'])
            ->except(['show']);

        // Seating plan
        Route::prefix('seating')->group(function () {
            Route::get('/',                             [SeatingController::class, 'index']);
            Route::post('/tables',                      [SeatingController::class, 'store']);
            Route::put('/tables/{table}',               [SeatingController::class, 'update']);
            Route::delete('/tables/{table}',            [SeatingController::class, 'destroy']);
            Route::post('/tables/{table}/assign',       [SeatingController::class, 'assign']);
            Route::delete('/tables/{table}/guests/{guest}', [SeatingController::class, 'unassign']);
        });
    });
});
