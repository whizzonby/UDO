FINAL FIGMA PROMPT — UDO GUESTS SECTION OVERHAUL
Premium, complete, production-level rebuild of the Guests module

Redesign and fully build out the Guests section of the Udo app so it is no longer a loose collection of tabs and partial screens. It must become a complete, beautiful, calm, usable guest management system that feels premium, emotionally intelligent, and immediately valuable. It should match the improved Home and Plan pages in tone, color system, spacing, polish, and visual rhythm. It must feel like it belongs to the same product family.

The Guests module should make the user feel one thing immediately:

“My guests are handled. I am not chasing anyone. I am in control.”

Do not build a shallow admin dashboard. Do not create decorative screens with dead buttons. Do not leave placeholder pages. Do not use “coming soon.” Do not leave any button without a designed result. If something can be clicked, it must open a designed subpage, modal, panel, filter state, or action state.

The system must be clear enough that if this were handed to a CTO, they would understand what the intended product behavior is from the screens alone.

GLOBAL VISUAL AND UX RULES

The Guests section must follow the exact product direction we have now established for Udo:

calm
premium
organized
soft
readable
refined
feminine without being childish
modern and lightly editorial

Use the established palette:

warm ivory / off-white base backgrounds
white cards
soft blush / pale rose accents
deep muted green for structure and confident emphasis
dark charcoal for headings and important text
warm greys for secondary text

Use the exact same level of polish as the Home and Plan pages:

rounded cards
soft shadows only
no harsh borders
high readability
no washed-out text
no large areas of empty useless whitespace
no awkward alignment
no visual clutter

All headings should feel intentional. All secondary copy should feel calming and helpful. Avoid robotic phrasing and avoid patronizing language. Avoid “take a breath.” Avoid cheesy language. The tone should feel like an elegant, thoughtful assistant.

Every page must have:

a clear page title
a short 1-sentence explanation under the title
a clearly visible primary action if appropriate
at least one meaningful interaction
a back button if it is a subpage

Every screen must feel complete.

INFORMATION ARCHITECTURE FOR THE GUESTS MODULE

The current guest area feels too fragmented. The rebuilt structure should contain these top-level tabs within the Guests module:

Overview
Guest List
Invitations
Guest Experience
Messages
Seating & Logistics

These tabs must all be fully designed. No empty tabs. No half-built tabs. No tab should simply repeat another tab with slightly different wording. Each one should serve a distinct purpose.

The flow should feel sensible:

Overview tells me the state of my guest system
Guest List lets me manage actual people
Invitations lets me send and track invites
Guest Experience lets me design what guests see
Messages handles communication
Seating & Logistics handles the operational side

This must feel like one connected system, not six unrelated tools.

PAGE 1 — GUESTS OVERVIEW

This page should be the main control center for guest-related planning. The user should land here and understand immediately:

how many guests are in the system
how many have confirmed
who still needs attention
whether travel, seating, and meal issues exist
what the next logical guest-related action is

The page should not feel busy. It should feel like a premium dashboard with just enough information to create control without overwhelm.

Header area

At the top, keep the Udo brand treatment consistent with the rest of the app. Use the refined “UDO” wordmark treatment that matches the updated direction. The page title should be:

Guests

Directly underneath, include this short explanatory sentence:

Keep your guest list, responses, and guest experience beautifully organized in one place.

This copy should sit beneath the heading in a warm, readable grey. It should not feel overly small or faint.

To the right or top-right, include a primary blush-toned button:

Add Guest

This button must work. When clicked, it must open a fully designed Add Guest modal.

Add Guest modal

The Add Guest modal must feel like a real mini-form the user could use today. It should not be a generic placeholder. The modal title should be:

Add a new guest

Under the title, include a short helper sentence:

Add guest details now so you can manage RSVPs, seating, travel, and communication later without the back-and-forth.

The modal must contain these fields in this order:

Full Name — text input, required
Email Address — text input
Phone Number — text input
Guest Group — dropdown with options such as Family, Friends, Wedding Party, Colleagues, Other
Dietary Preference — dropdown with options like None, Vegetarian, Vegan, Gluten-free, Nut allergy, Seafood allergy, Halal, Kosher, Other
Plus One — toggle labeled “This guest has a plus one”
If Plus One is turned on, reveal a field labeled Plus One Name
Travelling — toggle labeled “This guest is travelling”
If Travelling is turned on, reveal:
Hotel / Stay Needed — yes/no selector
Transport Needed — yes/no selector

