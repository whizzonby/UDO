import { useState } from 'react';
import { Plane, Hotel, MapPin, Users, Calendar, Clock, AlertCircle, Car, Ship, Sun, Globe, Check, ChevronRight, Edit, Plus, Link2, Settings, Sparkles, MessageCircle } from 'lucide-react';

interface GuestLogisticsProps {
  savedHotels: any[];
  transportGroups: any[];
  onShowEditHotels: () => void;
  onShowEditTransport: () => void;
  onShowComposeMessage: () => void;
}

type WeddingMode = 'destination' | 'local';
type LogisticsView = 'overview' | 'arrivals' | 'transport' | 'accommodation';

export default function GuestLogistics({
  savedHotels,
  transportGroups,
  onShowEditHotels,
  onShowEditTransport,
  onShowComposeMessage,
}: GuestLogisticsProps) {
  const [weddingMode, setWeddingMode] = useState<WeddingMode>('destination');
  const [logisticsView, setLogisticsView] = useState<LogisticsView>('overview');

  const stats = {
    travellingGuests: 42,
    partnerHotelGuests: 31,
    airportTransfersRequested: 18,
    missingArrivalInfo: 7,
    shuttleSeatsRemaining: 14,
    villaGroups: 3,
  };

  return (
    <div className="space-y-6">
      {/* Page Intro */}
      <div>
        <p className="text-[15px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
          Coordinate arrivals, transportation, and accommodation like a luxury concierge
        </p>

        {/* Wedding Mode Toggle */}
        <div className="flex items-center gap-3">
          <span className="text-[13px] text-gray-600">Wedding type:</span>
          <div className="inline-flex gap-2 p-1 bg-white rounded-full border border-gray-200">
            <button
              onClick={() => setWeddingMode('destination')}
              className={`px-4 py-2 rounded-full text-[13px] font-medium transition-all flex items-center gap-2 ${
                weddingMode === 'destination'
                  ? 'bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] text-white shadow-md'
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <Globe size={14} />
              Destination Wedding
            </button>
            <button
              onClick={() => setWeddingMode('local')}
              className={`px-4 py-2 rounded-full text-[13px] font-medium transition-all flex items-center gap-2 ${
                weddingMode === 'local'
                  ? 'bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] text-white shadow-md'
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <MapPin size={14} />
              Local Wedding
            </button>
          </div>
        </div>
      </div>

      {/* Master Overview - Operationally Intelligent Dashboard */}
      {logisticsView === 'overview' && (
        <>
          {/* Destination Wedding Banner */}
          {weddingMode === 'destination' && (
            <div className="bg-gradient-to-br from-[#F0F9FA] to-[#E8F4F5] rounded-[32px] p-8 border border-[#3A8B95]/20">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-14 h-14 rounded-full bg-white flex items-center justify-center flex-shrink-0">
                  <Globe size={24} className="text-[#3A8B95]" />
                </div>
                <div className="flex-1">
                  <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                    Traveling to Jamaica 🇯🇲
                  </h3>
                  <p className="text-[14px] text-gray-600 leading-relaxed">
                    Destination wedding mode is active. Your guests will see travel coordination, accommodation options, and local recommendations.
                  </p>
                </div>
                <button className="px-4 py-2 bg-white border border-[#3A8B95]/30 text-[#3A8B95] rounded-full text-[13px] font-medium hover:bg-[#3A8B95] hover:text-white transition-all">
                  <Settings size={14} className="inline mr-1" />
                  Configure
                </button>
              </div>

              <div className="grid md:grid-cols-4 gap-3">
                <div className="p-3 bg-white/80 backdrop-blur-sm rounded-[16px]">
                  <div className="text-[11px] text-gray-600 mb-1">Weather</div>
                  <div className="flex items-center gap-2">
                    <Sun size={16} className="text-[#FFB020]" />
                    <span className="text-[14px] font-medium text-gray-900">78°F & Sunny</span>
                  </div>
                </div>
                <div className="p-3 bg-white/80 backdrop-blur-sm rounded-[16px]">
                  <div className="text-[11px] text-gray-600 mb-1">Currency</div>
                  <div className="text-[14px] font-medium text-gray-900">USD widely accepted</div>
                </div>
                <div className="p-3 bg-white/80 backdrop-blur-sm rounded-[16px]">
                  <div className="text-[11px] text-gray-600 mb-1">Airport</div>
                  <div className="text-[14px] font-medium text-gray-900">MBJ (Montego Bay)</div>
                </div>
                <div className="p-3 bg-white/80 backdrop-blur-sm rounded-[16px]">
                  <div className="text-[11px] text-gray-600 mb-1">Tip</div>
                  <div className="text-[14px] font-medium text-gray-900">Lightweight formal</div>
                </div>
              </div>
            </div>
          )}

          {/* Smart KPIs - What Needs Attention */}
          <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
            <h3 className="text-[20px] text-gray-900 mb-6" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
              Coordination Overview
            </h3>

            <div className="grid md:grid-cols-3 gap-4 mb-6">
              {/* Travelling Guests */}
              <div className="p-6 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[24px] border border-gray-100">
                <div className="flex items-center justify-between mb-3">
                  <div className="w-12 h-12 rounded-full bg-[#3A8B95]/10 flex items-center justify-center">
                    <Plane size={20} className="text-[#3A8B95]" />
                  </div>
                  <div className="text-[32px] font-semibold text-gray-900">{stats.travellingGuests}</div>
                </div>
                <div className="text-[13px] text-gray-600 mb-2">Travelling guests</div>
                <div className="text-[11px] text-[#3A8B95] font-medium">{stats.partnerHotelGuests} at partner hotels</div>
              </div>

              {/* Airport Transfers */}
              <div className="p-6 bg-gradient-to-br from-[#FFF5F8] to-white rounded-[24px] border border-gray-100">
                <div className="flex items-center justify-between mb-3">
                  <div className="w-12 h-12 rounded-full bg-[#FF3E9B]/10 flex items-center justify-center">
                    <Car size={20} className="text-[#FF3E9B]" />
                  </div>
                  <div className="text-[32px] font-semibold text-gray-900">{stats.airportTransfersRequested}</div>
                </div>
                <div className="text-[13px] text-gray-600 mb-2">Airport transfers</div>
                <div className="text-[11px] text-gray-500">{stats.shuttleSeatsRemaining} shuttle seats left</div>
              </div>

              {/* Needs Attention */}
              <div className="p-6 bg-gradient-to-br from-[#FFFBF0] to-white rounded-[24px] border border-gray-100">
                <div className="flex items-center justify-between mb-3">
                  <div className="w-12 h-12 rounded-full bg-[#FFB020]/10 flex items-center justify-center">
                    <AlertCircle size={20} className="text-[#FFB020]" />
                  </div>
                  <div className="text-[32px] font-semibold text-[#FFB020]">{stats.missingArrivalInfo}</div>
                </div>
                <div className="text-[13px] text-gray-600 mb-2">Missing arrival info</div>
                <button
                  onClick={onShowComposeMessage}
                  className="text-[11px] text-[#FFB020] font-medium hover:underline"
                >
                  Send reminder →
                </button>
              </div>
            </div>

            {/* Quick View Tabs */}
            <div className="flex gap-2 overflow-x-auto pb-2">
              {[
                { id: 'overview', label: 'Overview', icon: Globe },
                { id: 'arrivals', label: 'Arrivals', icon: Plane },
                { id: 'transport', label: 'Transport', icon: Car },
                { id: 'accommodation', label: 'Accommodation', icon: Hotel },
              ].map((view) => {
                const Icon = view.icon;
                return (
                  <button
                    key={view.id}
                    onClick={() => setLogisticsView(view.id as LogisticsView)}
                    className={`px-4 py-2.5 rounded-full text-[13px] font-medium transition-all flex items-center gap-2 whitespace-nowrap ${
                      logisticsView === view.id
                        ? 'bg-[#3A8B95] text-white'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    <Icon size={14} />
                    {view.label}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Smart Automations - What Udo Can Do */}
          <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h3 className="text-[20px] text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Smart Coordination
                </h3>
                <p className="text-[13px] text-gray-600">Automatic reminders and intelligent grouping</p>
              </div>
              <div className="flex items-center gap-2 px-3 py-1.5 bg-[#3A8B95]/10 rounded-full">
                <Sparkles size={14} className="text-[#3A8B95]" />
                <span className="text-[12px] font-medium text-[#3A8B95]">Automations active</span>
              </div>
            </div>

            <div className="space-y-3">
              {[
                {
                  title: 'Arrival window grouping',
                  description: '4 guests arriving within 2 hours of each other have been auto-grouped for shared shuttle',
                  action: 'View groups',
                  color: '#3A8B95',
                  icon: Users,
                },
                {
                  title: 'Villa coordination',
                  description: 'Villa Azure guests will receive a shared chat 48 hours before check-in',
                  action: 'Preview message',
                  color: '#FF88BA',
                  icon: MessageCircle,
                },
                {
                  title: 'Missing information reminder',
                  description: '7 guests will receive a gentle arrival details reminder tomorrow',
                  action: 'Edit timing',
                  color: '#FFB020',
                  icon: Clock,
                },
                {
                  title: 'Shuttle capacity alert',
                  description: 'Welcome dinner shuttle is 85% full - consider adding another pickup',
                  action: 'Add shuttle',
                  color: '#FF3E9B',
                  icon: AlertCircle,
                },
              ].map((automation, idx) => {
                const Icon = automation.icon;
                return (
                  <div
                    key={idx}
                    className="flex items-start justify-between p-5 rounded-[20px] border border-gray-100 hover:border-gray-200 hover:shadow-md transition-all group"
                  >
                    <div className="flex items-start gap-4 flex-1">
                      <div
                        className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0"
                        style={{ backgroundColor: `${automation.color}15` }}
                      >
                        <Icon size={20} style={{ color: automation.color }} />
                      </div>
                      <div className="flex-1">
                        <div className="text-[15px] font-medium text-gray-900 mb-1">{automation.title}</div>
                        <div className="text-[13px] text-gray-600 leading-relaxed">{automation.description}</div>
                      </div>
                    </div>
                    <button
                      className="px-4 py-2 rounded-full text-[13px] font-medium transition-all opacity-0 group-hover:opacity-100"
                      style={{ backgroundColor: automation.color, color: 'white' }}
                    >
                      {automation.action}
                    </button>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Shared Accommodation Groups - Villa Coordination */}
          {weddingMode === 'destination' && (
            <div className="bg-gradient-to-br from-white via-[#FEFDFB] to-[#F0F9FA] rounded-[32px] p-8 shadow-lg border border-gray-100">
              <div className="flex items-center justify-between mb-6">
                <div>
                  <h3 className="text-[20px] text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                    Villa Groups
                  </h3>
                  <p className="text-[13px] text-gray-600">Shared accommodation coordination</p>
                </div>
                <button
                  onClick={onShowEditHotels}
                  className="px-4 py-2 bg-[#3A8B95] text-white rounded-full text-[13px] font-medium hover:shadow-md transition-all flex items-center gap-2"
                >
                  <Plus size={14} />
                  Add Villa
                </button>
              </div>

              <div className="space-y-4">
                {[
                  {
                    name: 'Villa Azure',
                    guests: ['Jessica M.', 'Amanda R.', 'Sarah P.'],
                    checkIn: 'June 12',
                    transport: 'Shared shuttle included',
                    amountDue: '$320',
                    status: 'pending',
                  },
                  {
                    name: 'Ocean Breeze',
                    guests: ['Michael C.', 'Thomas K.'],
                    checkIn: 'June 11',
                    transport: 'Private transfer arranged',
                    amountDue: '$280',
                    status: 'paid',
                  },
                  {
                    name: 'Sunset Manor',
                    guests: ['Emily R.', 'David P.', 'Maria G.', 'Carlos M.'],
                    checkIn: 'June 12',
                    transport: 'Shuttle TBD',
                    amountDue: '$450',
                    status: 'pending',
                  },
                ].map((villa, idx) => (
                  <div
                    key={idx}
                    className="p-6 bg-white rounded-[24px] border border-gray-100 hover:border-[#3A8B95] hover:shadow-lg transition-all"
                  >
                    <div className="flex items-start justify-between mb-4">
                      <div>
                        <div className="text-[17px] font-semibold text-gray-900 mb-1">{villa.name}</div>
                        <div className="flex items-center gap-2">
                          <div className="text-[13px] text-gray-600">{villa.guests.length} guests</div>
                          <div className="w-1 h-1 rounded-full bg-gray-300" />
                          <div className="text-[13px] text-gray-600">Check-in: {villa.checkIn}</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-[18px] font-semibold text-gray-900">{villa.amountDue}</div>
                        <div
                          className={`text-[11px] px-2 py-1 rounded-full font-medium ${
                            villa.status === 'paid'
                              ? 'bg-[#3A8B95]/10 text-[#3A8B95]'
                              : 'bg-[#FFB020]/10 text-[#FFB020]'
                          }`}
                        >
                          {villa.status === 'paid' ? '✓ Paid' : 'Pending'}
                        </div>
                      </div>
                    </div>

                    <div className="space-y-3">
                      {/* Guests */}
                      <div>
                        <div className="text-[12px] text-gray-500 mb-2">Assigned guests</div>
                        <div className="flex gap-2 flex-wrap">
                          {villa.guests.map((guest, gIdx) => (
                            <div
                              key={gIdx}
                              className="px-3 py-1.5 bg-gray-50 rounded-full text-[12px] text-gray-700 flex items-center gap-2"
                            >
                              <div
                                className="w-6 h-6 rounded-full bg-gradient-to-br from-[#3A8B95] to-[#66D0BC] flex items-center justify-center text-[10px] text-white font-medium"
                              >
                                {guest.split(' ').map(n => n[0]).join('')}
                              </div>
                              {guest}
                            </div>
                          ))}
                        </div>
                      </div>

                      {/* Transport */}
                      <div className="flex items-center gap-2 text-[13px] text-gray-600">
                        <Car size={14} className="text-[#3A8B95]" />
                        <span>{villa.transport}</span>
                      </div>

                      {/* Actions */}
                      <div className="flex gap-2 pt-2 border-t border-gray-100">
                        <button className="flex-1 py-2 border border-gray-200 rounded-full text-[12px] font-medium text-gray-700 hover:bg-gray-50 transition-all">
                          View details
                        </button>
                        <button className="flex-1 py-2 border border-gray-200 rounded-full text-[12px] font-medium text-gray-700 hover:bg-gray-50 transition-all flex items-center justify-center gap-1">
                          <MessageCircle size={12} />
                          Villa chat
                        </button>
                        <button className="px-4 py-2 bg-[#3A8B95] text-white rounded-full text-[12px] font-medium hover:shadow-md transition-all">
                          Manage
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Event Transportation Schedule */}
          <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
            <div className="flex items-center justify-between mb-6">
              <div>
                <h3 className="text-[20px] text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Event Transportation
                </h3>
                <p className="text-[13px] text-gray-600">Shuttle schedules for each event</p>
              </div>
              <button
                onClick={onShowEditTransport}
                className="px-4 py-2 border-2 border-gray-200 text-gray-700 rounded-full text-[13px] font-medium hover:bg-gray-50 transition-all flex items-center gap-2"
              >
                <Edit size={14} />
                Edit Schedule
              </button>
            </div>

            <div className="space-y-3">
              {[
                {
                  event: 'Welcome Dinner',
                  icon: '🍸',
                  date: 'Thursday, June 12',
                  pickup: '6:00 PM',
                  return: '10:30 PM',
                  pickupPoints: ['Fairmont', 'Villa Azure', 'Ocean Breeze'],
                  capacity: '32/38 seats reserved',
                  status: 'active',
                },
                {
                  event: 'Catamaran Party',
                  icon: '⛵',
                  date: 'Friday, June 13',
                  pickup: '9:00 AM',
                  return: '2:00 PM',
                  pickupPoints: ['Fairmont', 'Ocean Breeze Villas'],
                  capacity: '18/30 seats reserved',
                  status: 'active',
                },
                {
                  event: 'Ceremony',
                  icon: '💍',
                  date: 'Saturday, June 14',
                  pickup: '2:15 PM & 2:45 PM',
                  return: 'Continuous after 6 PM',
                  pickupPoints: ['All partner hotels'],
                  capacity: '86 attending',
                  status: 'active',
                },
                {
                  event: 'After Party Return',
                  icon: '🌙',
                  date: 'Saturday, June 14',
                  pickup: 'Continuous',
                  return: '11:30 PM - 2:00 AM',
                  pickupPoints: ['Fairmont', 'Villa Azure', 'Ocean Breeze'],
                  capacity: 'Unlimited',
                  status: 'active',
                },
              ].map((transport, idx) => (
                <div
                  key={idx}
                  className="p-5 rounded-[20px] border border-gray-100 hover:border-[#3A8B95] hover:shadow-md transition-all"
                >
                  <div className="flex items-start gap-4">
                    <div className="text-[32px]">{transport.icon}</div>
                    <div className="flex-1">
                      <div className="flex items-start justify-between mb-3">
                        <div>
                          <div className="text-[16px] font-semibold text-gray-900 mb-1">{transport.event}</div>
                          <div className="text-[13px] text-gray-600">{transport.date}</div>
                        </div>
                        <div className="text-[12px] px-3 py-1 bg-[#3A8B95]/10 text-[#3A8B95] rounded-full font-medium">
                          {transport.capacity}
                        </div>
                      </div>

                      <div className="grid md:grid-cols-2 gap-3 mb-3">
                        <div className="flex items-center gap-2 text-[13px] text-gray-600">
                          <Clock size={14} className="text-[#3A8B95]" />
                          <span>Pickup: {transport.pickup}</span>
                        </div>
                        <div className="flex items-center gap-2 text-[13px] text-gray-600">
                          <Clock size={14} className="text-[#FF88BA]" />
                          <span>Return: {transport.return}</span>
                        </div>
                      </div>

                      <div className="text-[12px] text-gray-600 mb-3">
                        <span className="font-medium">Pickup points:</span> {transport.pickupPoints.join(', ')}
                      </div>

                      <button className="text-[13px] text-[#3A8B95] font-medium hover:underline flex items-center gap-1">
                        View guest signups
                        <ChevronRight size={14} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Guest Experience Preview */}
          <div className="bg-gradient-to-br from-[#FFF5F8] to-white rounded-[32px] p-8 border border-[#FF88BA]/20">
            <div className="text-center mb-6">
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-white rounded-full mb-4 shadow-sm">
                <Sparkles size={14} className="text-[#FF3E9B]" />
                <span className="text-[12px] font-medium text-[#FF3E9B]">Guest Portal Preview</span>
              </div>
              <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                What Your Guests See
              </h3>
              <p className="text-[14px] text-gray-600">
                Every guest gets a personalized portal with their travel information
              </p>
            </div>

            <div className="p-6 bg-white rounded-[24px] border border-gray-100">
              <div className="text-center mb-4">
                <div className="text-[20px] font-semibold text-gray-900 mb-1">Jessica's Wedding Portal</div>
                <div className="text-[13px] text-gray-600 mb-2">udo.app/olivia-aaron/jessica</div>
                <button className="text-[12px] text-[#3A8B95] font-medium hover:underline flex items-center gap-1 mx-auto">
                  <Link2 size={12} />
                  Copy link
                </button>
              </div>

              <div className="space-y-2">
                {['✓ RSVP Status', '✓ Personalized Itinerary', '✓ Transportation Schedule', '✓ Villa Azure Details', '✓ Airport Transfer Info', '✓ Emergency Contacts', '✓ Wedding Wall Access'].map((item, idx) => (
                  <div key={idx} className="flex items-center gap-2 text-[13px] text-gray-700 p-2 bg-gray-50 rounded-lg">
                    <Check size={14} className="text-[#3A8B95]" />
                    <span>{item}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
