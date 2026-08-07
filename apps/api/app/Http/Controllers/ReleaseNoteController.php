<?php

namespace App\Http\Controllers;

use App\Models\ReleaseNote;
use Illuminate\Http\JsonResponse;

class ReleaseNoteController extends Controller
{
    public function index(): JsonResponse
    {
        $notes = ReleaseNote::orderByDesc('released_at')->orderByDesc('id')->get();

        return response()->json(['data' => $notes]);
    }
}
