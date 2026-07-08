'use client';

import { useState, useEffect } from 'react';
import { Search, Plus, Mail, Link as LinkIcon, Eye, MapPin, MessageSquare, Users as UsersIcon, ChevronRight, Calendar, MapPinIcon, Clock, AlertCircle, Send, X, Check, Hotel, Plane, Bus, Copy, Edit, LayoutGrid } from 'lucide-react';
import { api } from '@/lib/api';
import { getToken } from '@/lib/auth';
import GuestOverview from './guests/GuestOverview';
import GuestListSection from './guests/GuestListSection';
import InvitationStudio from './guests/InvitationStudio';
import GuestExperience from './guests/GuestExperience';
import WeddingWall from './guests/WeddingWall';
import GuestLogistics from './guests/GuestLogistics';

type GuestTab = 'overview' | 'guests' | 'invites' | 'landing' | 'messages' | 'logistics';
type GuestViewType = 'attending' | 'travelling' | 'wedding-party' | 'pending';
type VisibilityGroup = 'All Guests' | 'Wedding Party' | 'Family' | 'Travelling Guests';

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

export default function GuestsPage() {
  const [activeTab, setActiveTab] = useState<GuestTab>('overview');
  const [showInvitePreview, setShowInvitePreview] = useState(false);
  const [showGuestDetail, setShowGuestDetail] = useState(false);
  const [showAddGuestModal, setShowAddGuestModal] = useState(false);
  const [showImportGuestsModal, setShowImportGuestsModal] = useState(false);
  const [showNeedsAttentionPanel, setShowNeedsAttentionPanel] = useState(false);
  const [guestViewType, setGuestViewType] = useState<GuestViewType>('attending');
  const [dayOfView, setDayOfView] = useState(false);
  const [showReminderModal, setShowReminderModal] = useState(false);
  const [showQuickAction, setShowQuickAction] = useState<'calendar' | 'maps' | 'schedule' | null>(null);
  const [showVisibilityModal, setShowVisibilityModal] = useState(false);
  const [selectedEventForVisibility, setSelectedEventForVisibility] = useState<string | null>(null);
  const [addGuestMode, setAddGuestMode] = useState<'quick' | 'manual'>('quick');
  const [showBulkActionsPanel, setShowBulkActionsPanel] = useState(false);
  const [showEditInviteContent, setShowEditInviteContent] = useState(false);
  const [showChangeTheme, setShowChangeTheme] = useState(false);
  const [showComposeMessage, setShowComposeMessage] = useState(false);
  const [showGuestLogisticsDetail, setShowGuestLogisticsDetail] = useState(false);
  const [showEditHotels, setShowEditHotels] = useState(false);
  const [showEditTransport, setShowEditTransport] = useState(false);
  const [showSendInvitationsModal, setShowSendInvitationsModal] = useState(false);
  const [addGuestPlusOne, setAddGuestPlusOne] = useState(false);
  const [addGuestTravelling, setAddGuestTravelling] = useState(false);
  const [showGuestInsights, setShowGuestInsights] = useState(false);
  const [showGuestJourney, setShowGuestJourney] = useState(false);
  const [showVIPGuests, setShowVIPGuests] = useState(false);
  const [showExperienceDesign, setShowExperienceDesign] = useState(false);

  // Guest list filters and sort
  const [primaryFilter, setPrimaryFilter] = useState('all');
  const [secondaryFilter, setSecondaryFilter] = useState<string | null>(null);
  const [guestSort, setGuestSort] = useState('rsvp-status');
  const [hoveredGuestIdx, setHoveredGuestIdx] = useState<number | null>(null);

  // Message form state
  const [messageRecipient, setMessageRecipient] = useState('All guests (120)');
  const [messageDeliveryMethod, setMessageDeliveryMethod] = useState<'email' | 'sms' | 'whatsapp'>('email');
  const [messageSubject, setMessageSubject] = useState('');
  const [messageBody, setMessageBody] = useState('');
  const [includeGuestLink, setIncludeGuestLink] = useState(true);

  // Reminder form state
  const [reminderSubject, setReminderSubject] = useState('Friendly reminder: Please RSVP');
  const [reminderBody, setReminderBody] = useState("Hi there! We're finalizing details for our wedding and would love to know if you'll be joining us. Please take a moment to RSVP when you can. Looking forward to celebrating with you!");
  const [includeRsvpLink, setIncludeRsvpLink] = useState(true);

  // Visibility rules state
  const [visibilityRules, setVisibilityRules] = useState<{[key: string]: VisibilityGroup[]}>({
    'rehearsal-dinner': ['Wedding Party', 'Family'],
    'transport-details': ['Travelling Guests'],
    'private-event': ['Wedding Party'],
    'ceremony': ['All Guests'],
    'reception': ['All Guests'],
  });

  // Travel & Stay state
  const [showTravelStayModal, setShowTravelStayModal] = useState(false);
  const [showHotelSearchMode, setShowHotelSearchMode] = useState(false);
  const [showHotelDetailsModal, setShowHotelDetailsModal] = useState(false);
  const [showMapViewModal, setShowMapViewModal] = useState(false);
  const [selectedHotelForDetails, setSelectedHotelForDetails] = useState<string | null>(null);
  const [travelStayData, setTravelStayData] = useState({
    weddingCity: 'San Francisco',
    venueName: 'Palace of Fine Arts',
    venueAddress: '3301 Lyon Street, San Francisco, CA 94123',
    nearestAirport: 'San Francisco International Airport (SFO)',
    showFlightSuggestions: true,
    travelTips: '',
    showTransportOptions: true,
  });
  const [savedHotels, setSavedHotels] = useState<any[]>([]);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<{ data: any[] }>('/logistics/accommodation', t)
      .then(res => setSavedHotels(res.data ?? []))
      .catch(() => {});
  }, []);
  const [transportGroups, setTransportGroups] = useState<any[]>([]);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<{ data: any[] }>('/logistics/transport', t)
      .then(res => setTransportGroups(res.data ?? []))
      .catch(() => {});
  }, []);

  const [messageSending, setMessageSending] = useState(false);
  const sendMessage = async () => {
    if (!messageBody.trim() || !messageSubject.trim()) return;
    const t = getToken();
    if (!t) return;
    setMessageSending(true);
    try {
      await api.post('/messages', {
        subject: messageSubject,
        body: messageBody,
        channel: messageDeliveryMethod,
        message_type: 'general',
      }, t);
      setShowComposeMessage(false);
      setMessageSubject('');
      setMessageBody('');
    } catch {}
    finally { setMessageSending(false); }
  };

  const [invitationSending, setInvitationSending] = useState(false);
  const publishInvitation = async () => {
    const t = getToken();
    if (!t) return;
    setInvitationSending(true);
    try {
      await api.post('/invitation/publish', {}, t);
      setShowSendInvitationsModal(false);
    } catch {}
    finally { setInvitationSending(false); }
  };

  const tabs = [
    { id: 'overview' as GuestTab, label: 'Overview' },
    { id: 'guests' as GuestTab, label: 'Guest List' },
    { id: 'invites' as GuestTab, label: 'Invitations' },
    { id: 'landing' as GuestTab, label: 'Guest Experience' },
    { id: 'messages' as GuestTab, label: 'Messages' },
    { id: 'logistics' as GuestTab, label: 'Guest Logistics' },
  ];

  const [guests, setGuests] = useState<{id:number;first_name:string;last_name:string;email?:string;attending_status:string;meal_preference?:string;plus_one_allowed?:boolean}[]>([]);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<any[]>('/guests', t)
      .then(data => setGuests(Array.isArray(data) ? data : []))
      .catch(() => {});
  }, []);

  return (
    <div className="min-h-screen bg-[#fefdfb]">
      {/* Header */}
      <div className="bg-white border-b border-gray-100 px-4 pt-6 pb-4">
        <h1 className="text-3xl text-[#FF3E9B] mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>Guests</h1>
        {/* Tab Navigation */}
        <div className="flex gap-2 overflow-x-auto pb-2">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-4 py-2 rounded-full whitespace-nowrap transition-all ${
                activeTab === tab.id
                  ? 'bg-[#3A8B95] text-white'
                  : 'bg-[#FAFAFA] text-gray-700 hover:bg-[#FF88BA]/30'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-6">
        {activeTab === 'overview' && (
          <GuestOverview
            onAddGuest={() => setShowAddGuestModal(true)}
            onNavigateToTab={(tab) => setActiveTab(tab as GuestTab)}
          />
        )}

        {activeTab === 'guests' && (
          <GuestListSection
            guests={guests.map(g => ({
              name: `${g.first_name} ${g.last_name || ''}`.trim(),
              email: g.email ?? '',
              rsvp: g.attending_status === 'attending' ? 'Attending' : g.attending_status === 'declined' ? 'Declined' : 'Pending',
              meal: g.meal_preference ?? '-',
              plusOne: g.plus_one_allowed ?? false,
            }))}
            onAddGuest={() => setShowAddGuestModal(true)}
            onImportGuests={() => setShowImportGuestsModal(true)}
            onShowGuestDetail={() => setShowGuestDetail(true)}
            onComposeMessage={() => setShowComposeMessage(true)}
          />
        )}
        {activeTab === 'invites' && (
          <InvitationStudio
            onShowPreview={() => setShowInvitePreview(true)}
            onEditContent={() => setShowEditInviteContent(true)}
            onChangeTheme={() => setShowChangeTheme(true)}
            onSendInvitations={() => setShowSendInvitationsModal(true)}
          />
        )}

        {activeTab === 'landing' && (
          <GuestExperience
            savedHotels={savedHotels}
            transportGroups={transportGroups}
            travelStayData={travelStayData}
            visibilityRules={visibilityRules}
            onShowReminderModal={() => setShowReminderModal(true)}
            onShowVisibilityModal={(eventId) => {
              setSelectedEventForVisibility(eventId);
              setShowVisibilityModal(true);
            }}
            onShowTravelStayModal={() => setShowTravelStayModal(true)}
            onShowHotelDetailsModal={(hotelId) => {
              setSelectedHotelForDetails(hotelId);
              setShowHotelDetailsModal(true);
            }}
            onShowMapViewModal={() => setShowMapViewModal(true)}
            onShowQuickAction={(action) => setShowQuickAction(action)}
          />
        )}

        {activeTab === 'messages' && (
          <WeddingWall
            onShowComposeMessage={() => setShowComposeMessage(true)}
            onShowReminderModal={() => setShowReminderModal(true)}
          />
        )}

        {activeTab === 'logistics' && (
          <GuestLogistics
            savedHotels={savedHotels}
            transportGroups={transportGroups}
            onShowEditHotels={() => setShowEditHotels(true)}
            onShowEditTransport={() => setShowEditTransport(true)}
            onShowComposeMessage={() => setShowComposeMessage(true)}
          />
        )}
      </div>

      {/* Invite Preview Modal */}
      {showInvitePreview && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowInvitePreview(false)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="bg-gradient-to-br from-[#FAFAFA] via-white to-[#FAFAFA] p-8 rounded-2xl border-2 border-[#FF88BA]/30">
              <div className="text-center">
                <div className="text-xs text-[#FF3E9B] mb-2 tracking-widest uppercase">You are invited to celebrate</div>
                <div className="text-4xl text-[#FF3E9B] mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
                  Olivia & Aaron
                </div>
                <div className="h-[1px] bg-gradient-to-r from-transparent via-[#f194b2] to-transparent my-4"></div>
                <div className="text-sm text-gray-600 mb-2">Saturday, June 15th, 2026</div>
                <div className="text-sm text-gray-600 mb-4">4:00 PM</div>
                <div className="text-base text-gray-700 mb-6">
                  Sunset Gardens<br />
                  Montego Bay, Jamaica
                </div>
                <div className="h-[1px] bg-gradient-to-r from-transparent via-[#f194b2] to-transparent my-4"></div>
                <p className="text-xs italic text-gray-600">
                  "Love is composed of a single soul inhabiting two bodies."
                </p>
              </div>
            </div>
            <button className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] font-medium mt-6">
              Close preview
            </button>
          </div>
        </div>
      )}

      {/* Guest Detail Modal */}
      {showGuestDetail && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowGuestDetail(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Sarah Johnson</h2>
                <button onClick={() => setShowGuestDetail(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-6">
              {/* Basic details */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Basic details</h3>
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 bg-[#FAFAFA] rounded-[20px]">
                    <div>
                      <div className="text-[11px] text-gray-600 mb-0.5">Name</div>
                      <p className="text-[14px] font-medium text-gray-800">Sarah Johnson</p>
                    </div>
                    <Edit size={16} className="text-gray-400" />
                  </div>
                  <div className="flex items-center justify-between p-3 bg-[#FAFAFA] rounded-[20px]">
                    <div>
                      <div className="text-[11px] text-gray-600 mb-0.5">Email</div>
                      <p className="text-[14px] font-medium text-gray-800">sarah@email.com</p>
                    </div>
                    <Edit size={16} className="text-gray-400" />
                  </div>
                  <div className="flex items-center justify-between p-3 bg-[#FAFAFA] rounded-[20px]">
                    <div>
                      <div className="text-[11px] text-gray-600 mb-0.5">Phone</div>
                      <p className="text-[14px] font-medium text-gray-800">+1 (555) 123-4567</p>
                    </div>
                    <Edit size={16} className="text-gray-400" />
                  </div>
                  <div className="flex items-center justify-between p-3 bg-[#FAFAFA] rounded-[20px]">
                    <div>
                      <div className="text-[11px] text-gray-600 mb-0.5">Tag</div>
                      <div className="flex gap-2 mt-1">
                        <span className="px-3 py-1 bg-[#3A8B95] text-white text-[11px] rounded-full">Family</span>
                      </div>
                    </div>
                    <Edit size={16} className="text-gray-400" />
                  </div>
                </div>
              </div>

              {/* RSVP & plus ones */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">RSVP & plus ones</h3>
                <div className="space-y-3">
                  <div className="p-4 bg-white rounded-[20px] border border-gray-200">
                    <div className="flex items-center justify-between mb-3">
                      <div className="text-[13px] text-gray-700">RSVP Status</div>
                      <span className="px-3 py-1 bg-[#3A8B95] text-white text-[11px] rounded-full font-medium">Attending</span>
                    </div>
                    <div className="grid grid-cols-2 gap-3 text-[11px]">
                      <div>
                        <div className="text-gray-500 mb-1">Invite sent</div>
                        <div className="text-gray-800">March 15, 2026</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Opened</div>
                        <div className="text-gray-800">March 16, 2026</div>
                      </div>
                      <div>
                        <div className="text-gray-500 mb-1">Responded</div>
                        <div className="text-gray-800">March 18, 2026</div>
                      </div>
                    </div>
                  </div>
                  <div className="p-4 bg-white rounded-[20px] border border-gray-200">
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="text-[13px] font-medium text-gray-800">Plus one</div>
                        <div className="text-[12px] text-gray-600 mt-0.5">Alex Johnson</div>
                      </div>
                      <Check size={18} className="text-[#FF3E9B]" />
                    </div>
                  </div>
                </div>
              </div>

              {/* Meals */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Meals</h3>
                <div className="space-y-3">
                  <div className="p-4 bg-white rounded-[20px] border border-gray-200">
                    <div className="text-[11px] text-gray-600 mb-1">Dietary preference</div>
                    <div className="text-[14px] font-medium text-gray-800">Vegetarian</div>
                  </div>
                  <div className="p-4 bg-white rounded-[20px] border border-gray-200">
                    <div className="text-[11px] text-gray-600 mb-1">Selected meal</div>
                    <div className="text-[14px] font-medium text-gray-800">Garden Risotto with Seasonal Vegetables</div>
                  </div>
                  <div className="p-4 bg-white rounded-[20px] border border-gray-200">
                    <div className="text-[11px] text-gray-600 mb-1">Allergies & notes</div>
                    <div className="text-[14px] text-gray-800">None</div>
                  </div>
                </div>
              </div>

              {/* Travel & stay */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Travel & stay</h3>
                <div className="p-4 bg-white rounded-[20px] border border-gray-200 space-y-3">
                  <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                    <div className="text-[13px] text-gray-700">Travelling from out of town</div>
                    <Check size={18} className="text-[#FF3E9B]" />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <div className="text-[11px] text-gray-600 mb-1">Arrival</div>
                      <div className="text-[13px] font-medium text-gray-800">April 1, 2026</div>
                    </div>
                    <div>
                      <div className="text-[11px] text-gray-600 mb-1">Departure</div>
                      <div className="text-[13px] font-medium text-gray-800">April 4, 2026</div>
                    </div>
                  </div>
                  <div>
                    <div className="text-[11px] text-gray-600 mb-1">Airport</div>
                    <div className="text-[13px] font-medium text-gray-800">San Francisco Int'l (SFO)</div>
                  </div>
                  <div>
                    <div className="text-[11px] text-gray-600 mb-1">Accommodation</div>
                    <div className="text-[13px] font-medium text-gray-800">The Fairmont Heritage Place</div>
                  </div>
                  <div>
                    <div className="text-[11px] text-gray-600 mb-1">Transport needs</div>
                    <div className="text-[13px] text-gray-800">Hotel to Venue Shuttle - 3:00 PM</div>
                  </div>
                </div>
              </div>

              {/* Access & visibility */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Access & visibility</h3>
                <p className="text-[12px] text-gray-600 mb-3">Events and sections this guest can see on the wedding website</p>
                <div className="space-y-2">
                  {[
                    { label: 'Ceremony', visible: true },
                    { label: 'Reception', visible: true },
                    { label: 'Rehearsal Dinner', visible: false },
                    { label: 'Wedding Party Schedule', visible: false },
                    { label: 'Travel Details', visible: true },
                    { label: 'Registry', visible: true },
                    { label: 'Message Board', visible: true },
                  ].map((item) => (
                    <div key={item.label} className="flex items-center justify-between p-3 bg-gray-50 rounded-[20px]">
                      <span className="text-[13px] text-gray-800">{item.label}</span>
                      {item.visible ? (
                        <Check size={16} className="text-[#FF3E9B]" />
                      ) : (
                        <X size={16} className="text-gray-300" />
                      )}
                    </div>
                  ))}
                </div>
              </div>

              {/* Invite history */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Invite history</h3>
                <div className="space-y-2">
                  {[
                    { icon: Mail, text: 'Invitation sent via email', time: 'March 15, 2026', color: '#285301' },
                    { icon: Eye, text: 'Invitation link opened', time: 'March 16, 2026', color: '#d45d78' },
                    { icon: Check, text: 'RSVP confirmed', time: 'March 18, 2026', color: '#285301' },
                  ].map((item, index) => (
                    <div key={index} className="flex items-start gap-3 p-3 bg-gray-50 rounded-[20px]">
                      <div className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0" style={{ backgroundColor: `${item.color}15` }}>
                        <item.icon size={14} style={{ color: item.color }} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-[13px] text-gray-800">{item.text}</p>
                        <p className="text-[11px] text-gray-500 mt-0.5">{item.time}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Notes */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Notes</h3>
                <div className="p-4 bg-white rounded-[20px] border border-gray-200">
                  <textarea
                    className="w-full text-[13px] text-gray-800 outline-none resize-none"
                    rows={3}
                    placeholder="Add private notes about this guest..."
                    defaultValue="Sarah mentioned she's excited to bring her partner Alex. They're staying at the recommended hotel."
                  />
                </div>
              </div>

              {/* Action buttons */}
              <div className="space-y-3 pt-2">
                <button className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] font-medium flex items-center justify-center gap-2">
                  <Send size={18} />
                  Send invite link
                </button>
                <button className="w-full bg-[#FF3E9B] text-white py-3 rounded-[20px] font-medium flex items-center justify-center gap-2">
                  <Mail size={18} />
                  Send reminder
                </button>
                <div className="grid grid-cols-2 gap-3">
                  <button className="border border-gray-300 py-3 rounded-[20px] text-gray-700 font-medium">
                    Edit guest
                  </button>
                  <button className="border border-gray-300 py-3 rounded-[20px] text-gray-700 font-medium">
                    Mark manually
                  </button>
                </div>
                <button className="w-full border border-red-200 text-red-600 py-3 rounded-[20px] font-medium">
                  Remove guest
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Send Reminder Modal */}
      {showReminderModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowReminderModal(false)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Send RSVP reminder</h2>
              <button onClick={() => setShowReminderModal(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="space-y-4">
              <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                <div className="text-[13px] text-gray-700 mb-2">
                  This message will be sent to <span className="font-medium text-[#FF3E9B]">18 guests</span> who haven't responded yet
                </div>
                <div className="text-[11px] text-gray-600">
                  Last reminder sent: 5 days ago
                </div>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Subject</label>
                <input
                  type="text"
                  value={reminderSubject}
                  onChange={(e) => setReminderSubject(e.target.value)}
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Message</label>
                <textarea
                  value={reminderBody}
                  onChange={(e) => setReminderBody(e.target.value)}
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  rows={5}
                />
              </div>

              <div className="flex items-center gap-3 p-3 bg-white rounded-[20px] border border-gray-200">
                <input
                  type="checkbox"
                  id="include-rsvp-link"
                  checked={includeRsvpLink}
                  onChange={(e) => setIncludeRsvpLink(e.target.checked)}
                  className="w-4 h-4 rounded border-gray-300 text-[#FF3E9B]"
                />
                <label htmlFor="include-rsvp-link" className="text-[13px] text-gray-700">Include RSVP link</label>
              </div>

              <div className="flex gap-3 mt-6">
                <button
                  onClick={() => setShowReminderModal(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowReminderModal(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] flex items-center justify-center gap-2"
                  style={{ fontWeight: 500 }}
                >
                  <Send size={18} />
                  Send reminder
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Quick Action Modals */}
      {showQuickAction && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowQuickAction(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>
                {showQuickAction === 'calendar' && 'Add to Calendar'}
                {showQuickAction === 'maps' && 'Open in Maps'}
                {showQuickAction === 'schedule' && 'View Schedule'}
              </h2>
              <button onClick={() => setShowQuickAction(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            {showQuickAction === 'calendar' && (
              <div className="space-y-3">
                <p className="text-[13px] text-gray-600 mb-4">Choose your calendar app</p>
                {['Apple Calendar', 'Google Calendar', 'Outlook', 'Download .ics file'].map((option) => (
                  <button
                    key={option}
                    className="w-full p-4 bg-[#FAFAFA] rounded-[20px] text-left hover:bg-[#FF88BA]/30 transition-colors"
                  >
                    <div className="text-[14px] font-medium text-gray-800">{option}</div>
                  </button>
                ))}
              </div>
            )}

            {showQuickAction === 'maps' && (
              <div className="space-y-3">
                <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px] mb-4">
                  <div className="text-[14px] font-medium text-gray-800 mb-1">Sunset Gardens</div>
                  <div className="text-[12px] text-gray-600">123 Beach Road, Montego Bay, Jamaica</div>
                </div>
                {['Apple Maps', 'Google Maps', 'Waze'].map((option) => (
                  <button
                    key={option}
                    className="w-full p-4 bg-[#FAFAFA] rounded-[20px] text-left hover:bg-[#FF88BA]/30 transition-colors"
                  >
                    <div className="text-[14px] font-medium text-gray-800">{option}</div>
                  </button>
                ))}
              </div>
            )}

            {showQuickAction === 'schedule' && (
              <div className="space-y-3">
                <div className="space-y-2">
                  {[
                    { time: '4:00 PM', event: 'Ceremony', location: 'Sunset Gardens' },
                    { time: '5:30 PM', event: 'Cocktail Hour', location: 'Garden Terrace' },
                    { time: '7:00 PM', event: 'Reception', location: 'Main Ballroom' },
                    { time: '10:00 PM', event: 'After Party', location: 'Beach Club' },
                  ].map((item, idx) => (
                    <div key={idx} className="p-4 bg-[#FAFAFA] rounded-[20px]">
                      <div className="flex items-start gap-3">
                        <div className="text-[13px] font-medium text-[#FF3E9B] w-20 flex-shrink-0">{item.time}</div>
                        <div className="flex-1">
                          <div className="text-[14px] font-medium text-gray-800">{item.event}</div>
                          <div className="text-[12px] text-gray-600 mt-0.5">{item.location}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <button className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] font-medium mt-4">
                  Download schedule
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Visibility Settings Modal */}
      {showVisibilityModal && selectedEventForVisibility && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowVisibilityModal(false)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>
                Visibility settings
              </h2>
              <button onClick={() => setShowVisibilityModal(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="space-y-4">
              <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                <div className="text-[13px] font-medium text-gray-800 mb-1">
                  {selectedEventForVisibility.split('-').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}
                </div>
                <div className="text-[11px] text-gray-600">
                  Choose which guest groups can see this section
                </div>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Visible to</label>
                <div className="space-y-2">
                  {['All Guests', 'Wedding Party', 'Family', 'Travelling Guests'].map((group) => {
                    const isSelected = visibilityRules[selectedEventForVisibility]?.includes(group as VisibilityGroup);
                    return (
                      <button
                        key={group}
                        onClick={() => {
                          const currentRules = visibilityRules[selectedEventForVisibility] || [];
                          const newRules = isSelected
                            ? currentRules.filter(g => g !== group)
                            : [...currentRules, group as VisibilityGroup];
                          setVisibilityRules({
                            ...visibilityRules,
                            [selectedEventForVisibility]: newRules
                          });
                        }}
                        className={`w-full p-3 rounded-[20px] border-2 text-left transition-all ${
                          isSelected
                            ? 'border-[#3A8B95] bg-[#3A8B95]/5'
                            : 'border-gray-200 bg-white hover:border-gray-300'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-[13px] font-medium text-gray-800">{group}</span>
                          {isSelected && <Check size={16} className="text-[#FF3E9B]" />}
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>

              <button
                onClick={() => setShowVisibilityModal(false)}
                className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] font-medium mt-6"
              >
                Save changes
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Travel & Stay Modal */}
      {showTravelStayModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowTravelStayModal(false)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Edit Travel & Stay</h2>
              <button onClick={() => setShowTravelStayModal(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="space-y-6">
              {/* Location & Venue Context */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Location & Venue Context</h3>
                <div className="space-y-3">
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2">Wedding City</label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      value={travelStayData.weddingCity}
                      onChange={(e) => setTravelStayData({...travelStayData, weddingCity: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2">Venue Name</label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      value={travelStayData.venueName}
                      onChange={(e) => setTravelStayData({...travelStayData, venueName: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2">Venue Address</label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      value={travelStayData.venueAddress}
                      onChange={(e) => setTravelStayData({...travelStayData, venueAddress: e.target.value})}
                    />
                  </div>
                </div>
              </div>

              {/* Nearby Hotels */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Nearby Hotels</h3>

                <button
                  onClick={() => setShowHotelSearchMode(true)}
                  className="w-full mb-3 py-3 bg-[#FAFAFA] rounded-[20px] text-[13px] font-medium text-gray-700 flex items-center justify-center gap-2 hover:bg-[#FF88BA]/30 transition-colors"
                >
                  <Search size={16} />
                  Find hotels near venue
                </button>

                {showHotelSearchMode && (
                  <div className="mb-4 p-4 bg-gradient-to-br from-[#FAFAFA]/40 to-white rounded-[20px] border border-gray-100">
                    <div className="text-[13px] font-medium text-gray-800 mb-3">Suggested Hotels Near Venue</div>
                    <div className="space-y-2">
                      {[
                        { name: 'The Grand Palace Hotel', distance: '0.8 miles', price: '$$$' },
                        { name: 'Harbor View Inn', distance: '1.2 miles', price: '$$' },
                        { name: 'Seaside Boutique Hotel', distance: '1.5 miles', price: '$$$' },
                        { name: 'Downtown Marriott', distance: '2.1 miles', price: '$$' },
                      ].map((suggestion, idx) => (
                        <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[20px] border border-gray-200">
                          <div className="flex-1">
                            <div className="text-[12px] font-medium text-gray-800">{suggestion.name}</div>
                            <div className="text-[11px] text-gray-600 mt-0.5">{suggestion.distance} • {suggestion.price}</div>
                          </div>
                          <button
                            onClick={() => {
                              const newHotel: HotelData = {
                                id: Date.now().toString(),
                                name: suggestion.name,
                                address: '',
                                distance: suggestion.distance,
                                priceRange: suggestion.price,
                                bookingLink: '',
                                notes: '',
                                recommended: false,
                              };
                              setSavedHotels([...savedHotels, newHotel]);
                              setShowHotelSearchMode(false);
                            }}
                            className="px-3 py-1.5 bg-[#3A8B95] text-white rounded-[20px] text-[11px] font-medium"
                          >
                            Select
                          </button>
                        </div>
                      ))}
                    </div>
                    <button
                      onClick={() => setShowHotelSearchMode(false)}
                      className="w-full mt-3 py-2 text-[12px] text-gray-600 hover:text-gray-800"
                    >
                      Close search
                    </button>
                  </div>
                )}

                {/* Saved Hotels */}
                <div className="space-y-3">
                  {savedHotels.map((hotel) => (
                    <div key={hotel.id} className="p-4 bg-white rounded-[20px] border border-gray-200">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1">
                          <input
                            type="text"
                            placeholder="Hotel name"
                            className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px] mb-2"
                            value={hotel.name ?? ''}
                            onChange={(e) => {
                              const updated = savedHotels.map(h => h.id === hotel.id ? {...h, name: e.target.value} : h);
                              setSavedHotels(updated);
                            }}
                          />
                          <input
                            type="text"
                            placeholder="Address"
                            className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[12px]"
                            value={hotel.address ?? ''}
                            onChange={(e) => {
                              const updated = savedHotels.map(h => h.id === hotel.id ? {...h, address: e.target.value} : h);
                              setSavedHotels(updated);
                            }}
                          />
                        </div>
                        <button
                          onClick={() => setSavedHotels(savedHotels.filter(h => h.id !== hotel.id))}
                          className="ml-2 text-gray-400 hover:text-red-500"
                        >
                          <X size={18} />
                        </button>
                      </div>
                      <div className="grid grid-cols-2 gap-2 mb-2">
                        <input
                          type="text"
                          placeholder="Distance"
                          className="px-3 py-2 rounded-[20px] border border-gray-200 text-[12px]"
                          value={hotel.distance_km != null ? `${hotel.distance_km} km` : (hotel.distance ?? '')}
                          onChange={(e) => {
                            const updated = savedHotels.map(h => h.id === hotel.id ? {...h, distance: e.target.value} : h);
                            setSavedHotels(updated);
                          }}
                        />
                        <input
                          type="text"
                          placeholder="Price range"
                          className="px-3 py-2 rounded-[20px] border border-gray-200 text-[12px]"
                          value={hotel.price_per_night != null ? `$${hotel.price_per_night}/night` : (hotel.priceRange ?? '')}
                          onChange={(e) => {
                            const updated = savedHotels.map(h => h.id === hotel.id ? {...h, priceRange: e.target.value} : h);
                            setSavedHotels(updated);
                          }}
                        />
                      </div>
                      <input
                        type="text"
                        placeholder="Booking link"
                        className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[12px] mb-2"
                        value={hotel.booking_url ?? hotel.bookingLink ?? ''}
                        onChange={(e) => {
                          const updated = savedHotels.map(h => h.id === hotel.id ? {...h, booking_url: e.target.value, bookingLink: e.target.value} : h);
                          setSavedHotels(updated);
                        }}
                      />
                      <textarea
                        placeholder="Notes"
                        className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[12px] mb-2"
                        rows={2}
                        value={hotel.notes ?? ''}
                        onChange={(e) => {
                          const updated = savedHotels.map(h => h.id === hotel.id ? {...h, notes: e.target.value} : h);
                          setSavedHotels(updated);
                        }}
                      />
                      <div className="flex items-center gap-2">
                        <input
                          type="checkbox"
                          id={`rec-${hotel.id}`}
                          checked={hotel.recommended ?? false}
                          onChange={(e) => {
                            const updated = savedHotels.map(h => h.id === hotel.id ? {...h, recommended: e.target.checked} : h);
                            setSavedHotels(updated);
                          }}
                          className="w-4 h-4 rounded border-gray-300 text-[#FF3E9B]"
                        />
                        <label htmlFor={`rec-${hotel.id}`} className="text-[12px] text-gray-700">Mark as recommended</label>
                      </div>
                    </div>
                  ))}

                  <button
                    onClick={() => {
                      const newHotel: HotelData = {
                        id: Date.now().toString(),
                        name: '',
                        address: '',
                        distance: '',
                        priceRange: '',
                        bookingLink: '',
                        notes: '',
                        recommended: false,
                      };
                      setSavedHotels([...savedHotels, newHotel]);
                    }}
                    className="w-full py-3 border-2 border-dashed border-gray-300 rounded-[20px] text-[13px] text-gray-600 hover:border-[#3A8B95] hover:text-[#FF3E9B] transition-all"
                  >
                    + Add hotel manually
                  </button>
                </div>
              </div>

              {/* Flights & Travel Guidance */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Flights & Travel Guidance</h3>
                <div className="space-y-3">
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2">Nearest Airport</label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      value={travelStayData.nearestAirport}
                      onChange={(e) => setTravelStayData({...travelStayData, nearestAirport: e.target.value})}
                    />
                  </div>

                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA]/40 to-white rounded-[20px] border border-gray-100">
                    <div className="text-[13px] font-medium text-gray-800 mb-3">Popular Routes</div>
                    <div className="space-y-2">
                      {[
                        { from: 'New York (JFK)', airline: 'United', duration: '6h 15m', price: 'from $380' },
                        { from: 'Los Angeles (LAX)', airline: 'American', duration: '5h 30m', price: 'from $420' },
                        { from: 'Chicago (ORD)', airline: 'Delta', duration: '4h 45m', price: 'from $340' },
                      ].map((flight, idx) => (
                        <div key={idx} className="p-3 bg-white rounded-[20px] border border-gray-200">
                          <div className="flex items-start justify-between">
                            <div className="flex-1">
                              <div className="text-[12px] font-medium text-gray-800">{flight.from}</div>
                              <div className="text-[11px] text-gray-600 mt-0.5">
                                {flight.airline} • {flight.duration}
                              </div>
                            </div>
                            <div className="text-[11px] font-medium text-[#FF3E9B]">{flight.price}</div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="flex items-center gap-3 p-3 bg-white rounded-[20px] border border-gray-200">
                    <input
                      type="checkbox"
                      id="show-flights"
                      checked={travelStayData.showFlightSuggestions}
                      onChange={(e) => setTravelStayData({...travelStayData, showFlightSuggestions: e.target.checked})}
                      className="w-4 h-4 rounded border-gray-300 text-[#FF3E9B]"
                    />
                    <label htmlFor="show-flights" className="text-[13px] text-gray-700">Show flight suggestions to guests</label>
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2">Travel tips for guests</label>
                    <textarea
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      rows={4}
                      placeholder="Add helpful notes such as best arrival times, visa requirements, or recommended routes..."
                      value={travelStayData.travelTips}
                      onChange={(e) => setTravelStayData({...travelStayData, travelTips: e.target.value})}
                    />
                  </div>
                </div>
              </div>

              {/* Transport & Arrival */}
              <div>
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Transport & Arrival</h3>

                <div className="space-y-3 mb-3">
                  {transportGroups.map((transport) => (
                    <div key={transport.id} className="p-4 bg-white rounded-[20px] border border-gray-200">
                      <div className="flex items-start justify-between mb-3">
                        <input
                          type="text"
                          placeholder="Transport name"
                          className="flex-1 px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                          value={transport.name ?? ''}
                          onChange={(e) => {
                            const updated = transportGroups.map(t => t.id === transport.id ? {...t, name: e.target.value} : t);
                            setTransportGroups(updated);
                          }}
                        />
                        <button
                          onClick={() => setTransportGroups(transportGroups.filter(t => t.id !== transport.id))}
                          className="ml-2 text-gray-400 hover:text-red-500"
                        >
                          <X size={18} />
                        </button>
                      </div>
                      <div className="grid grid-cols-2 gap-2 mb-2">
                        <input
                          type="text"
                          placeholder="Pickup location"
                          className="px-3 py-2 rounded-[20px] border border-gray-200 text-[12px]"
                          value={transport.pickup_location ?? transport.pickupLocation ?? ''}
                          onChange={(e) => {
                            const updated = transportGroups.map(t => t.id === transport.id ? {...t, pickup_location: e.target.value, pickupLocation: e.target.value} : t);
                            setTransportGroups(updated);
                          }}
                        />
                        <input
                          type="text"
                          placeholder="Time"
                          className="px-3 py-2 rounded-[20px] border border-gray-200 text-[12px]"
                          value={transport.departure_time ?? transport.time ?? ''}
                          onChange={(e) => {
                            const updated = transportGroups.map(t => t.id === transport.id ? {...t, departure_time: e.target.value, time: e.target.value} : t);
                            setTransportGroups(updated);
                          }}
                        />
                      </div>
                      <textarea
                        placeholder="Notes"
                        className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[12px]"
                        rows={2}
                        value={transport.notes ?? ''}
                        onChange={(e) => {
                          const updated = transportGroups.map(t => t.id === transport.id ? {...t, notes: e.target.value} : t);
                          setTransportGroups(updated);
                        }}
                      />
                    </div>
                  ))}

                  <button
                    onClick={() => {
                      const newTransport: TransportGroup = {
                        id: Date.now().toString(),
                        name: '',
                        pickupLocation: '',
                        time: '',
                        notes: '',
                      };
                      setTransportGroups([...transportGroups, newTransport]);
                    }}
                    className="w-full py-3 border-2 border-dashed border-gray-300 rounded-[20px] text-[13px] text-gray-600 hover:border-[#3A8B95] hover:text-[#FF3E9B] transition-all"
                  >
                    + Add transport option
                  </button>
                </div>

                <div className="flex items-center gap-3 p-3 bg-white rounded-[20px] border border-gray-200">
                  <input
                    type="checkbox"
                    id="show-transport"
                    checked={travelStayData.showTransportOptions}
                    onChange={(e) => setTravelStayData({...travelStayData, showTransportOptions: e.target.checked})}
                    className="w-4 h-4 rounded border-gray-300 text-[#FF3E9B]"
                  />
                  <label htmlFor="show-transport" className="text-[13px] text-gray-700">Display transport options to guests</label>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowTravelStayModal(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowTravelStayModal(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px]"
                  style={{ fontWeight: 500 }}
                >
                  Save changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Hotel Details Modal */}
      {showHotelDetailsModal && selectedHotelForDetails && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setShowHotelDetailsModal(false)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            {(() => {
              const hotel = savedHotels.find(h => h.id === selectedHotelForDetails);
              if (!hotel) return null;

              return (
                <>
                  <div className="flex items-center justify-between mb-6">
                    <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>{hotel.name}</h2>
                    <button onClick={() => setShowHotelDetailsModal(false)} className="text-gray-400 hover:text-gray-600">
                      <X size={24} />
                    </button>
                  </div>

                  <div className="space-y-4">
                    {hotel.recommended && (
                      <div className="p-3 bg-[#3A8B95]/10 rounded-[20px] border border-[#3A8B95]/20">
                        <div className="text-[13px] font-medium text-[#FF3E9B]">Recommended by couple</div>
                      </div>
                    )}

                    <div>
                      <div className="text-[13px] text-gray-600 mb-1">Location</div>
                      <div className="text-[15px] text-gray-800">{hotel.address || hotel.distance_km != null ? `${hotel.distance_km} km from venue` : (hotel.distance ?? '')}</div>
                    </div>

                    <div>
                      <div className="text-[13px] text-gray-600 mb-1">Distance from venue</div>
                      <div className="text-[15px] text-gray-800">{hotel.distance_km != null ? `${hotel.distance_km} km` : (hotel.distance ?? '')}</div>
                    </div>

                    <div>
                      <div className="text-[13px] text-gray-600 mb-1">Price range</div>
                      <div className="text-[15px] text-gray-800">{hotel.price_per_night != null ? `$${hotel.price_per_night}/night` : (hotel.priceRange ?? '')}</div>
                    </div>

                    {hotel.notes && (
                      <div>
                        <div className="text-[13px] text-gray-600 mb-1">Notes</div>
                        <div className="text-[14px] text-gray-800">{hotel.notes}</div>
                      </div>
                    )}

                    {(hotel.booking_url || hotel.bookingLink) && (
                      <button
                        onClick={() => window.open(hotel.booking_url ?? hotel.bookingLink, '_blank')}
                        className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] font-medium"
                      >
                        Book now
                      </button>
                    )}

                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => setShowMapViewModal(true)}
                        className="py-3 bg-[#FAFAFA] rounded-[20px] text-[13px] font-medium text-gray-700"
                      >
                        View on map
                      </button>
                      <button
                        onClick={() => {
                          navigator.clipboard.writeText(`${hotel.name}\n${hotel.address || (hotel.distance_km != null ? `${hotel.distance_km} km` : hotel.distance ?? '')}`);
                        }}
                        className="py-3 bg-[#FAFAFA] rounded-[20px] text-[13px] font-medium text-gray-700"
                      >
                        Copy details
                      </button>
                    </div>
                  </div>
                </>
              );
            })()}
          </div>
        </div>
      )}

      {/* Map View Modal */}
      {showMapViewModal && (
        <div className="fixed inset-0 bg-black/50 z-[70] flex items-end" onClick={() => setShowMapViewModal(false)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Location Map</h2>
              <button onClick={() => setShowMapViewModal(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="space-y-4">
              {/* Simulated Map */}
              <div className="relative h-64 bg-gradient-to-br from-[#FAFAFA] to-[#FF88BA]/20 rounded-[20px] border border-gray-200 overflow-hidden">
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="text-center">
                    <MapPin className="text-[#FF3E9B] mx-auto mb-2" size={48} />
                    <div className="text-[14px] font-medium text-gray-800">{travelStayData.venueName}</div>
                    <div className="text-[12px] text-gray-600 mt-1">Interactive map view</div>
                  </div>
                </div>
              </div>

              <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                <div className="text-[14px] font-medium text-gray-800 mb-2">{travelStayData.venueName}</div>
                <div className="text-[13px] text-gray-600">{travelStayData.venueAddress}</div>
              </div>

              <div className="grid grid-cols-3 gap-2">
                <button className="py-3 bg-white border border-gray-200 rounded-[20px] text-[12px] font-medium text-gray-700">
                  Apple Maps
                </button>
                <button className="py-3 bg-white border border-gray-200 rounded-[20px] text-[12px] font-medium text-gray-700">
                  Google Maps
                </button>
                <button className="py-3 bg-white border border-gray-200 rounded-[20px] text-[12px] font-medium text-gray-700">
                  Waze
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Add Guest Modal */}
      {showAddGuestModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowAddGuestModal(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Add a new guest</h2>
                <button onClick={() => setShowAddGuestModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
              <p className="text-[13px] text-gray-600 mt-2">
                Add guest details now so you can manage RSVPs, seating, travel, and communication later without the back-and-forth.
              </p>
            </div>

            <div className="p-6">
              <p className="text-[13px] text-gray-600 mb-5" style={{ lineHeight: 1.6 }}>
                Invite guests with a personalized link so they can fill in their own details, or add someone manually if you prefer to manage their RSVP yourself.
              </p>

              {/* Toggle between Quick Invite and Manual Add */}
              <div className="flex gap-2 mb-6 p-1 bg-gray-100 rounded-[20px]">
                <button
                  onClick={() => setAddGuestMode('quick')}
                  className={`flex-1 py-3 rounded-[20px] text-[14px] font-medium transition-all ${
                    addGuestMode === 'quick'
                      ? 'bg-white text-[#FF3E9B] shadow-sm'
                      : 'bg-transparent text-gray-600'
                  }`}
                >
                  Quick Invite
                </button>
                <button
                  onClick={() => setAddGuestMode('manual')}
                  className={`flex-1 py-3 rounded-[20px] text-[14px] font-medium transition-all ${
                    addGuestMode === 'manual'
                      ? 'bg-white text-[#FF3E9B] shadow-sm'
                      : 'bg-transparent text-gray-600'
                  }`}
                >
                  Manual Add
                </button>
              </div>

              {addGuestMode === 'quick' ? (
                <div className="space-y-4">
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Guest Name <span className="text-[#FF3E9B]">*</span></label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      placeholder="Enter guest name"
                    />
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Email Address</label>
                    <input
                      type="email"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      placeholder="email@example.com"
                    />
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Phone Number</label>
                    <input
                      type="tel"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      placeholder="+1 (555) 123-4567"
                    />
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Preferred Send Method</label>
                    <div className="flex gap-2">
                      <button className="flex-1 py-3 border-2 border-[#3A8B95] bg-[#3A8B95] text-white rounded-[20px] text-[13px] font-medium">
                        Email
                      </button>
                      <button className="flex-1 py-3 border-2 border-gray-200 text-gray-700 rounded-[20px] text-[13px] font-medium hover:border-[#3A8B95]">
                        SMS
                      </button>
                      <button className="flex-1 py-3 border-2 border-gray-200 text-gray-700 rounded-[20px] text-[13px] font-medium hover:border-[#3A8B95]">
                        WhatsApp
                      </button>
                    </div>
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Guest Tag</label>
                    <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                      <option>Select a tag</option>
                      <option>Family</option>
                      <option>Friends</option>
                      <option>Colleagues</option>
                      <option>Wedding Party</option>
                      <option>VIP</option>
                      <option>Custom</option>
                    </select>
                  </div>

                  <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                    <p className="text-[12px] text-gray-700" style={{ lineHeight: 1.6 }}>
                      <strong>Best for most guests.</strong> They will receive a personalized link to RSVP, add travel details, meal preferences, and view wedding information.
                    </p>
                  </div>

                  <div className="flex gap-3 pt-2">
                    <button
                      onClick={() => setShowAddGuestModal(false)}
                      className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                      style={{ fontWeight: 500 }}
                    >
                      Save without sending
                    </button>
                    <button
                      onClick={() => setShowAddGuestModal(false)}
                      className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px] flex items-center justify-center gap-2"
                      style={{ fontWeight: 500 }}
                    >
                      <Send size={18} />
                      Send invite link
                    </button>
                  </div>
                </div>
              ) : (
                <div className="space-y-4">
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Name <span className="text-[#FF3E9B]">*</span></label>
                    <input
                      type="text"
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      placeholder="Enter guest name"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Email</label>
                      <input
                        type="email"
                        className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                        placeholder="email@example.com"
                      />
                    </div>
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Phone</label>
                      <input
                        type="tel"
                        className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                        placeholder="+1 555 123 4567"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>RSVP Status</label>
                      <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                        <option>Pending</option>
                        <option>Attending</option>
                        <option>Declined</option>
                      </select>
                    </div>
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Plus One Count</label>
                      <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                        <option>0</option>
                        <option>1</option>
                        <option>2</option>
                      </select>
                    </div>
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Meal Preference</label>
                    <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                      <option>Standard</option>
                      <option>Vegetarian</option>
                      <option>Vegan</option>
                      <option>Gluten-free</option>
                      <option>Pescatarian</option>
                      <option>Other</option>
                    </select>
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Tag</label>
                    <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                      <option>Select a tag</option>
                      <option>Family</option>
                      <option>Friends</option>
                      <option>Colleagues</option>
                      <option>Wedding Party</option>
                    </select>
                  </div>

                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Notes</label>
                    <textarea
                      className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none"
                      rows={3}
                      placeholder="Add any private notes about this guest..."
                    />
                  </div>

                  <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px] space-y-3">
                    <div className="flex items-center justify-between">
                      <label className="text-[13px] text-gray-700" style={{ fontWeight: 500 }}>Travelling?</label>
                      <input type="checkbox" className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                    </div>
                    <div className="flex items-center justify-between">
                      <label className="text-[13px] text-gray-700" style={{ fontWeight: 500 }}>Accommodation known?</label>
                      <input type="checkbox" className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Arrival Date</label>
                      <input
                        type="date"
                        className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      />
                    </div>
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Departure Date</label>
                      <input
                        type="date"
                        className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                      />
                    </div>
                  </div>

                  <div className="p-3 bg-blue-50 border border-blue-200 rounded-[20px]">
                    <p className="text-[11px] text-blue-800" style={{ lineHeight: 1.5 }}>
                      💡 <strong>Tip:</strong> You can still send this guest a personalized link later if you want them to complete their own details.
                    </p>
                  </div>

                  <div className="flex gap-3 pt-2">
                    <button
                      onClick={() => setShowAddGuestModal(false)}
                      className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                      style={{ fontWeight: 500 }}
                    >
                      Cancel
                    </button>
                    <button
                      onClick={() => setShowAddGuestModal(false)}
                      className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                      style={{ fontWeight: 500 }}
                    >
                      Save guest
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Edit Hotels Modal */}
      {showEditHotels && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowEditHotels(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Edit Hotel Recommendations</h2>
                <button onClick={() => setShowEditHotels(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Wedding City</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="San Francisco"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Venue Name</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="Palace of Fine Arts"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Venue Address</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="3301 Lyon Street, San Francisco, CA 94123"
                />
              </div>

              <button className="w-full bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px] font-medium">
                Find hotels near venue
              </button>

              <div className="pt-4 border-t border-gray-200">
                <h3 className="text-[15px] font-medium text-gray-800 mb-3">Selected Hotels</h3>
                <div className="space-y-3">
                  {savedHotels.map((hotel) => (
                    <div key={hotel.id} className="p-4 bg-gradient-to-r from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                      <div className="flex items-start justify-between mb-2">
                        <div className="flex-1">
                          <div className="text-[14px] font-medium text-gray-800">{hotel.name}</div>
                          <div className="text-[11px] text-gray-600 mt-0.5">{hotel.address ?? ''}</div>
                        </div>
                        {hotel.recommended && (
                          <span className="px-2 py-1 bg-[#3A8B95] text-white text-[10px] rounded-full font-medium">Recommended</span>
                        )}
                      </div>
                      <div className="flex items-center gap-3 text-[11px] text-gray-600">
                        <span>{hotel.distance_km != null ? `${hotel.distance_km} km` : (hotel.distance ?? '')}</span>
                        <span>•</span>
                        <span>{hotel.price_per_night != null ? `$${hotel.price_per_night}/night` : (hotel.priceRange ?? '')}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowEditHotels(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowEditHotels(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Save changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Edit Transport Modal */}
      {showEditTransport && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowEditTransport(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Edit Transport Details</h2>
                <button onClick={() => setShowEditTransport(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              {transportGroups.map((group) => (
                <div key={group.id} className="p-4 bg-gradient-to-r from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                  <div className="space-y-3">
                    <div>
                      <label className="text-[11px] text-gray-600 block mb-1">Shuttle Name</label>
                      <input
                        type="text"
                        className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                        defaultValue={group.name ?? ''}
                      />
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-[11px] text-gray-600 block mb-1">Pickup Location</label>
                        <input
                          type="text"
                          className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                          defaultValue={group.pickup_location ?? group.pickupLocation ?? ''}
                        />
                      </div>
                      <div>
                        <label className="text-[11px] text-gray-600 block mb-1">Time</label>
                        <input
                          type="text"
                          className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                          defaultValue={group.departure_time ?? group.time ?? ''}
                        />
                      </div>
                    </div>
                    <div>
                      <label className="text-[11px] text-gray-600 block mb-1">Notes</label>
                      <textarea
                        className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px] resize-none"
                        rows={2}
                        defaultValue={group.notes ?? ''}
                      />
                    </div>
                  </div>
                </div>
              ))}

              <button className="w-full border-2 border-dashed border-gray-300 text-gray-600 py-3 rounded-[20px] text-[14px] font-medium hover:border-[#3A8B95] hover:text-[#FF3E9B] transition-colors">
                + Add transport option
              </button>

              <div className="p-4 bg-gray-50 rounded-[20px] border border-gray-200 space-y-3">
                <h4 className="text-[13px] font-medium text-gray-800">Airport Transfer</h4>
                <div>
                  <label className="text-[11px] text-gray-600 block mb-1">Nearest Airport</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                    defaultValue="San Francisco International Airport (SFO)"
                  />
                </div>
                <div>
                  <label className="text-[11px] text-gray-600 block mb-1">Travel Note</label>
                  <textarea
                    className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px] resize-none"
                    rows={2}
                    placeholder="Add guidance for airport arrivals..."
                  />
                </div>
              </div>

              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-[20px]">
                <label className="text-[13px] text-gray-700">Display transport options to guests</label>
                <input type="checkbox" defaultChecked className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowEditTransport(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowEditTransport(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Save changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Guest Logistics Detail Modal */}
      {showGuestLogisticsDetail && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowGuestLogisticsDetail(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Guest Logistics</h2>
                <button onClick={() => setShowGuestLogisticsDetail(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <div className="p-4 bg-blue-50 border border-blue-200 rounded-[20px]">
                <p className="text-[12px] text-blue-800" style={{ lineHeight: 1.5 }}>
                  ℹ️ Guests can update these details themselves after booking through their personalized link.
                </p>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Arrival Airport</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>San Francisco International (SFO)</option>
                  <option>Oakland International (OAK)</option>
                  <option>San Jose International (SJC)</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Arrival Date</label>
                  <input
                    type="date"
                    className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  />
                </div>
                <div>
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Departure Date</label>
                  <input
                    type="date"
                    className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  />
                </div>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Hotel</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Select hotel</option>
                  <option>The Fairmont Heritage Place</option>
                  <option>Other</option>
                </select>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Booking Status</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Confirmed</option>
                  <option>Pending</option>
                  <option>Not booked</option>
                </select>
              </div>

              <div className="flex items-center justify-between p-4 bg-gray-50 rounded-[20px]">
                <label className="text-[13px] text-gray-700" style={{ fontWeight: 500 }}>Shuttle needed?</label>
                <input type="checkbox" className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Travel Notes</label>
                <textarea
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none"
                  rows={3}
                  placeholder="Add any notes about this guest's travel plans..."
                />
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowGuestLogisticsDetail(false)}
                  className="flex-1 bg-[#FF3E9B] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Send travel reminder
                </button>
                <button
                  onClick={() => setShowGuestLogisticsDetail(false)}
                  className="flex-1 bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Save
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Edit Invite Content Modal */}
      {showEditInviteContent && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowEditInviteContent(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Edit Invitation Content</h2>
                <button onClick={() => setShowEditInviteContent(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Couple Names</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="Olivia & Aaron"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Wedding Date</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="June 15, 2026"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Venue Name</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="Sunset Gardens"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Location</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  defaultValue="Montego Bay, Jamaica"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Quote (optional)</label>
                <textarea
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none"
                  rows={2}
                  defaultValue="Love is friendship set to music"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Message to Guests</label>
                <textarea
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none"
                  rows={4}
                  defaultValue="request the honor of your presence at their wedding"
                />
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowEditInviteContent(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowEditInviteContent(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Save changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Change Theme Modal */}
      {showChangeTheme && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowChangeTheme(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Change Theme</h2>
                <button onClick={() => setShowChangeTheme(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <p className="text-[13px] text-gray-600" style={{ lineHeight: 1.6 }}>
                Choose a theme that matches your wedding style and personality.
              </p>

              <div className="space-y-3">
                {[
                  { name: 'Classic Elegant', colors: ['#285301', '#d45d78', '#f8edeb'], desc: 'Timeless and sophisticated' },
                  { name: 'Modern Minimal', colors: ['#1a1a1a', '#f5f5f5', '#e0e0e0'], desc: 'Clean and contemporary' },
                  { name: 'Tropical Destination', colors: ['#00695c', '#ff6f00', '#fff3e0'], desc: 'Vibrant and fresh' },
                  { name: 'Editorial Luxury', colors: ['#2c2c2c', '#c9b037', '#f4f4f2'], desc: 'Bold and refined' },
                ].map((theme, idx) => (
                  <button
                    key={idx}
                    className="w-full p-4 bg-white rounded-[20px] border-2 border-gray-200 hover:border-[#3A8B95] transition-all text-left"
                  >
                    <div className="flex items-start gap-3">
                      <div className="flex gap-1.5 pt-1">
                        {theme.colors.map((color, i) => (
                          <div
                            key={i}
                            className="w-6 h-6 rounded-full border border-gray-200"
                            style={{ backgroundColor: color }}
                          />
                        ))}
                      </div>
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">{theme.name}</div>
                        <div className="text-[12px] text-gray-600 mt-0.5">{theme.desc}</div>
                      </div>
                      {idx === 0 && (
                        <Check size={20} className="text-[#FF3E9B]" />
                      )}
                    </div>
                  </button>
                ))}
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowChangeTheme(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowChangeTheme(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Apply theme
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Compose Message Modal */}
      {showComposeMessage && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowComposeMessage(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Compose Message</h2>
                <button onClick={() => setShowComposeMessage(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Send to</label>
                <select
                  value={messageRecipient}
                  onChange={(e) => setMessageRecipient(e.target.value)}
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                >
                  <option>All guests (120)</option>
                  <option>Pending RSVP (18)</option>
                  <option>Travelling guests (32)</option>
                  <option>Wedding party (8)</option>
                  <option>Family (24)</option>
                  <option>Friends (64)</option>
                </select>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Delivery method</label>
                <div className="flex gap-2">
                  <button
                    onClick={() => setMessageDeliveryMethod('email')}
                    className={`flex-1 py-2.5 border-2 rounded-[20px] text-[13px] font-medium ${
                      messageDeliveryMethod === 'email'
                        ? 'border-[#3A8B95] bg-[#3A8B95] text-white'
                        : 'border-gray-200 text-gray-700 hover:border-[#3A8B95]'
                    }`}
                  >
                    Email
                  </button>
                  <button
                    onClick={() => setMessageDeliveryMethod('sms')}
                    className={`flex-1 py-2.5 border-2 rounded-[20px] text-[13px] font-medium ${
                      messageDeliveryMethod === 'sms'
                        ? 'border-[#3A8B95] bg-[#3A8B95] text-white'
                        : 'border-gray-200 text-gray-700 hover:border-[#3A8B95]'
                    }`}
                  >
                    SMS
                  </button>
                  <button
                    onClick={() => setMessageDeliveryMethod('whatsapp')}
                    className={`flex-1 py-2.5 border-2 rounded-[20px] text-[13px] font-medium ${
                      messageDeliveryMethod === 'whatsapp'
                        ? 'border-[#3A8B95] bg-[#3A8B95] text-white'
                        : 'border-gray-200 text-gray-700 hover:border-[#3A8B95]'
                    }`}
                  >
                    WhatsApp
                  </button>
                </div>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Subject</label>
                <input
                  type="text"
                  value={messageSubject}
                  onChange={(e) => setMessageSubject(e.target.value)}
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  placeholder="Enter subject..."
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Message</label>
                <textarea
                  value={messageBody}
                  onChange={(e) => setMessageBody(e.target.value)}
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none"
                  rows={6}
                  placeholder="Write your message..."
                />
              </div>

              <div className="flex items-center gap-3 p-3 bg-white rounded-[20px] border border-gray-200">
                <input
                  type="checkbox"
                  id="include-link"
                  checked={includeGuestLink}
                  onChange={(e) => setIncludeGuestLink(e.target.checked)}
                  className="w-4 h-4 rounded border-gray-300 text-[#FF3E9B]"
                />
                <label htmlFor="include-link" className="text-[13px] text-gray-700">Include guest link</label>
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowComposeMessage(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Save draft
                </button>
                <button
                  onClick={sendMessage}
                  disabled={messageSending}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px] flex items-center justify-center gap-2 disabled:opacity-60"
                  style={{ fontWeight: 500 }}
                >
                  <Send size={18} />
                  {messageSending ? 'Sending…' : 'Send message'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Bulk Actions Panel */}
      {showBulkActionsPanel && (
        <div className="fixed bottom-0 left-0 right-0 bg-white border-t-2 border-[#3A8B95] p-4 z-50 shadow-xl">
          <div className="max-w-screen-xl mx-auto">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setShowBulkActionsPanel(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X size={20} />
                </button>
                <span className="text-[14px] font-medium text-gray-800">3 guests selected</span>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setShowComposeMessage(true)}
                  className="px-4 py-2 bg-[#FAFAFA] rounded-[20px] text-[13px] font-medium text-gray-700 hover:bg-[#FF3E9B] hover:text-white transition-colors"
                >
                  Send message
                </button>
                <button
                  onClick={() => setShowEditHotels(true)}
                  className="px-4 py-2 bg-[#FAFAFA] rounded-[20px] text-[13px] font-medium text-gray-700 hover:bg-[#FF3E9B] hover:text-white transition-colors"
                >
                  Assign hotel
                </button>
                <button
                  onClick={() => setShowReminderModal(true)}
                  className="px-4 py-2 bg-[#3A8B95] text-white rounded-[20px] text-[13px] font-medium hover:bg-[#1f4001] transition-colors"
                >
                  Request info
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Import Guests Modal - PER SPEC */}
      {showImportGuestsModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowImportGuestsModal(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Import Guests</h2>
                <button onClick={() => setShowImportGuestsModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <p className="text-[13px] text-gray-600" style={{ lineHeight: 1.6 }}>
                Import your guest list from a CSV file or paste guest details directly. We'll help you organize everything.
              </p>

              <div className="space-y-3">
                <div className="p-5 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border-2 border-dashed border-gray-300 hover:border-[#3A8B95] transition-colors cursor-pointer text-center">
                  <div className="w-12 h-12 rounded-full bg-[#3A8B95]/10 flex items-center justify-center mx-auto mb-3">
                    <Plus size={24} className="text-[#FF3E9B]" />
                  </div>
                  <p className="text-[14px] font-medium text-gray-800 mb-1">Upload CSV File</p>
                  <p className="text-[12px] text-gray-600">Click to browse or drag and drop your file here</p>
                </div>

                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-gray-200"></div>
                  </div>
                  <div className="relative flex justify-center">
                    <span className="px-3 bg-white text-[13px] text-gray-500">or</span>
                  </div>
                </div>

                <div>
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Paste guest details</label>
                  <textarea
                    className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none font-mono"
                    rows={8}
                    placeholder="Paste guest data here (Name, Email, Phone)&#10;Example:&#10;John Smith, john@email.com, +1 555 123 4567&#10;Jane Doe, jane@email.com, +1 555 987 6543"
                  />
                </div>

                <div className="p-3 bg-blue-50 border border-blue-200 rounded-[20px]">
                  <p className="text-[11px] text-blue-800" style={{ lineHeight: 1.5 }}>
                    💡 <strong>Tip:</strong> Your CSV should include columns for Name, Email, and Phone. Additional columns like Group, Meal Preference, and Notes are also supported.
                  </p>
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowImportGuestsModal(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowImportGuestsModal(false)}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Import guests
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Send Invitations Modal - PER SPEC */}
      {showSendInvitationsModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setShowSendInvitationsModal(false)}>
          <div className="bg-white w-full rounded-t-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h2 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>Send invitations</h2>
                <button onClick={() => setShowSendInvitationsModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Recipients</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>All guests (120)</option>
                  <option>Pending only (34)</option>
                  <option>Custom selection</option>
                </select>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Subject</label>
                <input
                  type="text"
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]"
                  placeholder="You're invited to our wedding"
                />
              </div>

              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Message body</label>
                <textarea
                  className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] resize-none"
                  rows={6}
                  placeholder="Write your invitation message..."
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-[#FAFAFA]/40 rounded-[20px]">
                  <label className="text-[13px] text-gray-700">Include RSVP link</label>
                  <input type="checkbox" defaultChecked className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                </div>
                <div className="flex items-center justify-between p-3 bg-[#FAFAFA]/40 rounded-[20px]">
                  <label className="text-[13px] text-gray-700">Include guest page link</label>
                  <input type="checkbox" defaultChecked className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowSendInvitationsModal(false)}
                  className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Cancel
                </button>
                <button
                  onClick={() => setShowSendInvitationsModal(false)}
                  className="px-5 py-3 bg-[#FAFAFA] text-gray-800 rounded-[20px] text-[14px] font-medium hover:bg-[#FF88BA]/30 transition-colors"
                >
                  Schedule send
                </button>
                <button
                  onClick={publishInvitation}
                  disabled={invitationSending}
                  className="flex-[2] bg-[#3A8B95] text-white py-3 rounded-[20px] text-[14px] flex items-center justify-center gap-2 disabled:opacity-60"
                  style={{ fontWeight: 500 }}
                >
                  <Send size={18} />
                  {invitationSending ? 'Sending…' : 'Send now'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ADVANCED SUPPORTING PAGE - GUEST INSIGHTS */}
      {showGuestInsights && (
        <div className="fixed inset-0 bg-[#fefdfb] z-[60] overflow-y-auto">
          <div className="min-h-screen">
            {/* Header */}
            <div className="bg-white border-b border-gray-100 px-4 pt-6 pb-4 sticky top-0 z-10">
              <div className="flex items-center justify-between mb-3">
                <button
                  onClick={() => setShowGuestInsights(false)}
                  className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors"
                >
                  <X size={20} className="text-gray-600" />
                </button>
                <h1 className="text-2xl text-[#FF3E9B] flex-1 text-center" style={{ fontFamily: 'Playfair Display, serif' }}>Guest Insights</h1>
                <div className="w-9"></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center">Understanding your guest composition and patterns</p>
            </div>

            <div className="px-4 py-6 space-y-5">
              {/* Summary insights header */}
              <div className="bg-gradient-to-br from-[#285301] to-[#1f4201] rounded-2xl p-6 text-white">
                <h2 className="text-[18px] font-medium mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>Key Insights</h2>
                <div className="space-y-3">
                  <div className="flex items-start gap-3">
                    <div className="w-1.5 h-1.5 bg-white rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-[14px]" style={{ lineHeight: 1.6 }}>62% of your guests are travelling from outside the area</p>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-1.5 h-1.5 bg-white rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-[14px]" style={{ lineHeight: 1.6 }}>18 guests are travelling internationally</p>
                  </div>
                  <div className="flex items-start gap-3">
                    <div className="w-1.5 h-1.5 bg-white rounded-full mt-2 flex-shrink-0"></div>
                    <p className="text-[14px]" style={{ lineHeight: 1.6 }}>Most guests respond within 48 hours of receiving their invitation</p>
                  </div>
                </div>
              </div>

              {/* Composition Analysis */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-4">Guest Composition</h3>

                {/* Relationship breakdown */}
                <div className="mb-5">
                  <p className="text-[13px] text-gray-600 mb-3">By Relationship</p>
                  <div className="space-y-3">
                    {[
                      { label: 'Family', count: 24, total: 120, color: '#285301' },
                      { label: 'Friends', count: 52, total: 120, color: '#d45d78' },
                      { label: 'Colleagues', count: 32, total: 120, color: '#f194b2' },
                      { label: 'Extended Family', count: 12, total: 120, color: '#c4a574' },
                    ].map((item) => (
                      <div key={item.label}>
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-[13px] text-gray-700">{item.label}</span>
                          <span className="text-[13px] font-medium text-gray-800">{item.count} ({Math.round((item.count / item.total) * 100)}%)</span>
                        </div>
                        <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full"
                            style={{
                              width: `${(item.count / item.total) * 100}%`,
                              backgroundColor: item.color
                            }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Travel status breakdown */}
                <div>
                  <p className="text-[13px] text-gray-600 mb-3">By Travel Status</p>
                  <div className="space-y-3">
                    {[
                      { label: 'Local', count: 46, total: 120, color: '#285301' },
                      { label: 'Domestic Travel', count: 56, total: 120, color: '#d45d78' },
                      { label: 'International', count: 18, total: 120, color: '#f194b2' },
                    ].map((item) => (
                      <div key={item.label}>
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-[13px] text-gray-700">{item.label}</span>
                          <span className="text-[13px] font-medium text-gray-800">{item.count} ({Math.round((item.count / item.total) * 100)}%)</span>
                        </div>
                        <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full"
                            style={{
                              width: `${(item.count / item.total) * 100}%`,
                              backgroundColor: item.color
                            }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Travel Burden Analysis */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Travel Burden Analysis</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Understanding the effort required for guests to attend helps you provide better support.
                </p>

                <div className="space-y-3">
                  <button
                    onClick={() => setActiveTab('logistics')}
                    className="w-full p-4 bg-[#FAFAFA]/40 rounded-[20px] text-left hover:bg-[#FAFAFA] transition-colors"
                  >
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">High burden</div>
                        <div className="text-[12px] text-gray-600 mt-1">International flights, multiple connections, or same-day arrival</div>
                      </div>
                      <span className="text-[16px] font-medium text-[#FF3E9B] ml-3">18</span>
                    </div>
                  </button>

                  <button
                    onClick={() => setActiveTab('logistics')}
                    className="w-full p-4 bg-[#FAFAFA]/20 rounded-[20px] text-left hover:bg-[#FAFAFA]/40 transition-colors"
                  >
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">Medium burden</div>
                        <div className="text-[12px] text-gray-600 mt-1">Domestic flights or 3+ hour drive</div>
                      </div>
                      <span className="text-[16px] font-medium text-gray-700 ml-3">56</span>
                    </div>
                  </button>

                  <div className="p-4 bg-gray-50 rounded-[20px]">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">Low burden</div>
                        <div className="text-[12px] text-gray-600 mt-1">Local or short drive</div>
                      </div>
                      <span className="text-[16px] font-medium text-gray-700 ml-3">46</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Social Clusters */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Social Clusters</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Natural groups that may want to sit together or coordinate travel.
                </p>

                <div className="space-y-2.5">
                  {[
                    { name: 'College Friends', count: 18, note: 'Likely to coordinate travel together' },
                    { name: 'Work Team', count: 12, note: 'May share transportation' },
                    { name: "Bride's Extended Family", count: 16, note: 'Mostly travelling from same city' },
                    { name: 'Wedding Party Core', count: 8, note: 'Need early arrival coordination' },
                    { name: 'Neighborhood Friends', count: 14, note: 'All local' },
                  ].map((cluster) => (
                    <div key={cluster.name} className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                      <div className="flex items-start justify-between mb-1">
                        <div className="text-[14px] font-medium text-gray-800">{cluster.name}</div>
                        <span className="text-[13px] font-medium text-[#FF3E9B] ml-3">{cluster.count}</span>
                      </div>
                      <div className="text-[12px] text-gray-600">{cluster.note}</div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Behavior Patterns */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Behavior Patterns</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Understanding response patterns helps you plan follow-ups.
                </p>

                <div className="grid grid-cols-3 gap-3 mb-4">
                  <div className="p-4 bg-gradient-to-br from-[#285301] to-[#1f4201] rounded-[20px] text-white text-center">
                    <div className="text-[24px] font-medium mb-1">64</div>
                    <div className="text-[11px] opacity-90">Early responders</div>
                    <div className="text-[10px] opacity-75 mt-1">&lt; 48 hours</div>
                  </div>
                  <div className="p-4 bg-gradient-to-br from-[#FF3E9B] to-[#c14d68] rounded-[20px] text-white text-center">
                    <div className="text-[24px] font-medium mb-1">22</div>
                    <div className="text-[11px] opacity-90">Late responders</div>
                    <div className="text-[10px] opacity-75 mt-1">1+ weeks</div>
                  </div>
                  <div className="p-4 bg-gradient-to-br from-gray-400 to-gray-500 rounded-[20px] text-white text-center">
                    <div className="text-[24px] font-medium mb-1">34</div>
                    <div className="text-[11px] opacity-90">Non-responders</div>
                    <div className="text-[10px] opacity-75 mt-1">No response yet</div>
                  </div>
                </div>

                <button
                  onClick={() => {
                    setShowGuestInsights(false);
                    setActiveTab('messages');
                  }}
                  className="w-full py-3 bg-[#FF3E9B] text-white rounded-[20px] text-[14px] font-medium hover:bg-[#c14d68] transition-colors"
                >
                  Send reminder to non-responders
                </button>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={() => setShowGuestInsights(false)}
                  className="flex-1 py-3 border border-gray-300 rounded-[20px] text-gray-700 text-[14px] font-medium hover:bg-gray-50 transition-colors"
                >
                  Close
                </button>
                <button
                  onClick={() => {
                    setShowGuestInsights(false);
                    setActiveTab('guests');
                  }}
                  className="flex-1 py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] font-medium hover:bg-[#1f4201] transition-colors"
                >
                  View full guest list
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ADVANCED SUPPORTING PAGE - GUEST JOURNEY */}
      {showGuestJourney && (
        <div className="fixed inset-0 bg-[#fefdfb] z-[60] overflow-y-auto">
          <div className="min-h-screen">
            {/* Header */}
            <div className="bg-white border-b border-gray-100 px-4 pt-6 pb-4 sticky top-0 z-10">
              <div className="flex items-center justify-between mb-3">
                <button
                  onClick={() => setShowGuestJourney(false)}
                  className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors"
                >
                  <X size={20} className="text-gray-600" />
                </button>
                <h1 className="text-2xl text-[#FF3E9B] flex-1 text-center" style={{ fontFamily: 'Playfair Display, serif' }}>Guest Journey</h1>
                <div className="w-9"></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center">Track each guest's progress from invitation to post-wedding</p>
            </div>

            <div className="px-4 py-6 space-y-5">
              {/* Journey stages visualization */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-4">Journey Stages</h3>
                <div className="flex items-center gap-2 overflow-x-auto pb-2">
                  {[
                    { stage: 'Invite', count: 120, color: '#285301', complete: true },
                    { stage: 'RSVP', count: 86, color: '#285301', complete: true },
                    { stage: 'Flight', count: 52, color: '#d45d78', complete: false },
                    { stage: 'Hotel', count: 48, color: '#d45d78', complete: false },
                    { stage: 'Transport', count: 38, color: '#d45d78', complete: false },
                    { stage: 'Event Ready', count: 24, color: '#f194b2', complete: false },
                    { stage: 'Post-wedding', count: 0, color: '#c4a574', complete: false },
                  ].map((item, idx) => (
                    <div key={item.stage} className="flex items-center gap-2 flex-shrink-0">
                      <div className={`px-4 py-3 rounded-[20px] border-2 ${item.complete ? 'bg-[#3A8B95] border-[#3A8B95] text-white' : 'bg-white border-gray-200 text-gray-700'} text-center`}>
                        <div className="text-[11px] mb-1">{item.stage}</div>
                        <div className="text-[16px] font-medium">{item.count}</div>
                      </div>
                      {idx < 6 && <ChevronRight size={16} className="text-gray-400 flex-shrink-0" />}
                    </div>
                  ))}
                </div>
              </div>

              {/* Overall progress summary */}
              <div className="bg-gradient-to-br from-[#285301] to-[#1f4201] rounded-2xl p-6 text-white">
                <h3 className="text-[18px] font-medium mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>Overall Journey Progress</h3>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-[28px] font-medium mb-1">86/120</div>
                    <div className="text-[13px] opacity-90">Have responded</div>
                  </div>
                  <div>
                    <div className="text-[28px] font-medium mb-1">24/86</div>
                    <div className="text-[13px] opacity-90">Fully ready for event</div>
                  </div>
                </div>
              </div>

              {/* Individual guest journey tracking */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-4">Guest Progress</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Track where each guest is in their journey. Click to see details or take action.
                </p>

                <div className="space-y-3">
                  {[
                    { name: 'Sarah Johnson', email: 'sarah@email.com', stages: [true, true, true, true, true, true, false], status: 'Event Ready' },
                    { name: 'Michael Chen', email: 'michael@email.com', stages: [true, true, true, true, false, false, false], status: 'Needs Transport' },
                    { name: 'Emily Rodriguez', email: 'emily@email.com', stages: [true, false, false, false, false, false, false], status: 'Awaiting RSVP' },
                    { name: 'David Park', email: 'david@email.com', stages: [true, true, true, false, false, false, false], status: 'Needs Hotel' },
                    { name: 'Lisa Anderson', email: 'lisa@email.com', stages: [true, true, false, false, false, false, false], status: 'Needs Flight' },
                  ].map((guest) => (
                    <button
                      key={guest.name}
                      onClick={() => {
                        setShowGuestJourney(false);
                        setActiveTab('guests');
                      }}
                      className="w-full p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100 text-left hover:shadow-md transition-all"
                    >
                      <div className="flex items-start justify-between mb-3">
                        <div>
                          <div className="text-[14px] font-medium text-gray-800">{guest.name}</div>
                          <div className="text-[12px] text-gray-600">{guest.email}</div>
                        </div>
                        <span className={`text-[11px] px-2.5 py-1 rounded-full font-medium ${guest.status === 'Event Ready' ? 'bg-[#3A8B95] text-white' : 'bg-[#FF3E9B] text-white'}`}>
                          {guest.status}
                        </span>
                      </div>
                      <div className="flex gap-1.5">
                        {guest.stages.map((complete, idx) => (
                          <div
                            key={idx}
                            className={`flex-1 h-1.5 rounded-full ${complete ? 'bg-[#3A8B95]' : 'bg-gray-200'}`}
                          />
                        ))}
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Bottleneck Analysis */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Bottleneck Analysis</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Where guests are getting stuck in the journey.
                </p>

                <div className="space-y-3">
                  <button
                    onClick={() => {
                      setShowGuestJourney(false);
                      setActiveTab('messages');
                    }}
                    className="w-full p-4 bg-[#FAFAFA]/60 rounded-[20px] text-left hover:bg-[#FAFAFA] transition-colors"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800 mb-1">34 guests awaiting RSVP</div>
                        <div className="text-[12px] text-gray-600">Biggest drop-off point — send reminder</div>
                      </div>
                      <ChevronRight size={18} className="text-gray-400 flex-shrink-0 ml-2" />
                    </div>
                  </button>

                  <button
                    onClick={() => {
                      setShowGuestJourney(false);
                      setActiveTab('logistics');
                    }}
                    className="w-full p-4 bg-[#FAFAFA]/40 rounded-[20px] text-left hover:bg-[#FAFAFA] transition-colors"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800 mb-1">38 guests missing hotel details</div>
                        <div className="text-[12px] text-gray-600">May need hotel recommendations</div>
                      </div>
                      <ChevronRight size={18} className="text-gray-400 flex-shrink-0 ml-2" />
                    </div>
                  </button>

                  <button
                    onClick={() => {
                      setShowGuestJourney(false);
                      setActiveTab('logistics');
                    }}
                    className="w-full p-4 bg-[#FAFAFA]/20 rounded-[20px] text-left hover:bg-[#FAFAFA]/40 transition-colors"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800 mb-1">48 guests need transport assignment</div>
                        <div className="text-[12px] text-gray-600">Ready for shuttle coordination</div>
                      </div>
                      <ChevronRight size={18} className="text-gray-400 flex-shrink-0 ml-2" />
                    </div>
                  </button>
                </div>
              </div>

              {/* Journey Automations */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Journey Automations</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Set up automated reminders and follow-ups for key journey milestones.
                </p>

                <div className="space-y-3">
                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">RSVP reminder sequence</div>
                        <div className="text-[12px] text-gray-600 mt-1">3 days, 7 days, and 14 days after invite</div>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-[11px] px-2 py-0.5 rounded-full bg-[#3A8B95] text-white">Active</span>
                      </div>
                    </div>
                  </div>

                  <div className="p-4 bg-white rounded-[20px] border-2 border-dashed border-gray-300">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">Travel reminder flow</div>
                        <div className="text-[12px] text-gray-600 mt-1">14 days and 3 days before event</div>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-[11px] px-2 py-0.5 rounded-full bg-gray-200 text-gray-700">Draft</span>
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={() => {
                      setShowGuestJourney(false);
                      setActiveTab('messages');
                    }}
                    className="w-full py-2.5 bg-white border border-gray-300 rounded-[20px] text-[13px] text-gray-700 font-medium hover:bg-gray-50 transition-colors"
                  >
                    + Create new automation
                  </button>
                </div>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={() => setShowGuestJourney(false)}
                  className="flex-1 py-3 border border-gray-300 rounded-[20px] text-gray-700 text-[14px] font-medium hover:bg-gray-50 transition-colors"
                >
                  Close
                </button>
                <button
                  onClick={() => {
                    setShowGuestJourney(false);
                    setActiveTab('guests');
                  }}
                  className="flex-1 py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] font-medium hover:bg-[#1f4201] transition-colors"
                >
                  Manage guests
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ADVANCED SUPPORTING PAGE - VIP / PRIORITY GUESTS */}
      {showVIPGuests && (
        <div className="fixed inset-0 bg-[#fefdfb] z-[60] overflow-y-auto">
          <div className="min-h-screen">
            {/* Header */}
            <div className="bg-white border-b border-gray-100 px-4 pt-6 pb-4 sticky top-0 z-10">
              <div className="flex items-center justify-between mb-3">
                <button
                  onClick={() => setShowVIPGuests(false)}
                  className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors"
                >
                  <X size={20} className="text-gray-600" />
                </button>
                <h1 className="text-2xl text-[#FF3E9B] flex-1 text-center" style={{ fontFamily: 'Playfair Display, serif' }}>VIP / Priority Guests</h1>
                <div className="w-9"></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center">Special handling and coordination for key attendees</p>
            </div>

            <div className="px-4 py-6 space-y-5">
              {/* VIP summary */}
              <div className="bg-gradient-to-br from-[#285301] to-[#1f4201] rounded-2xl p-6 text-white">
                <h2 className="text-[18px] font-medium mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>Priority Guest Overview</h2>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-[28px] font-medium mb-1">12</div>
                    <div className="text-[13px] opacity-90">VIP guests</div>
                  </div>
                  <div>
                    <div className="text-[28px] font-medium mb-1">10/12</div>
                    <div className="text-[13px] opacity-90">Travel confirmed</div>
                  </div>
                </div>
              </div>

              {/* VIP guest cards */}
              <div className="space-y-3">
                {[
                  {
                    name: 'Margaret Anderson',
                    role: "Bride's Mother",
                    vipType: 'Core Family',
                    travelReady: true,
                    seatingImportance: 'High',
                    lastContact: '2 days ago',
                    notes: 'Arriving 2 days early, needs airport pickup'
                  },
                  {
                    name: 'Robert Chen',
                    role: "Groom's Father",
                    vipType: 'Core Family',
                    travelReady: true,
                    seatingImportance: 'High',
                    lastContact: '1 week ago',
                    notes: 'Flying in from Hong Kong'
                  },
                  {
                    name: 'Jennifer Williams',
                    role: 'Maid of Honor',
                    vipType: 'Wedding Party',
                    travelReady: false,
                    seatingImportance: 'High',
                    lastContact: '4 days ago',
                    notes: 'Need to confirm rehearsal dinner attendance'
                  },
                  {
                    name: 'Thomas Rodriguez',
                    role: 'Best Man',
                    vipType: 'Wedding Party',
                    travelReady: true,
                    seatingImportance: 'High',
                    lastContact: 'Yesterday',
                    notes: 'Coordinating bachelor party arrival'
                  },
                  {
                    name: 'Dr. Patricia Martinez',
                    role: 'Officiant',
                    vipType: 'Special Role',
                    travelReady: true,
                    seatingImportance: 'Medium',
                    lastContact: '3 days ago',
                    notes: 'Needs ceremony script review'
                  },
                ].map((vip) => (
                  <div key={vip.name} className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="text-[16px] font-medium text-gray-900">{vip.name}</h3>
                          <span className="text-[11px] px-2 py-0.5 rounded-full bg-[#3A8B95] text-white">{vip.vipType}</span>
                        </div>
                        <p className="text-[13px] text-gray-600">{vip.role}</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3 mb-4">
                      <div className="p-3 bg-[#FAFAFA]/40 rounded-[20px]">
                        <div className="text-[11px] text-gray-600 mb-1">Travel Status</div>
                        <div className={`text-[13px] font-medium ${vip.travelReady ? 'text-[#FF3E9B]' : 'text-[#FF3E9B]'}`}>
                          {vip.travelReady ? '✓ Confirmed' : 'Pending'}
                        </div>
                      </div>
                      <div className="p-3 bg-[#FAFAFA]/40 rounded-[20px]">
                        <div className="text-[11px] text-gray-600 mb-1">Seating Priority</div>
                        <div className="text-[13px] font-medium text-gray-800">{vip.seatingImportance}</div>
                      </div>
                    </div>

                    <div className="p-3 bg-blue-50 border border-blue-200 rounded-[20px] mb-4">
                      <div className="text-[11px] text-blue-800 mb-1" style={{ fontWeight: 500 }}>Notes</div>
                      <p className="text-[12px] text-blue-900">{vip.notes}</p>
                    </div>

                    <div className="text-[11px] text-gray-500 mb-3">Last contact: {vip.lastContact}</div>

                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => {
                          setShowVIPGuests(false);
                          setActiveTab('messages');
                        }}
                        className="py-2.5 bg-[#FF3E9B] text-white rounded-[20px] text-[13px] font-medium hover:bg-[#c14d68] transition-colors flex items-center justify-center gap-1.5"
                      >
                        <MessageSquare size={14} />
                        Message
                      </button>
                      <button
                        onClick={() => {
                          setShowVIPGuests(false);
                          setActiveTab('guests');
                        }}
                        className="py-2.5 bg-white border border-gray-300 text-gray-700 rounded-[20px] text-[13px] font-medium hover:bg-gray-50 transition-colors"
                      >
                        View Details
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              {/* Quick actions for all VIPs */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-4">Bulk VIP Actions</h3>
                <div className="space-y-2">
                  <button
                    onClick={() => {
                      setShowVIPGuests(false);
                      setActiveTab('messages');
                    }}
                    className="w-full py-3 bg-[#FF3E9B] text-white rounded-[20px] text-[14px] font-medium hover:bg-[#c14d68] transition-colors flex items-center justify-center gap-2"
                  >
                    <Send size={16} />
                    Send personal message to all VIPs
                  </button>
                  <button
                    onClick={() => {
                      setShowVIPGuests(false);
                      setActiveTab('logistics');
                    }}
                    className="w-full py-3 bg-white border border-gray-300 text-gray-700 rounded-[20px] text-[14px] font-medium hover:bg-gray-50 transition-colors"
                  >
                    Confirm all VIP arrivals
                  </button>
                </div>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={() => setShowVIPGuests(false)}
                  className="flex-1 py-3 border border-gray-300 rounded-[20px] text-gray-700 text-[14px] font-medium hover:bg-gray-50 transition-colors"
                >
                  Close
                </button>
                <button
                  onClick={() => {
                    setShowVIPGuests(false);
                    setActiveTab('guests');
                  }}
                  className="flex-1 py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] font-medium hover:bg-[#1f4201] transition-colors"
                >
                  View all guests
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ADVANCED SUPPORTING PAGE - EXPERIENCE DESIGN */}
      {showExperienceDesign && (
        <div className="fixed inset-0 bg-[#fefdfb] z-[60] overflow-y-auto">
          <div className="min-h-screen">
            {/* Header */}
            <div className="bg-white border-b border-gray-100 px-4 pt-6 pb-4 sticky top-0 z-10">
              <div className="flex items-center justify-between mb-3">
                <button
                  onClick={() => setShowExperienceDesign(false)}
                  className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center hover:bg-gray-200 transition-colors"
                >
                  <X size={20} className="text-gray-600" />
                </button>
                <h1 className="text-2xl text-[#FF3E9B] flex-1 text-center" style={{ fontFamily: 'Playfair Display, serif' }}>Experience Design</h1>
                <div className="w-9"></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center">Shape the emotional experience of your guests</p>
            </div>

            <div className="px-4 py-6 space-y-5">
              {/* Intro card */}
              <div className="bg-gradient-to-br from-[#285301] to-[#1f4201] rounded-2xl p-6 text-white">
                <h2 className="text-[18px] font-medium mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>Emotional Planning Layer</h2>
                <p className="text-[14px] opacity-95" style={{ lineHeight: 1.6 }}>
                  This is where guest management becomes guest experience. Think not only about what guests need, but how they should feel at every touchpoint.
                </p>
              </div>

              {/* Welcome Experience */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Welcome Experience</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Set the tone for your wedding from the moment guests arrive.
                </p>

                <div className="space-y-3">
                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800 mb-1">First impression</div>
                        <div className="text-[12px] text-gray-600">What guests see when they open your invitation link</div>
                      </div>
                      <button
                        onClick={() => {
                          setShowExperienceDesign(false);
                          setActiveTab('landing');
                        }}
                        className="text-[#FF3E9B] hover:text-[#c14d68]"
                      >
                        <Edit size={18} />
                      </button>
                    </div>
                    <div className="mt-3 p-3 bg-white rounded-[20px] border border-gray-200">
                      <p className="text-[12px] text-gray-700" style={{ lineHeight: 1.5 }}>
                        "We're so excited to celebrate with you in San Francisco. Every detail is designed to make you feel welcome."
                      </p>
                    </div>
                  </div>

                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    <div className="text-[14px] font-medium text-gray-800 mb-1">Arrival moment</div>
                    <div className="text-[12px] text-gray-600 mb-3">How travelling guests are greeted</div>
                    <div className="flex items-center justify-between p-3 bg-white rounded-[20px]">
                      <label className="text-[13px] text-gray-700">Welcome package at hotel</label>
                      <input type="checkbox" className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                    </div>
                  </div>
                </div>
              </div>

              {/* Event Personalization */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Event Personalization</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Customize what different guest groups experience.
                </p>

                <div className="space-y-3">
                  <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">Travelling guests</div>
                        <div className="text-[12px] text-gray-600 mt-1">See hospitality-forward experience with hotels, transport, and local tips</div>
                      </div>
                      <span className="text-[11px] px-2 py-0.5 rounded-full bg-[#3A8B95] text-white">Active</span>
                    </div>
                  </div>

                  <div className="p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">Wedding party</div>
                        <div className="text-[12px] text-gray-600 mt-1">See insider schedule with rehearsal, call times, and special instructions</div>
                      </div>
                      <span className="text-[11px] px-2 py-0.5 rounded-full bg-[#3A8B95] text-white">Active</span>
                    </div>
                  </div>

                  <div className="p-4 bg-white rounded-[20px] border-2 border-dashed border-gray-300">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] font-medium text-gray-800">Family only</div>
                        <div className="text-[12px] text-gray-600 mt-1">Private family events and extended schedule access</div>
                      </div>
                      <span className="text-[11px] px-2 py-0.5 rounded-full bg-gray-200 text-gray-700">Draft</span>
                    </div>
                  </div>
                </div>

                <button
                  onClick={() => {
                    setShowExperienceDesign(false);
                    setActiveTab('landing');
                  }}
                  className="w-full mt-3 py-2.5 bg-white border border-gray-300 rounded-[20px] text-[13px] text-gray-700 font-medium hover:bg-gray-50 transition-colors"
                >
                  Edit guest access rules
                </button>
              </div>

              {/* Gift or Welcome Notes */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Welcome Notes & Gifts</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Personal touches that make guests feel special.
                </p>

                <div className="space-y-3">
                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    <div className="text-[14px] font-medium text-gray-800 mb-2">Personalized welcome note</div>
                    <textarea
                      className="w-full px-3 py-2 rounded-[20px] border border-gray-200 text-[13px] resize-none"
                      rows={3}
                      placeholder="Write a warm welcome message for your guests..."
                      defaultValue="Thank you for traveling to celebrate with us. Your presence means the world."
                    />
                  </div>

                  <div className="flex items-center justify-between p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-800">Hotel welcome bags</div>
                      <div className="text-[12px] text-gray-600 mt-1">Local snacks, itinerary, and personal note</div>
                    </div>
                    <input type="checkbox" defaultChecked className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                  </div>

                  <div className="flex items-center justify-between p-4 bg-[#FAFAFA]/40 rounded-[20px]">
                    <div className="flex-1">
                      <div className="text-[14px] font-medium text-gray-800">Favor at place setting</div>
                      <div className="text-[12px] text-gray-600 mt-1">Small gift at each seat</div>
                    </div>
                    <input type="checkbox" className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]" />
                  </div>
                </div>
              </div>

              {/* Preference Collection */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Preference Collection</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Gather information that helps you create a better experience.
                </p>

                <div className="space-y-2">
                  {[
                    { label: 'Song requests', description: 'Let guests suggest music they want to hear' },
                    { label: 'Special memories', description: 'Ask guests to share a favorite memory with the couple' },
                    { label: 'Photo preferences', description: 'Ask if guests want to be included in group photos' },
                    { label: 'Accessibility needs', description: 'Collect mobility, dietary, or other accommodation needs' },
                  ].map((pref) => (
                    <div key={pref.label} className="flex items-start justify-between p-3 bg-[#FAFAFA]/30 rounded-[20px]">
                      <div className="flex-1">
                        <div className="text-[13px] text-gray-800">{pref.label}</div>
                        <div className="text-[11px] text-gray-600 mt-0.5">{pref.description}</div>
                      </div>
                      <input type="checkbox" className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B] mt-0.5" />
                    </div>
                  ))}
                </div>
              </div>

              {/* Emotional Moments */}
              <div className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                <h3 className="text-[16px] font-medium text-[#FF3E9B] mb-3">Emotional Moments</h3>
                <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
                  Plan the moments that will create lasting memories.
                </p>

                <div className="space-y-3">
                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    <div className="text-[14px] font-medium text-gray-800 mb-2">First glimpse</div>
                    <p className="text-[12px] text-gray-600" style={{ lineHeight: 1.5 }}>
                      When guests first enter the venue, what do you want them to see and feel?
                    </p>
                    <input
                      type="text"
                      className="w-full mt-2 px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                      placeholder="e.g., Candles and flowers creating a warm, intimate atmosphere"
                    />
                  </div>

                  <div className="p-4 bg-gradient-to-br from-[#FAFAFA] to-white rounded-[20px] border border-gray-100">
                    <div className="text-[14px] font-medium text-gray-800 mb-2">Last impression</div>
                    <p className="text-[12px] text-gray-600" style={{ lineHeight: 1.5 }}>
                      How do you want guests to leave? What will they remember?
                    </p>
                    <input
                      type="text"
                      className="w-full mt-2 px-3 py-2 rounded-[20px] border border-gray-200 text-[13px]"
                      placeholder="e.g., Sparkler send-off with late-night snacks to go"
                    />
                  </div>
                </div>
              </div>

              {/* Connection to main builder */}
              <div className="p-4 bg-blue-50 border border-blue-200 rounded-[20px]">
                <p className="text-[12px] text-blue-900" style={{ lineHeight: 1.5 }}>
                  💡 <strong>Tip:</strong> These emotional design choices connect directly to your Guest Experience builder. Changes here will update what guests see on their personalized pages.
                </p>
              </div>

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={() => setShowExperienceDesign(false)}
                  className="flex-1 py-3 border border-gray-300 rounded-[20px] text-gray-700 text-[14px] font-medium hover:bg-gray-50 transition-colors"
                >
                  Close
                </button>
                <button
                  onClick={() => {
                    setShowExperienceDesign(false);
                    setActiveTab('landing');
                  }}
                  className="flex-1 py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] font-medium hover:bg-[#1f4201] transition-colors"
                >
                  Open Guest Experience
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
