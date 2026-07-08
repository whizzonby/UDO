import { useState } from 'react';
import { Home, Calendar, Users, Radio, Image, MoreHorizontal } from 'lucide-react';
import HomePage from './components/HomePage';
import PlanPage from './components/PlanPage';
import GuestsPage from './components/GuestsPage';
import LivePage from './components/LivePage';
import GalleryPage from './components/GalleryPage';
import MorePage from './components/MorePage';
import RegistryPage from './components/RegistryPage';

type Tab = 'home' | 'plan' | 'guests' | 'live' | 'gallery' | 'more' | 'registry';

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>('home');

  const tabs = [
    { id: 'home' as Tab, label: 'Home', icon: Home },
    { id: 'plan' as Tab, label: 'Plan', icon: Calendar },
    { id: 'guests' as Tab, label: 'Guests', icon: Users },
    { id: 'live' as Tab, label: 'Live', icon: Radio },
    { id: 'gallery' as Tab, label: 'Gallery', icon: Image },
    { id: 'more' as Tab, label: 'More', icon: MoreHorizontal },
  ];

  return (
    <div className="h-screen flex flex-col bg-white overflow-hidden">
      {/* Main Content Area */}
      <div className="flex-1 overflow-y-auto pb-20">
        {activeTab === 'home' && <HomePage />}
        {activeTab === 'plan' && <PlanPage />}
        {activeTab === 'guests' && <GuestsPage />}
        {activeTab === 'live' && <LivePage />}
        {activeTab === 'gallery' && <GalleryPage />}
        {activeTab === 'more' && <MorePage onNavigate={(tab) => setActiveTab(tab)} />}
        {activeTab === 'registry' && <RegistryPage />}
      </div>

      {/* Bottom Navigation */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-[0_-4px_12px_rgba(0,0,0,0.05)]">
        <div className="flex justify-around items-center px-2 py-2">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className="flex flex-col items-center justify-center flex-1 py-2 px-1 transition-all duration-200"
              >
                <Icon
                  className={`mb-1 transition-colors ${
                    isActive ? 'text-[#FF3E9B]' : 'text-gray-400'
                  }`}
                  size={22}
                  strokeWidth={isActive ? 2.5 : 2}
                />
                <span
                  className={`text-[10px] transition-colors ${
                    isActive ? 'text-[#FF3E9B] font-medium' : 'text-gray-500'
                  }`}
                >
                  {tab.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
