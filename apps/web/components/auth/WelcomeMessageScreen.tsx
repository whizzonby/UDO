import React from 'react';

interface WelcomeMessageScreenProps {
  onBegin: () => void;
}

export function WelcomeMessageScreen({ onBegin }: WelcomeMessageScreenProps) {
  return (
    <div className="min-h-screen bg-[#f8edeb] flex items-center justify-center p-6">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-3xl shadow-lg p-8 space-y-6 animate-fade-in">
          {/* Decorative element */}
          <div className="flex justify-center mb-2">
            <div className="w-16 h-16 bg-[#f8edeb] rounded-full flex items-center justify-center">
              <svg className="w-8 h-8 text-[#d45d78]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                />
              </svg>
            </div>
          </div>

          <div className="text-center space-y-4">
            <h1 className="text-3xl font-serif text-[#285301]" style={{ fontFamily: 'Playfair Display, serif' }}>
              Welcome to UDO
            </h1>

            <div className="space-y-4 text-gray-700">
              <p className="text-base leading-relaxed">
                <span className="text-[#285301] font-medium">Udo</span> means <span className="italic">peace</span> in the Igbo
                language.
              </p>

              <p className="text-base leading-relaxed">
                And that is exactly what we want this experience to be for you — <span className="text-[#285301]">peaceful</span>,{' '}
                <span className="text-[#285301]">thoughtful</span>, and{' '}
                <span className="text-[#285301]">beautifully personal</span>.
              </p>

              <div className="bg-[#f8edeb] rounded-2xl p-5 mt-6 border border-[#f194b2]">
                <p className="text-sm leading-relaxed text-gray-700">
                  We are going to ask you a few questions to understand your vision, your style, and what matters most to you.
                </p>
                <p className="text-sm leading-relaxed text-gray-700 mt-3">
                  There is no rush. Take your time. We are here to hold space for you as you bring this celebration to life.
                </p>
              </div>

              <p className="text-sm text-[#d45d78] italic mt-6">You are seen. You are supported. Let us begin.</p>
            </div>
          </div>

          <button
            onClick={onBegin}
            className="w-full bg-[#285301] text-white py-4 rounded-xl font-medium hover:bg-[#1f4001] transition-all mt-8"
          >
            Begin planning
          </button>
        </div>
      </div>
    </div>
  );
}
