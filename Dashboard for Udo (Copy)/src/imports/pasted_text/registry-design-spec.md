🎨 FIGMA PROMPT — UDO REGISTRY (FULL SYSTEM WITH THANK-YOU + AUTO-REMINDERS)
🧠 OVERALL PRODUCT INTENT

Design a frictionless, emotionally warm registry system that feels:

Effortless to set up (under 2 minutes)
Elegant and non-commercial
Smart in the background (tracking + reminders handled quietly)
Helpful after the wedding (thank-you management)

This is not a “gift registry.”

This is:

A giving + gratitude system

🎨 GLOBAL DESIGN SYSTEM
Color System

Background:

#F8F7F4 (warm ivory)

Primary:

#2F5D50 (deep calming green)

Accent:

#E8CFCF (soft blush)

Success:

#DCEFE6

Warning:

#F5E6D8

Text:

Primary: #2B2B2B
Secondary: #6F6F6F

Borders:

#EAE7E2
Typography

Headers:

Playfair Display (soft, romantic)

Body:

Inter / SF Pro
Spacing System
Section spacing: 32px
Card padding: 24px
Grid gap: 16px
Border radius: 16px
🧱 PAGE 1 — REGISTRY (EMPTY STATE / SETUP)
Layout

Centered column
Max width: 720px

SECTION 1: HEADER

Left aligned:

Title:
Registry

Subtext:
“Create a simple, meaningful way for guests to give”

SECTION 2: HERO SETUP CARD

Centered card:

Title:
“Set up your registry in seconds”

Subtext:
“Add gifts, contributions, or simply share your wishes”

Below → 3 primary actions

SECTION 3: ACTION CARDS

3 equal cards (grid or stacked)

1. CASH FUND

Title:
“Contribute to our future”

Subtext:
“Honeymoon, home, or something meaningful”

CTA:
Set up fund

2. ADD LINK

Title:
“Add something you love”

Subtext:
“Paste a link from any store”

CTA:
Add item

3. SIMPLE WISHLIST

Title:
“Create a wishlist”

Subtext:
“Add gifts without links”

CTA:
Create list

All buttons → open modals

🔁 MODALS
CASH FUND MODAL

Fields:

Fund name
Description
Target (optional)

CTA:
Save fund

ADD LINK MODAL

Fields:

URL input

Auto-fetch preview:

Image
Title
Price

Editable:

Title
Note

CTA:
Add item

CUSTOM ITEM MODAL

Fields:

Name
Optional price
Note

CTA:
Save item

🧱 PAGE 2 — REGISTRY (ACTIVE STATE)
SECTION 1: HEADER CARD

Left:
“Your registry”

Right:

Share registry
Add item
SECTION 2: CASH FUND CARD
Title
Description
Progress bar
Amount raised

CTA:
Contribute

SECTION 3: ITEMS GRID

Each item card:

Image
Title
Price

Status pill:

Available
Reserved
Gifted
SECTION 4: THANK-YOU TRACKING (NEW — CORE FEATURE)
Card Title:

Thank-you tracker

Subtext:
“Keep track of who you have thanked”

Layout:

Two tabs:

Pending thanks
Completed
Pending Card List

Each card:

Left:

Guest name
Gift given (if known)
Small note preview

Right:

Status pill: “Needs thanks”

CTA:
Mark as thanked

Secondary CTA:
Write message

Completed Card
Guest name
Date thanked
Optional message preview
Empty State (completed):

“Every guest has been thanked 💛”

🔁 THANK-YOU MODAL

When clicking “Write message”

Modal:

Fields:

Message text area

Prefilled suggestion:
“Thank you so much for your thoughtful gift…”

Buttons:

Send (optional if integrated)
Save only
🤖 AUTO-REMINDERS SYSTEM (CRITICAL)
SECTION 5: SMART REMINDERS CARD
Title:

Smart reminders

Subtext:
“We will gently remind you when needed”

Cards inside:
1. PRE-WEDDING REMINDERS

Example:

“12 guests have not contributed or viewed the registry”

CTA:
Send gentle reminder

2. POST-WEDDING REMINDERS

Example:

“18 guests still need a thank-you message”

CTA:
Review now

3. SYSTEM AUTO-REMINDER SETTINGS

Toggle options:

☑ Send RSVP-based reminders
☑ Send registry reminders
☑ Remind me to send thank-you messages

Dropdown:

Reminder tone:

Formal
Warm
Casual
AUTOMATION LOGIC (IMPORTANT FOR DEV)
Pre-wedding

Trigger if:

Guest viewed invite but no action in X days

System suggests:
“Would you like to send a gentle reminder?”

Post-wedding

Trigger:

3 days after wedding

System surfaces:
“Time to send thank-you messages”

Follow-up

Trigger:

7 days after

Reminder:
“You still have X guests to thank”

🌐 PAGE 3 — GUEST REGISTRY (WEB VIEW)
Layout

Centered
Max width: 600px

SECTION 1: HEADER

Couple names
Date
Location

SECTION 2: MESSAGE

“Your presence means everything. If you wish to gift, here are a few ideas.”

SECTION 3: CASH FUND
Title
Description
Progress

CTA:
Contribute

SECTION 4: ITEMS

Each:

Image
Title
Price

CTA:
Reserve / Mark gifted

🔁 GUEST GIFT FLOW
MODAL

Fields:

Amount / selection
Name (optional)
Message (optional)

CTA:
Send gift

SUCCESS STATE

“Thank you for your gift 💛”

🔗 SHARE FLOW
SHARE MODAL

Options:

Copy link
WhatsApp
SMS
Email

Subtext:
“Guests can view and gift instantly”

🧠 UX PRINCIPLES (NON-NEGOTIABLE)
No friction
No login for guests
Maximum 2 taps to action
Emotional tone always soft
No aggressive prompts
✨ MICROCOPY (SOFT TOUCHES)
“With love”
“A little something we would cherish”
“Gratefully received”
🚀 STRATEGIC VALUE (WHY THIS MATTERS)

This feature now:

Extends lifecycle (before + after wedding)
Creates emotional stickiness
Enables monetization later (fees, partnerships)
Positions product as end-to-end experience system
🧠 FINAL EXPERIENCE

Bride:

“This is simple”
“This is beautiful”
“This helps me after the wedding too”

Guest:

“This is easy”
“This feels thoughtful”