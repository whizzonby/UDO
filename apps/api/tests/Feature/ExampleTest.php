<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * The root domain is dedicated to the admin panel, so it redirects
     * straight to /admin instead of serving Laravel's stock welcome page.
     */
    public function test_the_root_route_redirects_to_the_admin_panel(): void
    {
        $response = $this->get('/');

        $response->assertRedirect('/admin');
    }
}
