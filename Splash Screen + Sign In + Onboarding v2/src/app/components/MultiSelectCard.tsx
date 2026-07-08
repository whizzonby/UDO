import React from 'react';

interface MultiSelectCardProps {
  options: string[];
  selected: string[];
  onChange: (selected: string[]) => void;
  maxSelections?: number;
}

export const MultiSelectCard: React.FC<MultiSelectCardProps> = ({
  options,
  selected,
  onChange,
  maxSelections
}) => {
  const handleToggle = (option: string) => {
    if (selected.includes(option)) {
      onChange(selected.filter(item => item !== option));
    } else {
      if (!maxSelections || selected.length < maxSelections) {
        onChange([...selected, option]);
      }
    }
  };

  return (
    <div className="space-y-3">
      {options.map((option) => {
        const isSelected = selected.includes(option);
        const isDisabled = !isSelected && maxSelections && selected.length >= maxSelections;

        return (
          <button
            key={option}
            onClick={() => handleToggle(option)}
            disabled={isDisabled}
            className={`w-full p-4 rounded-xl border-2 transition-all text-left ${
              isSelected
                ? 'bg-[#f8edeb] border-[#d45d78] shadow-sm'
                : isDisabled
                ? 'bg-gray-50 border-gray-200 opacity-50 cursor-not-allowed'
                : 'bg-white border-[#EAEAEA] hover:border-[#f194b2]'
            }`}
          >
            <div className="flex items-center justify-between">
              <span className={isSelected ? 'text-[#285301]' : 'text-gray-700'}>{option}</span>
              {isSelected && (
                <div className="w-5 h-5 rounded-full bg-[#d45d78] flex items-center justify-center flex-shrink-0">
                  <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                    <path
                      d="M2 6L5 9L10 3"
                      stroke="white"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </div>
              )}
            </div>
          </button>
        );
      })}
    </div>
  );
};
