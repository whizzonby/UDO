Create a fully interactive, production-grade mobile dashboard and multi-page wedding planning system for UDO.

This is not a concept board.
This is not a static UI exercise.
This is a go-to-market product simulation for a premium wedding operating system.

The result must feel like:

modern
warm
premium
feminine but not childish
calming
emotionally intelligent
organized
easy to use
delightful
highly clickable
end-to-end
realistic enough that a CTO could translate it into build logic

The dashboard must reflect everything the user already selected during onboarding and allow them to:

see what matters now
edit their decisions
manage guests, people, vendors, meals, seating, events, lookbook, reminders
design and preview a guest landing page / invite page
send a shareable link
use a live wedding-day section
use crisis control
interact with maps, weather, and key logistics
feel less stressed the moment they open the app

Every page must be fully clickable.
Every major CTA must open a real next screen, drawer, bottom sheet, modal, editor, preview page, or details page.
No dead buttons.
No blank cards.
No empty nav items.

1. BRAND / VISUAL DIRECTION
Brand identity

UDO means peace.
The product should feel like peace, softness, reassurance, beauty, and intelligent structure.

Color palette

Use this exact palette consistently:

Dark green: #285301
Crimson: #d45d78
Pastel crimson: #f194b2
Light blush / light red: #f8edeb
White: #FFFFFF
How to use the palette
Backgrounds: mostly white and very light blush
Primary CTAs: crimson or deep green depending on context
Success / calm accents: dark green
Soft info cards / quote dividers / gentle emphasis: pastel crimson and light blush
Text: dark charcoal or deep green, never harsh pure black everywhere
Visual tone

Blend:

clean modern mobile UX
subtle whimsy
soft romantic polish
premium stationery energy
gentle, rounded cards
airy spacing
elegant serif headings paired with readable sans-serif body text
Typography
Headings: elegant serif
Body text: modern sans serif
Small quote nuggets: lightly styled, italic or script-accent if tasteful
Avoid overly curly fonts except in very small accents
Whimsy

Use whimsy carefully:

tiny sparkles
delicate line accents
soft hand-drawn separators
occasional romantic quote nuggets
a few cute illustrative moments
Do not make it childish or messy.
2. GLOBAL PRODUCT STRUCTURE

Create the dashboard with 6 main bottom navigation tabs:

Home
Plan
Guests
Live
Gallery
More

This information architecture is mandatory.

What each page is for
Home

A smart overview page only.
It should show:

the most important current items
next best steps
countdown
overall progress
urgent reminders
guest readiness
budget snapshot
quick actions
weather / live-event preview when close to wedding day

Do not overload Home with every planning module.

Plan

This is the main planning engine.
All major planning modules live here:

event structure
budget
priorities
food & dining
vendors
wedding party
seating
timeline
lookbook
reminders
additional events
personal moments
honeymoon
insurance
planning settings
Guests

Everything guest-facing or guest-managed:

guest list
RSVPs
meal selections
accommodation needs
transport needs
children / accessibility
communication
invite sending
landing page / guest page builder
guest previews
seating assignments
message board moderation
Live

Wedding-day control center:

run of show
timeline
weather widget
map
guest arrivals
transport status
crisis control
announcements
live updates
emergency contacts
venue notes
checklist for the day
Gallery

Lookbook + uploads + memories:

inspiration images
pinned design references
wedding moodboard
uploaded photos
guest photo submissions
post-wedding memory archive
More

Secondary settings and extra tools:

profile
collaborators
planner invite
decision-makers
notification settings
support settings
subscription / credits
help / feedback
about UDO
contact hello@udowedding.com
3. HOME PAGE — SMART WEDDING SNAPSHOT

Create a highly polished Home dashboard.

Top hero area

Show:

wedding names
wedding date
location
countdown in days
a soft reassurance line

Example:
Olivia & Aaron
142 days to go
Montego Bay, Jamaica
“Everything is coming together beautifully.”

Add a subtle decorative flourish or tiny sparkle separator.

Progress summary card

A rounded premium card titled:
Planning at a glance

Show:

overall progress percentage
guest readiness score
budget confidence
live prep status
decision-maker status

Make this card tap to a detailed overview page.

Next best steps card

Title:
Your next best steps

This is critical.

Pull from onboarding and dashboard logic:

if venue not booked, prompt venue
if guest experience options selected, show guest-related actions
if food selected but meals not set, show meal follow-up
if wedding party selected but not assigned, prompt role assignments
if vendors needed but not shortlisted, prompt shortlist
if landing page not published, prompt invite page setup

Each step should show:

title
1-line why it matters
urgency tag
CTA

Examples:

