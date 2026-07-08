import React from 'react';
import { ScreenLayout } from '../ScreenLayout';
import { SelectableCard } from '../SelectableCard';

interface Screen1Props {
  onNext: () => void;
  onSkip: () => void;
  role: string;
  setRole: (role: string) => void;
  decisionMaking: string;
  setDecisionMaking: (decision: string) => void;
}

export const Screen1: React.FC<Screen1Props> = ({
  onNext,
  onSkip,
  role,
  setRole,
  decisionMaking,
  setDecisionMaking
}) => {
  const roles = [
    'This is my wedding',
    'We are planning together (couple-led)',
    'I am supporting the planning (family/friend)',
    'I am the wedding planner',
    'I am part of a planning team'
  ];

  const showDecisionMaking = role === 'This is my wedding' || role === 'We are planning together (couple-led)';

  return (
    <ScreenLayout
      title="Tell us about your role in this wedding"
      onNext={onNext}
      onSkip={onSkip}
      showBack={false}
      showSkip={true}
      currentStep={1}
    >
      <div className="space-y-6 mt-6">
        <div className="space-y-3">
          {roles.map((roleOption) => (
            <SelectableCard
              key={roleOption}
              selected={role === roleOption}
              onClick={() => setRole(roleOption)}
            >
              <div className="pr-8">{roleOption}</div>
            </SelectableCard>
          ))}
        </div>

        {showDecisionMaking && (
          <div className="pt-4 animate-fade-in">
            <label className="text-sm text-gray-600 mb-3 block">
              Who is involved in decision-making?
            </label>
            <div className="space-y-3">
              <SelectableCard
                selected={decisionMaking === 'one-leads'}
                onClick={() => setDecisionMaking('one-leads')}
                size="sm"
              >
                <div className="pr-8">One person leads</div>
              </SelectableCard>
              <SelectableCard
                selected={decisionMaking === 'shared'}
                onClick={() => setDecisionMaking('shared')}
                size="sm"
              >
                <div className="pr-8">Shared decisions</div>
              </SelectableCard>
              <SelectableCard
                selected={decisionMaking === 'family-influenced'}
                onClick={() => setDecisionMaking('family-influenced')}
                size="sm"
              >
                <div className="pr-8">Family-influenced decisions</div>
              </SelectableCard>
            </div>
          </div>
        )}

        {(role === 'I am the wedding planner' || role === 'I am part of a planning team') && (
          <div className="pt-4 animate-fade-in">
            <button className="w-full py-3 bg-white border-2 border-[#5C3A47] text-[#5C3A47] rounded-xl hover:bg-[#FAF5F6] transition-colors">
              Invite couple via link
            </button>
            <p className="text-xs text-gray-500 mt-2 text-center">
              Define permissions (view/edit/approve)
            </p>
          </div>
        )}
      </div>
    </ScreenLayout>
  );
};
