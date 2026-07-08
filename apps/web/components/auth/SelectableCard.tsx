import React from 'react';
import { Check } from 'lucide-react';

interface SelectableCardProps {
  children: React.ReactNode;
  selected: boolean;
  onClick: () => void;
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg';
  showCheck?: boolean;
}

export const SelectableCard: React.FC<SelectableCardProps> = ({
  children,
  selected,
  onClick,
  disabled = false,
  size = 'md',
  showCheck = true
}) => {
  const sizeClasses = {
    sm: 'p-3',
    md: 'p-5',
    lg: 'p-6'
  };

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`w-full ${sizeClasses[size]} rounded-2xl cursor-pointer transition-all duration-200 border-2 text-left relative ${
        selected
          ? 'bg-[#f8edeb] border-[#d45d78] shadow-sm'
          : 'bg-white border-[#EAEAEA] hover:border-[#f194b2]'
      } ${disabled ? 'opacity-50 cursor-not-allowed' : ''}`}
    >
      {selected && showCheck && (
        <div className="absolute top-3 right-3">
          <div className="w-5 h-5 rounded-full bg-[#d45d78] flex items-center justify-center">
            <Check size={14} className="text-white" />
          </div>
        </div>
      )}
      {children}
    </button>
  );
};
