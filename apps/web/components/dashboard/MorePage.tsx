'use client';

import { useEffect, useMemo, useState } from 'react';
import { Activity, Bell, CalendarDays, CheckCircle2, ChevronRight, CreditCard, Gift, HelpCircle, LogOut, Mail, Shield, Settings, User, Users } from 'lucide-react';
import { api } from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';

interface MorePageProps {
  onNavigate?: (tab: 'registry') => void;
}

type Entitlements = {
  plan: string;
  label: string;
  status: string;
  billing_cycle: string;
  description?: string;
  features?: string[];
  prices?: { monthly: number; annual: number };
  available_plans?: PlanOption[];
  limits: Record<string, number | null>;
  usage: Record<string, number>;
};

type PlanOption = {
  plan: string;
  label: string;
  description: string;
  monthly_price: number;
  annual_price: number;
  features: string[];
  limits: Record<string, number | null>;
  recommended: boolean;
  current: boolean;
  can_change: boolean;
};

type TeamMember = {
  id: number | null;
  user_id: number;
  name: string;
  email: string;
  role: string;
  permissions: string[];
  is_owner: boolean;
};

type RoleOption = {
  role: string;
  permissions: string[];
};

type AuditLog = {
  id: number;
  action: string;
  created_at: string;
  user?: {
    first_name?: string;
    last_name?: string;
    email?: string;
  } | null;
};

type WeddingOption = {
  id: number;
  title?: string | null;
  couple_name_primary?: string | null;
  couple_name_secondary?: string | null;
  event_date?: string | null;
  city?: string | null;
  country?: string | null;
  primary_venue_name?: string | null;
  primary_venue_address?: string | null;
  rsvp_deadline?: string | null;
  is_active: boolean;
  access?: {
    role?: string | null;
    is_owner?: boolean;
  };
};

type WeddingSettingsForm = {
  title: string;
  couple_name_primary: string;
  couple_name_secondary: string;
  event_date: string;
  city: string;
  country: string;
  primary_venue_name: string;
  primary_venue_address: string;
  rsvp_deadline: string;
};

type ProfileForm = {
  first_name: string;
  last_name: string;
  email: string;
  avatar_url: string;
};

type NotificationPreferences = {
  rsvp_updates: boolean;
  task_reminders: boolean;
  guest_messages: boolean;
  live_mode: boolean;
  vendor_updates: boolean;
};

type SupportPreferences = {
  email_support: boolean;
  chat_support: boolean;
  proactive_checkins: boolean;
  response_time: 'within-1h' | 'within-24h' | 'within-3d';
};

type Panel = 'profile' | 'notifications' | 'support' | 'subscription' | 'team' | 'activity' | 'weddings' | 'settings' | 'ops' | null;

type InternalOpsData = {
  summary: { users: number; weddings: number; active_paid_subscriptions: number };
  health: {
    status: string;
    score: number;
    queue: { failed_jobs: number; pending_deliveries: number; failed_deliveries: number; stale_sending_messages: number };
  };
  users: { id: number; name: string; email: string; plan: string; subscription_status: string; active_wedding_id: number | null }[];
  weddings: { id: number; title: string; owner_email?: string | null; guests_count: number; messages_count: number; audit_logs_count: number }[];
  delivery_diagnostics: { id: number; status: string; channel: string; message_subject?: string | null; guest_email?: string | null; error_message?: string | null }[];
  plans: string[];
};

const formatLabel = (value: string) => value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase());

const weddingTitle = (wedding: WeddingOption) => {
  if (wedding.title) return wedding.title;
  const names = [wedding.couple_name_primary, wedding.couple_name_secondary].filter(Boolean).join(' & ');
  return names || 'Untitled wedding';
};

const weddingMeta = (wedding: WeddingOption) => {
  const parts = [wedding.event_date ? new Date(wedding.event_date).toLocaleDateString() : null, wedding.city, wedding.country].filter(Boolean);
  return parts.join(' - ') || 'Wedding workspace';
};

const emptyWeddingSettings: WeddingSettingsForm = {
  title: '',
  couple_name_primary: '',
  couple_name_secondary: '',
  event_date: '',
  city: '',
  country: '',
  primary_venue_name: '',
  primary_venue_address: '',
  rsvp_deadline: '',
};

const dateInputValue = (value?: string | null) => value ? value.slice(0, 10) : '';

const weddingToForm = (wedding: WeddingOption): WeddingSettingsForm => ({
  title: wedding.title ?? '',
  couple_name_primary: wedding.couple_name_primary ?? '',
  couple_name_secondary: wedding.couple_name_secondary ?? '',
  event_date: dateInputValue(wedding.event_date),
  city: wedding.city ?? '',
  country: wedding.country ?? '',
  primary_venue_name: wedding.primary_venue_name ?? '',
  primary_venue_address: wedding.primary_venue_address ?? '',
  rsvp_deadline: dateInputValue(wedding.rsvp_deadline),
});

const defaultNotificationPreferences = (): NotificationPreferences => ({
  rsvp_updates: true,
  task_reminders: true,
  guest_messages: true,
  live_mode: true,
  vendor_updates: false,
});

const defaultSupportPreferences = (): SupportPreferences => ({
  email_support: true,
  chat_support: false,
  proactive_checkins: true,
  response_time: 'within-24h',
});

