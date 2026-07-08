Redesign and fully build out the Guests section of the Udo app to production-level quality. This is not a light polish. This is a full UX, UI, structure, and interaction overhaul. The final result must feel intentional, premium, calm, modern, feminine-neutral, highly usable, and aligned with the refined Udo aesthetic already established across the updated Home and Plan pages.

The design language must feel like quiet luxury wedding software. It should feel organized, emotionally calming, and operationally sharp. The user should feel guided, not overloaded. Every page must clearly show what it is for, what the next step is, and what action the user should take. Reduce cognitive clutter. Use clear section headers, short supporting descriptions, soft cards, elegant spacing, and highly legible interfaces. Nothing should feel cramped, random, repetitive, or unfinished.

Very important: every button must lead somewhere real. Every tab must work. Every card with an arrow must open a proper subpage or modal. Every CTA must open a destination screen. Every secondary action must also work. Do not leave placeholders, dead ends, blank states without purpose, or “coming soon” patterns. If a page introduces a new sub-flow, build the next page too. If a modal has a save button, create the saved state. If a page has preview, create the preview screen. If a card says edit, create the edit screen. If a page says publish, create the publish confirmation state. The whole Guests section should feel like a complete working product.

Use the refined Udo color system consistently:

Background: warm off-white / soft ivory
Cards: white or blush-tinted white
Primary green: deep elegant green for headings, active tabs, key confirmations, selected states
Accent pink: muted dusty rose for CTAs, highlights, attention states, and soft accent chips
Text: dark charcoal for primary text, warm grey for secondary text
Borders: very light taupe / soft grey
Avoid harsh white, harsh black, neon green, or candy pink

Typography:

Serif for major section titles and important elegant headings only
Clean sans serif for body, tabs, buttons, fields, labels, chips, and data
Headings should feel premium and editorial, but all functional UI must be ultra legible
No cheap-looking logo lockup. Improve the “Udo” wordmark feel in the section header to align with the more premium direction already discussed across the app

Spacing and layout:

Use generous vertical spacing between major sections
Keep internal card padding consistent and breathable
Use grouped modules with explanatory subtitles
Avoid massive empty dead space
Avoid overpacking too much information into one card
Use rounded corners consistently
Keep all layouts mobile-first, but polished enough that they could also scale to tablet/web views

Bottom nav remains consistent with the rest of the app:
Home | Plan | Guests | Live | Gallery | More

Top Guests tabs must be redesigned and rebuilt as:

Overview
Guest List
Invitations
Guest Experience
Messages
Guest Logistics

Remove the old tab naming and structure entirely where relevant. Specifically:

Replace “Guests” tab with Overview
Replace “Landing page” tab with Guest Experience
Replace “Seating & Logistics” concept with Guest Logistics
Remove any duplicate seating planning logic from Guests that already lives properly inside Plan. Guests can reference seating readiness or assignment status, but the main seating builder belongs under Plan. In Guests, only show guest-facing seating status or seating completeness where relevant, not a duplicate planner.

Build the following pages and subpages exactly.

PAGE 1: GUESTS → OVERVIEW

This is the command center for guest management. It should immediately surface the most important information across invitations, responses, guest experience settings, guest communication, and travel/logistics. This page should answer: what is going well, what needs attention, and what the user should do next.

At the top of the page, show the page title Guests in refined serif styling with calm authority. Under the tab row, include a one-line helper sentence such as:
“Keep your guest list, responses, and guest experience beautifully organized in one place.”

Under that, create a prominent primary CTA row:

Primary pink button: Add or Invite Guest
Secondary outlined button: Import Guests
Optional tertiary text link or smaller action: Preview guest website

All three buttons must work.

Under the action row, show overview stats in a 2x2 card grid:

Total Guests
Confirmed
Awaiting RSVP
Needs Attention

Each stat card should have:

large number
label
one-line explanatory text
subtle semantic color treatment where relevant
Examples:
Confirmed uses green accent
Awaiting RSVP uses muted pink accent
Needs Attention uses blush card background with pink number

