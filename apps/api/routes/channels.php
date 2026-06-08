<?php

use Illuminate\Support\Facades\Broadcast;

// Admin users can subscribe to private-wedding.{id} if they belong to that wedding.
// Clients subscribe with the "private-" prefix; Laravel strips it when matching here.
Broadcast::channel('wedding.{weddingId}', function ($user, string $weddingId): bool {
    return (bool) $user->weddings()->where('weddings.id', $weddingId)->exists();
});
