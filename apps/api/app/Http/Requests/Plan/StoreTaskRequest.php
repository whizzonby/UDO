<?php

namespace App\Http\Requests\Plan;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreTaskRequest extends FormRequest
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
            'title'       => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status'      => ['nullable', 'in:pending,in_progress,complete'],
            'priority'    => ['nullable', 'in:low,medium,high'],
            'category'    => ['nullable', 'string', 'max:100'],
            'due_date'    => ['nullable', 'date'],
            'sort_order'  => ['nullable', 'integer'],
        ];
    }
}
