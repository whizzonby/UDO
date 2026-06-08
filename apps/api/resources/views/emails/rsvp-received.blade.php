<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>RSVP received</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #FAF0EC; font-family: 'DM Sans', sans-serif; color: #333; -webkit-font-smoothing: antialiased; }
    .wrapper { max-width: 520px; margin: 0 auto; padding: 32px 16px; }
    .card { background: #fff; border-radius: 20px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.06); }

    .top-bar {
      height: 6px;
      background: linear-gradient(90deg, #FF4D8C, #D4006A);
    }

    .body { padding: 36px 36px 28px; }

    .icon-row { text-align: center; margin-bottom: 20px; }
    .icon-circle {
      display: inline-flex; align-items: center; justify-content: center;
      width: 56px; height: 56px; border-radius: 50%;
      font-size: 26px; line-height: 1;
    }
    .icon-attending { background: #D1FAE5; }
    .icon-declined  { background: #FEE2E2; }
    .icon-maybe     { background: #FEF3C7; }

    h1 { font-family: 'Playfair Display', serif; font-size: 22px; color: #333; text-align: center; margin-bottom: 6px; }
    .sub { text-align: center; font-size: 14px; color: #888; margin-bottom: 28px; }

    .guest-card {
      border: 1px solid #EEE;
      border-radius: 14px;
      padding: 18px 20px;
      margin-bottom: 20px;
    }
    .guest-name { font-size: 17px; font-weight: 600; color: #333; margin-bottom: 4px; }
    .guest-email { font-size: 13px; color: #888; margin-bottom: 12px; }

    .status-pill {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }
    .pill-attending { background: #D1FAE5; color: #065F46; }
    .pill-declined  { background: #FEE2E2; color: #991B1B; }
    .pill-maybe     { background: #FEF3C7; color: #92400E; }
    .pill-pending   { background: #F3F4F6; color: #6B7280; }

    .detail-row { display: flex; gap: 8px; margin-top: 10px; font-size: 13px; color: #666; align-items: flex-start; }
    .detail-label { font-weight: 600; color: #333; min-width: 90px; }

    .footer { text-align: center; padding: 20px 36px 28px; border-top: 1px solid #EEE; }
    .footer-brand { font-family: 'Playfair Display', serif; font-size: 16px; color: #CCC; margin-bottom: 4px; }
    .footer-text { font-size: 11px; color: #CCC; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="card">
      <div class="top-bar"></div>
      <div class="body">

        <div class="icon-row">
          <div class="icon-circle {{ $guest->rsvp_status === 'attending' ? 'icon-attending' : ($guest->rsvp_status === 'declined' ? 'icon-declined' : 'icon-maybe') }}">
            {{ $guest->rsvp_status === 'attending' ? '🎉' : ($guest->rsvp_status === 'declined' ? '😢' : '🤔') }}
          </div>
        </div>

        <h1>{{ $guest->first_name }} {{ $label }}</h1>
        <p class="sub">New RSVP response on your Udo wedding page</p>

        <div class="guest-card">
          <div class="guest-name">{{ $guest->full_name }}</div>
          @if($guest->email)
          <div class="guest-email">{{ $guest->email }}</div>
          @endif

          <span class="status-pill pill-{{ $guest->rsvp_status }}">
            {{ ucfirst($guest->rsvp_status) }}
          </span>

          @if($guest->dietary_requirements)
          <div class="detail-row">
            <span class="detail-label">Dietary</span>
            <span>{{ $guest->dietary_requirements }}</span>
          </div>
          @endif

          @if($guest->plus_one_allowed)
          <div class="detail-row">
            <span class="detail-label">Plus one</span>
            <span>
              @if($guest->plus_one_rsvp_attending)
                Joining — {{ $guest->plus_one_name ?? 'name not provided' }}
              @else
                Not bringing a plus one
              @endif
            </span>
          </div>
          @endif
        </div>

        <p style="font-size:13px; color:#888; text-align:center; line-height:1.6;">
          Check your Udo dashboard for the full guest list and response details.
        </p>

      </div>
      <div class="footer">
        <div class="footer-brand">Udo</div>
        <p class="footer-text">Wedding management platform</p>
      </div>
    </div>
  </div>
</body>
</html>
