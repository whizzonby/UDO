<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VendorResource extends JsonResource
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
            'category'         => $this->category,
            'name'             => $this->name,
            'contact_name'     => $this->contact_name,
            'contact_email'    => $this->contact_email,
            'contact_phone'    => $this->contact_phone,
            'website'          => $this->website,
            'status'           => $this->status,
            'contract_amount'  => $this->contract_amount,
            'deposit_amount'   => $this->deposit_amount,
            'deposit_due_date' => $this->deposit_due_date?->toDateString(),
            'deposit_paid_at'  => $this->deposit_paid_at,
            'notes'            => $this->notes,
            'created_at'       => $this->created_at,
        ];
    }
}
