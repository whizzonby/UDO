import { Image as ImageIcon } from 'lucide-react';
import { C, Section, Heading, Lead, IconChip } from './shared';

export function LookbookSection() {
  return (
    <Section tone="white">
      <div className="flex flex-col items-center text-center">
        <IconChip>
          <ImageIcon className="h-5 w-5" style={{ color: C.rose }} />
        </IconChip>
        <Heading className="mt-5 max-w-xl">
          Create your <span style={{ color: C.rose }}>wedding lookbook</span>
        </Heading>
        <Lead className="mt-5 max-w-xl">
          Upload inspiration, themes, and visual ideas so your entire wedding aesthetic lives
          in one place — mood boards, color palettes, dress ideas, florals, and venue shots,
          all easy to share with your partner or vendors.
        </Lead>
      </div>
    </Section>
  );
}
