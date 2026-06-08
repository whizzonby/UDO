<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Http\Resources\WeddingResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MeController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $user = $request->user();
        $wedding = $user->weddings()->latest('wedding_users.created_at')->first();

        return response()->json([
            'user'    => new UserResource($user),
            'wedding' => $wedding ? new WeddingResource($wedding) : null,
        ]);
    }
}
