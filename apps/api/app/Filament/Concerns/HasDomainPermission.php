<?php

namespace App\Filament\Concerns;

use Illuminate\Database\Eloquent\Model;

/**
 * Gates a resource's view/create/edit/delete behind a single `admin.*` domain
 * permission (see RolesSeeder), so a staff role like content_admin — which only
 * holds admin.access + admin.content — cannot reach resources outside its
 * domain even though canAccessPanel() lets it into the panel itself.
 *
 * Resources that already define their own canCreate()/canEdit()/etc. (e.g.
 * read-only resources hardcoding false) keep that behavior: a class method
 * always takes priority over a trait method of the same name.
 */
trait HasDomainPermission
{
    public static function canViewAny(): bool
    {
        return auth()->user()?->can(static::$requiredPermission) ?? false;
    }

    public static function canCreate(): bool
    {
        return static::canViewAny();
    }

    public static function canEdit(Model $record): bool
    {
        return static::canViewAny();
    }

    public static function canDelete(Model $record): bool
    {
        return static::canViewAny();
    }

    public static function canView(Model $record): bool
    {
        return static::canViewAny();
    }
}
