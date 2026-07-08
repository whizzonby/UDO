import React from 'react';
import { Info } from 'lucide-react';

interface ToggleProps {
  label: string;
  description?: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
  showInfo?: boolean;
  onInfoClick?: () => void;
}

export const Toggle: React.FC<ToggleProps> = ({
  label,
  description,
  checked,
  onChange,
  showInfo,
  onInfoClick
}) => {
  return (
    <div className="flex items-center justify-between py-4 border-b border-gray-100">
      <div className="flex items-center gap-2 flex-1">
        <span className="text-gray-900">{label}</span>
        {showInfo && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              onInfoClick?.();
            }}
            className="text-gray-400 hover:text-gray-600"
          >
            <Info size={16} />
          </button>
        )}
      </div>
      {description && <span className="text-sm text-gray-500 mr-4">{description}</span>}
      <button
        onClick={() => onChange(!checked)}
        className={`w-12 h-6 rounded-full transition-colors duration-200 relative ${
          checked ? 'bg-[#5C3A47]' : 'bg-gray-300'
        }`}
      >
        <div
          className={`absolute top-0.5 w-5 h-5 bg-white rounded-full transition-transform duration-200 ${
            checked ? 'translate-x-6' : 'translate-x-0.5'
          }`}
        />
      </button>
    </div>
  );
};
