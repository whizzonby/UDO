Create and insert a NEW onboarding module into the existing UDO onboarding flow.

IMPORTANT:
This is NOT a redesign of the whole onboarding.
This is an EXPANSION of the existing onboarding journey.

The new onboarding module must be inserted DIRECTLY AFTER:
“Additional celebrations”

AND DIRECTLY BEFORE:
“Honeymoon plans”

The onboarding flow order should now become:

1. Budget & spending style
2. Wedding priorities
3. Food, dining & guest preferences
4. Vendors & supplier needs
5. Wedding party
6. Personal moments
7. Additional celebrations
8. NEW → Cultural traditions & wedding structure
9. Honeymoon plans
10. Wedding insurance
11. How will UDO support you?

IMPORTANT:
The progress bar percentages and onboarding progression must automatically adjust to accommodate the new section naturally.

==================================================
OVERALL DESIGN DIRECTION
========================

UDO is a premium emotionally intelligent wedding planning platform.

The onboarding should feel:

* calming
* luxurious
* editorial
* emotionally aware
* globally inclusive
* deeply personalized
* human
* intelligent
* non-corporate
* soft and elegant

DO NOT make this feel like:

* a government form
* a cultural survey
* a demographic questionnaire
* an ethnicity selector
* a checklist app
* a cold SaaS onboarding

The experience should feel like:
“A thoughtful concierge gently learning how this wedding should feel.”

==================================================
VISUAL SYSTEM
=============

Match the EXISTING UDO onboarding design system EXACTLY.

Maintain:

* white background
* deep olive green serif headers
* soft charcoal body text
* blush pink selected states
* rounded cards
* large spacing
* luxury editorial typography
* subtle shadows
* soft UI
* modern minimalism
* mobile-first layout
* elegant onboarding rhythm

Maintain EXACT styling conventions from current onboarding:

* progress bar at top
* back arrow top left
* skip button top right
* serif title
* body copy underneath
* question sections
* large rounded selection cards
* pink active states
* soft informational boxes
* large sticky “Next” button at bottom

==================================================
CRITICAL UX REQUIREMENTS
========================

EVERYTHING MUST BE CLICKABLE.

That includes:

* every card
* every toggle
* every info icon
* every “Other” field
* every conditional flow
* every multi-select interaction

This must behave like a REAL production app.

NOT static screens.

==================================================
DYNAMIC BEHAVIOR REQUIREMENTS
=============================

The onboarding must intelligently adapt.

Selections in this module should influence:

* timelines
* reminders
* vendor suggestions
* ceremony flow
* hospitality planning
* family coordination
* budgeting
* cultural guidance
* guest experience tools
* travel coordination
* attire scheduling

Examples:

* selecting “Mehndi” should later affect timeline structure
* selecting “Jewish ceremony” should later affect ceremony flow
* selecting “multi-day celebration” should affect scheduling architecture
* selecting “international guests” should activate hospitality workflows
* selecting “family-led decisions” should later suggest collaboration permissions

The onboarding should FEEL intelligent.

==================================================
NEW SECTION INTRO TRANSITION
============================

AFTER the “Additional celebrations” screen:

Create a smooth transition screen before the new section begins.

Mini transition copy:

“Many celebrations carry traditions, rituals, and meaningful family moments.
We’d love to understand yours more deeply.”

Soft fade transition into the new onboarding module.

==================================================
NEW SCREEN 1
============

TITLE:
“Cultural traditions & wedding structure”

BODY COPY:
“Every celebration carries meaning, traditions, and stories.
Tell us what cultural, spiritual, or family elements matter to you so UDO can support them thoughtfully.”

ADD elegant blush info card:

“These selections help UDO personalize timelines, reminders, guest planning, vendor recommendations, and ceremony flow.”

QUESTION:
“What best describes your celebration?”

Create LARGE multi-select rounded cards.

OPTIONS:

* Single-day celebration
* Multi-day celebration
* Destination wedding
* Religious ceremony
* Traditional cultural ceremony
* Fusion / multicultural wedding
* Private elopement
* Civil ceremony
* Community-centered celebration
* Not sure yet

INTERACTION RULES:

* Multi-select enabled
* Active state = blush pink background + darker pink border + checkmark
* Unselected state = white with subtle gray border
* Cards animate softly on tap

CONDITIONAL LOGIC:
IF user selects:
“Fusion / multicultural wedding”
→ later show:
“How would you describe the traditions you’re blending?”

IF user selects:
“Multi-day celebration”
→ onboarding later adapts scheduling structure

IF user selects:
“Destination wedding”
→ activate hospitality/travel planning logic later

==================================================
NEW SCREEN 2
============

TITLE:
“Ceremonies & traditions”

BODY COPY:
“Many weddings include rituals, celebrations, or meaningful customs beyond the main ceremony.”

QUESTION:
“Which traditions or ceremonies are important to your celebration?”

IMPORTANT:
DO NOT group by ethnicity or region.
Everything must feel globally integrated and respectful.

Create large multi-select cards:

* Mehndi / Henna night
* Sangeet
* Baraat
* Tea ceremony
* Libation ceremony
* Kola nut ceremony
* Jumping the broom
* Unity candle
* Handfasting
* Breaking the glass
* Haka / cultural performance
* Elders blessing
* Traditional drumming
* Family procession
* Prayer ceremony
* Ancestor honoring
* Traditional dance performances
* Gift exchange rituals
* Dowry / bride price traditions
* Traditional attire changes
* Naming ceremony
* Other

