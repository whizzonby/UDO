import { Sparkles, FolderKanban, Share2 } from 'lucide-react';
import { C, Section, Heading, Eyebrow, IconChip } from './shared';

const steps = [
  {
    icon: Sparkles,
    title: 'Create your wedding',
    description: 'Set your date, guest count, event structure, and overall vision.',
    tag: 'Personalized as you go',
  },
  {
    icon: FolderKanban,
    title: 'Organize everything in one place',
    description: 'Manage guests, seating, budget, vendors, details, reminders, and your run of show.',
    tag: 'Built around your day',
  },
  {
    icon: Share2,
    title: 'Share beautifully and stay aligned',
    description: 'Send one elegant guest link, collect RSVPs, share updates, and keep everyone informed.',
    tag: 'Calm communication',
  },
];

export function HowItWorks() {
  return (
    <Section id="how-it-works" tone="white" width="wide">
      <div className="space-y-4 text-center">
        <Eyebrow>How it works</Eyebrow>
        <Heading>A calmer way to plan, start to finish</Heading>
      </div>

      <ol className="mt-12 grid gap-6 md:grid-cols-3">
        {steps.map(({ icon: Icon, title, description, tag }, i) => (
          <li
            key={title}
            className="relative rounded-[28px] p-7 lg:p-8"
            style={{ backgroundColor: C.cream, border: `1.5px solid ${C.line}` }}
          >
            <span
              className="absolute -top-3.5 left-7 flex h-9 w-9 items-center justify-center rounded-full text-[15px] font-bold text-white"
              style={{ backgroundColor: C.rose, boxShadow: '0 2px 8px rgba(216,144,154,0.25)' }}
            >
              {i + 1}
            </span>

            <div className="pt-3">
              <IconChip>
                <Icon className="h-5 w-5" style={{ color: C.rose }} />
              </IconChip>
              <h3 className="mt-4 text-[19px] leading-[1.3] tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
                {title}
              </h3>
              <p className="mt-2.5 text-[15px] leading-[1.6]" style={{ color: C.body }}>
                {description}
              </p>
              <span
                className="mt-4 inline-flex rounded-full px-3 py-1.5 text-[13px]"
                style={{ backgroundColor: C.tan, color: C.body, fontWeight: 450 }}
              >
                {tag}
              </span>
            </div>
          </li>
        ))}
      </ol>
    </Section>
  );
}