Tapping each stat card must filter into the relevant destination:

Total Guests → Guest List with All selected
Confirmed → Guest List filtered to Attending
Awaiting RSVP → Invitations or Messages reminder flow depending on context, but preferably opens a filtered Responses state within Guest List
Needs Attention → a focused action list screen or filtered Guest List showing missing meal details, missing travel info, missing contact info, or pending RSVP

Below the stat grid, create a card called What matters most right now. This should feel like an intelligent assistant summary. Include 2–3 short sentences tailored to current guest status. Example:
“Based on current guest progress, the most helpful next steps are collecting remaining RSVPs, confirming meal choices, and completing travel details for guests flying in.”

Under that summary place 2–3 large pill CTAs:

Go to pending RSVPs
Review meal details
Review travel details

Each CTA must lead to a real page:

pending RSVPs → filtered Guest List or reminder workflow
review meal details → filtered Guest List showing guests with meal fields missing or incomplete
review travel details → Guest Logistics filtered to guests marked travelling or with incomplete travel data

Below that, create a card called Guest readiness. This should visually show progress bars for:

RSVP status
Meal information
Travel details
Seating assignment visibility if relevant to guest-facing experience only

This must not be the seating planner. This is only a readiness tracker. Include ratios like 86/120. Use green for healthy completion and dusty pink for incomplete or attention-needed progress bars.

Below that, create a card called Recent activity with concise timeline items:

“14 invitations sent today”
“3 guests updated meal preferences”
“2 guests opened their invite link”
“Wedding party access rules updated”

Each item can have timestamp and icon. Clicking opens the relevant destination.

Below that, create a card called Preview guest views. This is critical. It should show 4 preview chips:

Attending Guest
Travelling Guest
Wedding Party
Pending Guest

Tapping any chip opens the corresponding preview mockup screen. This preview section is important because the founder wants the CTO to understand exactly what the guest-facing website/link experience looks like.

PAGE 2: OVERVIEW → ADD OR INVITE GUEST MODAL / PAGE

This flow must make sense operationally. Do not force everything into manual entry. Build the flow around two paths:

Quick Invite
Manual Add

At the top of the modal or page, explain the difference:
“Invite guests with a personalized link so they can fill in their own details, or add someone manually if you prefer to manage their RSVP yourself.”

Use a toggle or two-option segmented control.

Path A: Quick Invite

Fields:

Guest name
Email address
Phone number
Preferred send method chips: Email / SMS / WhatsApp
Guest tag: Family / Friends / Colleagues / Wedding Party / VIP / Custom

Under fields, include helper text:
“Best for most guests. They will receive a personalized link to RSVP, add travel details, meal preferences, and view wedding information.”

Primary CTA: Send invite link
Secondary CTA: Save without sending

If phone only is entered, SMS or WhatsApp options should still be available.
If email only is entered, email option should still work.
If both are entered, allow either or both.

After sending, show a confirmation state:
“Invite sent. You can track opens, responses, and reminders from Invitations.”

Path B: Manual Add

Fields:

Name
Email
Phone
RSVP status dropdown
Plus one count
Meal preference
Notes
Tag
Travelling? yes/no
Accommodation known? yes/no
Arrival date
Departure date

Add a subtle in-flow reminder:
“Tip: You can still send this guest a personalized link later if you want them to complete their own details.”

Primary CTA: Save guest
Secondary CTA: Save and send invite later

PAGE 3: GUESTS → GUEST LIST

This is the operational list view. It should be clear, filterable, and fast to use.

Top helper sentence:
“View, filter, and manage every guest in your wedding plan.”

Action row:

Add or Invite Guest
Import Guests
Export List

Search bar placeholder:
“Search by name, email, phone, or tag”

Under search, place filter chips:

All
Attending
Pending
Declined
Travelling
Needs attention
Wedding party
Family
Friends
Custom tags

These chips must scroll horizontally cleanly and not get cut off awkwardly. Fix the current broken chip layout. Ensure proper side padding and horizontal scroll behavior.

