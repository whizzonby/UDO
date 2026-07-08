import { useState } from 'react';
import { DndProvider, useDrag, useDrop } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import { Users, Plus, ChevronRight, Clock, MapPin, Check, MessageSquare, Send, X, AlertCircle, Bell, Calendar, Phone, Mail, Edit, Trash2, Upload, FileText, Heart, Plane, Hotel, User, Flag, Shield, Zap, TrendingUp, Activity, ChevronDown, Search, Filter, MoreVertical, LayoutGrid, List as ListIcon, BarChart3, UserCircle, CalendarClock, GripVertical, ArrowUpDown, AlertTriangle, CheckCircle2, Utensils } from 'lucide-react';
import ResponsibilityDetailDrawer from './wedding-party/ResponsibilityDetailDrawer';
import TimelineItemDetailModal from './wedding-party/TimelineItemDetailModal';
import InteractiveOverviewTab from './wedding-party/InteractiveOverviewTab';
import InteractiveBuzzesTab from './wedding-party/InteractiveBuzzesTab';

type WeddingPartyTab = 'overview' | 'people' | 'responsibilities' | 'buzzes' | 'wedding-timeline' | 'travel' | 'rehearsal' | 'emergency' | 'files-speeches';
type ViewMode = 'kanban' | 'timeline' | 'priority' | 'by-person' | 'list';
type TaskStatus = 'assigned' | 'viewed' | 'acknowledged' | 'in-progress' | 'delayed' | 'needs-help' | 'escalated' | 'completed';

interface Person {
  id: string;
  name: string;
  nickname?: string;
  pronouns?: string;
  role: string;
  relationship: string;
  phone: string;
  email: string;
  preferredContact: 'WhatsApp' | 'SMS' | 'Email' | 'Call';
  location: string;
  timezone: string;
  arrival?: string;
  hotel?: string;
  flightNumber?: string;
  travelStatus: 'confirmed' | 'needs-response' | 'travelling' | 'delayed' | 'checked-in';
  attireStatus: 'complete' | 'needs-fitting' | 'pending-approval' | 'measurements-needed';
  rehearsalStatus: 'confirmed' | 'pending' | 'declined';
  responsiveness: 'high' | 'medium' | 'low';
  unreadUpdates: number;
  pendingTasks: number;
  emergencyContact: string;
  dietaryRestrictions?: string;
  allergies?: string;
  notes: string;
  measurements?: any;
  responsibilities: string[];
}

interface Responsibility {
  id: string;
  title: string;
  owner: string;
  backupOwner?: string;
  dueTime: string;
  location: string;
  status: TaskStatus;
  urgency: 'low' | 'medium' | 'high';
  dependencies?: string[];
  linkedPeople: string[];
  description: string;
}

interface Buzz {
  id: string;
  message: string;
  recipients: string;
  channel: 'WhatsApp' | 'SMS' | 'Email' | 'Push' | 'In-app';
  tone: 'elegant' | 'calm' | 'gentle' | 'loving' | 'excited' | 'urgent' | 'encouraging' | 'funny' | 'formal';
  sentAt: string;
  deliveryStatus: 'sent' | 'delivered' | 'read';
  reactions: { emoji: string; count: number }[];
  readBy: string[];
}