Finalize your venue shortlist
Set guest meal preferences
Add your bridesmaids and groomsmen
Publish your guest landing page
Build your seating chart
Confirm transport needs

Allow swipe gestures:

snooze
mark done
move to plan page
Priority alignment card

Pull from onboarding “What matters most to you?”

Title:
What matters most to you

Show 3–5 selected priorities:

Guest experience
Food & beverage quality
Photography & videography
Intimacy
Cultural traditions

Below that, show:
How your plan is aligning
Example:

Guest experience: in progress
Food: needs attention
Photography: not yet shortlisted

Tap opens priorities details page.

Budget snapshot card

Compact but smart:

total budget
allocated
spent
remaining
confidence level

Add a tiny insight:
“You are spending in line with your experience-focused preference.”

Tap opens full budget module.

Guest readiness card

Show:

guest count
invited / not invited
RSVP received / pending
meal responses
accommodation needed
transport needed

Add progress bar.
Tap opens Guests page.

Quick actions row

Include clickable icons or tiles:

Add guest
Send invite
Add vendor
Add payment
Build seating
Add event
Post update
Open Live view
Quote nugget

Between cards, add a soft line like:
“The best weddings feel intentional, not rushed.”

Home page near-wedding state

Also create an alternate state for when the wedding is within 14 days.

Then Home should additionally show:

weather preview
live countdown by hours/days
final checklist
emergency contacts shortcut
crisis control shortcut
guest travel readiness
4. PLAN PAGE — MAIN PLANNING HUB

This page must feel like the command center for planning.

Use a segmented top switch or filter:

Overview
Tasks
Budget
Vendors
Details

Default to Overview.

Plan Overview page content

Create modular cards with drag-and-drop reorder capability.

Modules:

Event structure
Budget & spending style
Food & dining
Vendors & suppliers
Wedding party
Seating
Timeline
Additional events
Personal moments
Honeymoon
Insurance
Lookbook
Reminders
Support settings

Each card should show:

completion state
short summary pulled from onboarding
edit CTA
details CTA
4A. Event structure module

Pull from onboarding:

wedding type
season
date status / actual date
time of day
event structure items selected

Allow edit:

date picker
add/remove events
drag order of event sequence
assign owner
add notes
mark event active/inactive

Possible events list should include:

ceremony
reception
civil ceremony
traditional ceremony
religious ceremony
welcome dinner
engagement party
rehearsal dinner
bridal shower
stag party
hen party
tea ceremony
nikah / signing
after party
brunch
farewell gathering
custom event

Each event can open to a details page:

date/time
location
guest list segment
dress code
vendors attached
reminders
notes
4B. Budget & spending style module

This must feel smart and understandable.

Show:

total budget
working budget
structure
allocation preference
funding sources
confidence

Add info buttons that open soft popups explaining:

fixed budget
flexible budget
priority-led budget
allocation preference types
confidence

Add charts:

category allocation donut
spent vs allocated bars
pending vendor costs
“at risk” spend category warning

Add editable categories:

venue
food & drink
decor
entertainment
photography
attire
transport
accommodation
gifts
stationery
other

Add action buttons:

add expense
add vendor quote
reallocate
mark paid
export summary

Add AI-style insight box:
“Based on your priorities, food and guest experience should remain protected budget areas.”

4C. Food & dining module

Pull from onboarding.

Show selected:

dining style
dietary requirements
dining enhancements

Add section explanation:
“Dining details here will also shape guest forms and meal tracking.”

Include cards:

Meal style
Dietary needs
Drink moments
Dessert moments
Pending decisions

Allow edit options:

maybe later
add menu notes
assign meal choices by guest
attach caterer
add tasting date
add bar setup
mark unresolved allergy needs

More exhaustive dietary options in editor:

vegetarian
vegan
pescatarian
halal
kosher
gluten-free
dairy-free
nut allergy
seafood allergy
egg-free
soy-free
child-friendly
low-sugar
no alcohol
custom

Dining enhancements options:

cocktail hour
champagne tower
signature cocktails
dessert table
sweet table
cake display
coffee cart
food truck
late-night snacks
interactive stations
brunch station
cultural food moment
welcome drinks
custom
4D. Vendor ecosystem module

This is a major planning center.

Show sections:

Needed
Shortlisted
Booked
Paid
Missing

Pull from onboarding:

core vendors
expanded vendors
unique suppliers

Core vendor cards:

Venue
Planner
Photographer
Videographer
Catering
Florist
Decor stylist
DJ/Band
Hair & makeup
Cake designer
Lighting
Rentals
Celebrant / officiant
Content creator
Security
Transport
Wedding website / stationery
Photo booth
AV support

Each vendor card opens a detailed page with:

