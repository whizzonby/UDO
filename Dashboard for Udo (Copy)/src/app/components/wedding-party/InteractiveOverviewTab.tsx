import { AlertCircle, Users, Clock, Check, ChevronRight, Plane, Bell, TrendingUp } from 'lucide-react';

interface OverviewProps {
  readinessScore: number;
  responsibilities: any[];
  travelData: any[];
  buzzes: any[];
  people: any[];
  onNavigateToTab: (tab: string) => void;
  onNavigateToItem: (tab: string, itemId: string) => void;
}

export default function InteractiveOverviewTab({
  readinessScore,
  responsibilities,
  travelData,
  buzzes,
  people,
  onNavigateToTab,
  onNavigateToItem
}: OverviewProps) {
  const overdueResponsibilities = responsibilities.filter(r => r.status !== 'completed' && r.urgency === 'high');
  const pendingTravel = travelData.filter(t => t.transferStatus === 'Needs confirmation');
  const unreadBuzzes = buzzes.filter(b => b.deliveryStatus !== 'read').length;
  const incompleteAttire = people.filter(p => p.attireStatus !== 'complete').length;

  const operationalAlerts = [
    ...(overdueResponsibilities.length > 0 ? [{
      id: 'resp',
      title: `${overdueResponsibilities.length} urgent responsibilities need attention`,
      type: 'responsibilities',
      urgency: 'high' as const,
      action: 'Review tasks',
      tab: 'responsibilities',
      impact: 'May affect wedding day readiness'
    }] : []),
    ...(pendingTravel.length > 0 ? [{
      id: 'travel',
      title: `${pendingTravel.length} travel confirmations pending`,
      type: 'travel',
      urgency: 'medium' as const,
      action: 'Follow up',
      tab: 'travel',
      impact: 'Transport coordination at risk'
    }] : []),
    ...(incompleteAttire > 0 ? [{
      id: 'attire',
      title: `${incompleteAttire} wedding party members need attire updates`,
      type: 'attire',
      urgency: 'medium' as const,
      action: 'Send reminder',
      tab: 'people',
      impact: 'Dress fittings may be delayed'
    }] : [])
  ];

  const statusCategories = [
    {
      icon: '💇',
      label: 'Hair & Makeup',
      status: 'Confirmed',
      color: '#1F4D2B',
      details: '3 appointments confirmed',
      onClick: () => onNavigateToTab('wedding-timeline')
    },
    {
      icon: '🚗',
      label: 'Transportation',
      status: pendingTravel.length > 0 ? `Awaiting ${pendingTravel.length} responses` : 'Confirmed',
      color: pendingTravel.length > 0 ? '#FFB020' : '#1F4D2B',
      details: `${travelData.length} travelers`,
      onClick: () => onNavigateToTab('travel')
    },
    {
      icon: '📝',
      label: 'Speeches',
      status: '4 uploaded',
      color: '#3A8B95',
      details: 'All speeches ready',
      onClick: () => onNavigateToTab('files-speeches')
    },
    {
      icon: '✈️',
      label: 'Travel arrivals',
      status: `7 confirmed`,
      color: '#1F4D2B',
      details: `${travelData.length} total travelers`,
      onClick: () => onNavigateToTab('travel')
    },
    {
      icon: '👗',
      label: 'Dress fittings',
      status: incompleteAttire > 0 ? `${incompleteAttire} pending` : 'Complete',
      color: incompleteAttire > 0 ? '#FFB020' : '#1F4D2B',
      details: `${people.length} party members`,
      onClick: () => onNavigateToTab('people')
    },
    {
      icon: '🎯',
      label: 'Emergency kit',
      status: 'Assigned',
      color: '#3A8B95',
      details: 'Ready and packed',
      onClick: () => onNavigateToTab('emergency')
    }
  ];

  return (
    <div className="space-y-6">
      {/* Hero Readiness Card */}
      <div className="bg-gradient-to-br from-[#F0F9FA] to-white rounded-[24px] p-6 border border-[#3A8B95]/20 shadow-sm">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-[18px] text-gray-900 mb-1" style={{ fontWeight: 600 }}>
              WEDDING PARTY READINESS
            </h3>
            <p className="text-[13px] text-gray-600">
              {overdueResponsibilities.length > 0
                ? `${overdueResponsibilities.length} items need attention`
                : 'Everything is on track'}
            </p>
          </div>
          <div className="relative w-24 h-24">
            <svg className="transform -rotate-90" width="96" height="96">
              <circle
                cx="48"
                cy="48"
                r="40"
                fill="none"
                stroke="#E5E7EB"
                strokeWidth="8"
              />
              <circle
                cx="48"
                cy="48"
                r="40"
                fill="none"
                stroke="#1F4D2B"
                strokeWidth="8"
                strokeDasharray={`${(readinessScore / 100) * 251.2} 251.2`}
                strokeLinecap="round"
              />
            </svg>
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="text-[20px] text-[#1F4D2B]" style={{ fontWeight: 600 }}>{readinessScore}%</span>
            </div>
          </div>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-3 gap-3">
          <button
            onClick={() => onNavigateToTab('responsibilities')}
            className="bg-white rounded-xl p-3 text-center hover:shadow-md transition-all"
          >
            <div className="text-[11px] text-gray-600 mb-1">Pending Tasks</div>
            <div className="text-[18px] text-[#FF3E9B]" style={{ fontWeight: 600 }}>
              {responsibilities.filter(r => r.status !== 'completed').length}
            </div>
          </button>
          <button
            onClick={() => onNavigateToTab('buzzes')}
            className="bg-white rounded-xl p-3 text-center hover:shadow-md transition-all"
          >
            <div className="text-[11px] text-gray-600 mb-1">Unread Buzzes</div>
            <div className="text-[18px] text-[#3A8B95]" style={{ fontWeight: 600 }}>
              {unreadBuzzes}
            </div>
          </button>
          <button
            onClick={() => onNavigateToTab('travel')}
            className="bg-white rounded-xl p-3 text-center hover:shadow-md transition-all"
          >
            <div className="text-[11px] text-gray-600 mb-1">Travel Pending</div>
            <div className="text-[18px] text-[#FFB020]" style={{ fontWeight: 600 }}>
              {pendingTravel.length}
            </div>
          </button>
        </div>
      </div>

      {/* Status Grid */}
      <div className="bg-white rounded-[24px] p-6 border border-gray-100 shadow-sm">
        <h3 className="text-[18px] text-gray-900 mb-4" style={{ fontWeight: 600 }}>
          Category Status
        </h3>
        <div className="grid grid-cols-2 gap-3">
          {statusCategories.map((item, idx) => (
            <button
              key={idx}
              onClick={item.onClick}
              className="flex items-center justify-between p-4 rounded-xl hover:bg-[#FAFAFA] transition-all group"
            >
              <div className="flex items-center gap-3">
                <span className="text-[16px]">{item.icon}</span>
                <div className="text-left">
                  <div className="text-[11px] text-gray-600" style={{ fontWeight: 400 }}>{item.label}</div>
                  <div className="text-[13px]" style={{ color: item.color, fontWeight: 500 }}>{item.status}</div>
                </div>
              </div>
              <ChevronRight className="text-gray-400 group-hover:text-[#FF3E9B] transition-colors" size={18} />
            </button>
          ))}
        </div>
      </div>

      {/* Operational Alerts */}
      {operationalAlerts.length > 0 && (
        <div className="bg-white rounded-[24px] p-6 border border-gray-100 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-[18px] text-gray-900" style={{ fontWeight: 600 }}>Needs Attention</h3>
            <span className="text-[12px] text-gray-500">{operationalAlerts.length} items</span>
          </div>

          <div className="space-y-3">
            {operationalAlerts.map((alert) => (
              <button
                key={alert.id}
                onClick={() => onNavigateToTab(alert.tab)}
                className="w-full bg-gradient-to-br from-[#FFF5F8] to-white rounded-[16px] p-4 border border-[#FFB0D1]/30 hover:shadow-md transition-all text-left group"
              >
                <div className="flex items-start gap-3">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                    alert.urgency === 'high' ? 'bg-[#FFE5F0]' : 'bg-[#FFF5E5]'
                  }`}>
                    <AlertCircle size={20} className={alert.urgency === 'high' ? 'text-[#FF3E9B]' : 'text-[#FFB020]'} />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <div className="text-[14px] text-gray-900 mb-1" style={{ fontWeight: 500 }}>
                          {alert.title}
                        </div>
                        <div className="text-[12px] text-gray-600">{alert.impact}</div>
                      </div>
                      <span className={`px-2 py-1 rounded-full text-[10px] ml-2 ${
                        alert.urgency === 'high' ? 'bg-[#FF3E9B] text-white' : 'bg-[#FFB020] text-white'
                      }`} style={{ fontWeight: 500 }}>
                        {alert.urgency === 'high' ? 'High priority' : 'Medium priority'}
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-[12px] text-[#FF3E9B] font-medium group-hover:underline">
                        {alert.action}
                      </span>
                      <ChevronRight size={14} className="text-[#FF3E9B]" />
                    </div>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Live Activity Feed */}
      <div className="bg-white rounded-[24px] p-6 border border-gray-100 shadow-sm">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-[18px] text-gray-900" style={{ fontWeight: 600 }}>Recent Activity</h3>
          <button className="text-[13px] text-[#FF3E9B]" style={{ fontWeight: 500 }}>
            View all
          </button>
        </div>
        <div className="space-y-3">
          {[
            { text: 'Emily uploaded speech draft', time: '2h ago', icon: '📝', tab: 'files-speeches' },
            { text: 'Best man confirmed transport', time: '4h ago', icon: '🚗', tab: 'travel' },
            { text: 'Hair stylist adjusted schedule', time: '6h ago', icon: '💇', tab: 'wedding-timeline' }
          ].map((activity, idx) => (
            <button
              key={idx}
              onClick={() => onNavigateToTab(activity.tab)}
              className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-[#FAFAFA] transition-all text-left group"
            >
              <span className="text-[16px]">{activity.icon}</span>
              <div className="flex-1">
                <div className="text-[13px] text-gray-900">{activity.text}</div>
                <div className="flex items-center gap-2 text-[11px] text-gray-500 mt-0.5">
                  <span>{activity.time}</span>
                </div>
              </div>
              <ChevronRight className="text-gray-400 group-hover:text-[#FF3E9B]" size={16} />
            </button>
          ))}
        </div>
      </div>

      {/* Quick Actions Panel */}
      <div className="bg-gradient-to-br from-[#FAFAFA] to-white rounded-[24px] p-6 border border-gray-100">
        <h3 className="text-[18px] text-gray-900 mb-4" style={{ fontWeight: 600 }}>Quick Actions</h3>
        <div className="grid grid-cols-2 gap-3">
          {[
            { icon: Users, label: 'Add Person', color: '#FF3E9B', onClick: () => {} },
            { icon: Clock, label: 'Update Timeline', color: '#3A8B95', onClick: () => onNavigateToTab('wedding-timeline') },
            { icon: Bell, label: 'Send Buzz', color: '#FFB020', onClick: () => onNavigateToTab('buzzes') },
            { icon: Plane, label: 'Manage Travel', color: '#4A90E2', onClick: () => onNavigateToTab('travel') }
          ].map((action, idx) => {
            const Icon = action.icon;
            return (
              <button
                key={idx}
                onClick={action.onClick}
                className="flex items-center gap-3 p-4 bg-white rounded-xl hover:shadow-md transition-all border border-gray-100"
              >
                <div
                  className="w-10 h-10 rounded-full flex items-center justify-center"
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
  );
}
