import { Users, Grid3x3, DollarSign, Clock, Camera, Bell, MapPin, Shield, Link2 } from 'lucide-react';
import { C, Section, Heading, Lead, Eyebrow } from './shared';

const features = [
  { icon: Users, title: 'Guest & RSVP management', description: 'Track invitations, RSVPs, plus-ones, guest details, and meal selections in one place.' },
  { icon: Grid3x3, title: 'Seating & floor planning', description: 'Organize guest placement with a clear planner that helps your day run more smoothly.' },
  { icon: DollarSign, title: 'Budget & payment tracking', description: 'Keep your budget visible, track deposits and balances, and stay confident in your spending.' },
  { icon: Clock, title: 'Timeline & day-of schedule', description: 'Build your full run of show so everyone knows where to be and when.' },
  { icon: Link2, title: 'Wedding page for guests', description: 'Share one beautifully designed link with your details, RSVP flow, and updates.' },
  { icon: Bell, title: 'Announcements & messaging', description: 'Keep guests informed with reminders and updates without chasing messages.' },
  { icon: Camera, title: 'Photo & memory sharing', description: 'Collect and organize memories in one elegant shared space.' },
  { icon: Shield, title: 'Privacy & permissions', description: 'Decide what guests can view, upload, or interact with.' },
  { icon: MapPin, title: 'Location & navigation', description: 'Help guests find venues, nearby stays, and important places with ease.' },
];

export function Features() {
  return (
    <Section id="features" tone="white" width="wide">
      <div className="space-y-4 text-center">
        <Eyebrow>Everything you need</Eyebrow>
        <Heading>One app for the whole wedding</Heading>
        <Lead className="mx-auto max-w-xl">
          A complete platform designed to reduce stress and create clarity at every stage.
        </Lead>
      </div>

      <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {features.map(({ icon: Icon, title, description }) => (
          <div
            key={title}
            className="rounded-[26px] p-7 transition-shadow hover:shadow-[0_10px_30px_-10px_rgba(216,144,154,0.25)]"
            style={{ backgroundColor: C.cream, border: `1.5px solid ${C.line}` }}
          >
            <span
              className="inline-flex h-11 w-11 items-center justify-center rounded-full"
              style={{ backgroundColor: C.tan }}
            >
              <Icon className="h-5 w-5" style={{ color: C.rose }} />
            </span>
            <h3 className="mt-4 text-[17px] leading-[1.3] tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
              {title}
            </h3>
            <p className="mt-2 text-[15px] leading-[1.6]" style={{ color: C.body }}>
              {description}
            </p>
          </div>
        ))}
      </div>
    </Section>
  );
}
