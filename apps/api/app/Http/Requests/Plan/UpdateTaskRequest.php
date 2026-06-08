<?php

namespace App\Http\Requests\Plan;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateTaskRequest extends FormRequest
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
            'title'       => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'status'      => ['sometimes', 'in:pending,in_progress,complete'],
            'priority'    => ['sometimes', 'in:low,medium,high'],
            'category'    => ['nullable', 'string', 'max:100'],
            'due_date'    => ['nullable', 'date'],
            'sort_order'  => ['nullable', 'integer'],
        ];
    }
}
