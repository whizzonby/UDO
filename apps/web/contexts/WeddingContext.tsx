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

type DashboardResponse = {
  wedding: WeddingData | null;
  stats: WeddingStats;
  upcoming_tasks: UpcomingTask[];
};

type WeddingContextType = {
  wedding: WeddingData | null;
  stats: WeddingStats | null;
  upcomingTasks: UpcomingTask[];
  loading: boolean;
  refresh: () => Promise<void>;
};

const WeddingContext = createContext<WeddingContextType>({
  wedding: null,
  stats: null,
  upcomingTasks: [],
  loading: true,
  refresh: async () => {},
});

export function WeddingProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [wedding, setWedding] = useState<WeddingData | null>(null);
  const [stats, setStats] = useState<WeddingStats | null>(null);
  const [upcomingTasks, setUpcomingTasks] = useState<UpcomingTask[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchDashboard = async () => {
    const token = getToken();
    if (!token) { setLoading(false); return; }
    try {
      const data = await api.get<DashboardResponse>('/dashboard', token);
      setWedding(data.wedding ?? null);
      setStats(data.stats ?? null);
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
    <WeddingContext.Provider value={{ wedding, stats, upcomingTasks, loading, refresh: fetchDashboard }}>
      {children}
    </WeddingContext.Provider>
  );
}

export function useWedding() {
  return useContext(WeddingContext);
}