At the bottom of the modal, place two buttons:

Cancel
Save Guest

When Save Guest is clicked, the modal should close, the guest should visibly appear in the Guest List, the summary cards on the Overview page should update, and a soft confirmation toast should appear at the bottom saying:

Guest added successfully

Summary cards

Below the header, create a row or responsive grid of summary cards. These cards must feel consistent with the Home page cards: soft, elevated, clean, and premium. Each card should have a title, a metric, and a short explanatory line.

The cards should be:

Total Guests

This card shows the total number of guests currently added. Under the number, include:
All guests in your wedding list

Confirmed

This card shows guests who have RSVP’d yes. Under the number, include:
Guests who have confirmed attendance

Awaiting RSVP

This card shows guests who have not yet responded. Under the number, include:
Guests still waiting to respond

Needs Attention

This card is especially important. It should look slightly more attention-worthy than the others without feeling alarming. Under the number, include:
Guests requiring follow-up or missing details

When the Needs Attention card is clicked, it should expand into a filtered action panel rather than navigating away immediately.

Needs Attention expansion panel

Clicking the Needs Attention card must open or expand a panel directly below the cards. This panel should list specific guest-related issues as action rows. Each row must be clickable and take the user to a filtered view in the Guest List.

Rows should include:

Guests without RSVP
Guests missing meal selections
Guests without seating assigned
Guests missing email addresses
Travelling guests without hotel information
Travelling guests without transport assignment

Each row should have a small explanatory line in lighter text and a chevron on the right. Example:
Guests without RSVP
These guests still need to respond before you can finalise seating and meals.

“Most important right now” card

Under the summary area, add a calm recommendation card similar in spirit to the “Today with Udo” logic from the Home page, but guest-specific. The title should be:

What matters most right now

Under that, include dynamic-style copy such as:
Based on your current guest progress, the most helpful next steps are collecting remaining RSVPs and confirming meal choices for travelling guests.

Include two small buttons:

Go to pending RSVPs
Review meal details

These buttons must work and take the user to the correct filtered page or section.

Guest readiness card

Below that, add a visual card called:

Guest readiness

This card should show a progress bar or completeness indicator with sub-items like:

RSVP status
Meal information
Travel details
Seating assigned

This card should feel like a quick health check of the guest system. Include one insight sentence beneath it such as:
Most guests are progressing well, but meal and travel details still need attention.

Clicking the card should take the user to a more detailed readiness breakdown page or a filtered Guest List.

PAGE 2 — GUEST LIST

This page should feel like the actual working list of people. It should not feel like a spreadsheet, but it should feel efficient and structured. It must be easy to scan, filter, search, and act on.

Header

Title:
Guest List

Subtext:
View, filter, and manage every guest in your wedding plan.

On the right, include:

Add Guest
Import Guests (secondary action)

Both must work. Import Guests can open a modal offering CSV import or copy-paste entry, even if simplified visually.

Search and filters

Under the header, include a search bar with this placeholder:
Search by name, email, phone, or tag

Next to or under the search, include filter chips:

All
Attending
Pending
Declined
Travelling
Needs attention
Wedding party
Family
Friends

These chips must be interactive. Clicking one should visibly change the list. This cannot be decorative.

Guest list rows

Each guest row should be a refined horizontal card with:

Guest name in bold
Email underneath
Optional phone in smaller text
Status pill (Attending / Pending / Declined)
Tags such as +1, Dietary, Travelling, Wedding Party
On the right: chevron and a three-dot menu

The three-dot menu should open a small action menu with:

View profile
Edit guest
Delete guest
Send invitation
Send message

Every one of these menu actions must open something meaningful.

Guest profile subpage

Clicking a row or “View profile” should open a full Guest Profile page.

Title:
Guest Profile

Subtext:
Everything you know about this guest, in one place.

The page should include distinct sections, each in its own card or clearly separated block:

Personal details

