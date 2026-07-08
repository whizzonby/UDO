🎯 FIGMA BUILD PROMPT — GUEST LOGISTICS (PRODUCTION READY)
🧠 CORE PURPOSE OF THIS PAGE (NON-NEGOTIABLE)

This page exists to answer ONE question:

👉 “Which guests are at risk of having a bad arrival experience, and how do I fix it immediately?”

Everything on this page must support:

Identification of issues
Prioritization
Immediate resolution

If a component does not serve that purpose → remove it.

🎨 DESIGN SYSTEM (STRICT — DO NOT DEVIATE)
COLORS (SYSTEMIZED, NOT RANDOM)
Primary Action Green: #1F4D2B
Used ONLY for:
Primary buttons
Completed states
Positive indicators
Soft Green Background: #E8F3EC
Used for:
Completed sections
Success containers
Alert Rose (IMPORTANT): #C75C6F
Used ONLY for:
Missing information
Urgent alerts
Risk states
Soft Alert Background: #F9EDEE
Used for:
Alert containers
Action center background
Neutral Background: #F7F7F5
Card Background: #FFFFFF
Borders: #E5E5E5
TYPOGRAPHY
Headers: Playfair Display
Body: Inter

Sizing:

Page Title: 28px
Section Title: 22px
Card Title: 16px–18px
Metadata: 13px
SPACING SYSTEM
Page padding: 24px
Section spacing: 32px
Card padding: 20px
Internal spacing: 12px–16px
Border radius: 16px
🧱 PAGE STRUCTURE (TOP → BOTTOM)
🔴 SECTION 1 — LOGISTICS ACTION CENTER (TOP PRIORITY ENGINE)
PURPOSE

Immediately surface:
👉 What is broken + what needs action now

CONTAINER DESIGN
Full-width card
Background: #F9EDEE
Padding: 20px
Rounded corners: 16px
HEADER

Title:
Logistics Action Center

Subtitle:
“Immediate actions required to ensure all guests arrive smoothly”

CONTENT STRUCTURE

Horizontal scroll (mobile) / grid (desktop)

Each card = one actionable problem

CARD TEMPLATE (MANDATORY)

Each card must include:

LEFT
Icon (inside soft rose circle)
CENTER
Title (problem statement)
Subtext (why it matters)
RIGHT
CTA button (green)
EXAMPLES (REAL DATA DRIVEN)
CARD 1

Title:
“8 guests arriving in 72 hours without transport”

Subtext:
“These guests may not reach the venue on time”

CTA:
Assign transport

CARD 2

Title:
“14 guests have no hotel assigned”

Subtext:
“They may struggle with accommodation planning”

CTA:
Assign hotels

CARD 3

Title:
“6 guests missing flight details”

Subtext:
“Arrival timing cannot be coordinated”

CTA:
Request details

INTERACTION RULES
Clicking card (not button):
→ Filters Section 4 (Guest List)
Clicking CTA:
→ Opens modal with pre-filtered guests
🟡 SECTION 2 — LOGISTICS OVERVIEW (PROBLEM-FOCUSED KPIs)
PURPOSE

Provide snapshot of issues, not totals

LAYOUT

2x2 grid of cards

CARDS
CARD 1

Label: Flights Missing
Value: 8 guests
Color: Rose

Click:
→ Filter guests missing flights

CARD 2

Label: Hotels Not Assigned
Value: 14 guests

CARD 3

Label: Transport Not Assigned
Value: 12 guests

CARD 4

Label: Fully Ready
Value: 18 guests
Color: Green

INTERACTION

ALL cards clickable → filter guest list

🟢 SECTION 3 — TRAVEL READINESS TRACKER
PURPOSE

Show progress across logistics dimensions

STRUCTURE

Single card with stacked progress rows

ROW FORMAT

Left: Label
Center: Progress bar
Right: Value (28/32)

ROWS
Arrival dates collected
Departure dates collected
Flights added
Hotels assigned
Transport assigned
COLOR LOGIC
80–100% → Green
50–79% → Neutral
<50% → Rose
INTERACTION

Click row → filters guests

🔵 SECTION 4 — GUESTS REQUIRING ACTION (CORE WORK AREA)
PURPOSE

This is where work happens

HEADER

Title: Guests Requiring Attention
Subtitle: “Grouped by urgency and missing logistics”

GROUPING (MANDATORY)
GROUP 1 — 🔴 URGENT

Criteria:

Arriving within 72 hours
Missing ANY key detail
GROUP 2 — 🟠 MISSING KEY INFO

Criteria:

Missing flight / hotel / transport
GROUP 3 — 🟡 PARTIAL

Criteria:

Some details missing but not urgent
GUEST CARD DESIGN
LEFT
Avatar circle (initials)
Name
Origin (e.g. “New York, JFK”)
CENTER (3-COLUMN GRID)
Arrival: Jun 14
Hotel: Pending / Confirmed
Transport: Assigned / Not set
RIGHT
Status badge:
🔴 Needs attention
🟠 Missing details
🟢 Ready
Action buttons:
Request info
Assign hotel
Arrange transport
INTERACTIONS
Clicking guest card:

→ Opens Guest Logistics Drawer

Drawer includes:

Full guest details
Editable fields
Messaging shortcut
Clicking “Request info”:

→ Opens messaging modal with pre-filled message

Clicking “Assign hotel”:

→ Opens hotel selection modal

Clicking “Arrange transport”:

→ Opens transport assignment modal

🟣 SECTION 5 — HOTEL & STAY SETUP
PURPOSE

Central place to manage accommodation

CONTENT
“3 hotels selected”
“14 guests unassigned”
CTA

👉 Assign hotels to guests

INTERACTION

Opens modal:

List of hotels
Multi-select guest assignment
🟤 SECTION 6 — TRANSPORT SETUP
PURPOSE

Manage movement logistics

CONTENT
“12 guests require transport”
“8 seats configured”
CTA

👉 Edit transport plan

INTERACTION

Opens:

Shuttle builder
Assign guests to vehicles
🧠 GLOBAL UX REQUIREMENTS (CRITICAL)
1. FILTER STATE MUST BE VISIBLE

When filtering:

Show chip at top:
👉 “Filtered by: Missing flights”

2. BULK ACTION BAR

When guests selected:

Sticky bottom bar appears:

Send message
Assign hotel
Assign transport
3. ALL BUTTONS MUST LEAD SOMEWHERE

No dead buttons allowed

4. SMART SUGGESTIONS (OPTIONAL BUT HIGH VALUE)

Add:

“5 guests arriving same time → group transport”
“3 guests booked same hotel”
🔗 DATA FLOW (IMPORTANT FOR CTO)
Inputs:
Guest list
RSVP data
Travel info
Hotel selection
Transport assignments
Outputs:
Filtered guest sets
Messaging triggers
Assignment updates
Dependencies:
Messaging system
Guest profile system
Invitations system
🎯 FINAL EXPERIENCE

User opens page → immediately sees:

What is broken
Who is impacted
What to do

Clicks once → fixes it

🔥 FINAL NOTE

If built correctly:

👉 This page becomes:
Your strongest product differentiator

Because no wedding tool:

Structures logistics this clearly
Connects data → action this tightly