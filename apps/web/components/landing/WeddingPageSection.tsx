import { Check } from 'lucide-react';
import { C, Section, Heading, Lead, Eyebrow } from './shared';

const includes = [
  'RSVP collection',
  'Guest contact details',
  'Dietary requirements',
  'Event details & schedule',
  'A contact number for questions',
];

export function WeddingPageSection() {
  return (
    <Section tone="cream">
      <div className="space-y-5 text-center">
        <Eyebrow>Guest wedding page</Eyebrow>
        <Heading className="mx-auto max-w-xl">
          Your wedding, <span style={{ color: C.rose }}>all in one link</span>
        </Heading>
        <Lead className="mx-auto max-w-xl">
          Create a beautiful in-app wedding page your guests can open anytime — no accounts,
          no confusion.
        </Lead>
      </div>

      <ul className="mx-auto mt-8 grid max-w-md gap-3 sm:grid-cols-2">
        {includes.map((item) => (
          <li key={item} className="flex items-center gap-2.5">
            <span
              className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full"
              style={{ backgroundColor: C.tan }}
            >
              <Check className="h-3.5 w-3.5" style={{ color: C.rose }} />
            </span>
            <span className="text-[15px]" style={{ color: C.body }}>
              {item}
            </span>
          </li>
        ))}
      </ul>

      <p
        className="mx-auto mt-8 max-w-xl rounded-[22px] p-6 text-center text-[15px] leading-[1.65]"
        style={{ backgroundColor: C.creamDeep, color: C.body }}
      >
        Guests get a simple link to view your details, RSVP, and stay updated — everything
        stays inside the app.
      </p>
    </Section>
  );
}
