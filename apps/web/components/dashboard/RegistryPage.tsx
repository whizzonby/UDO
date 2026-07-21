'use client';

import { useState, useEffect } from 'react';
import { Gift, Link2, List, Heart, Share2, Plus, X, Check, ExternalLink, Clock, Sparkles, CheckCircle, MessageSquare } from 'lucide-react';
import { api } from '@/lib/api';
import { getToken } from '@/lib/auth';

type RegistryTab = 'pending' | 'completed';
type ModalType = 'cash-fund' | 'add-link' | 'custom-item' | 'share' | 'thank-you' | 'contribute' | null;

interface RegistryItem {
  id: number;
  type: 'link' | 'custom';
  title: string;
  price?: string;
  image?: string;
  status: 'available' | 'reserved' | 'gifted';
  url?: string;
  note?: string;
}

interface ThankYouItem {
  id: number;
  guestName: string;
  gift: string;
  status: 'pending' | 'completed';
  dateThanked?: string;
  message?: string;
}

type ApiRegistryItem = {
  id: number;
  name: string;
  type: string;
  price?: string | number | null;
  fund_goal?: string | number | null;
  store_url?: string | null;
  contributions_count?: number;
};

type ApiThankYouRecord = {
  id: number;
  contribution_id?: number | null;
  recipient_name: string;
  reason?: string | null;
  note?: string | null;
  sent_at?: string | null;
  contribution?: { item?: { name?: string | null } | null } | null;
};

type RegistrySummary = {
  fund_raised_total?: number;
  fund_goal_total?: number;
  thank_yous?: {
    pending?: ApiThankYouRecord[];
    completed?: ApiThankYouRecord[];
  };
};