vendor name
status
package / quote
deposit
balance due
due dates
notes
contact info
uploaded docs
mood fit tag
“why shortlisted”
contract uploaded toggle

Add drag-and-drop shortlist ranking.

Add filters:

Needed
Booked
Waiting decision
Paid
Priority vendors

Add insight:
“Based on your priorities, photographer and caterer should be shortlisted next.”

Info popup buttons for unique suppliers:

fireworks
drone show
live performers
cultural performers
luxury experiences
interactive installations
4E. Wedding party module

Pull from onboarding roles selected.

Display cards for:

Maid of Honour
Best Man
Bridesmaids
Groomsmen
Ushers
Flower Girl
Page Boy
Ring Bearer

Each role card can:

add names
add email
assign tasks
attach reminders
add fitting date
add rehearsal attendance
mark speech responsibility
mark bouquet / ring / seating / transport duty

Add role info popup with elegant short definition.

Allow counts and easy editing.

If empty:
show CTA:
“Add your people”

4F. Seating module

This must be cool and easy.

Title:
Seating chart

Features:

drag-and-drop tables
assign guests to seats
table naming
category color labels
family grouping
plus-one linking
children grouping
accessibility seat placement
dietary icon markers

Views:

table layout view
guest list view
unassigned guests view

Actions:

auto-group by family
auto-group by dietary needs
auto-group by RSVP confirmation
clear assignments
preview guest seating cards

This should feel visual and satisfying.

4G. Timeline module

Title:
Run of show

Show wedding timeline across:

pre-event
ceremony
reception
after party

Each item:

time
title
owner
location
notes
reminder setting

Drag-and-drop reordering.
Tap item for detail.
Add suggested buffers.
Allow “add 15-min buffer” quick button.

4H. Additional events module

Pull from onboarding:

stag
hen
engagement party
rehearsal dinner
post-wedding brunch
others

For each:

planning owner
invite status
date/time
location
notes
who is organizing
contact email
copy link / send invite
4I. Personal moments module

This should feel emotional and beautiful.

Show:

speeches planned
speakers
tribute moments
traditions
special details

Cards:

Speeches
Honouring loved ones
Cultural or family traditions
Custom moments

Each card opens into an editor.

Examples:

add who is speaking
add order of speeches
add memory table notes
add tribute timing
add symbolic rituals
add music or reading
add custom moment

Add a soft quote nugget:
“These are the moments people remember in their hearts.”

4J. Honeymoon module

Show:

yes / not yet / no
destination
budget
timing
travel style
planning status

Allow:

add passport reminders
add flight notes
add accommodation
add packing reminder
mark delayed honeymoon
4K. Insurance module

Show:

yes / no / unsure
short explanation
optional provider fields
reminder to revisit
4L. Lookbook module

This must be beautiful.

Title:
Lookbook & inspiration

Features:

add image
add board section
drag-and-drop image order
create mood labels
add note to image
favorite image
compare styles

Sections:

overall mood
florals
attire
tablescape
ceremony
reception
stationery
beauty
other

Add CTA:
“Turn this into your wedding page style”

This connects to landing page design.

4M. Reminders module

Pull from support settings and planning logic.

Show:

minimal / weekly / real-time
reminders by category
planner reminders
vendor reminders
guest reminders
payment reminders
fitting reminders
speech reminders
travel reminders

Allow toggles and edit schedule.

5. GUESTS PAGE — FULL GUEST OPERATING SYSTEM

This page is critical.

Top tabs:

Guests
Invites
Landing page
Message board
Seating
Guest map
5A. Guest list view

Show searchable list:

name
email
phone
RSVP
plus one
meal choice
children
travel needed
accommodation needed
accessibility needs
table assignment

Actions:

add guest
bulk import
filter
tag
export
5B. Invitations

This must be powerful but simple.

Sections:

Invitation template
Guest landing page
App invite link
Send method
Preview
Invitation template editor

Allow:

change template style
upload couple photo
edit names
edit welcome message
choose what info shows
add event schedule
add dress code
add FAQ
add accommodation info
add transport info
add map
add registry link
add contact info

Templates should be selectable and modern.

Landing page preview

Very simple but real preview of what a guest sees when they download the app or open the link.

Show preview modes:

App preview
Link preview

Allow toggles:

show couple photo
show wedding story
show schedule
show map
show hotels nearby
show flights note / airport note
show dress code
show RSVP
show FAQ
show gallery
show message board
show registry
show transport tips
Share actions
Copy invite link
Send by email
Send by WhatsApp
Share manually

Add note:
“This page shapes your guest-facing experience.”

5C. Message board

Title:
Messages for the couple

Connected conceptually to WhatsApp API integration.

Create a simple but elegant message board where guests can:

write thoughtful messages
leave blessings
leave advice
share excitement

