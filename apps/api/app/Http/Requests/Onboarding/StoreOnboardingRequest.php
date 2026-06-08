<?php

namespace App\Http\Requests\Onboarding;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class StoreOnboardingRequest extends FormRequest
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
            // Wedding core
            'partner_one_name'    => ['required', 'string', 'max:255'],
            'partner_two_name'    => ['nullable', 'string', 'max:255'],
            'wedding_date'        => ['nullable', 'date'],
            'date_not_set'        => ['boolean'],
            'guest_count_range'   => ['nullable', 'string'],
            'total_budget'        => ['nullable', 'numeric', 'min:0'],
            'currency'            => ['nullable', 'string', 'size:3'],
            'timezone'            => ['nullable', 'string'],
            // Onboarding fields
            'user_role'           => ['nullable', 'string'],
            'planning_approach'   => ['nullable', 'string'],
            'decision_style'      => ['nullable', 'string'],
            'planning_stage'      => ['nullable', 'string'],
            'wedding_type'        => ['nullable', 'string'],
            'season'              => ['nullable', 'string'],
            'date_flexibility'    => ['nullable', 'string'],
            'time_of_day'         => ['nullable', 'string'],
            'event_structures'    => ['nullable', 'array'],
            'venue_status'        => ['nullable', 'string'],
            'guest_travel_profile'=> ['nullable', 'string'],
            'support_needed'      => ['nullable', 'array'],
            'food_experience'     => ['nullable', 'array'],
            'dietary_needs'       => ['nullable', 'array'],
            'entertainment'       => ['nullable', 'array'],
            'speeches_config'     => ['nullable', 'array'],
            'wedding_insurance'   => ['nullable', 'string'],
            'guest_experience_style' => ['nullable', 'string'],
            'communication_style' => ['nullable', 'string'],
            'invitation_channels' => ['nullable', 'array'],
            'planning_priorities' => ['nullable', 'array'],
            'wedding_vibes'       => ['nullable', 'array'],
            'budget_range'        => ['nullable', 'string'],
        ];
    }
}
