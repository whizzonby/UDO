<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable, HasApiTokens, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar_url',
        'social_provider',
        'social_id',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    // Gate Filament ops panel to users with the 'ops' role.
    // Grant with: User::find($id)->assignRole('ops')
    public function canAccessPanel(Panel $panel): bool
    {
        return $this->hasRole(['ops', 'super-admin']);
    }

    public function weddings(): BelongsToMany
    {
        return $this->belongsToMany(Wedding::class, 'wedding_users')
            ->withPivot(['role', 'permissions', 'joined_at'])
            ->withTimestamps();
    }
}