Admin side should include:

approve / hide message
pin message
sort newest / favorites
import WhatsApp messages if integrated later
enable / disable message board

Show sample guest cards.

5D. Guest map

Interactive map module.

Show:

venue location
hotel suggestions nearby
airport
shuttle pickup points
after party locations
brunch location

Allow toggles for what guests can see.
Add “Preview as guest”.

Optional note:
“Nearby hotel and route suggestions can be curated for guests.”

5E. Seating on guests page

Show guest-centric seating status:

assigned
unassigned
table changes
seat card preview
6. LIVE PAGE — WEDDING DAY CONTROL ROOM

This must be one of the coolest parts.

Tabs:

Today
Timeline
Map
Weather
Crisis control
Announcements
6A. Today overview

Title:
Live wedding day

Show:

current time
current event stage
next 3 moments
key contacts
weather summary
guest arrival status
transport status
checklist

Add calm message:
“We have today held beautifully.”

6B. Weather widget

Must feed directly into Live page.

Show:

current weather
hourly forecast
rain chance
wind
heat note

Then smart wedding implication:

“Outdoor cocktail hour may need a backup plan”
“Light breeze expected for ceremony”
“Heat reminder: water station recommended”
6C. Timeline live view

Show current run of show in real time.
Allow marking:

started
completed
delayed
skipped

Allow quick note:

“Ceremony started 12 min late”
“Shuttle delayed”
“Photographer arrived”
6D. Interactive map live view

Show:

venue map
ceremony area
reception area
bathrooms
emergency exit
shuttle pickup
hotel routes
VIP entry

Allow admin notes and guest-facing preview.

6E. Crisis control

This must be smart but calming.

Title:
Crisis control

Show common scenarios:

weather disruption
vendor late
transport delay
missing guest
schedule running late
seating issue
technical issue
attire emergency
food issue
medical concern

Each opens a calm action card:

what to do
who to contact
what to communicate
backup step
mark resolved

This should feel like a safety system, not panic.

6F. Announcements

Quick wedding-day updates:

shuttle now arriving
ceremony starting in 15 minutes
reception room now open
weather note
after party transport info

Can be sent to guest app / landing page / WhatsApp-linked flow later.

7. GALLERY PAGE

Sections:

Lookbook
Wedding uploads
Guest uploads
Favorites
Archive

Allow:

upload images
approve guest uploads
pin favorites
create albums
mark for post-wedding recap
8. MORE PAGE

Items:

Profile
Wedding settings
Collaborators
Decision-makers
Notifications
Support preferences
Subscription / Wedding Pass
Feedback / contact
Help center
hello@udowedding.com
Privacy
Sign out

Add branded note:
“Planning should feel peaceful. We are always here to listen.”

9. INFO BUTTON / TOOLTIP SYSTEM

Use info buttons consistently for anything not instantly obvious.

Info icon opens soft modal with:

title
short elegant explanation
“Got it” button

Use for:

budget terms
dining enhancements
vendor types
wedding party roles
guest travel terms
insurance
crisis control categories
message board
support settings
10. INTERACTION RULES

Every button must go somewhere.

Required interactions:

tap cards
open detail pages
open modals
drag and drop seating
drag priority ordering
drag lookbook images
reorder timeline items
send invite flow
copy link flow
preview landing page flow
guest preview flow
open crisis scenario cards
expand weather widget
toggle guest visibility options

No dead ends.

11. MICROCOPY / EMOTIONAL TONE

Use warm but polished language.
Do not sound childish.
Do not sound corporate.

Examples:

“Let’s make this feel effortless.”
“A little clarity goes a long way.”
“These details help everything run beautifully.”
“You can always refine this later.”
“The details matter, but the feeling matters more.”

Use soft quote nuggets sparingly between major sections.

12. DATA CONNECTION RULES

The dashboard must visibly pull from onboarding.

Examples:

If transport was selected, transport should appear on guest pages, live page, and reminders
If meal selection was selected, guests page should include meal response tracking
If wedding party roles were selected, Plan page should surface those roles and allow editing
If vendors were selected, vendor cards should already exist
If priorities were selected, Home page should reflect them
If support preferences were chosen, reminder style and guidance tone should adapt
If additional events were chosen, timeline and planning modules should include them

Make this obvious in the UI.

13. FINAL OUTPUT EXPECTATION

The result must feel like:

a premium wedding operating system
calming and beautiful
easy enough to reduce stress immediately
intelligent enough to justify payment
detailed enough for GTM
structured enough for engineering handoff

If this still feels like:

a flat planner
a checklist app
a generic dashboard
then it is incorrect.
Build this like a product women would open and instantly feel:
“Finally. This gets me.”