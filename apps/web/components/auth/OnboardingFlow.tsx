'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ScreenLayout } from './ScreenLayout';
import { SelectableCard } from './SelectableCard';
import { MultiSelectCard } from './MultiSelectCard';
import { Section } from './Section';
import { Input } from './Input';
import { Toggle } from './Toggle';
import { InfoModal } from './InfoModal';
import { WelcomeMessageScreen } from './WelcomeMessageScreen';
import { Info } from 'lucide-react';
import { api } from '@/lib/api';
import { getToken, getUser } from '@/lib/auth';

export default function OnboardingFlow() {
  const router = useRouter();
  const [currentScreen, setCurrentScreen] = useState(0);
  const [showModal, setShowModal] = useState(false);
  const [modalContent, setModalContent] = useState({ title: '', description: '' });
  const [submitting, setSubmitting] = useState(false);

  // All onboarding state
  const [role, setRole] = useState('This is my wedding');
  const [decisionStyle, setDecisionStyle] = useState('We make decisions together');
  const [planningApproach, setPlanningApproach] = useState('Self-managed');
  const [weddingType, setWeddingType] = useState('Destination');
  const [season, setSeason] = useState('Summer');
  const [dateStatus, setDateStatus] = useState('Fixed');
  const [weddingDate, setWeddingDate] = useState('');
  const [timeOfDay, setTimeOfDay] = useState('Evening');
  const [eventStructure, setEventStructure] = useState(['Ceremony', 'Reception']);
  const [country, setCountry] = useState('');
  const [city, setCity] = useState('');
  const [venueStatus, setVenueStatus] = useState('Shortlisting');
  const [guestTravel, setGuestTravel] = useState('Mixed');
  const [travelSupport, setTravelSupport] = useState<string[]>([]);
  const [guestExperience, setGuestExperience] = useState<string[]>([]);
  const [totalBudget, setTotalBudget] = useState('');
  const [budgetStructure, setBudgetStructure] = useState('Flexible budget');
  const [priorities, setPriorities] = useState<string[]>([]);
  const [culturalTraditions, setCulturalTraditions] = useState<string[]>([]);
  const [planningSupportStyle, setPlanningSupportStyle] = useState('Weekly guidance');

  const nextScreen = () => setCurrentScreen((prev) => Math.min(prev + 1, 8));
  const prevScreen = () => setCurrentScreen((prev) => Math.max(prev - 1, 0));
  const skipToFinal = () => setCurrentScreen(8);

  const showInfo = (title: string, description: string) => {
    setModalContent({ title, description });
    setShowModal(true);
  };

  const handleFinish = async () => {
    setSubmitting(true);
    try {
      const token = getToken();
      await api.post(
        '/onboarding',
        {
          role,
          decision_style: decisionStyle,
          planning_approach: planningApproach,
          wedding_type: weddingType,
          season,
          date_status: dateStatus,
          wedding_date: weddingDate || null,
          time_of_day: timeOfDay,
          event_structure: eventStructure,
          country,
          city,
          venue_status: venueStatus,
          guest_travel: guestTravel,
          travel_support: travelSupport,
          guest_experience: guestExperience,
          total_budget: totalBudget ? Number(totalBudget) : null,
          budget_structure: budgetStructure,
          priorities,
          cultural_traditions: culturalTraditions,
          planning_support_style: planningSupportStyle,
        },
        token ?? undefined
      );
      router.replace('/dashboard/home');
    } catch {
      router.replace('/dashboard/home');
    } finally {
      setSubmitting(false);
    }
  };

  if (currentScreen === 0) {
    return <WelcomeMessageScreen onBegin={() => setCurrentScreen(1)} />;
  }

  if (currentScreen === 1) {
    return (
      <ScreenLayout title="Tell us about your role" preamble="Every wedding is different. Knowing your role helps us shape the right planning experience for you." onNext={nextScreen} onSkip={skipToFinal} showBack={false} showSkip={true} currentStep={1} totalSteps={8}>
        <div className="space-y-3 mt-4">
          {['This is my wedding', 'We are planning together', 'I am supporting the planning', 'I am the wedding planner', 'I am part of a planning team'].map((r) => (
            <SelectableCard key={r} selected={role === r} onClick={() => setRole(r)}>
              <div className="pr-8">{r}</div>
            </SelectableCard>
          ))}
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 2) {
    return (
      <ScreenLayout title="Shape your wedding experience" preamble="This section helps us understand the structure, setting, and feeling of your celebration." onNext={nextScreen} onBack={prevScreen} onSkip={skipToFinal} showSkip={true} currentStep={2} totalSteps={8}>
        <div className="space-y-6 mt-4">
          <Section title="Wedding type">
            <div className="grid grid-cols-2 gap-3">
              {['Destination', 'Local', 'Hometown', 'Multi-country'].map((t) => (
                <SelectableCard key={t} selected={weddingType === t} onClick={() => setWeddingType(t)} size="sm"><div className="text-center text-sm pr-6">{t}</div></SelectableCard>
              ))}
            </div>
          </Section>
          <Section title="Date">
            <div className="space-y-3">
              <div className="grid grid-cols-3 gap-3">
                {['Fixed', 'Flexible', 'Not decided'].map((d) => (
                  <SelectableCard key={d} selected={dateStatus === d} onClick={() => setDateStatus(d)} size="sm"><div className="text-center text-xs pr-6">{d}</div></SelectableCard>
                ))}
              </div>
              {dateStatus === 'Fixed' && <Input label="" value={weddingDate} onChange={setWeddingDate} placeholder="Enter your wedding date" />}
            </div>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 3) {
    return (
      <ScreenLayout title="Location & guest travel" preamble="This helps us plan around venue progress, travel needs, and guest coordination." onNext={nextScreen} onBack={prevScreen} onSkip={skipToFinal} showSkip={true} currentStep={3} totalSteps={8}>
        <div className="space-y-6 mt-4">
          <Section title="Location details">
            <div className="space-y-3">
              <Input label="Country" value={country} onChange={setCountry} placeholder="Enter country" />
              <Input label="City" value={city} onChange={setCity} placeholder="Enter city" />
            </div>
          </Section>
          <Section title="Guest travel profile">
            <div className="space-y-3">
              {['Mostly local', 'Mixed', 'Mostly international'].map((t) => (
                <SelectableCard key={t} selected={guestTravel === t} onClick={() => setGuestTravel(t)} size="sm"><div className="pr-8">{t}</div></SelectableCard>
              ))}
            </div>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 4) {
    return (
      <ScreenLayout title="Design your guest experience" preamble="The choices you make here will shape your guest dashboard, communications, reminders, and planning recommendations." onNext={nextScreen} onBack={prevScreen} onSkip={skipToFinal} showSkip={true} currentStep={4} totalSteps={8}>
        <div className="mt-4">
          <MultiSelectCard
            options={['Children included', 'Adults-only event', 'Accommodation required', 'Transport required', 'Meal selection required', 'Dietary tracking required', 'Accessibility needs', 'Welcome packs / gifting', 'Guest communication portal', 'RSVP reminders', 'Hotel block coordination', 'Airport transfer support']}
            selected={guestExperience}
            onChange={setGuestExperience}
          />
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 5) {
    return (
      <ScreenLayout title="Budget & spending style" preamble="We are not just asking how much you want to spend — we are learning how you want to spend it." onNext={nextScreen} onBack={prevScreen} onSkip={skipToFinal} showSkip={true} currentStep={5} totalSteps={8}>
        <div className="space-y-6 mt-4">
          <Section title="Total budget">
            <Input label="" value={totalBudget} onChange={setTotalBudget} placeholder="Enter amount" />
          </Section>
          <Section title="Structure">
            <div className="space-y-3">
              {['Fixed budget', 'Flexible budget', 'Priority-led budget'].map((s) => (
                <SelectableCard key={s} selected={budgetStructure === s} onClick={() => setBudgetStructure(s)} size="sm"><div className="pr-8">{s}</div></SelectableCard>
              ))}
            </div>
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 6) {
    return (
      <ScreenLayout title="Your wedding priorities" preamble="We really want to know what makes you light up." onNext={nextScreen} onBack={prevScreen} onSkip={skipToFinal} showSkip={true} currentStep={6} totalSteps={8}>
        <div className="mt-4">
          <p className="text-sm text-gray-600 mb-4">Choose up to 5 priorities.</p>
          <MultiSelectCard
            options={['Guest experience', 'Food & beverage quality', 'Photography & videography', 'Visual design & decor', 'Entertainment', 'Convenience & ease', 'Cultural traditions', 'Budget efficiency', 'Luxury / exclusivity', 'Intimacy', 'Family involvement', 'Emotional meaning', 'Timeless elegance', 'Stress reduction', 'Smooth logistics']}
            selected={priorities}
            onChange={setPriorities}
            maxSelections={5}
          />
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 7) {
    return (
      <ScreenLayout title="Cultural traditions & wedding structure" preamble="Every celebration carries meaning, traditions, and stories." onNext={nextScreen} onBack={prevScreen} onSkip={skipToFinal} showSkip={true} currentStep={7} totalSteps={8}>
        <div className="space-y-6 mt-4">
          <Section title="Traditions important to your celebration">
            <MultiSelectCard
              options={['Mehndi / Henna night', 'Sangeet', 'Baraat', 'Tea ceremony', 'Libation ceremony', 'Jumping the broom', 'Unity candle', 'Breaking the glass', 'Traditional drumming', 'Family procession', 'Prayer ceremony', 'Traditional dance performances', 'Other']}
              selected={culturalTraditions}
              onChange={setCulturalTraditions}
            />
          </Section>
        </div>
      </ScreenLayout>
    );
  }

  if (currentScreen === 8) {
    return (
      <ScreenLayout
        title="You are all set"
        preamble="Your wedding planning workspace is ready."
        onNext={handleFinish}
        onBack={prevScreen}
        showSkip={false}
        currentStep={8}
        totalSteps={8}
        nextLabel={submitting ? 'Setting up…' : 'Enter Dashboard'}
      >
        <div className="space-y-4 mt-6">
          <div className="bg-[#f8edeb] rounded-2xl p-5 border border-[#f194b2]">
            <p className="text-sm text-[#285301] font-medium mb-1">Welcome to Udo</p>
            <p className="text-sm text-gray-600">Your personalized wedding planning experience is ready. Everything you need — guests, planning, live coordination, and memories — in one calm space.</p>
          </div>
        </div>
      </ScreenLayout>
    );
  }

  return null;
}
