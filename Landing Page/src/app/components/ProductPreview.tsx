export function ProductPreview() {
  const mockupImages = [
    {
      url: "https://images.unsplash.com/photo-1622304078573-f63776457d77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwcGxhbm5pbmclMjBub3RlYm9vayUyMG1pbmltYWx8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      label: "Dashboard",
    },
    {
      url: "https://images.unsplash.com/photo-1662152334682-1157099fe7e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjB3ZWRkaW5nJTIwc2VhdGluZyUyMGNoYXJ0fGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      label: "Seating",
    },
    {
      url: "https://images.unsplash.com/photo-1665072200747-5b4680684d45?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWRkaW5nJTIwZ3Vlc3QlMjBib29rfGVufDF8fHx8MTc3NDk5NjM4MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      label: "Guest View",
    },
    {
      url: "https://images.unsplash.com/photo-1771142480968-6036543055f7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibHVzaCUyMHBpbmslMjByb3NlcyUyMHdlZGRpbmd8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      label: "Gallery",
    },
  ];

  return (
    <section className="bg-white py-24">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mb-16 text-center">
          <h2 
            className="text-4xl sm:text-5xl"
            style={{ 
              color: "#1C1C1E",
              lineHeight: "1.2",
              fontWeight: "500"
            }}
          >
            Beautiful design meets{" "}
            <span style={{ color: "#E8A0A8" }}>powerful functionality</span>
          </h2>
          <p 
            className="mx-auto mt-4 max-w-2xl text-lg"
            style={{ color: "#8E8E93" }}
          >
            An elegant interface designed to make every task feel simple
          </p>
        </div>

        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {mockupImages.map((mockup, index) => (
            <div key={index} className="group relative">
              <div 
                className="overflow-hidden rounded-2xl shadow-lg transition-all group-hover:shadow-xl"
                style={{ 
                  backgroundColor: "#F5E9E2",
                  boxShadow: "0 10px 30px -5px rgba(232, 160, 168, 0.2)"
                }}
              >
                <div className="aspect-[3/4] overflow-hidden">
                  <img 
                    src={mockup.url}
                    alt={mockup.label}
                    className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
                  />
                </div>
              </div>
              <div className="mt-4 text-center">
                <p 
                  className="text-sm"
                  style={{ color: "#8B6F5C", fontWeight: "500" }}
                >
                  {mockup.label}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
