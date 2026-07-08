<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class EmailVerificationController extends Controller
{
    /**
     * Signed link from the verification email. No auth guard here — the
     * signature itself, scoped to this user's id + email hash, is the proof.
     */
    public function verify(Request $request, int $id, string $hash): Response
    {
        $user = User::findOrFail($id);

        if (! hash_equals($hash, sha1($user->getEmailForVerification()))) {
            return response('This verification link is invalid.', 403);
        }

        if (! $user->hasVerifiedEmail()) {
            $user->markEmailAsVerified();
        }

        return response(
            '<!DOCTYPE html><html><body style="font-family:sans-serif;text-align:center;padding:80px 20px;">' .
            '<h1 style="color:#285301;">Email verified</h1>' .
            '<p>You can close this tab and return to the Udo app.</p>' .
            '</body></html>'
        );
    }

    public function resend(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->hasVerifiedEmail()) {
            return response()->json(['message' => 'Email already verified.']);
        }

        $user->sendEmailVerificationNotification();

        return response()->json(['message' => 'Verification email sent.']);
    }
}
