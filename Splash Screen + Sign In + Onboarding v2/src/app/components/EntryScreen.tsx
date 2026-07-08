import React from 'react';
import { Sparkles } from 'lucide-react';

interface EntryScreenProps {
  onBegin: () => void;
}

export const EntryScreen: React.FC<EntryScreenProps> = ({ onBegin }) => {
  return (
    <div className="min-h-screen bg-[#f8edeb] flex flex-col items-center justify-center px-8 relative overflow-hidden">
      {/* Soft sparkles */}
      <div className="absolute top-24 left-12 animate-pulse opacity-50">
        <Sparkles size={18} className="text-[#d45d78]" />
      </div>
      <div className="absolute top-40 right-16 animate-pulse opacity-40" style={{ animationDelay: '1s' }}>
        <Sparkles size={14} className="text-[#f194b2]" />
      </div>
      <div className="absolute bottom-48 left-16 animate-pulse opacity-45" style={{ animationDelay: '2s' }}>
        <Sparkles size={16} className="text-[#d45d78]" />
      </div>
      <div className="absolute bottom-36 right-14 animate-pulse opacity-50" style={{ animationDelay: '1.5s' }}>
        <Sparkles size={12} className="text-[#285301]" />
      </div>

      {/* Main content */}
      <div className="text-center space-y-6 animate-fade-in max-w-sm">
        {/* Hand-drawn car illustration */}
        <div className="flex justify-center mb-6">
          <svg
            width="220"
            height="130"
            viewBox="0 0 220 130"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="animate-gentle-bounce"
          >
            {/* Car body */}
            <path
              d="M45 75 L65 75 L70 58 L100 58 L105 75 L170 75 L170 90 L45 90 Z"
              stroke="#285301"
              strokeWidth="2.5"
              fill="#ffffff"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            {/* Car windows */}
            <path
              d="M75 75 L78 63 L95 63 L98 75"
              stroke="#285301"
              strokeWidth="2"
              fill="none"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            {/* Wheels */}
            <circle cx="75" cy="90" r="9" stroke="#285301" strokeWidth="2.5" fill="white" />
            <circle cx="75" cy="90" r="3.5" fill="#d45d78" />
            <circle cx="145" cy="90" r="9" stroke="#285301" strokeWidth="2.5" fill="white" />
            <circle cx="145" cy="90" r="3.5" fill="#d45d78" />
            {/* "Just Married" sign */}
            <rect x="110" y="68" width="54" height="13" stroke="#d45d78" strokeWidth="1.5" fill="white" rx="3" />
            <text x="137" y="77" fontSize="7" fill="#d45d78" textAnchor="middle" fontFamily="serif" fontWeight="500">
              Just Married
            </text>
            {/* Cans trailing behind - softer colors */}
            <circle cx="180" cy="100" r="4.5" stroke="#d45d78" strokeWidth="1.5" fill="#f8edeb" className="animate-sway" />
            <circle cx="192" cy="104" r="4" stroke="#f194b2" strokeWidth="1.5" fill="#f8edeb" className="animate-sway" style={{ animationDelay: '0.2s' }} />
            <circle cx="202" cy="107" r="3.5" stroke="#d45d78" strokeWidth="1.5" fill="#f8edeb" className="animate-sway" style={{ animationDelay: '0.4s' }} />
            {/* String connecting cans */}
            <path
              d="M170 82 Q175 92 180 100 Q186 103 192 104 Q197 106 202 107"
              stroke="#d45d78"
              strokeWidth="1"
              fill="none"
              strokeDasharray="2,2"
              opacity="0.6"
            />
            {/* Decorative flourish on car */}
            <path
              d="M115 65 Q125 63 135 65"
              stroke="#f194b2"
              strokeWidth="1"
              fill="none"
              strokeLinecap="round"
            />
          </svg>
        </div>

        {/* Brand text */}
        <div className="space-y-4">
          <h1 className="font-serif tracking-widest" style={{ fontSize: '52px', lineHeight: '1.1', color: '#285301' }}>
            UDO
          </h1>
          <div className="space-y-3">
            <p className="text-[#285301] tracking-wide" style={{ fontSize: '17px', fontWeight: '500' }}>
              Udo means peace.
            </p>
            <p className="text-gray-700 leading-relaxed px-2" style={{ fontSize: '15px' }}>
              And that is exactly how your wedding should feel.
              <br />
              <span className="text-[#d45d78]">Beautifully guided. Gently held. Peacefully planned.</span>
            </p>
          </div>
        </div>

        {/* CTA */}
        <div className="pt-8">
          <button
            onClick={onBegin}
            className="w-full py-4 bg-[#d45d78] text-white rounded-2xl hover:bg-[#c04968] transition-all transform hover:scale-[1.02] shadow-sm"
            style={{ fontSize: '16px', fontWeight: '500' }}
          >
            Begin your journey
          </button>
        </div>

        {/* Optional footer */}
        <p className="text-xs text-gray-500 pt-4">
          Thoughtfully designed for modern weddings.
        </p>
      </div>
    </div>
  );
};
