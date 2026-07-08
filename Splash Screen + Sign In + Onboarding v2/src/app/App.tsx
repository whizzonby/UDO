import React, { useState } from 'react';
import { EntryScreen } from './components/EntryScreen';
import { AuthScreen } from './components/AuthScreen';
import { WelcomeMessageScreen } from './components/WelcomeMessageScreen';
import { ScreenLayout } from './components/ScreenLayout';
import { SelectableCard } from './components/SelectableCard';
import { MultiSelectCard } from './components/MultiSelectCard';
import { Section } from './components/Section';
import { Input } from './components/Input';
import { Toggle } from './components/Toggle';
import { InfoModal } from './components/InfoModal';
import { Info } from 'lucide-react';

function App() {
  const [currentScreen, setCurrentScreen] = useState(0);
  const [showModal, setShowModal] = useState(false);
  const [modalContent, setModalContent] = useState({ title: '', description: '' });

  // Screen 1 - Role
  const [role, setRole] = useState('This is my wedding');

  // Screen 1.5 - Decision Making (new separate screen)
  const [decisionStyle, setDecisionStyle] = useState('We make decisions together');
  const [collaborators, setCollaborators] = useState<Array<{ name: string; email: string; role: string }>>([]);

  // Screen 2 - Planning Structure
  const [planningApproach, setPlanningApproach] = useState('Self-managed');

  // Screen 3 - Core Event Architecture
  const [weddingType, setWeddingType] = useState('Destination');
  const [season, setSeason] = useState('Summer');
  const [dateStatus, setDateStatus] = useState('Fixed');
  const [weddingDate, setWeddingDate] = useState('');
  const [timeOfDay, setTimeOfDay] = useState('Evening');
  const [eventStructure, setEventStructure] = useState(['Ceremony', 'Reception']);

  // Screen 4 - Location & Travel
  const [country, setCountry] = useState('Jamaica');
  const [city, setCity] = useState('Montego Bay');
  const [venueStatus, setVenueStatus] = useState('Shortlisting');
  const [guestTravel, setGuestTravel] = useState('Mostly international');
  const [travelSupport, setTravelSupport] = useState(['Accommodation coordination', 'Shuttle services']);

  // Screen 5 - Guest Experience
  const [guestExperience, setGuestExperience] = useState([
    'Children included',
    'Accommodation required',
    'Transport required',
    'Meal selection required'
  ]);

  // Screen 6 - Budget Intelligence
  const [totalBudget, setTotalBudget] = useState('25000');
  const [budgetStructure, setBudgetStructure] = useState('Flexible budget');
  const [allocationPreference, setAllocationPreference] = useState('Experience-focused');
  const [funding, setFunding] = useState('Self-funded');
  const [budgetConfidence, setBudgetConfidence] = useState('Moderately defined');

  // Screen 7 - Priorities
  const [priorities, setPriorities] = useState(['Guest experience', 'Food & beverage quality']);

  // Screen 8 - Food & Dining
  const [diningStyle, setDiningStyle] = useState('Formal plated');
  const [dietary, setDietary] = useState(['Vegetarian', 'Allergies']);
  const [diningEnhancements, setDiningEnhancements] = useState(['Cocktail hour', 'Signature drinks']);

  // Screen 9 - Vendors
  const [coreVendors, setCoreVendors] = useState(['Venue', 'Photographer', 'Catering']);
  const [expandedVendors, setExpandedVendors] = useState<string[]>([]);
  const [uniqueSuppliers, setUniqueSuppliers] = useState<string[]>([]);

  // Screen 10 - Wedding Party
  const [weddingParty, setWeddingParty] = useState({
    'Maid of Honour': true,
    'Best Man': true,
    'Bridesmaids': true,
    'Groomsmen': true
  });

  // Screen 11 - Personal Moments
  const [speeches, setSpeeches] = useState('Yes');
  const [whoSpeaking, setWhoSpeaking] = useState<string[]>([]);
  const [honouringLovedOnes, setHonouringLovedOnes] = useState('Yes');
  const [tributeType, setTributeType] = useState('Memory table');
  const [personalTouches, setPersonalTouches] = useState('');

  // Screen 12 - Additional Events
  const [additionalEvents, setAdditionalEvents] = useState(['Rehearsal dinner']);
  const [eventOrganizer, setEventOrganizer] = useState('I am');

  // Screen 13 - Cultural Traditions (NEW MODULE - 8 screens)
  const [culturalCelebrationType, setCulturalCelebrationType] = useState<string[]>([]);
  const [culturalTraditions, setCulturalTraditions] = useState<string[]>([]);
  const [otherTraditions, setOtherTraditions] = useState('');
  const [religiousStructure, setReligiousStructure] = useState<string[]>([]);
  const [familyInvolvement, setFamilyInvolvement] = useState('Mostly couple-led');
  const [sharedPlanningAccess, setSharedPlanningAccess] = useState('Maybe later');
  const [guestHospitality, setGuestHospitality] = useState<string[]>([]);
  const [attirePlanning, setAttirePlanning] = useState<string[]>([]);
  const [celebrationDuration, setCelebrationDuration] = useState('Full-day wedding');
  const [celebrationAtmosphere, setCelebrationAtmosphere] = useState('Intimate & emotional');
  const [planningSupportStyle, setPlanningSupportStyle] = useState('Weekly guidance');

  // Screen 21 - Honeymoon
  const [planningHoneymoon, setPlanningHoneymoon] = useState('Yes');
  const [honeymoonDestination, setHoneymoonDestination] = useState('Maldives');
  const [honeymoonBudget, setHoneymoonBudget] = useState('5000');
  const [honeymoonTiming, setHoneymoonTiming] = useState('Immediate');

  // Screen 22 - Insurance
  const [insurance, setInsurance] = useState('Yes');

  // Screen 23 - Support Preferences
  const [supportStyle, setSupportStyle] = useState('Calm, minimal guidance');
  const [decisionSupport, setDecisionSupport] = useState('I would like guided suggestions');
  const [stressLevel, setStressLevel] = useState('Moderate support');
  const [reminders, setReminders] = useState('Weekly');

  const nextScreen = () => setCurrentScreen((prev) => Math.min(prev + 1, 26));
  const prevScreen = () => setCurrentScreen((prev) => Math.max(prev - 1, 0));
  const skipToFinal = () => setCurrentScreen(26);

  const showInfo = (title: string, description: string) => {
    setModalContent({ title, description });
    setShowModal(true);
  };

  if (currentScreen === 0) {
    return <EntryScreen onBegin={() => setCurrentScreen(1)} />;
  }

  // Screen 1: Authentication
  if (currentScreen === 1) {
    return <AuthScreen onContinue={() => setCurrentScreen(2)} />;
  }

  // Screen 2: Welcome message
  if (currentScreen === 2) {
    return <WelcomeMessageScreen onBegin={() => setCurrentScreen(3)} />;
  }

  // Screen 3: Role
  if (currentScreen === 3) {
    const roles = [
      'This is my wedding',
      'We are planning together',
      'I am supporting the planning',
      'I am the wedding planner',
      'I am part of a planning team'
    ];

    return (
      <ScreenLayout
        title="Tell us about your role"
        preamble="Every wedding is different. Knowing your role helps us shape the right planning experience for you."
        onNext={nextScreen}
        onSkip={skipToFinal}
        showBack={false}
        showSkip={true}
        currentStep={1}
        totalSteps={23}
      >
        <div className="space-y-3 mt-4">
          {roles.map((roleOption) => (
            <SelectableCard key={roleOption} selected={role === roleOption} onClick={() => setRole(roleOption)}>
              <div className="pr-8">{roleOption}</div>
            </SelectableCard>
          ))}
        </div>
      </ScreenLayout>
    );
  }

  // Screen 4: Decision Making
  if (currentScreen === 4) {
    return (
      <ScreenLayout
        title="Who is involved in decision-making?"
        preamble="Planning is easier when the right people are included from the start. Invite anyone helping shape important decisions."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={2}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="Decision style">
            <div className="space-y-3">
              {[
                'One person is leading',
                'We make decisions together',
                'Family input matters',
                'A planner helps guide decisions',
                'Final decisions are still evolving'
              ].map((style) => (
                <SelectableCard
                  key={style}
                  selected={decisionStyle === style}
                  onClick={() => setDecisionStyle(style)}
                  size="sm"
                >
                  <div className="pr-8">{style}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <div className="bg-[#f8edeb] rounded-2xl p-5 border border-[#f194b2]">
            <h3 className="text-sm text-[#285301] mb-3" style={{ fontWeight: '500' }}>
              Invite key people
            </h3>
            <p className="text-xs text-gray-600 mb-4">
              You can invite people now, or copy a link to share later.
            </p>
            <div className="space-y-3">
              <button className="w-full py-3 bg-white border-2 border-[#d45d78] text-[#d45d78] rounded-xl hover:bg-[#f8edeb] transition-colors text-sm">
                Add collaborator
              </button>
              <button className="w-full py-2.5 bg-white border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors text-sm">
                Copy invite link
              </button>
            </div>
          </div>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 5: Planning Structure
  if (currentScreen === 5) {
    return (
      <ScreenLayout
        title="How are you approaching the planning?"
        preamble="This helps us understand how hands-on UDO should be and where to support you most."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={3}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <div className="space-y-3">
            {['Planner-led', 'Hybrid planning', 'Self-managed', 'Family-supported', 'Still deciding'].map((approach) => (
              <SelectableCard
                key={approach}
                selected={planningApproach === approach}
                onClick={() => setPlanningApproach(approach)}
              >
                <div className="pr-8">{approach}</div>
              </SelectableCard>
            ))}
          </div>

          {(planningApproach === 'Planner-led' || planningApproach === 'Hybrid planning') && (
            <div className="bg-[#f8edeb] rounded-2xl p-5 animate-fade-in">
              <p className="text-xs text-gray-600 mb-3">
                If you already have a planner, we can bring them into your workspace.
              </p>
              <div className="space-y-2">
                <Input label="" value="" onChange={() => {}} placeholder="Add planner email" />
                <button className="w-full py-2.5 bg-white border border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors text-sm">
                  Copy planner invite link
                </button>
              </div>
            </div>
          )}
        </div>
      </ScreenLayout>
    );
  }

  // Screen 6: Core Event Architecture
  if (currentScreen === 6) {
    return (
      <ScreenLayout
        title="Shape your wedding experience"
        preamble="This section helps us understand the structure, setting, and feeling of your celebration."
        quoteNugget="The way your wedding unfolds should feel like you."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={4}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="Wedding type">
            <div className="grid grid-cols-2 gap-3">
              {['Destination', 'Local', 'Hometown', 'Multi-country'].map((type) => (
                <SelectableCard key={type} selected={weddingType === type} onClick={() => setWeddingType(type)} size="sm">
                  <div className="text-center text-sm pr-6">{type}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="Season">
            <div className="grid grid-cols-2 gap-3">
              {['Spring', 'Summer', 'Autumn', 'Winter'].map((s) => (
                <SelectableCard key={s} selected={season === s} onClick={() => setSeason(s)} size="sm">
                  <div className="text-center text-sm pr-6">{s}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="Date">
            <div className="space-y-3">
              <div className="grid grid-cols-3 gap-3">
                {['Fixed', 'Flexible', 'Not decided'].map((date) => (
                  <SelectableCard key={date} selected={dateStatus === date} onClick={() => setDateStatus(date)} size="sm">
                    <div className="text-center text-xs pr-6">{date}</div>
                  </SelectableCard>
                ))}
              </div>
              {dateStatus === 'Fixed' && (
                <Input
                  label=""
                  value={weddingDate}
                  onChange={setWeddingDate}
                  placeholder="Enter your wedding date"
                />
              )}
            </div>
          </Section>

          <Section title="Time of day">
            <div className="grid grid-cols-2 gap-3">
              {['Morning', 'Afternoon', 'Evening', 'Multi-part celebration'].map((time) => (
                <SelectableCard key={time} selected={timeOfDay === time} onClick={() => setTimeOfDay(time)} size="sm">
                  <div className="text-center text-xs pr-6">{time}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="Event structure (select all that apply)">
            <MultiSelectCard
              options={[
                'Ceremony',
                'Reception',
                'Civil ceremony',
                'Traditional ceremony',
                'Religious ceremony',
                'Welcome dinner',
                'Engagement party',
                'Rehearsal dinner',
                'Bridal shower',
                'Bachelor / stag party',
                'Bachelorette / hen party',
                'Cultural ceremonies',
                'Tea ceremony',
                'Nikah / signing ceremony',
                'After party',
                'Day-after brunch',
                'Farewell gathering',
                'Other'
              ]}
              selected={eventStructure}
              onChange={setEventStructure}
            />
            <p className="text-xs text-gray-500 mt-3">
              You can always add more events later inside the app.
            </p>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 7: Location & Travel
  if (currentScreen === 7) {
    return (
      <ScreenLayout
        title="Location & guest travel"
        preamble="This helps us plan around venue progress, travel needs, and guest coordination."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={5}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="Location details">
            <div className="space-y-3">
              <Input label="Country" value={country} onChange={setCountry} placeholder="Enter country" />
              <Input label="City" value={city} onChange={setCity} placeholder="Enter city" />
            </div>
          </Section>

          <Section title="Venue status">
            <div className="space-y-3">
              {['Not started', 'Shortlisting', 'Booked'].map((status) => (
                <SelectableCard
                  key={status}
                  selected={venueStatus === status}
                  onClick={() => setVenueStatus(status)}
                  size="sm"
                >
                  <div className="pr-8">{status}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="Guest travel profile">
            <div className="space-y-3">
              {['Mostly local', 'Mixed', 'Mostly international'].map((travel) => (
                <SelectableCard
                  key={travel}
                  selected={guestTravel === travel}
                  onClick={() => setGuestTravel(travel)}
                  size="sm"
                >
                  <div className="pr-8">{travel}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section
            title="Support needed"
            helper="The more we understand travel complexity, the better we can organize communication and logistics."
          >
            <MultiSelectCard
              options={['Accommodation coordination', 'Travel booking support', 'Visa guidance', 'Shuttle services']}
              selected={travelSupport}
              onChange={setTravelSupport}
            />
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // Continue in next part due to size...
  // For now, let me create the remaining screens as a continuation

  // Screen 8: Guest Experience
  if (currentScreen === 8) {
    return (
      <ScreenLayout
        title="Design your guest experience"
        preamble="The choices you make here will shape your guest dashboard, communications, reminders, and planning recommendations."
        quoteNugget="Think about how you want guests to feel from the moment they are invited."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={6}
        totalSteps={23}
      >
        <div className="mt-4">
          <MultiSelectCard
            options={[
              'Children included',
              'Adults-only event',
              'Accommodation required',
              'Transport required',
              'Meal selection required',
              'Dietary tracking required',
              'Accessibility needs',
              'Welcome packs / gifting',
              'Guest communication portal',
              'Seating optimization',
              'Multi-language support',
              'RSVP reminders',
              'Hotel block coordination',
              'Airport transfer support',
              'Local activity suggestions',
              'Dress code support',
              'FAQ page for guests',
              'Gift registry guidance',
              'Event map / directions',
              'Shuttle timing communication'
            ]}
            selected={guestExperience}
            onChange={setGuestExperience}
          />
          <p className="text-xs text-gray-600 mt-4 bg-[#f8edeb] p-3 rounded-xl">
            These choices will feed directly into your guest-facing experience inside UDO.
          </p>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 9: Budget Intelligence
  if (currentScreen === 9) {
    return (
      <ScreenLayout
        title="Budget & spending style"
        preamble="We are not just asking how much you want to spend — we are learning how you want to spend it."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={7}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <p className="text-sm text-gray-600">
            These answers help us tailor your dashboard, priorities, and planning suggestions around your real comfort level.
          </p>

          <Section title="Total budget" helper="Your working budget can always be refined later.">
            <Input label="" value={totalBudget} onChange={setTotalBudget} placeholder="Enter amount" />
          </Section>

          <Section title="Structure" helper="Structure tells us how firmly your budget is set.">
            <div className="space-y-3">
              {['Fixed budget', 'Flexible budget', 'Priority-led budget'].map((struct) => (
                <SelectableCard
                  key={struct}
                  selected={budgetStructure === struct}
                  onClick={() => setBudgetStructure(struct)}
                  size="sm"
                >
                  <div className="pr-8">{struct}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="Allocation preference" helper="This shows how you want your spending to feel overall.">
            <div className="grid grid-cols-2 gap-3">
              {['Even distribution', 'Experience-focused', 'Aesthetic-focused', 'Cost-conscious / controlled', 'Luxury-led', 'Logistics-first'].map(
                (pref) => (
                  <SelectableCard
                    key={pref}
                    selected={allocationPreference === pref}
                    onClick={() => setAllocationPreference(pref)}
                    size="sm"
                  >
                    <div className="text-center text-xs pr-6">{pref}</div>
                  </SelectableCard>
                )
              )}
            </div>
          </Section>

          <Section title="Funding" helper="Understanding who is contributing helps us frame planning conversations realistically.">
            <div className="space-y-3">
              {['Self-funded', 'Family-funded', 'Joint contributions', 'Shared support from multiple people', 'Prefer not to say'].map(
                (fund) => (
                  <SelectableCard key={fund} selected={funding === fund} onClick={() => setFunding(fund)} size="sm">
                    <div className="pr-8">{fund}</div>
                  </SelectableCard>
                )
              )}
            </div>
          </Section>

          <Section title="Confidence" helper="Confidence shows how certain you feel about your current budget choices.">
            <div className="space-y-3">
              {['Early estimate', 'Moderately defined', 'Finalised'].map((conf) => (
                <SelectableCard
                  key={conf}
                  selected={budgetConfidence === conf}
                  onClick={() => setBudgetConfidence(conf)}
                  size="sm"
                >
                  <div className="pr-8">{conf}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <p className="text-xs text-gray-600 bg-[#f8edeb] p-3 rounded-xl">
            These selections will shape how UDO prioritizes recommendations and budget nudges in your dashboard.
          </p>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 10: Priorities
  if (currentScreen === 10) {
    return (
      <ScreenLayout
        title="Your wedding priorities"
        preamble="We really want to know what makes you light up. Your priorities will help us guide you beautifully."
        quoteNugget="The most memorable weddings feel intentional."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={8}
        totalSteps={23}
      >
        <div className="mt-4">
          <p className="text-sm text-gray-600 mb-4">
            Choose up to 5 priorities. These will influence your dashboard, reminders, and recommendations.
          </p>
          <MultiSelectCard
            options={[
              'Guest experience',
              'Food & beverage quality',
              'Photography & videography',
              'Visual design & decor',
              'Entertainment',
              'Convenience & ease',
              'Cultural traditions',
              'Budget efficiency',
              'Luxury / exclusivity',
              'Intimacy',
              'Family involvement',
              'Emotional meaning',
              'Timeless elegance',
              'Stress reduction',
              'Smooth logistics'
            ]}
            selected={priorities}
            onChange={setPriorities}
            maxSelections={5}
          />
        </div>
      </ScreenLayout>
    );
  }

  // Screen 11: Food & Dining
  if (currentScreen === 11) {
    return (
      <ScreenLayout
        title="Food, dining & guest preferences"
        preamble="Great food is one of the most memorable parts of a wedding. Tell us what matters here — even if you only know part of it for now."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={9}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <p className="text-xs text-gray-600">
            You can always come back and refine your dining plans later in the app.
          </p>

          <Section title="Dining style" helper="How do you imagine the meal experience?">
            <div className="space-y-3">
              {[
                'Formal plated',
                'Buffet',
                'Family-style',
                'Shared banquet',
                'Cocktail-style reception',
                'Food stations',
                'Cultural cuisine',
                'Mixed format',
                'Not decided yet'
              ].map((style) => (
                <SelectableCard
                  key={style}
                  selected={diningStyle === style}
                  onClick={() => setDiningStyle(style)}
                  size="sm"
                >
                  <div className="pr-8">{style}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section
            title="Dietary needs"
            helper="This refers to guest dietary requirements or meal restrictions you may need to accommodate."
          >
            <MultiSelectCard
              options={[
                'Vegetarian',
                'Vegan',
                'Halal',
                'Kosher',
                'Gluten-free',
                'Dairy-free',
                'Nut allergy',
                'Seafood allergy',
                'Egg-free',
                'Low-sugar / diabetic-friendly',
                'No pork',
                'No alcohol',
                'Child-friendly meals',
                'Other',
                'Unsure for now'
              ]}
              selected={dietary}
              onChange={setDietary}
            />
          </Section>

          <Section title="Dining enhancements" helper="These are additional touches that elevate the food and drink experience.">
            <MultiSelectCard
              options={[
                'Cocktail hour',
                'Signature drinks',
                'Champagne tower',
                'Late-night snacks',
                'Dessert station',
                'Sweet table',
                'Coffee cart',
                'Food truck',
                'Interactive food stations',
                'Cultural food moments',
                'Welcome drinks',
                'Brunch station',
                'Custom cake experience',
                'Other'
              ]}
              selected={diningEnhancements}
              onChange={setDiningEnhancements}
            />
          </Section>

          <p className="text-xs text-gray-600 bg-[#f8edeb] p-3 rounded-xl">
            These selections will help UDO shape budget estimates, guest planning, and vendor recommendations.
          </p>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 12: Vendors
  if (currentScreen === 12) {
    return (
      <ScreenLayout
        title="Vendors & supplier needs"
        preamble="The vendors you expect to use will help us personalize your dashboard, recommendations, task lists, and planning timeline."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={10}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <p className="text-xs text-gray-600">
            Select what you expect to need now — you can always refine later.
          </p>

          <Section title="Core vendors">
            <MultiSelectCard
              options={['Venue', 'Planner', 'Photographer', 'Videographer', 'Catering', 'Florist', 'Decor stylist', 'DJ / Band']}
              selected={coreVendors}
              onChange={setCoreVendors}
            />
          </Section>

          <Section title="Expanded vendors">
            <MultiSelectCard
              options={[
                'Lighting designer',
                'Content creator',
                'Photo booth',
                'Live streaming',
                'Wedding website',
                'Stationery designer',
                'Security',
                'Transport provider',
                'Rentals',
                'Marquee / tipi hire',
                'Celebrant / officiant',
                'Hair & makeup',
                'Cake designer',
                'MC / host',
                'AV / sound support'
              ]}
              selected={expandedVendors}
              onChange={setExpandedVendors}
            />
          </Section>

          <Section title="Unique suppliers">
            <MultiSelectCard
              options={[
                'Fireworks',
                'Drone shows',
                'Live performers',
                'Cultural performers',
                'Luxury experiences',
                'Custom installations',
                'Interactive guest experiences',
                'Surprise entertainment'
              ]}
              selected={uniqueSuppliers}
              onChange={setUniqueSuppliers}
            />
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 13: Wedding Party
  if (currentScreen === 13) {
    const roles = [
      {
        name: 'Maid of Honour',
        info: 'Supports the bride throughout planning and on the wedding day, including coordination, emotional support, and logistics.'
      },
      { name: 'Best Man', info: 'Assists the groom, manages key logistics, and often delivers a speech.' },
      { name: 'Bridesmaids', info: 'Support the bride, assist with events, and contribute to planning tasks.' },
      { name: 'Groomsmen', info: 'Support the groom, assist with coordination, and participate in pre-wedding events.' },
      { name: 'Ushers', info: 'Help guests find their seats and assist with ceremony logistics.' },
      { name: 'Flower Girl', info: 'Young girl who walks down the aisle scattering flower petals before the bride.' },
      { name: 'Page Boy', info: 'Young boy who carries the rings or walks down the aisle during the ceremony.' },
      { name: 'Ring Bearer', info: 'Child responsible for carrying the wedding rings down the aisle.' }
    ];

    return (
      <ScreenLayout
        title="Your wedding party"
        preamble="These roles will help us organize timelines, reminders, responsibilities, and key moments throughout your planning."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={11}
        totalSteps={23}
      >
        <div className="space-y-4 mt-4">
          {roles.map((role) => (
            <div key={role.name} className="flex items-center justify-between p-4 bg-[#f8edeb] rounded-xl border border-[#f194b2]">
              <div className="flex items-center gap-2">
                <span className="text-sm text-[#285301]">{role.name}</span>
                <button onClick={() => showInfo(role.name, role.info)} className="text-[#d45d78]">
                  <Info size={16} />
                </button>
              </div>
              <Toggle
                enabled={weddingParty[role.name as keyof typeof weddingParty] || false}
                onChange={(val) => setWeddingParty({ ...weddingParty, [role.name]: val })}
              />
            </div>
          ))}
        </div>
      </ScreenLayout>
    );
  }

  // Screen 14: Personal Moments
  if (currentScreen === 14) {
    return (
      <ScreenLayout
        title="Personal moments"
        preamble="What special moments do you want your wedding to hold?"
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={12}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <p className="text-sm text-gray-600">
            These details help us honor the emotional heart of your celebration — not just the logistics.
          </p>

          <Section title="Speeches planned?">
            <div className="grid grid-cols-2 gap-3">
              {['Yes', 'No'].map((option) => (
                <SelectableCard key={option} selected={speeches === option} onClick={() => setSpeeches(option)} size="sm">
                  <div className="text-center pr-6">{option}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          {speeches === 'Yes' && (
            <Section title="Who is speaking?" helper="">
              <MultiSelectCard
                options={['Groom', 'Bride', 'Parent', 'Sibling', 'Best man', 'Maid of honour', 'Friend', 'Other']}
                selected={whoSpeaking}
                onChange={setWhoSpeaking}
              />
            </Section>
          )}

          <Section title="Honouring loved ones?">
            <div className="grid grid-cols-2 gap-3">
              {['Yes', 'No'].map((option) => (
                <SelectableCard
                  key={option}
                  selected={honouringLovedOnes === option}
                  onClick={() => setHonouringLovedOnes(option)}
                  size="sm"
                >
                  <div className="text-center pr-6">{option}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          {honouringLovedOnes === 'Yes' && (
            <Section title="Tribute type">
              <div className="space-y-3">
                {['Speech', 'Memory table', 'Candle lighting', 'Moment of silence', 'Photo display', 'Tribute mention', 'Custom'].map(
                  (type) => (
                    <SelectableCard
                      key={type}
                      selected={tributeType === type}
                      onClick={() => setTributeType(type)}
                      size="sm"
                    >
                      <div className="pr-8">{type}</div>
                    </SelectableCard>
                  )
                )}
              </div>
            </Section>
          )}

          <Input
            label="Any meaningful personal touches you already know you want?"
            value={personalTouches}
            onChange={setPersonalTouches}
            placeholder="Describe special moments or traditions"
          />
        </div>
      </ScreenLayout>
    );
  }

  // Screen 15: Additional Celebrations
  if (currentScreen === 15) {
    return (
      <ScreenLayout
        title="Additional celebrations"
        preamble="Many weddings include more than one moment. Let us know what else is part of your celebration."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={13}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <MultiSelectCard
            options={[
              'Stag party',
              'Hen party',
              'Engagement party',
              'Rehearsal dinner',
              'Post-wedding brunch',
              'Bridal shower',
              'Welcome drinks',
              'Family dinner',
              'Farewell breakfast',
              'Other'
            ]}
            selected={additionalEvents}
            onChange={setAdditionalEvents}
          />

          {additionalEvents.length > 0 && (
            <Section title="Who is organizing these events?">
              <div className="space-y-3">
                {['I am', 'My planner is', 'Friends / family are', 'Different people for different events'].map((org) => (
                  <SelectableCard
                    key={org}
                    selected={eventOrganizer === org}
                    onClick={() => setEventOrganizer(org)}
                    size="sm"
                  >
                    <div className="pr-8">{org}</div>
                  </SelectableCard>
                ))}
              </div>
            </Section>
          )}
        </div>
      </ScreenLayout>
    );
  }

  // NEW SECTION: Cultural Traditions & Wedding Structure
  // Transition Screen (15.5)
  if (currentScreen === 16) {
    return (
      <ScreenLayout
        title=""
        onNext={nextScreen}
        onBack={prevScreen}
        showSkip={false}
        showBack={true}
        currentStep={13}
        totalSteps={23}
        nextLabel="Continue"
      >
        <div className="flex flex-col items-center justify-center min-h-[50vh] text-center px-4">
          <div className="max-w-md space-y-6">
            <div className="w-16 h-16 mx-auto bg-[#f8edeb] rounded-full flex items-center justify-center mb-6">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#d45d78" strokeWidth="2">
                <path d="M12 2L2 7l10 5 10-5-10-5z" />
                <path d="M2 17l10 5 10-5" />
                <path d="M2 12l10 5 10-5" />
              </svg>
            </div>

            <p className="text-gray-600 leading-relaxed" style={{ fontSize: '16px' }}>
              Many celebrations carry traditions, rituals, and meaningful family moments.
            </p>

            <p className="text-[#285301] leading-relaxed font-serif" style={{ fontSize: '18px' }}>
              We'd love to understand yours more deeply.
            </p>
          </div>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 1: Cultural traditions & wedding structure
  if (currentScreen === 17) {
    return (
      <ScreenLayout
        title="Cultural traditions & wedding structure"
        preamble="Every celebration carries meaning, traditions, and stories. Tell us what cultural, spiritual, or family elements matter to you so UDO can support them thoughtfully."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={14}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <div className="bg-[#f8edeb] rounded-2xl p-5 border border-[#f194b2]">
            <p className="text-sm text-gray-700">
              These selections help UDO personalize timelines, reminders, guest planning, vendor recommendations, and ceremony flow.
            </p>
          </div>

          <Section title="What best describes your celebration?">
            <MultiSelectCard
              options={[
                'Single-day celebration',
                'Multi-day celebration',
                'Destination wedding',
                'Religious ceremony',
                'Traditional cultural ceremony',
                'Fusion / multicultural wedding',
                'Private elopement',
                'Civil ceremony',
                'Community-centered celebration',
                'Not sure yet'
              ]}
              selected={culturalCelebrationType}
              onChange={setCulturalCelebrationType}
            />
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 2: Ceremonies & traditions
  if (currentScreen === 18) {
    return (
      <ScreenLayout
        title="Ceremonies & traditions"
        preamble="Many weddings include rituals, celebrations, or meaningful customs beyond the main ceremony."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={15}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="Which traditions or ceremonies are important to your celebration?">
            <MultiSelectCard
              options={[
                'Mehndi / Henna night',
                'Sangeet',
                'Baraat',
                'Tea ceremony',
                'Libation ceremony',
                'Kola nut ceremony',
                'Jumping the broom',
                'Unity candle',
                'Handfasting',
                'Breaking the glass',
                'Haka / cultural performance',
                'Elders blessing',
                'Traditional drumming',
                'Family procession',
                'Prayer ceremony',
                'Ancestor honoring',
                'Traditional dance performances',
                'Gift exchange rituals',
                'Dowry / bride price traditions',
                'Traditional attire changes',
                'Naming ceremony',
                'Other'
              ]}
              selected={culturalTraditions}
              onChange={setCulturalTraditions}
            />
          </Section>

          {culturalTraditions.includes('Other') && (
            <div className="animate-fade-in">
              <Input
                label="Other traditions we should know about?"
                value={otherTraditions}
                onChange={setOtherTraditions}
                placeholder="Describe your traditions"
              />
            </div>
          )}

          <div className="bg-[#f8edeb] rounded-xl p-4">
            <p className="text-xs text-gray-600">
              UDO uses these details to create more culturally aware timelines and planning suggestions.
            </p>
          </div>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 3: Religious & spiritual structure
  if (currentScreen === 19) {
    return (
      <ScreenLayout
        title="Religious & spiritual structure"
        preamble="If faith or spirituality plays a role in your celebration, we want to support it respectfully."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={16}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="Will faith or spirituality shape your wedding experience?">
            <MultiSelectCard
              options={[
                'Christian ceremony',
                'Muslim ceremony',
                'Hindu ceremony',
                'Sikh ceremony',
                'Jewish ceremony',
                'Buddhist ceremony',
                'Indigenous spiritual traditions',
                'Traditional African spiritual traditions',
                'Interfaith ceremony',
                'Secular / non-religious',
                'Prefer not to say',
                'Other'
              ]}
              selected={religiousStructure}
              onChange={setReligiousStructure}
            />
          </Section>

          <div className="bg-white rounded-xl p-4 border border-[#f194b2]">
            <p className="text-xs text-gray-600">
              You can always refine or expand these details later.
            </p>
          </div>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 4: Family involvement
  if (currentScreen === 20) {
    return (
      <ScreenLayout
        title="Family involvement"
        preamble="Every wedding has a different planning dynamic. Help us understand how decisions are typically being made."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={17}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="How involved are family members in planning?">
            <div className="space-y-3">
              {[
                'Mostly couple-led',
                'Collaborative with family',
                'Family-led decisions',
                'Elders heavily involved',
                'Shared planning across households',
                'Planner-led coordination'
              ].map((involvement) => (
                <SelectableCard
                  key={involvement}
                  selected={familyInvolvement === involvement}
                  onClick={() => setFamilyInvolvement(involvement)}
                  size="sm"
                >
                  <div className="pr-8">{involvement}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="Would you like shared planning access later?">
            <div className="space-y-3">
              {['Yes', 'Maybe later', 'No'].map((access) => (
                <SelectableCard
                  key={access}
                  selected={sharedPlanningAccess === access}
                  onClick={() => setSharedPlanningAccess(access)}
                  size="sm"
                >
                  <div className="pr-8">{access}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 5: Guest travel & hospitality
  if (currentScreen === 21) {
    return (
      <ScreenLayout
        title="Guest travel & hospitality"
        preamble="Some weddings involve complex guest travel and hospitality planning."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={18}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="What best describes your guest situation?">
            <MultiSelectCard
              options={[
                'Mostly local guests',
                'International guests',
                'Guests traveling from multiple countries',
                'Visa coordination needed',
                'Hotel blocks needed',
                'Airport coordination needed',
                'Elderly guest accommodations',
                'Child-friendly accommodations',
                'Group transportation needed',
                'Large family travel groups',
                'Welcome events planned'
              ]}
              selected={guestHospitality}
              onChange={setGuestHospitality}
            />
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 6: Attire & presentation
  if (currentScreen === 22) {
    return (
      <ScreenLayout
        title="Attire & presentation"
        preamble="Outfits and presentation are often a meaningful part of the celebration."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={19}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="What matters most for attire planning?">
            <MultiSelectCard
              options={[
                'Multiple outfit changes',
                'Traditional attire',
                'Western attire',
                'Coordinated family attire',
                'Bridal styling support',
                'Groom styling support',
                'Beauty timeline planning',
                'Jewelry coordination',
                'Custom tailoring',
                'Cultural dressing assistance',
                'Headpiece / turban coordination',
                'Not sure yet'
              ]}
              selected={attirePlanning}
              onChange={setAttirePlanning}
            />
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 7: Celebration structure
  if (currentScreen === 23) {
    return (
      <ScreenLayout
        title="Celebration structure"
        preamble="Wedding celebrations vary greatly in timing and flow."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={20}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <Section title="How long will your celebration likely be?">
            <div className="space-y-3">
              {[
                'Short ceremony',
                'Half-day celebration',
                'Full-day wedding',
                'Weekend celebration',
                'Three-day celebration',
                'Flexible / open format',
                'Not sure yet'
              ].map((duration) => (
                <SelectableCard
                  key={duration}
                  selected={celebrationDuration === duration}
                  onClick={() => setCelebrationDuration(duration)}
                  size="sm"
                >
                  <div className="pr-8">{duration}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>

          <Section title="What atmosphere feels most like your celebration?">
            <div className="space-y-3">
              {[
                'Intimate & emotional',
                'High-energy & social',
                'Elegant & formal',
                'Family-centered',
                'Cultural & traditional',
                'Luxury experience',
                'Relaxed & peaceful',
                'Community celebration'
              ].map((atmosphere) => (
                <SelectableCard
                  key={atmosphere}
                  selected={celebrationAtmosphere === atmosphere}
                  onClick={() => setCelebrationAtmosphere(atmosphere)}
                  size="sm"
                >
                  <div className="pr-8">{atmosphere}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // NEW Screen 8: How UDO adapts to you
  if (currentScreen === 24) {
    // Generate dynamic insights based on selections
    const insights: string[] = [];

    if (culturalCelebrationType.includes('Multi-day celebration')) {
      insights.push("UDO will help structure your multi-day celebration thoughtfully.");
    }
    if (guestHospitality.includes('International guests') || guestHospitality.includes('Guests traveling from multiple countries')) {
      insights.push("We'll help coordinate hospitality and travel details.");
    }
    if (culturalTraditions.length > 3) {
      insights.push("Your planning journey may involve multiple ceremonies and traditions.");
    }
    if (familyInvolvement.includes('Family-led') || familyInvolvement.includes('Elders heavily involved')) {
      insights.push("Family collaboration tools may be especially helpful for your wedding.");
    }
    if (culturalCelebrationType.includes('Fusion / multicultural wedding')) {
      insights.push("Your selections suggest a beautifully blended cultural experience.");
    }
    if (celebrationDuration === 'Weekend celebration' || celebrationDuration === 'Three-day celebration') {
      insights.push("Multi-day timelines will be specially adapted to your needs.");
    }
    if (insights.length === 0) {
      insights.push("UDO will create a personalized planning experience just for you.");
      insights.push("Your selections will help us provide thoughtful, relevant guidance.");
    }

    return (
      <ScreenLayout
        title="How UDO adapts to you"
        preamble=""
        onNext={nextScreen}
        onBack={prevScreen}
        showSkip={false}
        currentStep={21}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <div className="space-y-4">
            {insights.map((insight, idx) => (
              <div
                key={idx}
                className="bg-[#f8edeb] rounded-2xl p-5 border border-[#f194b2] animate-fade-in"
                style={{ animationDelay: `${idx * 0.1}s` }}
              >
                <div className="flex items-start gap-3">
                  <div className="w-6 h-6 rounded-full bg-[#d45d78] flex items-center justify-center flex-shrink-0 mt-0.5">
                    <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                      <path
                        d="M3 7L6 10L11 4"
                        stroke="white"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </div>
                  <p className="text-sm text-[#285301]">{insight}</p>
                </div>
              </div>
            ))}
          </div>

          <Section title="Planning support style">
            <div className="space-y-3">
              {[
                'Minimal reminders',
                'Weekly guidance',
                'Structured planning support',
                'Hands-on support'
              ].map((style) => (
                <SelectableCard
                  key={style}
                  selected={planningSupportStyle === style}
                  onClick={() => setPlanningSupportStyle(style)}
                  size="sm"
                >
                  <div className="pr-8">{style}</div>
                </SelectableCard>
              ))}
            </div>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  // Screen 24: Honeymoon (previously 16)
  if (currentScreen === 25) {
    return (
      <ScreenLayout
        title="Honeymoon plans"
        preamble="If a honeymoon is part of your plans, we can keep it in mind as part of your wider journey."
        onNext={nextScreen}
        onBack={prevScreen}
        onSkip={skipToFinal}
        showSkip={true}
        currentStep={22}
        totalSteps={23}
      >
        <div className="space-y-6 mt-4">
          <p className="text-xs text-gray-600">You can keep this simple for now.</p>

          <div className="grid grid-cols-3 gap-3">
            {['Yes', 'Not yet', 'No'].map((option) => (
              <SelectableCard
                key={option}
                selected={planningHoneymoon === option}
                onClick={() => setPlanningHoneymoon(option)}
                size="sm"
              >
                <div className="text-center text-xs pr-6">{option}</div>
              </SelectableCard>
            ))}
          </div>

          {planningHoneymoon === 'Yes' && (
            <div className="space-y-6 animate-fade-in">
              <Input
                label="Destination"
                value={honeymoonDestination}
                onChange={setHoneymoonDestination}
                placeholder="Where are you going?"
              />
              <Input label="Budget range" value={honeymoonBudget} onChange={setHoneymoonBudget} placeholder="Enter amount" />
              <Section title="Timing">
                <div className="grid grid-cols-2 gap-3">
                  {['Immediate', 'Delayed'].map((timing) => (
                    <SelectableCard
                      key={timing}
                      selected={honeymoonTiming === timing}
                      onClick={() => setHoneymoonTiming(timing)}
                      size="sm"
                    >
                      <div className="text-center pr-6">{timing}</div>
                    </SelectableCard>
                  ))}
                </div>
              </Section>
            </div>
          )}
        </div>
      </ScreenLayout>
    );
  }

  // Screen 25: Insurance (previously 17)
  if (currentScreen === 26) {
    return (
      <ScreenLayout
        title="Wedding insurance"
        preamble="A little protection can bring peace of mind."
        onNext={() => alert('🎉 Welcome to UDO! Your wedding planning journey begins now.')}
        onBack={prevScreen}
        onSkip={false}
        showSkip={false}
        currentStep={23}
        totalSteps={23}
        nextLabel="Enter Dashboard"
      >
        <div className="space-y-6 mt-4">
          <div className="bg-[#f8edeb] p-4 rounded-xl border border-[#f194b2]">
            <div className="flex items-start gap-2">
              <Info size={18} className="text-[#d45d78] mt-0.5 flex-shrink-0" />
              <div className="text-sm text-gray-700">
                Wedding insurance can help protect you against disruptions such as cancellations, supplier issues, or event-day problems.
              </div>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            {['Yes', 'No', 'Not sure'].map((option) => (
              <SelectableCard key={option} selected={insurance === option} onClick={() => setInsurance(option)} size="sm">
                <div className="text-center text-xs pr-6">{option}</div>
              </SelectableCard>
            ))}
          </div>

          <p className="text-xs text-gray-600">If you are unsure, that is completely fine — we can revisit this later.</p>
        </div>
      </ScreenLayout>
    );
  }

  // Old Support Preferences screen removed - functionality now in Cultural Traditions module (screen 24)

  return (
    <div className="max-w-md mx-auto bg-white min-h-screen">
      <ScreenLayout
        title="Loading..."
        onNext={nextScreen}
        onBack={prevScreen}
        currentStep={currentScreen}
      >
        <p className="text-center text-gray-500">Screen {currentScreen}</p>
      </ScreenLayout>

      {showModal && (
        <InfoModal
          title={modalContent.title}
          description={modalContent.description}
          onClose={() => setShowModal(false)}
        />
      )}
    </div>
  );
}

export default App;
