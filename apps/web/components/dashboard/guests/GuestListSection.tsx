'use client';

import { useState } from 'react';
import { Search, Plus, AlertCircle, Check, Mail, ChevronRight } from 'lucide-react';

interface Guest {
  name: string;
  email: string;
  rsvp: string;
  meal: string;
  plusOne: boolean;
  table?: string;
}

interface GuestListSectionProps {
  guests: Guest[];
  onAddGuest: () => void;
  onImportGuests: () => void;
  onShowGuestDetail: () => void;
  onComposeMessage: () => void;
}

export default function GuestListSection({
  guests,
  onAddGuest,
  onImportGuests,
  onShowGuestDetail,
  onComposeMessage
}: GuestListSectionProps) {
  const [primaryFilter, setPrimaryFilter] = useState('all');
  const [secondaryFilter, setSecondaryFilter] = useState<string | null>(null);
  const [guestSort, setGuestSort] = useState('rsvp-status');
  const [hoveredGuestIdx, setHoveredGuestIdx] = useState<number | null>(null);

  return (
    <div className="space-y-5">
      {/* Page header */}
      <div className="flex items-center justify-between gap-4">
        <div className="flex-1">
          <p className="text-[14px] text-gray-600" style={{ lineHeight: 1.5 }}>
            Keep every guest detail beautifully organized.
          </p>
        </div>
        <div className="flex gap-2 flex-shrink-0">
          <button
            onClick={onAddGuest}
            className="bg-[#FF3E9B] text-white px-5 py-2.5 rounded-full text-[14px] flex items-center gap-2 hover:bg-[#c14d68] transition-colors"
            style={{ fontWeight: 500 }}
          >
            <Plus size={18} />
            Add Guest
          </button>
          <button
            onClick={onImportGuests}
            className="bg-white border border-gray-300 text-gray-700 px-5 py-2.5 rounded-full text-[14px] hover:bg-gray-50 transition-colors"
            style={{ fontWeight: 500 }}
          >
            Import Guests
          </button>
        </div>
      </div>

      {/* Search bar */}
      <div className="flex items-center gap-3">
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
          <input
            type="text"
            placeholder="Search guests, tags, travel, meals, or seating"
            className="w-full pl-12 pr-4 py-3.5 bg-white border border-gray-200 rounded-[20px] text-[14px] focus:outline-none focus:ring-2 focus:ring-[#FF3E9B]/20 focus:border-[#FF3E9B] transition-all"
          />
        </div>
        <button className="w-10 h-10 flex items-center justify-center bg-white border border-gray-200 rounded-full hover:border-[#3A8B95] hover:bg-gray-50 transition-colors">
          <AlertCircle size={18} className="text-gray-500" />
        </button>
      </div>

      {/* Sort Dropdown */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-[13px] text-gray-600">Sort by:</span>
          <select
            value={guestSort}
            onChange={(e) => setGuestSort(e.target.value)}
            className="px-3 py-1.5 bg-white border border-gray-200 rounded-full text-[13px] font-medium text-gray-700 focus:outline-none focus:border-[#3A8B95] hover:bg-gray-50 transition-colors"
          >
            <option value="rsvp-status">RSVP status</option>
            <option value="recent">Recently added</option>
            <option value="attention">Needs attention</option>
            <option value="wedding-party">Wedding party</option>
            <option value="table">Table assignment</option>
            <option value="travelling">Travelling guests</option>
          </select>
        </div>
      </div>

      {/* Primary Filters */}
      <div className="flex gap-2">
        {[
          { id: 'all', label: 'All Guests', count: 120 },
          { id: 'attending', label: 'Attending', count: 86 },
          { id: 'pending', label: 'Pending', count: 34 },
          { id: 'declined', label: 'Declined', count: 0 }
        ].map((filter) => (
          <button
            key={filter.id}
            onClick={() => setPrimaryFilter(filter.id)}
            className={`px-5 py-2.5 rounded-full whitespace-nowrap text-[13px] transition-all font-medium ${
              primaryFilter === filter.id
                ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-md'
                : 'bg-white text-gray-700 border border-gray-200 hover:border-[#FF3E9B] hover:bg-gray-50'
            }`}
          >
            {filter.label} {filter.count > 0 && <span className={primaryFilter === filter.id ? 'opacity-90' : 'text-gray-500'}>({filter.count})</span>}
          </button>
        ))}
      </div>

      {/* Secondary Filters */}
      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
        {[
          { id: 'travelling', label: 'Travelling', count: 32 },
          { id: 'family', label: 'Family', count: 24 },
          { id: 'friends', label: 'Friends', count: 52 },
          { id: 'party', label: 'Wedding party', count: 12 },
          { id: 'vip', label: 'VIP', count: 8 },
          { id: 'vendors', label: 'Vendors', count: 4 },
          { id: 'plus-ones', label: 'Plus ones', count: 18 }
        ].map((filter) => (
          <button
            key={filter.id}
            onClick={() => setSecondaryFilter(secondaryFilter === filter.id ? null : filter.id)}
            className={`px-4 py-2 rounded-full whitespace-nowrap text-[13px] transition-all ${
              secondaryFilter === filter.id
                ? 'bg-[#3A8B95] text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
            style={{ fontWeight: 500 }}
          >
            {filter.label} <span className={secondaryFilter === filter.id ? 'opacity-90' : ''}>{filter.count}</span>
          </button>
        ))}
      </div>

      {/* Emotional Intelligence */}
      <div className="px-1">
        <p className="text-[13px] text-gray-600 italic">
          86 guests are ready to celebrate with you.
        </p>
      </div>

      {/* Guest List */}
      <div className="space-y-2">
        {guests.map((guest, idx) => (
          <div
            key={idx}
            onMouseEnter={() => setHoveredGuestIdx(idx)}
            onMouseLeave={() => setHoveredGuestIdx(null)}
            onClick={onShowGuestDetail}
            className="relative bg-white rounded-[16px] border border-gray-100 px-4 py-3 hover:border-[#FF3E9B] hover:shadow-lg hover:-translate-y-0.5 transition-all cursor-pointer group"
          >
            <div className="flex items-center gap-4">
              {/* Avatar */}
              <div
                className="w-10 h-10 rounded-full flex items-center justify-center text-[13px] font-semibold text-white flex-shrink-0"
                style={{
                  background: `linear-gradient(135deg, ${
                    idx % 3 === 0 ? '#FF3E9B, #FF88BA' :
                    idx % 3 === 1 ? '#3A8B95, #66D0BC' :
                    '#FF88BA, #FFB3D6'
                  })`
                }}
              >
                {guest.name.split(' ').map(n => n[0]).join('')}
              </div>

              {/* LEFT - Name & Contact */}
              <div className="flex-1 min-w-0">
                <div className="text-[14px] font-medium text-gray-900">{guest.name}</div>
                <div className="text-[12px] text-gray-500 truncate">{guest.email}</div>
              </div>

              {/* CENTER - Status Icons */}
              <div className="flex items-center gap-2 flex-shrink-0">
                {guest.rsvp === 'Attending' && (
                  <div className="flex items-center gap-1 text-[#3A8B95]" title="RSVP confirmed">
                    <Check size={14} />
                  </div>
                )}
                {guest.meal !== '-' && (
                  <div className="flex items-center gap-1 text-[#3A8B95]" title="Meal selected">
                    <span className="text-[14px]">🍽</span>
                  </div>
                )}
                {guest.plusOne && (
                  <div className="flex items-center gap-1 text-[#FF3E9B]" title="Plus one">
                    <span className="text-[14px]">+1</span>
                  </div>
                )}
                {guest.table && guest.table !== '-' && (
                  <div className="flex items-center gap-1 text-[#3A8B95]" title="Seated">
                    <span className="text-[14px]">🪑</span>
                  </div>
                )}
              </div>

              {/* RIGHT - Metadata */}
              <div className="text-right flex-shrink-0 min-w-[120px]">
                {guest.table && guest.table !== '-' ? (
                  <>
                    <div className="text-[12px] text-gray-600">{guest.table}</div>
                    <div className="text-[11px] text-gray-500">
                      {guest.meal !== '-' ? 'Meal selected' : 'No meal'}
                    </div>
                  </>
                ) : (
                  <>
                    <div className="text-[12px] text-[#FF3E9B]">⚠ Missing meal</div>
                    <div className="text-[11px] text-gray-500">No seat assigned</div>
                  </>
                )}
              </div>

              {/* Quick Actions - Visible on hover */}
              {hoveredGuestIdx === idx && (
                <div className="flex items-center gap-1 ml-2 flex-shrink-0">
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onComposeMessage();
                    }}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-[#3A8B95] hover:text-white transition-colors"
                    title="Message"
                  >
                    <Mail size={14} />
                  </button>
                  <button
                    onClick={(e) => e.stopPropagation()}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-[#3A8B95] hover:text-white transition-colors"
                    title="Assign seat"
                  >
                    <span className="text-[14px]">🪑</span>
                  </button>
                  <button
                    onClick={(e) => e.stopPropagation()}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-[#FF3E9B] hover:text-white transition-colors"
                    title="More"
                  >
                    <span className="text-[12px]">⋯</span>
                  </button>
                </div>
              )}

              {/* Chevron */}
              <ChevronRight
                className={`flex-shrink-0 transition-all ${
                  hoveredGuestIdx === idx ? 'text-[#FF3E9B] translate-x-1' : 'text-gray-300'
                }`}
                size={18}
              />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
