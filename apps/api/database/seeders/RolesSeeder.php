<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolesSeeder extends Seeder
{
    private const ROLE_PERMISSIONS = [
        'super_admin' => [
            'admin.access',
            'admin.users',
            'admin.weddings',
            'admin.operations',
            'admin.finance',
            'admin.support',
            'admin.content',
        ],
        'admin' => [
            'admin.access',
            'admin.users',
            'admin.weddings',
            'admin.operations',
            'admin.finance',
            'admin.support',
            'admin.content',
        ],
        'ops_admin' => [
            'admin.access',
            'admin.weddings',
            'admin.operations',
            'admin.support',
        ],
        'support_admin' => [
            'admin.access',
            'admin.users',
            'admin.weddings',
            'admin.support',
        ],
        'finance_admin' => [
            'admin.access',
            'admin.users',
            'admin.finance',
            'admin.support',
        ],
        'content_admin' => [
            'admin.access',
            'admin.content',
        ],
    ];

    public function run(): void
    {
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        foreach (collect(self::ROLE_PERMISSIONS)->flatten()->unique() as $permission) {
            Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'web']);
        }

        foreach (self::ROLE_PERMISSIONS as $roleName => $permissions) {
            $role = Role::firstOrCreate(['name' => $roleName, 'guard_name' => 'web']);
            $role->syncPermissions($permissions);
        }

        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();
    }
}
