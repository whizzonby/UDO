import { C, Section, Heading, Lead } from './shared';

const mockups = [
  {
    label: 'Dashboard',
    url: 'https://images.unsplash.com/photo-1622304078573-f63776457d77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwcGxhbm5pbmclMjBub3RlYm9vayUyMG1pbmltYWx8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    label: 'Seating',
    url: 'https://images.unsplash.com/photo-1662152334682-1157099fe7e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjB3ZWRkaW5nJTIwc2VhdGluZyUyMGNoYXJ0fGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    label: 'Guest view',
    url: 'https://images.unsplash.com/photo-1665072200747-5b4680684d45?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwZ3Vlc3QlMjBib29rfGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    label: 'Gallery',
    url: 'https://images.unsplash.com/photo-1771142480968-6036543055f7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibHVzaCUyMHBpbmslMjByb3NlcyUyMHdlZGRpbmd8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
];

export function ProductPreview() {
  return (
    <Section tone="cream" width="full">
      <div className="space-y-4 text-center">
        <Heading>
          Beautiful design, <span style={{ color: C.rose }}>real power</span>
        </Heading>
        <Lead className="mx-auto max-w-xl">
          An elegant interface built to make every task feel simple.
        </Lead>
      </div>

      <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {mockups.map((mockup) => (
          <figure key={mockup.label} className="group">
            <div
              className="overflow-hidden rounded-[22px]"
              style={{ backgroundColor: C.creamDeep, boxShadow: '0 12px 30px -8px rgba(216,144,154,0.2)' }}
            >
              <div className="aspect-[3/4] overflow-hidden">
                <img
                  src={mockup.url}
                  alt={mockup.label}
                  className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                />
              </div>
            </div>
            <figcaption className="mt-3.5 text-center text-[14px] tracking-tight" style={{ color: C.ink, fontWeight: 600 }}>
              {mockup.label}
            </figcaption>
          </figure>
        ))}
      </div>
    </Section>
  );
}
