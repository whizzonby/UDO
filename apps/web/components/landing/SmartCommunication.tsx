import { Mail, Bell, Calendar } from 'lucide-react';
import { C, Section, Heading, Lead, IconChip } from './shared';

const items = [
  { icon: Mail, title: 'Email notifications', description: 'Guests receive key updates by email.' },
  { icon: Bell, title: 'RSVP reminders', description: 'Automatic nudges for pending RSVPs.' },
  { icon: Calendar, title: 'Schedule updates', description: 'Instant notice when anything changes.' },
];

export function SmartCommunication() {
  return (
    <Section tone="cream" width="wide">
      <div className="space-y-5 text-center">
        <Heading>
          Keep everyone <span style={{ color: C.rose }}>in the loop</span>
        </Heading>
        <Lead className="mx-auto max-w-xl">
          Send updates, reminders, and important information straight to your guests — without
          chasing messages.
        </Lead>
      </div>

      <div className="mt-11 grid gap-5 md:grid-cols-3">
        {items.map(({ icon: Icon, title, description }) => (
          <div
            key={title}
            className="rounded-[26px] p-8 text-center"
            style={{ backgroundColor: C.white, border: `1.5px solid ${C.line}` }}
          >
            <div className="flex justify-center">
              <IconChip size="lg">
                <Icon className="h-6 w-6" style={{ color: C.rose }} />
              </IconChip>
            </div>
            <h3 className="mt-5 text-[18px] tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
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
