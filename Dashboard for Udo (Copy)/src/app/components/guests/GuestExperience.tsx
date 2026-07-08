import { useState } from 'react';
import { Eye, MapPin, Hotel, Plane, Bus, Calendar, Clock, Copy, ChevronRight, AlertCircle, Send, Check, Edit, Heart, Sparkles, Sun, Cloud, Users, X, Settings, Palette, Music, Camera, Gift, MessageSquare, Layout, Globe, Link as LinkIcon, Plus, Play, ChevronDown, Grip } from 'lucide-react';

interface HotelData {
  id: string;
  name: string;
  address: string;
  distance: string;
  priceRange: string;
  bookingLink: string;
  notes: string;
  recommended: boolean;
}

interface TransportGroup {
  id: string;
  name: string;
  pickupLocation: string;
  time: string;
  notes: string;
}

interface GuestExperienceProps {
  savedHotels: HotelData[];
  transportGroups: TransportGroup[];
  travelStayData: {
    weddingCity: string;
    venueName: string;
    venueAddress: string;
    nearestAirport: string;
    showFlightSuggestions: boolean;
    travelTips: string;
    showTransportOptions: boolean;
  };
  visibilityRules: { [key: string]: string[] };
  onShowReminderModal: () => void;
  onShowVisibilityModal: (eventId: string) => void;
  onShowTravelStayModal: () => void;
  onShowHotelDetailsModal: (hotelId: string) => void;
  onShowMapViewModal: () => void;
  onShowQuickAction: (action: 'calendar' | 'maps' | 'schedule') => void;
}

type ViewMode = 'planning' | 'guest' | 'day-of';
type GuestPersona = 'attending' | 'travelling' | 'wedding-party' | 'pending' | 'family' | 'vip' | 'vendor' | 'child';

interface Module {
  id: string;
  icon: string;
  title: string;
  description: string;
  status: 'live' | 'hidden' | 'setup';
  visibleTo: string[];
  previewType: 'text' | 'map' | 'music' | 'photos' | 'weather';
}

