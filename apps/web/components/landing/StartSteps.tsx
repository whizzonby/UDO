import { PenLine, Users, Link as LinkIcon, Sparkles } from 'lucide-react';
import { C, Section, Heading, IconChip } from './shared';

const steps = [
  { icon: PenLine, title: 'Create your wedding' },
  { icon: Users, title: 'Add your guests' },
  { icon: LinkIcon, title: 'Share your link' },
  { icon: Sparkles, title: 'Everything updates automatically' },
];

export function StartSteps() {
  return (
    <Section tone="white" width="wide">
      <Heading className="text-center">Start in minutes</Heading>

      <div className="mt-11 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
        {steps.map(({ icon: Icon, title }) => (
          <div key={title} className="flex flex-col items-center text-center">
            <IconChip size="lg">
              <Icon className="h-6 w-6" style={{ color: C.rose }} />
            </IconChip>
            <p className="mt-4 text-[15px]" style={{ color: C.body, fontWeight: 500 }}>
              {title}
            </p>
          </div>
        ))}
      </div>
    </Section>
  );
}