Fields:

Full Name
Email
Phone Number
Group

With an Edit details button that opens a modal for editing these fields.

RSVP

A clean attendance toggle:

Attending
Declined
Pending

Add a line below:
This status affects meal tracking, seating, and reminders.

Meal information

Dropdown or chips for meal preference. If none selected, show:
No meal preference selected yet
Button:
Update meal preference

Plus One

Show whether a plus one exists. If yes, show the name. If not, show:
No plus one added
Button:
Add or edit plus one

Travel & stay

This section must show:

Travelling: Yes / No
Hotel assigned: Yes / No
Transport assigned: Yes / No

If missing info, surface it clearly:
Travel details are still incomplete
Button:
Update travel details

Notes

A freeform notes area with:
Add notes
or if filled:
Edit notes

Action buttons at bottom
Save changes
Send message
Assign seating
Remove guest

Every button must work. Assign seating must open a seating selector. Send message must open Compose Message with this guest preselected. Remove guest must trigger a confirmation modal.

PAGE 3 — INVITATIONS

This page must handle the sending, previewing, and status of invitations. It should not just be a dead “copy link” panel.

Header

Title:
Invitations

Subtext:
Preview, send, and track invitations in one place.

At the top right, include:

Send Invitations
Preview Invite

Both must work.

Invite preview section

Create a clean preview card that shows a realistic invitation layout. Include:

Couple names
Date
Venue / City
A short invitation line
A visible RSVP button or link preview

This should visually communicate the style of the invite. Do not make it too decorative or too fake. Keep it elegant and modern.

Below the preview, include:

Edit invitation
Preview full invitation

The full preview must open a separate full-screen invite page view.

Send Invitations modal

When “Send Invitations” is clicked, open a modal titled:

Send invitations

Include:

Recipient selection area with filters:
All guests
Pending only
Custom selection
Subject field
Message body field
Toggle:
Include RSVP link
Toggle:
Include guest page link

Buttons:

Cancel
Send now
Schedule send

Each button must lead to a designed result. Schedule send should open a date/time picker state.

Invitation status area

Below the preview section, include an invitation status block that shows:

Not sent
Sent
Opened
RSVP completed

This can be visualized as four small summary cards or a progress tracker. Include one short intelligence sentence:
Most guests have received their invite, but a smaller group still has not responded.

Add:
Send reminder to pending guests
This button must open the compose/reminder flow.

PAGE 4 — GUEST EXPERIENCE

This page is critical. It should function as a Guest Experience Builder, not a vague “landing page settings” screen.

Header

Title:
Guest Experience

Subtext:
Shape what your guests see, what they can access, and how they experience your wedding details.

This page should clearly communicate that the user is building a branded guest-facing experience, not a website in the traditional sense. It should feel premium and intentional.

Template selector

At the top of the builder, include a section called:

Choose your guest page style

Templates:

Minimal
Destination
Luxury
Traditional

Each template should have a thumbnail and a short descriptor. Selecting a template must visibly change the live preview.

Builder layout

This page should use a split or staged layout:

Left side or top section: content blocks / controls
Right side or lower section: live preview

The builder must feel modular.

Content blocks

Include draggable cards for these blocks:

Welcome Message
Couple Story
Schedule
RSVP
Travel & Stay
Map & Directions
Dress Code
Registry
Message Board
FAQ

Each block card must contain:

Title
Small 1-line description
Toggle ON/OFF
Drag handle
Edit button

Clicking Edit must open a specific modal for that section.

Example: Welcome Message edit modal

Title:
Edit Welcome Message

Fields:

Headline
Body text
Cover image upload
Show couple names toggle

Buttons:

Cancel
Save changes
Example: Travel & Stay edit modal

Title:
Edit Travel & Stay

Fields:

Hotel name
Hotel address
Booking link
Notes
Show transport section toggle

Buttons:

Cancel
Save changes
Guest preview

The preview area must look like a real guest-facing page. It should not be a blank phone shell. It should clearly show:

Header image / wedding image
Couple names
Main event date
Visible blocks based on settings

At the top of the preview, include toggles:

View as attending guest
View as pending guest
View as guest with plus one

Switching the mode must alter visible content in the preview.