export default function GuestExperience({
  savedHotels,
  transportGroups,
  travelStayData,
  visibilityRules,
  onShowReminderModal,
  onShowVisibilityModal,
  onShowTravelStayModal,
  onShowHotelDetailsModal,
  onShowMapViewModal,
  onShowQuickAction,
}: GuestExperienceProps) {
  const [viewMode, setViewMode] = useState<ViewMode>('planning');
  const [guestPersona, setGuestPersona] = useState<GuestPersona>('attending');
  const [showQuickEdit, setShowQuickEdit] = useState(false);
  const [editingModule, setEditingModule] = useState<string | null>(null);
  const [showPersonaSelector, setShowPersonaSelector] = useState(false);
  const [contentTransitioning, setContentTransitioning] = useState(false);

  const modules: Module[] = [
    { id: 'story', icon: '📖', title: 'Our Story', description: 'Share your journey with guests', status: 'live', visibleTo: ['All Guests'], previewType: 'text' },
    { id: 'venue', icon: '🗺', title: 'Venue Guide', description: 'Help guests navigate with ease', status: 'live', visibleTo: ['All Guests'], previewType: 'map' },
    { id: 'playlist', icon: '🎵', title: 'Wedding Playlist', description: 'Set the mood before the big day', status: 'setup', visibleTo: [], previewType: 'music' },
    { id: 'rsvp', icon: '💌', title: 'RSVP Collection', description: 'Track responses seamlessly', status: 'live', visibleTo: ['All Guests'], previewType: 'text' },
    { id: 'travel', icon: '🏨', title: 'Travel Concierge', description: 'Hotels, flights, and transport', status: 'live', visibleTo: ['Travelling Guests'], previewType: 'weather' },
    { id: 'photos', icon: '📸', title: 'Photo Sharing', description: 'Collect memories from guests', status: 'hidden', visibleTo: [], previewType: 'photos' },
    { id: 'registry', icon: '🎁', title: 'Gift Registry', description: 'Share your registry choices', status: 'live', visibleTo: ['All Guests'], previewType: 'text' },
    { id: 'messages', icon: '💬', title: 'Guest Messages', description: 'Enable a message board', status: 'hidden', visibleTo: [], previewType: 'text' },
  ];

  const personas = [
    { id: 'attending' as GuestPersona, label: 'Regular Guest', icon: '👤', color: '#3A8B95' },
    { id: 'travelling' as GuestPersona, label: 'Travelling Guest', icon: '✈️', color: '#FF88BA' },
    { id: 'wedding-party' as GuestPersona, label: 'Wedding Party', icon: '💍', color: '#FF3E9B' },
    { id: 'family' as GuestPersona, label: 'Family', icon: '👨‍👩‍👧', color: '#66D0BC' },
    { id: 'pending' as GuestPersona, label: 'Pending RSVP', icon: '⏳', color: '#FFB020' },
    { id: 'vip' as GuestPersona, label: 'VIP Guest', icon: '⭐', color: '#FF6B9D' },
    { id: 'vendor' as GuestPersona, label: 'Vendor', icon: '🎯', color: '#8B7355' },
    { id: 'child' as GuestPersona, label: 'Child Guest', icon: '🧸', color: '#A0C4FF' },
  ];

  const handlePersonaSwitch = (persona: GuestPersona) => {
    setContentTransitioning(true);
    setTimeout(() => {
      setGuestPersona(persona);
      setShowPersonaSelector(false);
      setTimeout(() => setContentTransitioning(false), 300);
    }, 150);
  };

  const getStatusBadge = (status: Module['status']) => {
    switch (status) {
      case 'live':
        return { label: '✨ Live', color: 'bg-[#3A8B95] text-white' };
      case 'hidden':
        return { label: '🕊 Hidden', color: 'bg-gray-200 text-gray-600' };
      case 'setup':
        return { label: '⚙️ Setup', color: 'bg-[#FFB020] text-white' };
    }
  };

  const renderModulePreview = (module: Module) => {
    switch (module.previewType) {
      case 'map':
        return (
          <div className="h-20 bg-gradient-to-br from-[#E8F4F5] to-[#F0F9FA] rounded-lg flex items-center justify-center">
            <MapPin size={20} className="text-[#3A8B95]" />
          </div>
        );
      case 'music':
        return (
          <div className="h-20 bg-gradient-to-br from-[#FFF5F8] to-[#FFE8F0] rounded-lg flex items-center justify-center gap-2">
            <Music size={16} className="text-[#FF3E9B]" />
            <div className="text-[10px] text-gray-600">12 songs</div>
          </div>
        );
      case 'weather':
        return (
          <div className="h-20 bg-gradient-to-br from-[#FFFBF0] to-[#FFF5E8] rounded-lg flex items-center justify-center gap-2">
            <Sun size={20} className="text-[#FFB020]" />
            <div className="text-[14px] font-medium text-gray-800">78°F</div>
          </div>
        );
      case 'photos':
        return (
          <div className="h-20 bg-gradient-to-br from-gray-100 to-gray-50 rounded-lg grid grid-cols-3 gap-1 p-1">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-white rounded" />
            ))}
          </div>
        );
      default:
        return (
          <div className="h-20 bg-gradient-to-br from-[#FAFAFA] to-white rounded-lg flex items-center justify-center">
            <span className="text-[10px] text-gray-500">Content preview</span>
          </div>
        );
    }
  };

  // PLANNING VIEW - Admin controls and configuration
  if (viewMode === 'planning') {
    return (
      <div className="space-y-6 relative">
        {/* View Mode Toggle */}
        <div className="flex items-center justify-center gap-1 p-1 bg-white rounded-full shadow-md border border-gray-100 max-w-md mx-auto sticky top-4 z-10">
          {[
            { id: 'planning' as ViewMode, label: 'Planning View', icon: Settings },
            { id: 'guest' as ViewMode, label: 'Guest View', icon: Eye },
            { id: 'day-of' as ViewMode, label: 'Day-of Mode', icon: Sparkles },
          ].map((mode) => {
            const Icon = mode.icon;
            return (
              <button
                key={mode.id}
                onClick={() => setViewMode(mode.id)}
                className={`flex-1 px-4 py-2.5 rounded-full text-[13px] font-medium transition-all flex items-center justify-center gap-2 ${
                  viewMode === mode.id
                    ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-lg scale-105'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                }`}
              >
                <Icon size={14} />
                <span className="hidden sm:inline">{mode.label}</span>
              </button>
            );
          })}
        </div>

        {/* Planning Mode Header */}
        <div className="text-center">
          <h2 className="text-[28px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
            Experience Builder
          </h2>
          <p className="text-[14px] text-gray-600" style={{ lineHeight: 1.6 }}>
            Craft a beautiful journey for your guests — every module is customizable
          </p>
        </div>

        {/* Experience Modules - FULLY EDITABLE */}
        <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-[20px] text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Experience Modules
              </h3>
              <p className="text-[13px] text-gray-500">Click any module to customize</p>
            </div>
            <button className="px-4 py-2 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white rounded-full text-[13px] font-medium hover:shadow-lg transition-all flex items-center gap-2">
              <Plus size={14} />
              Add Module
            </button>
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            {modules.map((module) => {
              const statusBadge = getStatusBadge(module.status);
              return (
                <button
                  key={module.id}
                  onClick={() => setEditingModule(module.id)}
                  className="p-5 rounded-[20px] border-2 transition-all text-left group hover:shadow-xl hover:-translate-y-1 bg-gradient-to-br from-white to-[#FAFAFA] border-gray-200 hover:border-[#FF88BA] relative overflow-hidden"
                >
                  {/* Grip handle for reordering */}
                  <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Grip size={16} className="text-gray-400" />
                  </div>

                  {/* Module header */}
                  <div className="flex items-start gap-3 mb-3">
                    <div className="text-[28px]">{module.icon}</div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <div className="text-[15px] font-semibold text-gray-900">{module.title}</div>
                        <span className={`text-[9px] px-2 py-0.5 rounded-full font-medium ${statusBadge.color}`}>
                          {statusBadge.label}
                        </span>
                      </div>
                      <div className="text-[12px] text-gray-600 mb-2">{module.description}</div>

                      {/* Audience chips */}
                      {module.visibleTo.length > 0 ? (
                        <div className="flex items-center gap-1.5 flex-wrap">
                          <div className="text-[10px] text-gray-500">Visible to:</div>
                          {module.visibleTo.map((audience) => (
                            <span key={audience} className="text-[10px] px-2 py-0.5 bg-[#3A8B95]/10 text-[#3A8B95] rounded-full font-medium">
                              {audience}
                            </span>
                          ))}
                        </div>
                      ) : (
                        <div className="text-[10px] text-gray-400 italic">Not visible to any guests</div>
                      )}
                    </div>
                  </div>

                  {/* Module preview thumbnail */}
                  {renderModulePreview(module)}

                  {/* Edit indicator */}
                  <div className="mt-3 flex items-center justify-between">
                    <span className="text-[11px] text-gray-500 group-hover:text-[#FF3E9B] transition-colors">
                      Click to customize
                    </span>
                    <ChevronRight size={14} className="text-gray-300 group-hover:text-[#FF3E9B] group-hover:translate-x-1 transition-all" />
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Audience Logic */}
        <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
          <h3 className="text-[20px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
            Audience Logic
          </h3>
          <p className="text-[13px] text-gray-600 mb-6" style={{ lineHeight: 1.6 }}>
            Control which guests see which events and details
          </p>

          <div className="space-y-3">
            {[
              { id: 'ceremony', name: 'Ceremony', groups: ['All Guests'], icon: '💍' },
              { id: 'reception', name: 'Reception', groups: ['All Guests'], icon: '🥂' },
              { id: 'rehearsal-dinner', name: 'Rehearsal Dinner', groups: ['Wedding Party', 'Family'], icon: '🍸' },
              { id: 'transport-details', name: 'Transport Details', groups: ['Travelling Guests'], icon: '✈️' },
              { id: 'private-event', name: 'Private Events', groups: ['Wedding Party'], icon: '🌙' },
            ].map((event) => (
              <button
                key={event.id}
                onClick={() => onShowVisibilityModal(event.id)}
                className="w-full flex items-center gap-4 p-4 bg-gradient-to-r from-[#FAFAFA] to-white rounded-[20px] border-2 border-gray-100 hover:border-[#3A8B95] hover:shadow-md transition-all group"
              >
                <div className="text-[24px]">{event.icon}</div>
                <div className="flex-1 text-left">
                  <div className="text-[14px] font-medium text-gray-900 mb-2">{event.name}</div>
                  <div className="flex items-center gap-1.5 flex-wrap">
                    {event.groups.map((group) => (
                      <span key={group} className="text-[11px] px-2.5 py-1 bg-[#3A8B95] text-white rounded-full font-medium">
                        {group}
                      </span>
                    ))}
                  </div>
                </div>
                <Edit size={16} className="text-gray-300 group-hover:text-[#3A8B95] transition-colors" />
              </button>
            ))}
          </div>
        </div>

        {/* Live Guest Simulation */}
        <div className="bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[32px] p-8 border border-[#3A8B95]/20">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-[20px] text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Test Guest Experience
              </h3>
              <p className="text-[13px] text-gray-600">Preview exactly what your guests will see</p>
            </div>
            <button
              onClick={() => setViewMode('guest')}
              className="px-5 py-2.5 bg-white border-2 border-[#3A8B95] text-[#3A8B95] rounded-full text-[13px] font-medium hover:bg-[#3A8B95] hover:text-white transition-all flex items-center gap-2"
            >
              <Eye size={14} />
              Switch to Guest View
            </button>
          </div>

          <div className="grid md:grid-cols-4 gap-3">
            {[
              { persona: 'attending', label: 'Regular Guest', icon: Users },
              { persona: 'travelling', label: 'Travelling Guest', icon: Plane },
              { persona: 'wedding-party', label: 'Wedding Party', icon: Heart },
              { persona: 'pending', label: 'Pending RSVP', icon: Clock },
            ].map((item) => {
              const Icon = item.icon;
              return (
                <button
                  key={item.persona}
                  className="p-4 bg-white rounded-[16px] border border-gray-100 hover:border-[#FF88BA] hover:shadow-md transition-all text-center group"
                >
                  <Icon size={20} className="mx-auto mb-2 text-gray-400 group-hover:text-[#FF3E9B] transition-colors" />
                  <div className="text-[12px] font-medium text-gray-700">{item.label}</div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Floating Quick Edit Button */}
        <button
          onClick={() => setShowQuickEdit(true)}
          className="fixed bottom-8 right-8 w-14 h-14 bg-gradient-to-br from-[#FF3E9B] to-[#FF88BA] text-white rounded-full shadow-2xl hover:scale-110 transition-all flex items-center justify-center z-50"
        >
          <Edit size={20} />
        </button>

        {/* Module Edit Modal */}
        {editingModule && (
          <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-[32px] max-w-2xl w-full max-h-[90vh] overflow-y-auto p-8">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  {modules.find(m => m.id === editingModule)?.title} Settings
                </h3>
                <button
                  onClick={() => setEditingModule(null)}
                  className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
                >
                  <X size={16} />
                </button>
              </div>

              <div className="space-y-6">
                {/* Module status */}
                <div>
                  <label className="block text-[13px] font-medium text-gray-700 mb-2">Module Status</label>
                  <div className="flex gap-2">
                    {['live', 'hidden', 'setup'].map((status) => {
                      const badge = getStatusBadge(status as Module['status']);
                      return (
                        <button
                          key={status}
                          className={`px-4 py-2 rounded-full text-[12px] font-medium transition-all ${badge.color}`}
                        >
                          {badge.label}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Visible to */}
                <div>
                  <label className="block text-[13px] font-medium text-gray-700 mb-2">Visible To</label>
                  <div className="flex gap-2 flex-wrap">
                    {['All Guests', 'Wedding Party', 'Family', 'Travelling Guests', 'VIP'].map((audience) => (
                      <button
                        key={audience}
                        className="px-4 py-2 bg-[#3A8B95]/10 text-[#3A8B95] rounded-full text-[12px] font-medium hover:bg-[#3A8B95] hover:text-white transition-all"
                      >
                        {audience}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Theme style */}
                <div>
                  <label className="block text-[13px] font-medium text-gray-700 mb-2">Theme Style</label>
                  <div className="grid grid-cols-2 gap-3">
                    {['Minimal', 'Elegant', 'Editorial', 'Romantic'].map((theme) => (
                      <button
                        key={theme}
                        className="p-4 border-2 border-gray-200 rounded-[16px] hover:border-[#FF88BA] transition-all text-[13px] font-medium text-gray-700"
                      >
                        {theme}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Preview */}
                <div>
                  <label className="block text-[13px] font-medium text-gray-700 mb-2">Guest Preview</label>
                  <div className="p-6 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    {renderModulePreview(modules.find(m => m.id === editingModule)!)}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-3 pt-4 border-t border-gray-100">
                  <button
                    onClick={() => setEditingModule(null)}
                    className="flex-1 py-3 border-2 border-gray-200 rounded-full text-[14px] font-medium text-gray-700 hover:bg-gray-50 transition-all"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={() => setEditingModule(null)}
                    className="flex-1 py-3 bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] text-white rounded-full text-[14px] font-medium hover:shadow-lg transition-all"
                  >
                    Save Changes
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  // DAY-OF MODE - Wedding Companion
  if (viewMode === 'day-of') {
    return (
      <div className="space-y-6 bg-gradient-to-br from-[#FAFAFA] via-white to-[#F0F9FA] min-h-screen -m-6 p-6">
        {/* View Mode Toggle */}
        <div className="flex items-center justify-center gap-1 p-1 bg-white rounded-full shadow-md border border-gray-100 max-w-md mx-auto sticky top-4 z-10">
          {[
            { id: 'planning' as ViewMode, label: 'Planning View', icon: Settings },
            { id: 'guest' as ViewMode, label: 'Guest View', icon: Eye },
            { id: 'day-of' as ViewMode, label: 'Day-of Mode', icon: Sparkles },
          ].map((mode) => {
            const Icon = mode.icon;
            return (
              <button
                key={mode.id}
                onClick={() => setViewMode(mode.id)}
                className={`flex-1 px-4 py-2.5 rounded-full text-[13px] font-medium transition-all flex items-center justify-center gap-2 ${
                  viewMode === mode.id
                    ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-lg scale-105'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                }`}
              >
                <Icon size={14} />
                <span className="hidden sm:inline">{mode.label}</span>
              </button>
            );
          })}
        </div>

        {/* Wedding Companion Header */}
        <div className="text-center">
          <div className="text-[36px] leading-tight mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            Olivia & Aaron
          </div>
          <div className="text-[16px] text-gray-700 font-medium mb-1">Saturday, June 15th, 2026</div>
          <div className="text-[14px] text-gray-500">Your Wedding Day Companion</div>
        </div>

        {/* Next Event - Large Card */}
        <div className="bg-white rounded-[32px] p-8 shadow-xl border border-gray-100">
          <div className="flex items-center justify-between mb-4">
            <div className="text-[13px] text-gray-500 uppercase tracking-wide">Up Next</div>
            <div className="text-[13px] font-medium text-[#FF3E9B]">In 45 minutes</div>
          </div>
          <div className="text-center py-6">
            <div className="text-[48px] mb-3">💍</div>
            <div className="text-[32px] font-semibold text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif' }}>
              Ceremony
            </div>
            <div className="text-[20px] text-[#FF3E9B] font-medium mb-1">4:00 PM</div>
            <div className="text-[14px] text-gray-600">Sunset Gardens</div>
          </div>
          <div className="flex gap-3 mt-6">
            <button className="flex-1 py-3 bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] text-white rounded-full text-[14px] font-medium flex items-center justify-center gap-2 hover:shadow-lg transition-all">
              <MapPin size={16} />
              Get Directions
            </button>
            <button className="flex-1 py-3 border-2 border-gray-200 rounded-full text-[14px] font-medium text-gray-700 flex items-center justify-center gap-2 hover:bg-gray-50 transition-all">
              <Calendar size={16} />
              Add to Calendar
            </button>
          </div>
        </div>

        {/* Today's Timeline */}
        <div className="bg-white rounded-[32px] p-6 shadow-lg border border-gray-100">
          <div className="text-[18px] font-semibold text-gray-900 mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
            Today's Timeline
          </div>
          <div className="space-y-3">
            {[
              { time: '4:00 PM', event: 'Ceremony', location: 'Sunset Gardens', icon: '💍', active: true },
              { time: '5:30 PM', event: 'Cocktail Hour', location: 'Garden Terrace', icon: '🍸', active: false },
              { time: '7:00 PM', event: 'Reception', location: 'Main Ballroom', icon: '🥂', active: false },
              { time: '10:00 PM', event: 'After Party', location: 'Beachfront', icon: '🌙', active: false },
            ].map((item, idx) => (
              <div key={idx} className="relative">
                <div className={`flex items-start gap-3 p-4 rounded-[20px] transition-all ${item.active ? 'bg-gradient-to-r from-[#FFF5F8] to-white border-2 border-[#FF3E9B] shadow-md' : 'bg-gray-50 border border-gray-100'}`}>
                  <div className="text-[24px]">{item.icon}</div>
                  <div className="flex-1">
                    <div className="flex items-baseline gap-3 mb-1">
                      <div className={`text-[13px] font-semibold ${item.active ? 'text-[#FF3E9B]' : 'text-gray-500'}`}>{item.time}</div>
                      <div className="text-[15px] font-medium text-gray-900">{item.event}</div>
                    </div>
                    <div className="text-[12px] text-gray-600">{item.location}</div>
                  </div>
                  {item.active && (
                    <div className="text-[10px] px-2 py-1 bg-[#FF3E9B] text-white rounded-full font-medium">
                      Next
                    </div>
                  )}
                </div>
                {idx < 3 && (
                  <div className="absolute left-[46px] top-[68px] w-0.5 h-3 bg-gradient-to-b from-gray-200 to-transparent" />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Quick Actions Grid */}
        <div className="grid grid-cols-2 gap-4">
          <button className="p-6 bg-gradient-to-br from-[#FFFBF0] to-white rounded-[24px] border border-gray-100 hover:shadow-lg transition-all text-center">
            <Sun size={28} className="mx-auto mb-3 text-[#FFB020]" />
            <div className="text-[20px] font-semibold text-gray-900 mb-1">78°F</div>
            <div className="text-[12px] text-gray-600">Perfect weather</div>
          </button>

          <button className="p-6 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[24px] border border-gray-100 hover:shadow-lg transition-all text-center">
            <Bus size={28} className="mx-auto mb-3 text-[#3A8B95]" />
            <div className="text-[14px] font-semibold text-gray-900 mb-1">Shuttle</div>
            <div className="text-[12px] text-gray-600">3:15 PM pickup</div>
          </button>
        </div>

        {/* Emergency Contact */}
        <div className="bg-gradient-to-br from-[#FFF5F8] to-white rounded-[24px] p-6 border border-[#FF88BA]/20">
          <div className="text-[15px] font-semibold text-gray-900 mb-3">Need Help?</div>
          <div className="space-y-2">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-[#FF3E9B]/10 flex items-center justify-center">
                <Users size={18} className="text-[#FF3E9B]" />
              </div>
              <div>
                <div className="text-[13px] font-medium text-gray-900">Wedding Coordinator</div>
                <div className="text-[12px] text-gray-600">+1 (555) 123-4567</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // GUEST VIEW - Interactive Experience Preview Engine
  const currentPersona = personas.find(p => p.id === guestPersona)!;

  return (
    <div className="space-y-6 bg-gradient-to-br from-white via-[#FEFDFB] to-[#F0F9FA] min-h-screen -m-6 p-6">
      {/* View Mode Toggle */}
      <div className="flex items-center justify-center gap-1 p-1 bg-white rounded-full shadow-md border border-gray-100 max-w-md mx-auto sticky top-4 z-20">
        {[
          { id: 'planning' as ViewMode, label: 'Planning View', icon: Settings },
          { id: 'guest' as ViewMode, label: 'Guest View', icon: Eye },
          { id: 'day-of' as ViewMode, label: 'Day-of Mode', icon: Sparkles },
        ].map((mode) => {
          const Icon = mode.icon;
          return (
            <button
              key={mode.id}
              onClick={() => setViewMode(mode.id)}
              className={`flex-1 px-4 py-2.5 rounded-full text-[13px] font-medium transition-all flex items-center justify-center gap-2 ${
                viewMode === mode.id
                  ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-lg scale-105'
                  : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
              }`}
            >
              <Icon size={14} />
              <span className="hidden sm:inline">{mode.label}</span>
            </button>
          );
        })}
      </div>

      {/* Live Simulation Badge */}
      <div className="flex items-center justify-center gap-3">
        <div className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-[#3A8B95]/10 to-[#66D0BC]/10 rounded-full border border-[#3A8B95]/20">
          <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
          <span className="text-[12px] font-medium text-[#3A8B95]">LIVE SIMULATION</span>
        </div>
      </div>

      {/* Viewing As Selector - Custom Floating Menu */}
      <div className="flex items-center justify-center">
        <div className="relative">
          <button
            onClick={() => setShowPersonaSelector(!showPersonaSelector)}
            className="px-6 py-3 bg-white border-2 border-gray-200 rounded-full text-[14px] font-medium text-gray-700 hover:border-[#3A8B95] hover:shadow-md transition-all flex items-center gap-3 min-w-[240px]"
            style={{ borderColor: currentPersona.color + '40' }}
          >
            <span className="text-[20px]">{currentPersona.icon}</span>
            <span className="flex-1 text-left">Viewing as <span className="font-semibold" style={{ color: currentPersona.color }}>{currentPersona.label}</span></span>
            <ChevronDown size={16} className={`transition-transform ${showPersonaSelector ? 'rotate-180' : ''}`} />
          </button>

          {/* Floating Persona Menu */}
          {showPersonaSelector && (
            <>
              {/* Backdrop */}
              <div
                className="fixed inset-0 z-30"
                onClick={() => setShowPersonaSelector(false)}
              />

              {/* Menu */}
              <div className="absolute top-full mt-2 left-0 right-0 bg-white rounded-[24px] shadow-2xl border border-gray-100 overflow-hidden z-40 animate-in fade-in slide-in-from-top-2 duration-200">
                <div className="p-2">
                  {personas.map((persona) => (
                    <button
                      key={persona.id}
                      onClick={() => handlePersonaSwitch(persona.id)}
                      className={`w-full flex items-center gap-3 p-4 rounded-[16px] transition-all text-left ${
                        guestPersona === persona.id
                          ? 'bg-gradient-to-r from-[#F0F9FA] to-[#FFF5F8]'
                          : 'hover:bg-gray-50'
                      }`}
                    >
                      <div className="w-10 h-10 rounded-full flex items-center justify-center text-[20px]" style={{ backgroundColor: persona.color + '15' }}>
                        {persona.icon}
                      </div>
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-900">{persona.label}</div>
                        <div className="text-[11px] text-gray-500">
                          {persona.id === 'attending' && 'Standard guest experience'}
                          {persona.id === 'travelling' && 'Hotels, transport & local tips'}
                          {persona.id === 'wedding-party' && 'Private events & coordination'}
                          {persona.id === 'family' && 'Family-specific details'}
                          {persona.id === 'pending' && 'Limited access until RSVP'}
                          {persona.id === 'vip' && 'Premium experience & perks'}
                          {persona.id === 'vendor' && 'Coordinator access & logistics'}
                          {persona.id === 'child' && 'Kid-friendly content'}
                        </div>
                      </div>
                      {guestPersona === persona.id && (
                        <Check size={18} style={{ color: persona.color }} />
                      )}
                    </button>
                  ))}
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Cinematic Guest Experience Preview - DYNAMIC CONTENT */}
      <div className={`relative bg-gradient-to-br from-[#FAFAFA] via-white to-[#F0F9FA] rounded-[40px] p-12 shadow-2xl border border-gray-100 overflow-hidden transition-all duration-300 ${contentTransitioning ? 'opacity-50 scale-[0.98]' : 'opacity-100 scale-100'}`}>
        {/* Floral texture */}
        <div className="absolute inset-0 opacity-[0.04]" style={{ backgroundImage: 'radial-gradient(circle at 2px 2px, #FF3E9B 1.5px, transparent 0)', backgroundSize: '48px 48px' }} />

        {/* Blurred edges */}
        <div className="absolute top-0 right-0 w-64 h-64 opacity-20 blur-3xl" style={{ background: 'radial-gradient(circle, #FF88BA, transparent)' }} />
        <div className="absolute bottom-0 left-0 w-64 h-64 opacity-20 blur-3xl" style={{ background: 'radial-gradient(circle, #3A8B95, transparent)' }} />

        {/* Shimmer */}
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 to-transparent" style={{ animation: 'shimmer 4s infinite', backgroundSize: '200% 100%' }} />

        <div className="relative z-10">
          {/* Paper card */}
          <div className="bg-white rounded-[32px] p-10 shadow-2xl border border-gray-50">

            {/* PENDING RSVP VIEW - Locked Experience */}
            {guestPersona === 'pending' && (
              <div className="space-y-6 text-center">
                <div className="text-[32px] leading-tight mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                  Olivia & Aaron
                </div>

                <div className="py-8 px-6 bg-gradient-to-br from-[#FFF5F8] to-white rounded-[24px] border-2 border-[#FF3E9B]/30">
                  <div className="text-[48px] mb-4">⏳</div>
                  <div className="text-[20px] font-semibold text-gray-900 mb-3">You're Invited!</div>
                  <div className="text-[14px] text-gray-600 mb-6 leading-relaxed">
                    Please RSVP to unlock your personalized wedding schedule, travel details, and more.
                  </div>
                  <button className="px-8 py-4 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white rounded-full text-[15px] font-medium shadow-lg hover:shadow-xl transition-all">
                    RSVP Now
                  </button>

                  <div className="mt-6 pt-6 border-t border-gray-100">
                    <div className="text-[13px] text-gray-600">
                      <span className="font-medium text-[#FF3E9B]">RSVP Deadline:</span> June 1, 2026
                    </div>
                    <div className="text-[12px] text-gray-500 mt-2">14 days remaining</div>
                  </div>
                </div>

                <div className="text-[12px] text-gray-500 italic">
                  Can't make it? Let us know with a simple decline.
                </div>
              </div>
            )}

            {/* REGULAR GUEST VIEW */}
            {guestPersona === 'attending' && (
              <div className="space-y-6">
                <div className="text-center pb-6 border-b border-gray-100">
                  <div className="text-[40px] leading-tight mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                    Olivia & Aaron
                  </div>
                  <div className="text-[14px] text-gray-600 mb-2">Saturday, June 15th, 2026</div>
                  <div className="text-[13px] text-gray-500 italic">Montego Bay, Jamaica</div>
                </div>

                <div className="py-6 border-y border-gray-100">
                  <p className="text-[14px] text-gray-700 italic text-center leading-relaxed" style={{ fontFamily: 'Playfair Display, serif' }}>
                    "Love is friendship set to music, and we can't wait to celebrate with you"
                  </p>
                </div>

                <div className="space-y-4">
                  <div className="text-[15px] font-semibold text-gray-900">Your Events</div>

                  <div className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px] hover:border-[#FF88BA] hover:shadow-md transition-all">
                    <div className="text-[24px]">💍</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900">Ceremony</div>
                      <div className="text-[12px] text-gray-600">Saturday, 4:00 PM • Sunset Gardens</div>
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px] hover:border-[#FF88BA] hover:shadow-md transition-all">
                    <div className="text-[24px]">🥂</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900">Reception</div>
                      <div className="text-[12px] text-gray-600">Saturday, 7:00 PM • Main Ballroom</div>
                    </div>
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-100 space-y-3">
                  <div className="p-4 bg-white border border-gray-100 rounded-[20px]">
                    <div className="text-[12px] font-medium text-gray-900 mb-1">Venue</div>
                    <div className="text-[12px] text-gray-600">Sunset Gardens, Montego Bay</div>
                  </div>

                  <div className="p-4 bg-white border border-gray-100 rounded-[20px]">
                    <div className="text-[12px] font-medium text-gray-900 mb-1">Dress Code</div>
                    <div className="text-[12px] text-gray-600">Beach formal</div>
                  </div>
                </div>
              </div>
            )}

            {/* TRAVELLING GUEST VIEW - Adds Hotels, Transport, Weather */}
            {guestPersona === 'travelling' && (
              <div className="space-y-6">
                <div className="text-center pb-6 border-b border-gray-100">
                  <div className="text-[40px] leading-tight mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                    Olivia & Aaron
                  </div>
                  <div className="text-[14px] text-gray-600 mb-2">Saturday, June 15th, 2026</div>
                  <div className="text-[13px] text-gray-500 italic">Montego Bay, Jamaica</div>
                </div>

                {/* Weather Widget - UNIQUE TO TRAVELLING */}
                <div className="p-6 bg-gradient-to-br from-[#FFFBF0] to-white rounded-[24px] border border-gray-100 animate-in fade-in slide-in-from-top duration-500">
                  <div className="flex items-center gap-4">
                    <Sun size={40} className="text-[#FFB020]" />
                    <div className="flex-1">
                      <div className="text-[24px] font-semibold text-gray-900 mb-1">78°F Sunny</div>
                      <div className="text-[13px] text-gray-600">Perfect beach weather for your stay</div>
                    </div>
                  </div>
                </div>

                {/* Travel Checklist - UNIQUE TO TRAVELLING */}
                <div className="p-6 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[24px] border border-[#3A8B95]/20 animate-in fade-in slide-in-from-top duration-500 delay-100">
                  <div className="text-[15px] font-semibold text-gray-900 mb-4 flex items-center gap-2">
                    <span className="text-[20px]">✈️</span>
                    Travel Essentials
                  </div>
                  <div className="space-y-3 text-[13px] text-gray-700">
                    <div className="flex items-center gap-2">
                      <Check size={14} className="text-[#3A8B95]" />
                      <span>Nearest airport: {travelStayData.nearestAirport}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Check size={14} className="text-[#3A8B95]" />
                      <span>Hotel shuttle available from 12 PM</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Check size={14} className="text-[#3A8B95]" />
                      <span>No passport required for US citizens</span>
                    </div>
                  </div>
                </div>

                {/* Hotel Recommendations - UNIQUE TO TRAVELLING */}
                <div className="space-y-3 animate-in fade-in slide-in-from-top duration-500 delay-200">
                  <div className="text-[15px] font-semibold text-gray-900">Recommended Hotels</div>
                  {savedHotels.slice(0, 2).map((hotel, idx) => (
                    <div key={hotel.id} className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px] hover:border-[#3A8B95] hover:shadow-md transition-all">
                      <div className="w-16 h-16 rounded-[12px] bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] flex items-center justify-center flex-shrink-0">
                        <Hotel size={20} className="text-[#3A8B95]" />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-start justify-between mb-1">
                          <div className="text-[13px] font-medium text-gray-900">{hotel.name}</div>
                          {hotel.recommended && (
                            <span className="text-[10px] px-2 py-0.5 bg-[#3A8B95] text-white rounded-full">
                              Recommended
                            </span>
                          )}
                        </div>
                        <div className="text-[11px] text-gray-600 mb-2">{hotel.distance}</div>
                        <button className="text-[11px] text-[#FF3E9B] font-medium hover:underline">
                          View details & book
                        </button>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Transport - UNIQUE TO TRAVELLING */}
                {transportGroups.length > 0 && (
                  <div className="space-y-3 animate-in fade-in slide-in-from-top duration-500 delay-300">
                    <div className="text-[15px] font-semibold text-gray-900">Shuttle Service</div>
                    {transportGroups.map((transport) => (
                      <div key={transport.id} className="flex items-start gap-3 p-4 bg-gradient-to-r from-[#F0F9FA] to-white border border-gray-100 rounded-[20px]">
                        <div className="text-[24px]">🚐</div>
                        <div className="flex-1">
                          <div className="text-[13px] font-medium text-gray-900">{transport.name}</div>
                          <div className="text-[11px] text-gray-600 mt-1">
                            {transport.pickupLocation} • {transport.time}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {/* Standard events */}
                <div className="pt-4 border-t border-gray-100 space-y-3">
                  <div className="text-[15px] font-semibold text-gray-900">Your Events</div>
                  <div className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px]">
                    <div className="text-[24px]">💍</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900">Ceremony</div>
                      <div className="text-[12px] text-gray-600">Saturday, 4:00 PM • Sunset Gardens</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px]">
                    <div className="text-[24px]">🥂</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900">Reception</div>
                      <div className="text-[12px] text-gray-600">Saturday, 7:00 PM • Main Ballroom</div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* WEDDING PARTY VIEW - Adds Rehearsal, Private Events */}
            {guestPersona === 'wedding-party' && (
              <div className="space-y-6">
                <div className="text-center pb-6 border-b border-gray-100">
                  <div className="text-[40px] leading-tight mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                    Olivia & Aaron
                  </div>
                  <div className="text-[14px] text-gray-600 mb-2">Saturday, June 15th, 2026</div>
                  <div className="flex items-center justify-center gap-2">
                    <div className="text-[20px]">💍</div>
                    <div className="text-[13px] font-medium text-[#FF3E9B]">Wedding Party Member</div>
                  </div>
                </div>

                {/* Priority Message - UNIQUE TO WEDDING PARTY */}
                <div className="p-6 bg-gradient-to-br from-[#FFF5F8] to-white rounded-[24px] border-2 border-[#FF3E9B]/30 animate-in fade-in slide-in-from-top duration-500">
                  <div className="flex items-start gap-3">
                    <div className="w-10 h-10 rounded-full bg-[#FF3E9B]/10 flex items-center justify-center flex-shrink-0">
                      <Heart size={18} className="text-[#FF3E9B]" />
                    </div>
                    <div>
                      <div className="text-[14px] font-semibold text-gray-900 mb-1">Thank you for being part of our special day!</div>
                      <div className="text-[12px] text-gray-600">
                        Important coordination details and timeline below.
                      </div>
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="text-[15px] font-semibold text-gray-900">Your Schedule</div>

                  {/* Rehearsal Dinner - UNIQUE TO WEDDING PARTY */}
                  <div className="flex items-start gap-3 p-4 bg-gradient-to-br from-[#FFF5F8] to-white border-2 border-[#FF3E9B]/30 rounded-[20px] animate-in fade-in slide-in-from-top duration-500 delay-100">
                    <div className="text-[24px]">🍸</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-[#FF3E9B] mb-1">Rehearsal Dinner</div>
                      <div className="text-[12px] text-gray-600 mb-2">Friday, 6:00 PM • Beachfront Restaurant</div>
                      <div className="text-[10px] px-2 py-1 bg-[#FF3E9B]/10 text-[#FF3E9B] rounded-full inline-block font-medium">
                        Wedding party exclusive
                      </div>
                    </div>
                  </div>

                  {/* Prep Timeline - UNIQUE TO WEDDING PARTY */}
                  <div className="p-4 bg-gradient-to-br from-[#F0F9FA] to-white border border-[#3A8B95]/20 rounded-[20px] animate-in fade-in slide-in-from-top duration-500 delay-200">
                    <div className="text-[13px] font-medium text-gray-900 mb-3">Saturday Prep Timeline</div>
                    <div className="space-y-2 text-[12px] text-gray-600">
                      <div className="flex justify-between">
                        <span>Hair & Makeup</span>
                        <span className="font-medium">11:00 AM</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Photos at venue</span>
                        <span className="font-medium">2:30 PM</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Final walkthrough</span>
                        <span className="font-medium">3:30 PM</span>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px]">
                    <div className="text-[24px]">💍</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900">Ceremony</div>
                      <div className="text-[12px] text-gray-600">Saturday, 4:00 PM • Sunset Gardens</div>
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-4 bg-white border border-gray-100 rounded-[20px]">
                    <div className="text-[24px]">🥂</div>
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-900">Reception</div>
                      <div className="text-[12px] text-gray-600">Saturday, 7:00 PM • Main Ballroom</div>
                    </div>
                  </div>
                </div>

                {/* Emergency Contacts - UNIQUE TO WEDDING PARTY */}
                <div className="p-4 bg-white border border-gray-100 rounded-[20px] animate-in fade-in slide-in-from-top duration-500 delay-300">
                  <div className="text-[13px] font-medium text-gray-900 mb-3">Coordinator Contacts</div>
                  <div className="space-y-2 text-[12px] text-gray-600">
                    <div>Wedding Planner: +1 (555) 123-4567</div>
                    <div>Photographer: +1 (555) 234-5678</div>
                  </div>
                </div>
              </div>
            )}

            {/* VIP, FAMILY, VENDOR, CHILD personas can have similar custom views */}
            {(guestPersona === 'family' || guestPersona === 'vip' || guestPersona === 'vendor' || guestPersona === 'child') && (
              <div className="space-y-6 text-center">
                <div className="text-[40px] leading-tight mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                  Olivia & Aaron
                </div>
                <div className="text-[14px] text-gray-600 mb-2">Saturday, June 15th, 2026</div>

                <div className="py-8 px-6 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[24px] border border-gray-100">
                  <div className="text-[48px] mb-4">{currentPersona.icon}</div>
                  <div className="text-[18px] font-semibold text-gray-900 mb-3">{currentPersona.label} View</div>
                  <div className="text-[13px] text-gray-600">
                    Custom experience for this audience type
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      <style>{`
        @keyframes shimmer {
          0% { background-position: -200% 0; }
          100% { background-position: 200% 0; }
        }
        @keyframes fade-in {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slide-in-from-top {
          from { transform: translateY(-10px); }
          to { transform: translateY(0); }
        }
        @keyframes slide-in-from-top-2 {
          from { transform: translateY(-4px); }
          to { transform: translateY(0); }
        }
        .animate-in {
          animation-fill-mode: both;
        }
        .fade-in {
          animation-name: fade-in;
        }
        .slide-in-from-top {
          animation-name: slide-in-from-top;
        }
        .slide-in-from-top-2 {
          animation-name: slide-in-from-top-2;
        }
        .delay-100 {
          animation-delay: 100ms;
        }
        .delay-200 {
          animation-delay: 200ms;
        }
        .delay-300 {
          animation-delay: 300ms;
        }
      `}</style>
    </div>
  );
}
