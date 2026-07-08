import { X, DollarSign, Users, Calendar, Briefcase, Utensils, MapPin, Plane, Plus, Check, Edit, Trash2, Search, Filter, ChevronRight, AlertCircle, Clock } from 'lucide-react';

interface PlanOverviewModalsProps {
  activeModal: string | null;
  onClose: () => void;
  onOpenFormModal?: (modal: string) => void;
  onNavigateToTab?: (tab: string) => void;
}

export default function PlanOverviewModals({ activeModal, onClose, onOpenFormModal, onNavigateToTab }: PlanOverviewModalsProps) {

  // BUDGET MODAL
  if (activeModal === 'budget') {
    const budgetCategories = [
      { name: 'Venue & Catering', allocated: 18000, spent: 15200, remaining: 2800, status: 'on-track' },
      { name: 'Photography & Video', allocated: 8000, spent: 8000, remaining: 0, status: 'complete' },
      { name: 'Florals & Décor', allocated: 6000, spent: 3200, remaining: 2800, status: 'on-track' },
      { name: 'Music & Entertainment', allocated: 4000, spent: 0, remaining: 4000, status: 'pending' },
      { name: 'Attire & Beauty', allocated: 5000, spent: 3800, remaining: 1200, status: 'on-track' },
      { name: 'Invitations & Stationery', allocated: 1500, spent: 1500, remaining: 0, status: 'complete' },
      { name: 'Rings', allocated: 3500, spent: 3500, remaining: 0, status: 'complete' },
      { name: 'Transportation', allocated: 2000, spent: 0, remaining: 2000, status: 'pending' },
      { name: 'Favors & Gifts', allocated: 1000, spent: 450, remaining: 550, status: 'on-track' }
    ];

    const totalAllocated = budgetCategories.reduce((sum, cat) => sum + cat.allocated, 0);
    const totalSpent = budgetCategories.reduce((sum, cat) => sum + cat.spent, 0);
    const totalRemaining = budgetCategories.reduce((sum, cat) => sum + cat.remaining, 0);

    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Budget Overview</h2>
              <p className="text-sm text-gray-600 mt-1">${totalSpent.toLocaleString()} spent of ${totalAllocated.toLocaleString()} allocated</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8 space-y-6">
            {/* Summary Cards */}
            <div className="grid grid-cols-3 gap-4">
              <div className="bg-gradient-to-br from-blue-50 to-white rounded-2xl p-6 border border-blue-100">
                <div className="text-sm text-gray-600 mb-2">Total Budget</div>
                <div className="text-3xl font-bold text-blue-600">${totalAllocated.toLocaleString()}</div>
              </div>
              <div className="bg-gradient-to-br from-green-50 to-white rounded-2xl p-6 border border-green-100">
                <div className="text-sm text-gray-600 mb-2">Spent</div>
                <div className="text-3xl font-bold text-green-600">${totalSpent.toLocaleString()}</div>
                <div className="text-xs text-gray-500 mt-1">{Math.round((totalSpent / totalAllocated) * 100)}% of budget</div>
              </div>
              <div className="bg-gradient-to-br from-purple-50 to-white rounded-2xl p-6 border border-purple-100">
                <div className="text-sm text-gray-600 mb-2">Remaining</div>
                <div className="text-3xl font-bold text-purple-600">${totalRemaining.toLocaleString()}</div>
                <div className="text-xs text-gray-500 mt-1">{Math.round((totalRemaining / totalAllocated) * 100)}% available</div>
              </div>
            </div>

            {/* Category Breakdown */}
            <div>
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-semibold text-gray-900">Category Breakdown</h3>
                <button
                  onClick={() => onOpenFormModal?.('add-budget-expense')}
                  className="px-4 py-2 bg-[#d45d78] text-white rounded-xl hover:bg-[#e63587] transition-colors flex items-center gap-2 text-sm font-medium"
                >
                  <Plus size={16} />
                  Add Expense
                </button>
              </div>

              <div className="space-y-3">
                {budgetCategories.map((category, idx) => (
                  <div key={idx} className="bg-gray-50 rounded-xl p-5 hover:bg-gray-100 transition-colors cursor-pointer">
                    <div className="flex items-center justify-between mb-3">
                      <div>
                        <h4 className="font-semibold text-gray-900">{category.name}</h4>
                        <p className="text-sm text-gray-600">
                          ${category.spent.toLocaleString()} of ${category.allocated.toLocaleString()}
                        </p>
                      </div>
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                        category.status === 'complete' ? 'bg-green-100 text-green-700' :
                        category.status === 'on-track' ? 'bg-blue-100 text-blue-700' :
                        'bg-amber-100 text-amber-700'
                      }`}>
                        {category.status === 'complete' ? 'Complete' :
                         category.status === 'on-track' ? 'On Track' :
                         'Pending'}
                      </span>
                    </div>
                    <div className="relative w-full bg-gray-200 rounded-full h-2">
                      <div
                        className={`h-2 rounded-full transition-all ${
                          category.status === 'complete' ? 'bg-green-500' :
                          category.status === 'on-track' ? 'bg-blue-500' :
                          'bg-gray-400'
                        }`}
                        style={{ width: `${(category.spent / category.allocated) * 100}%` }}
                      />
                    </div>
                    <div className="flex items-center justify-between mt-2 text-xs text-gray-600">
                      <span>{Math.round((category.spent / category.allocated) * 100)}% used</span>
                      <span>${category.remaining.toLocaleString()} remaining</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Quick Actions */}
            <div className="bg-gradient-to-br from-purple-50 to-white rounded-2xl p-6 border border-purple-100">
              <h4 className="font-semibold text-gray-900 mb-4">Budget Tools</h4>
              <div className="grid grid-cols-2 gap-3">
                <button
                  onClick={() => onOpenFormModal?.('edit-budget-categories')}
                  className="px-4 py-3 bg-white border border-gray-200 rounded-xl hover:border-purple-300 transition-all text-sm font-medium text-left"
                >
                  Edit Categories
                </button>
                <button className="px-4 py-3 bg-white border border-gray-200 rounded-xl hover:border-purple-300 transition-all text-sm font-medium text-left">
                  Export to Excel
                </button>
                <button className="px-4 py-3 bg-white border border-gray-200 rounded-xl hover:border-purple-300 transition-all text-sm font-medium text-left">
                  Payment Schedule
                </button>
                <button className="px-4 py-3 bg-white border border-gray-200 rounded-xl hover:border-purple-300 transition-all text-sm font-medium text-left">
                  View Receipts
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // GUESTS MODAL
  if (activeModal === 'guests') {
    const guestStats = {
      totalInvited: 120,
      confirmed: 95,
      declined: 12,
      pending: 13,
      plusOnes: 18,
      children: 8
    };

    const guestGroups = [
      { name: 'Immediate Family', invited: 24, confirmed: 24, declined: 0 },
      { name: 'Extended Family', invited: 35, confirmed: 28, declined: 5 },
      { name: 'Friends', invited: 42, confirmed: 32, declined: 6 },
      { name: 'Work Colleagues', invited: 12, confirmed: 8, declined: 1 },
      { name: 'Plus Ones', invited: 7, confirmed: 3, declined: 0 }
    ];

    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Guest List</h2>
              <p className="text-sm text-gray-600 mt-1">{guestStats.confirmed} confirmed of {guestStats.totalInvited} invited</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8 space-y-6">
            {/* Stats Grid */}
            <div className="grid grid-cols-3 gap-4">
              <div className="bg-gradient-to-br from-green-50 to-white rounded-2xl p-5 border border-green-100">
                <Users size={24} className="text-green-600 mb-2" />
                <div className="text-2xl font-bold text-green-600">{guestStats.confirmed}</div>
                <div className="text-sm text-gray-600">Confirmed</div>
              </div>
              <div className="bg-gradient-to-br from-red-50 to-white rounded-2xl p-5 border border-red-100">
                <AlertCircle size={24} className="text-red-600 mb-2" />
                <div className="text-2xl font-bold text-red-600">{guestStats.declined}</div>
                <div className="text-sm text-gray-600">Declined</div>
              </div>
              <div className="bg-gradient-to-br from-amber-50 to-white rounded-2xl p-5 border border-amber-100">
                <Clock size={24} className="text-amber-600 mb-2" />
                <div className="text-2xl font-bold text-amber-600">{guestStats.pending}</div>
                <div className="text-sm text-gray-600">Pending RSVP</div>
              </div>
            </div>

            {/* Guest Groups */}
            <div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Guest Groups</h3>
              <div className="space-y-3">
                {guestGroups.map((group, idx) => {
                  const pending = group.invited - group.confirmed - group.declined;
                  return (
                    <div key={idx} className="bg-gray-50 rounded-xl p-5 hover:bg-gray-100 transition-colors cursor-pointer">
                      <div className="flex items-center justify-between mb-3">
                        <h4 className="font-semibold text-gray-900">{group.name}</h4>
                        <div className="flex items-center gap-2 text-sm">
                          <span className="text-green-600 font-medium">{group.confirmed} confirmed</span>
                          {pending > 0 && (
                            <span className="text-amber-600">• {pending} pending</span>
                          )}
                        </div>
                      </div>
                      <div className="relative w-full bg-gray-200 rounded-full h-2">
                        <div
                          className="h-2 rounded-full bg-green-500"
                          style={{ width: `${(group.confirmed / group.invited) * 100}%` }}
                        />
                      </div>
                      <div className="text-xs text-gray-600 mt-2">
                        {group.confirmed} of {group.invited} guests ({Math.round((group.confirmed / group.invited) * 100)}%)
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button
                onClick={() => onNavigateToTab?.('guests')}
                className="flex-1 px-6 py-3 bg-[#d45d78] text-white rounded-xl hover:bg-[#e63587] transition-colors font-medium"
              >
                View Full Guest List
              </button>
              <button className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-medium">
                Send Reminder
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // EVENT STRUCTURE / WEDDING FLOW MODAL
  if (activeModal === 'event-structure') {
    const timelineMoments = [
      { time: '3:30 PM', event: 'Guests Arrive', location: 'Ceremony Venue', duration: '30 min' },
      { time: '4:00 PM', event: 'Ceremony Begins', location: 'Beach Pavilion', duration: '30 min' },
      { time: '4:30 PM', event: 'Cocktail Hour', location: 'Garden Terrace', duration: '90 min' },
      { time: '6:00 PM', event: 'Reception Doors Open', location: 'Main Ballroom', duration: '30 min' },
      { time: '6:30 PM', event: 'Grand Entrance', location: 'Main Ballroom', duration: '10 min' },
      { time: '6:40 PM', event: 'First Dance', location: 'Dance Floor', duration: '5 min' },
      { time: '6:45 PM', event: 'Dinner Service', location: 'Main Ballroom', duration: '90 min' },
      { time: '8:15 PM', event: 'Toasts & Speeches', location: 'Main Ballroom', duration: '30 min' },
      { time: '8:45 PM', event: 'Cake Cutting', location: 'Cake Table', duration: '15 min' },
      { time: '9:00 PM', event: 'Dancing', location: 'Dance Floor', duration: '120 min' },
      { time: '11:00 PM', event: 'After Party', location: 'Poolside Lounge', duration: '120 min' }
    ];

    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Wedding Day Timeline</h2>
              <p className="text-sm text-gray-600 mt-1">{timelineMoments.length} moments planned • 7.5 hours</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8">
            <div className="space-y-1">
              {timelineMoments.map((moment, idx) => (
                <div key={idx} className="flex items-start gap-4 p-4 hover:bg-purple-50 rounded-xl transition-colors cursor-pointer group">
                  <div className="flex-shrink-0 w-24 text-right">
                    <div className="text-lg font-bold text-[#d45d78]">{moment.time}</div>
                    <div className="text-xs text-gray-500">{moment.duration}</div>
                  </div>
                  <div className="flex-shrink-0 w-1 bg-gradient-to-b from-[#d45d78] to-[#f194b2] rounded-full self-stretch"></div>
                  <div className="flex-1">
                    <h4 className="font-semibold text-gray-900 mb-1">{moment.event}</h4>
                    <p className="text-sm text-gray-600 flex items-center gap-2">
                      <MapPin size={14} />
                      {moment.location}
                    </p>
                  </div>
                  <button className="p-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Edit size={18} className="text-gray-400" />
                  </button>
                </div>
              ))}
            </div>

            <div className="mt-6 flex gap-3">
              <button
                onClick={() => onOpenFormModal?.('add-timeline-moment')}
                className="flex-1 px-6 py-3 bg-[#d45d78] text-white rounded-xl hover:bg-[#e63587] transition-colors font-medium flex items-center justify-center gap-2"
              >
                <Plus size={18} />
                Add Moment
              </button>
              <button className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-xl hover:bg-purple-700 transition-colors font-medium">
                Export Schedule
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // VENDORS MODAL
  if (activeModal === 'vendors') {
    const vendors = [
      { category: 'Venue', status: 'Booked', name: 'Sunset Gardens', contact: 'Sarah Thompson', phone: '555-0200', amount: '$12,000', paid: '$6,000' },
      { category: 'Photographer', status: 'Booked', name: 'Emma Stone Photography', contact: 'Emma Stone', phone: '555-0201', amount: '$8,000', paid: '$8,000' },
      { category: 'Catering', status: 'Booked', name: 'Gourmet Affairs', contact: 'Chef Marco', phone: '555-0202', amount: '$15,000', paid: '$7,500' },
      { category: 'Florist', status: 'Shortlisted', shortlisted: ['Bloom & Co', 'Garden Dreams', 'Petal Perfect'] },
      { category: 'DJ / Band', status: 'Shortlisted', shortlisted: ['Harmony Beats', 'Elite Sound', 'Rhythm & Soul', 'Classic Vibes'] },
      { category: 'Hair & Makeup', status: 'Needed' },
      { category: 'Videographer', status: 'Shortlisted', shortlisted: ['Cinematic Weddings', 'Love Story Films', 'Timeless Video'] },
      { category: 'Transportation', status: 'Needed' },
      { category: 'Cake', status: 'Needed' }
    ];

    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-5xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Vendors</h2>
              <p className="text-sm text-gray-600 mt-1">3 booked • 3 shortlisted • 3 needed</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8 space-y-4">
            {vendors.map((vendor, idx) => (
              <div key={idx} className={`rounded-2xl p-6 border-2 transition-all cursor-pointer ${
                vendor.status === 'Booked' ? 'bg-green-50 border-green-200 hover:border-green-300' :
                vendor.status === 'Shortlisted' ? 'bg-blue-50 border-blue-200 hover:border-blue-300' :
                'bg-amber-50 border-amber-200 hover:border-amber-300'
              }`}>
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-xl font-semibold text-gray-900">{vendor.category}</h3>
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                        vendor.status === 'Booked' ? 'bg-green-600 text-white' :
                        vendor.status === 'Shortlisted' ? 'bg-blue-600 text-white' :
                        'bg-amber-600 text-white'
                      }`}>
                        {vendor.status}
                      </span>
                    </div>
                    {vendor.name && (
                      <p className="text-lg font-medium text-gray-900 mb-1">{vendor.name}</p>
                    )}
                    {vendor.contact && (
                      <p className="text-sm text-gray-600">Contact: {vendor.contact} • {vendor.phone}</p>
                    )}
                  </div>
                  {vendor.amount && (
                    <div className="text-right">
                      <div className="text-2xl font-bold text-gray-900">{vendor.amount}</div>
                      {vendor.paid && (
                        <div className="text-sm text-green-600">{vendor.paid} paid</div>
                      )}
                    </div>
                  )}
                </div>

                {vendor.shortlisted && (
                  <div className="mt-4">
                    <div className="text-xs text-gray-600 mb-2">SHORTLISTED ({vendor.shortlisted.length})</div>
                    <div className="flex flex-wrap gap-2">
                      {vendor.shortlisted.map((name, i) => (
                        <span key={i} className="px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-sm">
                          {name}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                <div className="mt-4 flex gap-2">
                  {vendor.status === 'Booked' && (
                    <>
                      <button className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm hover:bg-gray-50">
                        View Contract
                      </button>
                      <button className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm hover:bg-gray-50">
                        Contact Vendor
                      </button>
                    </>
                  )}
                  {vendor.status === 'Shortlisted' && (
                    <>
                      <button className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700">
                        Request Quote
                      </button>
                      <button className="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm hover:bg-gray-50">
                        Schedule Meeting
                      </button>
                    </>
                  )}
                  {vendor.status === 'Needed' && (
                    <button className="px-4 py-2 bg-[#d45d78] text-white rounded-lg text-sm hover:bg-[#e63587]">
                      Find Vendors
                    </button>
                  )}
                </div>
              </div>
            ))}

            <button
              onClick={() => onOpenFormModal?.('add-vendor')}
              className="w-full py-4 border-2 border-dashed border-gray-300 rounded-2xl text-gray-600 hover:border-[#d45d78] hover:text-[#d45d78] transition-all flex items-center justify-center gap-2 font-medium"
            >
              <Plus size={20} />
              Add Custom Vendor
            </button>
          </div>
        </div>
      </div>
    );
  }

  // FOOD & DINING MODAL
  if (activeModal === 'food') {
    const menuDetails = {
      style: 'Plated Dinner',
      courses: 3,
      appetizers: ['Caprese Salad', 'Butternut Squash Soup'],
      mains: ['Herb-Crusted Salmon', 'Filet Mignon', 'Vegetarian Risotto'],
      desserts: ['Tiramisu', 'Chocolate Lava Cake', 'Fruit Tart']
    };

    const dietaryNeeds = [
      { restriction: 'Vegetarian', count: 12, menuProvided: true },
      { restriction: 'Vegan', count: 4, menuProvided: true },
      { restriction: 'Gluten-Free', count: 6, menuProvided: true },
      { restriction: 'Nut Allergy', count: 3, menuProvided: true },
      { restriction: 'Dairy-Free', count: 2, menuProvided: false }
    ];

    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Food & Dining</h2>
              <p className="text-sm text-gray-600 mt-1">{menuDetails.style} • {menuDetails.courses} courses • {dietaryNeeds.reduce((sum, d) => sum + d.count, 0)} dietary accommodations</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8 space-y-6">
            {/* Menu Overview */}
            <div className="bg-gradient-to-br from-purple-50 to-white rounded-2xl p-6 border border-purple-100">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Menu</h3>

              <div className="space-y-4">
                <div>
                  <div className="text-sm font-medium text-gray-700 mb-2">Appetizers</div>
                  <div className="flex flex-wrap gap-2">
                    {menuDetails.appetizers.map((item, i) => (
                      <span key={i} className="px-3 py-1.5 bg-white border border-purple-200 rounded-lg text-sm">
                        {item}
                      </span>
                    ))}
                  </div>
                </div>

                <div>
                  <div className="text-sm font-medium text-gray-700 mb-2">Main Courses</div>
                  <div className="flex flex-wrap gap-2">
                    {menuDetails.mains.map((item, i) => (
                      <span key={i} className="px-3 py-1.5 bg-white border border-purple-200 rounded-lg text-sm">
                        {item}
                      </span>
                    ))}
                  </div>
                </div>

                <div>
                  <div className="text-sm font-medium text-gray-700 mb-2">Desserts</div>
                  <div className="flex flex-wrap gap-2">
                    {menuDetails.desserts.map((item, i) => (
                      <span key={i} className="px-3 py-1.5 bg-white border border-purple-200 rounded-lg text-sm">
                        {item}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Dietary Needs */}
            <div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Dietary Accommodations</h3>
              <div className="space-y-3">
                {dietaryNeeds.map((diet, idx) => (
                  <div key={idx} className={`p-4 rounded-xl border-2 ${
                    diet.menuProvided ? 'bg-green-50 border-green-200' : 'bg-amber-50 border-amber-200'
                  }`}>
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="font-semibold text-gray-900">{diet.restriction}</div>
                        <div className="text-sm text-gray-600">{diet.count} guests</div>
                      </div>
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                        diet.menuProvided ? 'bg-green-600 text-white' : 'bg-amber-600 text-white'
                      }`}>
                        {diet.menuProvided ? 'Menu Provided' : 'Needs Menu'}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button className="flex-1 px-6 py-3 bg-[#d45d78] text-white rounded-xl hover:bg-[#e63587] transition-colors font-medium">
                Edit Menu
              </button>
              <button className="flex-1 px-6 py-3 bg-purple-600 text-white rounded-xl hover:bg-purple-700 transition-colors font-medium">
                Update Dietary Needs
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // SEATING MODAL
  if (activeModal === 'seating') {
    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-3xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Seating Arrangements</h2>
              <p className="text-sm text-gray-600 mt-1">120 guests • 15 tables • 10 unassigned</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8 space-y-6">
            <div className="bg-gradient-to-br from-blue-50 to-white rounded-2xl p-8 border border-blue-100 text-center">
              <MapPin size={48} className="text-blue-600 mx-auto mb-4" />
              <h3 className="text-2xl font-semibold text-gray-900 mb-2">Interactive Seating Chart</h3>
              <p className="text-gray-600 mb-6">Drag and drop guests to assign tables</p>
              <button
                onClick={() => onOpenFormModal?.('seating-board')}
                className="px-8 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-medium"
              >
                Open Seating Board
              </button>
            </div>

            <div>
              <h4 className="font-semibold text-gray-900 mb-3">Quick Stats</h4>
              <div className="grid grid-cols-3 gap-3">
                <div className="bg-green-50 rounded-xl p-4 text-center">
                  <div className="text-2xl font-bold text-green-600">110</div>
                  <div className="text-xs text-gray-600">Seated</div>
                </div>
                <div className="bg-amber-50 rounded-xl p-4 text-center">
                  <div className="text-2xl font-bold text-amber-600">10</div>
                  <div className="text-xs text-gray-600">Unassigned</div>
                </div>
                <div className="bg-purple-50 rounded-xl p-4 text-center">
                  <div className="text-2xl font-bold text-purple-600">15</div>
                  <div className="text-xs text-gray-600">Tables</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // TRAVEL & STAY MODAL
  if (activeModal === 'travel-stay') {
    return (
      <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4" onClick={onClose}>
        <div className="bg-white rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
          <div className="sticky top-0 bg-white border-b border-gray-200 px-8 py-6 rounded-t-3xl flex items-center justify-between">
            <div>
              <h2 className="text-3xl font-bold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>Travel & Accommodations</h2>
              <p className="text-sm text-gray-600 mt-1">32 traveling guests • 12 transport requests</p>
            </div>
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <X size={24} className="text-gray-600" />
            </button>
          </div>

          <div className="p-8 space-y-6">
            {/* Hotel Blocks */}
            <div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Hotel Blocks</h3>
              <div className="space-y-3">
                {[
                  { name: 'Sunset Resort', rooms: 20, booked: 15, rate: '$189/night', code: 'WEDDING2026' },
                  { name: 'Garden Inn', rooms: 15, booked: 12, rate: '$149/night', code: 'SMITH-WEDDING' }
                ].map((hotel, idx) => (
                  <div key={idx} className="bg-gradient-to-br from-blue-50 to-white rounded-xl p-5 border border-blue-100">
                    <div className="flex items-start justify-between mb-3">
                      <div>
                        <h4 className="font-semibold text-gray-900 text-lg">{hotel.name}</h4>
                        <p className="text-sm text-gray-600">{hotel.rate} • Code: {hotel.code}</p>
                      </div>
                      <span className="px-3 py-1 bg-blue-600 text-white rounded-full text-xs font-medium">
                        {hotel.booked}/{hotel.rooms} booked
                      </span>
                    </div>
                    <div className="relative w-full bg-blue-200 rounded-full h-2">
                      <div
                        className="h-2 rounded-full bg-blue-600"
                        style={{ width: `${(hotel.booked / hotel.rooms) * 100}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Transportation */}
            <div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Transportation</h3>
              <div className="bg-gradient-to-br from-purple-50 to-white rounded-xl p-5 border border-purple-100">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-gray-600 mb-1">Shuttle Service</div>
                    <div className="text-lg font-semibold text-gray-900">Booked</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-600 mb-1">Pick-up Requests</div>
                    <div className="text-lg font-semibold text-gray-900">12 guests</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button className="flex-1 px-6 py-3 bg-[#d45d78] text-white rounded-xl hover:bg-[#e63587] transition-colors font-medium">
                Share Travel Info
              </button>
              <button className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors font-medium">
                Update Hotels
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return null;
}
