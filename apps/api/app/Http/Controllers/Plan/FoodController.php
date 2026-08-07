<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Guest;
use App\Models\GuestMenuSelection;
use App\Models\MenuCourse;
use App\Models\MenuCourseOption;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    /**
     * Mirrors the "Allergies" section of the guest dietary tag picker
     * (mobile `_dietaryAllergyOptions`) so the allergy stat tile doesn't
     * count a purely dietary-preference tag (e.g. "Vegetarian") as an allergy.
     * A custom "Other" entry is saved as "Other (Allergy): {text}" by the
     * picker, so it's matched by prefix rather than exact string.
     */
    private const ALLERGY_TAGS = [
        'Peanuts', 'Tree Nuts', 'Dairy (Milk)', 'Eggs', 'Fish', 'Shellfish',
        'Wheat', 'Soy', 'Sesame', 'Mustard', 'Celery', 'Lupin', 'Sulphites',
        'Corn', 'Coconut', 'Garlic', 'Onion', 'Mushroom', 'Chocolate', 'Citrus',
    ];

    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManagePlan(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_plan'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $courses = $wedding->menuCourses()
            ->with(['options' => fn ($query) => $query->withCount('selections')])
            ->get();

        $totalGuests = $wedding->guests()->count();
        $mealSelections = $wedding->guests()
            ->where(function ($query) {
                $query->whereNotNull('meal_preference')->orWhereHas('menuSelections');
            })
            ->count();
        $dietaryNeeds = $wedding->guests()
            ->where(function ($query) {
                $query->whereNotNull('dietary_note')
                    ->orWhereNotNull('allergies')
                    ->orWhereNotNull('dietary_tags');
            })
            ->count();
        $allergyCount = $wedding->guests()
            ->where(function ($query) {
                $query->whereNotNull('allergies')->orWhereNotNull('dietary_tags');
            })
            ->get(['id', 'allergies', 'dietary_tags'])
            ->filter(function (Guest $guest) {
                if (!empty($guest->allergies)) {
                    return true;
                }
                return collect($guest->dietary_tags ?? [])
                    ->contains(fn ($tag) => in_array($tag, self::ALLERGY_TAGS, true)
                        || str_starts_with((string) $tag, 'Other (Allergy):'));
            })
            ->count();
        $itemsToReview = MenuCourseOption::where('wedding_id', $wedding->id)->where('confirmed', false)->count();

        return response()->json([
            'data' => [
                'courses' => $courses,
                'summary' => [
                    'total_guests' => $totalGuests,
                    'meal_selections' => $mealSelections,
                    'dietary_needs' => $dietaryNeeds,
                    'allergy_count' => $allergyCount,
                    'items_to_review' => $itemsToReview,
                ],
            ],
        ]);
    }

    public function storeCourse(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'nullable|in:drinks,starter,main,dessert,late_night,other',
            'sort_order' => 'nullable|integer',
        ]);

        $course = $wedding->menuCourses()->create($data);

        return response()->json(['data' => $course->load('options')], 201);
    }

    public function updateCourse(Request $request, MenuCourse $menuCourse): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($menuCourse->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'type' => 'nullable|in:drinks,starter,main,dessert,late_night,other',
            'sort_order' => 'nullable|integer',
        ]);
        $menuCourse->update($data);

        return response()->json(['data' => $menuCourse->fresh()->load('options')]);
    }

    public function destroyCourse(Request $request, MenuCourse $menuCourse): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($menuCourse->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);
        $menuCourse->delete();

        return response()->json(null, 204);
    }

    public function storeOption(Request $request, MenuCourse $menuCourse): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($menuCourse->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'dietary_tags' => 'nullable|array',
            'metadata' => 'nullable|array',
            'sort_order' => 'nullable|integer',
        ]);

        $option = $menuCourse->options()->create([
            ...$data,
            'wedding_id' => $wedding->id,
            'confirmed' => false,
        ]);

        return response()->json(['data' => $option], 201);
    }

    public function updateOption(Request $request, MenuCourseOption $menuCourseOption): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($menuCourseOption->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'dietary_tags' => 'nullable|array',
            'metadata' => 'nullable|array',
            'confirmed' => 'nullable|boolean',
            'sort_order' => 'nullable|integer',
        ]);
        $menuCourseOption->update($data);

        return response()->json(['data' => $menuCourseOption->fresh()]);
    }

    public function destroyOption(Request $request, MenuCourseOption $menuCourseOption): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($menuCourseOption->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);
        $menuCourseOption->delete();

        return response()->json(null, 204);
    }

    public function selectForGuest(Request $request, MenuCourseOption $menuCourseOption): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($menuCourseOption->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'guest_id' => 'required|integer|exists:guests,id',
        ]);
        $guest = Guest::findOrFail($data['guest_id']);
        abort_unless($guest->wedding_id === $wedding->id, 403);

        $selection = GuestMenuSelection::updateOrCreate(
            ['guest_id' => $guest->id, 'menu_course_id' => $menuCourseOption->menu_course_id],
            ['menu_course_option_id' => $menuCourseOption->id, 'wedding_id' => $wedding->id],
        );

        if ($menuCourseOption->course->type === 'main') {
            $guest->update(['meal_preference' => $menuCourseOption->name]);
        }

        return response()->json(['data' => $selection->load('option', 'course')], 201);
    }

    public function removeSelection(Request $request, Guest $guest, MenuCourse $menuCourse): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($guest->wedding_id === $wedding->id && $menuCourse->wedding_id === $wedding->id, 403);
        $this->ensureCanManagePlan($request);

        GuestMenuSelection::where('guest_id', $guest->id)->where('menu_course_id', $menuCourse->id)->delete();

        if ($menuCourse->type === 'main') {
            $guest->update(['meal_preference' => null]);
        }

        return response()->json(null, 204);
    }
}
