'use client';

/* eslint-disable @next/next/no-img-element */

import { useState, useEffect } from 'react';
import { Image as ImageIcon, Upload, Archive, Star, Plus, ExternalLink, QrCode, Link2, Check, X, ChevronDown, Sparkles, Camera, Clock } from 'lucide-react';
import { api } from '@/lib/api';
import { getToken } from '@/lib/auth';

type GalleryTab = 'inspiration' | 'moments' | 'guest-uploads' | 'saved' | 'archive';
type SavedFilter = 'all' | 'florals' | 'attire' | 'venues' | 'decor';
type ModalType = 'moment' | 'pinterest' | 'share' | 'upload' | null;
type GalleryAsset = {
  id: number;
  url: string;
  thumbnail_url?: string | null;
  album: string | null;
  caption?: string | null;
  title?: string;
  approved: boolean;
  is_featured?: boolean;
  is_saved?: boolean;
  source: string;
  created_at: string;
  uploaded_by_guest_id?: number | null;
  uploaded_by_guest_name?: string | null;
};
type GallerySummary = {
  total_assets: number;
  approved_assets: number;
  pending_assets: number;
  featured_assets: number;
  saved_assets: number;
  archived_assets: number;
  albums: {
    inspiration: GalleryAsset[];
    moments: GalleryAsset[];
    guest_uploads_pending: GalleryAsset[];
    guest_uploads_approved: GalleryAsset[];
    saved: GalleryAsset[];
    featured: GalleryAsset[];
    archive: GalleryAsset[];
  };
};

