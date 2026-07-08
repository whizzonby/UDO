'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/api';
import { getToken } from '@/lib/auth';
import { Calendar, DollarSign, Utensils, Briefcase, Users, MapPin, Clock, Image, Bell, Heart, Plane, Shield, ChevronRight, Info, X, Plus, Edit, GripVertical, Trash2, Check, Upload, Share2, Link, MessageSquare, Mail, Send, Sparkles } from 'lucide-react';
import WeddingPartyPage from './WeddingPartyPage';
import PlanOverviewModals from './plan/PlanOverviewModals';
import YourVisionPage from './YourVisionPage';

type PlanTab = 'overview' | 'your-vision' | 'tasks' | 'budget' | 'vendors' | 'wedding-party' | 'details';
type ModalType = 'event-structure' | 'budget' | 'food' | 'vendors' | 'wedding-party' | 'seating' | 'timeline' | 'additional-events' | 'personal-moments' | 'honeymoon' | 'insurance' | 'lookbook' | 'reminders' | 'guests' | 'travel-stay' | null;
type FormModalType = 'add-task' | 'add-expense' | 'add-vendor' | 'edit-wedding-details' | 'manage-access' | 'guest-page-settings' | 'add-event' | 'edit-event' | 'add-timeline-moment' | 'edit-timeline-moment' | 'add-budget-expense' | 'edit-budget-categories' | 'add-wedding-party-member' | 'assign-duties' | 'start-seating' | 'seating-board' | 'add-additional-event' | 'add-custom-moment' | 'add-custom-duty' | 'edit-honeymoon' | 'track-bookings' | 'edit-insurance' | 'upload-policy' | 'upload-lookbook-photo' | 'pinterest-connect' | 'share-lookbook' | null;

interface Event {
  id: number;
  name: string;
  time: string;
  location: string;
  guests: number;
}

interface Vendor {
  category: string;
  status: 'Booked' | 'Shortlisted' | 'Needed';
  name?: string;
  dateBooked?: string;
  shortlistedCount?: number;
}

interface WeddingPartyMember {
  name: string;
  role: string;
  email: string;
  phone: string;
  speech: boolean;
}

