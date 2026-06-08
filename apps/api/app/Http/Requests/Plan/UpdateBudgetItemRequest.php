<?php

namespace App\Http\Requests\Plan;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateBudgetItemRequest extends FormRequest
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
            'vendor_id'       => ['nullable', 'exists:vendors,id'],
            'category'        => ['sometimes', 'string', 'max:100'],
            'name'            => ['sometimes', 'string', 'max:255'],
            'budgeted_amount' => ['sometimes', 'numeric', 'min:0'],
            'actual_amount'   => ['nullable', 'numeric', 'min:0'],
            'status'          => ['sometimes', 'in:planned,deposit_paid,fully_paid'],
            'notes'           => ['nullable', 'string'],
        ];
    }
}
