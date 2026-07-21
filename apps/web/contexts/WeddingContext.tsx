'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { api } from '@/lib/api';
import { getToken } from '@/lib/auth';
import { useAuth } from './AuthContext';

export type WeddingData = {
  id: number;
  slug: string;
  couple_names: string;
  event_date: string | null;
  venue_name: string | null;
  venue_city: string | null;
  days_until: number | null;
  status: string;
};

export type WeddingStats = {
  total_guests: number;
  confirmed_guests: number;
  declined_guests: number;
  pending_guests: number;
  total_tasks: number;
  completed_tasks: number;
  pending_tasks: number;
  budget_spent: number;
  budget_total: number;
};

export type UpcomingTask = {
  id: number;
  title: string;
  due_date: string;
  priority: string;
};

export type CommandCenterAction = {
  id: string;
  title: string;
  reason: string;
  priority: string;
  target: string;
};

export type SmartAlert = {
  id: number;
  key: string;
  alert_type: string;
  severity: string;
  status: string;
  target: string | null;
  title: string;
  body: string | null;
  action_label: string | null;
  action_url: string | null;
  trigger_at: string | null;
  metadata: Record<string, unknown>;
};

export type CommandCenter = {
  planning_health: { score: number; label: string; task_completion: number; days_until: number | null };
  rsvp_health: { completion: number; pending: number; confirmed: number; declined: number; deadline: string | null };
  budget_status: { usage: number; spent: number; total: number; remaining: number; unpaid_balance: number; due_soon: unknown[] };
  guest_issues: Record<string, number>;
  live_readiness: {
    score: number;
    label: string;
    open_incidents: number;
    timeline_items: number;
    vendor_readiness: { confirmed: number; total: number; missing_contracts: number };
  };
  upcoming_actions: CommandCenterAction[];
  smart_alerts?: {
    total_active: number;
    critical: number;
    high: number;
    next_alert: Pick<SmartAlert, 'id' | 'key' | 'title' | 'severity' | 'target' | 'trigger_at'> | null;
    alerts: SmartAlert[];
  };
  platform_health?: {
    status: string;
    score: number;
    checked_at: string;
    queue: {
      connection: string;
      failed_jobs: number;
      pending_deliveries: number;
      failed_deliveries: number;
      stale_sending_messages: number;
    };
    tokens: {
      expired_active: number;
      expiring_soon: number;
    };
    cache: {
      driver: string;
      ttl_seconds: number;
    };
  };
};

type DashboardResponse = {
  wedding: WeddingData | null;
  stats: WeddingStats;
  command_center?: CommandCenter;
  upcoming_tasks: UpcomingTask[];
};

type WeddingContextType = {
  wedding: WeddingData | null;
  stats: WeddingStats | null;
  commandCenter: CommandCenter | null;
  upcomingTasks: UpcomingTask[];
  loading: boolean;
  refresh: () => Promise<void>;
};

const WeddingContext = createContext<WeddingContextType>({
  wedding: null,
  stats: null,
  commandCenter: null,
  upcomingTasks: [],
  loading: true,
  refresh: async () => {},
});

export function WeddingProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [wedding, setWedding] = useState<WeddingData | null>(null);
  const [stats, setStats] = useState<WeddingStats | null>(null);
  const [commandCenter, setCommandCenter] = useState<CommandCenter | null>(null);
  const [upcomingTasks, setUpcomingTasks] = useState<UpcomingTask[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchDashboard = async () => {
    const token = getToken();
    if (!token) { setLoading(false); return; }
    try {
      const data = await api.get<DashboardResponse>('/dashboard', token);
      setWedding(data.wedding ?? null);
      setStats(data.stats ?? null);
      setCommandCenter(data.command_center ?? null);
      setUpcomingTasks(data.upcoming_tasks ?? []);
    } catch {
      // silently fail — user may not have a wedding yet
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (user) fetchDashboard();
    else setLoading(false);
  }, [user]);

  return (
    <WeddingContext.Provider value={{ wedding, stats, commandCenter, upcomingTasks, loading, refresh: fetchDashboard }}>
      {children}
    </WeddingContext.Provider>
  );
}

export function useWedding() {
  return useContext(WeddingContext);
}
