import { C, Section, Heading, Lead, Eyebrow } from './shared';

export function WhyUdo() {
  return (
    <Section tone="white">
      <div className="space-y-5 text-center">
        <Eyebrow>Why Udo</Eyebrow>
        <Heading className="mx-auto max-w-xl">
          Udo means <span style={{ color: C.rose }}>peace</span>.
        </Heading>
        <Lead className="mx-auto max-w-2xl">
          It is built for couples and planners who want clarity, structure, and a more
          thoughtful planning experience. Instead of juggling notes, guest lists, messages,
          timelines, vendors, and last-minute details across a dozen places, Udo brings
          everything together into one calm, beautifully organized space.
        </Lead>
      </div>
    </Section>
  );
}
