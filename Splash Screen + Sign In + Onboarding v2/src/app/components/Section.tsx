import React from 'react';

interface SectionProps {
  title: string;
  helper?: string;
  children: React.ReactNode;
}

export const Section: React.FC<SectionProps> = ({ title, helper, children }) => {
  return (
    <div className="mb-8">
      <div className="mb-4">
        <h3 className="text-sm text-[#285301] mb-1.5" style={{ fontWeight: '500' }}>
          {title}
        </h3>
        {helper && (
          <p className="text-xs text-gray-500 leading-relaxed">
            {helper}
          </p>
        )}
      </div>
      {children}
    </div>
  );
};