export default function MorePage({ onNavigate }: MorePageProps) {
  const { user, token, logout, refresh, switchWedding, updateProfile, updatePreferences } = useAuth();
  const [activePanel, setActivePanel] = useState<Panel>(null);
  const [profile, setProfile] = useState<ProfileForm>({
    first_name: user?.first_name ?? '',
    last_name: user?.last_name ?? '',
    email: user?.email ?? '',
    avatar_url: user?.avatar_url ?? '',
  });
  const [notificationPrefs, setNotificationPrefs] = useState<NotificationPreferences>({
    ...defaultNotificationPreferences(),
    ...user?.notification_preferences,
  });
  const [supportPrefs, setSupportPrefs] = useState<SupportPreferences>({
    ...defaultSupportPreferences(),
    ...user?.support_preferences,
  });
  const [entitlements, setEntitlements] = useState<Entitlements | null>(user?.subscription ?? null);
  const [planCatalog, setPlanCatalog] = useState<PlanOption[]>([]);
  const [billingCycle, setBillingCycle] = useState<'monthly' | 'annual'>('monthly');
  const [changingPlan, setChangingPlan] = useState<string | null>(null);
  const [weddings, setWeddings] = useState<WeddingOption[]>([]);
  const [weddingSettings, setWeddingSettings] = useState<WeddingSettingsForm>(emptyWeddingSettings);
  const [team, setTeam] = useState<TeamMember[]>([]);
  const [roles, setRoles] = useState<RoleOption[]>([]);
  const [auditLogs, setAuditLogs] = useState<AuditLog[]>([]);
  const [isLoadingOps, setIsLoadingOps] = useState(false);
  const [opsError, setOpsError] = useState<string | null>(null);
  const [switchingWeddingId, setSwitchingWeddingId] = useState<number | null>(null);
  const [newWedding, setNewWedding] = useState({
    title: '',
    couple_name_primary: '',
    couple_name_secondary: '',
    event_date: '',
    city: '',
    country: '',
  });
  const [isCreatingWedding, setIsCreatingWedding] = useState(false);
  const [isSavingWedding, setIsSavingWedding] = useState(false);
  const [isSavingProfile, setIsSavingProfile] = useState(false);
  const [isSavingPreferences, setIsSavingPreferences] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteRole, setInviteRole] = useState('viewer');
  const [isInviting, setIsInviting] = useState(false);
  const [opsSearch, setOpsSearch] = useState('');
  const [opsData, setOpsData] = useState<InternalOpsData | null>(null);
  const [opsOverride, setOpsOverride] = useState<Record<number, { plan: string; status: string; note: string }>>({});
  const [opsSavingUserId, setOpsSavingUserId] = useState<number | null>(null);

  const canManageTeam = user?.wedding_permissions?.includes('manage_team') || user?.is_wedding_owner;
  const canViewReports = user?.wedding_permissions?.includes('view_reports') || user?.is_wedding_owner;
  const canManageWedding = user?.wedding_permissions?.includes('manage_wedding') || user?.is_wedding_owner;
  const canUseInternalOps = !!user?.is_admin;

  useEffect(() => {
    setProfile({
      first_name: user?.first_name ?? '',
      last_name: user?.last_name ?? '',
      email: user?.email ?? '',
      avatar_url: user?.avatar_url ?? '',
    });
    setNotificationPrefs({ ...defaultNotificationPreferences(), ...user?.notification_preferences });
    setSupportPrefs({ ...defaultSupportPreferences(), ...user?.support_preferences });
  }, [user]);

  useEffect(() => {
    if (!token) return;

    let mounted = true;
    setIsLoadingOps(true);
    setOpsError(null);

    Promise.all([
      api.get<{ data: Entitlements }>('/billing/entitlements', token),
      api.get<{ data: PlanOption[] }>('/billing/plans', token),
      api.get<{ data: WeddingOption[] }>('/weddings', token),
      api.get<WeddingOption>('/wedding', token).catch(() => null),
      canManageTeam ? api.get<{ data: TeamMember[]; roles: RoleOption[] }>('/wedding/team', token) : Promise.resolve(null),
      canViewReports ? api.get<{ data: AuditLog[] }>('/audit-logs?limit=8', token) : Promise.resolve(null),
    ])
      .then(([billingRes, plansRes, weddingsRes, weddingRes, teamRes, auditRes]) => {
        if (!mounted) return;
        setEntitlements(billingRes.data);
        setPlanCatalog(plansRes.data);
        setBillingCycle(billingRes.data.billing_cycle === 'annual' ? 'annual' : 'monthly');
        setWeddings(weddingsRes.data);
        if (weddingRes) setWeddingSettings(weddingToForm(weddingRes));
        if (teamRes) {
          setTeam(teamRes.data);
          setRoles(teamRes.roles);
          setInviteRole(teamRes.roles.find((role) => role.role === 'viewer')?.role ?? teamRes.roles[0]?.role ?? 'viewer');
        }
        if (auditRes) setAuditLogs(auditRes.data);
      })
      .catch((error) => {
        if (mounted) setOpsError(error instanceof Error ? error.message : 'Could not load account details.');
      })
      .finally(() => {
        if (mounted) setIsLoadingOps(false);
      });

    return () => {
      mounted = false;
    };
  }, [token, canManageTeam, canViewReports, user?.wedding_id]);

  useEffect(() => {
    if (!token || !canUseInternalOps) return;
    const query = opsSearch.trim() ? `?q=${encodeURIComponent(opsSearch.trim())}` : '';
    api.get<{ data: InternalOpsData }>(`/internal/ops${query}`, token)
      .then((res) => setOpsData(res.data))
      .catch((error) => setOpsError(error instanceof Error ? error.message : 'Could not load internal operations.'));
  }, [token, canUseInternalOps, opsSearch]);

  const menuItems = [
    { icon: User, title: 'Profile', subtitle: user?.email ?? 'Edit your personal information', panel: 'profile' as const },
    { icon: CalendarDays, title: 'Wedding workspaces', subtitle: weddings.find((wedding) => wedding.is_active) ? weddingTitle(weddings.find((wedding) => wedding.is_active)!) : 'Switch active wedding', panel: 'weddings' as const },
    { icon: Settings, title: 'Wedding settings', subtitle: canManageWedding ? 'Date, location, and event details' : 'Requires wedding management access', panel: 'settings' as const },
    { icon: Gift, title: 'Registry', subtitle: 'Manage your wedding registry', route: 'registry' as const },
    { icon: Users, title: 'Collaborators', subtitle: team.length ? `${team.length} people with access` : 'Share planning access', panel: 'team' as const },
    { icon: Activity, title: 'Activity log', subtitle: canViewReports ? 'Recent team and planning changes' : 'Requires report access', panel: 'activity' as const },
    { icon: Bell, title: 'Notifications', subtitle: 'Manage alerts and reminders', panel: 'notifications' as const },
    { icon: Settings, title: 'Support preferences', subtitle: 'Set your guidance style', panel: 'support' as const },
    { icon: CreditCard, title: 'Subscription / Wedding Pass', subtitle: entitlements ? `${entitlements.label} plan` : 'Manage your plan', panel: 'subscription' as const },
    { icon: Mail, title: 'Feedback / Contact', subtitle: 'We would love to hear from you' },
    { icon: HelpCircle, title: 'Help center', subtitle: 'FAQs and guides' },
    { icon: Shield, title: 'Privacy', subtitle: 'Data and security settings' },
    ...(canUseInternalOps ? [{ icon: Activity, title: 'Internal ops', subtitle: opsData ? `${opsData.health.status} health - ${opsData.delivery_diagnostics.length} delivery checks` : 'Support diagnostics and overrides', panel: 'ops' as const }] : []),
  ];

  const primaryInitial = useMemo(() => {
    const first = user?.first_name?.trim()[0] || user?.email?.trim()[0] || 'U';
    return first.toUpperCase();
  }, [user]);

  async function inviteTeamMember() {
    if (!token || !inviteEmail.trim() || isInviting) return;
    setIsInviting(true);
    setOpsError(null);

    try {
      const res = await api.post<{ data: TeamMember }>('/wedding/team', {
        email: inviteEmail.trim(),
        role: inviteRole,
      }, token);
      setTeam((current) => [...current.filter((member) => member.user_id !== res.data.user_id), res.data]);
      setInviteEmail('');
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not add collaborator.');
    } finally {
      setIsInviting(false);
    }
  }

  async function changeWedding(weddingId: number) {
    if (switchingWeddingId || weddings.find((wedding) => wedding.id === weddingId)?.is_active) return;
    setSwitchingWeddingId(weddingId);
    setOpsError(null);

    try {
      await switchWedding(weddingId);
      setWeddings((current) => current.map((wedding) => ({ ...wedding, is_active: wedding.id === weddingId })));
      const freshWedding = await api.get<WeddingOption>('/wedding', token!);
      setWeddingSettings(weddingToForm(freshWedding));
      setTeam([]);
      setAuditLogs([]);
      setActivePanel(null);
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not switch wedding.');
    } finally {
      setSwitchingWeddingId(null);
    }
  }

  async function createWeddingWorkspace() {
    if (!token || !newWedding.couple_name_primary.trim() || isCreatingWedding) return;
    setIsCreatingWedding(true);
    setOpsError(null);

    try {
      const created = await api.post<WeddingOption>('/weddings', {
        title: newWedding.title.trim() || null,
        couple_name_primary: newWedding.couple_name_primary.trim(),
        couple_name_secondary: newWedding.couple_name_secondary.trim() || null,
        event_date: newWedding.event_date || null,
        city: newWedding.city.trim() || null,
        country: newWedding.country.trim() || null,
      }, token);
      setWeddings((current) => [...current.map((wedding) => ({ ...wedding, is_active: false })), created]);
      setWeddingSettings(weddingToForm(created));
      setTeam([]);
      setAuditLogs([]);
      setNewWedding({ title: '', couple_name_primary: '', couple_name_secondary: '', event_date: '', city: '', country: '' });
      await refresh();
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not create wedding workspace.');
    } finally {
      setIsCreatingWedding(false);
    }
  }

  async function saveWeddingSettings() {
    if (!token || !canManageWedding || isSavingWedding) return;
    setIsSavingWedding(true);
    setOpsError(null);

    try {
      const saved = await api.patch<WeddingOption>('/wedding', {
        title: weddingSettings.title.trim() || null,
        couple_name_primary: weddingSettings.couple_name_primary.trim() || null,
        couple_name_secondary: weddingSettings.couple_name_secondary.trim() || null,
        event_date: weddingSettings.event_date || null,
        city: weddingSettings.city.trim() || null,
        country: weddingSettings.country.trim() || null,
        primary_venue_name: weddingSettings.primary_venue_name.trim() || null,
        primary_venue_address: weddingSettings.primary_venue_address.trim() || null,
        rsvp_deadline: weddingSettings.rsvp_deadline || null,
      }, token);
      setWeddingSettings(weddingToForm(saved));
      setWeddings((current) => current.map((wedding) => wedding.id === saved.id ? { ...wedding, ...saved, is_active: true } : wedding));
      await refresh();
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not save wedding settings.');
    } finally {
      setIsSavingWedding(false);
    }
  }

  async function saveProfile() {
    if (isSavingProfile || !profile.first_name.trim() || !profile.email.trim()) return;
    setIsSavingProfile(true);
    setOpsError(null);

    try {
      await updateProfile({
        first_name: profile.first_name.trim(),
        last_name: profile.last_name.trim(),
        email: profile.email.trim(),
        avatar_url: profile.avatar_url.trim() || null,
      });
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not save profile.');
    } finally {
      setIsSavingProfile(false);
    }
  }

  async function savePreferences() {
    if (isSavingPreferences) return;
    setIsSavingPreferences(true);
    setOpsError(null);

    try {
      await updatePreferences({
        notification_preferences: notificationPrefs,
        support_preferences: supportPrefs,
      });
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not save preferences.');
    } finally {
      setIsSavingPreferences(false);
    }
  }

  async function overrideUserEntitlement(userId: number) {
    if (!token || opsSavingUserId) return;
    const form = opsOverride[userId];
    if (!form?.plan || !form?.status || !form.note.trim()) {
      setOpsError('Choose a plan, status, and note before overriding an entitlement.');
      return;
    }

    setOpsSavingUserId(userId);
    setOpsError(null);
    try {
      await api.patch(`/internal/ops/users/${userId}/entitlement`, {
        plan: form.plan,
        status: form.status,
        note: form.note,
        confirm: true,
      }, token);
      const query = opsSearch.trim() ? `?q=${encodeURIComponent(opsSearch.trim())}` : '';
      const res = await api.get<{ data: InternalOpsData }>(`/internal/ops${query}`, token);
      setOpsData(res.data);
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not override entitlement.');
    } finally {
      setOpsSavingUserId(null);
    }
  }

  async function changePlan(plan: string) {
    if (!token || changingPlan) return;
    setChangingPlan(plan);
    setOpsError(null);

    try {
      const res = await api.post<{ data: Entitlements; message: string }>('/billing/plan', {
        plan,
        billing_cycle: billingCycle,
        confirm: true,
      }, token);
      setEntitlements(res.data);
      const plansRes = await api.get<{ data: PlanOption[] }>('/billing/plans', token);
      setPlanCatalog(plansRes.data);
    } catch (error) {
      setOpsError(error instanceof Error ? error.message : 'Could not update plan.');
    } finally {
      setChangingPlan(null);
    }
  }

  return (
    <div className="min-h-screen bg-[#fefdfb]">
      <div className="bg-gradient-to-br from-[#FAFAFA] to-white px-4 pt-8 pb-6">
        <h1 className="text-3xl text-[#FF3E9B] mb-2">More</h1>
        <p className="text-sm text-gray-600">Settings, access, and account controls</p>
      </div>

      <div className="px-4 py-6 space-y-4">
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 mb-4">
          <div className="flex items-center">
            <div className="w-16 h-16 bg-gradient-to-br from-[#d45d78] to-[#f194b2] rounded-full flex items-center justify-center text-white text-2xl mr-4">
              {primaryInitial}
            </div>
            <div className="flex-1 min-w-0">
              <h3 className="text-lg font-medium text-[#FF3E9B] truncate">{user?.first_name || user?.email || 'Udo user'}</h3>
              <p className="text-sm text-gray-600 truncate">{user?.email}</p>
              <p className="text-xs text-gray-500 mt-1">{formatLabel(user?.wedding_role ?? 'No wedding role')}</p>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>
        </div>

        {opsError && (
          <div className="bg-[#fff5f8] border border-[#f194b2]/40 rounded-xl px-4 py-3 text-sm text-[#8a1f45]">
            {opsError}
          </div>
        )}

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          {menuItems.map((item) => {
            const Icon = item.icon;
            return (
              <button
                key={item.title}
                onClick={() => {
                  if (item.route) onNavigate?.(item.route);
                  if (item.panel) setActivePanel(activePanel === item.panel ? null : item.panel);
                }}
                className="w-full flex items-center p-4 hover:bg-[#FAFAFA]/30 transition-colors border-b border-gray-100 last:border-0"
              >
                <div className="bg-[#FAFAFA] p-2 rounded-[16px] mr-3">
                  <Icon className="text-[#FF3E9B]" size={20} />
                </div>
                <div className="flex-1 text-left min-w-0">
                  <div className="font-medium text-gray-800">{item.title}</div>
                  <div className="text-xs text-gray-600 mt-0.5 truncate">{item.subtitle}</div>
                </div>
                <ChevronRight className="text-gray-400 flex-shrink-0" size={20} />
              </button>
            );
          })}
        </div>

        {activePanel === 'profile' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Profile</h2>
            <p className="text-xs text-gray-600 mb-4">Keep your name and contact email current for collaboration and notifications.</p>
            <div className="space-y-2">
              <div className="grid grid-cols-2 gap-2">
                <input
                  value={profile.first_name}
                  onChange={(event) => setProfile((current) => ({ ...current, first_name: event.target.value }))}
                  placeholder="First name"
                  className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                />
                <input
                  value={profile.last_name}
                  onChange={(event) => setProfile((current) => ({ ...current, last_name: event.target.value }))}
                  placeholder="Last name"
                  className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                />
              </div>
              <input
                value={profile.email}
                onChange={(event) => setProfile((current) => ({ ...current, email: event.target.value }))}
                placeholder="Email address"
                type="email"
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
              />
              <input
                value={profile.avatar_url}
                onChange={(event) => setProfile((current) => ({ ...current, avatar_url: event.target.value }))}
                placeholder="Avatar URL"
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
              />
              <button
                type="button"
                onClick={saveProfile}
                disabled={isSavingProfile || !profile.first_name.trim() || !profile.email.trim()}
                className="w-full rounded-xl bg-[#FF3E9B] px-4 py-2 text-sm font-medium text-white disabled:opacity-50"
              >
                {isSavingProfile ? 'Saving profile' : 'Save profile'}
              </button>
            </div>
          </section>
        )}

        {activePanel === 'notifications' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Notifications</h2>
            <p className="text-xs text-gray-600 mb-4">Choose the wedding updates Udo should surface for you.</p>
            <div className="space-y-3">
              {[
                ['rsvp_updates', 'RSVP updates'],
                ['task_reminders', 'Task reminders'],
                ['guest_messages', 'Guest messages'],
                ['live_mode', 'Live mode alerts'],
                ['vendor_updates', 'Vendor updates'],
              ].map(([key, label]) => (
                <label key={key} className="flex items-center justify-between rounded-xl bg-[#FAFAFA]/60 px-3 py-3 text-sm text-gray-700">
                  <span>{label}</span>
                  <input
                    type="checkbox"
                    checked={notificationPrefs[key as keyof NotificationPreferences]}
                    onChange={(event) => setNotificationPrefs((current) => ({ ...current, [key]: event.target.checked }))}
                    className="h-4 w-4 accent-[#FF3E9B]"
                  />
                </label>
              ))}
              <button
                type="button"
                onClick={savePreferences}
                disabled={isSavingPreferences}
                className="w-full rounded-xl bg-[#FF3E9B] px-4 py-2 text-sm font-medium text-white disabled:opacity-50"
              >
                {isSavingPreferences ? 'Saving preferences' : 'Save preferences'}
              </button>
            </div>
          </section>
        )}

        {activePanel === 'support' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Support preferences</h2>
            <p className="text-xs text-gray-600 mb-4">Set how actively Udo should support your planning workflow.</p>
            <div className="space-y-3">
              {[
                ['email_support', 'Email support'],
                ['chat_support', 'Live chat'],
                ['proactive_checkins', 'Proactive check-ins'],
              ].map(([key, label]) => (
                <label key={key} className="flex items-center justify-between rounded-xl bg-[#FAFAFA]/60 px-3 py-3 text-sm text-gray-700">
                  <span>{label}</span>
                  <input
                    type="checkbox"
                    checked={supportPrefs[key as keyof Omit<SupportPreferences, 'response_time'>] as boolean}
                    onChange={(event) => setSupportPrefs((current) => ({ ...current, [key]: event.target.checked }))}
                    className="h-4 w-4 accent-[#FF3E9B]"
                  />
                </label>
              ))}
              <select
                value={supportPrefs.response_time}
                onChange={(event) => setSupportPrefs((current) => ({ ...current, response_time: event.target.value as SupportPreferences['response_time'] }))}
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
              >
                <option value="within-1h">Within 1 hour</option>
                <option value="within-24h">Within 24 hours</option>
                <option value="within-3d">Within 3 days</option>
              </select>
              <button
                type="button"
                onClick={savePreferences}
                disabled={isSavingPreferences}
                className="w-full rounded-xl bg-[#FF3E9B] px-4 py-2 text-sm font-medium text-white disabled:opacity-50"
              >
                {isSavingPreferences ? 'Saving preferences' : 'Save preferences'}
              </button>
            </div>
          </section>
        )}

        {activePanel === 'weddings' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Wedding workspaces</h2>
            <p className="text-xs text-gray-600 mb-4">Switch between weddings you own or have been invited to help manage.</p>
            <div className="space-y-3">
              {weddings.length === 0 && <p className="text-sm text-gray-500">{isLoadingOps ? 'Loading weddings...' : 'No accessible weddings yet.'}</p>}
              {weddings.map((wedding) => {
                const isSwitching = switchingWeddingId === wedding.id;
                return (
                  <button
                    key={wedding.id}
                    type="button"
                    onClick={() => changeWedding(wedding.id)}
                    disabled={wedding.is_active || switchingWeddingId !== null}
                    className="w-full rounded-xl border border-gray-100 bg-[#FAFAFA]/60 px-4 py-3 text-left transition hover:border-[#f194b2] disabled:cursor-default disabled:hover:border-gray-100"
                  >
                    <div className="flex items-start gap-3">
                      <div className="mt-0.5 rounded-full bg-white p-2 text-[#FF3E9B]">
                        {wedding.is_active ? <CheckCircle2 size={18} /> : <CalendarDays size={18} />}
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2">
                          <span className="truncate text-sm font-medium text-gray-800">{weddingTitle(wedding)}</span>
                          {wedding.is_active && <span className="rounded-full bg-[#FF3E9B]/10 px-2 py-0.5 text-[10px] font-medium text-[#FF3E9B]">Active</span>}
                        </div>
                        <p className="mt-1 truncate text-xs text-gray-500">{weddingMeta(wedding)}</p>
                        <p className="mt-1 text-[11px] text-gray-500">
                          {wedding.access?.is_owner ? 'Owner' : formatLabel(wedding.access?.role ?? 'Collaborator')}
                        </p>
                      </div>
                      {!wedding.is_active && (
                        <span className="shrink-0 rounded-lg border border-[#f194b2]/40 px-3 py-1 text-xs font-medium text-[#FF3E9B]">
                          {isSwitching ? 'Switching' : 'Switch'}
                        </span>
                      )}
                    </div>
                  </button>
                );
              })}
            </div>
            <div className="mt-5 border-t border-gray-100 pt-4">
              <h3 className="text-sm font-medium text-gray-800 mb-2">Create another wedding</h3>
              <div className="space-y-2">
                <input
                  value={newWedding.title}
                  onChange={(event) => setNewWedding((current) => ({ ...current, title: event.target.value }))}
                  placeholder="Workspace name, e.g. Lisbon weekend"
                  className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                />
                <div className="grid grid-cols-2 gap-2">
                  <input
                    value={newWedding.couple_name_primary}
                    onChange={(event) => setNewWedding((current) => ({ ...current, couple_name_primary: event.target.value }))}
                    placeholder="Primary name"
                    className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                  />
                  <input
                    value={newWedding.couple_name_secondary}
                    onChange={(event) => setNewWedding((current) => ({ ...current, couple_name_secondary: event.target.value }))}
                    placeholder="Partner name"
                    className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                  />
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <input
                    type="date"
                    value={newWedding.event_date}
                    onChange={(event) => setNewWedding((current) => ({ ...current, event_date: event.target.value }))}
                    className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                  />
                  <input
                    value={newWedding.city}
                    onChange={(event) => setNewWedding((current) => ({ ...current, city: event.target.value }))}
                    placeholder="City"
                    className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                  />
                </div>
                <input
                  value={newWedding.country}
                  onChange={(event) => setNewWedding((current) => ({ ...current, country: event.target.value }))}
                  placeholder="Country"
                  className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                />
                <button
                  type="button"
                  onClick={createWeddingWorkspace}
                  disabled={isCreatingWedding || !newWedding.couple_name_primary.trim()}
                  className="w-full rounded-xl bg-[#FF3E9B] px-4 py-2 text-sm font-medium text-white disabled:opacity-50"
                >
                  {isCreatingWedding ? 'Creating workspace' : 'Create workspace'}
                </button>
              </div>
            </div>
          </section>
        )}

        {activePanel === 'settings' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Wedding settings</h2>
            <p className="text-xs text-gray-600 mb-4">
              {canManageWedding ? 'Update the operational details used across guests, live mode, RSVP, and planning.' : 'You need wedding management access to edit these details.'}
            </p>
            <div className="space-y-2">
              <input
                value={weddingSettings.title}
                onChange={(event) => setWeddingSettings((current) => ({ ...current, title: event.target.value }))}
                disabled={!canManageWedding}
                placeholder="Workspace title"
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
              />
              <div className="grid grid-cols-2 gap-2">
                <input
                  value={weddingSettings.couple_name_primary}
                  onChange={(event) => setWeddingSettings((current) => ({ ...current, couple_name_primary: event.target.value }))}
                  disabled={!canManageWedding}
                  placeholder="Primary name"
                  className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
                />
                <input
                  value={weddingSettings.couple_name_secondary}
                  onChange={(event) => setWeddingSettings((current) => ({ ...current, couple_name_secondary: event.target.value }))}
                  disabled={!canManageWedding}
                  placeholder="Partner name"
                  className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
                />
              </div>
              <div className="grid grid-cols-2 gap-2">
                <label className="min-w-0">
                  <span className="mb-1 block text-[11px] text-gray-500">Wedding date</span>
                  <input
                    type="date"
                    value={weddingSettings.event_date}
                    onChange={(event) => setWeddingSettings((current) => ({ ...current, event_date: event.target.value }))}
                    disabled={!canManageWedding}
                    className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
                  />
                </label>
                <label className="min-w-0">
                  <span className="mb-1 block text-[11px] text-gray-500">RSVP deadline</span>
                  <input
                    type="date"
                    value={weddingSettings.rsvp_deadline}
                    onChange={(event) => setWeddingSettings((current) => ({ ...current, rsvp_deadline: event.target.value }))}
                    disabled={!canManageWedding}
                    className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
                  />
                </label>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <input
                  value={weddingSettings.city}
                  onChange={(event) => setWeddingSettings((current) => ({ ...current, city: event.target.value }))}
                  disabled={!canManageWedding}
                  placeholder="City"
                  className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
                />
                <input
                  value={weddingSettings.country}
                  onChange={(event) => setWeddingSettings((current) => ({ ...current, country: event.target.value }))}
                  disabled={!canManageWedding}
                  placeholder="Country"
                  className="min-w-0 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
                />
              </div>
              <input
                value={weddingSettings.primary_venue_name}
                onChange={(event) => setWeddingSettings((current) => ({ ...current, primary_venue_name: event.target.value }))}
                disabled={!canManageWedding}
                placeholder="Venue name"
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
              />
              <textarea
                value={weddingSettings.primary_venue_address}
                onChange={(event) => setWeddingSettings((current) => ({ ...current, primary_venue_address: event.target.value }))}
                disabled={!canManageWedding}
                placeholder="Venue address"
                rows={3}
                className="w-full resize-none rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B] disabled:bg-gray-50"
              />
              <button
                type="button"
                onClick={saveWeddingSettings}
                disabled={!canManageWedding || isSavingWedding || !weddingSettings.couple_name_primary.trim()}
                className="w-full rounded-xl bg-[#FF3E9B] px-4 py-2 text-sm font-medium text-white disabled:opacity-50"
              >
                {isSavingWedding ? 'Saving settings' : 'Save settings'}
              </button>
            </div>
          </section>
        )}

        {activePanel === 'subscription' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <div className="flex items-start justify-between gap-3 mb-4">
              <div>
                <h2 className="text-[17px] font-medium text-gray-800 mb-1">Wedding Pass</h2>
                <p className="text-xs text-gray-600">{entitlements ? `${entitlements.label} - ${formatLabel(entitlements.status)}` : isLoadingOps ? 'Loading plan details...' : 'No plan details available.'}</p>
              </div>
              <div className="flex rounded-full bg-[#FAFAFA] p-1 text-xs">
                {(['monthly', 'annual'] as const).map((cycle) => (
                  <button
                    key={cycle}
                    type="button"
                    onClick={() => setBillingCycle(cycle)}
                    className={`rounded-full px-3 py-1 font-medium ${billingCycle === cycle ? 'bg-white text-[#FF3E9B] shadow-sm' : 'text-gray-500'}`}
                  >
                    {cycle === 'annual' ? 'Annual' : 'Monthly'}
                  </button>
                ))}
              </div>
            </div>
            {entitlements && (
              <div className="space-y-3 mb-5">
                {Object.entries(entitlements.limits).map(([key, limit]) => {
                  const used = entitlements.usage[key] ?? 0;
                  const percent = limit ? Math.min(100, Math.round((used / limit) * 100)) : 100;
                  return (
                    <div key={key}>
                      <div className="flex justify-between text-xs text-gray-600 mb-1">
                        <span>{formatLabel(key)}</span>
                        <span>{used}{limit === null ? ' / Unlimited' : ` / ${limit}`}</span>
                      </div>
                      <div className="h-2 rounded-full bg-gray-100 overflow-hidden">
                        <div className="h-full bg-[#FF3E9B]" style={{ width: `${percent}%` }} />
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
            <div className="space-y-3">
              {(planCatalog.length ? planCatalog : entitlements?.available_plans ?? []).map((plan) => {
                const price = billingCycle === 'annual' ? plan.annual_price : plan.monthly_price;
                const isChanging = changingPlan === plan.plan;
                return (
                  <div key={plan.plan} className={`rounded-2xl border p-4 ${plan.current ? 'border-[#FF3E9B] bg-[#fff5f8]' : 'border-gray-100 bg-white'}`}>
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-sm font-semibold text-gray-900">{plan.label}</h3>
                          {plan.recommended && <span className="rounded-full bg-[#285301]/10 px-2 py-0.5 text-[10px] font-medium text-[#285301]">Recommended</span>}
                          {plan.current && <span className="rounded-full bg-[#FF3E9B]/10 px-2 py-0.5 text-[10px] font-medium text-[#FF3E9B]">Current</span>}
                        </div>
                        <p className="mt-1 text-xs text-gray-600">{plan.description}</p>
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-semibold text-gray-900">${price}</div>
                        <div className="text-[11px] text-gray-500">/{billingCycle === 'annual' ? 'yr' : 'mo'}</div>
                      </div>
                    </div>
                    <div className="mt-3 grid gap-1 text-xs text-gray-600">
                      {plan.features.slice(0, 4).map((feature) => <div key={feature}>- {feature}</div>)}
                    </div>
                    <button
                      type="button"
                      onClick={() => changePlan(plan.plan)}
                      disabled={plan.current || !plan.can_change || changingPlan !== null}
                      className="mt-4 w-full rounded-xl bg-[#FF3E9B] px-4 py-2 text-sm font-medium text-white disabled:bg-gray-200 disabled:text-gray-500"
                    >
                      {plan.current ? 'Current plan' : !plan.can_change ? 'Usage exceeds plan' : isChanging ? 'Updating plan' : `Switch to ${plan.label}`}
                    </button>
                  </div>
                );
              })}
            </div>
          </section>
        )}

        {activePanel === 'team' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Collaborators</h2>
            <p className="text-xs text-gray-600 mb-4">{canManageTeam ? 'Manage who can help plan this wedding.' : 'You need team access to manage collaborators.'}</p>
            <div className="space-y-3 mb-4">
              {team.map((member) => (
                <div key={`${member.user_id}-${member.role}`} className="flex items-center justify-between gap-3">
                  <div className="min-w-0">
                    <div className="text-sm font-medium text-gray-800 truncate">{member.name || member.email}</div>
                    <div className="text-xs text-gray-500 truncate">{member.email}</div>
                  </div>
                  <span className="text-[11px] px-2 py-1 rounded-full bg-[#FAFAFA] text-[#FF3E9B] border border-[#f194b2]/30">
                    {formatLabel(member.role)}
                  </span>
                </div>
              ))}
            </div>
            {canManageTeam && (
              <div className="space-y-3">
                <input
                  value={inviteEmail}
                  onChange={(event) => setInviteEmail(event.target.value)}
                  placeholder="collaborator@email.com"
                  className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                />
                <div className="flex gap-2">
                  <select
                    value={inviteRole}
                    onChange={(event) => setInviteRole(event.target.value)}
                    className="flex-1 rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-[#FF3E9B]"
                  >
                    {roles.map((role) => (
                      <option key={role.role} value={role.role}>{formatLabel(role.role)}</option>
                    ))}
                  </select>
                  <button
                    onClick={inviteTeamMember}
                    disabled={isInviting || !inviteEmail.trim()}
                    className="px-4 py-2 rounded-xl bg-[#FF3E9B] text-white text-sm font-medium disabled:opacity-50"
                  >
                    {isInviting ? 'Adding' : 'Add'}
                  </button>
                </div>
              </div>
            )}
          </section>
        )}

        {activePanel === 'activity' && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Activity log</h2>
            <p className="text-xs text-gray-600 mb-4">{canViewReports ? 'Recent important changes in this wedding workspace.' : 'You need report access to view activity.'}</p>
            <div className="space-y-3">
              {auditLogs.length === 0 && <p className="text-sm text-gray-500">{isLoadingOps ? 'Loading activity...' : 'No activity yet.'}</p>}
              {auditLogs.map((log) => (
                <div key={log.id} className="border-b border-gray-100 last:border-0 pb-3 last:pb-0">
                  <div className="text-sm font-medium text-gray-800">{formatLabel(log.action)}</div>
                  <div className="text-xs text-gray-500">
                    {log.user?.email ?? 'System'} - {new Date(log.created_at).toLocaleString()}
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {activePanel === 'ops' && canUseInternalOps && (
          <section className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h2 className="text-[17px] font-medium text-gray-800 mb-1">Internal ops</h2>
            <p className="text-xs text-gray-600 mb-4">Support diagnostics, delivery debugging, account lookup, and entitlement overrides.</p>
            <input value={opsSearch} onChange={(event) => setOpsSearch(event.target.value)} className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm mb-4" placeholder="Search users, emails, weddings, or slugs" />
            {!opsData && <p className="text-sm text-gray-500">Loading internal operations...</p>}
            {opsData && (
              <div className="space-y-5">
                <div className="grid grid-cols-3 gap-2 text-center">
                  <div className="rounded-xl bg-[#FAFAFA] p-3"><div className="text-lg font-semibold text-gray-900">{opsData.summary.users}</div><div className="text-[11px] text-gray-500">Users</div></div>
                  <div className="rounded-xl bg-[#FAFAFA] p-3"><div className="text-lg font-semibold text-gray-900">{opsData.summary.weddings}</div><div className="text-[11px] text-gray-500">Weddings</div></div>
                  <div className="rounded-xl bg-[#FAFAFA] p-3"><div className="text-lg font-semibold text-gray-900">{opsData.summary.active_paid_subscriptions}</div><div className="text-[11px] text-gray-500">Paid</div></div>
                </div>
                <div className="rounded-xl border border-gray-100 p-3">
                  <div className="flex items-center justify-between text-sm font-medium text-gray-800"><span>Platform health</span><span>{opsData.health.score}% {opsData.health.status}</span></div>
                  <div className="mt-2 grid grid-cols-2 gap-2 text-xs text-gray-600">
                    <div>Failed jobs: {opsData.health.queue.failed_jobs}</div>
                    <div>Pending sends: {opsData.health.queue.pending_deliveries}</div>
                    <div>Failed sends: {opsData.health.queue.failed_deliveries}</div>
                    <div>Stale sends: {opsData.health.queue.stale_sending_messages}</div>
                  </div>
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-800 mb-2">Users</h3>
                  <div className="space-y-3">
                    {opsData.users.map((opsUser) => {
                      const form = opsOverride[opsUser.id] ?? { plan: opsUser.plan, status: opsUser.subscription_status, note: '' };
                      return (
                        <div key={opsUser.id} className="rounded-xl border border-gray-100 p-3">
                          <div className="flex justify-between gap-3">
                            <div><div className="text-sm font-medium text-gray-900">{opsUser.name || opsUser.email}</div><div className="text-xs text-gray-500">{opsUser.email}</div></div>
                            <div className="text-xs text-gray-500">{formatLabel(opsUser.plan)} / {formatLabel(opsUser.subscription_status)}</div>
                          </div>
                          <div className="mt-3 grid grid-cols-2 gap-2">
                            <select value={form.plan} onChange={(event) => setOpsOverride((current) => ({ ...current, [opsUser.id]: { ...form, plan: event.target.value } }))} className="rounded-lg border border-gray-200 px-2 py-2 text-xs">
                              {opsData.plans.map((plan) => <option key={plan} value={plan}>{formatLabel(plan)}</option>)}
                            </select>
                            <select value={form.status} onChange={(event) => setOpsOverride((current) => ({ ...current, [opsUser.id]: { ...form, status: event.target.value } }))} className="rounded-lg border border-gray-200 px-2 py-2 text-xs">
                              {['active', 'trialing', 'cancelled', 'past_due', 'expired'].map((status) => <option key={status} value={status}>{formatLabel(status)}</option>)}
                            </select>
                          </div>
                          <div className="mt-2 flex gap-2">
                            <input value={form.note} onChange={(event) => setOpsOverride((current) => ({ ...current, [opsUser.id]: { ...form, note: event.target.value } }))} className="flex-1 rounded-lg border border-gray-200 px-2 py-2 text-xs" placeholder="Required support note" />
                            <button onClick={() => overrideUserEntitlement(opsUser.id)} disabled={opsSavingUserId === opsUser.id} className="rounded-lg bg-[#285301] px-3 py-2 text-xs font-medium text-white disabled:opacity-50">Override</button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-800 mb-2">Weddings</h3>
                  <div className="space-y-2">
                    {opsData.weddings.map((opsWedding) => (
                      <div key={opsWedding.id} className="rounded-xl border border-gray-100 p-3 text-sm">
                        <div className="font-medium text-gray-900">{opsWedding.title || `Wedding #${opsWedding.id}`}</div>
                        <div className="text-xs text-gray-500">{opsWedding.owner_email ?? 'No owner email'} - {opsWedding.guests_count} guests - {opsWedding.messages_count} messages - {opsWedding.audit_logs_count} audits</div>
                      </div>
                    ))}
                  </div>
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-800 mb-2">Delivery diagnostics</h3>
                  <div className="space-y-2">
                    {opsData.delivery_diagnostics.length === 0 && <p className="text-sm text-gray-500">No failed or pending deliveries.</p>}
                    {opsData.delivery_diagnostics.map((delivery) => (
                      <div key={delivery.id} className="rounded-xl border border-gray-100 p-3 text-sm">
                        <div className="font-medium text-gray-900">{delivery.message_subject ?? 'Message'} - {formatLabel(delivery.status)}</div>
                        <div className="text-xs text-gray-500">{delivery.channel} to {delivery.guest_email ?? 'unknown guest'}{delivery.error_message ? ` - ${delivery.error_message}` : ''}</div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </section>
        )}

        <div className="bg-gradient-to-br from-[#FAFAFA] to-white rounded-2xl p-5 border border-[#f194b2]/20 text-center">
          <Mail size={32} className="text-[#FF3E9B] mx-auto mb-3" />
          <h3 className="font-medium text-[#FF3E9B] mb-2">Get in touch</h3>
          <p className="text-sm text-gray-600 mb-4">hello@udowedding.com</p>
          <p className="text-xs italic text-gray-600">Planning should feel peaceful. We are always here to listen.</p>
        </div>

        <button onClick={logout} className="w-full bg-white rounded-2xl shadow-sm border border-gray-100 p-4 flex items-center justify-center hover:bg-gray-50 transition-colors">
          <LogOut className="text-[#FF3E9B] mr-2" size={20} />
          <span className="font-medium text-[#FF3E9B]">Sign out</span>
        </button>

        <div className="h-8" />
      </div>
    </div>
  );
}
