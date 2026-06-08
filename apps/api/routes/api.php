<?php

use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\LogoutController;
use App\Http\Controllers\Api\Auth\MeController;
use App\Http\Controllers\Api\Auth\RegisterController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\OnboardingController;
use App\Http\Controllers\Api\Guests\GuestController;
use App\Http\Controllers\Api\Experience\ExperienceController;
use App\Http\Controllers\Api\Plan\BudgetController;
use App\Http\Controllers\Api\Plan\TaskController;
use App\Http\Controllers\Api\Plan\TimelineController;
use App\Http\Controllers\Api\Plan\VendorController;
use Illuminate\Support\Facades\Route;

// ── Auth (public) ─────────────────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('/register', RegisterController::class);
    Route::post('/login',    LoginController::class);
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
        Route::post('/{guest}/mark-invited',     [GuestController::class, 'markInvited']);
        Route::post('/{guest}/regenerate-token', [GuestController::class, 'regenerateToken']);
    });

    // Guest Experience config
    Route::prefix('experience')->group(function () {
        Route::get('/',  [ExperienceController::class, 'show']);
        Route::put('/',  [ExperienceController::class, 'update']);
    });

    // Plan
    Route::prefix('plan')->group(function () {
        Route::apiResource('tasks',    TaskController::class)->except(['show']);
        Route::apiResource('timeline', TimelineController::class)->except(['show']);
        Route::apiResource('vendors',  VendorController::class)->except(['show']);
        Route::apiResource('budget',   BudgetController::class)
            ->parameters(['budget' => 'budgetItem'])
            ->except(['show']);
    });
});
