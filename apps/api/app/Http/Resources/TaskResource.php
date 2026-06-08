<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TaskResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'           => $this->id,
            'title'        => $this->title,
            'description'  => $this->description,
            'status'       => $this->status,
            'is_complete'  => $this->is_complete,
            'priority'     => $this->priority,
            'category'     => $this->category,
            'due_date'     => $this->due_date?->toDateString(),
            'completed_at' => $this->completed_at,
            'sort_order'   => $this->sort_order,
            'created_at'   => $this->created_at,
        ];
    }
}
