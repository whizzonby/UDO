'use client';

import { Plus, Check, AlertCircle, Users as UsersIcon, MapPinIcon, LayoutGrid, Send, Mail, MapPin } from 'lucide-react';

interface GuestOverviewProps {
  onAddGuest: () => void;
  onNavigateToTab: (tab: string) => void;
}

export default function GuestOverview({ onAddGuest, onNavigateToTab }: GuestOverviewProps) {
  return (
    <div className="space-y-6">
      {/* Header with Add Guest button */}
      <div className="flex items-start justify-between">
        <div>
          <p className="text-[15px] text-gray-600" style={{ lineHeight: 1.6 }}>
            Keep your guest list, responses, and guest experience beautifully organized in one place.
          </p>
        </div>
        <button
          onClick={onAddGuest}
          className="bg-[#FF3E9B] text-white px-5 py-2.5 rounded-[20px] text-[14px] flex items-center gap-2 hover:bg-[#c14d68] transition-colors flex-shrink-0 ml-4"
          style={{ fontWeight: 500 }}
        >
          <Plus size={18} />
          Add Guest
        </button>
      </div>

      {/* Unified Guest Snapshot Hero */}
      <div className="bg-white rounded-[24px] p-6 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between gap-6">
          {/* Left side - Stats */}
          <div className="flex-1">
            <div className="mb-4">
              <div className="text-[48px] leading-none font-semibold text-gray-900 mb-2">120</div>
              <div className="text-[15px] text-gray-600 mb-1">Total guests invited</div>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <div className="text-[28px] leading-none font-semibold text-[#3A8B95] mb-1">86</div>
                <div className="text-[13px] text-gray-600">Confirmed</div>
              </div>
              <div>
                <div className="text-[28px] leading-none font-semibold text-[#FF3E9B] mb-1">34</div>
                <div className="text-[13px] text-gray-600">Awaiting response</div>
              </div>
            </div>

            <div className="p-4 bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[16px] border border-[#3A8B95]/20">
              <div className="text-[13px] font-medium text-gray-800 mb-1">RSVP closes in 12 days</div>
              <div className="text-[12px] text-gray-600">Deadline: June 1, 2026</div>
            </div>
          </div>

          {/* Right side - Circular progress */}
          <div className="flex flex-col items-center justify-center">
            <div className="relative w-32 h-32">
              <svg className="w-full h-full" viewBox="0 0 120 120">
                <circle cx="60" cy="60" r="54" fill="none" stroke="#f0f0f0" strokeWidth="8" />
                <circle
                  cx="60"
                  cy="60"
                  r="54"
                  fill="none"
                  stroke="url(#gradient)"
                  strokeWidth="8"
                  strokeLinecap="round"
                  strokeDasharray={`${(86 / 120) * 339} 339`}
                  transform="rotate(-90 60 60)"
                />
                <defs>
                  <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="0%">
                    <stop offset="0%" stopColor="#FF3E9B" />
                    <stop offset="100%" stopColor="#FF88BA" />
                  </linearGradient>
                </defs>
              </svg>
              <div className="absolute inset-0 flex items-center justify-center flex-col">
                <div className="text-[24px] font-semibold text-gray-900">72%</div>
                <div className="text-[11px] text-gray-500">confirmed</div>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-5 pt-5 border-t border-gray-100">
          <p className="text-[13px] text-gray-600 italic text-center">
            Most guests have already responded beautifully.
          </p>
        </div>
      </div>

      {/* What Needs Attention */}
      <div className="bg-white rounded-[24px] p-6 shadow-sm border border-gray-100">
        <h3 className="text-[20px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          What needs attention
        </h3>
        <p className="text-[13px] text-gray-600 mb-5" style={{ lineHeight: 1.6 }}>
          A few details still need your care before finalizing your guest experience.
        </p>

        <div className="space-y-2">
          {[
            { icon: AlertCircle, label: '18 guests still need to RSVP', color: '#FF3E9B' },
            { icon: UsersIcon, label: '12 guests have not selected meals', color: '#FF3E9B' },
            { icon: LayoutGrid, label: '24 guests need seating assignments', color: '#3A8B95' },
            { icon: MapPinIcon, label: '8 travelling guests still need accommodation details', color: '#3A8B95' }
          ].map((item, idx) => {
            const Icon = item.icon;
            return (
              <button
                key={idx}
                onClick={() => onNavigateToTab('guests')}
                className="w-full flex items-center gap-3 p-4 rounded-[16px] hover:bg-gray-50 transition-colors text-left group"
              >
                <Icon size={18} style={{ color: item.color }} className="flex-shrink-0" />
                <span className="flex-1 text-[14px] text-gray-800">{item.label}</span>
                <span className="text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity">→</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Guest Journey Progress */}
      <div className="bg-white rounded-[24px] p-6 shadow-sm border border-gray-100">
        <h3 className="text-[20px] text-gray-900 mb-5" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Guest journey progress
        </h3>

        <div className="space-y-4">
          {[
            { label: 'RSVP Collection', value: 86, total: 120, color: '#3A8B95' },
            { label: 'Meal Selections', value: 74, total: 86, color: '#FF3E9B' },
            { label: 'Travel Details', value: 18, total: 32, color: '#FF88BA' },
            { label: 'Seating Assignments', value: 62, total: 86, color: '#66D0BC' }
          ].map((item) => (
            <div key={item.label}>
              <div className="flex items-center justify-between mb-2">
                <span className="text-[13px] text-gray-700">{item.label}</span>
                <span className="text-[13px] font-medium text-gray-500">{item.value}/{item.total}</span>
              </div>
              <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
                <div
                  className="h-full rounded-full transition-all"
                  style={{
                    width: `${(item.value / item.total) * 100}%`,
                    backgroundColor: item.color
                  }}
                />
              </div>
            </div>
          ))}
        </div>

        <p className="text-[13px] text-gray-600 italic mt-5 text-center" style={{ lineHeight: 1.6 }}>
          Your guest planning is coming together beautifully.
        </p>
      </div>

      {/* Guest Groups */}
      <div className="bg-white rounded-[24px] p-6 shadow-sm border border-gray-100">
        <h3 className="text-[20px] text-gray-900 mb-5" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Guest groups
        </h3>

        <div className="flex gap-2 flex-wrap">
          <button
            onClick={() => onNavigateToTab('guests')}
            className="px-5 py-2.5 rounded-full text-[13px] font-medium transition-all border-2 hover:shadow-md"
            style={{
              backgroundColor: '#FFF5F8',
              borderColor: '#FF3E9B',
              color: '#FF3E9B'
            }}
          >
            Wedding Party <span className="ml-1.5 font-semibold">(12)</span>
          </button>

          <button
            onClick={() => onNavigateToTab('guests')}
            className="px-5 py-2.5 rounded-full text-[13px] font-medium transition-all border-2 hover:shadow-md"
            style={{
              backgroundColor: '#FFF0F0',
              borderColor: '#FF88BA',
              color: '#FF3E9B'
            }}
          >
            Family <span className="ml-1.5 font-semibold">(24)</span>
          </button>

          <button
            onClick={() => onNavigateToTab('guests')}
            className="px-5 py-2.5 rounded-full text-[13px] font-medium transition-all border-2 hover:shadow-md"
            style={{
              backgroundColor: '#F0F9FA',
              borderColor: '#3A8B95',
              color: '#3A8B95'
            }}
          >
            Friends <span className="ml-1.5 font-semibold">(52)</span>
          </button>

          <button
            onClick={() => onNavigateToTab('guests')}
            className="px-5 py-2.5 rounded-full text-[13px] font-medium transition-all border-2 hover:shadow-md"
            style={{
              backgroundColor: '#FFF5F0',
              borderColor: '#FF9966',
              color: '#FF6633'
            }}
          >
            Travelling Guests <span className="ml-1.5 font-semibold">(32)</span>
          </button>
        </div>
      </div>

      {/* Guest Experience Pulse */}
      <div className="bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[24px] p-6 border border-[#3A8B95]/20">
        <h3 className="text-[20px] text-gray-900 mb-3" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Guest experience pulse
        </h3>

        <p className="text-[14px] text-gray-700 mb-5" style={{ lineHeight: 1.7 }}>
          Most guests have already confirmed attendance and meal selections are progressing well. This week is a good time to finalize seating and travel details.
        </p>

        <div className="flex gap-2 flex-wrap">
          <button
            onClick={() => onNavigateToTab('guests')}
            className="px-4 py-2 bg-white border border-[#3A8B95]/30 rounded-full text-[13px] font-medium text-[#3A8B95] hover:bg-[#3A8B95] hover:text-white transition-colors"
          >
            Review seating
          </button>
          <button
            onClick={() => onNavigateToTab('messages')}
            className="px-4 py-2 bg-white border border-[#FF3E9B]/30 rounded-full text-[13px] font-medium text-[#FF3E9B] hover:bg-[#FF3E9B] hover:text-white transition-colors"
          >
            Send reminder
          </button>
          <button
            onClick={() => onNavigateToTab('guests')}
            className="px-4 py-2 bg-white border border-[#66D0BC]/30 rounded-full text-[13px] font-medium text-[#3A8B95] hover:bg-[#66D0BC] hover:text-white transition-colors"
          >
            Finalize meals
          </button>
        </div>
      </div>
    </div>
  );
}
