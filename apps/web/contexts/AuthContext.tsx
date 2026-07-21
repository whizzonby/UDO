'use client';

import React, { createContext, useContext, useEffect, useState } from 'react';
import { AuthUser, clearAuth, getToken, getUser, setAuth } from '@/lib/auth';
import { api } from '@/lib/api';

type AuthContextType = {
  user: AuthUser | null;
  token: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  refresh: () => Promise<void>;
  switchWedding: (weddingId: number) => Promise<void>;
  updateProfile: (profile: { first_name: string; last_name?: string; email: string; avatar_url?: string | null }) => Promise<void>;
  updatePreferences: (preferences: {
    notification_preferences?: AuthUser['notification_preferences'];
    support_preferences?: AuthUser['support_preferences'];
  }) => Promise<void>;
};

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const storedToken = getToken();
    const storedUser = getUser();
    if (storedToken && storedUser) {
      setToken(storedToken);
      setUser(storedUser);
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    const res = await api.post<{ token: string; user: AuthUser }>('/auth/login', { email, password });
    setAuth(res.token, res.user);
    setToken(res.token);
    setUser(res.user);
  };

  const logout = () => {
    clearAuth();
    setToken(null);
    setUser(null);
  };

  const refresh = async () => {
    if (!token) return;
    const res = await api.get<AuthUser | { user: AuthUser }>('/auth/me', token);
    const nextUser = 'user' in res ? res.user : res;
    setUser(nextUser);
    const stored = getToken();
    if (stored) setAuth(stored, nextUser);
  };

  const switchWedding = async (weddingId: number) => {
    if (!token) return;
    await api.post('/weddings/switch', { wedding_id: weddingId }, token);
    await refresh();
  };

  const updateProfile = async (profile: { first_name: string; last_name?: string; email: string; avatar_url?: string | null }) => {
    if (!token) return;
    const nextUser = await api.patch<AuthUser>('/auth/me', profile, token);
    setUser(nextUser);
    const stored = getToken();
    if (stored) setAuth(stored, nextUser);
  };

  const updatePreferences = async (preferences: {
    notification_preferences?: AuthUser['notification_preferences'];
    support_preferences?: AuthUser['support_preferences'];
  }) => {
    if (!token) return;
    const nextUser = await api.patch<AuthUser>('/auth/preferences', preferences, token);
    setUser(nextUser);
    const stored = getToken();
    if (stored) setAuth(stored, nextUser);
  };

  return (
    <AuthContext.Provider value={{ user, token, isLoading, login, logout, refresh, switchWedding, updateProfile, updatePreferences }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
