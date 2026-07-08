'use client';

import { useState, useEffect } from 'react';
import { Clock, MapPin, Cloud, Phone, Radio as RadioIcon, CheckCircle, Sun, CloudRain, Wind, ChevronDown, ChevronUp, MessageCircle, Camera, Heart, Sparkles, Users } from 'lucide-react';
import { api } from '@/lib/api';
import { getToken } from '@/lib/auth';

type LiveTab = 'today' | 'timeline' | 'map' | 'weather' | 'updates';

export default function LivePage() {
  const [activeTab, setActiveTab] = useState<LiveTab>('today');
  const [showContactsExpanded, setShowContactsExpanded] = useState(false);
  const [showStatusDetails, setShowStatusDetails] = useState(false);
  const [showUpdateHistory, setShowUpdateHistory] = useState(false);
  const [currentTime, setCurrentTime] = useState('4:12 PM');
  const [guestsArrived, setGuestsArrived] = useState(89);
  const [liveUpdates, setLiveUpdates] = useState<{id:number;title:string;body?:string;created_at:string;event_time?:string}[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [sending, setSending] = useState(false);

  // Simulate real-time updates
  useEffect(() => {
    const interval = setInterval(() => {
      const now = new Date();
      setCurrentTime(now.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }));

      // Simulate guests arriving
      if (Math.random() > 0.7 && guestsArrived < 120) {
        setGuestsArrived(prev => Math.min(prev + 1, 120));
      }
    }, 3000);

    return () => clearInterval(interval);
  }, [guestsArrived]);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<{ data: any[] }>('/live', t)
      .then(res => setLiveUpdates(res.data ?? []))
      .catch(() => {});
  }, []);

  const tabs = [
    { id: 'today' as LiveTab, label: 'Today' },
    { id: 'timeline' as LiveTab, label: 'Timeline' },
    { id: 'map' as LiveTab, label: 'Map' },
    { id: 'weather' as LiveTab, label: 'Weather' },
    { id: 'updates' as LiveTab, label: 'Updates' },
  ];

  const timelineItems = [
    { time: '3:00 PM', event: 'Ceremony setup complete', status: 'completed' },
    { time: '3:30 PM', event: 'Guests begin arriving', status: 'completed' },
    { time: '4:00 PM', event: 'Ceremony begins', status: 'in-progress' },
    { time: '4:45 PM', event: 'Ceremony concludes', status: 'upcoming' },
    { time: '5:00 PM', event: 'Cocktail hour', status: 'upcoming' },
    { time: '6:00 PM', event: 'Reception doors open', status: 'upcoming' },
  ];

  const sendLiveUpdate = async () => {
    if (!newMessage.trim()) return;
    const t = getToken();
    if (!t) return;
    setSending(true);
    try {
      const res = await api.post<{ data: any }>('/live', { title: newMessage, visible_to_guests: true }, t);
      setLiveUpdates(prev => [res.data, ...prev]);
      setNewMessage('');
    } catch {}
    finally { setSending(false); }
  };

  return (
    <div className="min-h-screen bg-[#FAFAFA]">
      {/* HEADER SECTION - Calm, reassuring anchor */}
      <div className="bg-[#3A8B95] bg-opacity-90 text-white px-5 pt-8 pb-6">
        <div className="flex items-center mb-2">
          <RadioIcon size={20} className="mr-2" />
          <span className="text-[14px]" style={{ fontWeight: 500 }}>Live</span>
        </div>
        <p className="text-[12px] opacity-85 mb-5">Your day, gently guided</p>

        <div className="text-center">
          <h1 className="text-[26px] leading-tight" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 400 }}>
            {guestsArrived >= 110 ? "Your loved ones are here, and everything is perfect." : "Everything is flowing beautifully today."}
          </h1>
        </div>

        {/* Tab Navigation */}
        <div className="flex gap-2 overflow-x-auto pb-2 mt-6 scrollbar-hide">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-4 py-2 rounded-full whitespace-nowrap text-[13px] transition-all ${
                activeTab === tab.id
                  ? 'bg-white text-[#3A8B95]'
                  : 'bg-white/20 text-white hover:bg-white/30'
              }`}
              style={{ fontWeight: activeTab === tab.id ? 500 : 400 }}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-5 py-6" style={{ marginTop: '-8px' }}>
        {activeTab === 'today' && (
          <div className="space-y-6">
            {/* STATUS CARD - Critical calm element */}
            <button
              onClick={() => setShowStatusDetails(true)}
              className="w-full bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2] text-left hover:shadow-[0_6px_16px_rgba(0,0,0,0.06)] transition-shadow"
            >
              <div className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-full bg-[#3A7D6D]/10 flex items-center justify-center flex-shrink-0">
                  <CheckCircle size={20} className="text-[#3A7D6D]" />
                </div>
                <div className="flex-1">
                  <h3 className="text-[16px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                    No action needed right now
                  </h3>
                  <p className="text-[13px] text-[#6F6F6F]" style={{ lineHeight: 1.5 }}>
                    Your planner and vendors are handling everything.
                  </p>
                </div>
              </div>
            </button>

            {/* RIGHT NOW SECTION */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Right now</h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between py-2">
                  <span className="text-[14px] text-[#6F6F6F]">Current time</span>
                  <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>{currentTime}</span>
                </div>
                <div className="h-px bg-[#EAE7E2]"></div>
                <div className="flex items-center justify-between py-2">
                  <span className="text-[14px] text-[#6F6F6F]">Current moment</span>
                  <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>Guests arriving</span>
                </div>
                <div className="h-px bg-[#EAE7E2]"></div>
                <div className="flex items-center justify-between py-2">
                  <span className="text-[14px] text-[#6F6F6F]">Guests present</span>
                  <span className="text-[14px] text-[#3A8B95]" style={{ fontWeight: 500 }}>{guestsArrived} of 120</span>
                </div>
              </div>
            </div>

            {/* LIVE ACTIVITY FEED - Dynamic updates */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-[16px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>Happening now</h3>
                <div className="flex items-center gap-1.5">
                  <div className="w-2 h-2 rounded-full bg-[#3A7D6D] animate-pulse"></div>
                  <span className="text-[11px] text-[#6F6F6F]">Live</span>
                </div>
              </div>
              <div className="space-y-3">
                {[
                  { icon: Users, text: 'Sarah and Michael just arrived', time: 'Just now', color: '#3A7D6D' },
                  { icon: Camera, text: 'Photographer capturing ceremony details', time: '2 min ago', color: '#2F5D50' },
                  { icon: Heart, text: 'Your parents are greeting guests at entrance', time: '5 min ago', color: '#C97C7C' },
                  { icon: Sparkles, text: 'Final touches on floral arrangements complete', time: '8 min ago', color: '#D6A77A' },
                ].map((item, idx) => (
                  <div key={idx} className="flex items-start gap-3 p-3 bg-[#F3EFEA] rounded-[20px]">
                    <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0 border border-[#EAE7E2]">
                      <item.icon size={16} style={{ color: item.color }} strokeWidth={2} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-[13px] text-[#2B2B2B]" style={{ lineHeight: 1.5 }}>{item.text}</p>
                      <p className="text-[11px] text-[#6F6F6F] mt-1">{item.time}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* COMING UP NEXT - Minimal timeline */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Coming up next</h3>
              <div className="space-y-3">
                {[
                  { event: 'Ceremony begins', time: '4:30 PM', countdown: 'in 18 minutes' },
                  { event: 'Cocktail hour', time: '5:15 PM', countdown: 'in 1 hour 3 minutes' },
                ].map((item, idx) => (
                  <div key={idx} className="p-4 bg-[#F3EFEA] rounded-[20px]">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="text-[14px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>{item.event}</div>
                        <div className="text-[13px] text-[#6F6F6F]">{item.time}</div>
                      </div>
                      <span className="text-[13px] text-[#3A8B95] ml-3" style={{ fontWeight: 500 }}>{item.countdown}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* QUIET CONFIRMATIONS - Hidden complexity */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Everything in place</h3>
              <div className="space-y-2.5">
                {[
                  { label: 'Florist setup complete', handled: true },
                  { label: 'Musicians soundcheck done', handled: true },
                  { label: 'Catering team ready', handled: true },
                  { label: 'Photographer capturing pre-ceremony', handled: true },
                ].map((item, idx) => (
                  <div key={idx} className="flex items-center gap-3 p-3 bg-[#F3EFEA] rounded-[16px]">
                    <CheckCircle size={18} className="text-[#3A7D6D] flex-shrink-0" />
                    <span className="text-[14px] text-[#2B2B2B] flex-1">{item.label}</span>
                    <span className="text-[11px] text-[#6F6F6F]">Ready</span>
                  </div>
                ))}
              </div>
            </div>

            {/* SPECIAL MOMENTS - Bride-focused */}
            <div className="bg-gradient-to-br from-[#E8CFCF]/30 to-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#E8CFCF]">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles size={18} className="text-[#C97C7C]" />
                <h3 className="text-[16px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>Your day so far</h3>
              </div>
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Camera size={16} className="text-[#3A8B95]" />
                    <span className="text-[14px] text-[#2B2B2B]">Photos captured</span>
                  </div>
                  <span className="text-[16px] text-[#3A8B95]" style={{ fontWeight: 500 }}>127</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Heart size={16} className="text-[#C97C7C]" />
                    <span className="text-[14px] text-[#2B2B2B]">Well-wishes received</span>
                  </div>
                  <span className="text-[16px] text-[#C97C7C]" style={{ fontWeight: 500 }}>34</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Users size={16} className="text-[#3A7D6D]" />
                    <span className="text-[14px] text-[#2B2B2B]">Loved ones present</span>
                  </div>
                  <span className="text-[16px] text-[#3A7D6D]" style={{ fontWeight: 500 }}>{guestsArrived}</span>
                </div>
              </div>
            </div>

            {/* WEATHER - Only if relevant */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <div className="text-[36px] text-[#2B2B2B] leading-none mb-2" style={{ fontWeight: 500 }}>78°</div>
                  <div className="text-[14px] text-[#6F6F6F]">Partly cloudy</div>
                </div>
                <Sun size={56} className="text-[#D6A77A]" strokeWidth={1.5} />
              </div>
              <p className="text-[13px] text-[#6F6F6F]" style={{ lineHeight: 1.5 }}>
                Perfect conditions for your ceremony
              </p>
            </div>

            {/* SMART UPDATES - Passive, not demanding */}
            <button
              onClick={() => setShowUpdateHistory(true)}
              className="w-full bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2] text-left hover:shadow-[0_6px_16px_rgba(0,0,0,0.06)] transition-shadow"
            >
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Updates sent</h3>
              <div className="space-y-3">
                {liveUpdates.length === 0 ? (
                  <p className="text-[13px] text-[#6F6F6F] text-center py-4">No updates sent yet</p>
                ) : liveUpdates.slice(0, 5).map((update) => (
                  <div key={update.id} className="p-3 bg-[#F3EFEA] rounded-[16px]">
                    <div className="text-[13px] text-[#2B2B2B] mb-1">{update.title}{update.body ? ` — ${update.body}` : ''}</div>
                    <div className="text-[11px] text-[#6F6F6F]">{new Date(update.created_at).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}</div>
                  </div>
                ))}
              </div>
            </button>

            {/* EMERGENCY CONTACTS - Soft + collapsible */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <button
                onClick={() => setShowContactsExpanded(!showContactsExpanded)}
                className="w-full flex items-center justify-between"
              >
                <h3 className="text-[16px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>Your support team</h3>
                {showContactsExpanded ? (
                  <ChevronUp size={20} className="text-[#6F6F6F]" />
                ) : (
                  <ChevronDown size={20} className="text-[#6F6F6F]" />
                )}
              </button>

              {showContactsExpanded && (
                <div className="mt-4 space-y-2">
                  {[
                    { name: 'Maria Chen', role: 'Wedding Planner', phone: '(555) 123-4567' },
                    { name: 'John Anderson', role: 'Venue Manager', phone: '(555) 987-6543' },
                    { name: 'Sarah Williams', role: 'Day-of Coordinator', phone: '(555) 456-7890' },
                  ].map((contact, idx) => (
                    <button
                      key={idx}
                      className="w-full p-4 bg-[#F3EFEA] rounded-[20px] hover:bg-[#E8CFCF]/20 transition-colors text-left"
                    >
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>{contact.name}</div>
                          <div className="text-[12px] text-[#6F6F6F] mt-0.5">{contact.role}</div>
                        </div>
                        <div className="flex gap-2">
                          <Phone size={18} className="text-[#3A8B95]" />
                          <MessageCircle size={18} className="text-[#3A8B95]" />
                        </div>
                      </div>
                      <div className="text-[13px] text-[#6F6F6F]">{contact.phone}</div>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Gentle microcopy at bottom */}
            <div className="text-center py-6">
              <p className="text-[15px] text-[#2B2B2B] mb-2" style={{ fontFamily: 'Playfair Display, serif', fontStyle: 'italic', lineHeight: 1.6 }}>
                {guestsArrived >= 115 ? "Everyone who matters is here." : guestsArrived >= 100 ? "Your celebration is beginning beautifully." : "Today is yours."}
              </p>
              <p className="text-[12px] text-[#6F6F6F]">Just enjoy this moment.</p>
            </div>
          </div>
        )}

        {activeTab === 'timeline' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-5" style={{ fontWeight: 500 }}>Full schedule</h3>
              <div className="space-y-4">
                {timelineItems.map((item, idx) => (
                  <div key={idx} className="flex items-start gap-3">
                    <div className="flex-shrink-0 mt-1">
                      {item.status === 'completed' && (
                        <CheckCircle size={20} className="text-[#3A7D6D]" />
                      )}
                      {item.status === 'in-progress' && (
                        <div className="w-5 h-5 bg-[#3A8B95] rounded-full animate-pulse" />
                      )}
                      {item.status === 'upcoming' && (
                        <div className="w-5 h-5 border-2 border-[#EAE7E2] rounded-full" />
                      )}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-start justify-between gap-3">
                        <span className={`text-[14px] ${item.status === 'completed' ? 'text-[#6F6F6F]' : 'text-[#2B2B2B]'}`} style={{ fontWeight: item.status === 'in-progress' ? 500 : 400 }}>
                          {item.event}
                        </span>
                        <span className="text-[13px] text-[#6F6F6F] flex-shrink-0">{item.time}</span>
                      </div>
                      {item.status === 'in-progress' && (
                        <div className="mt-1 text-[12px] text-[#3A8B95]" style={{ fontWeight: 500 }}>In progress</div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'map' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Venue layout</h3>
              <div className="bg-[#F3EFEA] rounded-[20px] p-10 text-center mb-4" style={{ minHeight: '280px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                <MapPin size={64} className="text-[#3A8B95] mb-3 opacity-40" strokeWidth={1.5} />
                <p className="text-[13px] text-[#6F6F6F]">Interactive venue map</p>
              </div>
              <div className="space-y-2">
                {[
                  'Ceremony garden',
                  'Reception hall',
                  'Cocktail terrace',
                  'Restrooms',
                  'Photo area',
                ].map((area) => (
                  <button key={area} className="w-full p-3 bg-[#F3EFEA] rounded-[20px] flex items-center justify-between hover:bg-[#E8CFCF]/20 transition-colors text-left">
                    <span className="text-[14px] text-[#2B2B2B]">{area}</span>
                    <MapPin size={16} className="text-[#3A8B95]" />
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'weather' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-5" style={{ fontWeight: 500 }}>Weather forecast</h3>

              <div className="bg-[#F3EFEA] rounded-2xl p-6 mb-5">
                <div className="flex items-center justify-between mb-5">
                  <div>
                    <div className="text-[48px] text-[#2B2B2B] leading-none mb-2" style={{ fontWeight: 500 }}>78°</div>
                    <div className="text-[14px] text-[#6F6F6F]">Feels like 76°</div>
                  </div>
                  <Sun size={72} className="text-[#D6A77A]" strokeWidth={1.5} />
                </div>
                <div className="grid grid-cols-3 gap-4">
                  <div className="text-center">
                    <CloudRain size={28} className="text-[#3A8B95] mx-auto mb-2" strokeWidth={1.5} />
                    <div className="text-[11px] text-[#6F6F6F] mb-1">Rain</div>
                    <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>10%</div>
                  </div>
                  <div className="text-center">
                    <Wind size={28} className="text-[#3A8B95] mx-auto mb-2" strokeWidth={1.5} />
                    <div className="text-[11px] text-[#6F6F6F] mb-1">Wind</div>
                    <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>8 mph</div>
                  </div>
                  <div className="text-center">
                    <Cloud size={28} className="text-[#6F6F6F] mx-auto mb-2" strokeWidth={1.5} />
                    <div className="text-[11px] text-[#6F6F6F] mb-1">Clouds</div>
                    <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>30%</div>
                  </div>
                </div>
              </div>

              <h4 className="text-[14px] text-[#2B2B2B] mb-3" style={{ fontWeight: 500 }}>Hourly forecast</h4>
              <div className="space-y-2 mb-4">
                {[
                  '4:00 PM — 78° Sunny',
                  '5:00 PM — 76° Partly cloudy',
                  '6:00 PM — 74° Partly cloudy',
                  '7:00 PM — 72° Clear',
                  '8:00 PM — 70° Clear',
                ].map((hour) => (
                  <div key={hour} className="p-3 bg-[#F3EFEA] rounded-[16px] text-[13px] text-[#2B2B2B]">
                    {hour}
                  </div>
                ))}
              </div>

              <div className="p-4 bg-[#E8CFCF]/20 rounded-[20px] border border-[#E8CFCF]">
                <p className="text-[13px] text-[#2B2B2B]" style={{ lineHeight: 1.6 }}>
                  Perfect conditions for your outdoor ceremony. Light breeze will keep guests comfortable.
                </p>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'updates' && (
          <div className="space-y-4">
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Send update</h3>
              <textarea
                placeholder="Write a message to your guests..."
                className="w-full p-4 bg-[#F3EFEA] rounded-[20px] border-0 text-[14px] text-[#2B2B2B] placeholder:text-[#6F6F6F] resize-none focus:outline-none focus:ring-2 focus:ring-[#2F5D50]/20"
                rows={4}
                value={newMessage}
                onChange={e => setNewMessage(e.target.value)}
              />
              <button onClick={sendLiveUpdate} disabled={sending} className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px] mt-3 hover:bg-[#3A7D6D] transition-colors disabled:opacity-60" style={{ fontWeight: 500 }}>
                {sending ? 'Sending...' : 'Send to all guests'}
              </button>
            </div>

            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>Recent updates</h3>
              <div className="space-y-3">
                {liveUpdates.length === 0 ? (
                  <p className="text-[13px] text-[#6F6F6F] text-center py-4">No updates sent yet</p>
                ) : liveUpdates.slice(0, 10).map((update) => (
                  <div key={update.id} className="p-4 bg-[#F3EFEA] rounded-[20px]">
                    <div className="text-[11px] text-[#6F6F6F] mb-2">{new Date(update.created_at).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}</div>
                    <div className="text-[13px] text-[#2B2B2B]" style={{ lineHeight: 1.5 }}>{update.title}{update.body ? ` — ${update.body}` : ''}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Status Details Modal */}
      {showStatusDetails && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowStatusDetails(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[80vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-[#EAE7E2] p-5 pb-4">
              <div className="w-12 h-1 bg-[#EAE7E2] rounded-full mx-auto mb-4"></div>
              <h2 className="text-[20px] text-[#2B2B2B] text-center" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Status details
              </h2>
            </div>
            <div className="p-5">
              <div className="p-5 bg-[#F3EFEA] rounded-2xl mb-4">
                <p className="text-[14px] text-[#2B2B2B]" style={{ lineHeight: 1.6 }}>
                  Everything is running smoothly. Your planner and vendor team are managing all logistics. You can relax and enjoy this moment.
                </p>
              </div>
              <button
                onClick={() => setShowStatusDetails(false)}
                className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px]"
                style={{ fontWeight: 500 }}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Update History Modal */}
      {showUpdateHistory && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowUpdateHistory(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[80vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-[#EAE7E2] p-5 pb-4">
              <div className="w-12 h-1 bg-[#EAE7E2] rounded-full mx-auto mb-4"></div>
              <h2 className="text-[20px] text-[#2B2B2B] text-center" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                All updates
              </h2>
            </div>
            <div className="p-5 space-y-3">
              {[
                { time: '15 min ago', message: 'Guests notified of ceremony start', recipients: 'All guests' },
                { time: '42 min ago', message: 'Reminder sent to wedding party', recipients: 'Wedding party' },
                { time: '1 hour ago', message: 'Transport updates shared', recipients: 'Travelling guests' },
                { time: '2 hours ago', message: 'Welcome message sent', recipients: 'All guests' },
              ].map((update, idx) => (
                <div key={idx} className="p-4 bg-[#F3EFEA] rounded-[20px]">
                  <div className="text-[11px] text-[#6F6F6F] mb-2">{update.time}</div>
                  <div className="text-[14px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>{update.message}</div>
                  <div className="text-[12px] text-[#6F6F6F]">Sent to: {update.recipients}</div>
                </div>
              ))}
              <button
                onClick={() => setShowUpdateHistory(false)}
                className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] mt-2"
                style={{ fontWeight: 500 }}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