export default function WeddingPartyPage() {
  const [activeTab, setActiveTab] = useState<WeddingPartyTab>('overview');
  const [expandedPersonId, setExpandedPersonId] = useState<string | null>(null);
  const [expandedAlertId, setExpandedAlertId] = useState<string | null>(null);
  const [showBuzzModal, setShowBuzzModal] = useState(false);
  const [showAddPersonModal, setShowAddPersonModal] = useState(false);
  const [showAssignTaskModal, setShowAssignTaskModal] = useState(false);
  const [showEmergencyBroadcast, setShowEmergencyBroadcast] = useState(false);
  const [showActivityFeed, setShowActivityFeed] = useState(false);
  const [showTaskDetail, setShowTaskDetail] = useState<string | null>(null);
  const [showBuzzDetail, setShowBuzzDetail] = useState<string | null>(null);
  const [showAttireDetail, setShowAttireDetail] = useState<string | null>(null);
  const [showAddNoteModal, setShowAddNoteModal] = useState<string | null>(null);
  const [showUploadModal, setShowUploadModal] = useState<string | null>(null);
  const [responsibilitiesView, setResponsibilitiesView] = useState<ViewMode>('kanban');
  const [selectedTimelineType, setSelectedTimelineType] = useState('wedding-morning');
  const [readinessScore, setReadinessScore] = useState(93);
  const [peopleSearchQuery, setPeopleSearchQuery] = useState('');
  const [showPeopleFilter, setShowPeopleFilter] = useState(false);
  const [taskStatuses, setTaskStatuses] = useState<{[key: string]: TaskStatus}>({
    'r1': 'assigned',
    'r2': 'in-progress',
    'r3': 'acknowledged',
    'r4': 'completed',
    'r5': 'needs-help'
  });
  const [selectedBuzzRecipient, setSelectedBuzzRecipient] = useState('All wedding party (12)');
  const [selectedBuzzChannel, setSelectedBuzzChannel] = useState<'WhatsApp' | 'SMS' | 'Email'>('WhatsApp');
  const [selectedBuzzTone, setSelectedBuzzTone] = useState('gentle');
  const [buzzMessage, setBuzzMessage] = useState('');
  const [scheduleBuzz, setScheduleBuzz] = useState(false);
  const [selectedResponsibility, setSelectedResponsibility] = useState<any>(null);
  const [selectedTimelineItem, setSelectedTimelineItem] = useState<any>(null);
  const [autoAdjustTimeline, setAutoAdjustTimeline] = useState(true);
  const [isDestinationWedding, setIsDestinationWedding] = useState(true);
  const [selectedTravelPerson, setSelectedTravelPerson] = useState<string | null>(null);
  const [selectedRehearsalItem, setSelectedRehearsalItem] = useState<any>(null);
  const [showEmergencyBroadcastModal, setShowEmergencyBroadcastModal] = useState(false);

  // Navigation helpers
  const handleNavigateToTab = (tab: string) => {
    setActiveTab(tab as WeddingPartyTab);
  };

  const handleNavigateToItem = (tab: string, itemId: string) => {
    setActiveTab(tab as WeddingPartyTab);
    // Additional logic to open specific item based on tab
    if (tab === 'responsibilities') {
      setShowTaskDetail(itemId);
    } else if (tab === 'buzzes') {
      setShowBuzzDetail(itemId);
    } else if (tab === 'people') {
      setExpandedPersonId(itemId);
    }
  };

  const handleSendBuzz = (newBuzz: any) => {
    // In a real app, this would send to an API
    console.log('Sending buzz:', newBuzz);
    // Update buzzes state
    // buzzes.push({ ...newBuzz, id: `b${buzzes.length + 1}` });
  };

  // Sample data
  const people: Person[] = [
    {
      id: '1',
      name: 'Emily Rodriguez',
      nickname: 'Em',
      pronouns: 'she/her',
      role: 'Maid of Honor',
      relationship: 'College roommate',
      phone: '+1 (555) 234-5678',
      email: 'emily.r@email.com',
      preferredContact: 'WhatsApp',
      location: 'San Francisco, CA',
      timezone: 'PST',
      arrival: 'June 12, 4:20 PM',
      hotel: 'Villa Azure',
      flightNumber: 'UA 1234',
      travelStatus: 'confirmed',
      attireStatus: 'complete',
      rehearsalStatus: 'confirmed',
      responsiveness: 'high',
      unreadUpdates: 0,
      pendingTasks: 2,
      emergencyContact: 'Sarah Rodriguez: +1 (555) 234-5679',
      dietaryRestrictions: 'Vegetarian',
      notes: 'Always calms the bride down. Met in college freshman year. Very organized.',
      responsibilities: ['Bride support', 'Emergency coordinator', 'Breakfast coordination']
    },
    {
      id: '2',
      name: 'James Wilson',
      role: 'Best Man',
      relationship: 'Childhood friend',
      phone: '+1 (555) 876-5432',
      email: 'james.w@email.com',
      preferredContact: 'SMS',
      location: 'Los Angeles, CA',
      timezone: 'PST',
      arrival: 'June 12, 2:15 PM',
      hotel: 'Fairmont Hotel',
      flightNumber: 'AA 567',
      travelStatus: 'confirmed',
      attireStatus: 'complete',
      rehearsalStatus: 'confirmed',
      responsiveness: 'high',
      unreadUpdates: 1,
      pendingTasks: 1,
      emergencyContact: 'Maria Wilson: +1 (555) 876-5433',
      notes: 'Helped plan the proposal. Best friend since elementary school.',
      responsibilities: ['Ring security', 'Transport coordinator', 'Speech']
    },
    {
      id: '3',
      name: 'Sarah Martinez',
      pronouns: 'she/her',
      role: 'Bridesmaid',
      relationship: 'Sister',
      phone: '+1 (555) 345-6789',
      email: 'sarah.m@email.com',
      preferredContact: 'Email',
      location: 'New York, NY',
      timezone: 'EST',
      arrival: 'June 11, 6:00 PM',
      hotel: 'Villa Azure',
      travelStatus: 'needs-response',
      attireStatus: 'needs-fitting',
      rehearsalStatus: 'pending',
      responsiveness: 'medium',
      unreadUpdates: 3,
      pendingTasks: 4,
      emergencyContact: 'Carlos Martinez: +1 (555) 345-6790',
      allergies: 'Shellfish',
      notes: 'Feeling nervous about fitting. Point of contact for florist. Needs transportation confirmation.',
      responsibilities: ['Guest arrival coordination', 'Florist liaison']
    }
  ];

  const responsibilities: Responsibility[] = [
    {
      id: 'r1',
      title: 'Ensure bride eats breakfast before makeup',
      owner: 'Emily Rodriguez',
      dueTime: 'Wedding morning, 8:00 AM',
      location: 'Bridal suite',
      status: 'assigned',
      urgency: 'high',
      linkedPeople: ['1'],
      description: 'Make sure bride has proper nutrition before long day. Have light breakfast ready.'
    },
    {
      id: 'r2',
      title: 'Coordinate grandparents transportation',
      owner: 'James Wilson',
      backupOwner: 'Sarah Martinez',
      dueTime: 'Ceremony day, 2:00 PM',
      location: 'Hotel lobby',
      status: 'in-progress',
      urgency: 'medium',
      dependencies: ['Shuttle timing confirmed'],
      linkedPeople: ['2', '3'],
      description: 'Ensure grandparents have transportation arranged and confirmed'
    },
    {
      id: 'r3',
      title: 'Manage bouquet handoff during ceremony',
      owner: 'Sarah Martinez',
      dueTime: 'Ceremony, 4:10 PM',
      location: 'Ceremony venue',
      status: 'acknowledged',
      urgency: 'high',
      dependencies: ['Florist delivery confirmed'],
      linkedPeople: ['3'],
      description: 'Take bouquet from bride during vows, return after ring exchange'
    },
    {
      id: 'r4',
      title: 'Confirm emergency sewing kit is available',
      owner: 'Emily Rodriguez',
      dueTime: 'Wedding morning, 7:00 AM',
      location: 'Bridal suite',
      status: 'completed',
      urgency: 'low',
      linkedPeople: ['1'],
      description: 'Emergency kit with needle, thread, safety pins, stain remover'
    },
    {
      id: 'r5',
      title: 'Handle ceremony rings security',
      owner: 'James Wilson',
      backupOwner: 'Emily Rodriguez',
      dueTime: 'Ceremony, 4:00 PM',
      location: 'Ceremony venue',
      status: 'needs-help',
      urgency: 'high',
      linkedPeople: ['2', '1'],
      description: 'Ensure rings are secure and ready for ring bearer or ceremony'
    }
  ];

  const buzzes: Buzz[] = [
    {
      id: 'b1',
      message: 'Hi everyone 💛 rehearsal begins at 5:30 PM. Please arrive 15 minutes early so we can begin calmly and on time.',
      recipients: 'All wedding party (12)',
      channel: 'WhatsApp',
      tone: 'gentle',
      sentAt: '2h ago',
      deliveryStatus: 'read',
      reactions: [
        { emoji: '👍', count: 8 },
        { emoji: '💛', count: 4 }
      ],
      readBy: ['1', '2']
    },
    {
      id: 'b2',
      message: 'Transportation has been updated. Check your portal for details.',
      recipients: 'Travelling guests (7)',
      channel: 'SMS',
      tone: 'calm',
      sentAt: '5h ago',
      deliveryStatus: 'delivered',
      reactions: [
        { emoji: '👍', count: 6 },
        { emoji: '🚗', count: 3 }
      ],
      readBy: ['1']
    },
    {
      id: 'b3',
      message: 'Please upload your measurements by tonight ✨',
      recipients: 'Bridesmaids (6)',
      channel: 'Email',
      tone: 'encouraging',
      sentAt: '1d ago',
      deliveryStatus: 'read',
      reactions: [
        { emoji: '💛', count: 5 },
        { emoji: '✓', count: 4 }
      ],
      readBy: ['1', '3']
    }
  ];

  const operationalAlerts = [
    {
      id: 'a1',
      title: '2 bridesmaids still need final measurements',
      type: 'attire',
      urgency: 'medium',
      linkedPeople: ['Sarah Martinez', 'Jessica Moore'],
      action: 'Send reminder',
      impact: 'Dress alterations may be delayed'
    },
    {
      id: 'a2',
      title: 'Best man has not acknowledged rehearsal transport',
      type: 'logistics',
      urgency: 'high',
      linkedPeople: ['James Wilson'],
      action: 'Follow up',
      impact: 'May miss rehearsal start time'
    },
    {
      id: 'a3',
      title: 'Hair timeline may impact photography schedule',
      type: 'timeline',
      urgency: 'medium',
      linkedPeople: ['Emily Rodriguez'],
      action: 'Review timeline',
      impact: 'Photography session could start late'
    }
  ];

  const activities = [
    { id: '1', text: 'Emily uploaded her speech draft', time: '2h ago', icon: '📝', person: 'Emily Rodriguez' },
    { id: '2', text: 'Best man confirmed transportation route', time: '4h ago', icon: '🚗', person: 'James Wilson' },
    { id: '3', text: 'Hair stylist adjusted appointment schedule', time: '6h ago', icon: '💇', person: 'Vendor Update' },
    { id: '4', text: 'Bridesmaids approved final dress styling', time: '1d ago', icon: '👗', person: 'Wedding Party' },
    { id: '5', text: 'Transportation update sent to all guests', time: '1d ago', icon: '🚌', person: 'Planner' }
  ];

  const travelData = [
    {
      id: 't1',
      person: 'Emily Rodriguez',
      personId: '1',
      role: 'Maid of Honor',
      flightNumber: 'UA 2847',
      arrivalAirport: 'SFO',
      arrivalDate: 'June 13, 2026',
      arrivalTime: '2:30 PM',
      departureDate: 'June 17, 2026',
      departureTime: '6:45 PM',
      hotel: 'Rosewood Villa - Room 204',
      roommate: 'Sarah Martinez',
      shuttleGroup: 'Group A - 3:15 PM pickup',
      transferStatus: 'Confirmed',
      paymentStatus: 'Paid',
      coordinator: 'Wedding Planner',
      confirmationCode: 'RW-204-EM',
      notes: 'Vegetarian meal requested',
      emergencyContact: '+1 (555) 0101'
    },
    {
      id: 't2',
      person: 'James Wilson',
      personId: '2',
      role: 'Best Man',
      flightNumber: 'DL 1923',
      arrivalAirport: 'SFO',
      arrivalDate: 'June 13, 2026',
      arrivalTime: '4:15 PM',
      departureDate: 'June 17, 2026',
      departureTime: '8:30 PM',
      hotel: 'Rosewood Villa - Room 108',
      roommate: 'Solo',
      shuttleGroup: 'Group B - 5:00 PM pickup',
      transferStatus: 'Confirmed',
      paymentStatus: 'Pending',
      coordinator: 'Best Man',
      confirmationCode: 'RW-108-JW',
      emergencyContact: '+1 (555) 0102',
      delay: '15 min delay'
    },
    {
      id: 't3',
      person: 'Sarah Martinez',
      personId: '3',
      role: 'Bridesmaid',
      flightNumber: 'AA 5621',
      arrivalAirport: 'SFO',
      arrivalDate: 'June 13, 2026',
      arrivalTime: '11:45 AM',
      departureDate: 'June 17, 2026',
      departureTime: '3:20 PM',
      hotel: 'Rosewood Villa - Room 204',
      roommate: 'Emily Rodriguez',
      shuttleGroup: 'Group A - 3:15 PM pickup',
      transferStatus: 'Confirmed',
      paymentStatus: 'Paid',
      coordinator: 'Wedding Planner',
      confirmationCode: 'RW-204-SM',
      emergencyContact: '+1 (555) 0103'
    },
    {
      id: 't4',
      person: 'Jessica Moore',
      personId: '4',
      role: 'Bridesmaid',
      flightNumber: 'SW 782',
      arrivalAirport: 'SFO',
      arrivalDate: 'June 14, 2026',
      arrivalTime: '9:30 AM',
      departureDate: 'June 16, 2026',
      departureTime: '7:15 PM',
      hotel: 'Rosewood Villa - Room 312',
      roommate: 'Solo',
      shuttleGroup: 'Group C - 10:15 AM pickup',
      transferStatus: 'Needs confirmation',
      paymentStatus: 'Paid',
      coordinator: 'Wedding Planner',
      confirmationCode: 'RW-312-JM',
      emergencyContact: '+1 (555) 0104'
    }
  ];

  const rehearsalSchedule = [
    {
      id: 'r1',
      time: '5:00 PM',
      title: 'Arrival & Welcome',
      location: 'Garden Ceremony Site',
      attendees: ['All wedding party', 'Parents', 'Officiant'],
      status: 'confirmed',
      coordinator: 'Wedding Planner',
      notes: 'Please arrive 15 minutes early'
    },
    {
      id: 'r2',
      time: '5:15 PM',
      title: 'Processional Walkthrough',
      location: 'Ceremony Aisle',
      attendees: ['Wedding party', 'Parents', 'Flower girl', 'Ring bearer'],
      status: 'confirmed',
      coordinator: 'Wedding Planner',
      order: ['Groomsmen', 'Bridesmaids', 'Maid of Honor', 'Best Man', 'Flower girl', 'Ring bearer', 'Bride & Father'],
      notes: 'Practice timing and spacing'
    },
    {
      id: 'r3',
      time: '5:45 PM',
      title: 'Ceremony Positions & Vows Practice',
      location: 'Altar Area',
      attendees: ['Bride', 'Groom', 'Officiant', 'Maid of Honor', 'Best Man'],
      status: 'confirmed',
      coordinator: 'Officiant',
      notes: 'Optional vows run-through'
    },
    {
      id: 'r4',
      time: '6:15 PM',
      title: 'Recessional & Photo Lineup',
      location: 'Ceremony Site',
      attendees: ['All wedding party'],
      status: 'confirmed',
      coordinator: 'Photographer',
      notes: 'Practice recessional order and photo groupings'
    },
    {
      id: 'r5',
      time: '6:45 PM',
      title: 'Reception Entrance Practice',
      location: 'Grand Ballroom',
      attendees: ['Wedding party'],
      status: 'pending',
      coordinator: 'DJ',
      notes: 'Practice grand entrance choreography'
    },
    {
      id: 'r6',
      time: '7:00 PM',
      title: 'Speech Practice (Optional)',
      location: 'Private Lounge',
      attendees: ['Maid of Honor', 'Best Man', 'Father of Bride'],
      status: 'optional',
      coordinator: 'Wedding Planner',
      notes: 'Optional mic check and speech timing'
    },
    {
      id: 'r7',
      time: '7:30 PM',
      title: 'Rehearsal Dinner',
      location: 'Terrace Garden',
      attendees: ['All attendees'],
      status: 'confirmed',
      coordinator: 'Catering Team',
      notes: 'Casual dinner, speeches welcome'
    }
  ];

  const rehearsalAttendees = [
    { id: '1', name: 'Emily Rodriguez', role: 'Maid of Honor', status: 'confirmed', transport: 'Shared car with Sarah', speech: true },
    { id: '2', name: 'James Wilson', role: 'Best Man', status: 'confirmed', transport: 'Driving solo', speech: true },
    { id: '3', name: 'Sarah Martinez', role: 'Bridesmaid', status: 'confirmed', transport: 'Shared car with Emily', speech: false },
    { id: '4', name: 'Jessica Moore', role: 'Bridesmaid', status: 'pending', transport: 'TBD', speech: false },
    { id: '5', name: 'Father of Bride', role: 'Father', status: 'confirmed', transport: 'Driving with family', speech: true },
    { id: '6', name: 'Officiant Maria Chen', role: 'Officiant', status: 'confirmed', transport: 'Venue provided', speech: false }
  ];

  const emergencyContacts = [
    {
      id: 'e1',
      category: 'Wedding Team',
      contacts: [
        { name: 'Wedding Planner - Lisa Chang', phone: '+1 (555) 0200', available: '24/7', role: 'Primary coordinator' },
        { name: 'Assistant Planner - Marco Silva', phone: '+1 (555) 0201', available: '24/7', role: 'Backup coordinator' }
      ]
    },
    {
      id: 'e2',
      category: 'Venue',
      contacts: [
        { name: 'Venue Manager - Sarah Thompson', phone: '+1 (555) 0210', available: '8 AM - 10 PM', role: 'Venue operations' },
        { name: 'Security - John Davis', phone: '+1 (555) 0211', available: '24/7', role: 'Venue security' }
      ]
    },
    {
      id: 'e3',
      category: 'Critical Vendors',
      contacts: [
        { name: 'Photographer - Alex Kim', phone: '+1 (555) 0220', available: 'Event hours', role: 'Photography' },
        { name: 'Catering Director', phone: '+1 (555) 0221', available: 'Event hours', role: 'Food service' },
        { name: 'Florist - Garden Dreams', phone: '+1 (555) 0222', available: '7 AM - 9 PM', role: 'Floral arrangements' },
        { name: 'Transportation Lead', phone: '+1 (555) 0223', available: '24/7', role: 'Guest transport' }
      ]
    },
    {
      id: 'e4',
      category: 'Medical & Safety',
      contacts: [
        { name: 'Local Hospital', phone: '911 or +1 (555) 0300', available: '24/7', role: 'Emergency medical' },
        { name: 'On-site Nurse', phone: '+1 (555) 0301', available: 'Event hours', role: 'First aid' }
      ]
    },
    {
      id: 'e5',
      category: 'Backup Vendors',
      contacts: [
        { name: 'Backup DJ Service', phone: '+1 (555) 0230', available: 'On call', role: 'Entertainment backup' },
        { name: 'Backup Transportation', phone: '+1 (555) 0231', available: '24/7', role: 'Transport backup' }
      ]
    }
  ];

  const emergencyChecklists = {
    dress: [
      { item: 'Safety pins (assorted sizes)', status: 'packed', location: 'Bridal emergency kit' },
      { item: 'Sewing kit with white thread', status: 'packed', location: 'Bridal emergency kit' },
      { item: 'Stain remover wipes', status: 'packed', location: 'Bridal emergency kit' },
      { item: 'Clear nail polish (strap fix)', status: 'packed', location: 'Bridal emergency kit' },
      { item: 'Double-sided fashion tape', status: 'packed', location: 'Bridal emergency kit' },
      { item: 'Backup shoes (flats)', status: 'ready', location: 'Bridal suite closet' }
    ],
    weather: {
      plan: 'Indoor ceremony backup in Grand Ballroom',
      trigger: 'Rain forecast >40% or wind >20mph',
      decision: 'Final call by 10 AM day-of',
      coordinator: 'Wedding Planner + Venue Manager',
      status: 'Contingency ready'
    },
    medical: [
      { condition: 'Severe peanut allergy', person: 'Bridesmaid Jessica', medication: 'EpiPen in purse', location: 'Personal' },
      { condition: 'Migraine medication', person: 'Bride', medication: 'Sumatriptan', location: 'Bridal suite drawer' },
      { condition: 'Diabetes management', person: 'Father of Bride', medication: 'Insulin kit', location: 'Personal' }
    ]
  };

  return (
    <DndProvider backend={HTML5Backend}>
    <div>
      {/* Sticky Sub-Navigation */}
      <div className="sticky top-0 bg-gradient-to-r from-[#FEFDFB] to-white z-10 border-b border-gray-100 mb-6 pb-3">
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {[
            { id: 'overview', label: 'Overview' },
            { id: 'people', label: 'People' },
            { id: 'responsibilities', label: 'Responsibilities' },
            { id: 'buzzes', label: 'Buzzes' },
            { id: 'wedding-timeline', label: 'Wedding Timeline' },
            { id: 'travel', label: 'Travel' },
            { id: 'rehearsal', label: 'Rehearsal' },
            { id: 'emergency', label: 'Emergency' },
            { id: 'files-speeches', label: 'Files & Speeches' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as WeddingPartyTab)}
              className={`px-4 py-2 rounded-full text-[13px] whitespace-nowrap transition-all ${
                activeTab === tab.id
                  ? 'bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white shadow-md'
                  : 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
              }`}
              style={{ fontWeight: activeTab === tab.id ? 500 : 400 }}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* OVERVIEW TAB */}
      {activeTab === 'overview' && (
        <InteractiveOverviewTab
          readinessScore={readinessScore}
          responsibilities={responsibilities}
          travelData={travelData}
          buzzes={buzzes}
          people={people}
          onNavigateToTab={handleNavigateToTab}
          onNavigateToItem={handleNavigateToItem}
        />
      )}

      {activeTab === 'overview-old' && (
        <div className="space-y-6">
          {/* Hero Readiness Section */}
          <div className="bg-gradient-to-br from-[#FFF5F8] via-white to-[#F0F9FA] rounded-[32px] p-8 shadow-lg border border-[#FF88BA]/20">
            <div className="flex items-start justify-between mb-6">
              <div className="flex-1">
                <div className="text-[11px] text-[#FF3E9B] mb-2" style={{ fontWeight: 500, letterSpacing: '0.5px' }}>WEDDING PARTY READINESS</div>
                <h2 className="text-[32px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  {readinessScore}% Coordinated
                </h2>
                <p className="text-[14px] text-gray-600 leading-relaxed">
                  Transportation and final attire confirmations still require attention.
                </p>
              </div>
              <div className="relative w-24 h-24">
                <svg className="transform -rotate-90" width="96" height="96">
                  <circle
                    cx="48"
                    cy="48"
                    r="40"
                    stroke="#E8F3EC"
                    strokeWidth="8"
                    fill="none"
                  />
                  <circle
                    cx="48"
                    cy="48"
                    r="40"
                    stroke="#1F4D2B"
                    strokeWidth="8"
                    fill="none"
                    strokeDasharray={`${2 * Math.PI * 40}`}
                    strokeDashoffset={`${2 * Math.PI * 40 * (1 - readinessScore / 100)}`}
                    className="transition-all duration-1000"
                  />
                </svg>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-[20px] text-[#1F4D2B]" style={{ fontWeight: 600 }}>{readinessScore}%</span>
                </div>
              </div>
            </div>

            {/* Status Grid */}
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3 mb-6">
              {[
                { label: 'Hair & Makeup', status: 'Confirmed', color: '#1F4D2B', icon: '💇' },
                { label: 'Transportation', status: 'Awaiting 2 responses', color: '#FFB020', icon: '🚗' },
                { label: 'Speeches', status: '4 uploaded', color: '#3A8B95', icon: '🎤' },
                { label: 'Travel arrivals', status: '7 confirmed', color: '#1F4D2B', icon: '✈️' },
                { label: 'Dress fittings', status: 'Complete', color: '#1F4D2B', icon: '👗' },
                { label: 'Emergency kit', status: 'Assigned', color: '#3A8B95', icon: '🛠️' },
              ].map((item, idx) => (
                <div key={idx} className="bg-white/80 backdrop-blur-sm rounded-[16px] p-3 border border-gray-100 hover:shadow-md transition-all">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-[16px]">{item.icon}</span>
                    <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>{item.label}</div>
                  </div>
                  <div className="text-[13px] ml-6" style={{ color: item.color, fontWeight: 500 }}>{item.status}</div>
                </div>
              ))}
            </div>

            {/* Emotional & Stress Indicators */}
            <div className="grid grid-cols-3 gap-3">
              <div className="bg-gradient-to-br from-[#E8F3EC] to-white rounded-[16px] p-3 text-center">
                <div className="text-[11px] text-gray-600 mb-1">Stress Level</div>
                <div className="text-[18px] text-[#1F4D2B]" style={{ fontWeight: 600 }}>Low</div>
              </div>
              <div className="bg-gradient-to-br from-[#F0F9FA] to-white rounded-[16px] p-3 text-center">
                <div className="text-[11px] text-gray-600 mb-1">Pending Acks</div>
                <div className="text-[18px] text-[#3A8B95]" style={{ fontWeight: 600 }}>3</div>
              </div>
              <div className="bg-gradient-to-br from-[#FFF5F8] to-white rounded-[16px] p-3 text-center">
                <div className="text-[11px] text-gray-600 mb-1">Unread Buzzes</div>
                <div className="text-[18px] text-[#FF88BA]" style={{ fontWeight: 600 }}>2</div>
              </div>
            </div>
          </div>

          {/* Smart Operational Cards */}
          <div className="space-y-3">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-[18px] text-gray-900" style={{ fontWeight: 600 }}>Needs Attention</h3>
              <span className="text-[12px] text-gray-500">{operationalAlerts.length} items</span>
            </div>

            {operationalAlerts.map((alert) => {
              const isExpanded = expandedAlertId === alert.id;
              return (
                <div
                  key={alert.id}
                  className={`bg-white rounded-[20px] border transition-all ${
                    isExpanded ? 'border-[#FFB020] shadow-lg' : 'border-gray-100 shadow-sm hover:shadow-md'
                  }`}
                >
                  <button
                    onClick={() => setExpandedAlertId(isExpanded ? null : alert.id)}
                    className="w-full p-5 text-left"
                  >
                    <div className="flex items-start gap-4">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                        alert.urgency === 'high' ? 'bg-[#FFF5F8]' : 'bg-[#FFFBF0]'
                      }`}>
                        <AlertCircle size={20} className={alert.urgency === 'high' ? 'text-[#FF3E9B]' : 'text-[#FFB020]'} />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-start justify-between mb-2">
                          <h4 className="text-[15px] text-gray-900 pr-2" style={{ fontWeight: 600 }}>{alert.title}</h4>
                          <span className={`px-2 py-0.5 rounded-full text-[10px] whitespace-nowrap ${
                            alert.urgency === 'high'
                              ? 'bg-[#FFF5F8] text-[#FF3E9B]'
                              : 'bg-[#FFFBF0] text-[#FFB020]'
                          }`} style={{ fontWeight: 500 }}>
                            {alert.urgency === 'high' ? 'High priority' : 'Medium priority'}
                          </span>
                        </div>
                        <div className="flex items-center gap-2 text-[12px] text-gray-600">
                          <Users size={12} />
                          <span>{alert.linkedPeople.join(', ')}</span>
                        </div>
                      </div>
                      <ChevronRight
                        size={20}
                        className={`text-gray-400 transition-transform flex-shrink-0 ${isExpanded ? 'rotate-90' : ''}`}
                      />
                    </div>
                  </button>

                  {isExpanded && (
                    <div className="px-5 pb-5 space-y-3 animate-fadeIn">
                      <div className="p-3 bg-[#FAFAFA] rounded-[12px]">
                        <div className="text-[11px] text-gray-500 mb-1">Impact</div>
                        <div className="text-[13px] text-gray-900">{alert.impact}</div>
                      </div>
                      <div className="flex gap-2">
                        <button
                          onClick={() => setShowBuzzModal(true)}
                          className="flex-1 py-2.5 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[12px] text-[13px] flex items-center justify-center gap-2"
                          style={{ fontWeight: 500 }}
                        >
                          <Send size={14} />
                          {alert.action}
                        </button>
                        <button
                          onClick={() => {
                            setExpandedAlertId(null);
                            // In real app, would remove alert from list
                          }}
                          className="flex-1 py-2.5 border border-gray-200 text-gray-700 rounded-[12px] text-[13px] flex items-center justify-center gap-2 hover:bg-gray-50"
                          style={{ fontWeight: 500 }}
                        >
                          <Check size={14} />
                          Mark resolved
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Live Activity Feed */}
          <div className="bg-white rounded-[24px] p-6 shadow-sm border border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-[18px] text-gray-900" style={{ fontWeight: 600 }}>Recent Activity</h3>
              <button
                onClick={() => setShowActivityFeed(true)}
                className="text-[12px] text-[#3A8B95]" style={{ fontWeight: 500 }}
              >
                View all
              </button>
            </div>
            <div className="space-y-3">
              {activities.map((activity) => (
                <div key={activity.id} className="flex items-start gap-3 pb-3 border-b border-gray-50 last:border-0 hover:bg-gray-50 -mx-2 px-2 rounded-lg transition-colors">
                  <span className="text-[20px] flex-shrink-0">{activity.icon}</span>
                  <div className="flex-1 min-w-0">
                    <div className="text-[13px] text-gray-900">{activity.text}</div>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className="text-[11px] text-gray-500">{activity.time}</span>
                      <span className="text-[11px] text-gray-400">•</span>
                      <span className="text-[11px] text-[#3A8B95]">{activity.person}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Quick Action Panel */}
          <div className="bg-gradient-to-br from-white to-[#FAFAFA] rounded-[24px] p-6 shadow-sm border border-gray-100">
            <div className="text-[12px] text-gray-500 mb-4" style={{ fontWeight: 500 }}>QUICK ACTIONS</div>
            <div className="grid grid-cols-2 gap-3">
              {[
                { label: 'Send Buzz', icon: Send, color: '#FF3E9B', action: () => setShowBuzzModal(true) },
                { label: 'Assign Responsibility', icon: Check, color: '#3A8B95', action: () => setShowAssignTaskModal(true) },
                { label: 'Emergency Broadcast', icon: AlertCircle, color: '#FF3E9B', action: () => setShowEmergencyBroadcast(true) },
                { label: 'Add Party Member', icon: Plus, color: '#1F4D2B', action: () => setShowAddPersonModal(true) },
              ].map((action, idx) => {
                const Icon = action.icon;
                return (
                  <button
                    key={idx}
                    onClick={action.action}
                    className="flex items-center gap-3 p-4 rounded-[16px] border border-gray-100 hover:shadow-md hover:border-gray-200 transition-all bg-white"
                  >
                    <div
                      className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0"
                      style={{ backgroundColor: `${action.color}15` }}
                    >
                      <Icon size={18} style={{ color: action.color }} />
                    </div>
                    <span className="text-[14px] text-gray-900 text-left" style={{ fontWeight: 500 }}>{action.label}</span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* PEOPLE TAB - Enhanced with all 6 sections */}
      {activeTab === 'people' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Wedding Party
              </h3>
              <p className="text-[13px] text-gray-600">{people.length} people supporting your celebration</p>
            </div>
            <button
              onClick={() => setShowAddPersonModal(true)}
              className="px-4 py-2.5 bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white rounded-full text-[13px] flex items-center gap-2 shadow-md hover:shadow-lg transition-all"
              style={{ fontWeight: 500 }}
            >
              <Plus size={16} />
              Add Person
            </button>
          </div>

          {/* Search and Filter */}
          <div className="flex gap-3 mb-4">
            <div className="flex-1 relative">
              <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                value={peopleSearchQuery}
                onChange={(e) => setPeopleSearchQuery(e.target.value)}
                placeholder="Search wedding party..."
                className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-[16px] text-[14px] focus:outline-none focus:border-[#FF88BA]"
              />
            </div>
            <button
              onClick={() => setShowPeopleFilter(true)}
              className="px-4 py-2.5 border border-gray-200 rounded-[16px] text-[14px] text-gray-700 flex items-center gap-2 hover:bg-gray-50"
            >
              <Filter size={16} />
              Filter
            </button>
          </div>

          {/* Person Cards with Enhanced Profile */}
          <div className="space-y-4">
            {people
              .filter(p =>
                peopleSearchQuery === '' ||
                p.name.toLowerCase().includes(peopleSearchQuery.toLowerCase()) ||
                p.role.toLowerCase().includes(peopleSearchQuery.toLowerCase())
              )
              .map((person) => {
              const isExpanded = expandedPersonId === person.id;
              return (
                <div
                  key={person.id}
                  className={`bg-white rounded-[24px] border transition-all ${
                    isExpanded ? 'border-[#FF88BA] shadow-lg' : 'border-gray-100 shadow-sm'
                  }`}
                >
                  <button
                    onClick={() => setExpandedPersonId(isExpanded ? null : person.id)}
                    className="w-full p-6 text-left"
                  >
                    <div className="flex items-start gap-4">
                      <div className="w-16 h-16 rounded-full bg-gradient-to-br from-[#FF88BA] to-[#FF3E9B] flex items-center justify-center text-white text-[20px] flex-shrink-0" style={{ fontWeight: 600 }}>
                        {person.name.split(' ').map(n => n[0]).join('')}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between mb-2">
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 mb-1">
                              <h4 className="text-[18px] text-gray-900 truncate" style={{ fontWeight: 600 }}>{person.name}</h4>
                              {person.unreadUpdates > 0 && (
                                <span className="w-5 h-5 rounded-full bg-[#FF3E9B] text-white text-[10px] flex items-center justify-center flex-shrink-0" style={{ fontWeight: 600 }}>
                                  {person.unreadUpdates}
                                </span>
                              )}
                            </div>
                            <div className="flex items-center gap-2 mb-2 flex-wrap">
                              <span className="text-[13px] text-[#FF3E9B]" style={{ fontWeight: 500 }}>{person.role}</span>
                              <span className="text-[12px] text-gray-500">• {person.relationship}</span>
                            </div>
                            <div className="flex flex-wrap gap-2">
                              <span className={`px-2 py-0.5 rounded-full text-[11px] ${
                                person.travelStatus === 'confirmed'
                                  ? 'bg-[#E8F3EC] text-[#1F4D2B]'
                                  : 'bg-[#FFF5F8] text-[#FF88BA]'
                              }`} style={{ fontWeight: 500 }}>
                                {person.travelStatus === 'confirmed' ? 'Travel confirmed' : 'Needs response'}
                              </span>
                              <span className={`px-2 py-0.5 rounded-full text-[11px] ${
                                person.attireStatus === 'complete'
                                  ? 'bg-[#F0F9FA] text-[#3A8B95]'
                                  : 'bg-[#FFFBF0] text-[#FFB020]'
                              }`} style={{ fontWeight: 500 }}>
                                {person.attireStatus === 'complete' ? 'Attire complete' : 'Needs fitting'}
                              </span>
                              {person.pendingTasks > 0 && (
                                <span className="px-2 py-0.5 bg-[#FFF5F8] text-[#FF3E9B] rounded-full text-[11px]" style={{ fontWeight: 500 }}>
                                  {person.pendingTasks} tasks
                                </span>
                              )}
                            </div>
                          </div>
                          <ChevronRight
                            size={20}
                            className={`text-gray-400 transition-transform flex-shrink-0 ml-2 ${isExpanded ? 'rotate-90' : ''}`}
                          />
                        </div>
                      </div>
                    </div>
                  </button>

                  {isExpanded && (
                    <div className="px-6 pb-6 space-y-4 animate-fadeIn">
                      {/* SECTION 1 - Identity */}
                      <div className="bg-[#FAFAFA] rounded-[20px] p-4">
                        <div className="text-[12px] text-gray-500 mb-3" style={{ fontWeight: 500 }}>IDENTITY</div>
                        <div className="space-y-2">
                          {person.nickname && (
                            <div className="flex items-center justify-between text-[13px]">
                              <span className="text-gray-600">Nickname</span>
                              <span className="text-gray-900" style={{ fontWeight: 500 }}>{person.nickname}</span>
                            </div>
                          )}
                          {person.pronouns && (
                            <div className="flex items-center justify-between text-[13px]">
                              <span className="text-gray-600">Pronouns</span>
                              <span className="text-gray-900" style={{ fontWeight: 500 }}>{person.pronouns}</span>
                            </div>
                          )}
                          <div className="flex items-center justify-between text-[13px]">
                            <span className="text-gray-600">Relationship</span>
                            <span className="text-gray-900" style={{ fontWeight: 500 }}>{person.relationship}</span>
                          </div>
                        </div>
                      </div>

                      {/* SECTION 2 - Communication */}
                      <div className="bg-[#FAFAFA] rounded-[20px] p-4">
                        <div className="text-[12px] text-gray-500 mb-3" style={{ fontWeight: 500 }}>CONTACT & COMMUNICATION</div>
                        <div className="space-y-3 mb-4">
                          <div className="flex items-center justify-between">
                            <div>
                              <div className="text-[11px] text-gray-500">Phone</div>
                              <div className="text-[14px] text-gray-900" style={{ fontWeight: 500 }}>{person.phone}</div>
                            </div>
                            <div className="flex gap-2">
                              <button className="w-8 h-8 rounded-full bg-white border border-gray-200 flex items-center justify-center hover:bg-[#25D366] hover:text-white hover:border-[#25D366] transition-all">
                                <MessageSquare size={14} />
                              </button>
                              <button className="w-8 h-8 rounded-full bg-white border border-gray-200 flex items-center justify-center hover:bg-[#3A8B95] hover:text-white hover:border-[#3A8B95] transition-all">
                                <Phone size={14} />
                              </button>
                            </div>
                          </div>
                          <div className="flex items-center justify-between">
                            <div>
                              <div className="text-[11px] text-gray-500">Email</div>
                              <div className="text-[14px] text-gray-900" style={{ fontWeight: 500 }}>{person.email}</div>
                            </div>
                            <button className="w-8 h-8 rounded-full bg-white border border-gray-200 flex items-center justify-center hover:bg-[#3A8B95] hover:text-white hover:border-[#3A8B95] transition-all">
                              <Mail size={14} />
                            </button>
                          </div>
                          <div className="pt-2 border-t border-gray-200">
                            <div className="text-[11px] text-gray-500 mb-1">Preferred contact</div>
                            <div className="text-[13px] text-[#FF3E9B]" style={{ fontWeight: 500 }}>{person.preferredContact}</div>
                          </div>
                          <div className="flex items-center gap-2">
                            <div className={`w-2 h-2 rounded-full ${
                              person.responsiveness === 'high' ? 'bg-[#1F4D2B]' : 'bg-[#FFB020]'
                            }`}></div>
                            <span className="text-[12px] text-gray-600">
                              {person.responsiveness === 'high' ? 'Highly responsive' : 'Medium responsiveness'}
                            </span>
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <button className="flex-1 py-2.5 bg-gradient-to-r from-[#25D366] to-[#20BA5A] text-white rounded-[12px] text-[13px] flex items-center justify-center gap-2 shadow-sm hover:shadow-md transition-all" style={{ fontWeight: 500 }}>
                            <MessageSquare size={14} />
                            WhatsApp
                          </button>
                          <button className="flex-1 py-2.5 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[12px] text-[13px] flex items-center justify-center gap-2 shadow-sm hover:shadow-md transition-all" style={{ fontWeight: 500 }}>
                            <Send size={14} />
                            Send Buzz
                          </button>
                        </div>
                      </div>

                      {/* SECTION 3 - Logistics */}
                      <div className="bg-[#F0F9FA] rounded-[20px] p-4">
                        <div className="text-[12px] text-gray-500 mb-3" style={{ fontWeight: 500 }}>LOGISTICS</div>
                        <div className="grid grid-cols-2 gap-3">
                          <div>
                            <div className="text-[11px] text-gray-500 mb-1">Location</div>
                            <div className="text-[13px] text-gray-900" style={{ fontWeight: 500 }}>{person.location}</div>
                            <div className="text-[11px] text-gray-500 mt-0.5">{person.timezone}</div>
                          </div>
                          {person.arrival && (
                            <div>
                              <div className="text-[11px] text-gray-500 mb-1">Arrival</div>
                              <div className="text-[13px] text-gray-900" style={{ fontWeight: 500 }}>{person.arrival}</div>
                              {person.flightNumber && (
                                <div className="text-[11px] text-[#3A8B95] mt-0.5">{person.flightNumber}</div>
                              )}
                            </div>
                          )}
                          {person.hotel && (
                            <div>
                              <div className="text-[11px] text-gray-500 mb-1">Accommodation</div>
                              <div className="text-[13px] text-[#FF3E9B]" style={{ fontWeight: 500 }}>{person.hotel}</div>
                            </div>
                          )}
                          {person.dietaryRestrictions && (
                            <div>
                              <div className="text-[11px] text-gray-500 mb-1">Dietary</div>
                              <div className="text-[13px] text-gray-900" style={{ fontWeight: 500 }}>{person.dietaryRestrictions}</div>
                            </div>
                          )}
                          {person.allergies && (
                            <div className="col-span-2 p-2 bg-[#FFF5F8] rounded-lg">
                              <div className="text-[11px] text-[#FF3E9B] mb-1" style={{ fontWeight: 500 }}>⚠️ Allergies</div>
                              <div className="text-[12px] text-gray-900">{person.allergies}</div>
                            </div>
                          )}
                        </div>
                      </div>

                      {/* SECTION 4 - Wedding Tasks */}
                      <div>
                        <div className="text-[12px] text-gray-500 mb-2" style={{ fontWeight: 500 }}>RESPONSIBILITIES</div>
                        <div className="flex flex-wrap gap-2">
                          {person.responsibilities.map((resp, idx) => (
                            <span
                              key={idx}
                              className="px-3 py-1.5 bg-white border border-gray-200 text-[#3A8B95] rounded-full text-[12px]"
                              style={{ fontWeight: 500 }}
                            >
                              {resp}
                            </span>
                          ))}
                        </div>
                        {person.pendingTasks > 0 && (
                          <div className="mt-2 text-[12px] text-[#FF3E9B]" style={{ fontWeight: 500 }}>
                            {person.pendingTasks} pending task{person.pendingTasks > 1 ? 's' : ''}
                          </div>
                        )}
                      </div>

                      {/* SECTION 5 - Attire */}
                      <div className="bg-[#FFF5F8] rounded-[20px] p-4">
                        <div className="text-[12px] text-gray-500 mb-3" style={{ fontWeight: 500 }}>ATTIRE STATUS</div>
                        <div className="flex items-center justify-between">
                          <span className="text-[14px] text-gray-900" style={{ fontWeight: 500 }}>
                            {person.attireStatus === 'complete' ? 'All set ✓' : 'Needs final fitting'}
                          </span>
                          <button
                            onClick={() => setShowAttireDetail(person.id)}
                            className="text-[13px] text-[#FF3E9B]" style={{ fontWeight: 500 }}
                          >
                            View details →
                          </button>
                        </div>
                      </div>

                      {/* Emergency Contact */}
                      <div className="p-3 bg-white rounded-[16px] border border-gray-200">
                        <div className="text-[11px] text-gray-500 mb-1">Emergency Contact</div>
                        <div className="text-[13px] text-gray-900" style={{ fontWeight: 500 }}>{person.emergencyContact}</div>
                      </div>

                      {/* Private Notes */}
                      <div className="p-3 bg-[#FFFBF0] rounded-[16px] border border-[#FFB020]/20">
                        <div className="text-[11px] text-gray-500 mb-1">Private Notes</div>
                        <div className="text-[13px] text-gray-700 italic">{person.notes}</div>
                      </div>

                      {/* Action Buttons */}
                      <div className="grid grid-cols-3 gap-2 pt-2">
                        <button
                          onClick={() => setShowAssignTaskModal(true)}
                          className="py-2 px-3 border border-gray-200 rounded-[12px] text-[12px] text-gray-700 hover:bg-gray-50 transition-colors"
                        >
                          Assign task
                        </button>
                        <button
                          onClick={() => setShowAddNoteModal(person.id)}
                          className="py-2 px-3 border border-gray-200 rounded-[12px] text-[12px] text-gray-700 hover:bg-gray-50 transition-colors"
                        >
                          Add note
                        </button>
                        <button
                          onClick={() => setShowUploadModal(person.id)}
                          className="py-2 px-3 border border-gray-200 rounded-[12px] text-[12px] text-gray-700 hover:bg-gray-50 transition-colors"
                        >
                          Upload files
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* RESPONSIBILITIES TAB - With view toggles */}
      {activeTab === 'responsibilities' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Responsibilities
              </h3>
              <p className="text-[13px] text-gray-600">Wedding party task coordination</p>
            </div>
            <div className="flex items-center gap-2 px-3 py-1.5 bg-[#E8F3EC] rounded-full">
              <TrendingUp size={14} className="text-[#1F4D2B]" />
              <span className="text-[12px] text-[#1F4D2B]" style={{ fontWeight: 500 }}>Health: Excellent</span>
            </div>
          </div>

          {/* View Mode Toggles */}
          <div className="flex gap-2 overflow-x-auto pb-2">
            {[
              { id: 'checklist', label: 'Checklist', icon: Check },
              { id: 'kanban', label: 'Kanban', icon: LayoutGrid },
              { id: 'timeline', label: 'Timeline', icon: Calendar },
              { id: 'priority', label: 'Priority', icon: Flag },
              { id: 'person', label: 'By Person', icon: User },
            ].map((view) => {
              const Icon = view.icon;
              return (
                <button
                  key={view.id}
                  onClick={() => setResponsibilitiesView(view.id as ViewMode)}
                  className={`px-4 py-2 rounded-full text-[13px] whitespace-nowrap transition-all flex items-center gap-2 ${
                    responsibilitiesView === view.id
                      ? 'bg-[#3A8B95] text-white shadow-md'
                      : 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
                  }`}
                  style={{ fontWeight: responsibilitiesView === view.id ? 500 : 400 }}
                >
                  <Icon size={14} />
                  {view.label}
                </button>
              );
            })}
          </div>

          {/* Responsibility Cards */}
          <div className="space-y-3">
            {responsibilities.map((task) => (
              <div
                key={task.id}
                className="bg-white rounded-[20px] p-5 border border-gray-100 shadow-sm hover:shadow-md transition-all"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <h4 className="text-[15px] text-gray-900" style={{ fontWeight: 600 }}>{task.title}</h4>
                      {task.status === 'completed' && <Check size={16} className="text-[#1F4D2B]" />}
                      {task.status === 'needs-help' && <AlertCircle size={16} className="text-[#FF3E9B]" />}
                    </div>
                    <div className="flex items-center gap-2 text-[12px] text-gray-600 mb-2">
                      <User size={12} />
                      <span>{task.owner}</span>
                      {task.backupOwner && (
                        <>
                          <span>•</span>
                          <span className="text-gray-500">Backup: {task.backupOwner}</span>
                        </>
                      )}
                    </div>
                  </div>
                  <span
                    className={`px-3 py-1 rounded-full text-[11px] whitespace-nowrap ${
                      task.status === 'completed'
                        ? 'bg-[#E8F3EC] text-[#1F4D2B]'
                        : task.status === 'in-progress'
                        ? 'bg-[#F0F9FA] text-[#3A8B95]'
                        : task.status === 'needs-help'
                        ? 'bg-[#FFF5F8] text-[#FF3E9B]'
                        : 'bg-[#FAFAFA] text-gray-600'
                    }`}
                    style={{ fontWeight: 500 }}
                  >
                    {task.status.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-2 text-[12px] mb-3">
                  <div className="flex items-center gap-2">
                    <Clock size={12} className="text-gray-400" />
                    <span className="text-gray-700">{task.dueTime}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPin size={12} className="text-gray-400" />
                    <span className="text-gray-700">{task.location}</span>
                  </div>
                </div>

                {task.dependencies && task.dependencies.length > 0 && (
                  <div className="p-2 bg-[#FFFBF0] rounded-lg text-[11px] text-gray-600 mb-3">
                    <span className="text-[#FFB020]" style={{ fontWeight: 500 }}>⚠️ Depends on:</span> {task.dependencies.join(', ')}
                  </div>
                )}

                <div className="text-[13px] text-gray-600 mb-3">{task.description}</div>

                <div className="flex items-center gap-2">
                  <span
                    className={`px-2 py-1 rounded-full text-[10px] ${
                      task.urgency === 'high'
                        ? 'bg-[#FFF5F8] text-[#FF3E9B]'
                        : task.urgency === 'medium'
                        ? 'bg-[#FFFBF0] text-[#FFB020]'
                        : 'bg-[#F0F9FA] text-[#3A8B95]'
                    }`}
                    style={{ fontWeight: 500 }}
                  >
                    {task.urgency.charAt(0).toUpperCase() + task.urgency.slice(1)} priority
                  </span>
                  {task.status !== 'completed' && (
                    <button
                      onClick={() => setShowTaskDetail(task.id)}
                      className="ml-auto text-[12px] text-[#3A8B95]" style={{ fontWeight: 500 }}
                    >
                      Update status →
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* BUZZES TAB - Enhanced with tracking */}
      {activeTab === 'buzzes' && (
        <InteractiveBuzzesTab
          buzzes={buzzes}
          people={people}
          onSendBuzz={handleSendBuzz}
        />
      )}

      {/* TIMELINE TAB */}
      {activeTab === 'timeline' && (
        <div className="space-y-6">
          <div>
            <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
              Wedding Timeline
            </h3>
            <p className="text-[13px] text-gray-600">Operational scheduling engine</p>
          </div>

          {/* Timeline Type Selector */}
          <div className="flex gap-2 overflow-x-auto pb-2">
            {[
              'wedding-morning',
              'ceremony',
              'reception',
              'transport',
              'beauty-schedules'
            ].map((type) => (
              <button
                key={type}
                onClick={() => setSelectedTimelineType(type)}
                className={`px-4 py-2 rounded-full text-[13px] whitespace-nowrap transition-all ${
                  selectedTimelineType === type
                    ? 'bg-[#3A8B95] text-white shadow-md'
                    : 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
                }`}
                style={{ fontWeight: selectedTimelineType === type ? 500 : 400 }}
              >
                {type.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
              </button>
            ))}
          </div>

          {/* Timeline Events */}
          <div className="space-y-4">
            {[
              { time: '8:00 AM', event: 'Bride breakfast', owner: 'Emily Rodriguez', location: 'Bridal suite', status: 'upcoming' },
              { time: '9:00 AM', event: 'Hair begins', owner: 'Hair stylist', location: 'Bridal suite', dependencies: ['Breakfast complete'], status: 'upcoming' },
              { time: '11:00 AM', event: 'Makeup begins', owner: 'Makeup artist', location: 'Bridal suite', dependencies: ['Hair complete'], status: 'upcoming' },
              { time: '2:00 PM', event: 'Photography prep', owner: 'Photographer', location: 'Venue', status: 'upcoming' },
            ].map((item, idx) => (
              <div key={idx} className="relative">
                {idx < 3 && (
                  <div className="absolute left-6 top-16 w-0.5 h-8 bg-gradient-to-b from-[#3A8B95] to-transparent"></div>
                )}
                <div className="bg-white rounded-[20px] p-5 border border-gray-100 shadow-sm hover:shadow-md transition-all">
                  <div className="flex items-start gap-4">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#F0F9FA] to-[#E8F3EC] flex items-center justify-center flex-shrink-0">
                      <span className="text-[13px] text-[#3A8B95]" style={{ fontWeight: 600 }}>{item.time}</span>
                    </div>
                    <div className="flex-1">
                      <h4 className="text-[16px] text-gray-900 mb-1" style={{ fontWeight: 600 }}>{item.event}</h4>
                      <div className="flex items-center gap-2 text-[12px] text-gray-600 mb-2">
                        <User size={12} />
                        <span>{item.owner}</span>
                        <span>•</span>
                        <MapPin size={12} />
                        <span>{item.location}</span>
                      </div>
                      {item.dependencies && (
                        <div className="text-[11px] text-[#FFB020] italic">
                          Depends on: {item.dependencies.join(', ')}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* TRAVEL TAB */}
      {activeTab === 'travel' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Travel Coordination
              </h3>
              <p className="text-[13px] text-gray-600">Manage arrivals, accommodations, and transportation</p>
            </div>
            <div className="flex items-center gap-3 bg-white rounded-xl border border-gray-200 p-1.5">
              <button
                onClick={() => setIsDestinationWedding(false)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  !isDestinationWedding ? 'bg-[#FF3E9B] text-white' : 'text-gray-600'
                }`}
              >
                Local Wedding
              </button>
              <button
                onClick={() => setIsDestinationWedding(true)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  isDestinationWedding ? 'bg-[#FF3E9B] text-white' : 'text-gray-600'
                }`}
              >
                Destination Wedding
              </button>
            </div>
          </div>

          {/* Summary Cards */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-gradient-to-br from-blue-50 to-white rounded-xl p-4 border border-blue-100">
              <div className="text-sm text-gray-600 mb-1">Total Travelers</div>
              <div className="text-2xl font-bold text-blue-600">{travelData.length}</div>
            </div>
            <div className="bg-gradient-to-br from-green-50 to-white rounded-xl p-4 border border-green-100">
              <div className="text-sm text-gray-600 mb-1">Confirmed</div>
              <div className="text-2xl font-bold text-green-600">
                {travelData.filter(t => t.transferStatus === 'Confirmed').length}
              </div>
            </div>
            <div className="bg-gradient-to-br from-amber-50 to-white rounded-xl p-4 border border-amber-100">
              <div className="text-sm text-gray-600 mb-1">Pending</div>
              <div className="text-2xl font-bold text-amber-600">
                {travelData.filter(t => t.transferStatus === 'Needs confirmation').length}
              </div>
            </div>
            <div className="bg-gradient-to-br from-purple-50 to-white rounded-xl p-4 border border-purple-100">
              <div className="text-sm text-gray-600 mb-1">Payment Pending</div>
              <div className="text-2xl font-bold text-purple-600">
                {travelData.filter(t => t.paymentStatus === 'Pending').length}
              </div>
            </div>
          </div>

          {/* Travel Cards */}
          <div className="space-y-4">
            {travelData.map((travel) => (
              <div
                key={travel.id}
                className="bg-white rounded-2xl border-2 border-gray-200 p-6 hover:border-[#FF3E9B] transition-all cursor-pointer"
                onClick={() => setSelectedTravelPerson(travel.id)}
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-gradient-to-br from-[#FF88BA] to-[#FF3E9B] rounded-full flex items-center justify-center text-white font-semibold">
                      {travel.person.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div>
                      <h4 className="text-lg font-semibold text-gray-900">{travel.person}</h4>
                      <p className="text-sm text-gray-600">{travel.role}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {travel.delay && (
                      <span className="px-3 py-1 bg-red-100 text-red-700 text-xs rounded-full font-medium flex items-center gap-1">
                        <AlertCircle size={12} />
                        {travel.delay}
                      </span>
                    )}
                    <span className={`px-3 py-1 text-xs rounded-full font-medium ${
                      travel.transferStatus === 'Confirmed' ? 'bg-green-100 text-green-700' :
                      'bg-amber-100 text-amber-700'
                    }`}>
                      {travel.transferStatus}
                    </span>
                  </div>
                </div>

                {isDestinationWedding ? (
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-3">
                      <div>
                        <div className="text-xs text-gray-500 mb-1">ARRIVAL</div>
                        <div className="flex items-center gap-2 text-sm">
                          <Plane size={14} className="text-[#FF3E9B]" />
                          <span className="font-medium">{travel.flightNumber}</span>
                          <span className="text-gray-600">• {travel.arrivalTime}</span>
                        </div>
                        <div className="text-xs text-gray-600 mt-1">{travel.arrivalDate}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-500 mb-1">ACCOMMODATION</div>
                        <div className="flex items-center gap-2 text-sm">
                          <Hotel size={14} className="text-[#FF3E9B]" />
                          <span className="font-medium">{travel.hotel}</span>
                        </div>
                        <div className="text-xs text-gray-600 mt-1">Roommate: {travel.roommate}</div>
                      </div>
                    </div>
                    <div className="space-y-3">
                      <div>
                        <div className="text-xs text-gray-500 mb-1">SHUTTLE</div>
                        <div className="text-sm font-medium">{travel.shuttleGroup}</div>
                        <div className="text-xs text-gray-600 mt-1">Coordinator: {travel.coordinator}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-500 mb-1">PAYMENT</div>
                        <div className="flex items-center gap-2">
                          <span className={`px-2 py-1 text-xs rounded-full ${
                            travel.paymentStatus === 'Paid' ? 'bg-green-100 text-green-700' :
                            'bg-amber-100 text-amber-700'
                          }`}>
                            {travel.paymentStatus}
                          </span>
                          <span className="text-xs text-gray-600">{travel.confirmationCode}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="grid grid-cols-3 gap-4">
                    <div>
                      <div className="text-xs text-gray-500 mb-1">ARRIVAL</div>
                      <div className="flex items-center gap-2 text-sm">
                        <Clock size={14} className="text-[#FF3E9B]" />
                        <span className="font-medium">{travel.arrivalTime}</span>
                      </div>
                    </div>
                    <div>
                      <div className="text-xs text-gray-500 mb-1">TRANSPORT</div>
                      <div className="text-sm font-medium">{travel.shuttleGroup}</div>
                    </div>
                    <div>
                      <div className="text-xs text-gray-500 mb-1">COORDINATOR</div>
                      <div className="text-sm font-medium">{travel.coordinator}</div>
                    </div>
                  </div>
                )}

                {travel.notes && (
                  <div className="mt-4 pt-4 border-t border-gray-200">
                    <div className="text-xs text-gray-500 mb-1">NOTES</div>
                    <div className="text-sm text-gray-700">{travel.notes}</div>
                  </div>
                )}

                <div className="mt-4 flex items-center gap-2">
                  <button className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 flex items-center gap-2">
                    <Phone size={14} />
                    Call {travel.emergencyContact}
                  </button>
                  <button className="px-4 py-2 bg-green-600 text-white rounded-lg text-sm hover:bg-green-700 flex items-center gap-2">
                    <MessageSquare size={14} />
                    Send Update
                  </button>
                  <button className="px-4 py-2 bg-purple-600 text-white rounded-lg text-sm hover:bg-purple-700 flex items-center gap-2">
                    <Edit size={14} />
                    Edit Details
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Quick Actions */}
          <div className="bg-gradient-to-br from-[#FAFAFA] to-white rounded-2xl p-6 border border-gray-200">
            <h4 className="font-semibold text-gray-900 mb-4">Quick Actions</h4>
            <div className="grid grid-cols-3 gap-3">
              <button className="px-4 py-3 bg-white border-2 border-gray-200 rounded-xl hover:border-[#FF3E9B] transition-all text-sm font-medium">
                Send Travel Reminder to All
              </button>
              <button className="px-4 py-3 bg-white border-2 border-gray-200 rounded-xl hover:border-[#FF3E9B] transition-all text-sm font-medium">
                Export Travel Schedule
              </button>
              <button className="px-4 py-3 bg-white border-2 border-gray-200 rounded-xl hover:border-[#FF3E9B] transition-all text-sm font-medium">
                Add New Traveler
              </button>
            </div>
          </div>
        </div>
      )}

      {/* REHEARSAL TAB */}
      {activeTab === 'rehearsal' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Rehearsal Coordination
              </h3>
              <p className="text-[13px] text-gray-600">June 14, 2026 • Garden Ceremony Site</p>
            </div>
            <button className="px-6 py-2.5 bg-[#FF3E9B] text-white rounded-xl hover:bg-[#e63587] transition-colors flex items-center gap-2">
              <Bell size={18} />
              Send Rehearsal Reminder
            </button>
          </div>

          {/* Attendance Summary */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-gradient-to-br from-green-50 to-white rounded-xl p-4 border border-green-100">
              <div className="text-sm text-gray-600 mb-1">Confirmed</div>
              <div className="text-2xl font-bold text-green-600">
                {rehearsalAttendees.filter(a => a.status === 'confirmed').length}
              </div>
            </div>
            <div className="bg-gradient-to-br from-amber-50 to-white rounded-xl p-4 border border-amber-100">
              <div className="text-sm text-gray-600 mb-1">Pending</div>
              <div className="text-2xl font-bold text-amber-600">
                {rehearsalAttendees.filter(a => a.status === 'pending').length}
              </div>
            </div>
            <div className="bg-gradient-to-br from-purple-50 to-white rounded-xl p-4 border border-purple-100">
              <div className="text-sm text-gray-600 mb-1">Speeches</div>
              <div className="text-2xl font-bold text-purple-600">
                {rehearsalAttendees.filter(a => a.speech).length}
              </div>
            </div>
            <div className="bg-gradient-to-br from-blue-50 to-white rounded-xl p-4 border border-blue-100">
              <div className="text-sm text-gray-600 mb-1">Total Attendees</div>
              <div className="text-2xl font-bold text-blue-600">{rehearsalAttendees.length}</div>
            </div>
          </div>

          {/* Rehearsal Schedule */}
          <div className="bg-white rounded-2xl border-2 border-gray-200 p-6">
            <h4 className="text-lg font-semibold text-gray-900 mb-4">Rehearsal Schedule</h4>
            <div className="space-y-4">
              {rehearsalSchedule.map((item) => (
                <div
                  key={item.id}
                  className="border-l-4 border-[#FF3E9B] pl-6 pb-6 relative cursor-pointer hover:bg-gray-50 -ml-6 -mr-6 px-6 py-4 rounded-lg transition-colors"
                  onClick={() => setSelectedRehearsalItem(item)}
                >
                  <div className="absolute left-0 top-4 w-3 h-3 bg-[#FF3E9B] rounded-full -translate-x-[8.5px]"></div>
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <div className="flex items-center gap-3 mb-2">
                        <span className="text-lg font-bold text-[#FF3E9B]">{item.time}</span>
                        <h5 className="text-base font-semibold text-gray-900">{item.title}</h5>
                        <span className={`px-2.5 py-1 text-xs rounded-full font-medium ${
                          item.status === 'confirmed' ? 'bg-green-100 text-green-700' :
                          item.status === 'pending' ? 'bg-amber-100 text-amber-700' :
                          'bg-gray-100 text-gray-700'
                        }`}>
                          {item.status}
                        </span>
                      </div>
                      <div className="flex items-center gap-4 text-sm text-gray-600">
                        <span className="flex items-center gap-1">
                          <MapPin size={14} />
                          {item.location}
                        </span>
                        <span className="flex items-center gap-1">
                          <User size={14} />
                          {item.coordinator}
                        </span>
                      </div>
                    </div>
                  </div>
                  <div className="mb-3">
                    <div className="text-xs text-gray-500 mb-2">ATTENDEES</div>
                    <div className="flex flex-wrap gap-2">
                      {item.attendees.map((attendee, idx) => (
                        <span key={idx} className="px-3 py-1 bg-blue-50 text-blue-700 text-xs rounded-full">
                          {attendee}
                        </span>
                      ))}
                    </div>
                  </div>
                  {item.order && (
                    <div className="mb-3">
                      <div className="text-xs text-gray-500 mb-2">PROCESSIONAL ORDER</div>
                      <div className="flex flex-wrap gap-2">
                        {item.order.map((role, idx) => (
                          <span key={idx} className="px-3 py-1 bg-purple-50 text-purple-700 text-xs rounded-full">
                            {idx + 1}. {role}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}
                  {item.notes && (
                    <div className="text-sm text-gray-600 italic">{item.notes}</div>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Attendees List */}
          <div className="bg-white rounded-2xl border-2 border-gray-200 p-6">
            <h4 className="text-lg font-semibold text-gray-900 mb-4">Attendees & Confirmations</h4>
            <div className="space-y-3">
              {rehearsalAttendees.map((attendee) => (
                <div key={attendee.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 bg-gradient-to-br from-[#FF88BA] to-[#FF3E9B] rounded-full flex items-center justify-center text-white font-semibold text-sm">
                      {attendee.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    <div>
                      <div className="font-medium text-gray-900">{attendee.name}</div>
                      <div className="text-sm text-gray-600">{attendee.role}</div>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="text-sm text-gray-600">{attendee.transport}</div>
                    {attendee.speech && (
                      <span className="px-2.5 py-1 bg-purple-100 text-purple-700 text-xs rounded-full">
                        Speech
                      </span>
                    )}
                    <span className={`px-3 py-1 text-xs rounded-full font-medium ${
                      attendee.status === 'confirmed' ? 'bg-green-100 text-green-700' :
                      'bg-amber-100 text-amber-700'
                    }`}>
                      {attendee.status}
                    </span>
                    <button className="px-3 py-1.5 bg-blue-600 text-white rounded-lg text-xs hover:bg-blue-700">
                      Contact
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Rehearsal Dinner */}
          <div className="bg-gradient-to-br from-amber-50 to-white rounded-2xl p-6 border-2 border-amber-100">
            <div className="flex items-center gap-3 mb-4">
              <Utensils size={24} className="text-amber-600" />
              <div>
                <h4 className="text-lg font-semibold text-gray-900">Rehearsal Dinner</h4>
                <p className="text-sm text-gray-600">7:30 PM • Terrace Garden</p>
              </div>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <div className="text-xs text-gray-500 mb-1">MENU</div>
                <div className="text-sm font-medium">Italian Family Style</div>
              </div>
              <div>
                <div className="text-xs text-gray-500 mb-1">EXPECTED GUESTS</div>
                <div className="text-sm font-medium">{rehearsalAttendees.length} people</div>
              </div>
              <div>
                <div className="text-xs text-gray-500 mb-1">COORDINATOR</div>
                <div className="text-sm font-medium">Catering Team</div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* EMERGENCY TAB */}
      {activeTab === 'emergency' && (
        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                Emergency Coordination
              </h3>
              <p className="text-[13px] text-gray-600">Calm, prepared, and ready to support you</p>
            </div>
            <button
              onClick={() => setShowEmergencyBroadcastModal(true)}
              className="px-6 py-2.5 bg-gradient-to-r from-red-600 to-red-500 text-white rounded-xl hover:shadow-lg transition-all flex items-center gap-2"
            >
              <Bell size={18} />
              Emergency Broadcast
            </button>
          </div>

          {/* Quick Access Cards */}
          <div className="grid grid-cols-3 gap-4">
            <button className="bg-gradient-to-br from-blue-50 to-white p-6 rounded-2xl border-2 border-blue-100 hover:border-blue-300 transition-all text-left">
              <Phone size={24} className="text-blue-600 mb-3" />
              <div className="text-lg font-semibold text-gray-900 mb-1">Wedding Planner</div>
              <div className="text-2xl font-bold text-blue-600">+1 (555) 0200</div>
              <div className="text-xs text-gray-600 mt-2">Available 24/7</div>
            </button>
            <button className="bg-gradient-to-br from-green-50 to-white p-6 rounded-2xl border-2 border-green-100 hover:border-green-300 transition-all text-left">
              <MapPin size={24} className="text-green-600 mb-3" />
              <div className="text-lg font-semibold text-gray-900 mb-1">Venue Manager</div>
              <div className="text-2xl font-bold text-green-600">+1 (555) 0210</div>
              <div className="text-xs text-gray-600 mt-2">8 AM - 10 PM</div>
            </button>
            <button className="bg-gradient-to-br from-red-50 to-white p-6 rounded-2xl border-2 border-red-100 hover:border-red-300 transition-all text-left">
              <Shield size={24} className="text-red-600 mb-3" />
              <div className="text-lg font-semibold text-gray-900 mb-1">Medical Emergency</div>
              <div className="text-2xl font-bold text-red-600">911</div>
              <div className="text-xs text-gray-600 mt-2">Emergency services</div>
            </button>
          </div>

          {/* Emergency Contacts */}
          <div className="space-y-4">
            {emergencyContacts.map((category) => (
              <div key={category.id} className="bg-white rounded-2xl border-2 border-gray-200 p-6">
                <h4 className="text-lg font-semibold text-gray-900 mb-4">{category.category}</h4>
                <div className="space-y-3">
                  {category.contacts.map((contact, idx) => (
                    <div key={idx} className="flex items-center justify-between p-4 bg-gray-50 rounded-xl hover:bg-gray-100 transition-colors">
                      <div className="flex-1">
                        <div className="font-medium text-gray-900">{contact.name}</div>
                        <div className="text-sm text-gray-600">{contact.role}</div>
                        <div className="text-xs text-gray-500 mt-1">Available: {contact.available}</div>
                      </div>
                      <div className="flex items-center gap-3">
                        <div className="text-right">
                          <div className="font-mono text-lg font-semibold text-[#FF3E9B]">{contact.phone}</div>
                        </div>
                        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
                          <Phone size={16} />
                          Call
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>

          {/* Emergency Checklists */}
          <div className="grid grid-cols-2 gap-6">
            {/* Dress Emergency Kit */}
            <div className="bg-gradient-to-br from-pink-50 to-white rounded-2xl p-6 border-2 border-pink-100">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 bg-pink-200 rounded-full flex items-center justify-center">
                  ✨
                </div>
                <h4 className="text-lg font-semibold text-gray-900">Dress Emergency Kit</h4>
              </div>
              <div className="space-y-2">
                {emergencyChecklists.dress.map((item, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-lg">
                    <div className="flex items-center gap-3">
                      <Check size={16} className="text-green-600" />
                      <span className="text-sm text-gray-900">{item.item}</span>
                    </div>
                    <span className="text-xs text-gray-500">{item.location}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Weather Contingency */}
            <div className="bg-gradient-to-br from-blue-50 to-white rounded-2xl p-6 border-2 border-blue-100">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 bg-blue-200 rounded-full flex items-center justify-center">
                  ☂️
                </div>
                <h4 className="text-lg font-semibold text-gray-900">Weather Contingency</h4>
              </div>
              <div className="space-y-3">
                <div>
                  <div className="text-xs text-gray-500 mb-1">BACKUP PLAN</div>
                  <div className="text-sm font-medium text-gray-900">{emergencyChecklists.weather.plan}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-500 mb-1">DECISION TRIGGER</div>
                  <div className="text-sm font-medium text-gray-900">{emergencyChecklists.weather.trigger}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-500 mb-1">FINAL DECISION</div>
                  <div className="text-sm font-medium text-gray-900">{emergencyChecklists.weather.decision}</div>
                </div>
                <div className="pt-3 border-t border-blue-200">
                  <div className="flex items-center gap-2">
                    <span className="px-3 py-1 bg-green-100 text-green-700 text-xs rounded-full font-medium">
                      {emergencyChecklists.weather.status}
                    </span>
                    <span className="text-xs text-gray-600">Coordinator: {emergencyChecklists.weather.coordinator}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Medical Notes */}
          <div className="bg-gradient-to-br from-red-50 to-white rounded-2xl p-6 border-2 border-red-100">
            <div className="flex items-center gap-3 mb-4">
              <Heart size={24} className="text-red-600" />
              <h4 className="text-lg font-semibold text-gray-900">Medical & Allergy Information</h4>
            </div>
            <div className="grid grid-cols-3 gap-4">
              {emergencyChecklists.medical.map((item, idx) => (
                <div key={idx} className="bg-white rounded-xl p-4 border border-red-200">
                  <div className="text-xs text-gray-500 mb-1">PERSON</div>
                  <div className="font-medium text-gray-900 mb-2">{item.person}</div>
                  <div className="text-xs text-gray-500 mb-1">CONDITION</div>
                  <div className="text-sm font-semibold text-red-600 mb-2">{item.condition}</div>
                  <div className="text-xs text-gray-500 mb-1">MEDICATION</div>
                  <div className="text-sm text-gray-900 mb-1">{item.medication}</div>
                  <div className="text-xs text-gray-500">Location: {item.location}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Silent Emergency Mode */}
          <div className="bg-gradient-to-br from-purple-50 to-white rounded-2xl p-6 border-2 border-purple-100">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <Shield size={24} className="text-purple-600" />
                <div>
                  <h4 className="text-lg font-semibold text-gray-900">Silent Emergency Mode</h4>
                  <p className="text-sm text-gray-600">Discreetly alert selected coordinators without alarming guests</p>
                </div>
              </div>
              <button className="px-6 py-2.5 bg-purple-600 text-white rounded-xl hover:bg-purple-700 transition-colors">
                Activate Silent Mode
              </button>
            </div>
            <div className="text-sm text-gray-600 italic">
              This mode sends discrete notifications to wedding planner, venue manager, and selected coordinators without visible or audible alerts.
            </div>
          </div>
        </div>
      )}

      {/* Placeholder for other tabs */}
      {['wedding-day', 'looks', 'seating', 'documents', 'files-speeches'].includes(activeTab) && (
        <div className="bg-white rounded-[24px] p-8 text-center border border-gray-100">
          <div className="w-16 h-16 rounded-full bg-gradient-to-br from-[#FF88BA] to-[#FF3E9B] flex items-center justify-center mx-auto mb-4">
            <Activity size={32} className="text-white" />
          </div>
          <div className="text-[20px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
            {activeTab.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}
          </div>
          <p className="text-[14px] text-gray-600 mb-4">
            This powerful coordination system is ready for your wedding party
          </p>
          <p className="text-[13px] text-gray-500">
            Full functionality coming soon
          </p>
        </div>
      )}

      {/* Enhanced Buzz Modal */}
      {showBuzzModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowBuzzModal(false)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Send Buzz
                </h3>
                <button onClick={() => setShowBuzzModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Recipients</label>
                <select
                  value={selectedBuzzRecipient}
                  onChange={(e) => setSelectedBuzzRecipient(e.target.value)}
                  className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] bg-white"
                >
                  <option>All wedding party (12)</option>
                  <option>Bridesmaids (6)</option>
                  <option>Groomsmen (6)</option>
                  <option>Maid of Honor & Best Man</option>
                  <option>Travelling guests (7)</option>
                  <option>Select individuals...</option>
                </select>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Delivery Channel</label>
                <div className="grid grid-cols-3 gap-2">
                  {(['WhatsApp', 'SMS', 'Email'] as const).map((method) => (
                    <button
                      key={method}
                      onClick={() => setSelectedBuzzChannel(method)}
                      className={`py-2.5 border rounded-[12px] text-[13px] transition-all ${
                        selectedBuzzChannel === method
                          ? 'border-[#FF3E9B] bg-[#FFF5F8] text-[#FF3E9B]'
                          : 'border-gray-200 hover:border-[#FF3E9B] hover:bg-[#FFF5F8]'
                      }`}
                    >
                      {method}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Emotional Tone</label>
                <div className="grid grid-cols-3 gap-2">
                  {['elegant', 'calm', 'gentle', 'loving', 'excited', 'urgent', 'encouraging', 'funny', 'formal'].map((tone) => (
                    <button
                      key={tone}
                      onClick={() => setSelectedBuzzTone(tone)}
                      className={`py-2 border rounded-[12px] text-[12px] transition-all ${
                        selectedBuzzTone === tone
                          ? 'border-[#3A8B95] bg-[#F0F9FA] text-[#3A8B95]'
                          : 'border-gray-200 hover:border-[#3A8B95] hover:bg-[#F0F9FA]'
                      }`}
                    >
                      {tone.charAt(0).toUpperCase() + tone.slice(1)}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Message</label>
                <textarea
                  value={buzzMessage}
                  onChange={(e) => setBuzzMessage(e.target.value)}
                  className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] resize-none focus:outline-none focus:border-[#FF88BA]"
                  rows={4}
                  placeholder="Type your message..."
                />
                <button
                  onClick={() => setBuzzMessage("Hi everyone 🤍 rehearsal begins at 5:30 PM. Please arrive 15 minutes early so we can begin calmly and on time.")}
                  className="mt-2 w-full"
                >
                  <div className="p-3 bg-[#F0F9FA] rounded-[12px] border border-[#3A8B95]/20 hover:border-[#3A8B95] transition-colors cursor-pointer">
                    <div className="text-[11px] text-gray-500 mb-1">💡 AI Suggestion - Click to use</div>
                    <div className="text-[13px] text-gray-700 italic">
                      "Hi everyone 🤍 rehearsal begins at 5:30 PM. Please arrive 15 minutes early so we can begin calmly and on time."
                    </div>
                  </div>
                </button>
              </div>

              <div>
                <label className="text-[13px] text-gray-700 mb-2 flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={scheduleBuzz}
                    onChange={(e) => setScheduleBuzz(e.target.checked)}
                    className="rounded"
                  />
                  <span>Schedule for later</span>
                </label>
              </div>

              <button
                onClick={() => {
                  // In real app, would send buzz
                  setShowBuzzModal(false);
                  setBuzzMessage('');
                  setScheduleBuzz(false);
                }}
                className="w-full py-3.5 bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white rounded-[16px] text-[15px] shadow-md hover:shadow-lg transition-shadow"
                style={{ fontWeight: 500 }}
              >
                {scheduleBuzz ? 'Schedule Buzz' : 'Send Buzz'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add Person Modal */}
      {showAddPersonModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowAddPersonModal(false)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Add Party Member
                </h3>
                <button onClick={() => setShowAddPersonModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Full Name</label>
                <input type="text" placeholder="First and last name" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Role</label>
                <select className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] bg-white">
                  <option>Select role...</option>
                  <option>Bridesmaid</option>
                  <option>Groomsman</option>
                  <option>Maid of Honor</option>
                  <option>Best Man</option>
                  <option>Flower Girl</option>
                  <option>Ring Bearer</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Relationship to Couple</label>
                <input type="text" placeholder="e.g. College friend, Sister" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Phone</label>
                  <input type="tel" placeholder="+1 (555) 000-0000" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
                </div>
                <div>
                  <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Email</label>
                  <input type="email" placeholder="email@example.com" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
                </div>
              </div>
              <button
                onClick={() => setShowAddPersonModal(false)}
                className="w-full py-3.5 bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white rounded-[16px] text-[15px] shadow-md"
                style={{ fontWeight: 500 }}
              >
                Add to Wedding Party
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Assign Task Modal */}
      {showAssignTaskModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowAssignTaskModal(false)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-[#3A8B95]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Assign Responsibility
                </h3>
                <button onClick={() => setShowAssignTaskModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Task Title</label>
                <input type="text" placeholder="e.g. Coordinate transportation" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Assign To</label>
                <select className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] bg-white">
                  <option>Select person...</option>
                  {people.map(p => (
                    <option key={p.id}>{p.name}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Due Time</label>
                <input type="text" placeholder="e.g. Wedding morning, 8:00 AM" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Location</label>
                <input type="text" placeholder="e.g. Bridal suite" className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Urgency</label>
                <div className="grid grid-cols-3 gap-2">
                  {['Low', 'Medium', 'High'].map((level) => (
                    <button key={level} className="py-2.5 border border-gray-200 rounded-[12px] text-[13px] hover:border-[#3A8B95] hover:bg-[#F0F9FA]">
                      {level}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Description</label>
                <textarea className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] resize-none" rows={3} placeholder="Task details..."></textarea>
              </div>
              <button
                onClick={() => setShowAssignTaskModal(false)}
                className="w-full py-3.5 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[16px] text-[15px] shadow-md"
                style={{ fontWeight: 500 }}
              >
                Assign Task
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Emergency Broadcast Modal */}
      {showEmergencyBroadcast && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowEmergencyBroadcast(false)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-gradient-to-r from-[#FFF5F8] to-white border-b border-[#FF3E9B]/20 p-6 pb-4">
              <div className="w-12 h-1 bg-[#FF3E9B] rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <div>
                  <div className="flex items-center gap-2 mb-2">
                    <AlertCircle size={20} className="text-[#FF3E9B]" />
                    <h3 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Emergency Broadcast
                    </h3>
                  </div>
                  <p className="text-[13px] text-gray-600">Send urgent update to entire wedding party</p>
                </div>
                <button onClick={() => setShowEmergencyBroadcast(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div className="p-4 bg-[#FFF5F8] rounded-[16px] border border-[#FF3E9B]/30">
                <div className="text-[12px] text-[#FF3E9B] mb-1" style={{ fontWeight: 500 }}>⚠️ Emergency broadcasts will be sent immediately via WhatsApp, SMS, and Email</div>
                <div className="text-[11px] text-gray-600">Use only for time-sensitive updates</div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Emergency Type</label>
                <select className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] bg-white">
                  <option>Select type...</option>
                  <option>Weather Update</option>
                  <option>Time Change</option>
                  <option>Location Change</option>
                  <option>Transportation Issue</option>
                  <option>Vendor Delay</option>
                  <option>General Alert</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Message</label>
                <textarea className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] resize-none" rows={4} placeholder="Urgent update..."></textarea>
              </div>
              <button
                onClick={() => setShowEmergencyBroadcast(false)}
                className="w-full py-3.5 bg-gradient-to-r from-[#FF3E9B] to-[#D4183D] text-white rounded-[16px] text-[15px] shadow-md"
                style={{ fontWeight: 500 }}
              >
                Send Emergency Broadcast
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Activity Feed Modal */}
      {showActivityFeed && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowActivityFeed(false)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  All Activity
                </h3>
                <button onClick={() => setShowActivityFeed(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-3">
              {activities.map((activity) => (
                <div key={activity.id} className="flex items-start gap-3 p-3 rounded-[16px] hover:bg-gray-50 transition-colors">
                  <span className="text-[20px] flex-shrink-0">{activity.icon}</span>
                  <div className="flex-1 min-w-0">
                    <div className="text-[13px] text-gray-900">{activity.text}</div>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className="text-[11px] text-gray-500">{activity.time}</span>
                      <span className="text-[11px] text-gray-400">•</span>
                      <span className="text-[11px] text-[#3A8B95]">{activity.person}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Task Detail Modal */}
      {showTaskDetail && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowTaskDetail(null)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Update Status
                </h3>
                <button onClick={() => setShowTaskDetail(null)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-3">
              <div className="text-[14px] text-gray-600 mb-4">Select new status for this task</div>
              {[
                { status: 'assigned' as TaskStatus, label: 'Assigned', color: '#6B7280' },
                { status: 'viewed' as TaskStatus, label: 'Viewed', color: '#9CA3AF' },
                { status: 'acknowledged' as TaskStatus, label: 'Acknowledged', color: '#3A8B95' },
                { status: 'in-progress' as TaskStatus, label: 'In Progress', color: '#3A8B95' },
                { status: 'delayed' as TaskStatus, label: 'Delayed', color: '#FFB020' },
                { status: 'needs-help' as TaskStatus, label: 'Needs Help', color: '#FF3E9B' },
                { status: 'escalated' as TaskStatus, label: 'Escalated', color: '#D4183D' },
                { status: 'completed' as TaskStatus, label: 'Completed', color: '#1F4D2B' },
              ].map(({ status, label, color }) => (
                <button
                  key={status}
                  onClick={() => {
                    if (showTaskDetail) {
                      setTaskStatuses(prev => ({ ...prev, [showTaskDetail]: status }));
                      setShowTaskDetail(null);
                    }
                  }}
                  className="w-full p-4 border border-gray-200 rounded-[16px] text-left hover:border-gray-300 hover:bg-gray-50 transition-all flex items-center justify-between"
                >
                  <span className="text-[15px]" style={{ color }}>{label}</span>
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: color }}></div>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Buzz Detail Modal */}
      {showBuzzDetail && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowBuzzDetail(null)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            {(() => {
              const buzz = buzzes.find(b => b.id === showBuzzDetail);
              if (!buzz) return null;
              return (
                <>
                  <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
                    <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
                    <div className="flex items-center justify-between">
                      <h3 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                        Buzz Details
                      </h3>
                      <button onClick={() => setShowBuzzDetail(null)} className="text-gray-400 hover:text-gray-600">
                        <X size={24} />
                      </button>
                    </div>
                  </div>
                  <div className="p-6 space-y-4">
                    <div>
                      <div className="text-[12px] text-gray-500 mb-2">MESSAGE</div>
                      <div className="text-[15px] text-gray-900">{buzz.message}</div>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <div className="text-[12px] text-gray-500 mb-1">Recipients</div>
                        <div className="text-[14px] text-gray-900">{buzz.recipients}</div>
                      </div>
                      <div>
                        <div className="text-[12px] text-gray-500 mb-1">Channel</div>
                        <div className="text-[14px] text-[#3A8B95]">{buzz.channel}</div>
                      </div>
                      <div>
                        <div className="text-[12px] text-gray-500 mb-1">Tone</div>
                        <div className="text-[14px] text-[#FF88BA]">{buzz.tone}</div>
                      </div>
                      <div>
                        <div className="text-[12px] text-gray-500 mb-1">Sent</div>
                        <div className="text-[14px] text-gray-900">{buzz.sentAt}</div>
                      </div>
                    </div>
                    <div>
                      <div className="text-[12px] text-gray-500 mb-2">DELIVERY STATUS</div>
                      <div className="p-3 bg-[#E8F3EC] rounded-[12px]">
                        <div className="text-[14px] text-[#1F4D2B]" style={{ fontWeight: 500 }}>
                          {buzz.deliveryStatus === 'read' ? `Read by ${buzz.readBy.length} people` : 'Delivered'}
                        </div>
                      </div>
                    </div>
                    <div>
                      <div className="text-[12px] text-gray-500 mb-2">REACTIONS</div>
                      <div className="flex gap-2">
                        {buzz.reactions.map((reaction, idx) => (
                          <div key={idx} className="px-3 py-2 bg-[#FAFAFA] rounded-[12px]">
                            <span className="text-[16px] mr-2">{reaction.emoji}</span>
                            <span className="text-[14px] text-gray-700">{reaction.count}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                    <button
                      onClick={() => setShowBuzzDetail(null)}
                      className="w-full py-3 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[16px] text-[14px]"
                      style={{ fontWeight: 500 }}
                    >
                      Resend Buzz
                    </button>
                  </div>
                </>
              );
            })()}
          </div>
        </div>
      )}

      {/* Attire Detail Modal */}
      {showAttireDetail && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowAttireDetail(null)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            {(() => {
              const person = people.find(p => p.id === showAttireDetail);
              if (!person) return null;
              return (
                <>
                  <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
                    <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
                    <div className="flex items-center justify-between">
                      <h3 className="text-[22px] text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                        {person.name}'s Attire
                      </h3>
                      <button onClick={() => setShowAttireDetail(null)} className="text-gray-400 hover:text-gray-600">
                        <X size={24} />
                      </button>
                    </div>
                  </div>
                  <div className="p-6 space-y-4">
                    <div className="p-4 bg-[#FFF5F8] rounded-[20px]">
                      <div className="text-[12px] text-gray-500 mb-2">STATUS</div>
                      <div className="text-[16px] text-gray-900" style={{ fontWeight: 500 }}>
                        {person.attireStatus === 'complete' ? '✓ All set' : 'Needs final fitting'}
                      </div>
                    </div>
                    <div>
                      <div className="text-[14px] text-gray-700 mb-3" style={{ fontWeight: 500 }}>Checklist</div>
                      {['Measurements submitted', 'Dress/suit selected', 'First fitting complete', 'Final fitting scheduled', 'Accessories confirmed'].map((item, idx) => (
                        <div key={idx} className="flex items-center gap-3 p-3 border-b border-gray-100 last:border-0">
                          <div className={`w-5 h-5 rounded-full flex items-center justify-center ${
                            idx < 3 ? 'bg-[#E8F3EC]' : 'bg-gray-100'
                          }`}>
                            {idx < 3 && <Check size={14} className="text-[#1F4D2B]" />}
                          </div>
                          <span className="text-[13px] text-gray-700">{item}</span>
                        </div>
                      ))}
                    </div>
                    <button
                      onClick={() => setShowAttireDetail(null)}
                      className="w-full py-3 bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white rounded-[16px] text-[14px]"
                      style={{ fontWeight: 500 }}
                    >
                      Update Attire Status
                    </button>
                  </div>
                </>
              );
            })()}
          </div>
        </div>
      )}

      {/* Add Note Modal */}
      {showAddNoteModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowAddNoteModal(null)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Add Private Note
                </h3>
                <button onClick={() => setShowAddNoteModal(null)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div className="p-3 bg-[#FFFBF0] rounded-[12px] border border-[#FFB020]/20">
                <div className="text-[11px] text-gray-600">Private notes are only visible to you and your planner</div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>Note</label>
                <textarea className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] resize-none" rows={5} placeholder="Add note about this person..."></textarea>
              </div>
              <button
                onClick={() => setShowAddNoteModal(null)}
                className="w-full py-3.5 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[16px] text-[15px] shadow-md"
                style={{ fontWeight: 500 }}
              >
                Save Note
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Upload Modal */}
      {showUploadModal && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowUploadModal(null)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Upload Files
                </h3>
                <button onClick={() => setShowUploadModal(null)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div className="border-2 border-dashed border-gray-300 rounded-[20px] p-8 text-center hover:border-[#3A8B95] transition-colors cursor-pointer">
                <Upload size={32} className="text-gray-400 mx-auto mb-3" />
                <div className="text-[14px] text-gray-900 mb-1" style={{ fontWeight: 500 }}>Click to upload or drag and drop</div>
                <div className="text-[12px] text-gray-500">PDF, images, documents (max 10MB)</div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>File Type</label>
                <select className="w-full p-3 border border-gray-200 rounded-[16px] text-[14px] bg-white">
                  <option>Select type...</option>
                  <option>Measurements</option>
                  <option>Attire Reference</option>
                  <option>Speech Draft</option>
                  <option>Travel Documents</option>
                  <option>Other</option>
                </select>
              </div>
              <button
                onClick={() => setShowUploadModal(null)}
                className="w-full py-3.5 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[16px] text-[15px] shadow-md"
                style={{ fontWeight: 500 }}
              >
                Upload Files
              </button>
            </div>
          </div>
        </div>
      )}

      {/* People Filter Modal */}
      {showPeopleFilter && (
        <div className="fixed inset-0 bg-black/40 z-50 flex items-end" onClick={() => setShowPeopleFilter(false)}>
          <div className="bg-white w-full rounded-t-[32px] max-h-[85vh] overflow-y-auto animate-slideUp" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-100 p-6 pb-4">
              <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4"></div>
              <div className="flex items-center justify-between">
                <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                  Filter Wedding Party
                </h3>
                <button onClick={() => setShowPeopleFilter(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <div className="text-[14px] text-gray-700 mb-3" style={{ fontWeight: 500 }}>Role</div>
                {['All Roles', 'Bridesmaids', 'Groomsmen', 'Maid of Honor', 'Best Man'].map((role) => (
                  <button key={role} className="w-full p-3 text-left border border-gray-200 rounded-[12px] mb-2 hover:bg-gray-50">
                    {role}
                  </button>
                ))}
              </div>
              <div>
                <div className="text-[14px] text-gray-700 mb-3" style={{ fontWeight: 500 }}>Status</div>
                {['All Statuses', 'Confirmed', 'Needs Response', 'Travelling', 'Needs Fitting'].map((status) => (
                  <button key={status} className="w-full p-3 text-left border border-gray-200 rounded-[12px] mb-2 hover:bg-gray-50">
                    {status}
                  </button>
                ))}
              </div>
              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => setShowPeopleFilter(false)}
                  className="flex-1 py-3 border border-gray-200 text-gray-700 rounded-[16px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Clear
                </button>
                <button
                  onClick={() => setShowPeopleFilter(false)}
                  className="flex-1 py-3 bg-gradient-to-r from-[#3A8B95] to-[#2A7B85] text-white rounded-[16px] text-[14px]"
                  style={{ fontWeight: 500 }}
                >
                  Apply Filters
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Emergency Broadcast Modal */}
      {showEmergencyBroadcastModal && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={() => setShowEmergencyBroadcastModal(false)}>
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="bg-gradient-to-br from-red-50 to-white p-6 border-b border-red-100">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-red-600 rounded-full flex items-center justify-center">
                    <Bell size={24} className="text-white" />
                  </div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900">Emergency Broadcast</h3>
                    <p className="text-sm text-gray-600">Alert your coordination team immediately</p>
                  </div>
                </div>
                <button onClick={() => setShowEmergencyBroadcastModal(false)} className="text-gray-400 hover:text-gray-600">
                  <X size={24} />
                </button>
              </div>
              <div className="bg-red-100 border-l-4 border-red-600 p-4 rounded-r-lg">
                <p className="text-sm text-red-900">
                  <strong>Important:</strong> This will immediately notify all selected coordinators. Use only for genuine emergencies requiring immediate attention.
                </p>
              </div>
            </div>

            <div className="p-6 space-y-6">
              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-3">Who to notify</label>
                <div className="space-y-2">
                  {[
                    { name: 'Wedding Planner - Lisa Chang', phone: '+1 (555) 0200', role: 'Primary coordinator' },
                    { name: 'Venue Manager - Sarah Thompson', phone: '+1 (555) 0210', role: 'Venue operations' },
                    { name: 'Best Man - James Wilson', phone: '+1 (555) 0102', role: 'Wedding party lead' },
                    { name: 'Maid of Honor - Emily Rodriguez', phone: '+1 (555) 0101', role: 'Wedding party lead' }
                  ].map((contact, idx) => (
                    <label key={idx} className="flex items-center p-3 bg-gray-50 rounded-xl hover:bg-gray-100 cursor-pointer">
                      <input type="checkbox" defaultChecked className="mr-3 h-5 w-5 text-red-600 rounded" />
                      <div className="flex-1">
                        <div className="font-medium text-gray-900">{contact.name}</div>
                        <div className="text-sm text-gray-600">{contact.role} • {contact.phone}</div>
                      </div>
                    </label>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-2">Emergency type</label>
                <select className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent">
                  <option>Medical Emergency</option>
                  <option>Venue Issue</option>
                  <option>Vendor No-Show</option>
                  <option>Weather Emergency</option>
                  <option>Transportation Issue</option>
                  <option>Missing Person</option>
                  <option>Security Concern</option>
                  <option>Other Urgent Matter</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-2">Message</label>
                <textarea
                  placeholder="Describe the situation clearly and calmly..."
                  rows={4}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-2">Your location</label>
                <input
                  type="text"
                  placeholder="e.g., Bridal Suite, Main Entrance, Terrace"
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-transparent"
                />
              </div>

              <div className="flex items-center gap-3">
                <input type="checkbox" id="silent" className="h-5 w-5 text-purple-600 rounded" />
                <label htmlFor="silent" className="text-sm text-gray-700">
                  <strong>Silent mode</strong> - Send discreet notifications without audible alerts
                </label>
              </div>
            </div>

            <div className="bg-gray-50 p-6 border-t border-gray-200 flex items-center justify-between">
              <button
                onClick={() => setShowEmergencyBroadcastModal(false)}
                className="px-6 py-3 bg-white border-2 border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors font-medium"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  alert('Emergency broadcast sent to selected coordinators');
                  setShowEmergencyBroadcastModal(false);
                }}
                className="px-8 py-3 bg-gradient-to-r from-red-600 to-red-500 text-white rounded-xl hover:shadow-lg transition-all font-semibold flex items-center gap-2"
              >
                <Bell size={18} />
                Send Emergency Alert
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Responsibility Detail Drawer */}
      {selectedResponsibility && (
        <ResponsibilityDetailDrawer
          responsibility={selectedResponsibility}
          people={people}
          onClose={() => setSelectedResponsibility(null)}
          onSave={(updated) => {
            setSelectedResponsibility(null);
          }}
          onDelete={() => {
            setSelectedResponsibility(null);
          }}
          onSendBuzz={() => {
            alert('Send Buzz functionality');
          }}
          onReassign={() => {
            alert('Reassign functionality');
          }}
        />
      )}

      {/* Timeline Item Detail Modal */}
      {selectedTimelineItem && (
        <TimelineItemDetailModal
          item={selectedTimelineItem}
          onClose={() => setSelectedTimelineItem(null)}
          onSave={(updated) => {
            setSelectedTimelineItem(null);
          }}
          onDelete={() => {
            setSelectedTimelineItem(null);
          }}
          onNotifyPeople={() => {
            alert('Notifying all affected people about this timeline change');
          }}
        />
      )}
    </div>
    </DndProvider>
  );
}
