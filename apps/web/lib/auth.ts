'use client';

const TOKEN_KEY = 'udo_token';
const USER_KEY = 'udo_user';

export type AuthUser = {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  avatar_url?: string;
  wedding_id?: number;
  wedding_role?: string | null;
  wedding_permissions?: string[];
  is_wedding_owner?: boolean;
  notification_preferences?: {
    rsvp_updates: boolean;
    task_reminders: boolean;
    guest_messages: boolean;
    live_mode: boolean;
    vendor_updates: boolean;
  };
  support_preferences?: {
    email_support: boolean;
    chat_support: boolean;
    proactive_checkins: boolean;
    response_time: 'within-1h' | 'within-24h' | 'within-3d';
  };
  subscription?: {
    plan: string;
    label: string;
    status: string;
    billing_cycle: string;
    current_period_end?: string | null;
    limits: Record<string, number | null>;
    usage: Record<string, number>;
  } | null;
  onboarding_completed?: boolean;
  roles?: string[];
  is_admin?: boolean;
};

export function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(TOKEN_KEY);
}

export function getUser(): AuthUser | null {
  if (typeof window === 'undefined') return null;
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as AuthUser;
  } catch {
    return null;
  }
}

export function setAuth(token: string, user: AuthUser): void {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearAuth(): void {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function isAuthenticated(): boolean {
  return !!getToken();
}
