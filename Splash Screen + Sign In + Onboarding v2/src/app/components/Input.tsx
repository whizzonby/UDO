import React from 'react';

interface InputProps {
  label?: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  type?: string;
}

export const Input: React.FC<InputProps> = ({
  label,
  value,
  onChange,
  placeholder,
  type = 'text'
}) => {
  return (
    <div className="flex flex-col gap-2">
      {label && <label className="text-sm text-gray-700">{label}</label>}
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="px-4 py-3 bg-white border border-[#EAEAEA] rounded-xl focus:outline-none focus:border-[#5C3A47] transition-colors"
      />
    </div>
  );
};
