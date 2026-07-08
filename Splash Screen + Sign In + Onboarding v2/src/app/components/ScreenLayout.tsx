import React from 'react';
import { ChevronLeft } from 'lucide-react';

interface ScreenLayoutProps {
  title: string;
  preamble?: string;
  quoteNugget?: string;
  children: React.ReactNode;
  onBack?: () => void;
  onNext?: () => void;
  onSkip?: () => void;
  showBack?: boolean;
  showNext?: boolean;
  showSkip?: boolean;
  nextLabel?: string;
  currentStep?: number;
  totalSteps?: number;
}

export const ScreenLayout: React.FC<ScreenLayoutProps> = ({
  title,
  preamble,
  quoteNugget,
  children,
  onBack,
  onNext,
  onSkip,
  showBack = true,
  showNext = true,
  showSkip = false,
  nextLabel = 'Next',
  currentStep,
  totalSteps = 15
}) => {
  return (
    <div className="min-h-screen bg-white flex flex-col">
      {/* Header */}
      <div className="px-6 pt-12 pb-4">
        <div className="flex items-center justify-between mb-6">
          {showBack ? (
            <button
              onClick={onBack}
              className="text-gray-600 hover:text-[#d45d78] transition-colors"
            >
              <ChevronLeft size={28} />
            </button>
          ) : (
            <div className="w-7" />
          )}

          {showSkip && (
            <button
              onClick={onSkip}
              className="text-gray-500 hover:text-[#d45d78] transition-colors text-sm"
            >
              Skip
            </button>
          )}
        </div>

        {/* Progress bar */}
        {currentStep && (
          <div className="mb-8">
            <div className="h-1 bg-[#f8edeb] rounded-full overflow-hidden">
              <div
                className="h-full bg-[#d45d78] transition-all duration-300"
                style={{ width: `${(currentStep / totalSteps) * 100}%` }}
              />
            </div>
          </div>
        )}

        <h1 className="font-serif tracking-wide text-[#285301] mb-3" style={{ fontSize: '28px', lineHeight: '1.3' }}>
          {title}
        </h1>

        {preamble && (
          <p className="text-gray-600 leading-relaxed mb-4" style={{ fontSize: '15px' }}>
            {preamble}
          </p>
        )}

        {quoteNugget && (
          <div className="bg-[#f8edeb] rounded-xl px-4 py-3 mb-4 border-l-2 border-[#f194b2]">
            <p className="text-sm text-[#285301] italic">
              {quoteNugget}
            </p>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="flex-1 px-6 pb-6 overflow-y-auto">
        {children}
      </div>

      {/* Footer */}
      {showNext && (
        <div className="px-6 pb-8 pt-4 bg-white border-t border-gray-100">
          <button
            onClick={onNext}
            className="w-full py-4 bg-[#d45d78] text-white rounded-2xl hover:bg-[#c04968] transition-all shadow-sm"
            style={{ fontSize: '16px', fontWeight: '500' }}
          >
            {nextLabel}
          </button>
        </div>
      )}
    </div>
  );
};
