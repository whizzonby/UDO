<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'google' => [
        'client_id'     => env('GOOGLE_CLIENT_ID'),
        'ios_client_id' => env('GOOGLE_IOS_CLIENT_ID'),
        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
        'redirect'      => env('GOOGLE_REDIRECT_URI'),
    ],

    'apple' => [
        'client_id'     => env('APPLE_CLIENT_ID'),
        'client_secret' => env('APPLE_CLIENT_SECRET'),
        'redirect'      => env('APPLE_REDIRECT_URI'),
        'team_id'       => env('APPLE_TEAM_ID'),
        'key_id'        => env('APPLE_KEY_ID'),
    ],

    'openweather' => [
        'key' => env('OPENWEATHER_API_KEY')
            ?: env('OPEN_WEATHER_API_KEY')
            ?: env('OPENWEATHERMAP_API_KEY'),
    ],

    'spoonacular' => [
        'key' => env('SPOONACULAR_API_KEY'),
    ],

    'google_places' => [
        'key' => env('GOOGLE_PLACES_API_KEY'),
    ],

    'openai' => [
        'key' => env('OPENAI_API_KEY'),
        'model' => env('OPENAI_MODEL', 'gpt-4o-mini'),
    ],

    'twilio' => [
        'account_sid' => env('TWILIO_ACCOUNT_SID'),
        'auth_token' => env('TWILIO_AUTH_TOKEN'),
        'sms_from' => env('TWILIO_SMS_FROM'),
        'whatsapp_from' => env('TWILIO_WHATSAPP_FROM'),
        'validate_webhooks' => env('TWILIO_VALIDATE_WEBHOOKS', true),
    ],

    'pinterest' => [
        'client_id' => env('PINTEREST_CLIENT_ID'),
        'client_secret' => env('PINTEREST_CLIENT_SECRET'),
        'redirect_uri' => env('PINTEREST_REDIRECT_URI'),
    ],

    'stripe' => [
        'secret_key' => env('STRIPE_SECRET_KEY'),
        'publishable_key' => env('STRIPE_PUBLISHABLE_KEY'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
    ],

    'apple_iap' => [
        'shared_secret' => env('APPLE_IAP_SHARED_SECRET'),
        'product_id' => env('IOS_LIFETIME_PRODUCT_ID'),
    ],

    'google_play' => [
        'service_account_json' => env('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'),
        'package_name' => env('GOOGLE_PLAY_PACKAGE_NAME'),
        'product_id' => env('ANDROID_LIFETIME_PRODUCT_ID'),
    ],

    'guest_tokens' => [
        'default_expiry_days' => env('GUEST_TOKEN_DEFAULT_EXPIRY_DAYS', 365),
    ],

    'billing' => [
        'stripe_prices' => [
            'free' => [
                'monthly' => env('STRIPE_PRICE_FREE_MONTHLY'),
                'annual' => env('STRIPE_PRICE_FREE_ANNUAL'),
            ],
            'starter' => [
                'monthly' => env('STRIPE_PRICE_STARTER_MONTHLY'),
                'annual' => env('STRIPE_PRICE_STARTER_ANNUAL'),
            ],
            'pro' => [
                'monthly' => env('STRIPE_PRICE_PRO_MONTHLY'),
                'annual' => env('STRIPE_PRICE_PRO_ANNUAL'),
            ],
            'elite' => [
                'monthly' => env('STRIPE_PRICE_ELITE_MONTHLY'),
                'annual' => env('STRIPE_PRICE_ELITE_ANNUAL'),
            ],
        ],
    ],

];
