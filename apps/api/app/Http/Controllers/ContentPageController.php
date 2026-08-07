<?php

namespace App\Http\Controllers;

use App\Models\ContentPage;
use Illuminate\Http\JsonResponse;

class ContentPageController extends Controller
{
    public function show(string $slug): JsonResponse
    {
        $page = ContentPage::where('slug', $slug)->firstOrFail();

        return response()->json(['data' => $page]);
    }
}
