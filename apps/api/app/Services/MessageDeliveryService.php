<?php

namespace App\Services;

use App\Mail\GuestMessageMail;
use App\Models\GuestMessageDelivery;
use App\Models\GuestToken;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;
use RuntimeException;

class MessageDeliveryService
{
    public function send(GuestMessageDelivery $delivery): array
    {
        return match ($delivery->channel) {
            'email' => $this->sendEmail($delivery),
            'sms' => $this->sendTwilioMessage($delivery, false),
            'whatsapp' => $this->sendTwilioMessage($delivery, true),
            'in_app' => $this->sendInApp($delivery),
            default => throw new RuntimeException("Channel {$delivery->channel} is not configured yet."),
        };
    }

    /**
     * In-app has no external transport (no native guest inbox yet — that's
     * a v2 feature). "Delivery" here means the message becomes visible on
     * the guest's wedding portal page: once this delivery succeeds, the
     * parent Message reaches status `sent`, and the portal's messages feed
     * (GuestPortalController::portalMessages()) already queries `messages`
     * by that status with no channel filter, so it picks this up with no
     * further plumbing needed.
     */
    private function sendInApp(GuestMessageDelivery $delivery): array
    {
        return ['external_id' => null];
    }

    private function sendEmail(GuestMessageDelivery $delivery): array
    {
        if ($delivery->guest->email_opt_out) {
            throw new RuntimeException('Guest has opted out of email messages.');
        }

        if (! $delivery->guest->email) {
            throw new RuntimeException('Guest does not have an email address.');
        }

        Mail::to($delivery->guest->email)->send(new GuestMessageMail(
            $this->renderTemplate($delivery, $delivery->message->subject ?? 'A wedding update'),
            $this->renderTemplate($delivery, $delivery->message->body),
        ));

        return ['external_id' => null];
    }

    private function sendTwilioMessage(GuestMessageDelivery $delivery, bool $whatsapp): array
    {
        if ($whatsapp && $delivery->guest->whatsapp_opt_out) {
            throw new RuntimeException('Guest has opted out of WhatsApp messages.');
        }

        if (! $whatsapp && $delivery->guest->sms_opt_out) {
            throw new RuntimeException('Guest has opted out of SMS messages.');
        }

        if (! $delivery->guest->phone) {
            throw new RuntimeException('Guest does not have a phone number.');
        }

        $accountSid = config('services.twilio.account_sid');
        $authToken = config('services.twilio.auth_token');
        $from = $whatsapp
            ? config('services.twilio.whatsapp_from')
            : config('services.twilio.sms_from');

        if (! $accountSid || ! $authToken || ! $from) {
            throw new RuntimeException($whatsapp
                ? 'Twilio WhatsApp credentials are not configured.'
                : 'Twilio SMS credentials are not configured.');
        }

        $response = Http::asForm()
            ->withBasicAuth($accountSid, $authToken)
            ->timeout(10)
            ->post("https://api.twilio.com/2010-04-01/Accounts/{$accountSid}/Messages.json", [
                'From' => $this->formatTwilioAddress($from, $whatsapp),
                'To' => $this->formatTwilioAddress($delivery->guest->phone, $whatsapp),
                'Body' => $this->renderTemplate($delivery, $delivery->message->body),
                'StatusCallback' => route('twilio.messages.status'),
            ]);

        if ($response->failed()) {
            throw new RuntimeException($response->json('message') ?: 'Twilio message delivery failed.');
        }

        return ['external_id' => $response->json('sid')];
    }

    private function formatTwilioAddress(string $address, bool $whatsapp): string
    {
        $address = trim($address);

        if (! $whatsapp || str_starts_with($address, 'whatsapp:')) {
            return $address;
        }

        return "whatsapp:{$address}";
    }

    private function renderTemplate(GuestMessageDelivery $delivery, string $content): string
    {
        $guest = $delivery->guest;
        $wedding = $delivery->message->wedding;
        $token = $guest->token;

        if (! $token && $delivery->message->message_type === 'invitation') {
            $token = GuestToken::create([
                'wedding_id' => $guest->wedding_id,
                'guest_id' => $guest->id,
                'view_type' => $guest->guest_view_type,
            ]);
            $guest->setRelation('token', $token);
        }

        $frontendUrl = rtrim((string) config('app.frontend_url', config('app.url')), '/');
        $rsvpUrl = $token ? "{$frontendUrl}/g/{$token->token}" : $frontendUrl;
        $guestName = trim(implode(' ', array_filter([$guest->first_name, $guest->last_name]))) ?: 'there';
        $coupleNames = trim(implode(' & ', array_filter([$wedding?->couple_name_primary, $wedding?->couple_name_secondary])));

        return strtr($content, [
            '{{first_name}}' => $guest->first_name ?: $guestName,
            '{{guest_name}}' => $guestName,
            '{{rsvp_url}}' => $rsvpUrl,
            '{{guest_portal_url}}' => $rsvpUrl,
            '{{couple_names}}' => $coupleNames,
            '{{wedding_title}}' => $wedding?->title ?: ($coupleNames ? "{$coupleNames}'s wedding" : 'our wedding'),
        ]);
    }
}
