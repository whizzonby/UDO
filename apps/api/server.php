<?php

/**
 * Laravel development server router — serves static files from public/
 * and routes everything else through public/index.php.
 */

$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$publicPath = __DIR__ . '/public' . $uri;

if ($uri !== '/' && is_file($publicPath)) {
    // Serve static file with correct MIME type
    $ext = strtolower(pathinfo($publicPath, PATHINFO_EXTENSION));
    $mime = match ($ext) {
        'css'  => 'text/css; charset=UTF-8',
        'js'   => 'application/javascript',
        'png'  => 'image/png',
        'jpg', 'jpeg' => 'image/jpeg',
        'gif'  => 'image/gif',
        'svg'  => 'image/svg+xml',
        'ico'  => 'image/x-icon',
        'woff' => 'font/woff',
        'woff2'=> 'font/woff2',
        'ttf'  => 'font/ttf',
        'json' => 'application/json',
        default => 'application/octet-stream',
    };
    header('Content-Type: ' . $mime);
    readfile($publicPath);
    return;
}

$_SERVER['SCRIPT_FILENAME'] = __DIR__ . '/public/index.php';
require __DIR__ . '/public/index.php';