export default function PlanPage() {
  const [activeTab, setActiveTab] = useState<PlanTab>('overview');
  const [activeModal, setActiveModal] = useState<ModalType>(null);
  const [activeFormModal, setActiveFormModal] = useState<FormModalType>(null);
  const [editingEventId, setEditingEventId] = useState<number | null>(null);
  const [expandedTaskId, setExpandedTaskId] = useState<number | null>(null);
  const [showAddTaskTemplate, setShowAddTaskTemplate] = useState(false);
  const [taskFilter, setTaskFilter] = useState<string>('All');
  const [completedTasks, setCompletedTasks] = useState<number[]>([]);
  const [hoveredTaskId, setHoveredTaskId] = useState<number | null>(null);
  const [showCompletionToast, setShowCompletionToast] = useState(false);
  const [completionMessage, setCompletionMessage] = useState('');
  const [showStatusMenu, setShowStatusMenu] = useState<number | null>(null);
  const [taskDetailId, setTaskDetailId] = useState<number | null>(null);
  const [taskStatuses, setTaskStatuses] = useState<{[key: number]: string}>({
    1: 'Requires decision',
    2: 'Awaiting quote',
    3: 'Pending confirmation',
  });
  const [swipedTaskId, setSwipedTaskId] = useState<number | null>(null);
  const [swipeDirection, setSwipeDirection] = useState<'left' | 'right' | null>(null);
  const [expandedCategoryId, setExpandedCategoryId] = useState<string | null>(null);
  const [expandedExpenseId, setExpandedExpenseId] = useState<number | null>(null);
  const [showAddExpenseFlow, setShowAddExpenseFlow] = useState(false);
  const [budgetInsightsOpen, setBudgetInsightsOpen] = useState(true);
  const [expandedVendorId, setExpandedVendorId] = useState<string | null>(null);
  const [vendorFilter, setVendorFilter] = useState<string>('All');
  const [showVendorComparison, setShowVendorComparison] = useState(false);
  const [selectedCompareVendors, setSelectedCompareVendors] = useState<string[]>([]);
  const [events, setEvents] = useState<Event[]>([]);
  const [dietaryNeeds, setDietaryNeeds] = useState({ vegetarian: 0, vegan: 0, glutenFree: 0, allergies: 0 });
  const [enhancements, setEnhancements] = useState({
    cocktailHour: true,
    signatureCocktails: true,
    champagneToast: true,
    dessertTable: false,
    lateNightSnacks: true,
    coffeeCart: false,
    kidsMenu: true,
  });
  const [lookbookCategory, setLookbookCategory] = useState('All');
  const [pinterestConnected, setPinterestConnected] = useState(false);
  const [draggedGuest, setDraggedGuest] = useState<string | null>(null);
  const [seatingTables, setSeatingTables] = useState<{[key: string]: string[]}>({});
  const [unassignedGuests, setUnassignedGuests] = useState<string[]>([]);
  const [viewingImage, setViewingImage] = useState<number | null>(null);
  const [selectedTaskPriority, setSelectedTaskPriority] = useState<string>('Urgent');
  const [selectedVendorStatus, setSelectedVendorStatus] = useState<string>('Booked');
  const [selectedPaymentStatus, setSelectedPaymentStatus] = useState<string>('Paid');
  const [draggedTimelineMoment, setDraggedTimelineMoment] = useState<number | null>(null);
  const [draggedEvent, setDraggedEvent] = useState<number | null>(null);
  const [timelineMoments, setTimelineMoments] = useState<{time:string;moment:string;owner:string;type:string}[]>([]);

  // API state — tasks
  const [apiTasks, setApiTasks] = useState<{id:number;title:string;description?:string;category?:string;due_date?:string;priority?:string;completed:boolean;sort_order?:number}[]>([]);
  const [tasksLoading, setTasksLoading] = useState(false);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    setTasksLoading(true);
    api.get<{ data: any[] }>('/plan/tasks', t)
      .then(res => setApiTasks(res.data ?? []))
      .catch(() => {})
      .finally(() => setTasksLoading(false));
  }, []);

  // API state — budget
  const [budgetItems, setBudgetItems] = useState<{id:number;name:string;category:string;estimated_amount:number;actual_amount:number;paid_amount:number;payment_status:string;is_essential:boolean;due_date?:string}[]>([]);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<{ data: any[] }>('/plan/budget', t)
      .then(res => setBudgetItems(res.data ?? []))
      .catch(() => {});
  }, []);

  // API state — vendors
  const [apiVendors, setApiVendors] = useState<{id:number;name:string;category:string;booking_status:string;contract_signed:boolean;contact_name?:string;contact_email?:string;contact_phone?:string;estimated_cost?:number}[]>([]);

  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<{ data: any[] }>('/plan/vendors', t)
      .then(res => setApiVendors(res.data ?? []))
      .catch(() => {});
  }, []);

  // API state — timeline (feeds both events calendar and timeline moments views)
  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<{ data: any[] }>('/plan/timeline', t)
      .then(res => {
        const items = res.data ?? [];
        setEvents(items.map((item: any) => ({
          id: item.id,
          name: item.title,
          time: item.start_time ?? '',
          location: item.location ?? '',
          guests: 0,
        })));
        setTimelineMoments(items.map((item: any) => ({
          time: item.start_time ?? '',
          moment: item.title,
          owner: item.location ?? '',
          type: item.event_type ?? 'Custom',
        })));
      })
      .catch(() => {});
  }, []);

  // API state — wedding party members
  const [weddingParty, setWeddingParty] = useState<WeddingPartyMember[]>([]);
  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<any[]>('/guests?group=wedding_party', t)
      .then(data => {
        const list = Array.isArray(data) ? data : [];
        setWeddingParty(list.map((g: any) => ({
          name: `${g.first_name ?? ''} ${g.last_name ?? ''}`.trim(),
          role: g.notes ?? 'Guest',
          email: g.email ?? '',
          phone: g.phone ?? '',
          speech: false,
        })));
      })
      .catch(() => {});
  }, []);

  // API state — dietary needs (derived from guest meal preferences)
  useEffect(() => {
    const t = getToken();
    if (!t) return;
    api.get<any[]>('/guests', t)
      .then(data => {
        const guests = Array.isArray(data) ? data : [];
        setDietaryNeeds({
          vegetarian: guests.filter((g: any) => g.meal_preference === 'vegetarian').length,
          vegan: guests.filter((g: any) => g.meal_preference === 'vegan').length,
          glutenFree: guests.filter((g: any) => g.meal_preference === 'gluten-free').length,
          allergies: guests.filter((g: any) => g.dietary_restrictions).length,
        });
      })
      .catch(() => {});
  }, []);

  // Derived budget totals
  const totalBudget = budgetItems.reduce((sum, item) => sum + (Number(item.estimated_amount) || 0), 0);
  const totalSpent = budgetItems.reduce((sum, item) => sum + (Number(item.actual_amount) || 0), 0);

  // Toggle task completion via API
  const toggleTask = async (taskId: number, completed: boolean) => {
    const t = getToken();
    if (!t) return;
    try {
      await api.patch(`/plan/tasks/${taskId}`, { completed }, t);
      setApiTasks(prev => prev.map(task => task.id === taskId ? { ...task, completed } : task));
      if (completed) {
        setCompletedTasks(prev => [...prev, taskId]);
        setCompletionMessage('Task completed');
        setShowCompletionToast(true);
        setTimeout(() => setShowCompletionToast(false), 3000);
      } else {
        setCompletedTasks(prev => prev.filter(id => id !== taskId));
      }
    } catch {}
  };

  const tabs = [
    { id: 'overview' as PlanTab, label: 'Overview' },
    { id: 'your-vision' as PlanTab, label: 'Your Vision', special: true },
    { id: 'tasks' as PlanTab, label: 'Tasks' },
    { id: 'budget' as PlanTab, label: 'Budget' },
    { id: 'vendors' as PlanTab, label: 'Vendors' },
    { id: 'wedding-party' as PlanTab, label: 'Wedding Party' },
    { id: 'details' as PlanTab, label: 'Details' },
  ];

  const priorityTasks = [
    {
      title: 'Finalize venue shortlist',
      explanation: 'This shapes your guest count and budget.',
      supporting: 'Best to complete soon.',
      status: 'Urgent',
      module: 'vendors' as ModalType,
    },
    {
      title: 'Set guest meal preferences',
      explanation: 'Dining needs final counts and dietary clarity.',
      supporting: 'A good task for this week.',
      status: 'Soon',
      module: 'food' as ModalType,
    },
    {
      title: 'Publish guest page',
      explanation: 'Guests need this to RSVP and plan travel.',
      supporting: 'Share when your key details feel settled.',
      status: 'Soon',
      module: 'timeline' as ModalType,
    },
  ];

  // Core planning modules - drive the wedding
  const coreModules = [
    {
      id: 'budget',
      icon: DollarSign,
      title: 'Budget',
      status: 'In progress',
      summary: '$45,000 total',
      progress: 70,
      nextStep: 'Food and décor still have room to shape',
      lastUpdated: '2h ago',
      updatedBy: 'Planner'
    },
    {
      id: 'guests',
      icon: Users,
      title: 'Guests',
      status: 'In progress',
      summary: '120 invited • 95 confirmed',
      progress: 85,
      nextStep: '8 guests still pending RSVP',
      lastUpdated: '4h ago',
      comments: 2
    },
    {
      id: 'event-structure',
      icon: Calendar,
      title: 'Wedding Flow',
      status: 'Complete',
      summary: '18 moments planned',
      progress: 100,
      nextStep: 'Your ceremony and reception flow is set',
      lastUpdated: '1d ago'
    },
    {
      id: 'vendors',
      icon: Briefcase,
      title: 'Vendors',
      status: 'In progress',
      summary: '8 booked • 3 still needed',
      progress: 65,
      nextStep: 'Florist and cake vendor need confirmation',
      lastUpdated: '3h ago',
      updatedBy: 'You'
    },
    {
      id: 'food',
      icon: Utensils,
      title: 'Food & Dining',
      status: 'In progress',
      summary: 'Plated dinner • 5 dietary needs tracked',
      progress: 60,
      nextStep: 'Menu enhancements still need review',
      lastUpdated: '1d ago',
      comments: 1
    },
  ];

  // Experience modules - guest journey and aesthetics
  const experienceModules = [
    {
      id: 'lookbook',
      icon: Image,
      title: 'Vision & Style',
      status: 'In progress',
      summary: '47 images saved',
      progress: 55,
      nextStep: 'Color palette needs final selection',
      lastUpdated: '5h ago'
    },
    {
      id: 'seating',
      icon: MapPin,
      title: 'Seating',
      status: 'Not started',
      summary: '120 guests • 15 tables planned',
      progress: 0,
      nextStep: 'Guest placement has not been arranged yet',
      lastUpdated: null
    },
    {
      id: 'travel-stay',
      icon: Plane,
      title: 'Travel & Stay',
      status: 'In progress',
      summary: '32 travelling guests • 12 transport requests',
      progress: 45,
      nextStep: 'Send logistics link',
      lastUpdated: '6h ago',
      comments: 3
    },
    {
      id: 'additional-events',
      icon: Calendar,
      title: 'Wedding Weekend',
      status: 'In progress',
      summary: 'Rehearsal dinner • Post-wedding brunch',
      progress: 50,
      nextStep: 'Welcome party venue needs booking',
      lastUpdated: '2d ago'
    },
  ];

  // Enhancement modules - lighter/optional features
  const enhancementModules = [
    {
      id: 'honeymoon',
      icon: Plane,
      title: 'Honeymoon',
      status: 'Planned',
      summary: 'Bali • 10 days',
      progress: 90,
      nextStep: 'Almost ready',
      lastUpdated: '1w ago'
    },
    {
      id: 'personal-moments',
      icon: Heart,
      title: 'Memories',
      status: 'In progress',
      summary: '4 speeches • Cultural traditions',
      progress: 40,
      nextStep: 'Photo booth and guestbook setup',
      lastUpdated: '4d ago'
    },
    {
      id: 'insurance',
      icon: Shield,
      title: 'Insurance',
      status: 'Complete',
      summary: 'Policy active',
      progress: 100,
      nextStep: 'You are covered',
      lastUpdated: '2w ago'
    },
    {
      id: 'reminders',
      icon: Bell,
      title: 'Reminders',
      status: 'Active',
      summary: 'Weekly updates enabled',
      progress: 100,
      nextStep: 'You will stay gently informed',
      lastUpdated: '1h ago'
    },
  ];

  const vendors: Vendor[] = apiVendors.map(v => ({
    category: v.category,
    status: (v.booking_status === 'confirmed' ? 'Booked' : v.booking_status === 'shortlisted' ? 'Shortlisted' : 'Needed') as 'Booked' | 'Shortlisted' | 'Needed',
    name: v.name || undefined,
    dateBooked: v.contract_signed ? 'Confirmed' : undefined,
    shortlistedCount: undefined,
  }));

  // weddingParty is loaded from API — see useState above

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Complete':
      case 'Active':
      case 'Planned':
        return 'bg-[#285301]';
      case 'Urgent':
      case 'Needs attention':
        return 'bg-[#d45d78]';
      case 'Soon':
      case 'In progress':
        return 'bg-[#f194b2]';
      default:
        return 'bg-gray-300';
    }
  };

  return (
    <div className="min-h-screen bg-[#FAFAFA]">
      {/* Header */}
      <div className="bg-gradient-to-br from-[#f194b2]/10 to-[#d45d78]/10 px-6 pt-10 pb-8">
        <h1 className="text-4xl text-[#d45d78] mb-3 text-center" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Plan</h1>
        <p className="text-[14px] text-gray-600 text-center max-w-md mx-auto" style={{ fontWeight: 400, lineHeight: 1.6 }}>
          Everything important in one peaceful place.
        </p>
      </div>

      {/* Tab Navigation */}
      <div className="px-6 py-4 bg-white border-b border-gray-100">
        <div className="flex gap-2 overflow-x-auto max-w-3xl mx-auto">
          {tabs.map((tab) => {
            const isActive = activeTab === tab.id;
            const isSpecial = tab.special;

            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`px-4 py-2 rounded-full whitespace-nowrap text-[13px] transition-all relative ${
                  isActive && isSpecial
                    ? 'bg-gradient-to-r from-[#f194b2] to-[#d45d78] text-white shadow-lg'
                    : isActive
                    ? 'bg-[#285301] text-white'
                    : isSpecial
                    ? 'bg-gradient-to-r from-[#f8edeb] to-[#f8edeb] text-[#d45d78] hover:shadow-md'
                    : 'bg-[#FAFAFA]/60 text-gray-700 hover:bg-[#FAFAFA]'
                }`}
                style={{
                  fontWeight: isActive ? 500 : 400,
                  fontFamily: isSpecial ? 'Playfair Display, serif' : 'inherit',
                  boxShadow: isActive && isSpecial ? '0 4px 12px rgba(212, 93, 120, 0.3)' : undefined
                }}
              >
                {isSpecial && <Sparkles size={14} className="inline mr-1.5 -mt-0.5" />}
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Content */}
      <div className="max-w-3xl mx-auto px-5 pb-10 space-y-8 mt-6">
        {activeTab === 'overview' && (
          <>
            {/* Calm Planning Intro */}
            <div className="bg-gradient-to-br from-white to-[#FAFAFA] rounded-[24px] p-6 border border-gray-100/50" style={{ boxShadow: '0 8px 24px rgba(0,0,0,0.04)' }}>
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <p className="text-[15px] text-gray-700 mb-2" style={{ fontWeight: 400, lineHeight: 1.7 }}>
                    This is your planning space. Everything is grouped here so you can move through it clearly.
                  </p>
                  <p className="text-[13px] text-gray-500" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                    Start with what matters most, then refine details as you go.
                  </p>
                </div>
                <Heart className="text-[#f194b2] opacity-50 ml-4 flex-shrink-0" size={20} />
              </div>
            </div>

            {/* Core Planning Modules */}
            <div>
              <h3 className="text-[18px] text-[#1F4D2B] mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Core Planning
              </h3>
              <div className="space-y-3">
                {coreModules.map((module) => {
                  const Icon = module.icon;
                  return (
                    <button
                      key={module.id}
                      onClick={() => setActiveModal(module.id as ModalType)}
                      className="w-full bg-white rounded-[24px] p-5 text-left hover:shadow-lg transition-all group"
                      style={{ boxShadow: '0 4px 16px rgba(0,0,0,0.06)', border: '1px solid rgba(0,0,0,0.04)' }}
                    >
                      <div className="flex items-start gap-4">
                        {/* Icon */}
                        <div className="bg-gradient-to-br from-[#F0F9FA] to-[#E8F4F5] p-3 rounded-[20px] flex-shrink-0">
                          <Icon className="text-[#285301]" size={22} />
                        </div>

                        {/* Content */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between mb-2">
                            <h4 className="text-[16px] text-gray-800" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                              {module.title}
                            </h4>
                            <span className={`text-[10px] px-2.5 py-1 rounded-full text-white flex-shrink-0 ml-2 ${getStatusColor(module.status)}`} style={{ fontWeight: 500 }}>
                              {module.status}
                            </span>
                          </div>

                          <p className="text-[14px] text-gray-700 mb-2" style={{ fontWeight: 400 }}>
                            {module.summary}
                          </p>

                          {/* Progress bar */}
                          <div className="w-full bg-[#F7F7F5] rounded-full h-1.5 mb-3">
                            <div
                              className="bg-gradient-to-r from-[#285301] to-[#2A7B85] h-1.5 rounded-full transition-all"
                              style={{ width: `${module.progress}%` }}
                            />
                          </div>

                          <div className="flex items-center justify-between">
                            <p className="text-[12px] text-gray-500 italic" style={{ fontWeight: 400 }}>
                              {module.nextStep}
                            </p>
                            <div className="flex items-center gap-3 text-[11px] text-gray-400">
                              {module.updatedBy && (
                                <span>Updated by {module.updatedBy}</span>
                              )}
                              {module.comments && (
                                <span className="flex items-center gap-1">
                                  <MessageSquare size={12} />
                                  {module.comments}
                                </span>
                              )}
                              {module.lastUpdated && (
                                <span>{module.lastUpdated}</span>
                              )}
                            </div>
                          </div>
                        </div>

                        <ChevronRight className="text-gray-300 group-hover:text-[#285301] transition-colors flex-shrink-0" size={20} />
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Experience Modules */}
            <div>
              <h3 className="text-[18px] text-[#1F4D2B] mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Guest Experience
              </h3>
              <div className="grid grid-cols-2 gap-3">
                {experienceModules.map((module) => {
                  const Icon = module.icon;
                  return (
                    <button
                      key={module.id}
                      onClick={() => setActiveModal(module.id as ModalType)}
                      className="bg-white rounded-[20px] p-4 text-left hover:shadow-md transition-all group"
                      style={{ boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}
                    >
                      <div className="flex items-center justify-between mb-3">
                        <div className="bg-gradient-to-br from-[#FFF5F8] to-[#FFE8F0] p-2.5 rounded-[16px]">
                          <Icon className="text-[#f194b2]" size={18} />
                        </div>
                        <span className={`text-[9px] px-2 py-0.5 rounded-full text-white ${getStatusColor(module.status)}`} style={{ fontWeight: 500 }}>
                          {module.status}
                        </span>
                      </div>

                      <h4 className="text-[14px] text-gray-800 mb-2" style={{ fontWeight: 500, lineHeight: 1.3 }}>
                        {module.title}
                      </h4>

                      <p className="text-[12px] text-gray-600 mb-3" style={{ fontWeight: 400, lineHeight: 1.4 }}>
                        {module.summary}
                      </p>

                      <div className="w-full bg-[#FAFAFA] rounded-full h-1 mb-2">
                        <div className="bg-[#f194b2] h-1 rounded-full transition-all" style={{ width: `${module.progress}%` }} />
                      </div>

                      <div className="flex items-center justify-between">
                        <p className="text-[10px] text-gray-400 italic flex-1 pr-2" style={{ fontWeight: 400 }}>
                          {module.nextStep}
                        </p>
                        {module.comments && (
                          <span className="text-[10px] text-gray-400 flex items-center gap-1 flex-shrink-0">
                            <MessageSquare size={10} />
                            {module.comments}
                          </span>
                        )}
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Enhancement Modules - Smaller cards */}
            <div>
              <h3 className="text-[16px] text-[#1F4D2B] mb-3" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Additional
              </h3>
              <div className="grid grid-cols-2 gap-2.5">
                {enhancementModules.map((module) => {
                  const Icon = module.icon;
                  return (
                    <button
                      key={module.id}
                      onClick={() => setActiveModal(module.id as ModalType)}
                      className="bg-white rounded-[16px] p-3.5 text-left hover:shadow-sm transition-all"
                      style={{ boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}
                    >
                      <div className="flex items-center gap-2 mb-2">
                        <div className="bg-[#FAFAFA] p-1.5 rounded-[12px]">
                          <Icon className="text-gray-500" size={14} />
                        </div>
                        <h4 className="text-[13px] text-gray-800 flex-1" style={{ fontWeight: 500 }}>
                          {module.title}
                        </h4>
                        <span className={`text-[8px] px-1.5 py-0.5 rounded-full text-white ${getStatusColor(module.status)}`} style={{ fontWeight: 500 }}>
                          {module.status}
                        </span>
                      </div>
                      <p className="text-[11px] text-gray-500" style={{ fontWeight: 400, lineHeight: 1.3 }}>
                        {module.summary}
                      </p>
                    </button>
                  );
                })}
              </div>
            </div>
          </>
        )}

        {activeTab === 'your-vision' && <YourVisionPage />}

        {activeTab === 'tasks' && (
          <>
            {/* Summary Row */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              <div className="bg-gradient-to-br from-[#d45d78]/10 to-[#f194b2]/20 rounded-[20px] p-4 text-center border border-[#d45d78]/20">
                <div className="text-[24px] text-[#d45d78] mb-1" style={{ fontWeight: 500 }}>3</div>
                <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>Needs attention</div>
              </div>
              <div className="bg-gradient-to-br from-[#f194b2]/10 to-[#FAFAFA]/40 rounded-[20px] p-4 text-center border border-[#f194b2]/20">
                <div className="text-[24px] text-[#d45d78] mb-1" style={{ fontWeight: 500 }}>12</div>
                <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>This week</div>
              </div>
              <div className="bg-gradient-to-br from-[#285301]/10 to-[#FAFAFA]/20 rounded-[20px] p-4 text-center border border-[#285301]/20">
                <div className="text-[24px] text-[#285301] mb-1" style={{ fontWeight: 500 }}>47</div>
                <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>Completed</div>
              </div>
            </div>

            {/* Filter Chips - Interactive */}
            <div className="flex gap-2 overflow-x-auto mb-6 pb-1">
              {['All', 'Needs attention', 'This week', 'Assigned to me', 'Completed'].map((filter) => (
                <button
                  key={filter}
                  onClick={() => setTaskFilter(filter)}
                  className={`px-3 py-1.5 rounded-full whitespace-nowrap text-[12px] transition-all ${
                    taskFilter === filter
                      ? 'bg-[#285301] text-white shadow-md scale-105'
                      : 'bg-[#FAFAFA] text-gray-700 hover:bg-gray-100 hover:scale-102'
                  }`}
                  style={{ fontWeight: 500 }}
                >
                  {filter}
                </button>
              ))}
            </div>

            {/* Loading state for tasks */}
            {tasksLoading && (
              <div className="text-center py-8 text-gray-400 text-[13px]">Loading tasks...</div>
            )}

            {/* Most Important - Expandable Tasks */}
            <div className="mb-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-[18px] text-[#1F4D2B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                  Most important right now
                </h3>
                {taskFilter !== 'All' && (
                  <span className="px-2.5 py-1 bg-[#285301] text-white text-[11px] rounded-full" style={{ fontWeight: 500 }}>
                    Filtered: {taskFilter}
                  </span>
                )}
              </div>
              <div className="space-y-3 transition-all duration-300">
                {(() => {
                  const tasks = tasksLoading ? [] : apiTasks.length > 0 ? apiTasks.map(t => ({
                    id: t.id,
                    title: t.title,
                    subtitle: t.description || '',
                    due: t.due_date ? new Date(t.due_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : 'No due date',
                    module: t.category || 'General',
                    status: t.completed ? 'Completed' : (t.priority === 'urgent' ? 'Requires decision' : 'In progress'),
                    assignedTo: 'You',
                    details: {} as Record<string, any>
                  })) : [
                    {
                      id: 1,
                      title: 'Finalize venue shortlist',
                      subtitle: 'This shapes your guest count and budget',
                      due: 'Apr 5',
                      module: 'Vendors',
                      status: 'Requires decision',
                      assignedTo: 'You + Planner',
                      details: {
                        shortlisted: 4,
                        awaitingPricing: 2,
                        siteVisitPending: 1,
                        notes: 'Sunset Gardens has April availability. Ocean View requires $5k deposit.',
                        linkedModule: 'Budget'
                      }
                    },
                    {
                      id: 2,
                      title: 'Secure florist booking before peak season pricing changes',
                      subtitle: 'Floral costs typically increase 20-30% closer to summer',
                      due: 'Apr 8',
                      module: 'Vendors',
                      status: 'Awaiting quote',
                      assignedTo: 'Planner',
                      comments: 2,
                      details: {
                        quotes: 3,
                        preferred: 'Bloom & Co',
                        estimatedCost: '$3,500',
                        depositRequired: '$1,200',
                        notes: 'Bloom & Co can match vision board aesthetic. Quote expires Apr 12.'
                      }
                    },
                    {
                      id: 3,
                      title: 'Finalize guest meal selections so catering can prepare final counts',
                      subtitle: 'Catering needs confirmed numbers by Apr 15',
                      due: 'Apr 10',
                      module: 'Food & Dining',
                      status: 'Pending confirmation',
                      assignedTo: 'You',
                      details: {
                        dietaryNeeds: 5,
                        guestsConfirmed: 95,
                        guestsPending: 25,
                        menuFinalized: true,
                        notes: '5 guests have dietary restrictions that need alternative menu options.'
                      }
                    },
                  ];

                  const filteredTasks = tasks.filter(task => {
                    if (taskFilter === 'Completed') return completedTasks.includes(task.id);
                    if (taskFilter === 'Needs attention') return taskStatuses[task.id] === 'Requires decision' || taskStatuses[task.id] === 'Awaiting quote';
                    if (taskFilter === 'This week') return true;
                    if (taskFilter === 'Assigned to me') return task.assignedTo.includes('You');
                    return true;
                  });

                  if (filteredTasks.length === 0) {
                    return (
                      <div className="text-center py-12 animate-fadeIn">
                        <div className="w-16 h-16 rounded-full bg-[#F0F9FA] mx-auto mb-4 flex items-center justify-center">
                          <Check size={24} className="text-[#285301]" />
                        </div>
                        <p className="text-[15px] text-gray-600 mb-1" style={{ fontWeight: 500 }}>No tasks found</p>
                        <p className="text-[13px] text-gray-400">Try a different filter or add a new task</p>
                      </div>
                    );
                  }

                  return filteredTasks.map((task, index) => (
                  <div
                    key={task.id}
                    onMouseEnter={() => setHoveredTaskId(task.id)}
                    onMouseLeave={() => setHoveredTaskId(null)}
                    className={`bg-white rounded-[20px] overflow-hidden border transition-all duration-300 cursor-pointer animate-fadeIn ${
                      expandedTaskId === task.id
                        ? 'border-[#285301] shadow-lg'
                        : hoveredTaskId === task.id
                        ? 'border-gray-200 shadow-md'
                        : 'border-gray-100 shadow-sm'
                    } ${completedTasks.includes(task.id) ? 'opacity-50' : ''}`}
                    style={{
                      transform: hoveredTaskId === task.id ? 'translateY(-2px)' : 'translateY(0)',
                      animationDelay: `${index * 0.05}s`,
                    }}
                  >
                    {/* Collapsed View - Full card clickable */}
                    <div
                      onClick={() => {
                        if (expandedTaskId !== task.id) {
                          setTaskDetailId(task.id);
                        }
                      }}
                      className="w-full p-4 text-left"
                    >
                      <div className="flex items-start justify-between mb-2">
                        <div className="flex-1 pr-3">
                          <h4 className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>
                            {task.title}
                          </h4>
                          <p className="text-[13px] text-gray-600 mb-2" style={{ fontWeight: 400, lineHeight: 1.5 }}>
                            {task.subtitle}
                          </p>
                          <div className="flex items-center gap-3 text-[12px] flex-wrap">
                            <span className={`px-2 py-0.5 rounded-full text-[11px] ${
                              task.module === 'Vendors' ? 'bg-[#F0F9FA] text-[#285301]' :
                              task.module === 'Food & Dining' ? 'bg-[#FFF5F8] text-[#f194b2]' :
                              'bg-[#F7F7F5] text-gray-600'
                            }`} style={{ fontWeight: 500 }}>
                              {task.module}
                            </span>
                            <span className="text-gray-400">•</span>
                            <span className="text-gray-500">Due {task.due}</span>
                            <span className="text-gray-400">•</span>
                            <span className="text-gray-500">{task.assignedTo}</span>
                            {(task as { comments?: string }).comments && (
                              <>
                                <span className="text-gray-400">•</span>
                                <span className="flex items-center gap-1 text-gray-500">
                                  <MessageSquare size={11} />
                                  {(task as { comments?: string }).comments}
                                </span>
                              </>
                            )}
                          </div>
                        </div>
                        <div className="relative flex-shrink-0">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              setShowStatusMenu(showStatusMenu === task.id ? null : task.id);
                            }}
                            className={`text-[10px] px-2.5 py-1 rounded-full text-white transition-all hover:shadow-md ${
                              (taskStatuses[task.id] || task.status) === 'Requires decision' ? 'bg-[#d45d78]' :
                              (taskStatuses[task.id] || task.status) === 'Awaiting quote' ? 'bg-[#f194b2]' :
                              (taskStatuses[task.id] || task.status) === 'Waiting on response' ? 'bg-[#FFA726]' :
                              (taskStatuses[task.id] || task.status) === 'Pending confirmation' ? 'bg-[#FFA726]' :
                              (taskStatuses[task.id] || task.status) === 'Ready to finalize' ? 'bg-[#285301]' :
                              'bg-gray-400'
                            }`}
                            style={{ fontWeight: 500 }}
                          >
                            {taskStatuses[task.id] || task.status}
                          </button>

                          {showStatusMenu === task.id && (
                            <div className="absolute top-full right-0 mt-2 bg-white rounded-[16px] shadow-xl border border-gray-100 py-2 z-10 min-w-[180px] animate-scaleIn">
                              {['Requires decision', 'Awaiting quote', 'Pending confirmation', 'Waiting on response', 'Ready to finalize', 'Scheduled', 'Blocked'].map((status) => (
                                <button
                                  key={status}
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    setTaskStatuses({...taskStatuses, [task.id]: status});
                                    setShowStatusMenu(null);
                                  }}
                                  className={`w-full px-4 py-2 text-left text-[12px] hover:bg-[#FAFAFA] transition-colors ${
                                    taskStatuses[task.id] === status ? 'bg-[#F0F9FA] text-[#285301]' : 'text-gray-700'
                                  }`}
                                  style={{ fontWeight: 500 }}
                                >
                                  {status}
                                </button>
                              ))}
                            </div>
                          )}
                        </div>
                      </div>

                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          setExpandedTaskId(expandedTaskId === task.id ? null : task.id);
                        }}
                        className="flex items-center gap-2 text-[12px] text-[#285301] hover:underline mt-2"
                        style={{ fontWeight: 500 }}
                      >
                        {expandedTaskId === task.id ? 'Hide quick view' : 'Quick view'}
                        <ChevronRight
                          size={14}
                          className={`transition-transform ${expandedTaskId === task.id ? 'rotate-90' : ''}`}
                        />
                      </button>
                    </div>

                    {/* Expanded View */}
                    {expandedTaskId === task.id && (
                      <div className="px-4 pb-4 border-t border-gray-100 pt-4 animate-fadeIn" style={{ animationDuration: '0.3s' }}>
                        <div className="space-y-3">
                          {/* Task Details Grid */}
                          <div className="grid grid-cols-2 gap-3">
                            {Object.entries(task.details).filter(([key]) => !['notes', 'linkedModule'].includes(key)).map(([key, value]) => (
                              <div key={key} className="p-3 bg-[#FAFAFA] rounded-[16px]">
                                <div className="text-[11px] text-gray-500 mb-0.5 capitalize" style={{ fontWeight: 400 }}>
                                  {key.replace(/([A-Z])/g, ' $1').trim()}
                                </div>
                                <div className="text-[14px] text-gray-800" style={{ fontWeight: 500 }}>
                                  {value}
                                </div>
                              </div>
                            ))}
                          </div>

                          {/* Notes */}
                          {task.details.notes && (
                            <div className="p-3 bg-[#F0F9FA] rounded-[16px] border border-[#285301]/10">
                              <div className="text-[11px] text-gray-500 mb-1" style={{ fontWeight: 400 }}>
                                Notes
                              </div>
                              <p className="text-[13px] text-gray-700" style={{ fontWeight: 400, lineHeight: 1.5 }}>
                                {task.details.notes}
                              </p>
                            </div>
                          )}

                          {/* Linked Module */}
                          {task.details.linkedModule && (
                            <button className="w-full p-3 bg-white border border-gray-200 rounded-[16px] text-left hover:border-[#285301] transition-colors">
                              <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                  <Link size={14} className="text-[#285301]" />
                                  <span className="text-[13px] text-gray-700" style={{ fontWeight: 500 }}>
                                    Linked to {task.details.linkedModule}
                                  </span>
                                </div>
                                <ChevronRight size={14} className="text-gray-400" />
                              </div>
                            </button>
                          )}

                          {/* Action Buttons */}
                          <div className="flex gap-2 pt-2">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                const isNowComplete = !completedTasks.includes(task.id);
                                toggleTask(task.id, isNowComplete);
                                setCompletionMessage(`${task.module} updated • Progress increased`);
                                setTimeout(() => setExpandedTaskId(null), 500);
                              }}
                              className="flex-1 py-2.5 bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white rounded-[16px] text-[13px] hover:shadow-md transition-all"
                              style={{ fontWeight: 500 }}
                            >
                              <Check size={14} className="inline mr-1.5 mb-0.5" />
                              Mark complete
                            </button>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                setActiveFormModal('add-task');
                              }}
                              className="px-4 py-2.5 bg-[#FAFAFA] text-gray-700 rounded-[16px] text-[13px] hover:bg-gray-100 transition-all"
                              style={{ fontWeight: 500 }}
                            >
                              <Edit size={14} className="inline mr-1.5 mb-0.5" />
                              Edit
                            </button>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                  ));
                })()}
              </div>
            </div>

            {/* Upcoming - Interactive */}
            <div className="mb-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-[18px] text-[#1F4D2B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                  Upcoming
                </h3>
                <span className="text-[11px] text-gray-400 italic">Swipe to complete →</span>
              </div>
              <div className="space-y-2">
                {[
                  { id: 101, title: 'Choose the songs that will shape your ceremony atmosphere', due: 'Apr 15', module: 'Timeline', status: 'Scheduled' },
                  { id: 102, title: 'Schedule hair & makeup trial', due: 'Apr 18', module: 'Beauty', status: 'Waiting on response' },
                  { id: 103, title: 'Confirm hotel room blocks before availability closes', due: 'May 1', module: 'Travel & Stay', status: 'Ready to finalize' },
                ].map((task) => (
                  <div
                    key={task.id}
                    className={`bg-white rounded-[18px] p-3.5 border transition-all duration-200 cursor-pointer ${
                      completedTasks.includes(task.id)
                        ? 'border-[#285301] bg-gradient-to-r from-[#F0F9FA] to-white opacity-60'
                        : 'border-gray-100 hover:border-gray-200 hover:shadow-md'
                    }`}
                    style={{
                      transform: completedTasks.includes(task.id) ? 'scale(0.98)' : 'scale(1)',
                    }}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1 pr-2">
                        <div className={`text-[14px] mb-1.5 transition-all ${
                          completedTasks.includes(task.id) ? 'text-gray-400 line-through' : 'text-gray-800'
                        }`} style={{ fontWeight: 500 }}>
                          {task.title}
                        </div>
                        <div className="flex items-center gap-2 text-[11px] flex-wrap">
                          <span className={`px-2 py-0.5 rounded-full text-[10px] ${
                            task.module === 'Timeline' ? 'bg-[#F0F9FA] text-[#285301]' :
                            task.module === 'Beauty' ? 'bg-[#FFF5F8] text-[#f194b2]' :
                            task.module === 'Travel & Stay' ? 'bg-[#F0F9FA] text-[#285301]' :
                            'bg-[#F7F7F5] text-gray-600'
                          }`} style={{ fontWeight: 500 }}>
                            {task.module}
                          </span>
                          <span className="text-gray-400">•</span>
                          <span className="text-gray-500">{task.due}</span>
                          <span className="text-gray-400">•</span>
                          <span className={completedTasks.includes(task.id) ? 'text-[#285301] font-medium' : 'text-[#f194b2]'}>
                            {completedTasks.includes(task.id) ? 'Completed' : task.status}
                          </span>
                        </div>
                      </div>
                      <button
                        onClick={() => {
                          if (!completedTasks.includes(task.id)) {
                            setCompletedTasks([...completedTasks, task.id]);
                            setCompletionMessage(`${task.module} updated • Progress increased`);
                            setShowCompletionToast(true);
                            setTimeout(() => setShowCompletionToast(false), 3000);
                          }
                        }}
                        className={`ml-2 flex-shrink-0 transition-all duration-300 ${
                          completedTasks.includes(task.id)
                            ? 'text-[#285301] bg-[#F0F9FA] p-1 rounded-full'
                            : 'text-gray-300 hover:text-[#285301] hover:scale-110'
                        }`}
                      >
                        <Check size={20} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Smart Add Task Button */}
            <div className="relative">
              <button
                onClick={() => setShowAddTaskTemplate(!showAddTaskTemplate)}
                className="w-full bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white py-3.5 rounded-[20px] flex items-center justify-center shadow-md hover:shadow-lg transition-all active:scale-98"
                style={{ fontWeight: 500 }}
              >
                <Plus size={18} className={`mr-2 transition-transform ${showAddTaskTemplate ? 'rotate-45' : ''}`} />
                {showAddTaskTemplate ? 'Close' : 'Add task'}
              </button>

              {/* Task Template Dropdown */}
              {showAddTaskTemplate && (
                <div
                  className="absolute bottom-full mb-2 w-full bg-white rounded-[20px] shadow-xl border border-gray-100 overflow-hidden"
                  style={{
                    animation: 'fadeIn 0.3s ease-out',
                  }}
                >
                  <div className="p-3">
                    <h4 className="text-[13px] text-gray-500 mb-2 px-2" style={{ fontWeight: 500 }}>
                      Quick add
                    </h4>
                    <div className="space-y-1">
                      {[
                        { icon: Plus, label: 'Create custom task', color: 'text-gray-700' },
                        { icon: Briefcase, label: 'Add vendor task', color: 'text-[#285301]' },
                        { icon: Users, label: 'Add guest task', color: 'text-[#f194b2]' },
                        { icon: DollarSign, label: 'Add payment reminder', color: 'text-[#FFA726]' },
                        { icon: Plane, label: 'Add travel/logistics task', color: 'text-[#285301]' },
                      ].map((template, idx) => {
                        const Icon = template.icon;
                        return (
                          <button
                            key={idx}
                            onClick={() => {
                              setShowAddTaskTemplate(false);
                              setActiveFormModal('add-task');
                            }}
                            className="w-full p-3 rounded-[16px] text-left hover:bg-[#FAFAFA] transition-colors flex items-center gap-3"
                          >
                            <Icon size={16} className={template.color} />
                            <span className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>
                              {template.label}
                            </span>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                  <div className="border-t border-gray-100 p-3 bg-gradient-to-br from-[#F0F9FA] to-white">
                    <button
                      onClick={() => setShowAddTaskTemplate(false)}
                      className="w-full p-3 rounded-[16px] text-left hover:bg-white transition-colors flex items-center gap-3"
                    >
                      <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#f194b2] to-[#d45d78] flex items-center justify-center flex-shrink-0">
                        <span className="text-white text-[14px]">✨</span>
                      </div>
                      <div className="flex-1">
                        <div className="text-[13px] text-gray-800 mb-0.5" style={{ fontWeight: 500 }}>
                          Generate AI task suggestions
                        </div>
                        <div className="text-[11px] text-gray-500" style={{ fontWeight: 400 }}>
                          Based on your wedding timeline
                        </div>
                      </div>
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Completion Toast - Shows module update */}
            {showCompletionToast && (
              <div
                className="fixed bottom-6 left-1/2 transform -translate-x-1/2 bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white px-5 py-3 rounded-[20px] shadow-xl flex items-center gap-3 z-50"
                style={{
                  animation: 'slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                }}
              >
                <div className="w-6 h-6 rounded-full bg-white/20 flex items-center justify-center">
                  <Check size={14} className="text-white" />
                </div>
                <div>
                  <div className="text-[13px]" style={{ fontWeight: 500 }}>
                    Task completed
                  </div>
                  <div className="text-[11px] opacity-90">
                    {completionMessage}
                  </div>
                </div>
              </div>
            )}

            {/* Full Task Detail Modal - Bottom Sheet */}
            {taskDetailId !== null && (
              <div
                className="fixed inset-0 bg-black/40 z-50 flex items-end"
                onClick={() => setTaskDetailId(null)}
                style={{
                  animation: 'fadeIn 0.2s ease-out',
                }}
              >
                <div
                  className="bg-white w-full rounded-t-[32px] max-h-[90vh] overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                  style={{
                    animation: 'slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                  }}
                >
                  {/* Handle */}
                  <div className="sticky top-0 bg-white pt-4 pb-2 px-6 border-b border-gray-100 z-10">
                    <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
                    <div className="flex items-center justify-between">
                      <h2 className="text-[20px] text-[#1F4D2B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                        Task Details
                      </h2>
                      <button
                        onClick={() => setTaskDetailId(null)}
                        className="w-8 h-8 rounded-full bg-[#FAFAFA] hover:bg-gray-200 flex items-center justify-center transition-colors"
                      >
                        <X size={18} className="text-gray-600" />
                      </button>
                    </div>
                  </div>

                  <div className="p-6 space-y-6">
                    {/* Task Title & Status */}
                    <div>
                      <div className="flex items-start justify-between mb-3">
                        <h3 className="text-[18px] text-gray-800 flex-1 pr-3" style={{ fontWeight: 500, lineHeight: 1.4 }}>
                          {taskDetailId === 1 ? 'Finalize venue shortlist' :
                           taskDetailId === 2 ? 'Secure florist booking before peak season pricing changes' :
                           'Finalize guest meal selections so catering can prepare final counts'}
                        </h3>
                        <div className="relative">
                          <button
                            onClick={() => setShowStatusMenu(showStatusMenu === taskDetailId ? null : taskDetailId)}
                            className={`text-[11px] px-3 py-1.5 rounded-full text-white ${
                              (taskStatuses[taskDetailId] || 'Requires decision') === 'Requires decision' ? 'bg-[#d45d78]' :
                              (taskStatuses[taskDetailId] || 'Awaiting quote') === 'Awaiting quote' ? 'bg-[#f194b2]' :
                              'bg-[#FFA726]'
                            }`}
                            style={{ fontWeight: 500 }}
                          >
                            {taskStatuses[taskDetailId] || 'Requires decision'}
                          </button>
                          {showStatusMenu === taskDetailId && (
                            <div className="absolute top-full right-0 mt-2 bg-white rounded-[16px] shadow-xl border border-gray-100 py-2 z-10 min-w-[200px]">
                              {['Requires decision', 'Awaiting quote', 'Pending confirmation', 'Waiting on response', 'Ready to finalize', 'Scheduled', 'Blocked'].map((status) => (
                                <button
                                  key={status}
                                  onClick={() => {
                                    setTaskStatuses({...taskStatuses, [taskDetailId]: status});
                                    setShowStatusMenu(null);
                                  }}
                                  className="w-full px-4 py-2 text-left text-[13px] text-gray-700 hover:bg-[#FAFAFA] transition-colors"
                                  style={{ fontWeight: 500 }}
                                >
                                  {status}
                                </button>
                              ))}
                            </div>
                          )}
                        </div>
                      </div>
                      <p className="text-[14px] text-gray-600 mb-3" style={{ lineHeight: 1.6 }}>
                        {taskDetailId === 1 ? 'This shapes your guest count and budget. Compare venue capacity, pricing, and availability before finalizing.' :
                         taskDetailId === 2 ? 'Floral costs typically increase 20-30% closer to summer. Secure your preferred florist now to lock in pricing.' :
                         'Catering needs confirmed numbers by Apr 15. Review dietary restrictions and finalize menu choices.'}
                      </p>
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="px-3 py-1 rounded-full text-[12px] bg-[#F0F9FA] text-[#285301]" style={{ fontWeight: 500 }}>
                          {taskDetailId === 1 ? 'Vendors' : taskDetailId === 2 ? 'Vendors' : 'Food & Dining'}
                        </span>
                        <span className="text-gray-400">•</span>
                        <span className="text-[12px] text-gray-600">Due Apr {taskDetailId === 1 ? '5' : taskDetailId === 2 ? '8' : '10'}</span>
                        <span className="text-gray-400">•</span>
                        <span className="text-[12px] text-gray-600">You + Planner</span>
                      </div>
                    </div>

                    {/* Progress Indicator */}
                    <div className="p-4 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[20px] border border-[#285301]/10">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-[13px] text-gray-700" style={{ fontWeight: 500 }}>Task progress</span>
                        <span className="text-[13px] text-[#285301]" style={{ fontWeight: 500 }}>65%</span>
                      </div>
                      <div className="w-full bg-white rounded-full h-2 mb-2">
                        <div className="bg-gradient-to-r from-[#285301] to-[#2A7B85] h-2 rounded-full transition-all" style={{ width: '65%' }} />
                      </div>
                      <p className="text-[11px] text-gray-500 italic">3 of 4 subtasks complete</p>
                    </div>

                    {/* Subtasks */}
                    <div>
                      <h4 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Subtasks</h4>
                      <div className="space-y-2">
                        {[
                          { label: 'Research venue options', done: true },
                          { label: 'Schedule site visits', done: true },
                          { label: 'Compare pricing quotes', done: true },
                          { label: 'Make final decision', done: false },
                        ].map((subtask, idx) => (
                          <div key={idx} className="flex items-center gap-3 p-3 bg-[#FAFAFA] rounded-[16px] hover:bg-gray-100 transition-colors cursor-pointer">
                            <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                              subtask.done ? 'border-[#285301] bg-[#285301]' : 'border-gray-300'
                            }`}>
                              {subtask.done && <Check size={12} className="text-white" />}
                            </div>
                            <span className={`text-[14px] ${subtask.done ? 'text-gray-400 line-through' : 'text-gray-800'}`}>
                              {subtask.label}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Linked Items */}
                    <div>
                      <h4 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Linked items</h4>
                      <div className="space-y-2">
                        <button className="w-full p-3 bg-white border border-gray-200 rounded-[16px] text-left hover:border-[#285301] transition-all flex items-center justify-between group">
                          <div className="flex items-center gap-3">
                            <Briefcase size={16} className="text-[#285301]" />
                            <div>
                              <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>Budget module</div>
                              <div className="text-[11px] text-gray-500">Affects venue allocation</div>
                            </div>
                          </div>
                          <ChevronRight size={16} className="text-gray-300 group-hover:text-[#285301] transition-colors" />
                        </button>
                        <button className="w-full p-3 bg-white border border-gray-200 rounded-[16px] text-left hover:border-[#285301] transition-all flex items-center justify-between group">
                          <div className="flex items-center gap-3">
                            <Users size={16} className="text-[#f194b2]" />
                            <div>
                              <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>Guest count</div>
                              <div className="text-[11px] text-gray-500">120 confirmed guests</div>
                            </div>
                          </div>
                          <ChevronRight size={16} className="text-gray-300 group-hover:text-[#285301] transition-colors" />
                        </button>
                      </div>
                    </div>

                    {/* Notes */}
                    <div>
                      <h4 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Notes</h4>
                      <textarea
                        className="w-full p-4 bg-[#FAFAFA] border border-gray-200 rounded-[16px] text-[14px] resize-none focus:outline-none focus:border-[#285301] transition-colors"
                        rows={4}
                        placeholder="Add notes about this task..."
                        defaultValue="Sunset Gardens has April availability. Ocean View requires $5k deposit. Need to decide by end of week."
                      />
                    </div>

                    {/* Comments */}
                    <div>
                      <h4 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Comments (2)</h4>
                      <div className="space-y-3">
                        <div className="p-3 bg-[#FAFAFA] rounded-[16px]">
                          <div className="flex items-center gap-2 mb-2">
                            <div className="w-6 h-6 rounded-full bg-gradient-to-br from-[#285301] to-[#2A7B85] flex items-center justify-center">
                              <span className="text-white text-[10px]" style={{ fontWeight: 500 }}>P</span>
                            </div>
                            <span className="text-[12px] text-gray-800" style={{ fontWeight: 500 }}>Planner</span>
                            <span className="text-[11px] text-gray-400">2h ago</span>
                          </div>
                          <p className="text-[13px] text-gray-700" style={{ lineHeight: 1.5 }}>
                            Sunset Gardens confirmed they can accommodate 120-150 guests. Their pricing includes setup and breakdown.
                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <input
                            type="text"
                            placeholder="Add a comment..."
                            className="flex-1 px-4 py-2.5 bg-[#FAFAFA] border border-gray-200 rounded-[16px] text-[13px] focus:outline-none focus:border-[#285301] transition-colors"
                          />
                          <button className="w-10 h-10 rounded-full bg-[#285301] hover:bg-[#2A7B85] flex items-center justify-center transition-colors">
                            <Send size={16} className="text-white" />
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="flex gap-3 pt-4 border-t border-gray-100">
                      <button
                        onClick={() => {
                          setCompletedTasks([...completedTasks, taskDetailId]);
                          setCompletionMessage(`${taskDetailId === 1 || taskDetailId === 2 ? 'Vendors' : 'Food & Dining'} updated • Progress increased`);
                          setShowCompletionToast(true);
                          setTaskDetailId(null);
                          setTimeout(() => setShowCompletionToast(false), 3000);
                        }}
                        className="flex-1 py-3 bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white rounded-[20px] text-[14px] hover:shadow-lg transition-all"
                        style={{ fontWeight: 500 }}
                      >
                        <Check size={16} className="inline mr-2 mb-0.5" />
                        Mark complete
                      </button>
                      <button className="px-6 py-3 bg-[#FAFAFA] text-gray-700 rounded-[20px] text-[14px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                        <Edit size={16} className="inline mr-2 mb-0.5" />
                        Edit
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </>
        )}

        {activeTab === 'budget' && (
          <>
            {/* Financial Snapshot - Richer Top Section */}
            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className="bg-gradient-to-br from-white to-[#FAFAFA] rounded-[24px] p-5 border border-gray-100">
                <div className="text-[11px] text-gray-500 mb-1" style={{ fontWeight: 400 }}>Total wedding budget</div>
                <div className="text-[32px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>
                  {budgetItems.length > 0 ? `$${totalBudget.toLocaleString()}` : '$45,000'}
                </div>
                <div className="text-[11px] text-gray-500">Set January 2026</div>
              </div>
              <div className="bg-gradient-to-br from-[#1F4D2B] to-[#285301] text-white rounded-[24px] p-5 relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-transparent" />
                <div className="relative">
                  <div className="text-[11px] opacity-90 mb-1" style={{ fontWeight: 400 }}>Remaining available</div>
                  <div className="text-[32px] mb-1" style={{ fontWeight: 500 }}>$13,500</div>
                  <div className="flex items-center gap-1.5">
                    <div className="px-2 py-0.5 bg-white/20 rounded-full text-[10px]" style={{ fontWeight: 500 }}>
                      Healthy pace
                    </div>
                    <span className="text-[11px] opacity-80">30% buffer</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-2 gap-2.5 mb-6">
              <div className="bg-white rounded-[18px] p-4 border border-gray-100">
                <div className="text-[11px] text-gray-500 mb-1">Committed</div>
                <div className="text-[20px] text-gray-800" style={{ fontWeight: 500 }}>$42,500</div>
              </div>
              <div className="bg-white rounded-[18px] p-4 border border-gray-100">
                <div className="text-[11px] text-gray-500 mb-1">Already paid</div>
                <div className="text-[20px] text-[#285301]" style={{ fontWeight: 500 }}>$31,500</div>
              </div>
              <div className="bg-white rounded-[18px] p-4 border border-gray-100">
                <div className="text-[11px] text-gray-500 mb-1">Due within 30 days</div>
                <div className="text-[20px] text-[#f194b2]" style={{ fontWeight: 500 }}>$4,200</div>
              </div>
              <div className="bg-white rounded-[18px] p-4 border border-gray-100">
                <div className="text-[11px] text-gray-500 mb-1">Estimated final</div>
                <div className="text-[20px] text-gray-800" style={{ fontWeight: 500 }}>$44,100</div>
              </div>
            </div>

            {/* Intelligent Insights */}
            <button
              onClick={() => setBudgetInsightsOpen(!budgetInsightsOpen)}
              className="w-full bg-gradient-to-br from-[#F0F9FA] to-white rounded-[20px] p-4 border border-[#285301]/20 mb-6 text-left hover:shadow-md transition-all"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#285301] to-[#2A7B85] flex items-center justify-center">
                    <Info size={18} className="text-white" />
                  </div>
                  <div>
                    <div className="text-[14px] text-gray-800 mb-0.5" style={{ fontWeight: 500 }}>
                      Financial insights
                    </div>
                    <div className="text-[12px] text-gray-500">
                      3 recommendations • 1 opportunity
                    </div>
                  </div>
                </div>
                <ChevronRight
                  size={18}
                  className={`text-gray-400 transition-transform ${budgetInsightsOpen ? 'rotate-90' : ''}`}
                />
              </div>
            </button>

            {budgetInsightsOpen && (
              <div className="mb-6 space-y-2 animate-fadeIn">
                {[
                  { type: 'success', message: 'You are currently 8% under your projected floral budget', icon: '✓' },
                  { type: 'info', message: 'Venue spending is finalized and fully paid', icon: 'ℹ' },
                  { type: 'opportunity', message: 'Entertainment still has room for upgrades', icon: '✨' },
                  { type: 'warning', message: 'Three vendors require deposits within 7 days', icon: '⚠' },
                ].map((insight, idx) => (
                  <div
                    key={idx}
                    className={`p-3 rounded-[16px] flex items-start gap-3 ${
                      insight.type === 'success' ? 'bg-gradient-to-r from-[#E8F3EC] to-white border border-[#1F4D2B]/10' :
                      insight.type === 'warning' ? 'bg-gradient-to-r from-[#FFF5F8] to-white border border-[#f194b2]/20' :
                      insight.type === 'opportunity' ? 'bg-gradient-to-r from-[#FFF5EB] to-white border border-[#FFA726]/20' :
                      'bg-gradient-to-r from-[#F0F9FA] to-white border border-[#285301]/10'
                    }`}
                    style={{ animationDelay: `${idx * 0.05}s` }}
                  >
                    <span className="text-[16px] flex-shrink-0">{insight.icon}</span>
                    <p className="text-[13px] text-gray-700 flex-1" style={{ lineHeight: 1.5 }}>
                      {insight.message}
                    </p>
                  </div>
                ))}
              </div>
            )}

            {/* Expandable Category Cards */}
            <div className="mb-6">
              <h3 className="text-[18px] text-[#1F4D2B] mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                By category
              </h3>
              <div className="space-y-3">
                {[
                  {
                    id: 'venue',
                    category: 'Venue',
                    allocated: 12000,
                    spent: 12000,
                    status: 'Fully secured • Paid in full',
                    vendors: [{ name: 'Sunset Gardens', amount: 12000, paid: true }],
                    color: '#1F4D2B'
                  },
                  {
                    id: 'food',
                    category: 'Food & Drink',
                    allocated: 10000,
                    spent: 8500,
                    status: '2 pending catering adjustments',
                    vendors: [
                      { name: 'Gourmet Affairs', amount: 7500, paid: true },
                      { name: 'Wine Selection', amount: 1000, paid: false }
                    ],
                    color: '#285301'
                  },
                  {
                    id: 'photo',
                    category: 'Photography',
                    allocated: 4500,
                    spent: 3500,
                    status: 'Final payment due in 14 days',
                    vendors: [{ name: 'Emma Stone Photography', amount: 4500, paid: false, due: 'Apr 15' }],
                    color: '#f194b2'
                  },
                  {
                    id: 'decor',
                    category: 'Decor & Flowers',
                    allocated: 4000,
                    spent: 2800,
                    status: 'Budget flexibility available',
                    vendors: [{ name: 'Petal Perfection', amount: 2800, paid: true }],
                    color: '#285301'
                  },
                ].map((item) => (
                  <div
                    key={item.id}
                    className={`bg-white rounded-[20px] border overflow-hidden transition-all duration-300 ${
                      expandedCategoryId === item.id ? 'border-[#285301] shadow-lg' : 'border-gray-100 hover:border-gray-200 hover:shadow-md'
                    }`}
                  >
                    <button
                      onClick={() => setExpandedCategoryId(expandedCategoryId === item.id ? null : item.id)}
                      className="w-full p-4 text-left"
                    >
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1">
                          <div className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>
                            {item.category}
                          </div>
                          <div className="text-[12px] text-gray-500 mb-2">
                            {item.status}
                          </div>
                          <div className="text-[13px] text-gray-600">
                            ${item.spent.toLocaleString()} / ${item.allocated.toLocaleString()}
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className={`px-2.5 py-1 rounded-full text-[10px] text-white ${
                            item.spent === item.allocated ? 'bg-[#1F4D2B]' :
                            item.spent / item.allocated > 0.9 ? 'bg-[#f194b2]' :
                            'bg-[#285301]'
                          }`} style={{ fontWeight: 500 }}>
                            {Math.round((item.spent / item.allocated) * 100)}%
                          </span>
                          <ChevronRight
                            size={16}
                            className={`text-gray-400 transition-transform ${expandedCategoryId === item.id ? 'rotate-90' : ''}`}
                          />
                        </div>
                      </div>
                      <div className="w-full bg-[#FAFAFA] rounded-full h-2 overflow-hidden">
                        <div
                          className="h-2 rounded-full transition-all duration-500"
                          style={{
                            width: `${(item.spent / item.allocated) * 100}%`,
                            background: `linear-gradient(to right, ${item.color}, ${item.color}dd)`
                          }}
                        />
                      </div>
                    </button>

                    {/* Expanded Content */}
                    {expandedCategoryId === item.id && (
                      <div className="px-4 pb-4 border-t border-gray-100 pt-4 animate-fadeIn">
                        <div className="space-y-3">
                          <div>
                            <div className="text-[13px] text-gray-700 mb-2" style={{ fontWeight: 500 }}>Vendors</div>
                            {item.vendors.map((vendor, idx) => (
                              <div key={idx} className="p-3 bg-[#FAFAFA] rounded-[16px] mb-2">
                                <div className="flex items-center justify-between mb-1">
                                  <span className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>
                                    {vendor.name}
                                  </span>
                                  <span className={`text-[12px] ${vendor.paid ? 'text-[#1F4D2B]' : 'text-[#f194b2]'}`} style={{ fontWeight: 500 }}>
                                    ${vendor.amount.toLocaleString()}
                                  </span>
                                </div>
                                <div className="flex items-center gap-2">
                                  <span className={`px-2 py-0.5 rounded-full text-[10px] ${
                                    vendor.paid ? 'bg-[#E8F3EC] text-[#1F4D2B]' : 'bg-[#FFF5F8] text-[#f194b2]'
                                  }`} style={{ fontWeight: 500 }}>
                                    {vendor.paid ? 'Paid' : 'Pending'}
                                  </span>
                                  {('due' in vendor) && vendor.due && (
                                    <span className="text-[11px] text-gray-500">Due {vendor.due}</span>
                                  )}
                                </div>
                              </div>
                            ))}
                          </div>
                          <div className="flex gap-2">
                            <button className="flex-1 py-2 bg-[#FAFAFA] text-gray-700 rounded-[16px] text-[12px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                              Add vendor
                            </button>
                            <button className="flex-1 py-2 bg-[#285301] text-white rounded-[16px] text-[12px] hover:bg-[#2A7B85] transition-colors" style={{ fontWeight: 500 }}>
                              View invoices
                            </button>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Recent Expenses - Premium Activity Feed */}
            <div className="mb-6">
              <h3 className="text-[18px] text-[#1F4D2B] mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Recent activity
              </h3>
              <div className="space-y-2">
                {[
                  {
                    id: 1,
                    vendor: 'Gourmet Affairs',
                    amount: 1500,
                    date: 'Mar 28',
                    category: 'Food & Drink',
                    status: 'Deposit paid',
                    approvedBy: 'Planner',
                    remaining: 6000,
                    remainingDue: 'May 15'
                  },
                  {
                    id: 2,
                    vendor: 'Petal Perfection',
                    amount: 800,
                    date: 'Mar 25',
                    category: 'Decor & Flowers',
                    status: 'Paid in full',
                    approvedBy: 'You'
                  },
                  {
                    id: 3,
                    vendor: 'Sunset Gardens',
                    amount: 3000,
                    date: 'Mar 20',
                    category: 'Venue',
                    status: 'First installment',
                    approvedBy: 'You',
                    remaining: 9000,
                    remainingDue: 'Apr 1'
                  },
                ].map((expense) => (
                  <div
                    key={expense.id}
                    className={`bg-white rounded-[20px] border transition-all duration-200 cursor-pointer overflow-hidden ${
                      expandedExpenseId === expense.id ? 'border-[#285301] shadow-md' : 'border-gray-100 hover:border-gray-200 hover:shadow-sm'
                    }`}
                  >
                    <button
                      onClick={() => setExpandedExpenseId(expandedExpenseId === expense.id ? null : expense.id)}
                      className="w-full p-4 text-left"
                    >
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#F0F9FA] to-[#E8F4F5] flex items-center justify-center flex-shrink-0">
                          <Briefcase size={16} className="text-[#285301]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-start justify-between mb-1">
                            <div className="flex-1">
                              <div className="text-[14px] text-gray-800 mb-0.5" style={{ fontWeight: 500 }}>
                                {expense.vendor}
                              </div>
                              <div className="text-[12px] text-gray-500">
                                {expense.status} • {expense.category}
                              </div>
                            </div>
                            <div className="text-[15px] text-gray-800 text-right" style={{ fontWeight: 500 }}>
                              ${expense.amount.toLocaleString()}
                            </div>
                          </div>
                          <div className="flex items-center gap-2 text-[11px] text-gray-400 mt-2">
                            <span>{expense.date}</span>
                            <span>•</span>
                            <span>Approved by {expense.approvedBy}</span>
                          </div>
                          {expense.remaining && expandedExpenseId !== expense.id && (
                            <div className="mt-2 text-[11px] text-[#f194b2]">
                              ${expense.remaining.toLocaleString()} remaining due {expense.remainingDue}
                            </div>
                          )}
                        </div>
                      </div>
                    </button>

                    {/* Expanded Expense Detail */}
                    {expandedExpenseId === expense.id && (
                      <div className="px-4 pb-4 border-t border-gray-100 pt-4 animate-fadeIn">
                        <div className="space-y-3">
                          {expense.remaining && (
                            <div className="p-3 bg-[#FFF5F8] rounded-[16px] border border-[#f194b2]/20">
                              <div className="text-[12px] text-gray-700 mb-1" style={{ fontWeight: 500 }}>
                                Payment schedule
                              </div>
                              <div className="text-[13px] text-gray-600">
                                Remaining balance: ${expense.remaining.toLocaleString()}
                              </div>
                              <div className="text-[11px] text-[#f194b2] mt-1">
                                Due {expense.remainingDue}
                              </div>
                            </div>
                          )}
                          <div className="grid grid-cols-2 gap-2">
                            <button className="py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[12px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                              <Upload size={12} className="inline mr-1.5 mb-0.5" />
                              View receipt
                            </button>
                            <button className="py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[12px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                              <Edit size={12} className="inline mr-1.5 mb-0.5" />
                              Edit details
                            </button>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Premium Add Expense Button */}
            <button
              onClick={() => setShowAddExpenseFlow(true)}
              className="w-full bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white py-3.5 rounded-[20px] flex items-center justify-center shadow-md hover:shadow-lg transition-all active:scale-98"
              style={{ fontWeight: 500 }}
            >
              <Plus size={18} className="mr-2" />
              Add expense
            </button>

            {/* Add Expense Modal - Guided Flow */}
            {showAddExpenseFlow && (
              <div
                className="fixed inset-0 bg-black/40 z-50 flex items-end"
                onClick={() => setShowAddExpenseFlow(false)}
              >
                <div
                  className="bg-white w-full rounded-t-[32px] max-h-[90vh] overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                  style={{ animation: 'slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1)' }}
                >
                  <div className="sticky top-0 bg-white pt-4 pb-2 px-6 border-b border-gray-100 z-10">
                    <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
                    <div className="flex items-center justify-between">
                      <h2 className="text-[20px] text-[#1F4D2B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                        Add expense
                      </h2>
                      <button
                        onClick={() => setShowAddExpenseFlow(false)}
                        className="w-8 h-8 rounded-full bg-[#FAFAFA] hover:bg-gray-200 flex items-center justify-center transition-colors"
                      >
                        <X size={18} className="text-gray-600" />
                      </button>
                    </div>
                  </div>

                  <div className="p-6 space-y-5">
                    {/* Vendor Search */}
                    <div>
                      <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>
                        Vendor or description
                      </label>
                      <input
                        type="text"
                        placeholder="Search vendors or enter name..."
                        className="w-full px-4 py-3 bg-[#FAFAFA] border border-gray-200 rounded-[16px] text-[14px] focus:outline-none focus:border-[#285301] transition-colors"
                      />
                    </div>

                    {/* Amount */}
                    <div>
                      <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>
                        Amount
                      </label>
                      <div className="relative">
                        <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 text-[14px]">$</span>
                        <input
                          type="number"
                          placeholder="0.00"
                          className="w-full pl-8 pr-4 py-3 bg-[#FAFAFA] border border-gray-200 rounded-[16px] text-[14px] focus:outline-none focus:border-[#285301] transition-colors"
                        />
                      </div>
                    </div>

                    {/* Smart Categorization */}
                    <div>
                      <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>
                        Category
                      </label>
                      <div className="grid grid-cols-2 gap-2">
                        {['Venue', 'Food & Drink', 'Photography', 'Decor & Flowers', 'Entertainment', 'Attire'].map((cat) => (
                          <button
                            key={cat}
                            className="py-2.5 px-3 bg-[#FAFAFA] border border-gray-200 rounded-[14px] text-[13px] text-gray-700 hover:border-[#285301] hover:bg-[#F0F9FA] transition-all"
                            style={{ fontWeight: 500 }}
                          >
                            {cat}
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Payment Status */}
                    <div>
                      <label className="text-[13px] text-gray-700 mb-2 block" style={{ fontWeight: 500 }}>
                        Payment status
                      </label>
                      <div className="flex gap-2">
                        {['Paid', 'Pending', 'Installment'].map((status) => (
                          <button
                            key={status}
                            className="flex-1 py-2.5 bg-[#FAFAFA] border border-gray-200 rounded-[14px] text-[13px] text-gray-700 hover:border-[#285301] hover:bg-[#F0F9FA] transition-all"
                            style={{ fontWeight: 500 }}
                          >
                            {status}
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Budget Impact Preview */}
                    <div className="p-4 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[16px] border border-[#285301]/20">
                      <div className="flex items-start gap-3">
                        <Info size={16} className="text-[#285301] flex-shrink-0 mt-0.5" />
                        <div>
                          <div className="text-[12px] text-gray-700 mb-1" style={{ fontWeight: 500 }}>
                            Budget impact
                          </div>
                          <p className="text-[11px] text-gray-600" style={{ lineHeight: 1.5 }}>
                            This will update your category allocation. You'll see the impact before saving.
                          </p>
                        </div>
                      </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="flex gap-3 pt-2">
                      <button
                        onClick={() => setShowAddExpenseFlow(false)}
                        className="flex-1 py-3 bg-[#FAFAFA] text-gray-700 rounded-[20px] text-[14px] hover:bg-gray-100 transition-colors"
                        style={{ fontWeight: 500 }}
                      >
                        Cancel
                      </button>
                      <button
                        onClick={() => setShowAddExpenseFlow(false)}
                        className="flex-1 py-3 bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white rounded-[20px] text-[14px] hover:shadow-lg transition-all"
                        style={{ fontWeight: 500 }}
                      >
                        Save expense
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </>
        )}

        {activeTab === 'vendors' && (
          <>
            {/* Intelligent Planning Insight Cards */}
            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className="bg-gradient-to-br from-[#E8F3EC] to-white rounded-[20px] p-4 border border-[#1F4D2B]/10">
                <div className="text-[24px] text-[#1F4D2B] mb-1" style={{ fontWeight: 500 }}>8</div>
                <div className="text-[11px] text-gray-600 mb-2" style={{ fontWeight: 400 }}>Fully secured</div>
                <div className="text-[10px] text-[#1F4D2B]" style={{ fontWeight: 500 }}>All contracts signed</div>
              </div>
              <div className="bg-gradient-to-br from-[#FFF5F8] to-white rounded-[20px] p-4 border border-[#f194b2]/20">
                <div className="text-[24px] text-[#f194b2] mb-1" style={{ fontWeight: 500 }}>2</div>
                <div className="text-[11px] text-gray-600 mb-2" style={{ fontWeight: 400 }}>Awaiting response</div>
                <div className="text-[10px] text-[#f194b2]" style={{ fontWeight: 500 }}>Quotes pending</div>
              </div>
              <div className="bg-gradient-to-br from-[#F0F9FA] to-white rounded-[20px] p-4 border border-[#285301]/10">
                <div className="text-[24px] text-[#285301] mb-1" style={{ fontWeight: 500 }}>1</div>
                <div className="text-[11px] text-gray-600 mb-2" style={{ fontWeight: 400 }}>Deposit due</div>
                <div className="text-[10px] text-[#285301]" style={{ fontWeight: 500 }}>Florist • 3 days</div>
              </div>
              <div className="bg-gradient-to-br from-[#FFF5EB] to-white rounded-[20px] p-4 border border-[#FFA726]/20">
                <div className="text-[24px] text-[#FFA726] mb-1" style={{ fontWeight: 500 }}>3</div>
                <div className="text-[11px] text-gray-600 mb-2" style={{ fontWeight: 400 }}>Still needed</div>
                <div className="text-[10px] text-[#FFA726]" style={{ fontWeight: 500 }}>Key categories</div>
              </div>
            </div>

            {/* AI Intelligence Insights */}
            <div className="mb-6 p-4 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[20px] border border-[#285301]/20">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#285301] to-[#2A7B85] flex items-center justify-center flex-shrink-0">
                  <span className="text-white text-[14px]">✨</span>
                </div>
                <div className="flex-1">
                  <div className="text-[13px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>Vendor insights</div>
                  <p className="text-[12px] text-gray-600 mb-2" style={{ lineHeight: 1.5 }}>
                    Photographers in your area are booking quickly for June weddings.
                  </p>
                  <p className="text-[11px] text-[#285301]" style={{ fontWeight: 500 }}>
                    Your venue timeline may require additional lighting vendors →
                  </p>
                </div>
              </div>
            </div>

            {/* Category Filter */}
            <div className="flex gap-2 overflow-x-auto mb-6 pb-1">
              {['All', 'Booked', 'Shortlisted', 'Needed'].map((filter) => (
                <button
                  key={filter}
                  onClick={() => setVendorFilter(filter)}
                  className={`px-3 py-1.5 rounded-full whitespace-nowrap text-[12px] transition-all ${
                    vendorFilter === filter
                      ? 'bg-[#285301] text-white shadow-md scale-105'
                      : 'bg-[#FAFAFA] text-gray-700 hover:bg-gray-100 hover:scale-102'
                  }`}
                  style={{ fontWeight: 500 }}
                >
                  {filter}
                </button>
              ))}
            </div>

            {/* Booked Vendors - Rich Expandable Cards */}
            {(vendorFilter === 'All' || vendorFilter === 'Booked') && (
              <div className="mb-6">
                <h3 className="text-[18px] text-[#1F4D2B] mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                  Your wedding team
                </h3>
                <div className="space-y-3">
                  {vendors.filter(v => v.status === 'Booked').map((vendor, idx) => {
                    const vendorId = `${vendor.category}-${idx}`;
                    const isExpanded = expandedVendorId === vendorId;

                    return (
                      <div
                        key={vendorId}
                        className={`bg-white rounded-[20px] border overflow-hidden transition-all duration-300 ${
                          isExpanded ? 'border-[#285301] shadow-lg' : 'border-gray-100 hover:border-gray-200 hover:shadow-md'
                        }`}
                      >
                        <button
                          onClick={() => setExpandedVendorId(isExpanded ? null : vendorId)}
                          className="w-full p-4 text-left"
                        >
                          <div className="flex items-start gap-3">
                            {/* Vendor Icon/Photo */}
                            <div className="w-12 h-12 rounded-[16px] bg-gradient-to-br from-[#F0F9FA] to-[#E8F4F5] flex items-center justify-center flex-shrink-0">
                              <Briefcase size={20} className="text-[#285301]" />
                            </div>

                            {/* Vendor Info */}
                            <div className="flex-1 min-w-0">
                              <div className="flex items-start justify-between mb-1">
                                <div className="flex-1">
                                  <div className="text-[11px] text-gray-500 mb-0.5">{vendor.category}</div>
                                  <h4 className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>
                                    {vendor.name}
                                  </h4>
                                  <div className="flex items-center gap-2 text-[11px] text-gray-500 mb-2">
                                    <span className="px-2 py-0.5 bg-[#E8F3EC] text-[#1F4D2B] rounded-full text-[10px]" style={{ fontWeight: 500 }}>
                                      Contract signed
                                    </span>
                                    <span>•</span>
                                    <span>Booked {vendor.dateBooked}</span>
                                  </div>
                                  <div className="text-[12px] text-gray-600">
                                    Deposit paid • Final walkthrough May 12
                                  </div>
                                </div>
                                <ChevronRight
                                  size={16}
                                  className={`text-gray-400 transition-transform flex-shrink-0 ml-2 ${isExpanded ? 'rotate-90' : ''}`}
                                />
                              </div>

                              {/* Quick stats when collapsed */}
                              {!isExpanded && (
                                <div className="flex items-center gap-3 text-[11px] text-gray-400 mt-2">
                                  <span className="flex items-center gap-1">
                                    <MessageSquare size={10} />2 notes
                                  </span>
                                  <span className="flex items-center gap-1">
                                    <Upload size={10} />1 attachment
                                  </span>
                                  <span className="flex items-center gap-1">
                                    <Check size={10} />1 task
                                  </span>
                                </div>
                              )}
                            </div>
                          </div>
                        </button>

                        {/* Expanded Vendor Detail */}
                        {isExpanded && (
                          <div className="px-4 pb-4 border-t border-gray-100 pt-4 animate-fadeIn">
                            <div className="space-y-4">
                              {/* Payment Progress */}
                              <div>
                                <div className="flex items-center justify-between mb-2">
                                  <span className="text-[12px] text-gray-700" style={{ fontWeight: 500 }}>Payment progress</span>
                                  <span className="text-[12px] text-[#285301]" style={{ fontWeight: 500 }}>$3,000 / $12,000</span>
                                </div>
                                <div className="w-full bg-[#FAFAFA] rounded-full h-2">
                                  <div className="bg-gradient-to-r from-[#285301] to-[#2A7B85] h-2 rounded-full" style={{ width: '25%' }} />
                                </div>
                                <p className="text-[11px] text-gray-500 mt-1">Next payment: $9,000 due May 1</p>
                              </div>

                              {/* Communication Status */}
                              <div className="grid grid-cols-2 gap-2">
                                <div className="p-3 bg-[#FAFAFA] rounded-[14px]">
                                  <div className="text-[11px] text-gray-500 mb-0.5">Last contact</div>
                                  <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>3 days ago</div>
                                </div>
                                <div className="p-3 bg-[#FAFAFA] rounded-[14px]">
                                  <div className="text-[11px] text-gray-500 mb-0.5">Response time</div>
                                  <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>{'< 24h'}</div>
                                </div>
                              </div>

                              {/* Vendor Contacts */}
                              <div>
                                <div className="text-[12px] text-gray-700 mb-2" style={{ fontWeight: 500 }}>Contacts</div>
                                <div className="space-y-2">
                                  <div className="p-2 bg-[#F0F9FA] rounded-[12px] flex items-center justify-between">
                                    <div>
                                      <div className="text-[12px] text-gray-800" style={{ fontWeight: 500 }}>Sarah Martinez</div>
                                      <div className="text-[11px] text-gray-500">Event coordinator</div>
                                    </div>
                                    <div className="flex gap-1.5">
                                      <button className="w-8 h-8 rounded-full bg-white hover:bg-gray-50 flex items-center justify-center transition-colors">
                                        <MessageSquare size={14} className="text-[#285301]" />
                                      </button>
                                      <button className="w-8 h-8 rounded-full bg-white hover:bg-gray-50 flex items-center justify-center transition-colors">
                                        <Mail size={14} className="text-[#285301]" />
                                      </button>
                                    </div>
                                  </div>
                                </div>
                              </div>

                              {/* Notes & Tasks */}
                              <div>
                                <div className="text-[12px] text-gray-700 mb-2" style={{ fontWeight: 500 }}>Notes & tasks</div>
                                <div className="p-3 bg-[#FAFAFA] rounded-[14px] mb-2">
                                  <p className="text-[12px] text-gray-600" style={{ lineHeight: 1.5 }}>
                                    Confirmed ceremony setup at 2 PM. Need to follow up on lighting preferences.
                                  </p>
                                </div>
                                <div className="flex items-center gap-2 p-2 bg-[#FFF5F8] rounded-[12px] border border-[#f194b2]/20">
                                  <div className="w-4 h-4 rounded border-2 border-[#f194b2]" />
                                  <span className="text-[12px] text-gray-700 flex-1">Send final floor plan by Apr 15</span>
                                </div>
                              </div>

                              {/* Action Buttons */}
                              <div className="grid grid-cols-3 gap-2">
                                <button className="py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[11px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                                  <Upload size={12} className="inline mr-1 mb-0.5" />
                                  Files
                                </button>
                                <button className="py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[11px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                                  <DollarSign size={12} className="inline mr-1 mb-0.5" />
                                  Invoice
                                </button>
                                <button className="py-2 bg-[#285301] text-white rounded-[14px] text-[11px] hover:bg-[#2A7B85] transition-colors" style={{ fontWeight: 500 }}>
                                  <MessageSquare size={12} className="inline mr-1 mb-0.5" />
                                  Message
                                </button>
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Shortlisted - Visual Comparison Cards */}
            {(vendorFilter === 'All' || vendorFilter === 'Shortlisted') && (
              <div className="mb-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-[18px] text-[#1F4D2B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                    Under review
                  </h3>
                  <button
                    onClick={() => setShowVendorComparison(true)}
                    className="text-[12px] text-[#285301] hover:underline" style={{ fontWeight: 500 }}
                  >
                    Compare all →
                  </button>
                </div>
                <div className="space-y-3">
                  {vendors.filter(v => v.status === 'Shortlisted').map((vendor, idx) => (
                    <div key={idx} className="bg-white rounded-[20px] p-4 border border-gray-100 hover:border-[#285301] hover:shadow-md transition-all cursor-pointer">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1">
                          <h4 className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{vendor.category}</h4>
                          <p className="text-[13px] text-gray-600 mb-2">{vendor.shortlistedCount} vendors • Comparing pricing and style</p>
                        </div>
                        <span className="px-2.5 py-1 rounded-full text-[10px] text-white bg-[#f194b2]" style={{ fontWeight: 500 }}>
                          Review
                        </span>
                      </div>
                      <div className="flex gap-2">
                        <button
                          onClick={() => setShowVendorComparison(true)}
                          className="flex-1 py-2 bg-[#285301] text-white rounded-[14px] text-[12px] hover:bg-[#2A7B85] transition-colors"
                          style={{ fontWeight: 500 }}
                        >
                          Compare options
                        </button>
                        <button className="px-4 py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[12px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                          Schedule calls
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Still Needed - Actionable Recommendation Cards */}
            {(vendorFilter === 'All' || vendorFilter === 'Needed') && (
              <div className="mb-6">
                <h3 className="text-[18px] text-[#1F4D2B] mb-4" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                  Recommended next steps
                </h3>
                <div className="space-y-3">
                  {[
                    {
                      category: 'Hair & Makeup',
                      recommendation: '4 recommended artists nearby',
                      timeline: 'Average booking: 5 months ahead',
                      available: '2 highly rated matches available'
                    },
                    {
                      category: 'Cake',
                      recommendation: '3 luxury bakers match your aesthetic',
                      timeline: 'Book 3-4 months in advance',
                      available: 'Tasting appointments available'
                    },
                    {
                      category: 'Transport',
                      recommendation: 'Guest shuttle planning incomplete',
                      timeline: 'Setup recommended now',
                      available: 'Airport transfer coordination needed'
                    },
                  ].map((item, idx) => (
                    <div
                      key={idx}
                      className="bg-gradient-to-br from-white to-[#FAFAFA] rounded-[20px] p-4 border border-gray-100 hover:border-[#285301] hover:shadow-md transition-all"
                    >
                      <div className="flex items-start gap-3 mb-3">
                        <div className="w-10 h-10 rounded-[14px] bg-gradient-to-br from-[#FFF5EB] to-[#FFE8D6] flex items-center justify-center flex-shrink-0">
                          <span className="text-[16px]">✨</span>
                        </div>
                        <div className="flex-1">
                          <h4 className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{item.category}</h4>
                          <p className="text-[12px] text-gray-600 mb-1" style={{ lineHeight: 1.5 }}>{item.recommendation}</p>
                          <div className="flex items-center gap-2 text-[11px] text-gray-500">
                            <span>{item.timeline}</span>
                            <span>•</span>
                            <span className="text-[#285301]">{item.available}</span>
                          </div>
                        </div>
                      </div>
                      <div className="grid grid-cols-2 gap-2">
                        <button
                          onClick={() => setActiveFormModal('add-vendor')}
                          className="py-2 bg-[#285301] text-white rounded-[14px] text-[12px] hover:bg-[#2A7B85] transition-colors"
                          style={{ fontWeight: 500 }}
                        >
                          Browse vendors
                        </button>
                        <button className="py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[12px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                          Request quotes
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Add Vendor Button */}
            <button
              onClick={() => setActiveFormModal('add-vendor')}
              className="w-full bg-gradient-to-r from-[#285301] to-[#2A7B85] text-white py-3.5 rounded-[20px] flex items-center justify-center shadow-md hover:shadow-lg transition-all active:scale-98"
              style={{ fontWeight: 500 }}
            >
              <Plus size={18} className="mr-2" />
              Add vendor
            </button>

            {/* Vendor Comparison Modal */}
            {showVendorComparison && (
              <div
                className="fixed inset-0 bg-black/40 z-50 flex items-end"
                onClick={() => setShowVendorComparison(false)}
              >
                <div
                  className="bg-white w-full rounded-t-[32px] max-h-[90vh] overflow-y-auto"
                  onClick={(e) => e.stopPropagation()}
                  style={{ animation: 'slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1)' }}
                >
                  <div className="sticky top-0 bg-white pt-4 pb-2 px-6 border-b border-gray-100 z-10">
                    <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-4" />
                    <div className="flex items-center justify-between">
                      <h2 className="text-[20px] text-[#1F4D2B]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                        Compare vendors
                      </h2>
                      <button
                        onClick={() => setShowVendorComparison(false)}
                        className="w-8 h-8 rounded-full bg-[#FAFAFA] hover:bg-gray-200 flex items-center justify-center transition-colors"
                      >
                        <X size={18} className="text-gray-600" />
                      </button>
                    </div>
                  </div>

                  <div className="p-6 space-y-4">
                    {/* Comparison Grid */}
                    <div className="grid grid-cols-1 gap-4">
                      {['Videographer A', 'Videographer B', 'Videographer C'].map((name, idx) => (
                        <div key={idx} className="bg-gradient-to-br from-white to-[#FAFAFA] rounded-[20px] p-4 border border-gray-100">
                          <div className="flex items-start gap-3 mb-3">
                            <div className="w-16 h-16 rounded-[16px] bg-gradient-to-br from-[#F0F9FA] to-[#E8F4F5] flex items-center justify-center flex-shrink-0">
                              <Image size={24} className="text-[#285301]" />
                            </div>
                            <div className="flex-1">
                              <h4 className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{name}</h4>
                              <div className="flex items-center gap-2 mb-2">
                                <span className="px-2 py-0.5 bg-[#F0F9FA] text-[#285301] rounded-full text-[10px]" style={{ fontWeight: 500 }}>
                                  Luxury cinematic feel
                                </span>
                                <span className="text-[11px] text-gray-500">4.9★</span>
                              </div>
                              <div className="text-[18px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>
                                ${2500 + (idx * 500)}
                              </div>
                              <p className="text-[11px] text-gray-500">
                                {idx === 0 ? '8 hours • 2 shooters • Highlights reel' : idx === 1 ? '10 hours • 2 shooters • Full ceremony' : '6 hours • 1 shooter • Edited film'}
                              </p>
                            </div>
                          </div>
                          <div className="grid grid-cols-2 gap-2">
                            <button className="py-2 bg-[#285301] text-white rounded-[14px] text-[12px] hover:bg-[#2A7B85] transition-colors" style={{ fontWeight: 500 }}>
                              Book call
                            </button>
                            <button className="py-2 bg-[#FAFAFA] text-gray-700 rounded-[14px] text-[12px] hover:bg-gray-100 transition-colors" style={{ fontWeight: 500 }}>
                              View portfolio
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            )}
          </>
        )}

        {activeTab === 'wedding-party' && <WeddingPartyPage />}

        {activeTab === 'details' && (
          <>
            {/* Wedding Details */}
            <div className="bg-gradient-to-br from-[#FAFAFA]/40 to-white rounded-[20px] p-6 border border-gray-100 mb-6">
              <h3 className="text-[20px] text-[#d45d78] mb-5" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                Wedding details
              </h3>
              <div className="space-y-4">
                <div className="flex items-center justify-between py-3 border-b border-gray-100">
                  <div>
                    <div className="text-[13px] text-gray-900 mb-1" style={{ fontWeight: 500 }}>Date</div>
                    <div className="text-[12px] text-gray-600">Saturday, June 15, 2024</div>
                  </div>
                  <button onClick={() => setActiveFormModal('edit-wedding-details')} className="text-[13px] text-[#285301]" style={{ fontWeight: 500 }}>
                    Edit
                  </button>
                </div>
                <div className="flex items-center justify-between py-3 border-b border-gray-100">
                  <div>
                    <div className="text-[13px] text-gray-900 mb-1" style={{ fontWeight: 500 }}>Location</div>
                    <div className="text-[12px] text-gray-600">Sunset Gardens, Malibu, CA</div>
                  </div>
                  <button onClick={() => setActiveFormModal('edit-wedding-details')} className="text-[13px] text-[#285301]" style={{ fontWeight: 500 }}>
                    Edit
                  </button>
                </div>
                <div className="flex items-center justify-between py-3">
                  <div>
                    <div className="text-[13px] text-gray-900 mb-1" style={{ fontWeight: 500 }}>Guest count</div>
                    <div className="text-[12px] text-gray-600">120 guests</div>
                  </div>
                  <button onClick={() => setActiveFormModal('edit-wedding-details')} className="text-[13px] text-[#285301]" style={{ fontWeight: 500 }}>
                    Edit
                  </button>
                </div>
              </div>
            </div>
          </>
        )}
      </div>

      {/* PLAN OVERVIEW MODALS */}
      <PlanOverviewModals
        activeModal={activeModal}
        onClose={() => setActiveModal(null)}
        onOpenFormModal={(modal) => setActiveFormModal(modal as FormModalType)}
        onNavigateToTab={(tab) => setActiveTab(tab as PlanTab)}
      />

      {/* ADDITIONAL EVENTS MODAL */}
      {activeModal === 'additional-events' && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setActiveModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[26px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Additional events</h2>
              <button onClick={() => setActiveModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="mb-6">
              <div className="w-full bg-[#FAFAFA]/60 rounded-full h-1.5 mb-2">
                <div className="bg-[#285301] h-1.5 rounded-full" style={{ width: '50%' }}></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Keep extra moments organized without letting them take over the day.
              </p>
            </div>

            <div className="space-y-3 mb-6">
              {events.length === 0 ? (
                <div className="text-center py-8 text-gray-400 text-[14px]">No events yet — add them in the Timeline section.</div>
              ) : events.map((event, idx) => (
                <div key={idx} className="bg-[#fefdfb] rounded-[20px] p-4 border border-gray-100">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <h4 className="text-[15px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{event.name}</h4>
                      {event.time && <p className="text-[13px] text-[#d45d78] mb-2" style={{ fontWeight: 500 }}>{event.time}</p>}
                      {event.location && <p className="text-[12px] text-gray-600" style={{ fontWeight: 400 }}>{event.location}</p>}
                    </div>
                    <button onClick={() => setActiveFormModal('add-additional-event')} className="text-gray-400 hover:text-[#d45d78]">
                      <Edit size={16} />
                    </button>
                  </div>
                </div>
              ))}
            </div>

            <button onClick={() => setActiveFormModal('add-additional-event')} className="w-full bg-[#285301] text-white py-3 rounded-[20px] flex items-center justify-center" style={{ fontWeight: 500 }}>
              <Plus size={18} className="mr-2" />
              Add additional event
            </button>
          </div>
        </div>
      )}

      {/* PERSONAL MOMENTS MODAL */}
      {activeModal === 'personal-moments' && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setActiveModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[26px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Personal moments</h2>
              <button onClick={() => setActiveModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="mb-6">
              <div className="w-full bg-[#FAFAFA]/60 rounded-full h-1.5 mb-2">
                <div className="bg-[#285301] h-1.5 rounded-full" style={{ width: '40%' }}></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                These are the moments people remember in their hearts.
              </p>
            </div>

            {/* Speeches Section */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Speeches planned</h3>
              <div className="space-y-2">
                {(weddingParty.filter(m => m.speech).length > 0
                  ? weddingParty.filter(m => m.speech).map(m => ({ role: m.role, person: m.name }))
                  : []
                ).map((speech, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[16px] border border-gray-100">
                    <div>
                      <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>{speech.role}</div>
                      {speech.person && (
                        <div className="text-[12px] text-gray-600" style={{ fontWeight: 400 }}>{speech.person}</div>
                      )}
                    </div>
                    <button onClick={() => setActiveFormModal('add-custom-moment')} className="text-gray-400 hover:text-[#d45d78]">
                      <Edit size={14} />
                    </button>
                  </div>
                ))}
              </div>
            </div>

            {/* Cultural Traditions */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Cultural traditions</h3>
              <div className="space-y-2">
                {[
                  { name: 'First dance with parents', included: true },
                  { name: 'Bouquet toss', included: false },
                  { name: 'Cake cutting ceremony', included: true },
                  { name: 'Memory table', included: true },
                  { name: 'Moment of silence', included: true },
                ].map((tradition, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[16px] border border-gray-100">
                    <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{tradition.name}</span>
                    <div className="flex items-center gap-2">
                      {tradition.included && (
                        <Check size={16} className="text-[#d45d78]" />
                      )}
                      <input
                        type="checkbox"
                        checked={tradition.included}
                        readOnly
                        className="w-5 h-5 rounded text-[#d45d78]"
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <button onClick={() => setActiveFormModal('add-custom-moment')} className="w-full bg-[#285301] text-white py-3 rounded-[20px] flex items-center justify-center" style={{ fontWeight: 500 }}>
              <Plus size={18} className="mr-2" />
              Add custom moment
            </button>
          </div>
        </div>
      )}

      {/* HONEYMOON MODAL */}
      {activeModal === 'honeymoon' && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setActiveModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[26px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Honeymoon</h2>
              <button onClick={() => setActiveModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="mb-6">
              <div className="w-full bg-[#FAFAFA]/60 rounded-full h-1.5 mb-2">
                <div className="bg-[#285301] h-1.5 rounded-full" style={{ width: '90%' }}></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Keep your getaway simple, joyful, and easy to look forward to.
              </p>
            </div>

            {/* Summary Metrics */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              <div className="bg-[#fefdfb] rounded-[20px] p-4 border border-gray-100 text-center">
                <div className="text-[18px] text-[#d45d78] mb-1" style={{ fontWeight: 500 }}>Bali</div>
                <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>Destination</div>
              </div>
              <div className="bg-[#fefdfb] rounded-[20px] p-4 border border-gray-100 text-center">
                <div className="text-[18px] text-[#d45d78] mb-1" style={{ fontWeight: 500 }}>10</div>
                <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>Days</div>
              </div>
              <div className="bg-[#fefdfb] rounded-[20px] p-4 border border-gray-100 text-center">
                <div className="text-[18px] text-[#d45d78] mb-1" style={{ fontWeight: 500 }}>$8,500</div>
                <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>Budget</div>
              </div>
            </div>

            {/* Booking Checklist */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Booking checklist</h3>
              <div className="space-y-2">
                {[
                  { item: 'Flights booked', done: true },
                  { item: 'Hotel reserved', done: true },
                  { item: 'Activities planned', done: false },
                  { item: 'Passports checked', done: true },
                  { item: 'Travel insurance', done: false },
                ].map((task, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[16px] border border-gray-100">
                    <span className={`text-[13px] ${task.done ? 'text-gray-500 line-through' : 'text-gray-700'}`} style={{ fontWeight: 400 }}>
                      {task.item}
                    </span>
                    <div className="flex items-center gap-2">
                      {task.done && (
                        <Check size={16} className="text-[#d45d78]" />
                      )}
                      <input
                        type="checkbox"
                        checked={task.done}
                        readOnly
                        className="w-5 h-5 rounded text-[#d45d78]"
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex gap-3">
              <button onClick={() => setActiveFormModal('edit-honeymoon')} className="flex-1 bg-[#285301] text-white py-3 rounded-[20px]" style={{ fontWeight: 500 }}>
                Edit plan
              </button>
              <button onClick={() => setActiveFormModal('track-bookings')} className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700" style={{ fontWeight: 500 }}>
                Track bookings
              </button>
            </div>
          </div>
        </div>
      )}

      {/* INSURANCE MODAL */}
      {activeModal === 'insurance' && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setActiveModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[26px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Insurance</h2>
              <button onClick={() => setActiveModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="mb-6">
              <div className="w-full bg-[#FAFAFA]/60 rounded-full h-1.5 mb-2">
                <div className="bg-[#285301] h-1.5 rounded-full" style={{ width: '100%' }}></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                A little protection can make the whole plan feel steadier.
              </p>
            </div>

            {/* Coverage Status */}
            <div className="bg-gradient-to-br from-[#285301]/10 to-[#FAFAFA]/40 rounded-[20px] p-5 mb-6 text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-[#285301] rounded-full mb-3">
                <Shield className="text-white" size={32} />
              </div>
              <h3 className="text-[18px] text-[#d45d78] mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>You are covered</h3>
              <p className="text-[13px] text-gray-600" style={{ fontWeight: 400 }}>Policy active and ready</p>
            </div>

            {/* Policy Details */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-4" style={{ fontWeight: 500 }}>Policy details</h3>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-[13px] text-gray-600" style={{ fontWeight: 400 }}>Provider</span>
                  <span className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>WedSafe Insurance Co.</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-[13px] text-gray-600" style={{ fontWeight: 400 }}>Policy number</span>
                  <span className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>WS-2026-78451</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-[13px] text-gray-600" style={{ fontWeight: 400 }}>Start date</span>
                  <span className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>Jan 15, 2026</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-[13px] text-gray-600" style={{ fontWeight: 400 }}>Coverage amount</span>
                  <span className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>Up to $50,000</span>
                </div>
              </div>
            </div>

            {/* What's Covered */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>What's covered</h3>
              <div className="space-y-2">
                {['Venue cancellation', 'Vendor no-shows', 'Severe weather', 'Lost deposits', 'Medical emergencies'].map((item, idx) => (
                  <div key={idx} className="flex items-center gap-2 p-2">
                    <Check size={16} className="text-[#d45d78]" />
                    <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{item}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex gap-3">
              <button onClick={() => setActiveFormModal('edit-insurance')} className="flex-1 bg-[#285301] text-white py-3 rounded-[20px]" style={{ fontWeight: 500 }}>
                Edit policy
              </button>
              <button onClick={() => setActiveFormModal('upload-policy')} className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700" style={{ fontWeight: 500 }}>
                Upload document
              </button>
            </div>
          </div>
        </div>
      )}

      {/* LOOKBOOK MODAL */}
      {activeModal === 'lookbook' && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setActiveModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[26px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Lookbook</h2>
              <button onClick={() => setActiveModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="mb-6">
              <div className="w-full bg-[#FAFAFA]/60 rounded-full h-1.5 mb-2">
                <div className="bg-[#285301] h-1.5 rounded-full" style={{ width: '55%' }}></div>
              </div>
              <p className="text-[13px] text-gray-600 text-center" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Keep your visual direction clear so every choice feels connected.
              </p>
            </div>

            {/* Category Filter */}
            <div className="mb-6 overflow-x-auto">
              <div className="flex gap-2">
                {['All', 'Pinterest', 'Venue', 'Flowers', 'Fashion', 'Table design', 'Lighting', 'Ceremony'].map((cat, idx) => (
                  <button
                    key={idx}
                    onClick={() => {
                      if (cat === 'Pinterest') {
                        setActiveFormModal('pinterest-connect');
                      } else {
                        setLookbookCategory(cat);
                      }
                    }}
                    className={`px-3 py-1.5 rounded-full whitespace-nowrap text-[12px] ${
                      lookbookCategory === cat ? 'bg-[#285301] text-white' : cat === 'Pinterest' ? 'bg-[#E60023] text-white' : 'bg-[#FAFAFA]/60 text-gray-700'
                    }`}
                    style={{ fontWeight: 500 }}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Image Grid */}
            <div className="grid grid-cols-2 gap-3 mb-6">
              {Array.from({ length: 8 }).map((_, idx) => (
                <button
                  key={idx}
                  onClick={() => setViewingImage(idx)}
                  className="aspect-square bg-gradient-to-br from-[#FAFAFA]/40 to-[#f194b2]/20 rounded-[20px] flex items-center justify-center border border-gray-100 hover:border-[#285301] transition-all cursor-pointer"
                >
                  <Image className="text-gray-300" size={32} />
                </button>
              ))}
            </div>

            <div className="bg-[#FAFAFA]/40 rounded-[20px] p-4 mb-6">
              <p className="text-[12px] text-gray-600 text-center italic" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Save what feels like you. The details will start to tell one story.
              </p>
            </div>

            <div className="flex gap-2 mb-3">
              <button onClick={() => setActiveFormModal('upload-lookbook-photo')} className="flex-1 bg-[#285301] text-white py-3 rounded-[20px] flex items-center justify-center" style={{ fontWeight: 500 }}>
                <Plus size={18} className="mr-2" />
                Upload
              </button>
              <button onClick={() => setActiveFormModal('pinterest-connect')} className="flex-1 bg-[#E60023] text-white py-3 rounded-[20px] flex items-center justify-center" style={{ fontWeight: 500 }}>
                <Image size={18} className="mr-2" />
                Pinterest
              </button>
              <button onClick={() => setActiveFormModal('share-lookbook')} className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 flex items-center justify-center" style={{ fontWeight: 500 }}>
                <Share2 size={18} className="mr-2" />
                Share
              </button>
            </div>
          </div>
        </div>
      )}

      {/* REMINDERS MODAL */}
      {activeModal === 'reminders' && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end" onClick={() => setActiveModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[26px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Reminders</h2>
              <button onClick={() => setActiveModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>

            <div className="mb-6">
              <p className="text-[13px] text-gray-600 text-center" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                We will keep you gently informed, without overwhelming you.
              </p>
            </div>

            {/* Reminder Style */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Reminder style</h3>
              <div className="space-y-2">
                {[
                  { label: 'Minimal', desc: 'Only critical updates', selected: false },
                  { label: 'Weekly', desc: 'Gentle weekly digest', selected: true },
                  { label: 'Real-time', desc: 'Stay in the loop', selected: false },
                ].map((option, idx) => (
                  <div key={idx} className={`p-3 rounded-[16px] border ${
                    option.selected ? 'border-[#285301] bg-[#285301]/5' : 'border-gray-100 bg-white'
                  }`}>
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="text-[13px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{option.label}</div>
                        <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>{option.desc}</div>
                      </div>
                      <div className={`w-5 h-5 rounded-full border-2 ${
                        option.selected ? 'border-[#285301] bg-[#285301]' : 'border-gray-300'
                      } flex items-center justify-center`}>
                        {option.selected && <div className="w-2 h-2 bg-white rounded-full"></div>}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Reminder Channels */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Reminder channels</h3>
              <div className="space-y-2">
                {[
                  { name: 'Push notifications', enabled: true },
                  { name: 'Email', enabled: true },
                  { name: 'Planner alerts', enabled: false },
                  { name: 'Wedding party alerts', enabled: false },
                ].map((channel, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[16px] border border-gray-100">
                    <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{channel.name}</span>
                    <input
                      type="checkbox"
                      checked={channel.enabled}
                      readOnly
                      className="w-5 h-5 rounded text-[#d45d78]"
                    />
                  </div>
                ))}
              </div>
            </div>

            {/* Reminder Types */}
            <div className="bg-[#fefdfb] rounded-[20px] p-5 border border-gray-100 mb-6">
              <h3 className="text-[15px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Reminder types</h3>
              <div className="space-y-2">
                {[
                  { name: 'Upcoming payments', enabled: true },
                  { name: 'RSVP follow-ups', enabled: true },
                  { name: 'Vendor deadlines', enabled: true },
                  { name: 'Timeline checks', enabled: false },
                  { name: 'Travel reminders', enabled: true },
                ].map((type, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[16px] border border-gray-100">
                    <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{type.name}</span>
                    <input
                      type="checkbox"
                      checked={type.enabled}
                      readOnly
                      className="w-5 h-5 rounded text-[#d45d78]"
                    />
                  </div>
                ))}
              </div>
            </div>

            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px]" style={{ fontWeight: 500 }}>
              Save reminder settings
            </button>
          </div>
        </div>
      )}

      {/* FORM MODALS */}
      {/* Add Task Form */}
      {activeFormModal === 'add-task' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add task</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Task title</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="What needs to be done?" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Module</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Vendors</option>
                  <option>Budget</option>
                  <option>Food & dining</option>
                  <option>Timeline</option>
                  <option>Guest planning</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Due date</label>
                <input type="date" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Priority</label>
                <div className="flex gap-2">
                  {['Urgent', 'Soon', 'Later'].map(p => (
                    <button
                      key={p}
                      onClick={() => setSelectedTaskPriority(p)}
                      className={`flex-1 py-2 rounded-[16px] border text-[13px] ${
                        selectedTaskPriority === p
                          ? 'border-[#285301] bg-[#285301]/10 text-[#d45d78]'
                          : 'border-gray-200 hover:border-[#285301] hover:bg-[#285301]/5'
                      }`}
                    >
                      {p}
                    </button>
                  ))}
                </div>
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Add task
            </button>
          </div>
        </div>
      )}

      {/* Add Expense Form */}
      {activeFormModal === 'add-expense' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add expense</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Vendor / Description</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., Gourmet Affairs" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Category</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Food & drink</option>
                  <option>Venue</option>
                  <option>Photography</option>
                  <option>Decor & flowers</option>
                  <option>Entertainment</option>
                  <option>Attire</option>
                  <option>Stationery</option>
                  <option>Transport</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Amount</label>
                <input type="number" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="$0.00" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Date paid</label>
                <input type="date" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Payment status</label>
                <div className="flex gap-2">
                  {['Paid', 'Pending', 'Scheduled'].map(s => (
                    <button
                      key={s}
                      onClick={() => setSelectedPaymentStatus(s)}
                      className={`flex-1 py-2 rounded-[16px] border text-[13px] ${
                        selectedPaymentStatus === s
                          ? 'border-[#285301] bg-[#285301]/10 text-[#d45d78]'
                          : 'border-gray-200 hover:border-[#285301] hover:bg-[#285301]/5'
                      }`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Save expense
            </button>
          </div>
        </div>
      )}

      {/* Add Vendor Form */}
      {activeFormModal === 'add-vendor' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add vendor</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Vendor name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="Business name" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Category</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Photographer</option>
                  <option>Videographer</option>
                  <option>Florist</option>
                  <option>DJ / band</option>
                  <option>Hair & makeup</option>
                  <option>Cake</option>
                  <option>Transport</option>
                  <option>Other</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Status</label>
                <div className="flex gap-2">
                  {['Booked', 'Shortlisted', 'Needed'].map(s => (
                    <button
                      key={s}
                      onClick={() => setSelectedVendorStatus(s)}
                      className={`flex-1 py-2 rounded-[16px] border text-[13px] ${
                        selectedVendorStatus === s
                          ? 'border-[#285301] bg-[#285301]/10 text-[#d45d78]'
                          : 'border-gray-200 hover:border-[#285301] hover:bg-[#285301]/5'
                      }`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Contact email</label>
                <input type="email" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="vendor@email.com" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Phone</label>
                <input type="tel" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="555-0000" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Save vendor
            </button>
          </div>
        </div>
      )}

      {/* Edit Wedding Details Form */}
      {activeFormModal === 'edit-wedding-details' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Edit wedding details</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Wedding date</label>
                <input type="date" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="2026-07-25" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Partner 1 name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="Emily" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Partner 2 name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="James" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Main location</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="Sunset Gardens, Malibu" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Guest count target</label>
                <input type="number" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="120" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Save changes
            </button>
          </div>
        </div>
      )}

      {/* Manage Access Form */}
      {activeFormModal === 'manage-access' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Manage access</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <p className="text-[13px] text-gray-600" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Control who can view and edit your wedding planning details.
              </p>
              <div className="space-y-3">
                {[
                  { role: 'Wedding planner', email: 'planner@eliteweddings.com', access: 'Full access' },
                  { role: 'Maid of honour', email: 'sarah@email.com', access: 'View only' },
                  { role: 'Best man', email: 'michael@email.com', access: 'View only' },
                ].map((person, idx) => (
                  <div key={idx} className="bg-[#fefdfb] rounded-[20px] p-4 border border-gray-100">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex-1">
                        <div className="text-[14px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{person.role}</div>
                        <div className="text-[12px] text-gray-500" style={{ fontWeight: 400 }}>{person.email}</div>
                      </div>
                      <select className="px-3 py-1.5 rounded-[16px] border border-gray-200 text-[12px]" defaultValue={person.access}>
                        <option>Full access</option>
                        <option>View only</option>
                        <option>No access</option>
                      </select>
                    </div>
                  </div>
                ))}
              </div>
              <button onClick={() => setActiveFormModal('manage-access')} className="w-full border border-[#285301] text-[#d45d78] py-3 rounded-[20px] flex items-center justify-center" style={{ fontWeight: 500 }}>
                <Plus size={18} className="mr-2" />
                Add person
              </button>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Save access settings
            </button>
          </div>
        </div>
      )}

      {/* Guest Page Settings Form */}
      {activeFormModal === 'guest-page-settings' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Guest page settings</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Guest page URL</label>
                <div className="flex gap-2">
                  <input type="text" className="flex-1 px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] bg-gray-50" defaultValue="udo.wedding/emily-james" readOnly />
                  <button onClick={() => {
                    navigator.clipboard.writeText('udo.wedding/emily-james');
                  }} className="px-4 py-3 bg-[#285301] text-white rounded-[20px] flex items-center gap-2">
                    <Link size={18} />
                  </button>
                </div>
              </div>
              <div className="space-y-3">
                <label className="text-[13px] text-gray-700 block" style={{ fontWeight: 500 }}>Page visibility</label>
                {[
                  { label: 'Public with password', enabled: true },
                  { label: 'Private (invite only)', enabled: false },
                  { label: 'Published and active', enabled: true },
                ].map((setting, idx) => (
                  <div key={idx} className="flex items-center justify-between p-3 bg-[#fefdfb] rounded-[16px] border border-gray-100">
                    <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{setting.label}</span>
                    <input type="checkbox" checked={setting.enabled} readOnly className="w-5 h-5 rounded text-[#d45d78]" />
                  </div>
                ))}
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Password</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="emilyJames2026" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Save settings
            </button>
          </div>
        </div>
      )}

      {/* Add/Edit Event Form */}
      {(activeFormModal === 'add-event' || activeFormModal === 'edit-event') && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => { setActiveFormModal(null); setEditingEventId(null); }}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                {activeFormModal === 'edit-event' ? 'Edit event' : 'Add event'}
              </h2>
              <button onClick={() => { setActiveFormModal(null); setEditingEventId(null); }} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Event name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., Cocktail hour" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Time</label>
                <input type="time" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Location</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., Garden terrace" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Expected guests</label>
                <input type="number" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="120" />
              </div>
            </div>
            <button onClick={() => { setActiveFormModal(null); setEditingEventId(null); }} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              {activeFormModal === 'edit-event' ? 'Save changes' : 'Add event'}
            </button>
          </div>
        </div>
      )}

      {/* Pinterest Connect Modal */}
      {activeFormModal === 'pinterest-connect' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Connect Pinterest</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            {!pinterestConnected ? (
              <div className="text-center py-8">
                <div className="inline-flex items-center justify-center w-20 h-20 bg-[#FAFAFA] rounded-full mb-4">
                  <Image className="text-[#d45d78]" size={40} />
                </div>
                <h3 className="text-[16px] text-gray-800 mb-2" style={{ fontWeight: 500 }}>Import from Pinterest</h3>
                <p className="text-[13px] text-gray-600 mb-6" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                  Connect your Pinterest account to import boards and pins directly into your lookbook.
                </p>
                <button onClick={() => setPinterestConnected(true)} className="w-full bg-[#E60023] text-white py-3 rounded-[20px] flex items-center justify-center mb-3" style={{ fontWeight: 500 }}>
                  Connect Pinterest account
                </button>
                <button onClick={() => setActiveFormModal(null)} className="w-full border border-gray-300 py-3 rounded-[20px] text-gray-700" style={{ fontWeight: 500 }}>
                  Cancel
                </button>
              </div>
            ) : (
              <div>
                <div className="bg-[#FAFAFA]/40 rounded-[20px] p-4 mb-4 flex items-center gap-3">
                  <Check className="text-[#d45d78]" size={20} />
                  <span className="text-[13px] text-gray-700" style={{ fontWeight: 500 }}>Pinterest connected</span>
                </div>
                <div className="space-y-3">
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Select boards to import</label>
                  {['Wedding Inspiration', 'Venue Ideas', 'Floral Arrangements', 'Table Settings'].map((board, idx) => (
                    <div key={idx} className="flex items-center justify-between p-3 bg-white rounded-[16px] border border-gray-100">
                      <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{board}</span>
                      <input type="checkbox" className="w-5 h-5 rounded text-[#d45d78]" />
                    </div>
                  ))}
                </div>
                <button onClick={() => { setActiveFormModal(null); }} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
                  Import selected boards
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Upload Photo Modal */}
      {activeFormModal === 'upload-lookbook-photo' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Upload inspiration</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div className="border-2 border-dashed border-gray-300 rounded-[20px] p-8 text-center hover:border-[#285301] transition-colors cursor-pointer">
                <Upload className="mx-auto text-gray-400 mb-3" size={40} />
                <p className="text-[14px] text-gray-700 mb-1" style={{ fontWeight: 500 }}>Drag and drop photos here</p>
                <p className="text-[12px] text-gray-500" style={{ fontWeight: 400 }}>or click to browse</p>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Category</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Venue</option>
                  <option>Flowers</option>
                  <option>Fashion</option>
                  <option>Table design</option>
                  <option>Lighting</option>
                  <option>Ceremony</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Notes (optional)</label>
                <textarea className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" rows={3} placeholder="Why this inspires you..."></textarea>
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Upload
            </button>
          </div>
        </div>
      )}

      {/* Share Lookbook Modal */}
      {activeFormModal === 'share-lookbook' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Share lookbook</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <p className="text-[13px] text-gray-600" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Share your lookbook with vendors, your planner, or your wedding party.
              </p>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Shareable link</label>
                <div className="flex gap-2">
                  <input type="text" className="flex-1 px-4 py-3 rounded-[20px] border border-gray-200 text-[14px] bg-gray-50" defaultValue="udo.wedding/lookbook/emily-james" readOnly />
                  <button className="px-4 py-3 bg-[#285301] text-white rounded-[20px] flex items-center gap-2" onClick={() => {
                    navigator.clipboard.writeText('udo.wedding/lookbook/emily-james');
                  }}>
                    <Link size={18} />
                  </button>
                </div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Share with</label>
                <div className="space-y-2">
                  {['Wedding planner', 'Florist', 'Photographer', 'Wedding party'].map((recipient, idx) => (
                    <div key={idx} className="flex items-center justify-between p-3 bg-[#fefdfb] rounded-[16px] border border-gray-100">
                      <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>{recipient}</span>
                      <input type="checkbox" className="w-5 h-5 rounded text-[#d45d78]" />
                    </div>
                  ))}
                </div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Permission level</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>View only</option>
                  <option>Can comment</option>
                  <option>Can add photos</option>
                </select>
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Share lookbook
            </button>
          </div>
        </div>
      )}

      {/* Add Wedding Party Member */}
      {activeFormModal === 'add-wedding-party-member' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add wedding party member</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="Full name" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Role</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Bridesmaid</option>
                  <option>Groomsman</option>
                  <option>Maid of honour</option>
                  <option>Best man</option>
                  <option>Flower girl</option>
                  <option>Ring bearer</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Email</label>
                <input type="email" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="email@example.com" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Phone</label>
                <input type="tel" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="555-0000" />
              </div>
              <div className="flex items-center justify-between p-3 bg-[#fefdfb] rounded-[16px] border border-gray-100">
                <span className="text-[13px] text-gray-700" style={{ fontWeight: 400 }}>Speech planned</span>
                <input type="checkbox" className="w-5 h-5 rounded text-[#d45d78]" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Add member
            </button>
          </div>
        </div>
      )}

      {/* Additional modals for other buttons */}
      {activeFormModal === 'add-timeline-moment' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add timeline moment</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Moment name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., First dance" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Time</label>
                <input type="time" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Type</label>
                <div className="flex gap-2">
                  {['Ceremony', 'Reception'].map(t => (
                    <button key={t} className="flex-1 py-2 rounded-[16px] border border-gray-200 text-[13px] hover:border-[#285301] hover:bg-[#285301]/5">{t}</button>
                  ))}
                </div>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Owner</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., DJ, Couple" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>Add moment</button>
          </div>
        </div>
      )}

      {activeFormModal === 'add-additional-event' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add additional event</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Event name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., Welcome drinks" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Date</label>
                <input type="date" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Host</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="Who is hosting?" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Expected guests</label>
                <input type="number" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Location</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>Add event</button>
          </div>
        </div>
      )}

      {activeFormModal === 'add-custom-moment' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add custom moment</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Moment name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., Unity candle" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Description</label>
                <textarea className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" rows={3} placeholder="What makes this moment special?"></textarea>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>When does this happen?</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>During ceremony</option>
                  <option>During reception</option>
                  <option>Throughout the day</option>
                </select>
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>Add moment</button>
          </div>
        </div>
      )}

      {(activeFormModal === 'edit-honeymoon' || activeFormModal === 'track-bookings') && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                {activeFormModal === 'track-bookings' ? 'Track bookings' : 'Edit honeymoon'}
              </h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Destination</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="Bali" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Number of days</label>
                <input type="number" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="10" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Budget</label>
                <input type="number" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="8500" />
              </div>
            </div>
            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>Save changes</button>
          </div>
        </div>
      )}

      {(activeFormModal === 'edit-insurance' || activeFormModal === 'upload-policy') && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
                {activeFormModal === 'upload-policy' ? 'Upload policy document' : 'Edit insurance policy'}
              </h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            {activeFormModal === 'upload-policy' ? (
              <div className="space-y-4">
                <div className="border-2 border-dashed border-gray-300 rounded-[20px] p-8 text-center hover:border-[#285301] transition-colors cursor-pointer">
                  <Upload className="mx-auto text-gray-400 mb-3" size={40} />
                  <p className="text-[14px] text-gray-700 mb-1" style={{ fontWeight: 500 }}>Upload policy document</p>
                  <p className="text-[12px] text-gray-500" style={{ fontWeight: 400 }}>PDF, DOC, or image files</p>
                </div>
                <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px]" style={{ fontWeight: 500 }}>Upload</button>
              </div>
            ) : (
              <div className="space-y-4">
                <div>
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Provider</label>
                  <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="WedSafe Insurance Co." />
                </div>
                <div>
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Policy number</label>
                  <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="WS-2026-78451" />
                </div>
                <div>
                  <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Coverage amount</label>
                  <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" defaultValue="$50,000" />
                </div>
                <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>Save changes</button>
              </div>
            )}
          </div>
        </div>
      )}

      {activeFormModal === 'start-seating' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Start seating plan</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            <div className="space-y-4">
              <p className="text-[13px] text-gray-600" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Create your seating arrangement by organizing guests into tables. You can drag and drop guests to arrange them.
              </p>
              <div className="bg-[#FAFAFA]/40 rounded-[20px] p-4">
                <h3 className="text-[14px] text-gray-800 mb-2" style={{ fontWeight: 500 }}>Quick setup options</h3>
                <div className="space-y-2">
                  <button onClick={() => setActiveFormModal('seating-board')} className="w-full p-3 bg-white rounded-[16px] border border-gray-200 text-left hover:border-[#285301]">
                    <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>Auto-assign by family groups</div>
                    <div className="text-[11px] text-gray-500" style={{ fontWeight: 400 }}>Group guests with their families</div>
                  </button>
                  <button onClick={() => setActiveFormModal('seating-board')} className="w-full p-3 bg-white rounded-[16px] border border-gray-200 text-left hover:border-[#285301]">
                    <div className="text-[13px] text-gray-800" style={{ fontWeight: 500 }}>Manual arrangement</div>
                    <div className="text-[11px] text-gray-500" style={{ fontWeight: 400 }}>Drag and drop guests yourself</div>
                  </button>
                </div>
              </div>
            </div>
            <button onClick={() => setActiveFormModal('seating-board')} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>Continue to seating board</button>
          </div>
        </div>
      )}

      {activeFormModal === 'seating-board' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Seating arrangement</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="bg-[#FAFAFA]/40 rounded-[20px] p-4">
                <div className="text-[13px] text-gray-600 mb-1" style={{ fontWeight: 400 }}>Total guests</div>
                <div className="text-[24px] text-[#d45d78]" style={{ fontWeight: 500 }}>
                  {Object.values(seatingTables).reduce((sum, guests) => sum + guests.length, 0) + unassignedGuests.length}
                </div>
              </div>
              <div className="bg-[#FAFAFA]/40 rounded-[20px] p-4">
                <div className="text-[13px] text-gray-600 mb-1" style={{ fontWeight: 400 }}>Unassigned</div>
                <div className="text-[24px] text-[#d45d78]" style={{ fontWeight: 500 }}>{unassignedGuests.length}</div>
              </div>
            </div>

            {/* Unassigned guests pool */}
            <div className="mb-6">
              <h3 className="text-[14px] text-gray-800 mb-3" style={{ fontWeight: 500 }}>Unassigned guests</h3>
              <div
                className="bg-[#fefdfb] rounded-[20px] p-4 border-2 border-dashed border-gray-200 min-h-[120px]"
                onDragOver={(e) => e.preventDefault()}
                onDrop={(e) => {
                  e.preventDefault();
                  if (draggedGuest) {
                    // Move guest to unassigned
                    const newTables = {...seatingTables};
                    Object.keys(newTables).forEach(table => {
                      const index = newTables[table].indexOf(draggedGuest);
                      if (index > -1) {
                        newTables[table].splice(index, 1);
                      }
                    });
                    setSeatingTables(newTables);
                    if (!unassignedGuests.includes(draggedGuest)) {
                      setUnassignedGuests([...unassignedGuests, draggedGuest]);
                    }
                    setDraggedGuest(null);
                  }
                }}
              >
                <div className="flex flex-wrap gap-2">
                  {unassignedGuests.map((guest, idx) => (
                    <div
                      key={idx}
                      draggable
                      onDragStart={() => setDraggedGuest(guest)}
                      onDragEnd={() => setDraggedGuest(null)}
                      className="bg-white px-3 py-2 rounded-[16px] border border-gray-200 text-[13px] cursor-move hover:border-[#285301] flex items-center gap-2"
                    >
                      <GripVertical size={14} className="text-gray-400" />
                      {guest}
                    </div>
                  ))}
                  {unassignedGuests.length === 0 && (
                    <div className="text-[13px] text-gray-400 py-4">All guests assigned!</div>
                  )}
                </div>
              </div>
            </div>

            {/* Tables */}
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-[14px] text-gray-800" style={{ fontWeight: 500 }}>Tables</h3>
                <button
                  onClick={() => {
                    const newTableNum = Object.keys(seatingTables).length + 1;
                    setSeatingTables({...seatingTables, [`Table ${newTableNum}`]: []});
                  }}
                  className="text-[13px] text-[#d45d78] flex items-center gap-1"
                >
                  <Plus size={16} />
                  Add table
                </button>
              </div>

              {Object.entries(seatingTables).map(([tableName, guests]) => (
                <div
                  key={tableName}
                  className="bg-gradient-to-br from-[#FAFAFA]/40 to-white rounded-[20px] p-4 border border-gray-200"
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={(e) => {
                    e.preventDefault();
                    if (draggedGuest && !guests.includes(draggedGuest)) {
                      // Remove from unassigned
                      setUnassignedGuests(unassignedGuests.filter(g => g !== draggedGuest));

                      // Remove from other tables
                      const newTables = {...seatingTables};
                      Object.keys(newTables).forEach(table => {
                        const index = newTables[table].indexOf(draggedGuest);
                        if (index > -1) {
                          newTables[table].splice(index, 1);
                        }
                      });

                      // Add to this table
                      newTables[tableName] = [...newTables[tableName], draggedGuest];
                      setSeatingTables(newTables);
                      setDraggedGuest(null);
                    }
                  }}
                >
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <h4 className="text-[14px] text-gray-800" style={{ fontWeight: 500 }}>{tableName}</h4>
                      <span className="text-[12px] text-gray-500">({guests.length}/8)</span>
                    </div>
                    <button
                      onClick={() => {
                        const newTables = {...seatingTables};
                        // Move guests back to unassigned
                        setUnassignedGuests([...unassignedGuests, ...guests]);
                        delete newTables[tableName];
                        setSeatingTables(newTables);
                      }}
                      className="text-gray-400 hover:text-red-500"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>

                  <div
                    className="min-h-[80px] bg-white/50 rounded-[16px] p-3 border-2 border-dashed border-gray-200"
                  >
                    {guests.length > 0 ? (
                      <div className="flex flex-wrap gap-2">
                        {guests.map((guest, idx) => (
                          <div
                            key={idx}
                            draggable
                            onDragStart={() => setDraggedGuest(guest)}
                            onDragEnd={() => setDraggedGuest(null)}
                            className="bg-[#285301] text-white px-3 py-1.5 rounded-[16px] text-[12px] cursor-move flex items-center gap-1"
                          >
                            <GripVertical size={12} />
                            {guest}
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="text-[12px] text-gray-400 text-center py-4">
                        Drag guests here
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>

            <button onClick={() => setActiveFormModal(null)} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Save seating plan
            </button>
          </div>
        </div>
      )}

      {activeFormModal === 'assign-duties' && (
        <div className="fixed inset-0 bg-black/50 z-[60] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Assign duties</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>

            <div className="bg-[#FAFAFA]/40 rounded-[20px] p-4 mb-6">
              <p className="text-[13px] text-gray-600" style={{ fontWeight: 400, lineHeight: 1.6 }}>
                Assign wedding party members to help with various tasks throughout the day.
              </p>
            </div>

            <div className="space-y-3">
              {[
                { duty: 'Help with guest book', category: 'Reception' },
                { duty: 'Coordinate guest transport', category: 'Logistics' },
                { duty: 'Manage gift table', category: 'Reception' },
                { duty: 'Distribute programs', category: 'Ceremony' },
                { duty: 'Assist elderly guests', category: 'Logistics' },
                { duty: 'Direct guests to ceremony', category: 'Ceremony' },
                { duty: 'Coordinate with vendors', category: 'Coordination' },
                { duty: 'Oversee setup', category: 'Coordination' },
                { duty: 'Handle last-minute issues', category: 'Coordination' },
                { duty: 'Collect RSVPs', category: 'Pre-wedding' },
                { duty: 'Distribute favors', category: 'Reception' },
                { duty: 'Manage coat check', category: 'Reception' },
                { duty: 'Assist with decorations', category: 'Setup' },
                { duty: 'Gather family for photos', category: 'Photography' },
                { duty: 'Hold rings during ceremony', category: 'Ceremony' },
                { duty: 'Manage music playlist', category: 'Reception' },
                { duty: 'Coordinate send-off', category: 'Departure' },
                { duty: 'Supervise cleanup', category: 'Departure' },
              ].map((item, idx) => (
                <div key={idx} className="bg-white rounded-[20px] border border-gray-200 overflow-hidden">
                  <div className="grid grid-cols-[1fr,auto] gap-0">
                    {/* Left column - Duty */}
                    <div className="p-4 border-r border-gray-200">
                      <div className="text-[13px] text-gray-800 mb-1" style={{ fontWeight: 500 }}>{item.duty}</div>
                      <div className="text-[11px] text-gray-500" style={{ fontWeight: 400 }}>{item.category}</div>
                    </div>

                    {/* Right column - Assignment */}
                    <div className="p-4 min-w-[180px] flex items-center">
                      <select className="w-full px-3 py-2 rounded-[16px] border border-gray-200 text-[12px] bg-[#fefdfb]">
                        <option>Assign to...</option>
                        {weddingParty.map((m, i) => (
                          <option key={i}>{m.name} ({m.role})</option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setActiveFormModal('add-custom-duty')}
                className="flex-1 border border-gray-300 py-3 rounded-[20px] text-gray-700 flex items-center justify-center gap-2"
                style={{ fontWeight: 500 }}
              >
                <Plus size={18} />
                Add custom duty
              </button>
              <button onClick={() => setActiveFormModal(null)} className="flex-[2] bg-[#285301] text-white py-3 rounded-[20px]" style={{ fontWeight: 500 }}>
                Save assignments
              </button>
            </div>
          </div>
        </div>
      )}

      {activeFormModal === 'add-custom-duty' && (
        <div className="fixed inset-0 bg-black/50 z-[70] flex items-end" onClick={() => setActiveFormModal(null)}>
          <div className="bg-white w-full rounded-t-3xl p-6 max-h-[85vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="w-12 h-1 bg-gray-300 rounded-full mx-auto mb-6"></div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-[22px] text-[#d45d78]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>Add custom duty</h2>
              <button onClick={() => setActiveFormModal(null)} className="text-gray-400 hover:text-gray-600"><X size={24} /></button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Duty name</label>
                <input type="text" className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" placeholder="e.g., Check in with DJ every hour" />
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Category</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Select category</option>
                  <option>Ceremony</option>
                  <option>Reception</option>
                  <option>Logistics</option>
                  <option>Coordination</option>
                  <option>Setup</option>
                  <option>Photography</option>
                  <option>Departure</option>
                  <option>Pre-wedding</option>
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Assign to</label>
                <select className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]">
                  <option>Select person</option>
                  {weddingParty.map((m, i) => (
                    <option key={i}>{m.name} ({m.role})</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-[13px] text-gray-700 block mb-2" style={{ fontWeight: 500 }}>Notes (optional)</label>
                <textarea className="w-full px-4 py-3 rounded-[20px] border border-gray-200 text-[14px]" rows={3} placeholder="Any special instructions..."></textarea>
              </div>
            </div>
            <button onClick={() => setActiveFormModal('assign-duties')} className="w-full bg-[#285301] text-white py-3 rounded-[20px] mt-6" style={{ fontWeight: 500 }}>
              Add duty
            </button>
          </div>
        </div>
      )}

      {/* IMAGE VIEWER MODAL */}
      {viewingImage !== null && (
        <div className="fixed inset-0 bg-black/90 z-[70] flex items-center justify-center" onClick={() => setViewingImage(null)}>
          <div className="relative max-w-4xl w-full mx-4" onClick={(e) => e.stopPropagation()}>
            <button
              onClick={() => setViewingImage(null)}
              className="absolute top-4 right-4 text-white bg-black/50 rounded-full p-2 hover:bg-black/70"
            >
              <X size={24} />
            </button>
            <div className="bg-gradient-to-br from-[#FAFAFA] to-[#f194b2]/30 rounded-2xl aspect-video flex items-center justify-center">
              <div className="text-center">
                <Image className="text-white/50 mx-auto mb-4" size={64} />
                <p className="text-white text-[14px]" style={{ fontWeight: 400 }}>
                  Lookbook image #{viewingImage + 1}
                </p>
              </div>
            </div>
            <div className="flex gap-2 mt-4 justify-center">
              <button
                onClick={() => setViewingImage(Math.max(0, viewingImage - 1))}
                className="px-4 py-2 bg-white rounded-[16px] text-[13px]"
                disabled={viewingImage === 0}
              >
                Previous
              </button>
              <button
                onClick={() => setViewingImage(Math.min(7, viewingImage + 1))}
                className="px-4 py-2 bg-white rounded-[16px] text-[13px]"
                disabled={viewingImage === 7}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
