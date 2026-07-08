Create a fully interactive, high-fidelity iPhone mobile onboarding flow for an app called UDO (a wedding planning operating system).

This is a complete rebuild. Do not modify any existing screens.

CORE REQUIREMENTS
The design must be clean, modern, minimal, and premium
The experience must feel like a guided setup, not a long form
All screens must be fully clickable
No dead buttons
Every “Next” button must work without user input
All selections must have default values or pre-selected states
Include back, next, and skip options on every screen
Use consistent spacing and alignment throughout
Use reusable components (buttons, cards, inputs)
VISUAL STYLE (STRICT)

Background:

White (#FFFFFF)

Cards:

Very light blush (#FAF5F6)

Primary button:

Deep plum (#5C3A47)
Rounded corners (16px+)
Large and centered

Secondary button:

Light grey or outlined

Inputs:

White background
Thin border (#EAEAEA)
Rounded corners (12px)
NOT filled shapes

Typography:

Heading: elegant serif (large, spaced)
Body: clean sans-serif
Clear hierarchy

DO NOT:

Use gradients
Use heavy beige backgrounds
Use large filled rounded blobs
Overcrowd the screen
SCREEN STRUCTURE
SCREEN 1: ROLE SELECTION

Title:
Who is planning this wedding?

Options (selectable cards):

This is my wedding (default selected)
I am helping plan
I am a professional planner

Button:
Next

SCREEN 2: PLANNER STATUS

Title:
How are you planning?

Options:

I already have a planner
I plan to hire one
I am not sure yet
I am planning it myself (default)

If “I already have a planner” is selected:
Show button:
Invite your planner

Buttons:
Back | Next

SCREEN 3: CORE DETAILS

Title:
Let’s start with the essentials

Sections:

Wedding Name:
Pre-filled: Jamé & Louis

Wedding Type (card selection):

Destination (default)
Local
Hometown

Event Format:

Ceremony only
Ceremony + reception (default)
Multi-day

Date:
Pre-filled: June 2026

Time of day:

Morning
Afternoon
Evening (default)

Location:
Pre-filled: Jamaica

Venue status:

Not booked (default)
Booked
Exploring

Buttons:
Back | Next

SCREEN 4: GUEST EXPERIENCE

Title:
What will your guests need?

Use toggle rows with short descriptions:

Children allowed (ON)
Accommodation needed (ON)
Transport needed (ON)
Meal selection required (ON)

Buttons:
Back | Next

SCREEN 5: SCALE & BUDGET

Title:
Let’s define your scale

Guest Count:
Slider + number display (default: 120)

Budget:
Pre-filled: 25,000

Budget confidence:

Rough estimate
Mostly set (default)
Final

Buttons:
Back | Next

SCREEN 6: PRIORITIES

Title:
What matters most to you?

Select up to 3 (pre-select 2):

Guest experience (selected)
Food (selected)
Photography
Decor
Entertainment
Convenience

Helper text:
Choose up to 3 priorities

Buttons:
Back | Next

SCREEN 7: STYLE

Title:
What should your wedding feel like?

Style:

Modern luxury (selected)
Garden
Beach
Minimal

Mood:

Elegant (selected)
Romantic (selected)
Intimate
Vibrant

Dress code:

Formal (selected)
Cocktail
Beach formal
Custom

Inspiration:
Upload box (placeholder only)

Buttons:
Back | Next

SCREEN 8: VENDORS

Title:
What will you need?

Core vendors (grid, selectable):

Venue (selected)
Photographer (selected)
Videographer
Catering (selected)
DJ / Band (selected)
Decor

Additional services section (expandable):

Photo Booth
Entertainment
Celebrant
Wedding Transport
Wedding Favours
Marquee / Tipi Hire
Wedding Décor & Styling
Unique Suppliers

Each item must have a small info icon.

When clicked, show a bottom sheet with definition text.

Buttons:
Back | Next

SCREEN 9: WEDDING PARTY

Title:
Who is part of your wedding party?

Toggle list:

Maid of Honour
Best Man
Bridesmaids
Ushers
Flower Girl
Page Boy
Ring Bearer

Each item must include an info icon.

Info icon opens a bottom sheet explaining the role.

Buttons:
Back | Next

SCREEN 10: PERSONAL DETAILS

Title:
Personal touches

Fields:

Speeches planned (Yes selected)

Honour loved ones (No selected)

Theme or colour scheme (text field)

Buttons:
Back | Next

SCREEN 11: EVENTS

Title:
Will you have additional events?

Toggle options:

Stag party
Hen party
Engagement party
Rehearsal dinner

Buttons:
Back | Next

SCREEN 12: HONEYMOON

Title:
Are you planning a honeymoon?

Options:

Yes (default)
Not yet
No

If Yes:
Show fields:

Destination
Budget

Buttons:
Back | Next

SCREEN 13: INSURANCE

Title:
Will you get wedding insurance?

Options:

Yes
No (default)
Not sure

Include info icon explaining wedding insurance

Buttons:
Back | Next

SCREEN 14: EMOTIONAL SETTINGS

Title:
How should Udo support you?

Support style:

Calm (default)
Direct
Proactive

Stress level:

Low
Moderate (default)
High

Reminders:

Minimal
Weekly (default)
Frequent

Buttons:
Back | Next

SCREEN 15: SUMMARY

Title:
Here’s your wedding overview

Display cards:

Location: Jamaica
Budget: $25,000
Guests: 120
Style: Modern luxury

Buttons:
Create My Wedding (primary)
Edit Details (secondary)

INTERACTIONS
All buttons must navigate
Info icons must open modals
Back and Next must work
Skip must go to summary
No broken flows
FILE STRUCTURE

Organize screens into sections:

Onboarding Screens
Components
Modals
Interaction Flow
FINAL NOTE

The design must feel:

clean
calm
premium
modern

NOT:

cluttered
generic
template-like
AI-generated
✅ WHAT THIS DOES

This version:

removes ambiguity
removes styling errors
forces structure
prevents “AI slop”
ensures full clickable flow
gives your CTO clarity