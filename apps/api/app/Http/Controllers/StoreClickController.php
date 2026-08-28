<?php

namespace App\Http\Controllers;

use App\Models\StoreLinkClick;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

/**
 * Public, unauthenticated. The marketing site beacons here right before a
 * visitor leaves for the Play Store, so app-link clicks show up in the admin
 * panel. Fire-and-forget: always returns 204, never surfaces an error to the
 * page.
 */
class StoreClickController extends Controller
{
    public function store(Request $request): Response
    {
        $data = $request->validate([
            'platform'      => 'nullable|string|in:android,ios,web',
            'source_path'   => 'nullable|string|max:191',
            'link_location' => 'nullable|string|max:64',
            'utm_source'    => 'nullable|string|max:191',
            'utm_medium'    => 'nullable|string|max:191',
            'utm_campaign'  => 'nullable|string|max:191',
            'utm_content'   => 'nullable|string|max:191',
            'utm_term'      => 'nullable|string|max:191',
            'referrer'      => 'nullable|string|max:512',
            'click_id'      => 'nullable|string|max:40',
        ]);

        $attributes = [
            ...$data,
            'platform'   => $data['platform'] ?? 'android',
            'country'    => $request->header('CF-IPCountry') ?: null,
            'ip_hash'    => hash('sha256', $request->ip() . '|' . config('app.key')),
            'user_agent' => mb_substr((string) $request->userAgent(), 0, 512),
        ];

        if (! empty($data['click_id'])) {
            StoreLinkClick::firstOrCreate(['click_id' => $data['click_id']], $attributes);
        } else {
            StoreLinkClick::create($attributes);
        }

        return response()->noContent();
    }
}
