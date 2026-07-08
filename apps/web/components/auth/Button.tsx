import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  onClick?: () => void;
  fullWidth?: boolean;
  type?: 'button' | 'submit';
}

export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  onClick,
  fullWidth = false,
  type = 'button'
}) => {
  const baseStyles = "py-4 px-8 rounded-2xl transition-all duration-200 cursor-pointer";

  const variantStyles = {
    primary: "bg-[#5C3A47] text-white hover:bg-[#4a2e39]",
    secondary: "bg-white border border-[#EAEAEA] text-[#5C3A47] hover:bg-gray-50"
  };

  return (
    <button
      type={type}
      onClick={onClick}
      className={`${baseStyles} ${variantStyles[variant]} ${fullWidth ? 'w-full' : ''}`}
    >
      {children}
    </button>
  );
};
