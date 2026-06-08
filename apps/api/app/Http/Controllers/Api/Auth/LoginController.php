<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    public function __invoke(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $user->tokens()->where('name', 'udo-admin-app')->delete();
        $token = $user->createToken('udo-admin-app')->plainTextToken;

        $wedding = $user->weddings()->latest()->first();

        return response()->json([
            'user'    => new UserResource($user),
            'token'   => $token,
            'wedding' => $wedding?->only(['id', 'partner_one_name', 'partner_two_name', 'wedding_date', 'status']),
        ]);
    }
}
