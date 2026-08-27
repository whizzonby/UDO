import { CheckCircle2, Users, FolderKanban, Brain } from 'lucide-react';
import { C, Section, Heading, Lead } from './shared';

const benefits = [
  { icon: Brain, text: 'Know what matters next' },
  { icon: Users, text: 'Keep guests organized' },
  { icon: FolderKanban, text: 'Centralize every detail' },
  { icon: CheckCircle2, text: 'Feel more in control' },
];

export function StressRelief() {
  return (
    <Section tone="tan">
      <div className="space-y-5 text-center">
        <Heading>
          Less chasing. Less forgetting.
          <br />
          <span style={{ color: C.rose }}>Less overwhelm.</span>
        </Heading>
        <Lead className="mx-auto max-w-2xl">
          Udo is built to reduce the invisible stress of wedding planning — the constant
          checking, reminding, searching, and second-guessing that makes the process feel
          heavier than it should. It gives you structure, visibility, and a calmer way
          through each stage.
        </Lead>

        <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
          {benefits.map(({ icon: Icon, text }) => (
            <div
              key={text}
              className="flex items-center gap-2.5 rounded-full px-4 py-2.5"
              style={{ backgroundColor: C.white, border: `1.5px solid ${C.line}` }}
            >
              <Icon className="h-4 w-4" style={{ color: C.rose }} />
              <span className="text-[14px]" style={{ color: C.body, fontWeight: 450 }}>
                {text}
              </span>
            </div>
          ))}
        </div>
      </div>
    </Section>
  );
}