export default function GalleryPage() {
  const [activeTab, setActiveTab] = useState<GalleryTab>('inspiration');
  const [savedFilter, setSavedFilter] = useState<SavedFilter>('all');
  const [openModal, setOpenModal] = useState<ModalType>(null);
  const [selectedMoment, setSelectedMoment] = useState<number | null>(null);
  const [galleryAssets, setGalleryAssets] = useState<GalleryAsset[]>([]);
  const [gallerySummary, setGallerySummary] = useState<GallerySummary | null>(null);
  const [isLoadingGallery, setIsLoadingGallery] = useState(true);
  const [galleryError, setGalleryError] = useState<string | null>(null);
  const [galleryNotice, setGalleryNotice] = useState<string | null>(null);

  const loadGallery = async () => {
    const t = getToken();
    if (!t) {
      setIsLoadingGallery(false);
      return;
    }
    setIsLoadingGallery(true);
    setGalleryError(null);
    try {
      const [assetsRes, summaryRes] = await Promise.all([
        api.get<{ data: GalleryAsset[] }>('/gallery', t),
        api.get<{ data: GallerySummary }>('/gallery/summary', t),
      ]);
      setGalleryAssets(assetsRes.data ?? []);
      setGallerySummary(summaryRes.data ?? null);
    } catch (error) {
      setGalleryError(error instanceof Error ? error.message : 'Could not load gallery.');
    } finally {
      setIsLoadingGallery(false);
    }
  };

  useEffect(() => {
    loadGallery().catch(() => {});
  }, []);

  const approveAsset = async (id: number, approved: boolean) => {
    const t = getToken();
    if (!t) return;
    try {
      const path = approved ? `/gallery/${id}/approve` : `/gallery/${id}/reject`;
      const res = await api.post<{ data: GalleryAsset }>(path, {}, t);
      setGalleryAssets(prev => prev.map(a => a.id === id ? res.data : a));
      setGalleryNotice(approved ? 'Photo approved.' : 'Photo rejected.');
      loadGallery().catch(() => {});
    } catch (error) {
      setGalleryError(error instanceof Error ? error.message : 'Could not update photo.');
    }
  };

  const toggleFeatured = async (asset: GalleryAsset) => {
    const t = getToken();
    if (!t) return;
    try {
      const res = await api.post<{ data: GalleryAsset }>(`/gallery/${asset.id}/feature`, { is_featured: !(asset.is_featured === true) }, t);
      setGalleryAssets(prev => prev.map(a => a.id === asset.id ? res.data : a));
      setGalleryNotice(asset.is_featured ? 'Removed from featured photos.' : 'Marked as featured.');
      loadGallery().catch(() => {});
    } catch (error) {
      setGalleryError(error instanceof Error ? error.message : 'Could not update featured status.');
    }
  };

  const archiveAsset = async (asset: GalleryAsset) => {
    const t = getToken();
    if (!t) return;
    try {
      const res = await api.post<{ data: GalleryAsset }>(`/gallery/${asset.id}/archive`, {}, t);
      setGalleryAssets(prev => prev.map(a => a.id === asset.id ? res.data : a));
      setGalleryNotice('Photo archived.');
      loadGallery().catch(() => {});
    } catch (error) {
      setGalleryError(error instanceof Error ? error.message : 'Could not archive photo.');
    }
  };

  const tabs = [
    { id: 'inspiration' as GalleryTab, label: 'Inspiration' },
    { id: 'moments' as GalleryTab, label: 'Moments' },
    { id: 'guest-uploads' as GalleryTab, label: 'Guest Uploads' },
    { id: 'saved' as GalleryTab, label: 'Saved' },
    { id: 'archive' as GalleryTab, label: 'Archive' },
  ];

  const pinterestBoards = [
    { title: 'Rustic Garden Ceremony', pins: 127, connected: true, url: 'https://www.pinterest.com/search/pins/?q=rustic%20garden%20ceremony' },
    { title: 'Romantic Florals', pins: 89, connected: true, url: 'https://www.pinterest.com/search/pins/?q=romantic%20wedding%20florals' },
    { title: 'Bridal Attire Inspo', pins: 156, connected: false, url: 'https://www.pinterest.com/search/pins/?q=bridal%20attire%20inspiration' },
  ];

  const moments = gallerySummary?.albums.moments ?? galleryAssets.filter(a => a.album === 'moments' && a.approved);
  const pendingUploads = gallerySummary?.albums.guest_uploads_pending ?? galleryAssets.filter(a => a.uploaded_by_guest_id != null && !a.approved);
  const approvedGuestUploads = gallerySummary?.albums.guest_uploads_approved ?? galleryAssets.filter(a => a.uploaded_by_guest_id != null && a.approved);
  const savedAssets = gallerySummary?.albums.saved ?? galleryAssets.filter(a => a.is_saved);
  const archivedAssets = gallerySummary?.albums.archive ?? galleryAssets.filter(a => a.album === 'archive');
  const uploadUrl = typeof window !== 'undefined' ? `${window.location.origin}/guest/upload` : 'https://udo.wedding/guest/upload';
  const selectedMomentAsset = moments.find(m => m.id === selectedMoment);

  const savedFilterOptions: { id: SavedFilter; label: string }[] = [
    { id: 'all', label: 'All' },
    { id: 'florals', label: 'Florals' },
    { id: 'attire', label: 'Attire' },
    { id: 'venues', label: 'Venues' },
    { id: 'decor', label: 'Decor' },
  ];

  const copyText = async (value: string, message: string) => {
    try {
      await navigator.clipboard.writeText(value);
      setGalleryNotice(message);
    } catch {
      setGalleryError('Could not copy the link. Select and copy it manually.');
    }
  };

  const openExternal = (url: string) => {
    window.open(url, '_blank', 'noopener,noreferrer');
  };

  return (
    <div className="min-h-screen bg-[#FAFAFA]">
      {/* Header */}
      <div className="bg-white border-b border-[#EAE7E2] px-4 pt-6 pb-4">
        <h1 className="text-[28px] text-[#3A8B95] mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 500 }}>
          Gallery
        </h1>
        <p className="text-[13px] text-[#6F6F6F] mb-4" style={{ fontStyle: 'italic' }}>
          Every detail, beautifully preserved
        </p>

        {/* Tab Navigation */}
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`px-4 py-2 rounded-full whitespace-nowrap text-[13px] transition-all ${
                activeTab === tab.id
                  ? 'bg-[#3A8B95] text-white'
                  : 'bg-white text-[#6F6F6F] border border-[#EAE7E2] hover:border-[#2F5D50]'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-8">
        {galleryNotice && (
          <div className="max-w-[720px] mx-auto mb-4 rounded-[16px] border border-[#3A8B95]/20 bg-[#F0F9FA] px-4 py-3 text-[13px] text-[#2B2B2B] flex items-center justify-between gap-3">
            <span>{galleryNotice}</span>
            <button onClick={() => setGalleryNotice(null)} className="text-[#3A8B95]" aria-label="Dismiss gallery notice">
              <X size={16} />
            </button>
          </div>
        )}

        {galleryError && (
          <div className="max-w-[720px] mx-auto mb-4 rounded-[16px] border border-[#8B6F47]/20 bg-[#FFF5F8] px-4 py-3 text-[13px] text-[#2B2B2B]">
            <div className="flex items-center justify-between gap-3">
              <span>{galleryError}</span>
              <button onClick={loadGallery} className="text-[#3A8B95]" style={{ fontWeight: 500 }}>
                Retry
              </button>
            </div>
          </div>
        )}

        {isLoadingGallery && (
          <div className="max-w-[720px] mx-auto mb-4 rounded-[16px] border border-[#EAE7E2] bg-white px-4 py-3 text-[13px] text-[#6F6F6F]">
            Loading gallery...
          </div>
        )}

        {/* INSPIRATION TAB */}
        {activeTab === 'inspiration' && (
          <div className="space-y-8">
            <div className="text-center max-w-md mx-auto">
              <p className="text-[14px] text-[#2B2B2B] leading-relaxed" style={{ fontFamily: 'Playfair Display, serif' }}>
                Connect your Pinterest boards to keep all your visual inspiration in one place
              </p>
            </div>

            {/* Pinterest Boards */}
            <div className="space-y-4">
              {pinterestBoards.map((board, idx) => (
                <div key={idx} className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex-1">
                      <h3 className="text-[16px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>{board.title}</h3>
                      <p className="text-[12px] text-[#6F6F6F]">{board.pins} pins</p>
                    </div>
                    {board.connected ? (
                      <div className="flex items-center gap-2 px-3 py-1.5 bg-[#3A8B95]/10 rounded-full">
                        <Check size={14} className="text-[#3A8B95]" />
                        <span className="text-[11px] text-[#3A8B95]" style={{ fontWeight: 500 }}>Connected</span>
                      </div>
                    ) : (
                      <button
                        onClick={() => setOpenModal('pinterest')}
                        className="px-3 py-1.5 bg-white border border-[#2F5D50] rounded-full text-[11px] text-[#3A8B95] hover:bg-[#3A8B95] hover:text-white transition-colors"
                        style={{ fontWeight: 500 }}
                      >
                        Connect
                      </button>
                    )}
                  </div>

                  {board.connected && (
                    <>
                      <div className="grid grid-cols-4 gap-2 mb-3">
                        {[...Array(4)].map((_, i) => (
                          <div
                            key={i}
                            className="aspect-square bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[16px] flex items-center justify-center"
                          >
                            <ImageIcon size={20} className="text-[#3A8B95]/40" />
                          </div>
                        ))}
                      </div>
                      <button onClick={() => openExternal(board.url)} className="w-full py-2 text-[12px] text-[#3A8B95] border border-[#EAE7E2] rounded-[16px] hover:bg-[#FAFAFA] transition-colors flex items-center justify-center gap-1.5">
                        <ExternalLink size={14} />
                        View on Pinterest
                      </button>
                    </>
                  )}
                </div>
              ))}
            </div>

            {/* Add Pinterest Board CTA */}
            <div className="bg-gradient-to-br from-[#E8CFCF]/20 to-white rounded-2xl p-6 border border-[#E8CFCF]/30 text-center">
              <Sparkles size={32} className="text-[#3A8B95] mx-auto mb-3" />
              <h3 className="text-[16px] text-[#2B2B2B] mb-2" style={{ fontWeight: 500 }}>Connect more boards</h3>
              <p className="text-[13px] text-[#6F6F6F] mb-4">
                Import your Pinterest inspiration to share with vendors
              </p>
              <button
                onClick={() => setOpenModal('pinterest')}
                className="px-5 py-2.5 bg-[#3A8B95] text-white rounded-[20px] text-[13px] hover:bg-[#3A8B95]/90 transition-colors"
                style={{ fontWeight: 500 }}
              >
                Link Pinterest account
              </button>
            </div>
          </div>
        )}

        {/* MOMENTS TAB */}
        {activeTab === 'moments' && (
          <div className="max-w-[680px] mx-auto space-y-6">
            <div className="text-center mb-6">
              <p className="text-[14px] text-[#2B2B2B] leading-relaxed" style={{ fontFamily: 'Playfair Display, serif' }}>
                Your journey, moment by moment
              </p>
            </div>

            {moments.length === 0 ? (
              <div className="bg-gradient-to-br from-[#E8CFCF]/20 to-white rounded-2xl p-8 border border-[#E8CFCF]/30 text-center">
                <Camera size={32} className="text-[#3A8B95] mx-auto mb-3" />
                <p className="text-[14px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>No moments yet</p>
                <p className="text-[13px] text-[#6F6F6F]">Upload photos to create your first moment</p>
              </div>
            ) : moments.map((moment) => (
              <div
                key={moment.id}
                onClick={() => {
                  setSelectedMoment(moment.id);
                  setOpenModal('moment');
                }}
                className="bg-white rounded-2xl overflow-hidden shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2] cursor-pointer hover:shadow-[0_6px_16px_rgba(0,0,0,0.08)] transition-all"
              >
                {/* Cover Image */}
                <div className="h-64 bg-gradient-to-br from-[#E8CFCF]/40 to-[#2F5D50]/20 flex items-center justify-center">
                  {moment.thumbnail_url ? (
                    <img src={moment.thumbnail_url} alt={moment.title ?? ''} className="w-full h-full object-cover" />
                  ) : (
                    <Camera size={48} className="text-[#3A8B95]/30" />
                  )}
                </div>

                {/* Content */}
                <div className="p-5">
                  <h3 className="text-[18px] text-[#2B2B2B] mb-2" style={{ fontWeight: 500 }}>
                    {moment.title ?? 'Untitled moment'}
                  </h3>
                  <div className="flex items-center gap-4 text-[12px] text-[#6F6F6F] mb-3">
                    <div className="flex items-center gap-1.5">
                      <Clock size={14} />
                      {new Date(moment.created_at).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                    </div>
                  </div>
                </div>
              </div>
            ))}

            {/* Add Moment CTA */}
            <button
              onClick={() => setOpenModal('upload')}
              className="w-full bg-gradient-to-br from-[#E8CFCF]/20 to-white rounded-2xl p-8 border border-[#E8CFCF]/30 flex flex-col items-center justify-center gap-3 hover:border-[#2F5D50] transition-colors"
            >
              <Plus size={32} className="text-[#3A8B95]" />
              <span className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                Add a new moment
              </span>
              <span className="text-[12px] text-[#6F6F6F]">
                Prepare a named collection for your photos
              </span>
            </button>
          </div>
        )}

        {/* GUEST UPLOADS TAB */}
        {activeTab === 'guest-uploads' && (
          <div className="space-y-8">
            {/* Sharing Section */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-3" style={{ fontWeight: 500 }}>
                Share with your guests
              </h3>
              <p className="text-[13px] text-[#6F6F6F] mb-4">
                Let guests upload photos directly to your gallery. They&apos;ll be held for your approval.
              </p>

              <div className="space-y-3">
                <button
                  onClick={() => setOpenModal('share')}
                  className="w-full flex items-center justify-between p-4 bg-[#FAFAFA] rounded-[20px] hover:bg-[#EAE7E2] transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <QrCode size={24} className="text-[#3A8B95]" />
                    <div className="text-left">
                      <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>Show QR code</div>
                      <div className="text-[11px] text-[#6F6F6F]">Display at your venue</div>
                    </div>
                  </div>
                  <ChevronDown size={20} className="text-[#6F6F6F]" />
                </button>

                <button
                  onClick={() => setOpenModal('share')}
                  className="w-full flex items-center justify-between p-4 bg-[#FAFAFA] rounded-[20px] hover:bg-[#EAE7E2] transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <Link2 size={24} className="text-[#3A8B95]" />
                    <div className="text-left">
                      <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>Copy upload link</div>
                      <div className="text-[11px] text-[#6F6F6F]">Share via text or email</div>
                    </div>
                  </div>
                  <ChevronDown size={20} className="text-[#6F6F6F]" />
                </button>
              </div>
            </div>

            {/* Pending Approval */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-[16px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  Pending approval
                </h3>
                <div className="px-2.5 py-1 bg-[#3A8B95] text-white rounded-full text-[11px]" style={{ fontWeight: 500 }}>
                  {pendingUploads.length} new
                </div>
              </div>

              <div className="space-y-3">
                {pendingUploads.length === 0 ? (
                  <p className="text-[13px] text-[#6F6F6F] text-center py-4">No photos pending approval</p>
                ) : pendingUploads.map((asset) => (
                  <div key={asset.id} className="flex items-center gap-3 p-3 bg-[#FAFAFA] rounded-[20px]">
                    <div className="w-16 h-16 bg-gradient-to-br from-[#E8CFCF] to-[#2F5D50]/40 rounded-[16px] flex items-center justify-center flex-shrink-0 overflow-hidden">
                      {asset.thumbnail_url ? (
                        <img src={asset.thumbnail_url} alt="" className="w-full h-full object-cover" />
                      ) : (
                        <Camera size={24} className="text-white" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>{asset.uploaded_by_guest_name ?? 'Guest'}</div>
                      <div className="text-[11px] text-[#6F6F6F] mt-0.5">{new Date(asset.created_at).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}</div>
                    </div>
                    <div className="flex gap-2">
                      <button onClick={() => approveAsset(asset.id, true)} className="p-2 bg-[#3A8B95] text-white rounded-[16px] hover:bg-[#3A8B95]/90 transition-colors">
                        <Check size={16} />
                      </button>
                      <button onClick={() => approveAsset(asset.id, false)} className="p-2 bg-white border border-[#EAE7E2] text-[#6F6F6F] rounded-[16px] hover:bg-[#FAFAFA] transition-colors">
                        <X size={16} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Approved Gallery */}
            <div className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
              <h3 className="text-[16px] text-[#2B2B2B] mb-4" style={{ fontWeight: 500 }}>
                Guest photos ({approvedGuestUploads.length})
              </h3>
              {approvedGuestUploads.length === 0 ? (
                <p className="text-[13px] text-[#6F6F6F] text-center py-4">Approved guest photos will appear here</p>
              ) : (
                <div className="grid grid-cols-3 gap-2">
                  {approvedGuestUploads.map((asset) => (
                    <div key={asset.id} className="aspect-square bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[16px] flex items-center justify-center relative cursor-pointer hover:opacity-80 transition-opacity overflow-hidden">
                      {asset.thumbnail_url || asset.url ? <img src={asset.thumbnail_url ?? asset.url} alt={asset.caption ?? 'Guest photo'} className="h-full w-full object-cover" /> : <ImageIcon size={24} className="text-[#3A8B95]/40" />}
                      <button onClick={() => toggleFeatured(asset)} className="absolute top-2 right-2 bg-white/90 backdrop-blur-sm rounded-full p-1.5 shadow-sm hover:bg-white transition-colors">
                        <Star size={14} className={asset.is_featured ? 'text-[#3A8B95] fill-[#2F5D50]' : 'text-[#3A8B95]'} />
                      </button>
                      <button onClick={() => archiveAsset(asset)} className="absolute bottom-2 right-2 bg-white/90 backdrop-blur-sm rounded-full p-1.5 shadow-sm hover:bg-white transition-colors">
                        <Archive size={14} className="text-[#3A8B95]" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* SAVED TAB */}
        {activeTab === 'saved' && (
          <div className="space-y-6">
            {/* Filter Pills */}
            <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
              {savedFilterOptions.map((option) => (
                <button
                  key={option.id}
                  onClick={() => setSavedFilter(option.id)}
                  className={`px-4 py-2 rounded-full whitespace-nowrap text-[12px] transition-all ${
                    savedFilter === option.id
                      ? 'bg-[#3A8B95] text-white'
                      : 'bg-white text-[#6F6F6F] border border-[#EAE7E2] hover:border-[#2F5D50]'
                  }`}
                  style={{ fontWeight: 500 }}
                >
                  {option.label}
                </button>
              ))}
            </div>

            <div className="text-center">
              <p className="text-[13px] text-[#6F6F6F]">
                {savedAssets.length} images saved
              </p>
            </div>

            {/* Masonry Grid */}
            <div className="columns-2 gap-3 space-y-3">
              {savedAssets.map((asset, i) => {
                const heights = ['h-48', 'h-64', 'h-56', 'h-72'];
                const randomHeight = heights[i % heights.length];
                return (
                  <div
                    key={asset.id}
                    className={`${randomHeight} bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[20px] flex items-center justify-center relative cursor-pointer hover:opacity-80 transition-opacity break-inside-avoid overflow-hidden`}
                  >
                    {asset.thumbnail_url || asset.url ? <img src={asset.thumbnail_url ?? asset.url} alt={asset.caption ?? 'Saved image'} className="h-full w-full object-cover" /> : <ImageIcon size={32} className="text-[#3A8B95]/40" />}
                    <button className="absolute top-3 right-3 bg-white/90 backdrop-blur-sm rounded-full p-2 shadow-sm hover:bg-white transition-colors">
                      <Star size={16} className="text-[#3A8B95] fill-[#2F5D50]" />
                    </button>
                  </div>
                );
              })}
            </div>

            {/* Empty State Overlay (if needed) */}
            <div className="bg-gradient-to-br from-[#E8CFCF]/20 to-white rounded-2xl p-8 border border-[#E8CFCF]/30 text-center">
              <p className="text-[13px] text-[#6F6F6F] mb-1">
                Save images from Inspiration or Moments
              </p>
              <p className="text-[11px] text-[#6F6F6F]" style={{ fontStyle: 'italic' }}>
                They&apos;ll appear here for easy reference
              </p>
            </div>
          </div>
        )}

        {/* ARCHIVE TAB */}
        {activeTab === 'archive' && (
          <div className="space-y-8">
            <div className="text-center max-w-md mx-auto">
              <p className="text-[14px] text-[#2B2B2B] leading-relaxed mb-2" style={{ fontFamily: 'Playfair Display, serif' }}>
                Your complete story
              </p>
              <p className="text-[12px] text-[#6F6F6F]">
                All photos organized by the moments that mattered most
              </p>
            </div>

            {/* Grouped by Stage */}
            {[
              { stage: 'Archived photos', date: 'Hidden from guest gallery', count: archivedAssets.length },
            ].map((group, idx) => (
              <div key={idx} className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-[17px] text-[#2B2B2B]" style={{ fontWeight: 500, fontFamily: 'Playfair Display, serif' }}>
                      {group.stage}
                    </h3>
                    <p className="text-[11px] text-[#6F6F6F] mt-1">{group.date} - {group.count} photos</p>
                  </div>
                  <Archive size={20} className="text-[#3A8B95]" />
                </div>

                {archivedAssets.length > 0 ? (
                  <div className="grid grid-cols-3 gap-2 mb-3">
                    {archivedAssets.slice(0, 6).map((asset) => (
                      <div
                        key={asset.id}
                        className="aspect-square bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[16px] flex items-center justify-center cursor-pointer hover:opacity-80 transition-opacity overflow-hidden"
                      >
                        {asset.thumbnail_url || asset.url ? <img src={asset.thumbnail_url ?? asset.url} alt={asset.caption ?? 'Archived photo'} className="h-full w-full object-cover" /> : <Camera size={20} className="text-[#3A8B95]/40" />}
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-[13px] text-[#6F6F6F] text-center py-4">Archived photos will appear here.</p>
                )}

                <button
                  onClick={() => setActiveTab('guest-uploads')}
                  className="w-full py-2.5 text-[13px] text-[#3A8B95] border border-[#EAE7E2] rounded-[16px] hover:bg-[#FAFAFA] transition-colors"
                  style={{ fontWeight: 500 }}
                >
                  Manage guest photos
                </button>
              </div>
            ))}

            {/* Pre-Wedding Archive */}
            <div className="bg-gradient-to-br from-[#E8CFCF]/20 to-white rounded-2xl p-6 border border-[#E8CFCF]/30">
              <h3 className="text-[16px] text-[#2B2B2B] mb-3 flex items-center gap-2" style={{ fontWeight: 500 }}>
                <Sparkles size={18} className="text-[#3A8B95]" />
                Pre-wedding journey
              </h3>
              <p className="text-[13px] text-[#6F6F6F] mb-4">
                All your planning moments, engagement photos, and pre-wedding celebrations
              </p>
              <button onClick={() => setActiveTab('moments')} className="px-5 py-2.5 bg-white border border-[#2F5D50] rounded-[20px] text-[13px] text-[#3A8B95] hover:bg-[#3A8B95] hover:text-white transition-colors" style={{ fontWeight: 500 }}>
                Browse moments
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Modals */}
      {openModal === 'moment' && (
        <div
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={() => setOpenModal(null)}
        >
          <div
            className="bg-white rounded-2xl max-w-2xl w-full max-h-[80vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-[20px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>
                  {selectedMomentAsset?.title ?? 'Moment'}
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="rounded-[20px] bg-[#FAFAFA] overflow-hidden">
                {selectedMomentAsset?.thumbnail_url || selectedMomentAsset?.url ? (
                  <img src={selectedMomentAsset.thumbnail_url ?? selectedMomentAsset.url} alt={selectedMomentAsset.caption ?? selectedMomentAsset.title ?? 'Moment photo'} className="w-full max-h-[60vh] object-cover" />
                ) : (
                  <div className="aspect-square flex items-center justify-center">
                    <ImageIcon size={32} className="text-[#3A8B95]/40" />
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

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
                Share upload link
              </h3>
              <button
                onClick={() => setOpenModal(null)}
                className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
              >
                <X size={20} className="text-[#6F6F6F]" />
              </button>
            </div>

            <div className="bg-[#FAFAFA] rounded-[20px] p-8 mb-4 flex items-center justify-center">
              <QrCode size={120} className="text-[#3A8B95]" />
            </div>

            <div className="bg-[#FAFAFA] rounded-[16px] p-3 mb-4 flex items-center justify-between">
              <span className="text-[12px] text-[#6F6F6F] truncate">
                {uploadUrl}
              </span>
              <button onClick={() => copyText(uploadUrl, 'Guest upload link copied.')} className="px-3 py-1.5 bg-[#3A8B95] text-white rounded-[16px] text-[11px] hover:bg-[#3A8B95]/90 transition-colors" style={{ fontWeight: 500 }}>
                Copy
              </button>
            </div>

            <p className="text-[12px] text-[#6F6F6F] text-center">
              Guests can scan the QR code or use the link to upload photos
            </p>
          </div>
        </div>
      )}

      {openModal === 'pinterest' && (
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
                Connect Pinterest
              </h3>
              <button
                onClick={() => setOpenModal(null)}
                className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
              >
                <X size={20} className="text-[#6F6F6F]" />
              </button>
            </div>

            <p className="text-[13px] text-[#6F6F6F] mb-6">
              Pinterest import needs OAuth before it can sync boards into UDO. You can still open Pinterest inspiration in a new tab.
            </p>

            <button onClick={() => openExternal('https://www.pinterest.com/search/pins/?q=wedding%20inspiration')} className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors mb-3" style={{ fontWeight: 500 }}>
              Open Pinterest inspiration
            </button>

            <button
              onClick={() => setOpenModal(null)}
              className="w-full py-3 text-[#6F6F6F] text-[13px]"
            >
              Maybe later
            </button>
          </div>
        </div>
      )}

      {openModal === 'upload' && (
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
                Add a moment
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
                  Moment title
                </label>
                <input
                  type="text"
                  placeholder="e.g., Rehearsal dinner"
                  className="w-full px-4 py-3 bg-[#FAFAFA] border border-[#EAE7E2] rounded-[16px] text-[14px] focus:outline-none focus:border-[#2F5D50] transition-colors"
                />
              </div>

              <div className="bg-[#FAFAFA] border-2 border-dashed border-[#EAE7E2] rounded-[20px] p-8 text-center">
                <Upload size={32} className="text-[#3A8B95] mx-auto mb-3" />
                <p className="text-[13px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                  Upload endpoint required
                </p>
                <p className="text-[11px] text-[#6F6F6F]">
                  Use the guest upload link for now. Direct organizer upload is queued for backend support.
                </p>
              </div>

              <button onClick={() => copyText(uploadUrl, 'Guest upload link copied.')} className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors" style={{ fontWeight: 500 }}>
                Copy upload link
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