Each guest card should show:

Name
email or phone or both
status pill
meal pill
plus one pill if applicable
travel indicator if travelling
small subtle “missing details” badge if incomplete
right-side arrow to open guest detail page

Guest card tap opens full guest profile page.

At top right or via overflow, add bulk actions:

Send reminder
Add tag
Export
Mark manually
Assign to event visibility group
PAGE 4: GUEST PROFILE PAGE

This page must be fully built out because every arrow from the guest list needs a destination.

Sections:

Basic details
RSVP & plus ones
Meals
Travel & stay
Access & visibility
Invite history
Notes

Basic details:

Name
Email
Phone
Tag
Relationship group

RSVP:

attending / pending / declined
invite sent date
opened invite date
responded date
plus one count

Meals:

dietary preference
selected meal
allergies
notes

Travel & stay:

travelling yes/no
arrival date
departure date
airport
hotel
transport need
notes

Access & visibility:
Which events and sections this guest can see:

Ceremony
Reception
Rehearsal Dinner
Wedding Party Morning Schedule
Travel Details
Registry
Message Board

Invite history:

invite sent via email
reminder sent via SMS
link opened
no response yet

Bottom actions:

Send invite link
Send reminder
Edit guest
Mark manually
Remove guest

All buttons must work.

PAGE 5: GUESTS → INVITATIONS

This page is for invitation design, sending, and tracking. It should not be just one static card. It needs a real production flow.

Top helper sentence:
“Preview, send, and track invitations in one place.”

Top CTA row:

Send Invitations
Preview Invite
Invitation Settings
Invitations page section A: Invitation Preview

Show a polished card preview of the invitation design. Make it feel elegant and mobile-friendly. Include:

couple names
date
location
a short line of invitation text
optional quote or subtitle
refined typography and balanced spacing

Under the preview, buttons:

Preview invitation
Edit invitation content
Change theme
Invitations page section B: Send invitations

Provide sending options:

Send by email
Send by SMS
Send by WhatsApp
Copy guest invite link

Do not make this feel repetitive. Use grouped cards, not giant empty buttons with no context.

Invitations page section C: Invitation tracking

Metrics:

sent
delivered
opened
responded
bounced/failed

Below metrics, show a list of recent invite activity:

Sarah Johnson opened invite 1h ago
Michael Chen responded yes
Emily Rodriguez failed delivery, missing number

Include CTA:

Resend failed invites
PAGE 6: INVITATIONS → EDIT INVITATION CONTENT

This page lets user edit what is shown in the invitation itself.

Fields:

Invitation title line
Couple names
Invitation text
Date
Time
Venue
City
Optional quote
RSVP deadline
Dress code snippet
Cover image optional
Theme preset selector
Font preset selector

Add preview panel live on the same screen or side-by-side in mobile stacked form.

At bottom:

Save changes
Preview invitation
Send test invite to self

All must work.

PAGE 7: INVITATIONS → CHANGE THEME

This page is critical because the founder does not want guests limited to green and pink only.

Create a curated theme selector, not infinite customization. Present 6 premium presets:

Classic Ivory
Soft Rose
Botanical Green
Modern Minimal
Champagne Neutral
Evening Black Tie

Each preset shows:

header color
accent color
button style
sample typography combo

Below themes, allow:

serif heading font selector
sans body font selector

Limit to curated combinations only so the design remains premium.

Button:

Apply theme

Then preview update.

PAGE 8: INVITATIONS → PREVIEW INVITATION MODAL

When previewing the invitation, show how it opens on mobile. It should feel like a guest receives a link and opens a beautiful wedding microsite, not a raw dashboard screen.

Structure:

invitation card hero
elegant intro
RSVP CTA
dress code snippet
date and venue

Include action at bottom:

Open full guest website preview

This leads into Guest Experience preview.

PAGE 9: GUESTS → GUEST EXPERIENCE

