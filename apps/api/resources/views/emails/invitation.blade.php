<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>You're invited</title>
  <!--[if mso]>
  <noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript>
  <![endif]-->
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=DM+Sans:wght@400;500;600&display=swap');

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      background-color: #FAF0EC;
      font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      -webkit-font-smoothing: antialiased;
      color: #333333;
    }

    .wrapper {
      max-width: 560px;
      margin: 0 auto;
      padding: 32px 16px;
    }

    /* Header */
    .header {
      text-align: center;
      padding: 48px 40px 40px;
      background: linear-gradient(160deg, #FF4D8C 0%, #D4006A 100%);
      border-radius: 24px 24px 0 0;
    }

    .header-eyebrow {
      font-size: 11px;
      font-weight: 600;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: rgba(255,255,255,0.75);
      margin-bottom: 16px;
    }

    .header-names {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 36px;
      font-weight: 700;
      color: #ffffff;
      line-height: 1.15;
      margin-bottom: 12px;
    }

    .header-date {
      font-size: 14px;
      color: rgba(255,255,255,0.85);
      font-weight: 500;
    }

    .header-heart {
      font-size: 32px;
      margin-top: 20px;
      display: block;
    }

    /* Card body */
    .card {
      background: #ffffff;
      padding: 40px;
      border-radius: 0 0 24px 24px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.06);
    }

    .greeting {
      font-size: 20px;
      font-weight: 600;
      color: #333333;
      margin-bottom: 12px;
    }

    .body-text {
      font-size: 15px;
      line-height: 1.65;
      color: #555555;
      margin-bottom: 16px;
    }

    /* Details block */
    .details-block {
      background: #FFF0F5;
      border-radius: 16px;
      padding: 20px 24px;
      margin: 28px 0;
    }

    .details-row {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 8px 0;
    }

    .details-row + .details-row {
      border-top: 1px solid rgba(255,77,140,0.15);
    }

    .details-icon {
      font-size: 16px;
      flex-shrink: 0;
      margin-top: 1px;
    }

    .details-label {
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: #FF4D8C;
      margin-bottom: 2px;
    }

    .details-value {
      font-size: 14px;
      font-weight: 500;
      color: #333333;
    }

    /* CTA button */
    .cta-wrapper {
      text-align: center;
      margin: 32px 0 24px;
    }

    .cta-button {
      display: inline-block;
      background: linear-gradient(135deg, #FF4D8C 0%, #D4006A 100%);
      color: #ffffff !important;
      text-decoration: none;
      font-size: 15px;
      font-weight: 600;
      padding: 16px 40px;
      border-radius: 50px;
      letter-spacing: 0.3px;
      box-shadow: 0 4px 16px rgba(255,77,140,0.35);
    }

    .link-fallback {
      text-align: center;
      font-size: 12px;
      color: #888888;
      margin-top: 12px;
      word-break: break-all;
    }

    .link-fallback a {
      color: #FF4D8C;
    }

    /* Divider */
    .divider {
      height: 1px;
      background: #EEEEEE;
      margin: 28px 0;
    }

    /* RSVP note */
    .rsvp-note {
      background: #F8F8F8;
      border-left: 3px solid #FF4D8C;
      border-radius: 0 12px 12px 0;
      padding: 14px 18px;
      font-size: 13px;
      color: #555555;
      line-height: 1.5;
      margin-bottom: 28px;
    }

    /* Footer */
    .footer {
      text-align: center;
      padding: 24px 0 8px;
    }

    .footer-brand {
      font-family: 'Playfair Display', Georgia, serif;
      font-size: 18px;
      font-weight: 700;
      color: #BBBBBB;
      margin-bottom: 6px;
    }

    .footer-text {
      font-size: 11px;
      color: #BBBBBB;
      line-height: 1.6;
    }

    @media (max-width: 480px) {
      .card { padding: 28px 24px; }
      .header { padding: 36px 24px 32px; }
      .header-names { font-size: 28px; }
      .cta-button { padding: 14px 32px; }
    }
  </style>
</head>
<body>
  <div class="wrapper">

    <!-- Header -->
    <div class="header">
      <p class="header-eyebrow">You're cordially invited</p>
      <h1 class="header-names">{{ $names }}</h1>
      @if($weddingDate)
      <p class="header-date">{{ $weddingDate }}</p>
      @endif
      <span class="header-heart">💍</span>
    </div>

    <!-- Card -->
    <div class="card">

      <p class="greeting">Hi {{ $guest->first_name }},</p>

      <p class="body-text">
        We're so happy you'll be part of our special day! Your personal invitation is ready —
        everything you need is in one place.
      </p>

      <!-- Details -->
      <div class="details-block">
        @if($weddingDate)
        <div class="details-row">
          <span class="details-icon">📅</span>
          <div>
            <div class="details-label">Date</div>
            <div class="details-value">{{ $weddingDate }}</div>
          </div>
        </div>
        @endif

        @if($wedding->venue_name)
        <div class="details-row">
          <span class="details-icon">📍</span>
          <div>
            <div class="details-label">Venue</div>
            <div class="details-value">{{ $wedding->venue_name }}</div>
            @if($wedding->venue_address)
            <div style="font-size:13px; color:#888; margin-top:2px;">{{ $wedding->venue_address }}</div>
            @endif
          </div>
        </div>
        @endif

        @if($guest->plus_one_allowed)
        <div class="details-row">
          <span class="details-icon">🎟</span>
          <div>
            <div class="details-label">Plus one</div>
            <div class="details-value">You're welcome to bring a guest</div>
          </div>
        </div>
        @endif
      </div>

      <!-- RSVP note -->
      <div class="rsvp-note">
        Please RSVP using your personal link below so we can plan ahead for you.
        @if($guest->plus_one_allowed)
        Let us know if your plus one will be joining too.
        @endif
      </div>

      <!-- CTA -->
      <div class="cta-wrapper">
        <a href="{{ $guestLink }}" class="cta-button">
          Open my invitation →
        </a>
      </div>

      <p class="link-fallback">
        Button not working? Copy this link:<br />
        <a href="{{ $guestLink }}">{{ $guestLink }}</a>
      </p>

      <div class="divider"></div>

      <p class="body-text" style="font-size:14px;">
        Your link is personal — please don't share it with others.
        If you have any questions, reply to this email and we'll get back to you.
      </p>

      <p class="body-text" style="font-size:14px; margin-bottom:0;">
        With love,<br />
        <strong>{{ $names }}</strong>
      </p>

    </div>

    <!-- Footer -->
    <div class="footer">
      <div class="footer-brand">Udo</div>
      <p class="footer-text">
        This invitation was sent because you were added to {{ $names }}'s wedding.<br />
        This link is unique to you and gives access to your personalised experience.
      </p>
    </div>

  </div>
</body>
</html>
