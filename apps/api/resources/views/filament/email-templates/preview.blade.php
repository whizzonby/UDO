<div class="space-y-3">
    <div class="text-sm text-gray-600 dark:text-gray-300">
        <span class="font-medium text-gray-950 dark:text-white">Subject:</span> {{ $subject }}
    </div>
    <iframe
        srcdoc="{{ $html }}"
        title="Email preview"
        style="width:100%;height:520px;border:1px solid #e5e7eb;border-radius:0.5rem;background:#fff;"
    ></iframe>
    <p class="text-xs text-gray-500">
        Rendered with sample values for any unfilled variables. This reflects the last saved version of the template.
    </p>
</div>
