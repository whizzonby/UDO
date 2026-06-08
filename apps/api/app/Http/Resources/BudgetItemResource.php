<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BudgetItemResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'vendor_id'       => $this->vendor_id,
            'vendor_name'     => $this->whenLoaded('vendor', fn () => $this->vendor?->name),
            'category'        => $this->category,
            'name'            => $this->name,
            'budgeted_amount' => $this->budgeted_amount,
            'actual_amount'   => $this->actual_amount,
            'status'          => $this->status,
            'notes'           => $this->notes,
            'created_at'      => $this->created_at,
        ];
    }
}
