🎨 FIGMA PROMPT — LIVE PAGE (Wedding Day + Pre-Day Experience)
🧠 OVERALL DESIGN INTENT (READ FIRST)

Design a “Live Page” that functions as a calm, intelligent reassurance layer, not a control dashboard. Every element must reduce cognitive load, remove uncertainty, and avoid overwhelming the user. The interface should feel like a soft, premium assistant, not a system shouting updates.

The tone is:

Gentle
Reassuring
Minimal but informative
Emotionally aware

The UI must never feel urgent, aggressive, or clinical, even when displaying important information.

🎨 COLOR SYSTEM (NON-OFFENSIVE, PREMIUM, UNIVERSAL)

Define colors as variables in Figma:

Primary Neutral Background

#F8F7F4 (soft warm white)

Card Background

#FFFFFF

Primary Accent (Calm Green — NOT harsh)

#2F5D50 (muted eucalyptus green)

Secondary Accent (Soft Rose — very subtle)

#E8CFCF (only for highlights, not dominant)

Text Primary

#2B2B2B

Text Secondary

#6F6F6F

Success / Calm Status

#3A7D6D

Soft Warning (not alarming)

#D6A77A

Critical (very muted, never bright red)

#C97C7C

Borders

#EAE7E2

Shadows

Very soft: 0px 4px 12px rgba(0,0,0,0.04)

⚠️ RULE:
No saturated greens, no harsh pinks, no neon colors. Everything must feel timeless and neutral across cultures and tastes.

🧱 PAGE STRUCTURE (VERTICAL FLOW)

Create a scrollable mobile-first frame (390px width or 1440px desktop variant depending on context).

Sections must appear in this exact order:

1️⃣ HEADER SECTION (ANCHOR)
Layout:

Full-width soft green banner (Primary Accent, slightly desaturated using 90% opacity overlay)

Height: ~120px

Content:

Top left:

“Live” (icon + text)
Subtext: “Your day, gently guided”

Below centered:

Dynamic reassurance text:

“Everything is flowing beautifully today.”
Alternate states:
“Your ceremony is coming together perfectly.”
“Guests are arriving smoothly.”

Typography:

Serif heading (Playfair Display or similar)
Large, elegant, 24–28px
2️⃣ STATUS CARD (CRITICAL — MUST FEEL CALM)
Card Style:
Rounded corners: 16px
Padding: 20px
Background: white
Shadow: soft
Content:

Left:

Small circular icon (soft green background)

Main text:

“No action needed right now”

Subtext:

“Your planner and vendors are handling everything.”

Alternate states:

🟡

“One small update being handled”
Subtext: “No action needed from you”

🔴

“A delay is being handled”
Subtext: “Everything is under control”

⚠️ IMPORTANT:
Never show “YOU need to fix something”

3️⃣ RIGHT NOW SECTION
Title:

“Right now”

Card:

Three stacked rows:

Row format:
Left label, right aligned value

Current time → “4:12 PM”
Current moment → “Guests arriving”
Guest readiness → “Most guests have arrived”

⚠️ Replace percentages with human language

4️⃣ COMING UP NEXT (MINIMAL TIMELINE)
Title:

“Coming up next”

Cards:

Stacked, max 2–3 items

Each card:

Event name
Time
Countdown (right aligned)

Example:

Ceremony begins — 4:30 PM — “in 18 minutes”

Design:

Soft background tint (#F3EFEA)
Rounded
Calm spacing
5️⃣ QUIET CONFIRMATIONS (HIDDEN COMPLEXITY)
Title:

“Everything in place”

Layout:

Checklist-style cards

Each item:
✔ Vendors ready
✔ Seating prepared
✔ Guests informed

Optional microcopy:
“Handled for you”

6️⃣ WEATHER (ONLY IF RELEVANT)
Card:
Large temperature
Condition
Icon (minimal, soft)

Subtext:
“Perfect conditions for your ceremony”

Avoid raw data overload.

7️⃣ SMART UPDATES (PASSIVE, NOT DEMANDING)
Title:

“Updates sent”

Cards:
“Guests notified of ceremony start”
“Reminder sent to wedding party”
“Transport updates shared”

Each with timestamp (small, subtle)

8️⃣ EMERGENCY CONTACTS (SOFT + COLLAPSIBLE)
Collapsed by default

Title:
“Your support team”

Expand shows:

Planner
Venue manager
Key contact

Each row clickable → opens call/message options

🔁 NAVIGATION TABS (TOP OR SECONDARY)

Tabs:

Today (default active)
Timeline
Map
Weather
Updates
Interaction:

Each tab switches view within same page (no reload)

🔗 BUTTON INTERACTIONS (ALL MUST WORK)

Every element must be clickable:

Status Card

→ Opens “Details modal”
Shows backend explanation (for planner-level insight, optional)

Timeline Cards

→ Opens full schedule page

Updates

→ Opens update history modal

Emergency Contacts

→ Opens contact sheet with:

Call
WhatsApp
Message
🌐 GUEST VIEW (CRITICAL REQUIREMENT)

When guest opens link:

They see a web-optimized version of THIS page, simplified:

Include:

Event info
Timeline
Updates
Map
RSVP (if enabled)

Exclude:

Internal logistics
Status indicators meant for bride
🧠 UX RULES (NON-NEGOTIABLE)
No clutter
No more than 2–3 items per section
Use whitespace generously (24–32px spacing between sections)
Every label must feel human, not technical
Replace metrics with meaning
✨ MICROCOPY (VERY IMPORTANT)

Sprinkle gentle phrases across the page:

“Today is yours.”
“Everything is taken care of.”
“Just enjoy this moment.”
“Your day is unfolding beautifully.”

Use sparingly, not everywhere.

📱 FINAL EXPERIENCE GOAL

When the bride opens this page, she should feel:

Calm
In control without doing anything
Reassured that nothing is falling apart
Guided, not managed