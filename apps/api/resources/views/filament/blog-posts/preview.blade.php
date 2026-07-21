<div class="space-y-4">
    @if($coverImage)
        <img src="{{ $coverImage }}" alt="" style="width:100%;max-height:280px;object-fit:cover;border-radius:0.75rem;">
    @endif
    <div>
        @if($category)
            <span class="fi-badge inline-flex items-center rounded-md px-2 py-1 text-xs font-medium bg-primary-50 text-primary-700 dark:bg-primary-400/10 dark:text-primary-400">{{ $category }}</span>
        @endif
        <h1 class="text-2xl font-bold text-gray-950 dark:text-white mt-2">{{ $title ?: '(untitled)' }}</h1>
        @if($excerpt)
            <p class="text-gray-500 dark:text-gray-400 mt-1">{{ $excerpt }}</p>
        @endif
    </div>
    <div class="prose dark:prose-invert max-w-none">
        {!! $body ?: '<p><em>No content yet.</em></p>' !!}
    </div>
    <p class="text-xs text-gray-500">
        This reflects the last saved version of the post. It does not reflect the live public template's styling.
    </p>
</div>
