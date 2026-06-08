<?php

namespace App\Http\Controllers\Api\Experience;

use App\Http\Controllers\Controller;
use App\Models\WeddingExperienceConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExperienceController extends Controller
{
    // GET /experience
    public function show(Request $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();

        $config = $wedding->experienceConfig ?? $this->createDefaults($wedding->id);

        return response()->json(['config' => $this->format($config)]);
    }

    // PUT /experience
    public function update(Request $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();

        $data = $request->validate([
            'is_published'      => 'boolean',
            'welcome_message'   => 'nullable|string|max:1000',
            'sections_enabled'  => 'nullable|array',
            'sections_enabled.*' => 'boolean',
            'theme_accent_color' => ['nullable', 'regex:/^#[0-9A-Fa-f]{6}$/'],
            'custom_domain'     => 'nullable|string|max:255',
        ]);

        $config = $wedding->experienceConfig ?? $this->createDefaults($wedding->id);

        if (isset($data['sections_enabled'])) {
            $current  = $config->sections_enabled ?? WeddingExperienceConfig::defaultSections();
            $data['sections_enabled'] = array_merge($current, $data['sections_enabled']);
        }

        $config->update($data);

        return response()->json(['config' => $this->format($config->fresh())]);
    }

    private function createDefaults(string $weddingId): WeddingExperienceConfig
    {
        return WeddingExperienceConfig::create([
            'wedding_id'       => $weddingId,
            'sections_enabled' => WeddingExperienceConfig::defaultSections(),
        ]);
    }

    private function format(WeddingExperienceConfig $c): array
    {
        return [
            'id'                => $c->id,
            'is_published'      => $c->is_published,
            'welcome_message'   => $c->welcome_message,
            'sections_enabled'  => $c->sections_enabled ?? WeddingExperienceConfig::defaultSections(),
            'theme_accent_color' => $c->theme_accent_color,
            'custom_domain'     => $c->custom_domain,
        ];
    }
}
