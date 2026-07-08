<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\EmailVerificationController;
use App\Http\Controllers\Auth\MobileSocialAuthController;
use App\Http\Controllers\Auth\SocialAuthController;
use App\Http\Controllers\Auth\PasswordResetController;
use App\Http\Controllers\GuestController;
use App\Http\Controllers\GuestExperienceController;
use App\Http\Controllers\GuestPortalController;
use App\Http\Controllers\GalleryController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\InvitationController;
use App\Http\Controllers\LiveController;
use App\Http\Controllers\LogisticsController;
use App\Http\Controllers\MessagesController;
use App\Http\Controllers\OnboardingController;
use App\Http\Controllers\RegistryController;
use App\Http\Controllers\SeatingController;
use App\Http\Controllers\WeddingController;
use App\Http\Controllers\Plan\BudgetController;
use App\Http\Controllers\Plan\TaskController;
use App\Http\Controllers\Plan\TimelineController;
use App\Http\Controllers\Plan\VendorController;
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
    Route::get('{token}', [GuestPortalController::class, 'show']);
    Route::post('{token}/rsvp', [GuestPortalController::class, 'rsvp']);
    Route::post('{token}/gallery', [GuestPortalController::class, 'uploadPhoto']);
});

/*
|--------------------------------------------------------------------------
| Authenticated routes
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // Auth utilities
    Route::get('auth/me', [AuthController::class, 'me']);
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::post('auth/email/resend', [EmailVerificationController::class, 'resend'])->middleware('throttle:6,1');

    // Onboarding
    Route::post('onboarding', [OnboardingController::class, 'store']);

    // Dashboard
    Route::get('dashboard', [HomeController::class, 'index']);

    // Wedding settings
    Route::prefix('wedding')->group(function () {
        Route::get('/', [WeddingController::class, 'show']);
        Route::patch('/', [WeddingController::class, 'update']);
    });

    // Guests
    Route::apiResource('guests', GuestController::class);
    Route::post('guests/{guest}/invite', [GuestController::class, 'sendInvite']);
    Route::post('guests/bulk-import', [GuestController::class, 'bulkImport']);
    Route::post('guests/{guest}/token', [GuestController::class, 'generateToken']);

    // Plan
    Route::prefix('plan')->group(function () {
        Route::apiResource('tasks', TaskController::class);
        Route::apiResource('vendors', VendorController::class);
        Route::apiResource('budget', BudgetController::class)->parameters(['budget' => 'budgetItem']);
        Route::apiResource('timeline', TimelineController::class)->parameters(['timeline' => 'timelineItem']);
    });

    // Invitation studio
    Route::prefix('invitation')->group(function () {
        Route::get('/', [InvitationController::class, 'show']);
        Route::post('/', [InvitationController::class, 'store']);
        Route::patch('/', [InvitationController::class, 'update']);
        Route::post('publish', [InvitationController::class, 'publish']);
    });

    // Live feed
    Route::get('live', [LiveController::class, 'index']);
    Route::post('live', [LiveController::class, 'store']);
    Route::patch('live/{liveUpdate}', [LiveController::class, 'update']);
    Route::delete('live/{liveUpdate}', [LiveController::class, 'destroy']);

    // Gallery
    Route::get('gallery', [GalleryController::class, 'index']);
    Route::post('gallery', [GalleryController::class, 'store']);
    Route::get('gallery/{galleryAsset}', [GalleryController::class, 'show']);
    Route::patch('gallery/{galleryAsset}', [GalleryController::class, 'update']);
    Route::delete('gallery/{galleryAsset}', [GalleryController::class, 'destroy']);

    // Registry
    Route::apiResource('registry', RegistryController::class)->parameters(['registry' => 'registryItem']);
    Route::get('registry/{registryItem}/contributions', [RegistryController::class, 'contributions']);

    // Messages
    Route::apiResource('messages', MessagesController::class);
    Route::post('messages/{message}/send', [MessagesController::class, 'send']);

    // Seating
    Route::get('seating', [SeatingController::class, 'index']);
    Route::post('seating/tables', [SeatingController::class, 'storeTable']);
    Route::patch('seating/tables/{seatingTable}', [SeatingController::class, 'updateTable']);
    Route::delete('seating/tables/{seatingTable}', [SeatingController::class, 'destroyTable']);
    Route::post('seating/tables/{seatingTable}/assign', [SeatingController::class, 'assignSeat']);
    Route::delete('seating/tables/{seatingTable}/seats/{seatingSeat}', [SeatingController::class, 'clearSeat']);

    // Logistics
    Route::get('logistics/accommodation', [LogisticsController::class, 'accommodations']);
    Route::post('logistics/accommodation', [LogisticsController::class, 'storeAccommodation']);
    Route::patch('logistics/accommodation/{accommodationOption}', [LogisticsController::class, 'updateAccommodation']);
    Route::delete('logistics/accommodation/{accommodationOption}', [LogisticsController::class, 'destroyAccommodation']);
    Route::get('logistics/transport', [LogisticsController::class, 'transportGroups']);
    Route::post('logistics/transport', [LogisticsController::class, 'storeTransportGroup']);
    Route::patch('logistics/transport/{transportGroup}', [LogisticsController::class, 'updateTransportGroup']);
    Route::delete('logistics/transport/{transportGroup}', [LogisticsController::class, 'destroyTransportGroup']);
    Route::post('logistics/transport/{transportGroup}/assign', [LogisticsController::class, 'assignTransport']);
    Route::delete('logistics/transport/{transportGroup}/guests/{guestId}', [LogisticsController::class, 'removeTransport']);

    // Guest experience builder
    Route::get('experience', [GuestExperienceController::class, 'show']);
    Route::patch('experience', [GuestExperienceController::class, 'update']);
    Route::get('experience/preview', [GuestExperienceController::class, 'preview']);
});
