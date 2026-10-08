/**
 * Design tokens for the editorial landing page ("Modern Romance Meets
 * Thoughtful Technology"). Colours match the Udo app (forest green + rose +
 * champagne on warm ivory). No gradients anywhere.
 *
 * Contrast (WCAG AA, measured against ivory unless noted):
 *   forest 11.1 · charcoal 13.7 · body 7.8 · roseDeep 5.0 · champagneDeep 5.5 (5.0 on cream)
 *   On forest: ivory 11.1 · blush 8.1 · champagne 5.3
 *   rose (3.1) and sage are decorative / large-display only — never body text.
 */
export const color = {
  ivory: '#F8F6F1',
  cream: '#F0EBE3',
  blush: '#EBCDD0',
  rose: '#B77C86',
  roseDeep: '#94586A',
  forest: '#243B35',
  forestSoft: '#2E4A42',
  sage: '#A5AD98',
  champagne: '#C7A77B',
  champagneDeep: '#7E5F30',
  charcoal: '#252925',
  body: '#4A4F49',
  white: '#FFFFFF',
  line: '#E2DBD0',
  lineOnForest: '#3E5750',
} as const;

/** Content widths. */
export const container = 'mx-auto w-full max-w-[1240px] px-5 sm:px-8 lg:px-12';
export const narrow = 'mx-auto w-full max-w-[760px] px-5 sm:px-8';

/** Motion timings — calm, editorial, never bouncy. */
export const ease = [0.22, 1, 0.36, 1] as const;
export const duration = { fast: 0.35, base: 0.7, slow: 1.1 } as const;
