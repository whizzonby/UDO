import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { format, parseISO, differenceInDays } from 'date-fns';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(dateStr: string | null, fmt = 'MMMM d, yyyy'): string {
  if (!dateStr) return '';
  try {
    return format(parseISO(dateStr), fmt);
  } catch {
    return dateStr;
  }
}

export function formatTime(timeStr: string | null): string {
  if (!timeStr) return '';
  // timeStr is HH:mm:ss from Laravel
  try {
    const [h, m] = timeStr.split(':').map(Number);
    const date = new Date();
    date.setHours(h!, m!, 0);
    return format(date, 'h:mm a');
  } catch {
    return timeStr;
  }
}

export function daysUntil(dateStr: string | null): number | null {
  if (!dateStr) return null;
  try {
    return differenceInDays(parseISO(dateStr), new Date());
  } catch {
    return null;
  }
}

export function coupleNames(partnerOne: string, partnerTwo: string | null): string {
  return partnerTwo ? `${partnerOne} & ${partnerTwo}` : partnerOne;
}

export function formatCurrency(amount: number | null, currency = 'USD'): string {
  if (amount == null) return '';
  return new Intl.NumberFormat('en-US', { style: 'currency', currency, maximumFractionDigits: 0 }).format(amount);
}

export function rsvpLabel(status: string): string {
  return { attending: 'Attending', declined: 'Declined', maybe: 'Maybe', pending: 'Pending' }[status] ?? status;
}
