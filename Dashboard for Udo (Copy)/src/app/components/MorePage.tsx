import { ChevronRight, User, Settings, Users, Bell, CreditCard, HelpCircle, Mail, Heart, LogOut, Shield, Gift } from 'lucide-react';

interface MorePageProps {
  onNavigate?: (tab: 'registry') => void;
}

export default function MorePage({ onNavigate }: MorePageProps) {
  const menuItems = [
    { icon: User, title: 'Profile', subtitle: 'Edit your personal information' },
    { icon: Settings, title: 'Wedding settings', subtitle: 'Date, location, and event details' },
    { icon: Gift, title: 'Registry', subtitle: 'Manage your wedding registry', route: 'registry' as const },
    { icon: Users, title: 'Collaborators', subtitle: 'Share planning access' },
    { icon: Users, title: 'Decision-makers', subtitle: 'Manage who can approve decisions' },
    { icon: Bell, title: 'Notifications', subtitle: 'Manage alerts and reminders' },
    { icon: Settings, title: 'Support preferences', subtitle: 'Set your guidance style' },
    { icon: CreditCard, title: 'Subscription / Wedding Pass', subtitle: 'Manage your plan' },
    { icon: Mail, title: 'Feedback / Contact', subtitle: 'We would love to hear from you' },
    { icon: HelpCircle, title: 'Help center', subtitle: 'FAQs and guides' },
    { icon: Shield, title: 'Privacy', subtitle: 'Data and security settings' },
  ];

  return (
    <div className="min-h-screen bg-[#fefdfb]">
      {/* Header */}
      <div className="bg-gradient-to-br from-[#FAFAFA] to-white px-4 pt-8 pb-6">
        <h1 className="text-3xl text-[#FF3E9B] mb-2">More</h1>
        <p className="text-sm text-gray-600">Settings and support</p>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-4">
        {/* Profile Card */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 mb-4">
          <div className="flex items-center">
            <div className="w-16 h-16 bg-gradient-to-br from-[#d45d78] to-[#f194b2] rounded-full flex items-center justify-center text-white text-2xl mr-4">
              O
            </div>
            <div className="flex-1">
              <h3 className="text-lg font-medium text-[#FF3E9B]">Olivia Martinez</h3>
              <p className="text-sm text-gray-600">olivia@email.com</p>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>
        </div>

        {/* Menu Items */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          {menuItems.map((item, idx) => {
            const Icon = item.icon;
            return (
              <button
                key={idx}
                onClick={() => item.route && onNavigate?.(item.route)}
                className="w-full flex items-center p-4 hover:bg-[#FAFAFA]/30 transition-colors border-b border-gray-100 last:border-0"
              >
                <div className="bg-[#FAFAFA] p-2 rounded-[16px] mr-3">
                  <Icon className="text-[#FF3E9B]" size={20} />
                </div>
                <div className="flex-1 text-left">
                  <div className="font-medium text-gray-800">{item.title}</div>
                  <div className="text-xs text-gray-600 mt-0.5">{item.subtitle}</div>
                </div>
                <ChevronRight className="text-gray-400 flex-shrink-0" size={20} />
              </button>
            );
          })}
        </div>

        {/* Contact UDO */}
        <div className="bg-gradient-to-br from-[#FAFAFA] to-white rounded-2xl p-5 border border-[#f194b2]/20 text-center">
          <Mail size={32} className="text-[#FF3E9B] mx-auto mb-3" />
          <h3 className="font-medium text-[#FF3E9B] mb-2">Get in touch</h3>
          <p className="text-sm text-gray-600 mb-4">
            hello@udowedding.com
          </p>
          <p className="text-xs italic text-gray-600">
            "Planning should feel peaceful. We are always here to listen."
          </p>
        </div>

        {/* About UDO */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 text-center">
          <div className="flex items-center justify-center mb-3">
            <Heart className="text-[#FF3E9B] mr-2" size={24} />
            <h3 className="text-xl text-[#FF3E9B]" style={{ fontFamily: 'Playfair Display, serif' }}>UDO</h3>
          </div>
          <p className="text-sm text-gray-600 mb-2">
            UDO means peace.
          </p>
          <p className="text-xs text-gray-500">
            Version 1.0.0
          </p>
        </div>

        {/* Sign Out */}
        <button className="w-full bg-white rounded-2xl shadow-sm border border-gray-100 p-4 flex items-center justify-center hover:bg-gray-50 transition-colors">
          <LogOut className="text-[#FF3E9B] mr-2" size={20} />
          <span className="font-medium text-[#FF3E9B]">Sign out</span>
        </button>

        {/* Bottom padding for safe area */}
        <div className="h-8"></div>
      </div>
    </div>
  );
}