This page controls what guests see when they open their personalized link. It currently feels good in concept but too overwhelming. Rebuild it with clearer explanation, stronger grouping, and calmer hierarchy.

Top helper sentence:
“Shape what your guests see, what they can access, and how they experience your wedding details.”

Add a short 2-step guidance strip at the top:

Choose what information is visible
Preview how each guest type will experience it

Then split the page into four clearly titled modules.

Module A: Page Setup

Subtitle:
“Control the main sections shown on the guest website.”

Use elegant toggle rows, but grouped and explained. Not one endless dump of settings. Group into:

Essentials
Show couple photo
Show wedding story
Show schedule
Show dress code
Travel & Stay
Show venue map
Show nearby hotels
Show transport details
Show flight guidance
Interaction
Enable RSVP
Enable message board
Show registry
Allow guest questions

Each group gets a short explanation sentence.

Module B: Access by Guest Type

Subtitle:
“Customize what different guest groups can see.”

Cards with arrows:

Attending Guest
Travelling Guest
Wedding Party
Pending Guest

Each opens its own preview and rule editor.

Module C: Website Preview

This is extremely important. Show a framed mobile website mockup card inline on the page. Add segmented preview tabs:

Attending Guest
Travelling Guest
Wedding Party
Pending Guest

Above it include:
“This is what your guests will see when they open their personalized link.”

The preview must update per segment.

Buttons:

Preview full website
Edit website structure
Publish updates
Module D: Website Templates

Subtitle:
“Choose the overall style of the guest-facing website.”

Show theme tiles:

Soft Editorial
Modern Romance
Botanical
Neutral Classic
Minimal Chic

Each tile previews:

hero style
card style
accent color
typography feel

Button:

Apply template
PAGE 10: GUEST EXPERIENCE → GUEST TYPE RULE EDITOR

Build subpages for:

Attending Guest
Travelling Guest
Wedding Party
Pending Guest

Each page must begin with a short explanation sentence so it feels less overwhelming.

Example:

Attending Guest
“This guest has confirmed attendance and should see the final wedding details relevant to them.”

Then show grouped settings:

Can view ceremony details
Can view reception details
Can view map
Can view schedule
Can view registry
Can post on message board
Can see travel recommendations
Can see dress code

Repeat appropriate versions for other guest types.

Pending Guest should have a more minimal view and primarily prompt RSVP.
Travelling Guest should surface travel, hotels, airport, and transport.
Wedding Party should include extra event access, rehearsal dinner, arrival times, private notes, and special schedules.

At bottom:

Save audience settings
Preview this audience
PAGE 11: GUEST EXPERIENCE → FULL GUEST WEBSITE PREVIEW

This must be one of the most polished parts of the flow. Build a full guest-facing microsite mockup to show the CTO what the link opens into.

This should look like a beautiful mobile wedding webpage inside the app/browser, not an admin screen.

Structure:

Hero
Couple names
date
city
elegant hero card or image
optional cover photo
Action buttons
Add to calendar
Open in maps
View schedule
Personalized content block

Depending on guest type:

Pending Guest: RSVP prompt prominently shown
Travelling Guest: hotel + transport + airport info shown
Wedding Party: rehearsal dinner + call time shown
Attending Guest: confirmed schedule and event info shown
Sections
Your Events
Travel & Stay
Dress Code
Venue
Registry if enabled
Message Board if enabled

Everything should feel like a clean mobile landing page / micro-site.

No awkward empty cards. No duplicate data. No random bullet dots. No dead blank sections.

PAGE 12: GUEST EXPERIENCE → WEBSITE STRUCTURE EDITOR

This is where the user customizes what appears in the guest website in a more editorial flow.

Modules:

Hero section
Story section
Schedule section
Travel section
Dress code section
Registry section
Message board section

For each, allow:

show/hide
short intro text
reorder handles if possible

At bottom:

Save structure
Preview website
Publish updates
PAGE 13: GUESTS → MESSAGES

Rename mental framing from passive inbox to communication center.