ADD:
“Other traditions we should know about?”
Expandable text field.

INFO BOX:
“UDO uses these details to create more culturally aware timelines and planning suggestions.”

==================================================
NEW SCREEN 3
============

TITLE:
“Religious & spiritual structure”

BODY COPY:
“If faith or spirituality plays a role in your celebration, we want to support it respectfully.”

QUESTION:
“Will faith or spirituality shape your wedding experience?”

OPTIONS:

* Christian ceremony
* Muslim ceremony
* Hindu ceremony
* Sikh ceremony
* Jewish ceremony
* Buddhist ceremony
* Indigenous spiritual traditions
* Traditional African spiritual traditions
* Interfaith ceremony
* Secular / non-religious
* Prefer not to say
* Other

IMPORTANT:
This section must feel OPTIONAL and respectful.

Add subtle note:
“You can always refine or expand these details later.”

DYNAMIC LOGIC:

* Jewish ceremony → later timeline suggestions include ceremonial sequencing
* Muslim ceremony → later food + scheduling logic adapts
* Hindu ceremony → multi-event structure suggestions
* Interfaith → blended ceremony recommendations later

==================================================
NEW SCREEN 4
============

TITLE:
“Family involvement”

BODY COPY:
“Every wedding has a different planning dynamic.
Help us understand how decisions are typically being made.”

QUESTION:
“How involved are family members in planning?”

OPTIONS:

* Mostly couple-led
* Collaborative with family
* Family-led decisions
* Elders heavily involved
* Shared planning across households
* Planner-led coordination

QUESTION 2:
“Would you like shared planning access later?”

OPTIONS:

* Yes
* Maybe later
* No

This should later affect:

* collaboration permissions
* budgeting visibility
* reminder routing
* guest coordination permissions

==================================================
NEW SCREEN 5
============

TITLE:
“Guest travel & hospitality”

BODY COPY:
“Some weddings involve complex guest travel and hospitality planning.”

QUESTION:
“What best describes your guest situation?”

MULTI-SELECT OPTIONS:

* Mostly local guests
* International guests
* Guests traveling from multiple countries
* Visa coordination needed
* Hotel blocks needed
* Airport coordination needed
* Elderly guest accommodations
* Child-friendly accommodations
* Group transportation needed
* Large family travel groups
* Welcome events planned

DYNAMIC LOGIC:
Selecting international or multi-country guests should later influence:

* guest communication
* hotel planning
* airport coordination
* local recommendations
* transportation timelines

==================================================
NEW SCREEN 6
============

TITLE:
“Attire & presentation”

BODY COPY:
“Outfits and presentation are often a meaningful part of the celebration.”

QUESTION:
“What matters most for attire planning?”

OPTIONS:

* Multiple outfit changes
* Traditional attire
* Western attire
* Coordinated family attire
* Bridal styling support
* Groom styling support
* Beauty timeline planning
* Jewelry coordination
* Custom tailoring
* Cultural dressing assistance
* Headpiece / turban coordination
* Not sure yet

These selections should later influence:

* beauty reminders
* scheduling
* preparation timelines
* vendor recommendations

==================================================
NEW SCREEN 7
============

TITLE:
“Celebration structure”

BODY COPY:
“Wedding celebrations vary greatly in timing and flow.”

QUESTION:
“How long will your celebration likely be?”

OPTIONS:

* Short ceremony
* Half-day celebration
* Full-day wedding
* Weekend celebration
* Three-day celebration
* Flexible / open format
* Not sure yet

QUESTION:
“What atmosphere feels most like your celebration?”

OPTIONS:

* Intimate & emotional
* High-energy & social
* Elegant & formal
* Family-centered
* Cultural & traditional
* Luxury experience
* Relaxed & peaceful
* Community celebration

==================================================
NEW SCREEN 8
============

TITLE:
“How UDO adapts to you”

This should feel deeply emotional and intelligent.

Generate dynamic adaptive summary cards based on earlier selections.

EXAMPLES:

* “UDO will help structure your multi-day celebration thoughtfully.”
* “Your selections suggest a highly guest-centered experience.”
* “We’ll help coordinate hospitality and travel details.”
* “Your planning journey may involve multiple ceremonies and traditions.”
* “Family collaboration tools may be especially helpful for your wedding.”

These cards should appear dynamically based on selections.

BOTTOM SECTION:
“Planning support style”

OPTIONS:

* Minimal reminders
* Weekly guidance
* Structured planning support
* Hands-on support

FINAL CTA BUTTON:
“Begin my planning journey”

==================================================
ANIMATION + INTERACTION REQUIREMENTS
====================================

Add:

* smooth scrolling
* animated card selection
* fade transitions
* subtle haptic-style interactions
* sticky bottom CTA
* realistic keyboard interactions
* active text fields
* hover/tap states
* expandable “Other” fields
* realistic onboarding pacing

==================================================
IMPORTANT GLOBAL INSTRUCTIONS
=============================

DO NOT:

* use flags
* use country imagery
* stereotype cultures
* group traditions by race
* ask “what ethnicity are you?”
* make assumptions

INSTEAD:
Make UDO feel:

* globally intelligent
* emotionally adaptive
* culturally respectful
* premium
* modern
* inclusive
* deeply thoughtful

The final onboarding should feel like:
“A luxury wedding concierge that truly understands different types of celebrations globally.”
