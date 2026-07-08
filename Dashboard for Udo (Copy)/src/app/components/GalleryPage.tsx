import { useState } from 'react';
import { Image, Upload, Heart, Archive, Star, Plus, ExternalLink, QrCode, Link2, Check, X, Filter, ChevronDown, Sparkles, Camera, Clock, MapPin } from 'lucide-react';

type GalleryTab = 'inspiration' | 'moments' | 'guest-uploads' | 'saved' | 'archive';
type SavedFilter = 'all' | 'florals' | 'attire' | 'venues' | 'decor';
type ModalType = 'moment' | 'pinterest' | 'share' | 'upload' | null;

export default function GalleryPage() {
  const [activeTab, setActiveTab] = useState<GalleryTab>('inspiration');
  const [savedFilter, setSavedFilter] = useState<SavedFilter>('all');
  const [openModal, setOpenModal] = useState<ModalType>(null);
  const [selectedMoment, setSelectedMoment] = useState<number | null>(null);

  const tabs = [
    { id: 'inspiration' as GalleryTab, label: 'Inspiration' },
    { id: 'moments' as GalleryTab, label: 'Moments' },
    { id: 'guest-uploads' as GalleryTab, label: 'Guest Uploads' },
    { id: 'saved' as GalleryTab, label: 'Saved' },
    { id: 'archive' as GalleryTab, label: 'Archive' },
  ];

  const pinterestBoards = [
    { title: 'Rustic Garden Ceremony', pins: 127, connected: true },
    { title: 'Romantic Florals', pins: 89, connected: true },
    { title: 'Bridal Attire Inspo', pins: 156, connected: false },
  ];

  const moments = [
    { id: 1, title: 'Engagement shoot at the park', date: 'March 15, 2026', photos: 24, location: 'Central Park' },
    { id: 2, title: 'Venue walkthrough', date: 'February 20, 2026', photos: 18, location: 'The Botanical Gardens' },
    { id: 3, title: 'Dress shopping day', date: 'January 12, 2026', photos: 31, location: 'Bella Bridal' },
  ];

  const savedFilterOptions: { id: SavedFilter; label: string }[] = [
    { id: 'all', label: 'All' },
    { id: 'florals', label: 'Florals' },
    { id: 'attire', label: 'Attire' },
    { id: 'venues', label: 'Venues' },
    { id: 'decor', label: 'Decor' },
  ];

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
                            <Image size={20} className="text-[#3A8B95]/40" />
                          </div>
                        ))}
                      </div>
                      <button className="w-full py-2 text-[12px] text-[#3A8B95] border border-[#EAE7E2] rounded-[16px] hover:bg-[#FAFAFA] transition-colors flex items-center justify-center gap-1.5">
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

            {moments.map((moment) => (
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
                  <Camera size={48} className="text-[#3A8B95]/30" />
                </div>

                {/* Content */}
                <div className="p-5">
                  <h3 className="text-[18px] text-[#2B2B2B] mb-2" style={{ fontWeight: 500 }}>
                    {moment.title}
                  </h3>
                  <div className="flex items-center gap-4 text-[12px] text-[#6F6F6F] mb-3">
                    <div className="flex items-center gap-1.5">
                      <Clock size={14} />
                      {moment.date}
                    </div>
                    <div className="flex items-center gap-1.5">
                      <MapPin size={14} />
                      {moment.location}
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Image size={16} className="text-[#3A8B95]" />
                    <span className="text-[13px] text-[#3A8B95]" style={{ fontWeight: 500 }}>
                      {moment.photos} photos
                    </span>
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
                Upload photos from your journey
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
                Let guests upload photos directly to your gallery. They'll be held for your approval.
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
                  12 new
                </div>
              </div>

              <div className="space-y-3">
                {[
                  { name: 'Sarah Martinez', time: '2 min ago', count: 3 },
                  { name: 'James Chen', time: '15 min ago', count: 5 },
                  { name: 'Emma Wilson', time: '1 hour ago', count: 2 },
                  { name: 'Michael Brown', time: '2 hours ago', count: 2 },
                ].map((upload, idx) => (
                  <div key={idx} className="flex items-center gap-3 p-3 bg-[#FAFAFA] rounded-[20px]">
                    <div className="w-16 h-16 bg-gradient-to-br from-[#E8CFCF] to-[#2F5D50]/40 rounded-[16px] flex items-center justify-center flex-shrink-0">
                      <Camera size={24} className="text-white" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-[14px] text-[#2B2B2B]" style={{ fontWeight: 500 }}>{upload.name}</div>
                      <div className="text-[11px] text-[#6F6F6F] mt-0.5">{upload.count} photos • {upload.time}</div>
                    </div>
                    <div className="flex gap-2">
                      <button className="p-2 bg-[#3A8B95] text-white rounded-[16px] hover:bg-[#3A8B95]/90 transition-colors">
                        <Check size={16} />
                      </button>
                      <button className="p-2 bg-white border border-[#EAE7E2] text-[#6F6F6F] rounded-[16px] hover:bg-[#FAFAFA] transition-colors">
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
                Guest photos (47)
              </h3>
              <div className="grid grid-cols-3 gap-2">
                {[...Array(9)].map((_, i) => (
                  <div
                    key={i}
                    className="aspect-square bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[16px] flex items-center justify-center relative cursor-pointer hover:opacity-80 transition-opacity"
                  >
                    <Image size={24} className="text-[#3A8B95]/40" />
                    <button className="absolute top-2 right-2 bg-white/90 backdrop-blur-sm rounded-full p-1.5 shadow-sm hover:bg-white transition-colors">
                      <Heart size={14} className="text-[#3A8B95]" />
                    </button>
                  </div>
                ))}
              </div>
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
                173 images saved
              </p>
            </div>

            {/* Masonry Grid */}
            <div className="columns-2 gap-3 space-y-3">
              {[...Array(12)].map((_, i) => {
                const heights = ['h-48', 'h-64', 'h-56', 'h-72'];
                const randomHeight = heights[i % heights.length];
                return (
                  <div
                    key={i}
                    className={`${randomHeight} bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[20px] flex items-center justify-center relative cursor-pointer hover:opacity-80 transition-opacity break-inside-avoid`}
                  >
                    <Image size={32} className="text-[#3A8B95]/40" />
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
                They'll appear here for easy reference
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
              { stage: 'The Ceremony', date: 'April 15, 2026', count: 147 },
              { stage: 'Cocktail Hour', date: 'April 15, 2026', count: 82 },
              { stage: 'Reception', date: 'April 15, 2026', count: 203 },
              { stage: 'First Dance', date: 'April 15, 2026', count: 54 },
            ].map((group, idx) => (
              <div key={idx} className="bg-white rounded-2xl p-5 shadow-[0_4px_12px_rgba(0,0,0,0.04)] border border-[#EAE7E2]">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-[17px] text-[#2B2B2B]" style={{ fontWeight: 500, fontFamily: 'Playfair Display, serif' }}>
                      {group.stage}
                    </h3>
                    <p className="text-[11px] text-[#6F6F6F] mt-1">{group.date} • {group.count} photos</p>
                  </div>
                  <Archive size={20} className="text-[#3A8B95]" />
                </div>

                <div className="grid grid-cols-3 gap-2 mb-3">
                  {[...Array(6)].map((_, i) => (
                    <div
                      key={i}
                      className="aspect-square bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[16px] flex items-center justify-center cursor-pointer hover:opacity-80 transition-opacity"
                    >
                      <Camera size={20} className="text-[#3A8B95]/40" />
                    </div>
                  ))}
                </div>

                <button className="w-full py-2.5 text-[13px] text-[#3A8B95] border border-[#EAE7E2] rounded-[16px] hover:bg-[#FAFAFA] transition-colors" style={{ fontWeight: 500 }}>
                  View all {group.count} photos
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
              <button className="px-5 py-2.5 bg-white border border-[#2F5D50] rounded-[20px] text-[13px] text-[#3A8B95] hover:bg-[#3A8B95] hover:text-white transition-colors" style={{ fontWeight: 500 }}>
                Browse 284 photos
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
                  {moments.find(m => m.id === selectedMoment)?.title}
                </h3>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 hover:bg-[#FAFAFA] rounded-[16px] transition-colors"
                >
                  <X size={20} className="text-[#6F6F6F]" />
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3">
                {[...Array(8)].map((_, i) => (
                  <div
                    key={i}
                    className="aspect-square bg-gradient-to-br from-[#E8CFCF]/30 to-[#F8F7F4] rounded-[20px] flex items-center justify-center"
                  >
                    <Image size={32} className="text-[#3A8B95]/40" />
                  </div>
                ))}
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
                udo.wedding/upload/sarah-john-2026
              </span>
              <button className="px-3 py-1.5 bg-[#3A8B95] text-white rounded-[16px] text-[11px] hover:bg-[#3A8B95]/90 transition-colors" style={{ fontWeight: 500 }}>
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
              Link your Pinterest account to import your wedding inspiration boards
            </p>

            <button className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors mb-3" style={{ fontWeight: 500 }}>
              Connect with Pinterest
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

              <div className="bg-[#FAFAFA] border-2 border-dashed border-[#EAE7E2] rounded-[20px] p-8 text-center cursor-pointer hover:border-[#2F5D50] transition-colors">
                <Upload size={32} className="text-[#3A8B95] mx-auto mb-3" />
                <p className="text-[13px] text-[#2B2B2B] mb-1" style={{ fontWeight: 500 }}>
                  Upload photos
                </p>
                <p className="text-[11px] text-[#6F6F6F]">
                  Drag and drop or click to browse
                </p>
              </div>

              <button className="w-full py-3 bg-[#3A8B95] text-white rounded-[20px] text-[14px] hover:bg-[#3A8B95]/90 transition-colors" style={{ fontWeight: 500 }}>
                Create moment
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
