<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;

class ForgotPasswordController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $request->validate(['email' => 'required|email']);

        // Always return 200 — never reveal whether an email exists
        Password::sendResetLink($request->only('email'));

        return response()->json([
            'message' => 'If that email address is registered, we\'ve sent a password reset link.',
        ]);
    }
}
