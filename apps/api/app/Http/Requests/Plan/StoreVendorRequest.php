<?php

namespace App\Http\Requests\Plan;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreVendorRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category'         => ['required', 'string', 'max:100'],
            'name'             => ['required', 'string', 'max:255'],
            'contact_name'     => ['nullable', 'string', 'max:255'],
            'contact_email'    => ['nullable', 'email'],
            'contact_phone'    => ['nullable', 'string', 'max:50'],
            'website'          => ['nullable', 'url'],
            'status'           => ['nullable', 'in:shortlisted,booked,confirmed,paid,cancelled'],
            'contract_amount'  => ['nullable', 'numeric', 'min:0'],
            'deposit_amount'   => ['nullable', 'numeric', 'min:0'],
            'deposit_due_date' => ['nullable', 'date'],
            'notes'            => ['nullable', 'string'],
        ];
    }
}