Guest page actions

At the bottom of this page, include action buttons:

Preview full guest page
Copy guest page link
Publish updates

All must work. Copy link must trigger a visual success message. Publish updates must trigger a success state and imply that guests now see the changes.

PAGE 5 — MESSAGES

This page must feel like a communication center, not just an empty thread view.

Header

Title:
Messages

Subtext:
Send updates, reminders, and guest communication without the back-and-forth.

At top right:
Compose Message

This button must open a full Compose Message page or modal.

Message summary cards

Add small summary cards for:

Messages sent this week
Pending reminders
Scheduled messages
Unread guest replies

These should not be fake metrics if fake data is removed; use structural placeholders like “—” or clearly neutral sample system states if needed, but do not invent unrealistic numbers.

Compose Message screen

Title:
Compose Message

Subtext:
Choose who should receive this message and send it now or later.

Sections:

Recipients

Options:

All guests
Pending RSVP guests
Confirmed guests
Travelling guests
Custom selection
Message body

Text area with placeholder:
Write your update here

Optional settings
Include event schedule
Include guest page link
Schedule for later

Buttons:

Cancel
Send now
Schedule send

Each must work. Schedule send opens a date/time picker state.

Message list

Below the compose area or on the main Messages page, create a list of sent messages. Each message row should show:

Subject / message title
Recipient group
Sent date/time
Delivery status

Clicking a message opens a detail screen showing the full message body and recipient breakdown.

Quick actions

At the top or side, include smart action buttons:

Send RSVP reminder
Send travel update
Send final guest update

Each must open a prefilled compose flow.

PAGE 6 — SEATING & LOGISTICS

This page must combine guest placement and travel logistics into one operational space.

Header

Title:
Seating & Logistics

Subtext:
Organise where guests go, how they get there, and what still needs to be arranged.

Seating summary cards

Show:

Tables created
Guests seated
Guests unassigned
Guests with travel needs

Each card must be clickable where appropriate.

Seating layout section

This must be more than a list. It should feel like an actual seating planning tool.

Include:

A left filter panel or toolbar with:
All guests
Unassigned
Wedding party
Family
Travelling
Dietary needs
A seating canvas or table list area

Each table card should show:

Table name
Seat capacity
Number assigned
Edit button

Clicking a table opens a table detail page.

Table detail page

Title:
Table Name

Show:

Guests assigned
Seats remaining
Add guest button
Reorder guests if needed

Add:
Add guest to table
This opens a guest selector modal.

Logistics section

This must have two subsections:

Hotels
Transport Groups
Hotels subsection

List all hotels being used. Each hotel card should show:

Hotel name
Address
Number of guests assigned
Edit button

Add button:
Add hotel

This opens a modal with:

Hotel name
Address
Booking link
Notes
Transport Groups subsection

List all transport groups. Each group should show:

Group name
Pickup location
Time
Number of assigned guests

Add button:
Create transport group

This opens a modal with:

Group name
Pickup point
Pickup time
Notes

Every action must have a result.

EMPTY STATES ACROSS THE MODULE

Every page must have a thoughtful empty state if there is no data.

Examples:

Guests page empty state

No guests added yet
Start building your guest list so you can keep invitations, responses, and seating in one place.
Button: Add your first guest

Invitations empty state

No invitations sent yet
When you are ready, send your invitations and start collecting responses.
Button: Send invitations

Guest Experience empty state

No guest experience created yet
Build a beautiful guest-facing page your guests can use to RSVP, view details, and stay updated.
Button: Start building

Messages empty state

No messages yet
Send your first update when you are ready to communicate with guests.
Button: Compose message

Seating empty state

No seating plan created yet
Once guests begin confirming, start shaping where everyone will sit.
Button: Create seating plan

FINAL SYSTEM RULES

Every page and subpage must visibly communicate:

what this page is for
what the user can do here
what the primary action is
what the next step should be if nothing has been set up yet

There must be no generic filler. No dead controls. No vague mini-panels that do not lead anywhere.

The Guests module should feel like a complete, premium subsystem inside the Udo app.

The end result should make a user feel:

“This is not just a guest list. This is guest control, guest communication, and guest experience handled beautifully.”