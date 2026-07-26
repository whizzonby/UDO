<?php

namespace App\Services;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\Relation;

class GuestAudienceFilterService
{
    public function apply(Builder|Relation $query, array $filter): Builder|Relation
    {
        if (! empty($filter['attending_status'])) {
            $query->where('attending_status', $filter['attending_status']);
        }
        if (! empty($filter['guest_group'])) {
            $query->where('guest_group', $filter['guest_group']);
        }
        if (! empty($filter['invite_status'])) {
            $query->where('invite_status', $filter['invite_status']);
        }
        if (! empty($filter['vip_flag'])) {
            $query->where('vip_flag', true);
        }
        if (! empty($filter['has_email'])) {
            $query->whereNotNull('email')->where('email', '!=', '');
        }
        if (! empty($filter['has_phone'])) {
            $query->whereNotNull('phone')->where('phone', '!=', '');
        }
        if (! empty($filter['travel_required'])) {
            $query->where('travel_required', true);
        }
        if (! empty($filter['added_after'])) {
            $query->where('created_at', '>=', $filter['added_after']);
        }
        if (! empty($filter['guest_ids']) && is_array($filter['guest_ids'])) {
            $query->whereIn('id', $filter['guest_ids']);
        }

        return $query;
    }

    public function contactBreakdown(Builder|Relation $query): array
    {
        $withEmail = (clone $query)->whereNotNull('email')->where('email', '!=', '')->count();
        $withPhone = (clone $query)->whereNotNull('phone')->where('phone', '!=', '')->count();
        $missingContact = (clone $query)
            ->where(function ($q) {
                $q->whereNull('email')->orWhere('email', '');
            })
            ->where(function ($q) {
                $q->whereNull('phone')->orWhere('phone', '');
            })
            ->count();

        return [
            'with_email' => $withEmail,
            'with_phone' => $withPhone,
            'missing_contact' => $missingContact,
        ];
    }
}
