<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WeddingResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'partner_one_name' => $this->partner_one_name,
            'partner_two_name' => $this->partner_two_name,
            'wedding_date'     => $this->wedding_date?->toDateString(),
            'date_not_set'     => $this->date_not_set,
            'venue_name'       => $this->venue_name,
            'venue_address'    => $this->venue_address,
            'guest_count_range'=> $this->guest_count_range,
            'currency'         => $this->currency,
            'total_budget'     => $this->total_budget,
            'cover_photo_url'  => $this->cover_photo_url,
            'status'           => $this->status,
            'timezone'         => $this->timezone,
            'created_at'       => $this->created_at,
        ];
    }
}