Top helper sentence:
“Send updates, reminders, and guest communication without the back-and-forth.”

Top action row:

Compose Message
Send Reminder
View Message History

Then create three modules.

Module A: Smart Alerts

Subtitle:
“Use quick actions to communicate based on guest status.”

Alert cards:

18 guests have not RSVP’d → Send reminder
12 travelling guests still need hotel details → Send travel reminder
Wedding party schedule updated → Notify wedding party
7 guests missing meal choices → Send meal request

Each card has one clear CTA button.

Module B: Audience Messaging

Show segment chips:

All guests
Pending RSVP
Wedding party
Travelling guests
Family
Friends
Custom tag groups

Tapping a chip updates the compose screen context.

Module C: Messages from guests

This is where the warm inbound notes live.
Show messages from guests as soft cards:

name
message snippet
timestamp

Allow tap to open conversation/detail.

PAGE 14: MESSAGES → COMPOSE MESSAGE

Fields:

Audience selector
Channel selector: Email / SMS / WhatsApp / In-app
Subject
Message body
Include RSVP link toggle
Include map link toggle
Include schedule link toggle

At top, show summary:
“This message will be sent to 18 pending guests.”

Buttons:

Send now
Save draft
Send test to self

Add message template chips:

RSVP reminder
Meal reminder
Travel update
Schedule change
Welcome message

Each chip pre-fills the content.

PAGE 15: MESSAGES → SEND RSVP REMINDER MODAL

This already exists conceptually, but refine it.

Show:

number of recipients
when last reminder was sent
subject
message body
include RSVP link checkbox

Buttons:

Cancel
Send reminder

After send, show success confirmation.

PAGE 16: GUESTS → GUEST LOGISTICS

This replaces Seating & Logistics. Seating is not the main structure here. This page is about guest movement and stay planning.

Top helper sentence:
“Track where guests are coming from, where they are staying, and what support they need to arrive smoothly.”

Overview stat cards:

Travelling Guests
Flights Added
Hotels Selected
Transport Needs

Then split into modules.

Module A: Travel Readiness

Show progress summary:

arrival dates collected
departure dates collected
flights added
hotel status
transport assigned
Module B: Guests Needing Logistics

Filtered list of guests marked travelling or missing logistics. Each guest row shows:

name
city/airport if known
arrival/departure if known
hotel status
transport status
needs attention badge if missing

Tap opens guest logistics detail page.

Module C: Hotel & Stay Setup

Summary card showing:

recommended hotels selected
room block note if used
booking links available

Button:

Edit hotel recommendations
Module D: Transport Setup

Summary card showing:

shuttle routes configured
pickup points
airport transfer info

Button:

Edit transport details
PAGE 17: GUEST LOGISTICS → GUEST LOGISTICS DETAIL PAGE

This is guest-specific logistics.

Sections:

Arrival airport
arrival date/time
departure date/time
hotel
booking status
shuttle needed
pickup notes
travel notes

Add note near flight section:
“Guests can update these details themselves after booking through their personalized link.”

Buttons:

Save
Send travel reminder
Open guest preview
PAGE 18: GUEST LOGISTICS → EDIT HOTEL RECOMMENDATIONS

This page should be useful and clean.

Fields:

Wedding city
Venue name
Venue address

Search action:

Find hotels near venue

Results list card format:

hotel name
distance
price level
select button

Below selected hotels, allow manual hotel entry:

hotel name
address
booking link
notes

Allow one hotel to be tagged:

Recommended
Budget option
Luxury option
Closest option

Bottom:

Save changes
Preview as travelling guest
PAGE 19: GUEST LOGISTICS → EDIT TRANSPORT DETAILS

Fields:

Shuttle name or route name
pickup location
departure time
return time
notes
who sees this? travelling guests / wedding party / custom group

Allow multiple transport options to be added.

Include airport transfer section:

nearest airport
recommended arrival window
suggested routes
travel note textarea

Include toggle:

Display transport options to guests

Buttons:

Save changes
Preview as travelling guest
PAGE 20: GUEST EXPERIENCE / PREVIEW → TRAVELLING GUEST VERSION

This preview must show:

hero
buttons for calendar/maps/schedule
personalized events
hotel recommendations
transport details
nearest airport
location card
dress code if enabled

No weird empty bullet placeholders. No blank transport rows. No redundant seating logic.

Use soft grouped sections with clear subtitles:

Your Events
Travel & Stay
Transport
Getting There
Location
PAGE 21: GUEST EXPERIENCE / PREVIEW → PENDING GUEST VERSION

This preview must clearly prioritize RSVP first.

Layout:

hero card
date/location
3 action buttons
main card:
“RSVP to view your personalized schedule”
RSVP Now CTA
simple teaser of event details, not full access until RSVP if that is the chosen rule

Bottom action row in admin preview:

Copy guest link
Publish updates
PAGE 22: GUEST EXPERIENCE / PREVIEW → WEDDING PARTY VERSION

This preview should include extra access:

rehearsal dinner
private call times
special morning instructions
venue details
schedule buttons
travel info if relevant

This view should feel like privileged access, but still polished and simple.

PAGE 23: GUEST EXPERIENCE / PREVIEW → ATTENDING GUEST VERSION

This preview should show:

full confirmed event schedule
map access
dress code
venue
registry if enabled
guest message board if enabled
PAGE 24: PAGE SETTINGS REDESIGN

The current settings stack is too flat and overwhelming. Replace the endless generic toggle list with grouped, described settings.

Structure:

Essentials

Short line: “These are the core details most guests need.”

couple photo
story
event schedule
dress code
Travel & Stay

Short line: “Helpful for guests travelling to your wedding.”

venue map
nearby hotels
transport details
flight guidance
Interaction

Short line: “Let guests respond and engage.”

enable RSVP
enable message board
show registry
allow guest questions

Each row should have:

label
one-line explainer
toggle

Not just raw labels.

PAGE 25: OVERVIEW → IMPORT GUESTS

Build simple import flow:

upload CSV
paste from spreadsheet
import from contacts mock state if desired

Map fields:

name
email
phone
tag
plus ones
notes

After import:

preview imported rows
confirm import
PAGE 26: GUEST LIST → BULK ACTIONS PANEL

For selected guests allow:

Send invite
Send reminder
Tag guests
Assign visibility group
Mark RSVP manually
Mark meal collected
Export selected
PAGE 27: DESIGN / USABILITY RULES TO APPLY ACROSS ALL GUESTS PAGES

Apply these rules everywhere:

Every screen must include a short explanatory subtitle under major titles or section headings where complexity exists.
Every arrow opens a real destination.
Every CTA opens a real destination.
Every modal has both open state and saved state.
Every preview must show an actual mockup, not just text labels.
Avoid repeating seating planner functionality from Plan.
Use chips, cards, and grouped modules to reduce overwhelm.
Eliminate dead white space.
Keep all components aligned with the updated calm premium Udo design system.
Ensure guest-facing experiences look elegant in browser, SMS link, and email-linked contexts.
Invitation links and guest website previews should feel like polished mobile microsites.
Any area that allows customization must also show a preview.
Any “publish” action must have a confirmation state:
“Guest website updated successfully.”
Any “send” action must have a confirmation state:
“Invitation sent” / “Reminder sent” / “Message scheduled”
PAGE 28: BUTTON DESTINATION RULE

This is mandatory and non-negotiable:
If a button exists, build its destination.
If a card has an arrow, build its destination.
If a tab exists, build its page.
If a modal has Save, show the saved state.
If a preview exists, show what is being previewed.
Do not leave any placeholder interactions or dead-end buttons.

FINAL INSTRUCTION TO FIGMA

Do not simplify these instructions. Do not compress multiple functions into vague cards. Build each page, subpage, modal, and preview screen in full. The Guests section should feel like a complete, premium, real product system that reduces stress and increases clarity for the couple while creating a polished and personalized experience for guests.