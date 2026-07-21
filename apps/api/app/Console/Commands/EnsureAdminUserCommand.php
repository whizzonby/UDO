<?php

namespace App\Console\Commands;

use App\Models\User;
use Database\Seeders\RolesSeeder;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Spatie\Permission\Models\Role;

class EnsureAdminUserCommand extends Command
{
    protected $signature = 'admin:ensure
        {email : Email address for the admin user}
        {--name= : Display name for a newly created admin}
        {--password= : Initial password. If omitted, a secure temporary password is generated}
        {--role=super_admin : Admin role to assign}
        {--force-password : Replace the password for an existing user}';

    protected $description = 'Create or promote an admin user and assign a seeded staff role.';

    public function handle(): int
    {
        $this->callSilent('db:seed', ['--class' => RolesSeeder::class, '--force' => true]);

        $email = strtolower(trim((string) $this->argument('email')));
        $roleName = (string) $this->option('role');
        $role = Role::where('guard_name', 'web')->where('name', $roleName)->first();

        if (! $role) {
            $this->error("Role [{$roleName}] does not exist. Run php artisan db:seed --class=RolesSeeder first.");
            return self::FAILURE;
        }

        $password = (string) ($this->option('password') ?: Str::password(20));
        $name = trim((string) ($this->option('name') ?: Str::before($email, '@')));

        $user = User::firstOrNew(['email' => $email]);
        $isNew = ! $user->exists;

        if ($isNew) {
            $user->fill([
                'name' => $name,
                'first_name' => $name,
                'last_name' => '',
                'password' => Hash::make($password),
                'email_verified_at' => now(),
                'onboarding_completed' => true,
            ]);
        } elseif ($this->option('force-password')) {
            $user->password = Hash::make($password);
        }

        if (! $user->email_verified_at) {
            $user->email_verified_at = now();
        }

        $user->save();
        $user->assignRole($role);

        $this->info(($isNew ? 'Created' : 'Updated') . " {$email} with role {$roleName}.");

        if (! $this->option('password') || $this->option('force-password')) {
            $this->warn('Temporary password: ' . $password);
        }

        return self::SUCCESS;
    }
}
