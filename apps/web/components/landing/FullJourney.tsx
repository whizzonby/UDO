import { PenTool, Calendar, MessageCircle, CheckSquare, Camera } from 'lucide-react';
import { C, Section, Heading, Lead } from './shared';

const stages = [
  { icon: PenTool, label: 'Planning' },
  { icon: Calendar, label: 'Coordination' },
  { icon: MessageCircle, label: 'Communication' },
  { icon: CheckSquare, label: 'Execution' },
  { icon: Camera, label: 'Memory keeping' },
];

export function FullJourney() {
  return (
    <Section tone="white" width="wide">
      <div className="space-y-5 text-center">
        <Heading>Designed for the full journey</Heading>
        <Lead className="mx-auto max-w-2xl">
          From the first guest list to your final schedule and shared memories, Udo keeps you
          organized through every stage.
        </Lead>
      </div>

      <div className="mt-11 grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-5">
        {stages.map(({ icon: Icon, label }) => (
          <div
            key={label}
            className="flex flex-col items-center gap-3.5 rounded-[24px] p-6"
            style={{ backgroundColor: C.cream, border: `1.5px solid ${C.line}` }}
          >
            <span
              className="flex h-12 w-12 items-center justify-center rounded-full"
              style={{ backgroundColor: C.rose }}
            >
              <Icon className="h-5 w-5 text-white" />
            </span>
            <span className="text-center text-[15px] tracking-tight" style={{ color: C.ink, fontWeight: 600 }}>
              {label}
            </span>
          </div>
        ))}
      </div>
    </Section>
  );
}
