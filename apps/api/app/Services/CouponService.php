<?php

namespace App\Services;

use App\Models\Coupon;
use App\Models\Subscription;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class CouponService
{
    public function findRedeemable(string $code): ?Coupon
    {
        $coupon = Coupon::where('code', strtoupper(trim($code)))->first();

        return ($coupon && $coupon->isRedeemable()) ? $coupon : null;
    }

    public function alreadyRedeemedBy(Coupon $coupon, User $user): bool
    {
        return $coupon->redemptions()->where('user_id', $user->id)->exists();
    }

    public function redeem(
        Coupon $coupon,
        User $user,
        int $baseCents,
        ?string $stripeCheckoutSessionId = null,
        ?Subscription $subscription = null,
    ): int {
        $discountCents = $coupon->discountCents($baseCents);

        DB::transaction(function () use ($coupon, $user, $subscription, $stripeCheckoutSessionId, $discountCents) {
            $coupon->redemptions()->create([
                'user_id' => $user->id,
                'subscription_id' => $subscription?->id,
                'stripe_checkout_session_id' => $stripeCheckoutSessionId,
                'amount_discounted_cents' => $discountCents,
                'redeemed_at' => now(),
            ]);

            $coupon->increment('redeemed_count');
        });

        return $discountCents;
    }
}
