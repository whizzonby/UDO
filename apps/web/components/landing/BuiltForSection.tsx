import { Heart, ClipboardList } from 'lucide-react';
import { C, Section, Heading, IconChip } from './shared';

const audiences = [
  {
    icon: Heart,
    title: 'Couples',
    body: 'Stay organized, reduce overwhelm, and keep every decision, guest detail, and important moment in one place.',
    tone: C.cream,
  },
  {
    icon: ClipboardList,
    title: 'Planners',
    body: 'Manage weddings with more structure, clearer client coordination, and a smoother flow from first meeting to the last dance.',
    tone: C.tan,
  },
];

export function BuiltForSection() {
  return (
    <Section tone="cream" width="wide">
      <Heading className="text-center">Built for couples and planners</Heading>

      <div className="mt-10 grid gap-6 sm:grid-cols-2">
        {audiences.map(({ icon: Icon, title, body, tone }) => (
          <div
            key={title}
            className="rounded-[28px] p-8 lg:p-9"
            style={{ backgroundColor: tone, border: `1.5px solid ${C.line}` }}
          >
            <IconChip filled>
              <Icon className="h-5 w-5 text-white" />
            </IconChip>
            <h3 className="mt-5 text-[22px] tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
              {title}
            </h3>
            <p className="mt-3 text-[16px] leading-[1.65]" style={{ color: C.body }}>
              {body}
            </p>
          </div>
        ))}
      </div>
    </Section>
  );
}
