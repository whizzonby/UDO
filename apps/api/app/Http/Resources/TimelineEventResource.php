<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TimelineEventResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'title'          => $this->title,
            'description'    => $this->description,
            'event_date'     => $this->event_date->toDateString(),
            'start_time'     => $this->start_time,
            'end_time'       => $this->end_time,
            'location'       => $this->location,
            'color'          => $this->color,
            'is_wedding_day' => $this->is_wedding_day,
            'sort_order'     => $this->sort_order,
            'created_at'     => $this->created_at,
        ];
    }
}
