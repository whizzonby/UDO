<?php

namespace App\Http\Controllers\Api\Gallery;

use App\Http\Controllers\Controller;
use App\Models\GalleryItem;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class GalleryController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        return $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();
    }

    private function authorizeItem(Request $request, GalleryItem $item): void
    {
        $wedding = $this->wedding($request);
        abort_unless($item->wedding_id === $wedding->id, 403);
    }

    // GET /gallery?type=inspiration|memory&category=florals
    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $query   = $wedding->galleryItems()->orderBy('sort_order')->orderBy('created_at', 'desc');

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        $items = $query->get();

        $inspiration = $items->where('type', 'inspiration');
        $memories    = $items->where('type', 'memory');

        return response()->json([
            'items' => $items->map(fn ($i) => $this->format($i))->values(),
            'summary' => [
                'total'        => $items->count(),
                'inspiration'  => $inspiration->count(),
                'memories'     => $memories->count(),
                'featured'     => $items->where('is_featured', true)->count(),
                'categories'   => $inspiration->pluck('category')->filter()->unique()->values(),
            ],
        ]);
    }

    // POST /gallery  (multipart/form-data OR json with image_url)
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'type'       => 'sometimes|in:inspiration,memory',
            'title'      => 'nullable|string|max:200',
            'caption'    => 'nullable|string|max:1000',
            'category'   => 'nullable|string|max:100',
            'source_url' => 'nullable|url|max:500',
            'image_url'  => 'required_without:image|nullable|url|max:500',
            'image'      => 'required_without:image_url|nullable|image|max:10240',
            'uploaded_by'=> 'nullable|string|max:200',
        ]);

        $wedding  = $this->wedding($request);
        $imageUrl = $request->image_url;

        if ($request->hasFile('image')) {
            $path     = $request->file('image')->store("weddings/{$wedding->id}/gallery", 'public');
            $imageUrl = Storage::disk('public')->url($path);
        }

        $maxOrder = $wedding->galleryItems()->max('sort_order') ?? -1;

        $item = $wedding->galleryItems()->create([
            'type'        => $request->input('type', 'inspiration'),
            'title'       => $request->title,
            'caption'     => $request->caption,
            'image_url'   => $imageUrl,
            'category'    => $request->category,
            'source_url'  => $request->source_url,
            'uploaded_by' => $request->uploaded_by,
            'sort_order'  => $maxOrder + 1,
        ]);

        return response()->json($this->format($item), 201);
    }

    // PUT /gallery/{item}
    public function update(Request $request, GalleryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);

        $request->validate([
            'title'   => 'nullable|string|max:200',
            'caption' => 'nullable|string|max:1000',
            'category'=> 'nullable|string|max:100',
        ]);

        $item->update($request->only(['title', 'caption', 'category']));

        return response()->json($this->format($item));
    }

    // DELETE /gallery/{item}
    public function destroy(Request $request, GalleryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);

        // Remove local file if stored on public disk
        if (Str::startsWith($item->image_url, config('app.url'))) {
            $path = Str::after($item->image_url, Storage::disk('public')->url(''));
            Storage::disk('public')->delete($path);
        }

        $item->delete();

        return response()->json(['deleted' => true]);
    }

    // PATCH /gallery/{item}/feature
    public function feature(Request $request, GalleryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $item->update(['is_featured' => !$item->is_featured]);

        return response()->json($this->format($item));
    }

    // POST /gallery/reorder
    public function reorder(Request $request): JsonResponse
    {
        $request->validate(['ids' => 'required|array', 'ids.*' => 'uuid']);

        $wedding = $this->wedding($request);
        foreach ($request->ids as $order => $id) {
            $wedding->galleryItems()->where('id', $id)->update(['sort_order' => $order]);
        }

        return response()->json(['reordered' => true]);
    }

    private function format(GalleryItem $item): array
    {
        return [
            'id'          => $item->id,
            'type'        => $item->type,
            'title'       => $item->title,
            'caption'     => $item->caption,
            'image_url'   => $item->image_url,
            'category'    => $item->category,
            'is_featured' => $item->is_featured,
            'source_url'  => $item->source_url,
            'uploaded_by' => $item->uploaded_by,
            'sort_order'  => $item->sort_order,
            'created_at'  => $item->created_at?->toIso8601String(),
        ];
    }
}