export default function RegistryPage() {
  const [hasRegistry, setHasRegistry] = useState(false);
  const [openModal, setOpenModal] = useState<ModalType>(null);
  const [thankYouTab, setThankYouTab] = useState<RegistryTab>('pending');
  const [selectedThankYou, setSelectedThankYou] = useState<number | null>(null);
  const [isLoadingRegistry, setIsLoadingRegistry] = useState(true);
  const [registryError, setRegistryError] = useState<string | null>(null);
  const [registryNotice, setRegistryNotice] = useState<string | null>(null);

  const [cashFund] = useState({
    title: 'Our Honeymoon Fund',
    description: 'Help us create unforgettable memories on our first adventure as newlyweds',
    target: 5000,
    raised: 2340,
  });

  const [registryItems, setRegistryItems] = useState<ApiRegistryItem[]>([]);
  const [registrySummary, setRegistrySummary] = useState<RegistrySummary | null>(null);
  const [addingItem, setAddingItem] = useState(false);
  const [linkUrl, setLinkUrl] = useState('');
  const [linkNote, setLinkNote] = useState('');
  const [customName, setCustomName] = useState('');
  const [customPrice, setCustomPrice] = useState('');
  const [customNote, setCustomNote] = useState('');
  const [thankYouMessage, setThankYouMessage] = useState('');

  const [thankYouItems, setThankYouItems] = useState<ThankYouItem[]>([]);

  const loadRegistry = async () => {
    const t = getToken();
    if (!t) {
      setIsLoadingRegistry(false);
      return;
    }
    setIsLoadingRegistry(true);
    setRegistryError(null);
    try {
      const [itemsRes, summaryRes] = await Promise.all([
        api.get<{ data: ApiRegistryItem[] }>('/registry', t),
        api.get<{ data: RegistrySummary }>('/registry/summary', t),
      ]);
      const items = itemsRes.data ?? [];
      setRegistryItems(items);
      setRegistrySummary(summaryRes.data ?? null);
      const pending = (summaryRes.data?.thank_yous?.pending ?? []).map((record) => ({
        id: record.contribution_id ?? record.id,
        guestName: record.recipient_name,
        gift: record.contribution?.item?.name ?? record.reason ?? 'Gift',
        status: 'pending' as const,
        message: record.note ?? undefined,
      }));
      const completed = (summaryRes.data?.thank_yous?.completed ?? []).map((record) => ({
        id: record.contribution_id ?? record.id,
        guestName: record.recipient_name,
        gift: record.contribution?.item?.name ?? record.reason ?? 'Gift',
        status: 'completed' as const,
        dateThanked: record.sent_at ? new Date(record.sent_at).toLocaleDateString() : undefined,
        message: record.note ?? undefined,
      }));
      setThankYouItems([...pending, ...completed]);
      setHasRegistry(items.length > 0);
    } catch (error) {
      setRegistryError(error instanceof Error ? error.message : 'Could not load registry.');
    } finally {
      setIsLoadingRegistry(false);
    }
  };

  useEffect(() => {
    loadRegistry().catch(() => {});
  }, []);

  const addCashFund = async () => {
    const t = getToken();
    if (!t) return;
    setAddingItem(true);
    try {
      const res = await api.post<{ data: ApiRegistryItem }>('/registry', { name: cashFund.title, type: 'cash_fund', fund_goal: cashFund.target, description: cashFund.description }, t);
      setRegistryItems(prev => [...prev, res.data]);
      setHasRegistry(true);
      setOpenModal(null);
      setRegistryNotice('Cash fund created.');
      loadRegistry().catch(() => {});
    } catch (error) {
      setRegistryError(error instanceof Error ? error.message : 'Could not create cash fund.');
    }
    finally { setAddingItem(false); }
  };

  const addRegistryItem = async (payload: Record<string, unknown>) => {
    const t = getToken();
    if (!t) return;
    setAddingItem(true);
    try {
      const res = await api.post<{ data: ApiRegistryItem }>('/registry', payload, t);
      setRegistryItems(prev => [...prev, res.data]);
      setHasRegistry(true);
      setOpenModal(null);
      setLinkUrl('');
      setLinkNote('');
      setCustomName('');
      setCustomPrice('');
      setCustomNote('');
      setRegistryNotice('Registry item saved.');
      await loadRegistry();
    } catch (error) {
      setRegistryError(error instanceof Error ? error.message : 'Could not save registry item.');
    } finally {
      setAddingItem(false);
    }
  };

  const markThanked = async (contributionId: number) => {
    const t = getToken();
    if (!t) return;
    try {
      await api.post(`/registry/contributions/${contributionId}/thank-you`, {}, t);
      setOpenModal(null);
      setSelectedThankYou(null);
      setThankYouMessage('');
      setRegistryNotice('Thank-you marked complete.');
      await loadRegistry();
    } catch (error) {
      setRegistryError(error instanceof Error ? error.message : 'Could not mark thank-you complete.');
    }
  };

  const displayItems: RegistryItem[] = registryItems.map(item => ({
    id: item.id,
    type: item.store_url ? 'link' : 'custom',
    title: item.name,
    price: item.price ? `$${item.price}` : item.fund_goal ? `Goal: $${item.fund_goal}` : undefined,
    status: (item.contributions_count ?? 0) > 0 ? 'gifted' : 'available',
    url: item.store_url ?? undefined,
  }));
  const cashFundRaised = registrySummary?.fund_raised_total ?? cashFund.raised;
  const cashFundTarget = registrySummary?.fund_goal_total || cashFund.target;
  const registryShareUrl = typeof window !== 'undefined' ? `${window.location.origin}/guest/registry` : 'https://udo.wedding/guest/registry';

  const pendingThankYous = thankYouItems.filter(item => item.status === 'pending');
  const completedThankYous = thankYouItems.filter(item => item.status === 'completed');
  const selectedThankYouItem = thankYouItems.find(item => item.id === selectedThankYou);

  const copyText = async (value: string, message: string) => {
    try {
      await navigator.clipboard.writeText(value);
      setRegistryNotice(message);
    } catch {
      setRegistryError('Could not copy the link. Select and copy it manually.');
    }
  };

  const openExternal = (url: string) => {
    window.open(url, '_blank', 'noopener,noreferrer');
  };

  const openShareUrl = (type: 'whatsapp' | 'sms') => {
    const message = `Here is our wedding registry: ${registryShareUrl}`;
    const url = type === 'whatsapp'
      ? `https://wa.me/?text=${encodeURIComponent(message)}`
      : `sms:?&body=${encodeURIComponent(message)}`;
    openExternal(url);
  };

  const renderStatus = () => (
    <>
      {registryNotice && (
        <div className="mb-4 rounded-[16px] border border-[#3A8B95]/20 bg-[#F0F9FA] px-4 py-3 text-[13px] text-[#2B2B2B] flex items-center justify-between gap-3">
          <span>{registryNotice}</span>
          <button onClick={() => setRegistryNotice(null)} className="text-[#3A8B95]" aria-label="Dismiss registry notice">
            <X size={16} />
          </button>
        </div>
      )}
      {registryError && (
        <div className="mb-4 rounded-[16px] border border-[#8B6F47]/20 bg-[#FFF5F8] px-4 py-3 text-[13px] text-[#2B2B2B]">
          <div className="flex items-center justify-between gap-3">
            <span>{registryError}</span>
            <button onClick={loadRegistry} className="text-[#3A8B95]" style={{ fontWeight: 500 }}>
              Retry
            </button>
          </div>
        </div>
      )}
      {isLoadingRegistry && (
        <div className="mb-4 rounded-[16px] border border-[#EAE7E2] bg-white px-4 py-3 text-[13px] text-[#6F6F6F]">
          Loading registry...
        </div>
      )}
    </>
  );

  if (!hasRegistry) {
    return (
      <div className="min-h-screen bg-[#FAFAFA]">
        {/* Header */}
        <div className="bg-white border-b border-[#EAE7E2] px-4 pt-6 pb-5">
          <h1 className="text-[28px] text-[#3A8B95] mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
            Registry
          </h1>
          <p className="text-[13px] text-[#6F6F6F]" style={{ fontStyle: 'italic' }}>
            Create a simple, meaningful way for guests to give
          </p>
        </div>

        {/* Content */}
        <div className="px-4 py-8 max-w-[720px] mx-auto">
          {renderStatus()}
          {/* Hero Card */}
          <div className="bg-gradient-to-br from-[#E8CFCF]/20 to-white rounded-2xl p-8 mb-8 text-center border border-[#E8CFCF]/30">
            <h2 className="text-[22px] text-[#2B2B2B] mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
              Set up your registry in seconds
            </h2>
            <p className="text-[14px] text-[#6F6F6F] leading-relaxed">
              Add gifts, contributions, or simply share your wishes
            </p>
          </div>

          {/* Action Cards */}
          <div className="space-y-4">
            {/* Cash Fund */}
            <div className="bg-white rounded-2xl p-6 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 bg-[#3A8B95]/10 rounded-[20px] flex items-center justify-center flex-shrink-0">
                  <Heart size={24} className="text-[#3A8B95]" />
                </div>
                <div className="flex-1">
                  <h3 className="text-[17px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                    Contribute to our future
                  </h3>
                  <p className="text-[13px] text-[#6F6F6F] mb-4">
                    Honeymoon, home, or something meaningful
                  </p>
                  <button
                    onClick={() => setOpenModal('cash-fund')}
                    className="px-5 py-2.5 bg-[#3A8B95] text-white rounded-[20px] text-[13px] hover:bg-[#3A8B95]/90 transition-colors"
                    style={{ fontWeight: 500 }}
                  >
                    Set up fund
                  </button>
                </div>
              </div>
            </div>

            {/* Add Link */}
            <div className="bg-white rounded-2xl p-6 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 bg-[#3A8B95]/10 rounded-[20px] flex items-center justify-center flex-shrink-0">
                  <Link2 size={24} className="text-[#3A8B95]" />
                </div>
                <div className="flex-1">
                  <h3 className="text-[17px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                    Add something you love
                  </h3>
                  <p className="text-[13px] text-[#6F6F6F] mb-4">
                    Paste a link from any store
                  </p>
                  <button
                    onClick={() => setOpenModal('add-link')}
                    className="px-5 py-2.5 bg-white border border-[#2F5D50] text-[#3A8B95] rounded-[20px] text-[13px] hover:bg-[#3A8B95] hover:text-white transition-colors"
                    style={{ fontWeight: 500 }}
                  >
                    Add item
                  </button>
                </div>
              </div>
            </div>

            {/* Simple Wishlist */}
            <div className="bg-white rounded-2xl p-6 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 bg-[#3A8B95]/10 rounded-[20px] flex items-center justify-center flex-shrink-0">
                  <List size={24} className="text-[#3A8B95]" />
                </div>
                <div className="flex-1">
                  <h3 className="text-[17px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                    Create a wishlist
                  </h3>
                  <p className="text-[13px] text-[#6F6F6F] mb-4">
                    Add gifts without links
                  </p>
                  <button
                    onClick={() => setOpenModal('custom-item')}
                    className="px-5 py-2.5 bg-white border border-[#2F5D50] text-[#3A8B95] rounded-[20px] text-[13px] hover:bg-[#3A8B95] hover:text-white transition-colors"
                    style={{ fontWeight: 500 }}
                  >
                    Create list
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Modals */}
        {renderModals()}
      </div>
    );
  }

  // Active Registry State
  return (
    <div className="min-h-screen bg-[#FAFAFA]">
      {/* Header */}
      <div className="bg-white border-b border-[#EAE7E2] px-4 pt-6 pb-5">
        <div className="flex items-start justify-between mb-1">
          <h1 className="text-[28px] text-[#3A8B95]" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
            Your registry
          </h1>
          <div className="flex gap-2">
            <button
              onClick={() => setOpenModal('share')}
              className="p-2 bg-[#FAFAFA] rounded-[16px] hover:bg-[#EAE7E2] transition-colors"
            >
              <Share2 size={20} className="text-[#3A8B95]" />
            </button>
            <button
              onClick={() => setOpenModal('add-link')}
              className="p-2 bg-[#3A8B95] rounded-[16px] hover:bg-[#3A8B95]/90 transition-colors"
            >
              <Plus size={20} className="text-white" />
            </button>
          </div>
        </div>
        <p className="text-[13px] text-[#6F6F6F]" style={{ fontStyle: 'italic' }}>
          Gifts, contributions, and thank-yous in one place
        </p>
      </div>

      {/* Content */}
      <div className="px-4 py-8 max-w-[720px] mx-auto space-y-8">
        {renderStatus()}
        {/* Cash Fund Card */}
        <div className="bg-white rounded-2xl p-6 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
          <div className="flex items-start justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-[#3A8B95]/10 rounded-[16px] flex items-center justify-center">
                <Heart size={20} className="text-[#3A8B95]" />
              </div>
              <div>
                <h3 className="text-[17px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  {cashFund.title}
                </h3>
                <p className="text-[12px] text-[#6F6F6F] mt-0.5">
                  {cashFund.description}
                </p>
              </div>
            </div>
          </div>

          {/* Progress Bar */}
          <div className="mb-3">
            <div className="h-2 bg-[#FAFAFA] rounded-full overflow-hidden">
              <div
                className="h-full bg-[#3A8B95] rounded-full transition-all"
                style={{ width: `${cashFundTarget > 0 ? Math.min(100, (cashFundRaised / cashFundTarget) * 100) : 0}%` }}
              ></div>
            </div>
          </div>

          <div className="flex items-center justify-between mb-4">
            <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
              ${cashFundRaised.toLocaleString()} raised
            </span>
            <span className="text-[12px] text-[#6F6F6F]">
              of ${cashFundTarget.toLocaleString()}
            </span>
          </div>

          <button
            onClick={() => setOpenModal('share')}
            className="w-full py-2.5 bg-[#3A8B95] text-white rounded-[20px] text-[13px] hover:bg-[#3A8B95]/90 transition-colors"
            style={{ fontWeight: 500 }}
          >
            Share fund with guests
          </button>
        </div>

        {/* Items Grid */}
        <div>
          <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>
            Registry items
          </h3>
          {displayItems.length === 0 ? (
            <div className="bg-white rounded-2xl p-6 text-center border border-[#EAE7E2]">
              <Gift size={28} className="text-[#3A8B95] mx-auto mb-3" />
              <p className="text-[14px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>No registry items yet</p>
              <p className="text-[13px] text-[#6F6F6F] mb-4">Add a store link or wishlist item so guests know what would help most.</p>
              <button onClick={() => setOpenModal('add-link')} className="px-5 py-2.5 bg-[#3A8B95] text-white rounded-[20px] text-[13px] hover:bg-[#3A8B95]/90 transition-colors" style={{ fontWeight: 500 }}>
                Add first item
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-3">
              {displayItems.map((item) => (
              <div key={item.id} className="bg-white rounded-[20px] overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
                <div className="h-40 bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] flex items-center justify-center">
                  <Gift size={32} className="text-[#3A8B95]/40" />
                </div>
                <div className="p-3">
                  <h4 className="text-[14px] text-[#2B2B2B] mb-1 line-clamp-1" style={{ fontWeight: 500 }}>
                    {item.title}
                  </h4>
                  {item.price && (
                    <p className="text-[13px] text-[#6F6F6F] mb-2">
                      {item.price}
                    </p>
                  )}
                  <div
                    className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] ${
                      item.status === 'gifted'
                        ? 'bg-[#F0F9FA] text-[#3A8B95]'
                        : item.status === 'reserved'
                        ? 'bg-[#FFF5F8] text-[#8B6F47]'
                        : 'bg-[#FAFAFA] text-[#6F6F6F]'
                    }`}
                    style={{ fontWeight: 500 }}
                  >
                    {item.status === 'gifted' && <Check size={10} className="mr-1" />}
                    {item.status === 'gifted' ? 'Gifted' : item.status === 'reserved' ? 'Reserved' : 'Available'}
                  </div>
                  {item.url && (
                    <button onClick={() => openExternal(item.url as string)} className="mt-3 w-full py-2 text-[12px] text-[#3A8B95] border border-[#EAE7E2] rounded-[16px] hover:bg-[#FAFAFA] transition-colors flex items-center justify-center gap-1.5" style={{ fontWeight: 500 }}>
                      <ExternalLink size={14} />
                      View item
                    </button>
                  )}
                </div>
              </div>
              ))}
            </div>
          )}
        </div>

        {/* Thank-You Tracker */}
        <div className="bg-white rounded-2xl p-6 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
          <div className="mb-5">
            <h3 className="text-[17px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
              Thank-you tracker
            </h3>
            <p className="text-[13px] text-[#6F6F6F]">
              Keep track of who you have thanked
            </p>
          </div>

          {/* Tabs */}
          <div className="flex gap-2 mb-5">
            <button
              onClick={() => setThankYouTab('pending')}
              className={`flex-1 px-4 py-2.5 rounded-[16px] text-[13px] transition-colors ${
                thankYouTab === 'pending'
                  ? 'bg-[#3A8B95] text-white'
                  : 'bg-[#FAFAFA] text-[#6F6F6F] hover:bg-[#EAE7E2]'
              }`}
              style={{ fontWeight: 500 }}
            >
              Pending thanks ({pendingThankYous.length})
            </button>
            <button
              onClick={() => setThankYouTab('completed')}
              className={`flex-1 px-4 py-2.5 rounded-[16px] text-[13px] transition-colors ${
                thankYouTab === 'completed'
                  ? 'bg-[#3A8B95] text-white'
                  : 'bg-[#FAFAFA] text-[#6F6F6F] hover:bg-[#EAE7E2]'
              }`}
              style={{ fontWeight: 500 }}
            >
              Completed ({completedThankYous.length})
            </button>
          </div>

          {/* Pending List */}
          {thankYouTab === 'pending' && (
            <div className="space-y-3">
              {pendingThankYous.length === 0 ? (
                <div className="text-center py-8">
                  <div className="w-16 h-16 bg-[#F0F9FA] rounded-full flex items-center justify-center mx-auto mb-3">
                    <Heart size={28} className="text-[#3A8B95]" />
                  </div>
                  <p className="text-[14px] text-[#2B2B2B]">No pending thank-yous.</p>
                </div>
              ) : pendingThankYous.map((item) => (
                <div key={item.id} className="bg-[#FAFAFA] rounded-[20px] p-4">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <h4 className="text-[14px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                        {item.guestName}
                      </h4>
                      <p className="text-[12px] text-[#6F6F6F]">
                        {item.gift}
                      </p>
                    </div>
                    <div className="px-2.5 py-1 bg-[#FFF5F8] text-[#8B6F47] rounded-full text-[10px] whitespace-nowrap ml-3" style={{ fontWeight: 500 }}>
                      Needs thanks
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => {
                        setSelectedThankYou(item.id);
                        setOpenModal('thank-you');
                      }}
                      className="flex-1 py-2 bg-[#3A8B95] text-white rounded-[16px] text-[12px] hover:bg-[#3A8B95]/90 transition-colors flex items-center justify-center gap-1.5"
                      style={{ fontWeight: 500 }}
                    >
                      <MessageSquare size={14} />
                      Write message
                    </button>
                    <button onClick={() => markThanked(item.id)} className="px-4 py-2 bg-white border border-[#EAE7E2] text-[#6F6F6F] rounded-[16px] text-[12px] hover:bg-[#FAFAFA] transition-colors flex items-center gap-1.5" style={{ fontWeight: 500 }}>
                      <Check size={14} />
                      Mark thanked
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Completed List */}
          {thankYouTab === 'completed' && (
            <>
              {completedThankYous.length > 0 ? (
                <div className="space-y-3">
                  {completedThankYous.map((item) => (
                    <div key={item.id} className="bg-[#F0F9FA] rounded-[20px] p-4">
                      <div className="flex items-start gap-3 mb-2">
                        <CheckCircle size={18} className="text-[#3A8B95] flex-shrink-0 mt-0.5" />
                        <div className="flex-1">
                          <h4 className="text-[14px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                            {item.guestName}
                          </h4>
                          <p className="text-[11px] text-[#6F6F6F] mb-2">
                            Thanked on {item.dateThanked}
                          </p>
                          {item.message && (
                            <p className="text-[12px] text-[#6F6F6F] italic line-clamp-2">
                              &ldquo;{item.message}&rdquo;
                            </p>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <div className="w-16 h-16 bg-[#F0F9FA] rounded-full flex items-center justify-center mx-auto mb-3">
                    <Heart size={28} className="text-[#3A8B95]" />
                  </div>
                  <p className="text-[14px] text-[#2B2B2B]">
                    Every guest has been thanked 💛
                  </p>
                </div>
              )}
            </>
          )}
        </div>

        {/* Smart Reminders */}
        <div className="bg-white rounded-2xl p-6 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
          <div className="mb-5">
            <h3 className="text-[17px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
              Smart reminders
            </h3>
            <p className="text-[13px] text-[#6F6F6F]">
              We will gently remind you when needed
            </p>
          </div>

          <div className="space-y-4">
            {/* Pre-wedding reminder */}
            <div className="bg-[#FAFAFA] rounded-[20px] p-4">
              <div className="flex items-start gap-3 mb-3">
                <Clock size={18} className="text-[#3A8B95] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <p className="text-[13px] text-[#2B2B2B] mb-1">
                    12 guests have not contributed or viewed the registry
                  </p>
                </div>
              </div>
              <button onClick={() => copyText(registryShareUrl, 'Registry link copied for your reminder.')} className="w-full py-2 bg-white border border-[#EAE7E2] text-[#3A8B95] rounded-[16px] text-[12px] hover:bg-[#FAFAFA] transition-colors" style={{ fontWeight: 500 }}>
                Copy registry link
              </button>
            </div>

            {/* Post-wedding reminder */}
            <div className="bg-[#FFF5F8] rounded-[20px] p-4">
              <div className="flex items-start gap-3 mb-3">
                <Sparkles size={18} className="text-[#8B6F47] flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <p className="text-[13px] text-[#2B2B2B] mb-1">
                    {pendingThankYous.length} guests still need a thank-you message
                  </p>
                </div>
              </div>
              <button onClick={() => setThankYouTab('pending')} className="w-full py-2 bg-white border border-[#8B6F47]/30 text-[#8B6F47] rounded-[16px] text-[12px] hover:bg-[#FAFAFA] transition-colors" style={{ fontWeight: 500 }}>
                Review now
              </button>
            </div>

            {/* Settings */}
            <div className="pt-4 border-t border-[#EAE7E2] space-y-3">
              <div className="flex items-center justify-between">
                <label className="text-[13px] text-[#2B2B2B]">Send RSVP-based reminders</label>
                <input type="checkbox" defaultChecked className="w-5 h-5 accent-[#2F5D50]" />
              </div>
              <div className="flex items-center justify-between">
                <label className="text-[13px] text-[#2B2B2B]">Send registry reminders</label>
                <input type="checkbox" defaultChecked className="w-5 h-5 accent-[#2F5D50]" />
              </div>
              <div className="flex items-center justify-between">
                <label className="text-[13px] text-[#2B2B2B]">Remind me to send thank-you messages</label>
                <input type="checkbox" defaultChecked className="w-5 h-5 accent-[#2F5D50]" />
              </div>

              <div className="pt-2">
                <label className="text-[12px] text-[#6F6F6F] block mb-2">Reminder tone</label>
                <select className="w-full px-4 py-2 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[13px] text-[#2B2B2B] focus:outline-none focus:border-[#2F5D50]">
                  <option>Warm</option>
                  <option>Formal</option>
                  <option>Casual</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      {renderModals()}
    </div>
  );

  function renderModals() {
    return (
      <>
        {/* Cash Fund Modal */}
        {openModal === 'cash-fund' && (
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <div
              className="bg-white rounded-2xl max-w-md w-full p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[18px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Create a cash fund
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Fund name
                  </label>
                  <input
                    type="text"
                    placeholder="e.g., Our Honeymoon Fund"
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Description
                  </label>
                  <textarea
                    placeholder="Share what this fund means to you..."
                    rows={3}
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors resize-none"
                  ></textarea>
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Target amount (optional)
                  </label>
                  <input
                    type="number"
                    placeholder="5000"
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <button
                  onClick={addCashFund}
                  disabled={addingItem}
                  className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors disabled:opacity-60"
                  style={{ fontWeight: 500 }}
                >
                  {addingItem ? 'Saving...' : 'Save fund'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Add Link Modal */}
        {openModal === 'add-link' && (
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <div
              className="bg-white rounded-2xl max-w-md w-full p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[18px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Add an item
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Product URL
                  </label>
                  <input
                    type="url"
                    value={linkUrl}
                    onChange={event => setLinkUrl(event.target.value)}
                    placeholder="https://..."
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                  <p className="text-[11px] text-[#6F6F6F] mt-2">
                    Paste a link from Amazon, Target, or any store
                  </p>
                </div>

                <div className="bg-[#FAFAFA] rounded-[20px] p-4">
                  <p className="text-[12px] text-[#6F6F6F] text-center">
                    Preview will appear here
                  </p>
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Note (optional)
                  </label>
                  <input
                    type="text"
                    value={linkNote}
                    onChange={event => setLinkNote(event.target.value)}
                    placeholder="Add a personal note..."
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <button
                  onClick={() => addRegistryItem({
                    name: linkNote || 'Registry item',
                    type: 'item',
                    store_url: linkUrl,
                    description: linkNote || undefined,
                  }).catch(() => {})}
                  disabled={!linkUrl || addingItem}
                  className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors disabled:opacity-60"
                  style={{ fontWeight: 500 }}
                >
                  {addingItem ? 'Saving...' : 'Add item'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Custom Item Modal */}
        {openModal === 'custom-item' && (
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <div
              className="bg-white rounded-2xl max-w-md w-full p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[18px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Add to wishlist
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Item name
                  </label>
                  <input
                    type="text"
                    value={customName}
                    onChange={event => setCustomName(event.target.value)}
                    placeholder="e.g., Kitchen Aid Mixer"
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Price (optional)
                  </label>
                  <input
                    type="text"
                    value={customPrice}
                    onChange={event => setCustomPrice(event.target.value)}
                    placeholder="$299"
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Note (optional)
                  </label>
                  <textarea
                    value={customNote}
                    onChange={event => setCustomNote(event.target.value)}
                    placeholder="Add any details..."
                    rows={3}
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors resize-none"
                  ></textarea>
                </div>

                <button
                  onClick={() => addRegistryItem({
                    name: customName,
                    type: 'item',
                    price: Number(customPrice.replace(/[^0-9.]/g, '')) || undefined,
                    description: customNote || undefined,
                  }).catch(() => {})}
                  disabled={!customName || addingItem}
                  className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors disabled:opacity-60"
                  style={{ fontWeight: 500 }}
                >
                  {addingItem ? 'Saving...' : 'Save item'}
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Share Modal */}
        {openModal === 'share' && (
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <div
              className="bg-white rounded-2xl max-w-md w-full p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[18px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Share your registry
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <p className="text-[13px] text-[#6F6F6F] mb-5">
                Guests can view and gift instantly
              </p>

              <div className="space-y-3">
                <button onClick={() => copyText(registryShareUrl, 'Registry link copied.')} className="w-full flex items-center justify-between p-4 bg-[#FAFAFA] rounded-[20px] hover:bg-[#EAE7E2] transition-colors">
                  <div className="flex items-center gap-3">
                    <Link2 size={20} className="text-[#3A8B95]" />
                    <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                      Copy link
                    </span>
                  </div>
                  <ExternalLink size={16} className="text-[#6F6F6F]" />
                </button>

                <button onClick={() => openShareUrl('whatsapp')} className="w-full flex items-center justify-between p-4 bg-[#FAFAFA] rounded-[20px] hover:bg-[#EAE7E2] transition-colors">
                  <div className="flex items-center gap-3">
                    <MessageSquare size={20} className="text-[#3A8B95]" />
                    <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                      Share via WhatsApp
                    </span>
                  </div>
                  <ExternalLink size={16} className="text-[#6F6F6F]" />
                </button>

                <button onClick={() => openShareUrl('sms')} className="w-full flex items-center justify-between p-4 bg-[#FAFAFA] rounded-[20px] hover:bg-[#EAE7E2] transition-colors">
                  <div className="flex items-center gap-3">
                    <MessageSquare size={20} className="text-[#3A8B95]" />
                    <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                      Share via SMS
                    </span>
                  </div>
                  <ExternalLink size={16} className="text-[#6F6F6F]" />
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Thank You Modal */}
        {openModal === 'thank-you' && (
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <div
              className="bg-white rounded-2xl max-w-md w-full p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[18px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Write thank-you message
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Your message
                  </label>
                  <textarea
                    value={thankYouMessage}
                    onChange={(event) => setThankYouMessage(event.target.value)}
                    placeholder={selectedThankYouItem ? `Thank ${selectedThankYouItem.guestName} for ${selectedThankYouItem.gift}...` : 'Write a thoughtful thank-you message...'}
                    rows={6}
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors resize-none"
                  ></textarea>
                </div>

                <div className="flex gap-3">
                  <button onClick={() => selectedThankYou && markThanked(selectedThankYou)} disabled={!selectedThankYou} className="flex-1 py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors disabled:opacity-60" style={{ fontWeight: 500 }}>
                    Save & mark thanked
                  </button>
                  <button
                    onClick={() => setOpenModal(null)}
                    className="px-5 py-3 bg-[#FAFAFA] text-[#6F6F6F] rounded-[20px] text-[14px] hover:bg-[#EAE7E2] transition-colors"
                    style={{ fontWeight: 500 }}
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Contribute Modal */}
        {openModal === 'contribute' && (
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <div
              className="bg-white rounded-2xl max-w-md w-full p-6"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-[18px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Contribute to fund
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Amount
                  </label>
                  <input
                    type="number"
                    placeholder="50"
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Your name (optional)
                  </label>
                  <input
                    type="text"
                    placeholder="Anonymous"
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                  />
                </div>

                <div>
                  <label className="text-[13px] text-[#2B2B2B] mb-2 block" style={{ fontWeight: 500 }}>
                    Message (optional)
                  </label>
                  <textarea
                    placeholder="Add a personal message..."
                    rows={3}
                    className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors resize-none"
                  ></textarea>
                </div>

                <button onClick={() => copyText(registryShareUrl, 'Registry link copied.')} className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors" style={{ fontWeight: 500 }}>
                  Copy registry link
                </button>
              </div>
            </div>
          </div>
        )}
      </>
    );
  }
}
