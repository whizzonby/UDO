<?php

use App\Http\Controllers\Api\Auth\LoginController;
use App\Http\Controllers\Api\Auth\LogoutController;
use App\Http\Controllers\Api\Auth\MeController;
use App\Http\Controllers\Api\Auth\RegisterController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\OnboardingController;
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
