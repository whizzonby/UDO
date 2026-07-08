<?php

return [
    'paths'                => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods'      => ['*'],
    // Comma-separated for multiple trusted origins (e.g. the Next.js web app
    // plus a Flutter web build during development); falls back to FRONTEND_URL.
    'allowed_origins'      => array_filter(array_map(
        'trim',
        explode(',', env('CORS_ALLOWED_ORIGINS', env('FRONTEND_URL', 'http://localhost:3000')))
    )),
    'allowed_origins_patterns' => [],
    'allowed_headers'      => ['*'],
    'exposed_headers'      => [],
    'max_age'              => 0,
    'supports_credentials' => true,
];
