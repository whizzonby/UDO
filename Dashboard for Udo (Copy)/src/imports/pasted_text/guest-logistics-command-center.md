🎨 FIGMA PROMPT — GUEST LOGISTICS (COMMAND CENTER LEVEL)
🟢 PAGE NAME:

Guests → Guest Logistics (Command Center)

🧠 DESIGN INTENT (VERY IMPORTANT — DO NOT SKIP)

This page is not a dashboard. It is a decision-making and execution hub.

The design must:

Surface what is broken first
Show who is impacted
Allow immediate action without friction
Reduce cognitive load through grouping and prioritization

The user should feel:
👉 “I know exactly what needs to be handled next”

🎨 DESIGN SYSTEM (STRICT)
Colors:
Primary Green: #1F4D2B (actions, confirmed states)
Soft Green Background: #E8F3EC
Accent Rose: #C75C6F (alerts, missing info)
Soft Rose Background: #F9EDEE
Neutral Background: #F7F7F5
Card Background: #FFFFFF
Border: #E5E5E5
Text Primary: #1A1A1A
Text Secondary: #6B6B6B
Typography:
Headers: Playfair Display (elegant)
Body: Inter / SF Pro
Section titles: 22–26px
Card titles: 16–18px
Metadata: 13–14px
Spacing System:
Page padding: 24px
Section spacing: 28–32px
Card padding: 16–20px
Card gap: 12–16px
Border radius: 16px
Shadows: soft, minimal (0px 4px 12px rgba(0,0,0,0.04))
🧱 PAGE STRUCTURE (TOP → BOTTOM)
🔴 SECTION 1: LOGISTICS ACTION CENTER (HIGHEST PRIORITY)
Container:

Full-width card with subtle rose background (#F9EDEE)

Title:

Logistics Action Center

Subtitle:

“Immediate actions required to ensure all guests arrive smoothly”

Layout:

Grid of 3–4 horizontally scrollable cards (or 2x2 grid on desktop)

Card Structure (each alert):
Example Card:

Icon (left):
Red alert icon inside soft rose circle

Title:
“8 guests arriving within 3 days without transport”

Subtext:
“These guests may face delays getting to the venue”

Right side CTA button:
Primary green button:
👉 “Assign transport”

Required Alert Cards:
Flights missing
Hotels not assigned
Transport not arranged
Arrival within 72 hours without full details
Behavior:
Clicking card filters guest list below
CTA opens modal or side panel
🟡 SECTION 2: LOGISTICS HEALTH OVERVIEW
Title:

Logistics Overview

Subtitle:

“High-level readiness across travel, stay, and transport”

Layout:

4 KPI cards (2x2 grid)

Cards (REPLACE current ones):
✈️ Flights Missing
Value: “8 guests”
Color: Rose
CTA: “View guests”
🏨 Hotels Not Assigned
Value: “14 guests”
Color: Rose
🚐 Transport Not Assigned
Value: “12 guests”
Color: Rose
✅ Fully Ready Guests
Value: “18 guests”
Color: Green
Interaction:

ALL cards clickable → filter guest list

🟢 SECTION 3: TRAVEL READINESS TRACKER
Title:

Travel Readiness

Subtitle:

“Track progress across key logistics inputs”

Layout:

Stacked progress bars inside a card

Each row:

Label (left):
“Arrival dates collected”

Progress bar (middle):
Green or rose depending on completion

Value (right):
“28 / 32”

Bars Required:
Arrival dates
Departure dates
Flights added
Hotels assigned
Transport assigned
Behavior:

Each row clickable → filters guests

🔵 SECTION 4: GUESTS NEEDING ACTION (CORE ENGINE)
Title:

Guests Requiring Attention

Subtitle:

“Grouped by urgency and missing logistics”

Structure:

Split into 3 groups:

🔴 Group 1: Urgent (Arriving Soon)

Guests arriving within 72 hours with missing details

🟠 Group 2: Missing Key Info

No flight / hotel / transport

🟡 Group 3: Partial Completion

Some details filled, not all

Guest Card Design:

Horizontal card with 3 sections:

LEFT:
Avatar circle with initials
Name
Location (e.g. “New York, JFK”)
CENTER:

3-column mini grid:

Arrival: Jun 14
Hotel: Pending / Confirmed
Transport: Assigned / Not set
RIGHT:
Status badge:
🔴 Needs attention
🟠 Missing details
🟢 Ready
Action buttons:
“Request info”
“Assign hotel”
“Arrange transport”
Behavior:

Clicking card opens:
👉 Guest Logistics Detail Drawer (side panel)

🟣 SECTION 5: HOTEL & STAY MANAGEMENT
Title:

Hotel & Stay Setup

Card Content:
“3 hotels selected”
“14 guests unassigned”
CTA:

👉 “Assign hotels to guests”

Interaction:

Opens modal:

Hotel list
Bulk assign guests
🟤 SECTION 6: TRANSPORT MANAGEMENT
Title:

Transport Setup

Card Content:
“12 guests require transport”
“8 seats configured”
CTA:

👉 “Edit transport plan”

Inside modal:
Shuttle routes
Capacity
Assign guests
🧠 CRITICAL UX REQUIREMENTS
1. EVERYTHING MUST BE CLICKABLE
KPI cards → filter
Progress bars → filter
Guest cards → detail view
Alerts → action modal
2. FILTER STATE MUST BE VISIBLE

When user clicks something:

Show:
👉 “Filtered by: Missing Flights”

3. BULK ACTION BAR

When multiple guests selected:

Show sticky bottom bar:

“Send message”
“Assign hotel”
“Request info”
4. SMART SUGGESTIONS (OPTIONAL BUT POWERFUL)

Add AI suggestions:

“3 guests arriving same time → group transport”
“These 5 guests staying same hotel”
🌐 CONNECTED FLOW (VERY IMPORTANT)
When clicking:

“Request info”
→ Opens messaging modal pre-filled:
“Hi, please share your flight details…”

When clicking:

“Assign hotel”
→ Opens hotel selection modal with guest pre-selected

When clicking:

“Assign transport”
→ Opens transport allocation screen

🎯 FINAL EXPERIENCE GOAL

When user opens this page:

They should:

See problems immediately
Click once
Fix instantly
🔥 FINAL NOTE TO FIGMA / DESIGN SYSTEM
Use soft elegance, not clutter
Avoid heavy borders
Use spacing to create calm
Keep everything breathable
Prioritize clarity over decoration