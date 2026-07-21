'use client';

import { useState } from 'react';
import { Heart, ChevronRight, Sparkles, Check, Clock, DollarSign, Users, Calendar, MapPin, Sun, Plus, X, Info, TrendingUp, AlertCircle, Edit, UserPlus, Send, Briefcase, LayoutGrid, MessageSquare, Mail, Link as LinkIcon, Shield } from 'lucide-react';
import { useWedding } from '@/contexts/WeddingContext';

type ModalType = 'progress' | 'priorities' | 'budget' | 'guests' | 'task-detail' | 'quick-action' | 'today-focus' | 'wedding-feeling' | 'add-vendor' | 'invite-guest' | 'set-milestone' | 'message-guests' | null;

type MoodType = 'calm' | 'excited' | 'overwhelmed' | 'balanced' | null;

export default function HomePage() {
  const { wedding, stats, commandCenter, upcomingTasks } = useWedding();
  const [activeModal, setActiveModal] = useState<ModalType>(null);
  const [selectedTask, setSelectedTask] = useState<any>(null);
  const [selectedAction, setSelectedAction] = useState('');
  const [selectedMood, setSelectedMood] = useState<MoodType>(null);

  // Vendor modal state
  const [vendorCategory, setVendorCategory] = useState('Venue');
  const [vendorName, setVendorName] = useState('');
  const [vendorBusinessName, setVendorBusinessName] = useState('');
  const [vendorContact, setVendorContact] = useState('');
  const [vendorPhone, setVendorPhone] = useState('');
  const [vendorEmail, setVendorEmail] = useState('');
  const [vendorInstagram, setVendorInstagram] = useState('');
  const [vendorWebsite, setVendorWebsite] = useState('');
  const [vendorPriceQuote, setVendorPriceQuote] = useState('');
  const [vendorDepositPaid, setVendorDepositPaid] = useState('');
  const [vendorRemainingBalance, setVendorRemainingBalance] = useState('');
  const [vendorNotes, setVendorNotes] = useState('');
  const [vendorPaymentReminder, setVendorPaymentReminder] = useState(false);
  const [vendorTimeline, setVendorTimeline] = useState(false);
  const [vendorBooked, setVendorBooked] = useState(false);
  const [vendorPriority, setVendorPriority] = useState(false);

  // Invite Guest modal state
  const [guestName, setGuestName] = useState('');
  const [guestEmail, setGuestEmail] = useState('');
  const [guestPhone, setGuestPhone] = useState('');
  const [guestPlusOne, setGuestPlusOne] = useState(false);
  const [guestGroup, setGuestGroup] = useState('Friends');
  const [guestDeliveryMethod, setGuestDeliveryMethod] = useState<'email' | 'sms' | 'whatsapp' | 'link'>('email');
  const [guestAutoReminder, setGuestAutoReminder] = useState(true);
  const [guestMealSelection, setGuestMealSelection] = useState(true);
  const [guestPhotoUpload, setGuestPhotoUpload] = useState(false);
  const [guestTravelDetails, setGuestTravelDetails] = useState(false);

  // Milestone modal state
  const [milestoneType, setMilestoneType] = useState('Planning milestone');
  const [milestoneDate, setMilestoneDate] = useState('');
  const [milestoneReminder, setMilestoneReminder] = useState('1 week before');
  const [milestoneNotes, setMilestoneNotes] = useState('');

  // Message Guests modal state
  const [messageAudience, setMessageAudience] = useState('All guests');
  const [messageType, setMessageType] = useState('');
  const [messageContent, setMessageContent] = useState('');
  const [messageSendImmediately, setMessageSendImmediately] = useState(true);
  const [messageScheduleLater, setMessageScheduleLater] = useState(false);

  const moodQuotes = {
    calm: "Peace looks good on you.",
    excited: "This energy is everything.",
    overwhelmed: "One step at a time — you're closer than you think.",
    balanced: "You've found your rhythm.",
  };

  const fallbackTasks = [
    {
      id: 1,
      title: 'Finalize your venue shortlist',
      reason: 'This helps shape your guest count and overall budget',
      urgency: 'high',
      metadata: 'This step helps unlock guest planning',
      details: 'Finalizing your shortlist will help you make guest, budget, and styling decisions with more confidence.',
      steps: ['Review venue capacity', 'Compare pricing', 'Check availability dates', 'Book site visit']
    },
    {
      id: 2,
      title: 'Set guest meal preferences',
      reason: 'Your caterer needs this to finalize the menu',
      urgency: 'medium',
      metadata: 'Takes about 15 minutes',
      details: 'Setting up meal preferences will help your caterer create the right portions and dietary accommodations.',
      steps: ['Define main courses', 'Add vegetarian options', 'Note any allergies', 'Confirm with caterer']
    },
    {
      id: 3,
      title: 'Create your timeline draft',
      reason: 'This keeps everyone aligned on the day',
      urgency: 'low',
      metadata: 'Quick setup',
      details: 'A timeline draft helps ensure your vendors and guests know the flow of your day.',
      steps: ['Set ceremony time', 'Plan cocktail hour', 'Schedule reception', 'Add photo time']
    }
  ];
  const priorityTasks = commandCenter?.upcoming_actions?.length
    ? commandCenter.upcoming_actions.map((action, index) => ({
        id: index + 1,
        title: action.title,
        reason: action.reason,
        urgency: action.priority,
        metadata: action.target,
        details: action.reason,
        steps: ['Open the related section', 'Review the issue', 'Make the update', 'Refresh the dashboard'],
      }))
    : upcomingTasks.length
      ? upcomingTasks.slice(0, 3).map((task) => ({
          id: task.id,
          title: task.title,
          reason: task.due_date ? `Due ${new Date(task.due_date).toLocaleDateString()}` : 'Upcoming planning task',
          urgency: task.priority,
          metadata: 'Planning task',
          details: 'This task is pulled from your real wedding plan.',
          steps: ['Open Plan', 'Review the task', 'Mark it complete when finished'],
        }))
      : fallbackTasks;
  const smartAlerts = commandCenter?.smart_alerts?.alerts ?? [];
  const platformHealth = commandCenter?.platform_health;

  const quickActions = [
    { icon: Edit, label: 'Add vendor', action: 'add-vendor', helper: 'Track venues, catering, florals & more' },
    { icon: UserPlus, label: 'Invite guest', action: 'invite-guest', helper: 'Send invitations in minutes' },
    { icon: Calendar, label: 'Set milestone', action: 'set-milestone', helper: 'Keep your wedding journey organized' },
    { icon: Send, label: 'Message guests', action: 'message-guests', helper: 'Share updates without stress' }
  ];

  return (
    <div className="min-h-screen bg-[#FAFAFA]">
      {/* Header */}
      <div className="bg-gradient-to-br from-[#FF88BA] to-[#FF3E9B] px-5 pt-10 pb-8 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 left-0 w-48 h-48 bg-white/10 rounded-full blur-2xl"></div>
        <div className="relative z-10">
          <div className="flex items-center justify-between mb-1">
            <h1 className="text-white text-[32px]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
              {wedding?.couple_names ?? 'Your Wedding'}
            </h1>
            <Heart className="text-white/90" size={28} fill="white" />
          </div>
          <p className="text-white/90 text-[15px]">
            {wedding?.event_date
              ? new Date(wedding.event_date).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
              : 'Date TBD'}
            {wedding?.venue_city ? ` • ${wedding.venue_city}` : ''}
          </p>
        </div>
      </div>

      {/* Content */}
      <div className="px-5 -mt-4 pb-24 space-y-5">
        {/* Today's Focus Card */}
        <div
          className="bg-white rounded-[20px] p-6 cursor-pointer transition-all active:scale-[0.98]"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          onClick={() => setActiveModal('today-focus')}
        >
          <div className="flex items-start justify-between mb-4">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <Sun size={18} className="text-[#FF3E9B]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Today's Focus</span>
              </div>
              <h2 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                {commandCenter ? 'Command center priorities' : 'Three things to move forward'}
              </h2>
            </div>
            <ChevronRight className="text-gray-400 flex-shrink-0" size={20} />
          </div>

          <div className="space-y-3">
            {priorityTasks.map((task) => (
              <div
                key={task.id}
                onClick={(e) => {
                  e.stopPropagation();
                  setSelectedTask(task);
                  setActiveModal('task-detail');
                }}
                className="flex items-start gap-3 p-4 bg-[#FAFAFA] rounded-[16px] hover:bg-gray-100 transition-colors cursor-pointer"
              >
                <div className={`mt-0.5 w-5 h-5 rounded-full border-2 flex-shrink-0 ${
                  task.urgency === 'high' ? 'border-[#FF3E9B]' :
                  task.urgency === 'medium' ? 'border-[#3A8B95]' :
                  'border-gray-300'
                }`}></div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-[15px] font-medium text-gray-900 mb-1">{task.title}</h3>
                  <p className="text-[13px] text-gray-500 leading-relaxed">{task.reason}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {commandCenter && (
          <div
            className="bg-white rounded-[20px] p-6"
            style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          >
            <div className="flex items-center gap-2 mb-5">
              <LayoutGrid size={16} className="text-[#3A8B95]" />
              <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Command Center</span>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <CommandCard label="Planning health" value={`${commandCenter.planning_health.score}%`} detail={commandCenter.planning_health.label} tone={commandCenter.planning_health.score >= 65 ? 'good' : 'risk'} />
              <CommandCard label="RSVP health" value={`${commandCenter.rsvp_health.completion}%`} detail={`${commandCenter.rsvp_health.pending} pending`} tone={commandCenter.rsvp_health.pending === 0 ? 'good' : 'warn'} />
              <CommandCard label="Budget used" value={`${commandCenter.budget_status.usage}%`} detail={`$${commandCenter.budget_status.remaining.toLocaleString()} remaining`} tone={commandCenter.budget_status.usage >= 90 ? 'risk' : 'good'} />
              <CommandCard label="Live readiness" value={`${commandCenter.live_readiness.score}%`} detail={`${commandCenter.live_readiness.open_incidents} open issues`} tone={commandCenter.live_readiness.open_incidents === 0 ? 'good' : 'risk'} />
            </div>
            <div className="mt-4 rounded-[16px] bg-[#FAFAFA] p-4">
              <div className="text-[13px] font-medium text-gray-900 mb-2">Guest issues</div>
              <div className="grid grid-cols-2 gap-2 text-[12px] text-gray-600">
                <div>Meals missing: {commandCenter.guest_issues.missing_meals ?? 0}</div>
                <div>Seating open: {commandCenter.guest_issues.unassigned_seating ?? 0}</div>
                <div>Arrival gaps: {commandCenter.guest_issues.missing_arrival_info ?? 0}</div>
                <div>VIP attention: {commandCenter.guest_issues.vip_needs_attention ?? 0}</div>
              </div>
            </div>
          </div>
        )}

        {platformHealth && (
          <div
            className="bg-white rounded-[20px] p-6"
            style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Shield size={16} className="text-[#3A8B95]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Platform Health</span>
              </div>
              <span className={`text-[11px] px-2.5 py-1 rounded-full ${
                platformHealth.status === 'healthy' ? 'bg-[#F0F9FA] text-[#285301]' :
                platformHealth.status === 'watch' ? 'bg-[#FFF8E7] text-[#9A6B00]' :
                'bg-[#FFF5F8] text-[#d45d78]'
              }`}>
                {platformHealth.status}
              </span>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <CommandCard label="Health score" value={`${platformHealth.score}%`} detail={`Queue: ${platformHealth.queue.connection}`} tone={platformHealth.score >= 90 ? 'good' : platformHealth.score >= 70 ? 'warn' : 'risk'} />
              <CommandCard label="Deliveries" value={`${platformHealth.queue.pending_deliveries}`} detail={`${platformHealth.queue.failed_deliveries} failed`} tone={platformHealth.queue.failed_deliveries === 0 ? 'good' : 'risk'} />
              <CommandCard label="Queue failures" value={`${platformHealth.queue.failed_jobs}`} detail={`${platformHealth.queue.stale_sending_messages} stale sends`} tone={platformHealth.queue.failed_jobs === 0 && platformHealth.queue.stale_sending_messages === 0 ? 'good' : 'risk'} />
              <CommandCard label="Guest links" value={`${platformHealth.tokens.expiring_soon}`} detail={`${platformHealth.tokens.expired_active} expired active`} tone={platformHealth.tokens.expired_active === 0 ? 'good' : 'warn'} />
            </div>
          </div>
        )}

        {smartAlerts.length > 0 && (
          <div
            className="bg-white rounded-[20px] p-6"
            style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          >
            <div className="flex items-center justify-between mb-5">
              <div className="flex items-center gap-2">
                <AlertCircle size={16} className="text-[#FF3E9B]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Smart Alerts</span>
              </div>
              <span className="text-[11px] text-gray-500">{commandCenter?.smart_alerts?.total_active ?? smartAlerts.length} active</span>
            </div>
            <div className="space-y-3">
              {smartAlerts.slice(0, 4).map((alert) => (
                <div key={alert.id} className="rounded-[16px] bg-[#FAFAFA] p-4 border border-gray-100">
                  <div className="flex items-start gap-3">
                    <div className={`mt-1 h-2.5 w-2.5 rounded-full ${
                      alert.severity === 'critical' ? 'bg-[#FF3E9B]' :
                      alert.severity === 'high' ? 'bg-[#F59E0B]' :
                      'bg-[#3A8B95]'
                    }`} />
                    <div className="flex-1 min-w-0">
                      <div className="text-[14px] font-medium text-gray-900">{alert.title}</div>
                      {alert.body && <div className="text-[12px] text-gray-500 mt-1 leading-relaxed">{alert.body}</div>}
                      <div className="flex items-center justify-between mt-3">
                        <span className="text-[11px] text-gray-500 capitalize">{alert.alert_type.replace('_', ' ')}</span>
                        <span className="text-[12px] text-[#3A8B95] font-medium">{alert.action_label ?? 'Review'}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Quick Actions */}
        <div
          className="bg-white rounded-[20px] p-6"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
        >
          <div className="flex items-center gap-2 mb-5">
            <Sparkles size={16} className="text-[#3A8B95]" />
            <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Quick Actions</span>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.action}
                  onClick={() => setActiveModal(action.action as ModalType)}
                  className="flex flex-col items-center justify-center p-5 bg-[#FAFAFA] rounded-[20px] hover:shadow-lg hover:-translate-y-0.5 transition-all active:scale-[0.98]"
                >
                  <div className="w-12 h-12 bg-gradient-to-br from-[#FF88BA] to-[#FF3E9B] rounded-full flex items-center justify-center mb-3 group-hover:shadow-lg transition-shadow">
                    <Icon className="text-white" size={20} />
                  </div>
                  <span className="text-[14px] font-medium text-gray-800 mb-1">{action.label}</span>
                  <span className="text-[11px] text-gray-500 text-center leading-snug">{action.helper}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Udo Guidance - Smart Wedding Insights */}
        <div
          className="bg-white rounded-[20px] p-6"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
        >
          <div className="mb-5">
            <div className="flex items-center gap-2 mb-2">
              <Sparkles size={16} className="text-[#FF3E9B]" />
              <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Udo Guidance</span>
            </div>
            <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>Thoughtful questions worth considering</h3>
          </div>

          {/* Horizontally scrollable cards */}
          <div className="relative -mx-6 px-6">
            <div className="flex gap-4 overflow-x-auto pb-4 snap-x snap-mandatory scrollbar-hide">
              {[
                { q: "Does your venue still comfortably fit your updated guest count?", a: "You may need to adjust layout or seating early to avoid last-minute changes" },
                { q: "Have you accounted for 'buffer guests' — plus ones or last-minute yes RSVPs?", a: "Planning for a 5-10% buffer can prevent catering or seating surprises" },
                { q: "Are you collecting dietary preferences in a structured way?", a: "If it's scattered across texts, you may miss someone's allergy or meal need" },
                { q: "Do you have a system for tracking RSVPs beyond 'I'll remember'?", a: "It's easy to lose track — a simple list or spreadsheet goes a long way" },
                { q: "Is your caterer charging per confirmed guest or a fixed minimum?", a: "This affects whether a small drop in attendance will actually save you money" },
                { q: "Have you built in a spending buffer for 'little extras' that add up?", a: "Things like extra linens, last-minute rentals, and gratuities can surprise you" },
                { q: "Do you know where you're currently over or under budget?", a: "Checking this weekly helps you course-correct before it's too late" },
                { q: "Are you tracking actual spending vs. estimates in real-time?", a: "Deposits and final payments can feel abstract until you see the real total" },
                { q: "Is your menu designed for your actual guest mix — kids, elders, dietary needs?", a: "A heavy, rich meal might not work for all ages or preferences" },
                { q: "Have you confirmed how food will be served — buffet, plated, stations?", a: "This affects timing, cost, and guest flow throughout the event" },
                { q: "Do you have a backup plan if a dish runs out or a vendor is delayed?", a: "Late food service is one of the top guest frustrations at weddings" },
                { q: "Have you thought through whether you want a signature drink or full open bar?", a: "A curated drink menu can feel more personal and often costs less" },
                { q: "Do you know your bar package structure — consumption vs. flat rate?", a: "One could save you money, the other gives more predictability" },
                { q: "Have you checked if the venue allows you to provide your own alcohol?", a: "This could be a major cost saver if you're comfortable coordinating it" },
                { q: "Is there a plan for non-drinkers beyond 'water and soda'?", a: "Thoughtful mocktails or specialty drinks make everyone feel included" },
                { q: "Will bar service continue through the entire event, or stop before the end?", a: "Some couples close the bar an hour early to ease the wind-down" },
                { q: "Do you have a rain plan that feels as special as your main plan?", a: "If the backup feels like 'Plan B,' it may affect your peace of mind" },
                { q: "Have you walked through the actual guest flow — arrival, ceremony, cocktail, reception?", a: "Bottlenecks in transitions or unclear signage can cause confusion" },
                { q: "Is there a clear restroom plan, especially if your venue is outdoors or remote?", a: "Long restroom lines or unclear locations quietly frustrate guests" },
                { q: "Do you know where guests will wait if things run behind schedule?", a: "If the ceremony is delayed, having a comfortable holding space matters" },
                { q: "Is parking or transportation clearly communicated to your guests?", a: "Parking struggles or unclear shuttle info can sour the arrival experience" },
                { q: "Have you planned 'pockets of rest' where guests can step away and recharge?", a: "Lounge areas or quiet corners help guests enjoy the event at their own pace" },
                { q: "Do you have a plan for guests who arrive early or leave late?", a: "Clear start and end times help everyone feel oriented and comfortable" },
                { q: "Is there a 'what to do if we're running late' plan for the day of?", a: "Decide in advance what gets shortened or skipped so you're not scrambling" },
                { q: "Are your parents or close family clear on what role they'll play that day?", a: "Unspoken expectations can lead to tension — clarity is kindness" },
                { q: "Do you have someone managing vendor coordination so you don't have to?", a: "A day-of coordinator or trusted friend can field questions so you stay present" },
                { q: "Have you confirmed final counts, payments, and timing with all your vendors?", a: "A week-before vendor check-in call prevents day-of surprises" },
                { q: "Do you know what time you'll actually eat during your own wedding?", a: "Many couples forget to eat — planning a moment to sit and have a meal matters" },
                { q: "Is there a plan for your phone and personal items during the event?", a: "Handing them to someone you trust means you can stay fully present" },
                { q: "Have you built in time to just be with your partner during the event?", a: "Even 10 minutes alone together can help you feel connected amid the chaos" },
                { q: "Do you have a 'what matters most' list for the day to keep you grounded?", a: "When things go sideways, knowing your non-negotiables helps you let go of the rest" }
              ].map((insight, idx) => (
                <div
                  key={idx}
                  className="flex-shrink-0 w-[85%] snap-start bg-[#FAFAFA] rounded-[18px] p-5 min-h-[160px]"
                >
                  <h4 className="text-[16px] text-gray-900 mb-3 leading-snug font-semibold" style={{ fontFamily: 'Inter, sans-serif' }}>
                    {insight.q}
                  </h4>
                  <p className="text-[13px] text-gray-600 leading-relaxed">
                    {insight.a}
                  </p>
                </div>
              ))}
            </div>

            {/* Scroll indicator dots */}
            <div className="flex justify-center gap-1.5 mt-2">
              {Array(5).fill(0).map((_, idx) => (
                <div
                  key={idx}
                  className={`h-1 rounded-full transition-all ${idx === 0 ? 'w-6 bg-[#FF3E9B]' : 'w-1 bg-gray-300'}`}
                ></div>
              ))}
            </div>
          </div>
        </div>

        {/* Wedding Feeling Check-in */}
        <div
          className="bg-gradient-to-br from-[#FF88BA]/10 to-[#FF3E9B]/10 rounded-[20px] p-6 border border-[#FF3E9B]/20 cursor-pointer transition-all active:scale-[0.98]"
          onClick={() => setActiveModal('wedding-feeling')}
        >
          <div className="flex items-center gap-2 mb-4">
            <Heart size={16} className="text-[#FF3E9B]" />
            <span className="text-[11px] text-gray-600 uppercase tracking-wide font-medium">Check-in</span>
          </div>
          <h3 className="text-[20px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
            How are you feeling about your wedding?
          </h3>
          <p className="text-[13px] text-gray-600 leading-relaxed">
            Your planning energy matters. Let's make sure you feel supported.
          </p>
        </div>

        {/* Progress Overview */}
        <div
          className="bg-white rounded-[20px] p-6 cursor-pointer transition-all active:scale-[0.98]"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          onClick={() => setActiveModal('progress')}
        >
          <div className="flex items-center justify-between mb-5">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <TrendingUp size={16} className="text-[#3A8B95]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Progress</span>
              </div>
              {(() => {
                const pct = stats?.total_tasks ? Math.round((stats.completed_tasks / stats.total_tasks) * 100) : 0;
                return (
                  <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                    You're {pct}% there
                  </h3>
                );
              })()}
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>

          <div className="space-y-4">
            <div>
              {(() => {
                const pct = stats?.total_tasks ? Math.round((stats.completed_tasks / stats.total_tasks) * 100) : 0;
                return (
                  <>
                    <div className="flex justify-between items-center mb-2">
                      <span className="text-[13px] text-gray-700 font-medium">Overall progress</span>
                      <span className="text-[13px] text-gray-500">{pct}%</span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div className="h-full bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] rounded-full" style={{ width: `${pct}%` }}></div>
                    </div>
                  </>
                );
              })()}
            </div>

            <div className="grid grid-cols-3 gap-3 pt-2">
              <div className="text-center">
                <div className="text-[24px] font-semibold text-[#FF3E9B]">{stats?.completed_tasks ?? 0}</div>
                <div className="text-[11px] text-gray-500 mt-1">Done</div>
              </div>
              <div className="text-center">
                <div className="text-[24px] font-semibold text-[#3A8B95]">{stats?.pending_tasks ?? 0}</div>
                <div className="text-[11px] text-gray-500 mt-1">Remaining</div>
              </div>
              <div className="text-center">
                <div className="text-[24px] font-semibold text-gray-400">{stats?.total_tasks ?? 0}</div>
                <div className="text-[11px] text-gray-500 mt-1">Total</div>
              </div>
            </div>
          </div>
        </div>

        {/* Priorities */}
        <div
          className="bg-white rounded-[20px] p-6 cursor-pointer transition-all active:scale-[0.98]"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          onClick={() => setActiveModal('priorities')}
        >
          <div className="flex items-center justify-between mb-5">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <AlertCircle size={16} className="text-[#FF3E9B]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Priorities</span>
              </div>
              <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                What needs attention
              </h3>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>

          <div className="space-y-3">
            <div className="flex items-center gap-3 p-4 bg-[#FFF5F8] rounded-[16px] border border-[#FF3E9B]/20">
              <Clock className="text-[#FF3E9B] flex-shrink-0" size={20} />
              <div>
                <div className="text-[14px] font-medium text-gray-900">Vendor deposit due in 3 days</div>
                <div className="text-[12px] text-gray-500 mt-0.5">Photography — $1,200</div>
              </div>
            </div>

            {(stats?.pending_guests ?? 0) > 0 && (
              <div className="flex items-center gap-3 p-4 bg-[#F0F9FA] rounded-[16px] border border-[#3A8B95]/20">
                <Users className="text-[#3A8B95] flex-shrink-0" size={20} />
                <div>
                  <div className="text-[14px] font-medium text-gray-900">{stats!.pending_guests} guests haven't RSVP'd</div>
                  <div className="text-[12px] text-gray-500 mt-0.5">Send them a reminder</div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Budget Snapshot */}
        <div
          className="bg-white rounded-[20px] p-6 cursor-pointer transition-all active:scale-[0.98]"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          onClick={() => setActiveModal('budget')}
        >
          <div className="flex items-center justify-between mb-5">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <DollarSign size={16} className="text-[#3A8B95]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Budget</span>
              </div>
              <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                ${(stats?.budget_spent ?? 0).toLocaleString()} of ${(stats?.budget_total ?? 0).toLocaleString()}
              </h3>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>

          <div className="space-y-4">
            <div>
              {(() => {
                const pct = stats?.budget_total ? Math.round((stats.budget_spent / stats.budget_total) * 100) : 0;
                const remaining = (stats?.budget_total ?? 0) - (stats?.budget_spent ?? 0);
                return (
                  <>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden mb-3">
                      <div className="h-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] rounded-full" style={{ width: `${pct}%` }}></div>
                    </div>
                    <div className="flex justify-between text-[12px]">
                      <span className="text-gray-500">${remaining.toLocaleString()} remaining</span>
                      <span className="text-gray-500">{pct}% used</span>
                    </div>
                  </>
                );
              })()}
            </div>

            <div className="grid grid-cols-2 gap-3 pt-2">
              <div className="p-3 bg-[#FAFAFA] rounded-[12px]">
                <div className="text-[11px] text-gray-500 mb-1">Spent</div>
                <div className="text-[15px] font-semibold text-gray-900">${(stats?.budget_spent ?? 0).toLocaleString()}</div>
              </div>
              <div className="p-3 bg-[#FAFAFA] rounded-[12px]">
                <div className="text-[11px] text-gray-500 mb-1">Budget</div>
                <div className="text-[15px] font-semibold text-gray-900">${(stats?.budget_total ?? 0).toLocaleString()}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Guest Summary */}
        <div
          className="bg-white rounded-[20px] p-6 cursor-pointer transition-all active:scale-[0.98]"
          style={{ boxShadow: '0 6px 20px rgba(0,0,0,0.04)' }}
          onClick={() => setActiveModal('guests')}
        >
          <div className="flex items-center justify-between mb-5">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <Users size={16} className="text-[#FF3E9B]" />
                <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Guests</span>
              </div>
              <h3 className="text-[22px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                {stats?.total_guests ?? 0} invited, {stats?.confirmed_guests ?? 0} confirmed
              </h3>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="text-center p-3 bg-[#F0F9FA] rounded-[12px]">
              <div className="text-[20px] font-semibold text-[#3A8B95]">{stats?.confirmed_guests ?? 0}</div>
              <div className="text-[11px] text-gray-600 mt-1">Coming</div>
            </div>
            <div className="text-center p-3 bg-[#FFF5F8] rounded-[12px]">
              <div className="text-[20px] font-semibold text-[#FF3E9B]">{stats?.declined_guests ?? 0}</div>
              <div className="text-[11px] text-gray-600 mt-1">Can't make it</div>
            </div>
            <div className="text-center p-3 bg-[#FAFAFA] rounded-[12px]">
              <div className="text-[20px] font-semibold text-gray-400">{stats?.pending_guests ?? 0}</div>
              <div className="text-[11px] text-gray-600 mt-1">Pending</div>
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      {activeModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end justify-center z-50 backdrop-blur-sm"
          onClick={() => setActiveModal(null)}
        >
          <div
            className="bg-white rounded-t-[24px] w-full max-w-[600px] max-h-[85vh] overflow-y-auto"
            style={{ boxShadow: '0 -4px 20px rgba(0,0,0,0.1)' }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Task Detail Modal */}
            {activeModal === 'task-detail' && selectedTask && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div className="flex-1">
                    <div className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full mb-3 ${
                      selectedTask.urgency === 'high' ? 'bg-[#FFF5F8] text-[#FF3E9B]' :
                      selectedTask.urgency === 'medium' ? 'bg-[#F0F9FA] text-[#3A8B95]' :
                      'bg-gray-100 text-gray-600'
                    }`}>
                      <span className="text-[11px] font-medium uppercase tracking-wide">
                        {selectedTask.urgency === 'high' ? 'High Priority' :
                         selectedTask.urgency === 'medium' ? 'Medium Priority' :
                         'Low Priority'}
                      </span>
                    </div>
                    <h2 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      {selectedTask.title}
                    </h2>
                    <p className="text-[14px] text-gray-600 leading-relaxed">{selectedTask.details}</p>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="ml-4 w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors flex-shrink-0"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-3 mb-6">
                  <h3 className="text-[13px] font-medium text-gray-700 uppercase tracking-wide">Steps to complete</h3>
                  {selectedTask.steps.map((step: string, idx: number) => (
                    <div key={idx} className="flex items-center gap-3 p-4 bg-[#FAFAFA] rounded-[16px]">
                      <div className="w-5 h-5 rounded-full border-2 border-gray-300 flex-shrink-0"></div>
                      <span className="text-[14px] text-gray-800">{step}</span>
                    </div>
                  ))}
                </div>

                <button className="w-full bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-4 rounded-[16px] font-medium hover:shadow-lg transition-shadow">
                  Mark as complete
                </button>
              </div>
            )}

            {/* Add Vendor Modal */}
            {activeModal === 'add-vendor' && (
              <div className="p-6 pb-8 max-h-[85vh] overflow-y-auto">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h2 className="text-[28px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Add a vendor
                    </h2>
                    <p className="text-[14px] text-gray-600">Keep all your wedding professionals beautifully organized.</p>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors flex-shrink-0"
                  >
                    <X size={20} className="text-gray-600" />
                  </button>
                </div>

                {/* Category Pills */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Vendor category</label>
                  <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
                    {['Venue', 'Catering', 'Photography', 'Florals', 'Makeup', 'Entertainment', 'Rentals', 'Transportation', 'Cake', 'Planner', 'Custom'].map((category) => (
                      <button
                        key={category}
                        onClick={() => setVendorCategory(category)}
                        className={`px-4 py-2 rounded-full text-[13px] font-medium whitespace-nowrap transition-all ${
                          vendorCategory === category
                            ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-md'
                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                        }`}
                      >
                        {category}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Vendor Form */}
                <div className="space-y-4">
                  <div className="grid grid-cols-1 gap-4">
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2 font-medium">Vendor name</label>
                      <input
                        type="text"
                        value={vendorName}
                        onChange={(e) => setVendorName(e.target.value)}
                        className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                        placeholder="Enter vendor name"
                      />
                    </div>

                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2 font-medium">Business/company name</label>
                      <input
                        type="text"
                        value={vendorBusinessName}
                        onChange={(e) => setVendorBusinessName(e.target.value)}
                        className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                        placeholder="Enter business name"
                      />
                    </div>

                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2 font-medium">Contact person</label>
                      <input
                        type="text"
                        value={vendorContact}
                        onChange={(e) => setVendorContact(e.target.value)}
                        className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                        placeholder="Enter contact name"
                      />
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Phone</label>
                        <input
                          type="tel"
                          value={vendorPhone}
                          onChange={(e) => setVendorPhone(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="Phone number"
                        />
                      </div>
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Email</label>
                        <input
                          type="email"
                          value={vendorEmail}
                          onChange={(e) => setVendorEmail(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="Email address"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Instagram</label>
                        <input
                          type="text"
                          value={vendorInstagram}
                          onChange={(e) => setVendorInstagram(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="@handle"
                        />
                      </div>
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Website</label>
                        <input
                          type="url"
                          value={vendorWebsite}
                          onChange={(e) => setVendorWebsite(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="website.com"
                        />
                      </div>
                    </div>

                    <div className="grid grid-cols-3 gap-3">
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Price quote</label>
                        <input
                          type="text"
                          value={vendorPriceQuote}
                          onChange={(e) => setVendorPriceQuote(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="$0"
                        />
                      </div>
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Deposit paid</label>
                        <input
                          type="text"
                          value={vendorDepositPaid}
                          onChange={(e) => setVendorDepositPaid(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="$0"
                        />
                      </div>
                      <div>
                        <label className="text-[13px] text-gray-700 block mb-2 font-medium">Balance</label>
                        <input
                          type="text"
                          value={vendorRemainingBalance}
                          onChange={(e) => setVendorRemainingBalance(e.target.value)}
                          className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                          placeholder="$0"
                        />
                      </div>
                    </div>

                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2 font-medium">Notes</label>
                      <textarea
                        value={vendorNotes}
                        onChange={(e) => setVendorNotes(e.target.value)}
                        className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none resize-none"
                        rows={3}
                        placeholder="Add any notes about this vendor..."
                      />
                    </div>
                  </div>

                  {/* Smart Features */}
                  <div className="pt-4 space-y-3">
                    <h3 className="text-[13px] text-gray-700 font-medium mb-3">Smart features</h3>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Add to payment reminders</span>
                      <input
                        type="checkbox"
                        checked={vendorPaymentReminder}
                        onChange={(e) => setVendorPaymentReminder(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Add to wedding timeline</span>
                      <input
                        type="checkbox"
                        checked={vendorTimeline}
                        onChange={(e) => setVendorTimeline(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Mark as booked</span>
                      <input
                        type="checkbox"
                        checked={vendorBooked}
                        onChange={(e) => setVendorBooked(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Priority vendor</span>
                      <input
                        type="checkbox"
                        checked={vendorPriority}
                        onChange={(e) => setVendorPriority(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                  </div>

                  {/* Still Deciding Section */}
                  <div className="p-5 bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[20px] border border-[#3A8B95]/20">
                    <h3 className="text-[15px] text-gray-800 font-medium mb-2">Still deciding?</h3>
                    <p className="text-[13px] text-gray-600 mb-3">Save this vendor and compare with others later</p>
                    <div className="flex gap-2">
                      <button className="px-4 py-2 bg-white border border-gray-200 rounded-[12px] text-[13px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                        Compare vendors
                      </button>
                      <button className="px-4 py-2 bg-white border border-gray-200 rounded-[12px] text-[13px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                        Save to favorites
                      </button>
                    </div>
                  </div>
                </div>

                {/* Sticky CTA Footer */}
                <div className="sticky bottom-0 bg-white pt-6 mt-6 border-t border-gray-100 -mx-6 px-6 flex gap-3">
                  <button
                    onClick={() => setActiveModal(null)}
                    className="flex-1 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-4 rounded-[20px] font-medium shadow-lg hover:shadow-xl transition-shadow"
                  >
                    Save vendor
                  </button>
                  <button
                    onClick={() => {
                      // Reset form
                      setVendorName('');
                      setVendorBusinessName('');
                      setVendorContact('');
                      setVendorPhone('');
                      setVendorEmail('');
                      setVendorInstagram('');
                      setVendorWebsite('');
                      setVendorPriceQuote('');
                      setVendorDepositPaid('');
                      setVendorRemainingBalance('');
                      setVendorNotes('');
                      setVendorPaymentReminder(false);
                      setVendorTimeline(false);
                      setVendorBooked(false);
                      setVendorPriority(false);
                    }}
                    className="flex-1 bg-white border-2 border-gray-300 text-gray-700 py-4 rounded-[20px] font-medium hover:bg-gray-50 transition-colors"
                  >
                    Save & add another
                  </button>
                </div>
              </div>
            )}

            {/* Invite Guest Modal */}
            {activeModal === 'invite-guest' && (
              <div className="p-6 pb-8 max-h-[85vh] overflow-y-auto">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h2 className="text-[28px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Invite guests
                    </h2>
                    <p className="text-[14px] text-gray-600">Bring everyone together beautifully.</p>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors flex-shrink-0"
                  >
                    <X size={20} className="text-gray-600" />
                  </button>
                </div>

                {/* Import Options */}
                <div className="mb-6">
                  <h3 className="text-[13px] text-gray-700 font-medium mb-3">Quick add options</h3>
                  <div className="grid grid-cols-2 gap-3">
                    <button className="p-4 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[16px] border border-[#3A8B95]/20 hover:shadow-md transition-all text-left">
                      <Users className="text-[#3A8B95] mb-2" size={20} />
                      <div className="text-[14px] font-medium text-gray-800 mb-1">Import contacts</div>
                      <div className="text-[11px] text-gray-500">From your phone or email</div>
                    </button>
                    <button className="p-4 bg-gradient-to-br from-[#FFF5F8] to-white rounded-[16px] border border-[#FF3E9B]/20 hover:shadow-md transition-all text-left">
                      <LayoutGrid className="text-[#FF3E9B] mb-2" size={20} />
                      <div className="text-[14px] font-medium text-gray-800 mb-1">Upload spreadsheet</div>
                      <div className="text-[11px] text-gray-500">CSV or Excel file</div>
                    </button>
                  </div>
                </div>

                {/* Guest Entry Form */}
                <div className="space-y-4">
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-2 font-medium">Full name</label>
                    <input
                      type="text"
                      value={guestName}
                      onChange={(e) => setGuestName(e.target.value)}
                      className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                      placeholder="Enter guest name"
                    />
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2 font-medium">Email</label>
                      <input
                        type="email"
                        value={guestEmail}
                        onChange={(e) => setGuestEmail(e.target.value)}
                        className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                        placeholder="email@example.com"
                      />
                    </div>
                    <div>
                      <label className="text-[13px] text-gray-700 block mb-2 font-medium">Phone</label>
                      <input
                        type="tel"
                        value={guestPhone}
                        onChange={(e) => setGuestPhone(e.target.value)}
                        className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                        placeholder="(555) 000-0000"
                      />
                    </div>
                  </div>

                  <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                    <span className="text-[14px] text-gray-800">Allow plus one</span>
                    <input
                      type="checkbox"
                      checked={guestPlusOne}
                      onChange={(e) => setGuestPlusOne(e.target.checked)}
                      className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                    />
                  </label>

                  {/* Group Tags */}
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-3 font-medium">Group/Category</label>
                    <div className="flex gap-2 flex-wrap">
                      {['Family', 'Friends', 'Wedding party', 'Coworkers', 'Traveling guests', 'VIP'].map((group) => (
                        <button
                          key={group}
                          onClick={() => setGuestGroup(group)}
                          className={`px-4 py-2 rounded-full text-[13px] font-medium transition-all ${
                            guestGroup === group
                              ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-md'
                              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                          }`}
                        >
                          {group}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Delivery Options */}
                  <div>
                    <label className="text-[13px] text-gray-700 block mb-3 font-medium">Send invitation via</label>
                    <div className="grid grid-cols-2 gap-2">
                      {[
                        { value: 'email' as const, label: 'Email', icon: Mail },
                        { value: 'sms' as const, label: 'SMS', icon: MessageSquare },
                        { value: 'whatsapp' as const, label: 'WhatsApp', icon: Send },
                        { value: 'link' as const, label: 'Share link', icon: LinkIcon }
                      ].map(({ value, label, icon: Icon }) => (
                        <button
                          key={value}
                          onClick={() => setGuestDeliveryMethod(value)}
                          className={`flex items-center gap-2 p-3 rounded-[12px] text-[13px] font-medium transition-all ${
                            guestDeliveryMethod === value
                              ? 'bg-[#3A8B95] text-white shadow-md'
                              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                          }`}
                        >
                          <Icon size={16} />
                          {label}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Smart Settings */}
                  <div className="pt-4 space-y-3">
                    <h3 className="text-[13px] text-gray-700 font-medium mb-3">Smart settings</h3>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Auto reminder if no response</span>
                      <input
                        type="checkbox"
                        checked={guestAutoReminder}
                        onChange={(e) => setGuestAutoReminder(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Allow meal selection</span>
                      <input
                        type="checkbox"
                        checked={guestMealSelection}
                        onChange={(e) => setGuestMealSelection(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Allow guest photo uploads</span>
                      <input
                        type="checkbox"
                        checked={guestPhotoUpload}
                        onChange={(e) => setGuestPhotoUpload(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Ask for travel details</span>
                      <input
                        type="checkbox"
                        checked={guestTravelDetails}
                        onChange={(e) => setGuestTravelDetails(e.target.checked)}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                  </div>

                  {/* Invitation Preview */}
                  <div className="p-5 bg-gradient-to-br from-[#FFF5F8] to-[#F0F9FA] rounded-[20px] border border-[#FF3E9B]/20">
                    <h3 className="text-[15px] text-gray-800 font-medium mb-2">Invitation preview</h3>
                    <div className="bg-white rounded-[12px] p-4 border border-gray-100">
                      <div className="text-center">
                        <p className="text-[18px] mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                          Olivia & Jordan
                        </p>
                        <p className="text-[13px] text-gray-600">June 14, 2026 • San Diego, CA</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Sticky CTA Footer */}
                <div className="sticky bottom-0 bg-white pt-6 mt-6 border-t border-gray-100 -mx-6 px-6 flex gap-3">
                  <button
                    onClick={() => setActiveModal(null)}
                    className="flex-1 bg-white border-2 border-gray-300 text-gray-700 py-4 rounded-[20px] font-medium hover:bg-gray-50 transition-colors"
                  >
                    Save as draft
                  </button>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="flex-1 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-4 rounded-[20px] font-medium shadow-lg hover:shadow-xl transition-shadow"
                  >
                    Send invitations
                  </button>
                </div>
              </div>
            )}

            {/* Set Milestone Modal */}
            {activeModal === 'set-milestone' && (
              <div className="p-6 pb-8 max-h-[85vh] overflow-y-auto">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h2 className="text-[28px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Set milestone
                    </h2>
                    <p className="text-[14px] text-gray-600">Small steps create beautiful weddings.</p>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors flex-shrink-0"
                  >
                    <X size={20} className="text-gray-600" />
                  </button>
                </div>

                {/* Sweet Microcopy */}
                <div className="mb-6 p-4 bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[16px] border border-[#3A8B95]/20">
                  <p className="text-[14px] text-gray-700 italic text-center">
                    "{['You are doing beautifully.', 'One step closer to your day.', 'Planning can feel calm.'][Math.floor(Math.random() * 3)]}"
                  </p>
                </div>

                {/* Timeline Types */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Milestone type</label>
                  <div className="grid grid-cols-2 gap-3">
                    {[
                      { type: 'Planning milestone', icon: Sparkles },
                      { type: 'Booking deadline', icon: Clock },
                      { type: 'Payment reminder', icon: DollarSign },
                      { type: 'Dress fitting', icon: Heart },
                      { type: 'RSVP deadline', icon: Users },
                      { type: 'Final vendor confirmation', icon: Check },
                      { type: 'Honeymoon prep', icon: MapPin }
                    ].map(({ type, icon: Icon }) => (
                      <button
                        key={type}
                        onClick={() => setMilestoneType(type)}
                        className={`flex items-center gap-3 p-4 rounded-[16px] text-left transition-all ${
                          milestoneType === type
                            ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-md'
                            : 'bg-gray-50 text-gray-700 hover:bg-gray-100'
                        }`}
                      >
                        <Icon size={18} className={milestoneType === type ? 'text-white' : 'text-[#FF3E9B]'} />
                        <span className="text-[13px] font-medium">{type}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Date Picker */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-2 font-medium">Date</label>
                  <input
                    type="date"
                    value={milestoneDate}
                    onChange={(e) => setMilestoneDate(e.target.value)}
                    className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none"
                  />
                </div>

                {/* Reminder Options */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Remind me</label>
                  <div className="grid grid-cols-2 gap-2">
                    {['1 week before', '3 days before', 'Same day', 'Custom reminder'].map((reminder) => (
                      <button
                        key={reminder}
                        onClick={() => setMilestoneReminder(reminder)}
                        className={`p-3 rounded-[12px] text-[13px] font-medium transition-all ${
                          milestoneReminder === reminder
                            ? 'bg-[#3A8B95] text-white shadow-md'
                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                        }`}
                      >
                        {reminder}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Notes */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-2 font-medium">What would you like to remember about this moment?</label>
                  <textarea
                    value={milestoneNotes}
                    onChange={(e) => setMilestoneNotes(e.target.value)}
                    className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none resize-none"
                    rows={3}
                    placeholder="Add any notes or thoughts..."
                  />
                </div>

                {/* Visual Timeline Preview */}
                <div className="p-5 bg-gradient-to-br from-[#FFF5F8] to-[#F0F9FA] rounded-[20px] border border-[#FF3E9B]/20">
                  <h3 className="text-[15px] text-gray-800 font-medium mb-4">Your wedding journey</h3>
                  <div className="flex items-center justify-between">
                    {[
                      { label: 'Engagement', active: true },
                      { label: 'Planning', active: true },
                      { label: 'Wedding week', active: false },
                      { label: 'Wedding day', active: false }
                    ].map((phase, idx) => (
                      <div key={phase.label} className="flex flex-col items-center flex-1">
                        <div className={`w-8 h-8 rounded-full flex items-center justify-center mb-2 ${
                          phase.active ? 'bg-gradient-to-br from-[#FF3E9B] to-[#FF88BA]' : 'bg-gray-200'
                        }`}>
                          {phase.active && <Check size={16} className="text-white" />}
                        </div>
                        <span className={`text-[10px] text-center ${phase.active ? 'text-gray-700 font-medium' : 'text-gray-400'}`}>
                          {phase.label}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Sticky CTA Footer */}
                <div className="sticky bottom-0 bg-white pt-6 mt-6 border-t border-gray-100 -mx-6 px-6 flex gap-3">
                  <button
                    onClick={() => {
                      // Reset form
                      setMilestoneType('Planning milestone');
                      setMilestoneDate('');
                      setMilestoneReminder('1 week before');
                      setMilestoneNotes('');
                    }}
                    className="flex-1 bg-white border-2 border-gray-300 text-gray-700 py-4 rounded-[20px] font-medium hover:bg-gray-50 transition-colors"
                  >
                    Add another
                  </button>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="flex-1 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-4 rounded-[20px] font-medium shadow-lg hover:shadow-xl transition-shadow"
                  >
                    Save milestone
                  </button>
                </div>
              </div>
            )}

            {/* Message Guests Modal */}
            {activeModal === 'message-guests' && (
              <div className="p-6 pb-8 max-h-[85vh] overflow-y-auto">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h2 className="text-[28px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Message guests
                    </h2>
                    <p className="text-[14px] text-gray-600">Share updates gently and clearly.</p>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors flex-shrink-0"
                  >
                    <X size={20} className="text-gray-600" />
                  </button>
                </div>

                {/* Audience Selector */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Send to</label>
                  <div className="flex gap-2 flex-wrap">
                    {['All guests', 'RSVP pending', 'Traveling guests', 'Family', 'Wedding party', 'Custom tag'].map((audience) => (
                      <button
                        key={audience}
                        onClick={() => setMessageAudience(audience)}
                        className={`px-4 py-2 rounded-full text-[13px] font-medium transition-all ${
                          messageAudience === audience
                            ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-md'
                            : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                        }`}
                      >
                        {audience}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Message Type Cards */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Message type</label>
                  <div className="grid grid-cols-2 gap-3">
                    {[
                      { type: 'Schedule update', icon: Calendar },
                      { type: 'Reminder', icon: Clock },
                      { type: 'Travel info', icon: MapPin },
                      { type: 'Welcome message', icon: Heart }
                    ].map(({ type, icon: Icon }) => (
                      <button
                        key={type}
                        onClick={() => setMessageType(type)}
                        className={`flex items-center gap-3 p-4 rounded-[16px] text-left transition-all ${
                          messageType === type
                            ? 'bg-[#3A8B95] text-white shadow-md'
                            : 'bg-gray-50 text-gray-700 hover:bg-gray-100'
                        }`}
                      >
                        <Icon size={16} className={messageType === type ? 'text-white' : 'text-[#3A8B95]'} />
                        <span className="text-[13px] font-medium">{type}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Smart Templates */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Quick templates</label>
                  <div className="space-y-2">
                    {[
                      'We cannot wait to celebrate with you.',
                      'Travel safely — we are so excited to see you.',
                      'Dinner begins at 6:30 PM.',
                      'Thank you for celebrating this chapter with us.'
                    ].map((template) => (
                      <button
                        key={template}
                        onClick={() => setMessageContent(template)}
                        className="w-full p-3 bg-gray-50 rounded-[12px] text-left text-[13px] text-gray-700 hover:bg-[#F0F9FA] hover:text-[#3A8B95] transition-colors"
                      >
                        {template}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Message Composer */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-2 font-medium">Your message</label>
                  <textarea
                    value={messageContent}
                    onChange={(e) => setMessageContent(e.target.value)}
                    className="w-full px-4 py-3 rounded-[16px] border border-gray-200 text-[14px] focus:border-[#FF3E9B] focus:outline-none resize-none"
                    rows={6}
                    placeholder="Write your message here..."
                  />
                </div>

                {/* Delivery Settings */}
                <div className="mb-6">
                  <label className="text-[13px] text-gray-700 block mb-3 font-medium">Delivery settings</label>
                  <div className="space-y-3">
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Send immediately</span>
                      <input
                        type="checkbox"
                        checked={messageSendImmediately}
                        onChange={(e) => {
                          setMessageSendImmediately(e.target.checked);
                          if (e.target.checked) setMessageScheduleLater(false);
                        }}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                    <label className="flex items-center justify-between p-4 bg-gray-50 rounded-[16px] cursor-pointer hover:bg-gray-100 transition-colors">
                      <span className="text-[14px] text-gray-800">Schedule for later</span>
                      <input
                        type="checkbox"
                        checked={messageScheduleLater}
                        onChange={(e) => {
                          setMessageScheduleLater(e.target.checked);
                          if (e.target.checked) setMessageSendImmediately(false);
                        }}
                        className="w-5 h-5 rounded border-gray-300 text-[#FF3E9B]"
                      />
                    </label>
                  </div>
                </div>

                {/* Message History Preview */}
                <div className="p-5 bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[20px] border border-[#3A8B95]/20">
                  <h3 className="text-[15px] text-gray-800 font-medium mb-3">Recent messages</h3>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between p-3 bg-white rounded-[12px]">
                      <div>
                        <div className="text-[13px] font-medium text-gray-800">RSVP reminder</div>
                        <div className="text-[11px] text-gray-500">Sent 3 days ago • 92% opened</div>
                      </div>
                      <Check size={16} className="text-[#3A8B95]" />
                    </div>
                    <div className="flex items-center justify-between p-3 bg-white rounded-[12px]">
                      <div>
                        <div className="text-[13px] font-medium text-gray-800">Welcome message</div>
                        <div className="text-[11px] text-gray-500">Sent 2 weeks ago • 98% opened</div>
                      </div>
                      <Check size={16} className="text-[#3A8B95]" />
                    </div>
                  </div>
                </div>

                {/* Sticky CTA Footer */}
                <div className="sticky bottom-0 bg-white pt-6 mt-6 border-t border-gray-100 -mx-6 px-6 flex gap-3">
                  <button
                    onClick={() => setActiveModal(null)}
                    className="flex-1 bg-white border-2 border-gray-300 text-gray-700 py-4 rounded-[20px] font-medium hover:bg-gray-50 transition-colors"
                  >
                    Save draft
                  </button>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="flex-1 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-4 rounded-[20px] font-medium shadow-lg hover:shadow-xl transition-shadow flex items-center justify-center gap-2"
                  >
                    <Send size={18} />
                    Send message
                  </button>
                </div>
              </div>
            )}

            {/* Today Focus Modal */}
            {activeModal === 'today-focus' && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <Sun size={18} className="text-[#FF3E9B]" />
                      <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Today's Focus</span>
                    </div>
                    <h2 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Your priority tasks
                    </h2>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-3">
                  {priorityTasks.map((task) => (
                    <div
                      key={task.id}
                      className="p-4 bg-[#FAFAFA] rounded-[16px] border border-gray-200"
                    >
                      <div className="flex items-start gap-3 mb-3">
                        <div className={`mt-0.5 w-5 h-5 rounded-full border-2 flex-shrink-0 ${
                          task.urgency === 'high' ? 'border-[#FF3E9B]' :
                          task.urgency === 'medium' ? 'border-[#3A8B95]' :
                          'border-gray-300'
                        }`}></div>
                        <div className="flex-1">
                          <h3 className="text-[15px] font-medium text-gray-900 mb-1">{task.title}</h3>
                          <p className="text-[13px] text-gray-500 leading-relaxed mb-2">{task.reason}</p>
                          <div className="text-[12px] text-gray-400">{task.metadata}</div>
                        </div>
                      </div>
                      <button className="w-full bg-white border border-gray-200 text-gray-700 py-3 rounded-[12px] text-[14px] font-medium hover:bg-gray-50 transition-colors">
                        View details
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Wedding Feeling Modal */}
            {activeModal === 'wedding-feeling' && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <Heart size={18} className="text-[#FF3E9B]" />
                      <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Check-in</span>
                    </div>
                    <h2 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      How are you feeling?
                    </h2>
                    <p className="text-[14px] text-gray-600">Let's make sure you're supported</p>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-3 mb-6">
                  {(['calm', 'excited', 'overwhelmed', 'balanced'] as MoodType[]).map((mood) => (
                    <button
                      key={mood}
                      onClick={() => setSelectedMood(mood)}
                      className={`w-full p-4 rounded-[16px] text-left transition-all ${
                        selectedMood === mood
                          ? 'bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white shadow-lg'
                          : 'bg-[#FAFAFA] text-gray-800 hover:bg-gray-100'
                      }`}
                    >
                      <div className="font-medium text-[15px] capitalize">{mood}</div>
                    </button>
                  ))}
                </div>

                {selectedMood && (
                  <div className="p-4 bg-[#F0F9FA] rounded-[16px] border border-[#3A8B95]/20 mb-6">
                    <p className="text-[14px] text-gray-800 italic">
                      "{moodQuotes[selectedMood]}"
                    </p>
                  </div>
                )}

                <button
                  onClick={() => setActiveModal(null)}
                  className="w-full bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-4 rounded-[16px] font-medium disabled:opacity-50"
                  disabled={!selectedMood}
                >
                  Save check-in
                </button>
              </div>
            )}

            {/* Progress Modal */}
            {activeModal === 'progress' && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <TrendingUp size={18} className="text-[#3A8B95]" />
                      <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Progress</span>
                    </div>
                    <h2 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Planning overview
                    </h2>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-6">
                  <div>
                    <div className="text-center mb-4">
                      <div className="text-[48px] font-bold text-[#FF3E9B]">64%</div>
                      <div className="text-[14px] text-gray-600">Complete</div>
                    </div>
                    <div className="h-3 bg-gray-100 rounded-full overflow-hidden">
                      <div className="h-full bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] rounded-full" style={{ width: '64%' }}></div>
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-4">
                    <div className="text-center p-4 bg-[#FFF5F8] rounded-[16px]">
                      <div className="text-[28px] font-semibold text-[#FF3E9B]">24</div>
                      <div className="text-[12px] text-gray-600 mt-1">Tasks done</div>
                    </div>
                    <div className="text-center p-4 bg-[#F0F9FA] rounded-[16px]">
                      <div className="text-[28px] font-semibold text-[#3A8B95]">8</div>
                      <div className="text-[12px] text-gray-600 mt-1">In progress</div>
                    </div>
                    <div className="text-center p-4 bg-[#FAFAFA] rounded-[16px]">
                      <div className="text-[28px] font-semibold text-gray-400">5</div>
                      <div className="text-[12px] text-gray-600 mt-1">Remaining</div>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <h3 className="text-[13px] font-medium text-gray-700 uppercase tracking-wide">By Category</h3>
                    {[
                      { name: 'Venue & Logistics', progress: 85, color: '#FF3E9B' },
                      { name: 'Guest Management', progress: 70, color: '#3A8B95' },
                      { name: 'Vendors', progress: 60, color: '#66D0BC' },
                      { name: 'Styling & Decor', progress: 45, color: '#FF88BA' }
                    ].map((cat) => (
                      <div key={cat.name} className="p-4 bg-[#FAFAFA] rounded-[16px]">
                        <div className="flex justify-between items-center mb-2">
                          <span className="text-[13px] font-medium text-gray-800">{cat.name}</span>
                          <span className="text-[13px] text-gray-500">{cat.progress}%</span>
                        </div>
                        <div className="h-2 bg-white rounded-full overflow-hidden">
                          <div
                            className="h-full rounded-full transition-all"
                            style={{ width: `${cat.progress}%`, backgroundColor: cat.color }}
                          ></div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* Priorities Modal */}
            {activeModal === 'priorities' && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <AlertCircle size={18} className="text-[#FF3E9B]" />
                      <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Priorities</span>
                    </div>
                    <h2 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      What needs attention
                    </h2>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-4">
                  <div className="p-4 bg-[#FFF5F8] rounded-[16px] border-2 border-[#FF3E9B]/30">
                    <div className="flex items-start gap-3 mb-4">
                      <Clock className="text-[#FF3E9B] flex-shrink-0 mt-0.5" size={20} />
                      <div className="flex-1">
                        <div className="text-[15px] font-medium text-gray-900 mb-1">Vendor deposit due in 3 days</div>
                        <div className="text-[13px] text-gray-600">Photography — $1,200</div>
                      </div>
                    </div>
                    <button className="w-full bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white py-3 rounded-[12px] text-[14px] font-medium">
                      Pay now
                    </button>
                  </div>

                  <div className="p-4 bg-[#F0F9FA] rounded-[16px] border-2 border-[#3A8B95]/30">
                    <div className="flex items-start gap-3 mb-4">
                      <Users className="text-[#3A8B95] flex-shrink-0 mt-0.5" size={20} />
                      <div className="flex-1">
                        <div className="text-[15px] font-medium text-gray-900 mb-1">12 guests haven't RSVP'd</div>
                        <div className="text-[13px] text-gray-600">Deadline is in 8 days</div>
                      </div>
                    </div>
                    <button className="w-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] text-white py-3 rounded-[12px] text-[14px] font-medium">
                      Send reminder
                    </button>
                  </div>

                  <div className="p-4 bg-[#FAFAFA] rounded-[16px] border border-gray-200">
                    <div className="flex items-start gap-3">
                      <Info className="text-gray-400 flex-shrink-0 mt-0.5" size={20} />
                      <div>
                        <div className="text-[15px] font-medium text-gray-900 mb-1">Finalize menu selections</div>
                        <div className="text-[13px] text-gray-600 mb-3">Your caterer needs final counts by next week</div>
                        <button className="text-[14px] text-[#FF3E9B] font-medium">Review menu →</button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Budget Modal */}
            {activeModal === 'budget' && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <DollarSign size={18} className="text-[#3A8B95]" />
                      <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Budget</span>
                    </div>
                    <h2 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Budget overview
                    </h2>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-6">
                  <div className="p-5 bg-gradient-to-br from-[#3A8B95] to-[#66D0BC] rounded-[20px] text-white">
                    <div className="text-[14px] opacity-90 mb-1">Total spent</div>
                    <div className="text-[36px] font-bold mb-1">$28,400</div>
                    <div className="text-[14px] opacity-90">of $35,000 budget</div>
                  </div>

                  <div>
                    <div className="h-3 bg-gray-100 rounded-full overflow-hidden mb-3">
                      <div className="h-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] rounded-full" style={{ width: '81%' }}></div>
                    </div>
                    <div className="flex justify-between text-[13px] text-gray-600">
                      <span>$6,600 remaining</span>
                      <span>81% used</span>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <h3 className="text-[13px] font-medium text-gray-700 uppercase tracking-wide">Top Expenses</h3>
                    {[
                      { name: 'Venue', amount: 12000, percent: 34 },
                      { name: 'Catering', amount: 8500, percent: 24 },
                      { name: 'Photography', amount: 4200, percent: 12 },
                      { name: 'Florals', amount: 2300, percent: 7 },
                      { name: 'Other', amount: 1400, percent: 4 }
                    ].map((expense) => (
                      <div key={expense.name} className="flex items-center justify-between p-4 bg-[#FAFAFA] rounded-[16px]">
                        <div className="flex-1">
                          <div className="text-[14px] font-medium text-gray-900 mb-1">{expense.name}</div>
                          <div className="h-1.5 bg-white rounded-full overflow-hidden">
                            <div
                              className="h-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] rounded-full"
                              style={{ width: `${expense.percent}%` }}
                            ></div>
                          </div>
                        </div>
                        <div className="ml-4 text-right">
                          <div className="text-[15px] font-semibold text-gray-900">${expense.amount.toLocaleString()}</div>
                          <div className="text-[12px] text-gray-500">{expense.percent}%</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* Guests Modal */}
            {activeModal === 'guests' && (
              <div className="p-6 pb-8">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-2">
                      <Users size={18} className="text-[#FF3E9B]" />
                      <span className="text-[11px] text-gray-500 uppercase tracking-wide font-medium">Guests</span>
                    </div>
                    <h2 className="text-[24px] text-gray-900" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                      Guest summary
                    </h2>
                  </div>
                  <button
                    onClick={() => setActiveModal(null)}
                    className="w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 transition-colors"
                  >
                    <X size={18} className="text-gray-600" />
                  </button>
                </div>

                <div className="space-y-6">
                  <div className="grid grid-cols-3 gap-3">
                    <div className="text-center p-5 bg-[#F0F9FA] rounded-[20px]">
                      <div className="text-[32px] font-bold text-[#3A8B95]">98</div>
                      <div className="text-[12px] text-gray-600 mt-1">Coming</div>
                    </div>
                    <div className="text-center p-5 bg-[#FFF5F8] rounded-[20px]">
                      <div className="text-[32px] font-bold text-[#FF3E9B]">32</div>
                      <div className="text-[12px] text-gray-600 mt-1">Can't make it</div>
                    </div>
                    <div className="text-center p-5 bg-[#FAFAFA] rounded-[20px]">
                      <div className="text-[32px] font-bold text-gray-400">12</div>
                      <div className="text-[12px] text-gray-600 mt-1">Pending</div>
                    </div>
                  </div>

                  <div className="p-5 bg-[#FAFAFA] rounded-[20px]">
                    <div className="text-[13px] font-medium text-gray-700 uppercase tracking-wide mb-3">Response rate</div>
                    <div className="h-3 bg-white rounded-full overflow-hidden mb-2">
                      <div className="h-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] rounded-full" style={{ width: '92%' }}></div>
                    </div>
                    <div className="text-[13px] text-gray-600">92% of guests have responded</div>
                  </div>

                  <div className="space-y-3">
                    <h3 className="text-[13px] font-medium text-gray-700 uppercase tracking-wide">Quick Stats</h3>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="p-4 bg-[#FAFAFA] rounded-[16px]">
                        <div className="text-[11px] text-gray-500 mb-1">Vegetarian</div>
                        <div className="text-[20px] font-semibold text-gray-900">14</div>
                      </div>
                      <div className="p-4 bg-[#FAFAFA] rounded-[16px]">
                        <div className="text-[11px] text-gray-500 mb-1">Kids</div>
                        <div className="text-[20px] font-semibold text-gray-900">8</div>
                      </div>
                      <div className="p-4 bg-[#FAFAFA] rounded-[16px]">
                        <div className="text-[11px] text-gray-500 mb-1">Plus ones</div>
                        <div className="text-[20px] font-semibold text-gray-900">22</div>
                      </div>
                      <div className="p-4 bg-[#FAFAFA] rounded-[16px]">
                        <div className="text-[11px] text-gray-500 mb-1">Allergies</div>
                        <div className="text-[20px] font-semibold text-gray-900">6</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function CommandCard({ label, value, detail, tone }: { label: string; value: string; detail: string; tone: 'good' | 'warn' | 'risk' }) {
  const colors = {
    good: 'text-[#3A8B95] bg-[#F0F9FA]',
    warn: 'text-[#B7791F] bg-[#FFF8E8]',
    risk: 'text-[#C2415B] bg-[#FFF1F4]',
  };

  return (
    <div className={`rounded-[16px] p-4 ${colors[tone]}`}>
      <div className="text-[11px] uppercase tracking-wide opacity-75 mb-1">{label}</div>
      <div className="text-[24px] font-semibold">{value}</div>
      <div className="text-[12px] opacity-80 mt-1">{detail}</div>
    </div>
  );
}
