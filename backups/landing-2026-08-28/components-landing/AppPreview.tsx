export function AppPreview() {
  const screens = [
    {
      title: "Wedding Dashboard",
      caption: "See everything at a glance",
      url: "https://images.unsplash.com/photo-1622304078573-f63776457d77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwcGxhbm5pbmclMjBub3RlYm9vayUyMG1pbmltYWx8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    },
    {
      title: "RSVP & Guest Tracking",
      caption: "Know who's coming, who needs a reminder",
      url: "https://images.unsplash.com/photo-1665072200747-5b4680684d45?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwZ3Vlc3QlMjBib29rfGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    },
    {
      title: "Seating Planner",
      caption: "Thoughtful table planning without the usual chaos",
      url: "https://images.unsplash.com/photo-1662152334682-1157099fe7e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjB3ZWRkaW5nJTIwc2VhdGluZyUyMGNoYXJ0fGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    },
    {
      title: "Guest Wedding Page",
      caption: "One elegant link for everything they need",
      url: "https://images.unsplash.com/photo-1768900315637-146ae46a2fb9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVnYW50JTIwd2VkZGluZyUyMGNvdXBsZSUyMHBlYWNlZnVsfGVufDF8fHx8MTc3NDk5NjM3OHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    },
    {
      title: "Lookbook / Visual Direction",
      caption: "Organize your inspiration in one place",
      url: "https://images.unsplash.com/photo-1771142480968-6036543055f7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibHVzaCUyMHBpbmslMjByb3NlcyUyMHdlZGRpbmd8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
    }
  ];

  return (
    <section className="bg-white py-20 lg:py-24">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mb-14 text-center">
          <h2
            className="text-3xl sm:text-4xl lg:text-5xl"
            style={{
              color: "#2F4A3C",
              lineHeight: "1.2",
              fontWeight: "500",
              fontFamily: "var(--font-heading)",
              letterSpacing: "-0.01em"
            }}
          >
            See Udo in Action
          </h2>
        </div>

        <div className="grid gap-7 sm:grid-cols-2 lg:grid-cols-5">
          {screens.map((screen, index) => (
            <div key={index} className="group">
              <div
                className="overflow-hidden rounded-3xl shadow-md transition-all group-hover:shadow-xl"
                style={{
                  backgroundColor: "#F5E9E2",
                  boxShadow: "0 10px 30px -5px rgba(232, 160, 168, 0.15)"
                }}
              >
                <div className="aspect-[9/16] overflow-hidden">
                  <img
                    src={screen.url}
                    alt={screen.title}
                    className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                  />
                </div>
              </div>
              <div className="mt-3.5 text-center space-y-1">
                <p
                  className="text-[15px]"
                  style={{
                    color: "#2D2D2F",
                    fontWeight: "500",
                    fontFamily: "var(--font-heading)"
                  }}
                >
                  {screen.title}
                </p>
                <p
                  className="text-[13px]"
                  style={{
                    color: "#5A524D",
                    lineHeight: "1.5"
                  }}
                >
                  {screen.caption}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
