import { useState } from 'react';
import { X } from 'lucide-react';

export default function YourVisionPage() {
  const [showModal, setShowModal] = useState(false);

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <div className="bg-gradient-to-b from-[#f8edeb]/30 to-white px-6 pt-12 pb-8 border-b border-gray-100">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-2">
            <span className="text-[11px] text-gray-500" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>
              DAY SIMULATION — JAIPUR, INDIA
            </span>
          </div>
          <h1 className="text-[32px] text-gray-900 text-center mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 400 }}>
            What the day actually looks like
          </h1>
          <p className="text-[15px] text-gray-600 text-center max-w-3xl mx-auto leading-relaxed">
            This is what UDO generates after onboarding is complete. Not a checklist. A simulation — atmospheric, behavioral, operational, and emotional — of exactly how the day will unfold. Every observation is specific to this couple, this venue, this guest list.
          </p>
        </div>
      </div>

      {/* Timeline Bar */}
      <div className="bg-[#FAFAFA] border-b border-gray-200 py-6">
        <div className="max-w-5xl mx-auto px-6">
          <div className="grid grid-cols-7 gap-2">
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>Mehndi</div>
              <div className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>3h</div>
            </div>
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>Sangeet</div>
              <div className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>4h</div>
            </div>
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>Baraat</div>
              <div className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>45m</div>
            </div>
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>Ceremony</div>
              <div className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>3h</div>
            </div>
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>Cocktails</div>
              <div className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>90m</div>
            </div>
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>Reception</div>
              <div className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>5h</div>
            </div>
            <div className="bg-white rounded-lg p-3 text-center border border-gray-200">
              <div className="text-[10px] text-gray-500 mb-1" style={{ fontWeight: 600, letterSpacing: '0.05em' }}>End time</div>
              <div className="text-[18px] text-gray-900" style={{ fontWeight: 600 }}>2:00 AM</div>
            </div>
          </div>
        </div>
      </div>

      {/* Timeline Simulation */}
      <div className="max-w-4xl mx-auto px-6 py-12">
        <h2 className="text-[11px] text-gray-500 mb-8" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>TIMELINE SIMULATION</h2>

        <div className="space-y-10">
          {/* 5:30 AM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>5:30 AM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              Bridal suite — controlled stillness
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Four people maximum in the room. Warm chai service and instrumental devotional playlist at 68 BPM. Phones out of reach of the bride. The energy is quiet anticipation, not celebration. This is intentional.
            </p>
            <div className="text-[11px] text-[#6366f1]" style={{ fontWeight: 600 }}>Atmosphere</div>
          </div>

          {/* 7:15 AM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>7:15 AM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              Hair and makeup — the 90-minute window
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Fresh jasmine florals added last-minute for scent retention. Humidity-protected updo structure begins 20 minutes earlier than needed due to outfit transitions and jewelry layering. Secondary dupatta secured for outdoor wind conditions. Photographer captures heirloom jewelry styling at 8:02 AM when morning light hits the preparation room.
            </p>
            <div className="text-[11px] text-[#10b981]" style={{ fontWeight: 600 }}>Operations · Photography</div>
          </div>

          {/* 8:45 AM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>8:45 AM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              The home becomes louder
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Aunties begin arriving. Steamers running constantly. Younger cousins filming TikToks upstairs. Breakfast trays move room to room. The bride briefly disappears for quiet time before dressing. This is likely the last calm moment before the emotional intensity of the ceremony begins.
            </p>
            <div className="text-[11px] text-[#6366f1]" style={{ fontWeight: 600 }}>Atmosphere · Memory moment</div>
          </div>

          {/* 4:10 PM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>4:10 PM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              The baraat becomes visible from the entrance road
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Percussion becomes louder. Guests leave cocktail areas. Children run toward entrance path. Phones immediately come out. The energy becomes chaotic in the best possible way. Traditional dhol transitions into brass fusion, then modern Bollywood percussion. Even reserved guests become participatory during the baraat due to the collective pacing and rhythm.
            </p>
            <div className="text-[11px] text-[#f59e0b]" style={{ fontWeight: 600 }}>Music · Atmosphere</div>
          </div>

          {/* 5:20 PM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>5:20 PM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              Ceremony begins — the intentional slowdown
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              The ceremony intentionally slows the pace of the weekend after several hours of celebration. Floral canopy filters late-afternoon light. Sound system tuned lower during vows. Elders seated closest to mandap. The emotional intensity peaks during parental blessings rather than the vows themselves. The room briefly quiets as everyone realizes the ceremony is about to begin.
            </p>
            <div className="text-[11px] text-[#6366f1]" style={{ fontWeight: 600 }}>Atmosphere · Memory moment</div>
          </div>

          {/* 8:40 PM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>8:40 PM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              Ceremony ends — guests immediately migrate
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Guests need 4 minutes to recalibrate emotionally before moving to cocktail area. Interactive chaat stations open at 8:44 PM — exactly when the first wave arrives. No one stands holding nothing. The scent of florals, candles, and food slowly replaces the ceremony incense.
            </p>
            <div className="text-[11px] text-[#10b981]" style={{ fontWeight: 600 }}>Guest behavior · Operations</div>
          </div>

          {/* 9:20 PM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>9:20 PM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              Dinner service opens gradually
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Interactive chaat stations. Late-night tandoor service running parallel. Dessert room opens separately at 10:15 PM. Food arrives in waves. Eating happens throughout, not in one service window. Older guests remain near live music. Younger guests transition toward dance floor staging area. Families continue taking portraits long after dinner begins.
            </p>
            <div className="text-[11px] text-[#10b981]" style={{ fontWeight: 600 }}>Guest behavior</div>
          </div>

          {/* 10:50 PM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>10:50 PM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              Halfway through dinner, guests stop checking their phones entirely
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Main course is cleared. Guests linger longer at tables because the candlelight and slower pace of post-meal live band naturally extend conversation. Espresso and masala chai station added after speeches. The room is doing its job.
            </p>
            <div className="text-[11px] text-[#10b981]" style={{ fontWeight: 600 }}>Guest behavior</div>
          </div>

          {/* 11:50 PM */}
          <div>
            <div className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 700 }}>11:50 PM</div>
            <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontWeight: 600 }}>
              The wedding transforms again
            </h3>
            <p className="text-[15px] text-gray-700 leading-relaxed mb-3">
              Formality collapses. Shoes disappear. Bollywood transitions into global dance music. Extended family joins dance floor unexpectedly. The dance floor becomes less polished and more joyful. This becomes the part of the wedding guests replay on their phones for years.
            </p>
            <div className="text-[11px] text-[#f59e0b]" style={{ fontWeight: 600 }}>Music · Guest behavior</div>
          </div>
        </div>
      </div>

      {/* Emotional Arc */}
      <div className="bg-[#FAFAFA] py-16 border-y border-gray-200">
        <div className="max-w-4xl mx-auto px-6">
          <div className="mb-8">
            <h2 className="text-[11px] text-gray-500 mb-2" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>EMOTIONAL ARC</h2>
            <h3 className="text-[20px] text-gray-900" style={{ fontWeight: 600 }}>Energy mapping across the day</h3>
          </div>

          <div className="space-y-3">
            {[
              { label: 'Morning preparation', value: 35, color: '#6366f1' },
              { label: 'Baraat arrival', value: 85, color: '#f59e0b' },
              { label: 'Ceremony gravity', value: 95, color: '#d45d78' },
              { label: 'Cocktail release', value: 60, color: '#10b981' },
              { label: 'Dinner warmth', value: 70, color: '#f97316' },
              { label: 'Dance floor peak', value: 98, color: '#8b5cf6' },
              { label: 'Late night joy', value: 75, color: '#10b981' }
            ].map((item, idx) => (
              <div key={idx}>
                <div className="flex items-center justify-between mb-1">
                  <span className="text-[13px] text-gray-700">{item.label}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="h-2 rounded-full transition-all"
                    style={{ width: `${item.value}%`, backgroundColor: item.color }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Behavioral Observations */}
      <div className="max-w-4xl mx-auto px-6 py-16">
        <h2 className="text-[11px] text-gray-500 mb-8" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>
          BEHAVIORAL OBSERVATIONS — FOR THE PLANNER
        </h2>

        <div className="space-y-6">
          {/* Guest Psychology */}
          <div className="border-l-4 border-[#285301] bg-gray-50 p-6">
            <h3 className="text-[11px] text-gray-500 mb-3" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>GUEST PSYCHOLOGY</h3>
            <p className="text-[15px] text-gray-700 leading-relaxed">
              At a 240-person Indian wedding with multi-generational attendance, approximately 60–70 elders will not participate in late-night dancing regardless of music energy. Design the lounge seating areas near the dance floor perimeter — not pushed to corners — so non-dancers feel present without feeling like spectators. Elder seating must be positioned away from speakers.
            </p>
          </div>

          {/* Family Dynamics */}
          <div className="border-l-4 border-[#D47B65] bg-gray-50 p-6">
            <h3 className="text-[11px] text-gray-500 mb-3" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>FAMILY DYNAMICS</h3>
            <p className="text-[15px] text-gray-700 leading-relaxed">
              Parents of the couple will be approached by guests throughout all 4 days for conversation. This makes them unavailable for family photos after 7 PM on the wedding day. Schedule formal extended family portraits at 3:45 PM before baraat begins, immediately after bride's preparation photos. This window closes faster than planners expect. Baraat timing and welcome ritual (Milni) require coordination across both families simultaneously.
            </p>
          </div>

          {/* Stress Prevention */}
          <div className="border-l-4 border-[#d45d78] bg-gray-50 p-6">
            <h3 className="text-[11px] text-gray-500 mb-3" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>STRESS PREVENTION</h3>
            <p className="text-[15px] text-gray-700 leading-relaxed">
              Hair schedule intentionally begins earlier than needed due to the complexity of outfit transitions and jewelry layering. The most common cause of timeline collapse is underestimating attire change duration between events. Assign one coordinator whose only job is to manage the bride's outfit transitions. The bride won't track this herself — she's in the moment. Someone external has to hold the time.
            </p>
          </div>

          {/* Music Intelligence */}
          <div className="border-l-4 border-[#6366f1] bg-gray-50 p-6">
            <h3 className="text-[11px] text-gray-500 mb-3" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>MUSIC INTELLIGENCE</h3>
            <p className="text-[15px] text-gray-700 leading-relaxed">
              The DJ should receive a behavioral brief, not just a playlist. Key instruction: Sangeet energy peaks between 9:30–11:00 PM. Family performances and choreographed dances drive this event — the Sangeet is often louder and more emotional than the reception. Live dhol must be coordinated with family entrance timing. Do not read the dance floor by who is dancing — read it by who is watching. When watchers exceed dancers, the song is wrong.
            </p>
          </div>

          {/* Photography Moment Engine */}
          <div className="border-l-4 border-[#10b981] bg-gray-50 p-6">
            <h3 className="text-[11px] text-gray-500 mb-3" style={{ fontWeight: 600, letterSpacing: '0.1em' }}>PHOTOGRAPHY MOMENT ENGINE</h3>
            <p className="text-[15px] text-gray-700 leading-relaxed">
              There are exactly 12–15 windows during the multi-day celebration where light quality, crowd position, emotional state, and cultural significance converge into likely memory-forming photographs. The 3:45 PM pre-baraat family portrait window is the most reliable. The grandmother's pause before entering the ceremony space is predictable and should be flagged to the photographer in advance. Arrival photography captures coordinated crowd in traditional attire — this is a designed visual moment.
            </p>
          </div>
        </div>
      </div>

      {/* Footer CTA */}
      <div className="bg-gradient-to-b from-white to-[#f8edeb]/20 py-16 border-t border-gray-200">
        <div className="max-w-2xl mx-auto px-6 text-center">
          <h2 className="text-[28px] text-gray-900 mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 400 }}>
            This is your wedding
          </h2>
          <p className="text-[15px] text-gray-600 mb-8 leading-relaxed">
            UDO has studied your culture, pacing, family structure, and emotional priorities to build a celebration that feels deeply, authentically yours.
          </p>
          <button
            onClick={() => setShowModal(true)}
            className="px-8 py-3 bg-[#d45d78] text-white rounded-lg hover:bg-[#c04d68] transition-colors"
            style={{ fontWeight: 500 }}
          >
            Download full day simulation
          </button>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-6" onClick={() => setShowModal(false)}>
          <div className="bg-white rounded-2xl max-w-lg w-full p-8" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Day simulation ready
              </h3>
              <button onClick={() => setShowModal(false)}>
                <X size={24} className="text-gray-400" />
              </button>
            </div>
            <p className="text-[15px] text-gray-600 leading-relaxed mb-6">
              Your complete 4-day wedding simulation is ready. This document includes minute-by-minute timing, behavioral observations, and coordination notes for your planning team.
            </p>
            <button className="w-full py-3 bg-[#d45d78] text-white rounded-lg hover:bg-[#c04d68] transition-colors" style={{ fontWeight: 500 }}>
              Download PDF
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
