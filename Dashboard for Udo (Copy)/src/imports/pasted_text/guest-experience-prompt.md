🎯 FULL FIGMA PROMPT — GUEST EXPERIENCE + INVITE + LIVE UPDATE SYSTEM (PRODUCTION LEVEL)
🧱 FRAME SETUP + GRID SYSTEM

Create a mobile-first frame (390 x 844 iPhone) and a desktop frame (1440 x 1024).

Use an 8pt spacing system:

Micro spacing: 4px
Standard spacing: 8, 16, 24px
Section spacing: 32–48px

Grid:

Mobile: 4 columns
Desktop: 12 columns

All components must be built as reusable Auto Layout components.

🎨 DESIGN SYSTEM (TOKENS — MUST BE CONSISTENT)
Colors

Primary (Action):

Deep Green: #2F5D50

Secondary (Accent themes — swappable):

Dusty Rose: #C68484
Champagne: #D6BFA9
Soft Lilac: #BFAFD3

Backgrounds:

Page background: #FAF9F7
Card background: #F3ECE8
Elevated card: #FFFFFF

Text:

Primary: #1F1F1F
Secondary: #6B6B6B

Borders:

#E6DFDA
Typography
Heading Large: Playfair Display (32–36px)
Heading Medium: Playfair Display (24px)
Body: Inter (14–16px)
Labels: Inter Medium (12px uppercase)
Components (DEFINE FIRST)

Create reusable components:

Primary Button (Filled)
Secondary Button (Outlined)
Ghost Button
Toggle Switch
Tag/Chip (with states)
Card (3 variants: flat, elevated, interactive)
Input Field
Modal Container
Bottom Sheet (mobile)
🧭 PAGE: GUEST EXPERIENCE BUILDER (PLANNER SIDE)
🟢 SECTION 1 — HERO PREVIEW (TOP OF PAGE)

This is a sticky component on desktop and first visible on mobile.

Layout
Full-width container
Rounded corners (20px)
Soft shadow
Padding: 24px
Header Row

Left:
👉 “Guest Experience Preview”

Right:

Toggle: Mobile | Web
Toggle: Guest Type:
Attending
Travelling
Wedding Party
Pending
Preview Container (CRITICAL)

This is NOT static.

👉 It must be a nested frame simulating the actual guest web page

Inside Preview (STRUCTURE)
Wedding Hero Card
Names (Playfair, centered)
Date + location
Soft background (theme dependent)
Action Buttons Row
Add to Calendar
Open in Maps
View Schedule
Conditional Sections (must appear/disappear based on toggles below):
Events list
Dress code
Travel & stay
Gallery preview
Message board preview
INTERACTION RULE

Every toggle on this page:
👉 Must update this preview instantly (simulate real system)

🟡 SECTION 2 — EXPERIENCE BUILDER (CONTENT CONTROL)
Title

“What Guests Will See”

Subtitle:
“Turn sections on or off. Changes update instantly in preview.”

STRUCTURE (DO NOT USE LONG LIST — USE GROUP CARDS)

Each group is its own card:

🟤 CARD 1: Event Information

Contains toggles:

Show schedule
Show venue map
Show dress code

Each row:

Label
Description (1 line)
Toggle (right aligned)
🟤 CARD 2: Visual Experience
Show couple photo
Show wedding story
Enable gallery uploads
🟤 CARD 3: Interaction
Enable RSVP
Enable message board
Enable live updates popup (IMPORTANT)
🟤 CARD 4: Travel & Stay
Show nearby hotels
Show transport details
Show travel notes
INTERACTION

When toggle changes:
👉 Immediately reflect in preview (hide/show section)

🔵 SECTION 3 — ACCESS CONTROL (WHO SEES WHAT)
Title

“Guest Access Rules”

Subtitle:
“Control which guests can see specific events or information”

LIST ITEMS

Each item:

Event name
Current visibility (tag style)
Chevron →
ON CLICK → OPEN MODAL
🧩 MODAL: ACCESS CONTROL

Layout:

Title: “Edit Access”
Event name at top
Multi-select chips:
All Guests
Wedding Party
Family
Travelling Guests
Custom Tag
SAVE BUTTON

On save:

Update label on parent screen
Update preview (critical)
🟣 SECTION 4 — LIVE UPDATES SYSTEM
Title

“Live Updates”

Subtitle:
“Send real-time updates that guests see instantly”

PRIMARY BUTTON

👉 “+ Create Update”

🧩 MODAL: CREATE UPDATE
Fields:
Title (optional)
Message body (required)
Audience selector:
All
Travelling
Wedding party
Custom
Delivery Methods (checkboxes):
Push to guest page (popup)
SMS
WhatsApp
Email
SEND BUTTON
SYSTEM BEHAVIOR (IMPORTANT)

If guest has page open:
👉 Popup appears immediately

If not:
👉 Stored in updates feed

🔴 POPUP DESIGN (GUEST SIDE)
Appearance
Bottom slide-up (mobile)
Center modal (desktop)
Rounded (20px)
Soft shadow
Content
Title
Message
Timestamp
CTA (optional)
Behavior
Auto appears
Can dismiss
Stored in “Updates” tab
🌐 GUEST LINK EXPERIENCE (WEB)
ENTRY STATE

User clicks link →

Landing page loads:

Screen 1: Invite Landing
Wedding hero card
CTA:
RSVP Now
View Details
SCREEN 2: MAIN GUEST EXPERIENCE
STRUCTURE
Header (names + date)
Action buttons:
Calendar
Maps
Schedule
Sections (conditional):
Events
Travel
Gallery
Messages
Updates
NAVIGATION (BOTTOM OR TABS)
Home
Schedule
Updates
Gallery
Messages
🔔 LIVE UPDATE SYSTEM (CRITICAL INTERACTION)

When update sent:

IF PAGE OPEN:
👉 popup appears instantly

IF PAGE CLOSED:
👉 notification badge appears

🎨 INVITATION TEMPLATE SYSTEM
TEMPLATE SELECTOR MODAL

Show 4 templates:

Classic Elegant
Modern Minimal
Tropical Destination
Editorial Luxury

Each preview card shows:

Font style
Layout style
Colour scheme
CUSTOMIZATION PANEL

Allow user to:

Change primary colour
Change font pairing
Edit text
PREVIEW BEHAVIOR

👉 Must update live

🔘 BUTTON LOGIC (EVERY BUTTON MUST WORK)
Planner Side
Preview Invite → opens full-screen preview
Send Invitations → opens delivery modal
Change Theme → opens theme selector
Send Reminder → opens update modal
Edit Travel → opens logistics editor
Guest Side
RSVP → opens RSVP flow
Add to Calendar → exports .ics
Maps → opens Google Maps
Updates → opens feed
Gallery → opens upload/view
Messages → opens message board
🧠 FINAL UX PRINCIPLE

The experience must feel like:

👉 “I am designing my wedding experience for guests in real time”

NOT:

👉 “I am filling out settings”

🔥 FINAL PRODUCT POSITIONING

If built correctly, this becomes:

👉 A live, interactive guest operating system
👉 Not just a wedding planner