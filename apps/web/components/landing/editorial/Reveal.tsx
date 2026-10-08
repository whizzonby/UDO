'use client';

import { motion, useReducedMotion } from 'motion/react';
import type { ReactNode } from 'react';
import { duration, ease } from './tokens';

/**
 * Gentle fade-and-rise as content enters the viewport. Plays once, and
 * renders statically for visitors who prefer reduced motion.
 */
export function Reveal({
  children,
  delay = 0,
  y = 24,
  className,
  as = 'div',
}: {
  children: ReactNode;
  delay?: number;
  y?: number;
  className?: string;
  as?: 'div' | 'li' | 'section' | 'figure';
}) {
  const reduce = useReducedMotion();
  const Tag = motion[as];

  if (reduce) {
    const Static = as;
    return <Static className={className}>{children}</Static>;
  }

  return (
    <Tag
      className={className}
      initial={{ opacity: 0, y }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: '0px 0px -12% 0px' }}
      transition={{ duration: duration.base, ease, delay }}
    >
      {children}
    </Tag>
  );
}

/** Photograph that eases from a slight zoom to rest when revealed. */
export function ImageReveal({ children, className }: { children: ReactNode; className?: string }) {
  const reduce = useReducedMotion();
  if (reduce) return <div className={className}>{children}</div>;

  return (
    <motion.div
      className={className}
      initial={{ opacity: 0, scale: 1.04 }}
      whileInView={{ opacity: 1, scale: 1 }}
      viewport={{ once: true, margin: '0px 0px -10% 0px' }}
      transition={{ duration: duration.slow, ease }}
    >
      {children}
    </motion.div>
  );
}
