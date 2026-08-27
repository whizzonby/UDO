import { C, Section, Heading, Eyebrow } from './shared';

const screens = [
  {
    title: 'Wedding Dashboard',
    caption: 'See everything at a glance',
    url: 'https://images.unsplash.com/photo-1622304078573-f63776457d77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwcGxhbm5pbmclMjBub3RlYm9vayUyMG1pbmltYWx8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    title: 'RSVP & Guest Tracking',
    caption: "Know who's coming, who needs a reminder",
    url: 'https://images.unsplash.com/photo-1665072200747-5b4680684d45?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwZ3Vlc3QlMjBib29rfGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    title: 'Seating Planner',
    caption: 'Thoughtful table planning without the usual chaos',
    url: 'https://images.unsplash.com/photo-1662152334682-1157099fe7e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjB3ZWRkaW5nJTIwc2VhdGluZyUyMGNoYXJ0fGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    title: 'Guest Wedding Page',
    caption: 'One elegant link for everything they need',
    url: 'https://images.unsplash.com/photo-1768900315637-146ae46a2fb9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVnYW50JTIwd2VkZGluZyUyMGNvdXBsZSUyMHBlYWNlZnVsfGVufDF8fHx8MTc3NDk5NjM3OHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
  {
    title: 'Lookbook',
    caption: 'Organize your inspiration in one place',
    url: 'https://images.unsplash.com/photo-1771142480968-6036543055f7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibHVzaCUyMHBpbmslMjByb3NlcyUyMHdlZGRpbmd8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
  },
];

export function AppPreview() {
  return (
    <Section tone="cream" width="full">
      <div className="space-y-4 text-center">
        <Eyebrow>A look inside</Eyebrow>
        <Heading>See Udo in action</Heading>
      </div>

      <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-5">
        {screens.map((screen) => (
          <figure key={screen.title} className="group">
            <div
              className="overflow-hidden rounded-[26px]"
              style={{ backgroundColor: C.creamDeep, boxShadow: '0 12px 30px -8px rgba(216,144,154,0.22)' }}
            >
              <div className="aspect-[9/16] overflow-hidden">
                <img
                  src={screen.url}
                  alt={screen.title}
                  className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                />
              </div>
            </div>
            <figcaption className="mt-3.5 text-center">
              <p className="text-[15px] tracking-tight" style={{ color: C.ink, fontWeight: 600 }}>
                {screen.title}
              </p>
              <p className="mt-1 text-[13px] leading-[1.5]" style={{ color: C.body }}>
                {screen.caption}
              </p>
            </figcaption>
          </figure>
        ))}
      </div>
    </Section>
  );
}
