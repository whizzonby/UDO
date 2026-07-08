import { useState } from 'react';
import { Send, Plus, Heart, Sparkles, Lock, Eye, Image as ImageIcon, Pin, CheckCircle, Clock, Users, Calendar, AlertCircle, Plane, Mail, Link2, MessageCircle, QrCode, Share2, ExternalLink, Copy } from 'lucide-react';

interface WeddingWallProps {
  onShowComposeMessage: () => void;
  onShowReminderModal: () => void;
}

interface GuestNote {
  id: string;
  guestName: string;
  message: string;
  timestamp: string;
  avatar: string;
  hasPhoto?: boolean;
  isPinned?: boolean;
  isApproved: boolean;
  rsvpStatus: 'attending' | 'pending';
}

type PostingStyle = 'public' | 'private' | 'capsule';

export default function WeddingWall({ onShowComposeMessage, onShowReminderModal }: WeddingWallProps) {
  const [showNoteComposer, setShowNoteComposer] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [showGuestPreview, setShowGuestPreview] = useState(false);
  const [showShareModal, setShowShareModal] = useState(false);
  const [postingStyle, setPostingStyle] = useState<PostingStyle>('public');
  const [wallSettings, setWallSettings] = useState({
    requireApproval: true,
    allowPhotos: true,
    allowAnonymous: false,
    openAfterWedding: false,
  });

  const wallUrl = 'udo.app/wall/olivia-aaron';

  const copyToClipboard = () => {
    navigator.clipboard.writeText(`https://${wallUrl}`);
    alert('Link copied to clipboard!');
  };

  const guestNotes: GuestNote[] = [
    {
      id: '1',
      guestName: 'Jessica M.',
      message: 'So excited to celebrate with you both! Wishing you all the love and happiness in the world. Your love story has been such an inspiration.',
      timestamp: '2 hours ago',
      avatar: 'JM',
      isPinned: true,
      isApproved: true,
      rsvpStatus: 'attending',
    },
    {
      id: '2',
      guestName: 'Thomas & Sarah R.',
      message: 'Congratulations! We cannot wait for this beautiful day. Thank you for including us in your celebration of love.',
      timestamp: '5 hours ago',
      avatar: 'T&S',
      hasPhoto: true,
      isApproved: true,
      rsvpStatus: 'attending',
    },
    {
      id: '3',
      guestName: 'Maria G.',
      message: 'Sending love and blessings from our family to yours. May your journey together be filled with endless joy and laughter.',
      timestamp: '1 day ago',
      avatar: 'MG',
      isApproved: true,
      rsvpStatus: 'attending',
    },
    {
      id: '4',
      guestName: 'David & Emma P.',
      message: 'Best wishes for a lifetime of happiness together! We feel so honored to be part of your special day.',
      timestamp: '1 day ago',
      avatar: 'D&E',
      isApproved: false,
      rsvpStatus: 'pending',
    },
  ];

  const approvedNotes = guestNotes.filter(note => note.isApproved);
  const pendingNotes = guestNotes.filter(note => !note.isApproved);

  return (
    <div className="space-y-8">
      {/* Page intro - Split purpose */}
      <div className="grid md:grid-cols-2 gap-6">
        {/* Guest Communication Section */}
        <div className="p-6 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[32px] border border-[#3A8B95]/20">
          <div className="flex items-center gap-2 mb-2">
            <Send size={20} className="text-[#3A8B95]" />
            <h3 className="text-[18px] font-semibold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>
              Guest Communication
            </h3>
          </div>
          <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
            Send updates, reminders, and important details to your guests
          </p>
          <button
            onClick={onShowComposeMessage}
            className="w-full py-3 bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] text-white rounded-full text-[14px] font-medium hover:shadow-lg transition-all flex items-center justify-center gap-2"
          >
            <Plus size={16} />
            Compose Message
          </button>
        </div>

        {/* Wedding Wall Section */}
        <div className="p-6 bg-gradient-to-br from-[#FFF5F8] to-white rounded-[32px] border border-[#FF88BA]/20">
          <div className="flex items-center gap-2 mb-2">
            <Heart size={20} className="text-[#FF3E9B]" fill="#FF3E9B" />
            <h3 className="text-[18px] font-semibold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>
              Wedding Wall
            </h3>
          </div>
          <p className="text-[13px] text-gray-600 mb-4" style={{ lineHeight: 1.6 }}>
            Heartfelt messages and wishes from your loved ones
          </p>
          <div className="flex gap-2">
            <button className="flex-1 py-3 border-2 border-[#FF3E9B] text-[#FF3E9B] rounded-full text-[14px] font-medium hover:bg-[#FF3E9B] hover:text-white transition-all flex items-center justify-center gap-2">
              <Eye size={16} />
              View Wall
            </button>
            <button
              onClick={() => setShowSettings(true)}
              className="px-4 py-3 border-2 border-gray-200 text-gray-700 rounded-full text-[14px] font-medium hover:bg-gray-50 transition-all"
            >
              <Sparkles size={16} />
            </button>
          </div>
        </div>
      </div>

      {/* Smart Alerts - Guest Communication */}
      <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
        <h3 className="text-[20px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Smart Alerts
        </h3>
        <p className="text-[14px] text-gray-600 mb-6" style={{ lineHeight: 1.6 }}>
          Take action based on guest status and needs
        </p>

        <div className="space-y-3">
          {[
            { count: 18, text: 'guests have not RSVP\'d', action: 'Send reminder', icon: AlertCircle, color: '#FF3E9B', onClick: onShowReminderModal },
            { count: 12, text: 'travelling guests need hotel details', action: 'Send travel info', icon: Plane, color: '#3A8B95', onClick: onShowComposeMessage },
            { count: 7, text: 'guests missing meal choices', action: 'Request meals', icon: Users, color: '#FF88BA', onClick: onShowComposeMessage },
            { count: 0, text: 'Wedding party schedule updated', action: 'Notify party', icon: Calendar, color: '#66D0BC', onClick: onShowComposeMessage },
          ].map((alert, index) => (
            <div
              key={index}
              className="flex items-center justify-between p-5 bg-gradient-to-r from-[#FAFAFA] to-white rounded-[24px] border border-gray-100 hover:border-gray-200 hover:shadow-md transition-all group"
            >
              <div className="flex items-center gap-4 flex-1">
                <div
                  className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0"
                  style={{ backgroundColor: `${alert.color}15` }}
                >
                  <alert.icon size={20} style={{ color: alert.color }} />
                </div>
                <div className="flex-1">
                  <div className="text-[15px] text-gray-800">
                    {alert.count > 0 && <span className="font-semibold" style={{ color: alert.color }}>{alert.count} </span>}
                    {alert.text}
                  </div>
                </div>
              </div>
              <button
                onClick={alert.onClick}
                className="px-5 py-2.5 rounded-full text-[13px] font-medium transition-all opacity-0 group-hover:opacity-100"
                style={{ backgroundColor: alert.color, color: 'white' }}
              >
                {alert.action}
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Audience Messaging */}
      <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
        <h3 className="text-[20px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Message by Audience
        </h3>
        <p className="text-[14px] text-gray-600 mb-6" style={{ lineHeight: 1.6 }}>
          Send targeted messages to specific guest groups
        </p>

        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {[
            { label: 'All guests', count: 120, color: '#3A8B95' },
            { label: 'Pending RSVP', count: 18, color: '#FFB020' },
            { label: 'Wedding party', count: 8, color: '#FF3E9B' },
            { label: 'Travelling guests', count: 32, color: '#FF88BA' },
            { label: 'Family', count: 24, color: '#66D0BC' },
            { label: 'Friends', count: 64, color: '#A0C4FF' },
          ].map((segment, index) => (
            <button
              key={index}
              onClick={onShowComposeMessage}
              className="px-5 py-3 rounded-full text-[13px] font-medium transition-all flex-shrink-0 whitespace-nowrap border-2 hover:shadow-md"
              style={{
                backgroundColor: `${segment.color}10`,
                borderColor: `${segment.color}30`,
                color: segment.color,
              }}
            >
              {segment.label}
              <span className="ml-2 opacity-70">({segment.count})</span>
            </button>
          ))}
        </div>
      </div>

      {/* Floral divider */}
      <div className="flex items-center justify-center gap-3 my-8">
        <div className="h-px w-16 bg-gradient-to-r from-transparent to-[#FF88BA]" />
        <Heart size={14} className="text-[#FF88BA]" fill="#FF88BA" />
        <div className="h-px w-16 bg-gradient-to-l from-transparent to-[#FF88BA]" />
      </div>

      {/* Guest Posting Access - THE KEY SECTION */}
      <div className="bg-gradient-to-br from-white via-[#FEFDFB] to-[#FFF5F8] rounded-[40px] p-10 shadow-xl border-2 border-[#FF88BA]/20">
        <div className="text-center mb-8">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-white rounded-full mb-4 shadow-sm">
            <Share2 size={14} className="text-[#FF3E9B]" />
            <span className="text-[12px] font-medium text-[#FF3E9B]">Share with guests</span>
          </div>
          <h2 className="text-[32px] leading-tight mb-3" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            Guest Posting Access
          </h2>
          <p className="text-[15px] text-gray-600 max-w-xl mx-auto" style={{ lineHeight: 1.7 }}>
            Allow guests to leave heartfelt messages without downloading the app
          </p>
        </div>

        {/* Posting Style Selector */}
        <div className="mb-8">
          <div className="text-[15px] font-semibold text-gray-900 mb-4 text-center">Choose posting style</div>
          <div className="grid md:grid-cols-3 gap-4">
            {[
              {
                id: 'public' as PostingStyle,
                icon: '🌐',
                title: 'Public Wall',
                description: 'Everyone sees messages in real-time',
                recommended: true,
              },
              {
                id: 'private' as PostingStyle,
                icon: '🔒',
                title: 'Private Notes',
                description: 'Only you see guest messages',
                recommended: false,
              },
              {
                id: 'capsule' as PostingStyle,
                icon: '✨',
                title: 'Time Capsule',
                description: 'Unlock after your wedding',
                recommended: false,
              },
            ].map((style) => (
              <button
                key={style.id}
                onClick={() => setPostingStyle(style.id)}
                className={`p-5 rounded-[24px] border-2 transition-all text-left ${
                  postingStyle === style.id
                    ? 'bg-gradient-to-br from-[#FFF5F8] to-white border-[#FF3E9B] shadow-lg'
                    : 'bg-white border-gray-200 hover:border-[#FF88BA]'
                }`}
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="text-[32px]">{style.icon}</div>
                  {style.recommended && postingStyle === style.id && (
                    <div className="px-2 py-1 bg-[#FF3E9B] text-white rounded-full text-[10px] font-medium">
                      Active
                    </div>
                  )}
                </div>
                <div className="text-[15px] font-semibold text-gray-900 mb-2">{style.title}</div>
                <div className="text-[12px] text-gray-600 leading-relaxed">{style.description}</div>
              </button>
            ))}
          </div>
        </div>

        {/* Public Link */}
        <div className="bg-white rounded-[24px] p-6 border border-gray-100 mb-6">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Link2 size={18} className="text-[#3A8B95]" />
              <span className="text-[15px] font-semibold text-gray-900">Public Wall Link</span>
            </div>
            <div className="flex items-center gap-2 text-[11px] text-gray-500">
              <Eye size={12} />
              <span>No app required</span>
            </div>
          </div>

          <div className="flex gap-2">
            <div className="flex-1 px-4 py-3 bg-gray-50 rounded-[16px] border border-gray-200 text-[14px] text-gray-700 font-mono overflow-x-auto">
              {wallUrl}
            </div>
            <button
              onClick={copyToClipboard}
              className="px-5 py-3 bg-[#3A8B95] text-white rounded-[16px] text-[13px] font-medium hover:bg-[#2d6f78] transition-all flex items-center gap-2 flex-shrink-0"
            >
              <Copy size={16} />
              Copy
            </button>
          </div>
        </div>

        {/* Share Options */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
          <button
            onClick={() => setShowShareModal(true)}
            className="p-4 bg-white rounded-[20px] border border-gray-200 hover:border-[#25D366] hover:shadow-md transition-all text-center group"
          >
            <div className="w-12 h-12 mx-auto mb-3 rounded-full bg-[#25D366]/10 flex items-center justify-center group-hover:bg-[#25D366]/20 transition-all">
              <MessageCircle size={20} className="text-[#25D366]" />
            </div>
            <div className="text-[13px] font-medium text-gray-900">WhatsApp</div>
            <div className="text-[11px] text-gray-500">Share link</div>
          </button>

          <button
            onClick={() => setShowShareModal(true)}
            className="p-4 bg-white rounded-[20px] border border-gray-200 hover:border-[#FF3E9B] hover:shadow-md transition-all text-center group"
          >
            <div className="w-12 h-12 mx-auto mb-3 rounded-full bg-[#FF3E9B]/10 flex items-center justify-center group-hover:bg-[#FF3E9B]/20 transition-all">
              <Mail size={20} className="text-[#FF3E9B]" />
            </div>
            <div className="text-[13px] font-medium text-gray-900">Email</div>
            <div className="text-[11px] text-gray-500">Send invite</div>
          </button>

          <button
            onClick={() => setShowShareModal(true)}
            className="p-4 bg-white rounded-[20px] border border-gray-200 hover:border-[#3A8B95] hover:shadow-md transition-all text-center group"
          >
            <div className="w-12 h-12 mx-auto mb-3 rounded-full bg-[#3A8B95]/10 flex items-center justify-center group-hover:bg-[#3A8B95]/20 transition-all">
              <QrCode size={20} className="text-[#3A8B95]" />
            </div>
            <div className="text-[13px] font-medium text-gray-900">QR Code</div>
            <div className="text-[11px] text-gray-500">Print ready</div>
          </button>

          <button
            onClick={() => setShowGuestPreview(true)}
            className="p-4 bg-gradient-to-br from-[#F0F9FA] to-white rounded-[20px] border border-[#3A8B95]/30 hover:shadow-md transition-all text-center group"
          >
            <div className="w-12 h-12 mx-auto mb-3 rounded-full bg-[#3A8B95]/10 flex items-center justify-center group-hover:bg-[#3A8B95]/20 transition-all">
              <Eye size={20} className="text-[#3A8B95]" />
            </div>
            <div className="text-[13px] font-medium text-gray-900">Preview</div>
            <div className="text-[11px] text-gray-500">Guest view</div>
          </button>
        </div>

        {/* Usage Tips */}
        <div className="p-5 bg-white rounded-[20px] border border-gray-100">
          <div className="text-[13px] font-medium text-gray-900 mb-3">💡 Share at your wedding</div>
          <div className="space-y-2 text-[12px] text-gray-600">
            <div className="flex items-center gap-2">
              <div className="w-1 h-1 rounded-full bg-[#3A8B95]" />
              <span>Add QR code to reception tables</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-1 h-1 rounded-full bg-[#3A8B95]" />
              <span>Include link in wedding programs</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-1 h-1 rounded-full bg-[#3A8B95]" />
              <span>Display on welcome signs</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-1 h-1 rounded-full bg-[#FF3E9B]" />
              <span className="font-medium">Guests post messages live during your celebration!</span>
            </div>
          </div>
        </div>
      </div>

      {/* Wedding Wall - Luxury Digital Guestbook */}
      <div className="bg-gradient-to-br from-white via-[#FEFDFB] to-[#FFF5F8] rounded-[40px] p-12 shadow-2xl border border-gray-100">
        <div className="text-center mb-8">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-[#FF3E9B]/10 rounded-full mb-4">
            <Heart size={14} className="text-[#FF3E9B]" fill="#FF3E9B" />
            <span className="text-[12px] font-medium text-[#FF3E9B]">
              {approvedNotes.length} messages of love
            </span>
          </div>
          <h2 className="text-[36px] leading-tight mb-3" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            Wedding Wall
          </h2>
          <p className="text-[15px] text-gray-600 italic max-w-xl mx-auto" style={{ lineHeight: 1.7 }}>
            Heartfelt wishes and cherished memories from your loved ones
          </p>
        </div>

        {/* Wall Settings Banner */}
        {wallSettings.openAfterWedding && (
          <div className="mb-8 p-6 bg-gradient-to-r from-[#F0F9FA] to-[#FFF5F8] rounded-[24px] border border-[#3A8B95]/20">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center flex-shrink-0">
                <Lock size={18} className="text-[#3A8B95]" />
              </div>
              <div className="flex-1">
                <div className="text-[15px] font-semibold text-gray-900 mb-1">Wedding Time Capsule</div>
                <div className="text-[13px] text-gray-600 leading-relaxed">
                  Guest messages will unlock after your wedding day. Your loved ones are leaving wishes for you to treasure forever.
                </div>
              </div>
              <Sparkles size={20} className="text-[#FFB020] flex-shrink-0" />
            </div>
          </div>
        )}

        {/* Pending Approval */}
        {pendingNotes.length > 0 && (
          <div className="mb-6 p-4 bg-[#FFB020]/10 rounded-[20px] border border-[#FFB020]/20">
            <div className="flex items-center gap-2">
              <Clock size={16} className="text-[#FFB020]" />
              <span className="text-[13px] font-medium text-gray-800">
                {pendingNotes.length} message{pendingNotes.length > 1 ? 's' : ''} awaiting your approval
              </span>
              <button className="ml-auto text-[12px] text-[#FFB020] font-medium hover:underline">
                Review
              </button>
            </div>
          </div>
        )}

        {/* Guest Notes - Instagram-story-ish floating cards */}
        <div className="space-y-4">
          {approvedNotes.map((note, idx) => (
            <div
              key={note.id}
              className={`relative p-6 rounded-[24px] transition-all hover:shadow-xl hover:-translate-y-1 ${
                note.isPinned
                  ? 'bg-gradient-to-br from-[#FFF5F8] to-white border-2 border-[#FF3E9B]/30'
                  : 'bg-white border border-gray-100'
              }`}
            >
              {/* Pinned badge */}
              {note.isPinned && (
                <div className="absolute top-4 right-4">
                  <div className="flex items-center gap-1 px-2 py-1 bg-[#FF3E9B] text-white rounded-full text-[10px] font-medium">
                    <Pin size={10} />
                    Pinned
                  </div>
                </div>
              )}

              <div className="flex items-start gap-4">
                {/* Avatar with gradient */}
                <div
                  className="w-14 h-14 rounded-full flex items-center justify-center text-[15px] font-semibold text-white flex-shrink-0 shadow-md"
                  style={{
                    background: `linear-gradient(135deg, ${
                      idx % 3 === 0 ? '#FF3E9B, #FF88BA' :
                      idx % 3 === 1 ? '#3A8B95, #66D0BC' :
                      '#FF88BA, #FFB3D6'
                    })`
                  }}
                >
                  {note.avatar}
                </div>

                <div className="flex-1 min-w-0">
                  {/* Header */}
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <div className="text-[16px] font-semibold text-gray-900">{note.guestName}</div>
                      <div className="text-[12px] text-gray-500">{note.timestamp}</div>
                    </div>
                  </div>

                  {/* Message - with handwriting feel */}
                  <div className="relative">
                    <p
                      className="text-[15px] text-gray-700 leading-relaxed mb-3"
                      style={{ fontFamily: 'Georgia, serif', fontStyle: 'italic' }}
                    >
                      "{note.message}"
                    </p>

                    {/* Photo attachment */}
                    {note.hasPhoto && (
                      <div className="mt-4 inline-flex items-center gap-2 px-3 py-2 bg-gray-50 rounded-full text-[12px] text-gray-600">
                        <ImageIcon size={14} />
                        <span>Photo attached</span>
                      </div>
                    )}
                  </div>

                  {/* Decorative elements */}
                  <div className="flex items-center gap-2 mt-4 pt-4 border-t border-gray-100">
                    <Heart size={14} className="text-[#FF88BA]" />
                    <Heart size={14} className="text-[#FF88BA]" />
                    <Heart size={14} className="text-[#FF88BA]" />
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* View more */}
        {approvedNotes.length > 3 && (
          <div className="text-center mt-8">
            <button className="px-8 py-3 border-2 border-[#FF88BA] text-[#FF3E9B] rounded-full text-[14px] font-medium hover:bg-[#FF3E9B] hover:text-white transition-all">
              View all {approvedNotes.length} messages
            </button>
          </div>
        )}

        {/* Empty state */}
        {approvedNotes.length === 0 && (
          <div className="text-center py-12">
            <div className="text-[48px] mb-4">💌</div>
            <div className="text-[18px] font-semibold text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif' }}>
              Your Wedding Wall awaits
            </div>
            <div className="text-[14px] text-gray-600 max-w-md mx-auto">
              As your guests RSVP, they'll be able to leave heartfelt messages and wishes for your special day.
            </div>
          </div>
        )}
      </div>

      {/* Wall Controls */}
      <div className="bg-white rounded-[32px] shadow-sm border border-gray-100 p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-[20px] text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
              Wall Settings
            </h3>
            <p className="text-[13px] text-gray-600">Control how guests interact with your Wedding Wall</p>
          </div>
        </div>

        <div className="space-y-4">
          {[
            {
              id: 'requireApproval',
              label: 'Approve before posting',
              description: 'Review messages before they appear on your wall',
              icon: CheckCircle,
              enabled: wallSettings.requireApproval,
            },
            {
              id: 'allowPhotos',
              label: 'Allow photo attachments',
              description: 'Guests can attach a photo with their message',
              icon: ImageIcon,
              enabled: wallSettings.allowPhotos,
            },
            {
              id: 'allowAnonymous',
              label: 'Allow anonymous notes',
              description: 'Guests can leave messages without their name',
              icon: Eye,
              enabled: wallSettings.allowAnonymous,
            },
            {
              id: 'openAfterWedding',
              label: '✨ Wedding Time Capsule',
              description: 'Lock messages until after your wedding day',
              icon: Lock,
              enabled: wallSettings.openAfterWedding,
              premium: true,
            },
          ].map((setting) => {
            const Icon = setting.icon;
            return (
              <div
                key={setting.id}
                className={`flex items-center justify-between p-5 rounded-[20px] border-2 transition-all ${
                  setting.enabled
                    ? 'bg-gradient-to-r from-[#F0F9FA] to-white border-[#3A8B95]/30'
                    : 'bg-white border-gray-200'
                } ${setting.premium ? 'border-[#FFB020]/30 bg-gradient-to-r from-[#FFFBF0] to-white' : ''}`}
              >
                <div className="flex items-start gap-4 flex-1">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 ${
                      setting.enabled ? 'bg-[#3A8B95]/10' : 'bg-gray-100'
                    } ${setting.premium ? 'bg-[#FFB020]/10' : ''}`}
                  >
                    <Icon
                      size={20}
                      className={setting.enabled ? 'text-[#3A8B95]' : 'text-gray-400'}
                      style={setting.premium ? { color: '#FFB020' } : {}}
                    />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="text-[15px] font-medium text-gray-900">{setting.label}</div>
                      {setting.premium && (
                        <div className="px-2 py-0.5 bg-[#FFB020] text-white rounded-full text-[10px] font-medium">
                          Premium
                        </div>
                      )}
                    </div>
                    <div className="text-[13px] text-gray-600">{setting.description}</div>
                  </div>
                </div>
                <button
                  onClick={() => setWallSettings({ ...wallSettings, [setting.id]: !setting.enabled })}
                  className={`w-14 h-8 rounded-full transition-all flex-shrink-0 ${
                    setting.enabled ? 'bg-[#3A8B95]' : 'bg-gray-200'
                  } ${setting.premium && setting.enabled ? 'bg-[#FFB020]' : ''}`}
                >
                  <div
                    className={`w-6 h-6 bg-white rounded-full shadow-md transition-transform ${
                      setting.enabled ? 'translate-x-7' : 'translate-x-1'
                    }`}
                  />
                </button>
              </div>
            );
          })}
        </div>
      </div>

      {/* Romantic closing */}
      <div className="text-center pt-6 border-t border-gray-100">
        <p className="text-[13px] text-gray-500 italic">
          Every message is a cherished memory in the making
        </p>
      </div>

      {/* Guest Preview Modal */}
      {showGuestPreview && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-[32px] max-w-md w-full max-h-[90vh] overflow-y-auto">
            {/* Modal header */}
            <div className="sticky top-0 bg-white rounded-t-[32px] p-6 border-b border-gray-100 z-10">
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-[20px] font-semibold text-gray-900 mb-1" style={{ fontFamily: 'Playfair Display, serif' }}>
                    Guest Experience
                  </div>
                  <div className="text-[13px] text-gray-600">What your guests will see</div>
                </div>
                <button
                  onClick={() => setShowGuestPreview(false)}
                  className="w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
                >
                  <span className="text-[20px] text-gray-600">×</span>
                </button>
              </div>
            </div>

            {/* Guest view simulation */}
            <div className="p-6">
              {/* Header */}
              <div className="text-center mb-8">
                <div className="text-[28px] leading-tight mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600, background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                  Olivia & Aaron
                </div>
                <div className="text-[14px] text-gray-600 mb-4">Saturday, June 15th, 2026</div>
                <div className="flex items-center justify-center gap-2 text-[13px] text-gray-500">
                  <Heart size={14} className="text-[#FF88BA]" fill="#FF88BA" />
                  <span>Leave a message for the couple</span>
                </div>
              </div>

              {/* Message form - lightweight */}
              <div className="space-y-4">
                <div>
                  <label className="block text-[13px] font-medium text-gray-700 mb-2">Your name</label>
                  <input
                    type="text"
                    placeholder="Jessica Martinez"
                    className="w-full px-4 py-3 bg-white border border-gray-200 rounded-[16px] text-[14px] focus:outline-none focus:ring-2 focus:ring-[#FF3E9B]/20 focus:border-[#FF3E9B]"
                  />
                </div>

                <div>
                  <label className="block text-[13px] font-medium text-gray-700 mb-2">Your message</label>
                  <textarea
                    placeholder="Share your excitement, wishes, or favorite memories..."
                    rows={4}
                    className="w-full px-4 py-3 bg-white border border-gray-200 rounded-[16px] text-[14px] focus:outline-none focus:ring-2 focus:ring-[#FF3E9B]/20 focus:border-[#FF3E9B] resize-none"
                    style={{ fontFamily: 'Georgia, serif', fontStyle: 'italic' }}
                  />
                </div>

                {wallSettings.allowPhotos && (
                  <button className="w-full py-3 border-2 border-dashed border-gray-300 rounded-[16px] text-[13px] text-gray-600 hover:border-[#FF88BA] hover:bg-gray-50 transition-all flex items-center justify-center gap-2">
                    <ImageIcon size={16} />
                    Add photo (optional)
                  </button>
                )}

                {wallSettings.allowAnonymous && (
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" className="w-4 h-4 rounded border-gray-300 text-[#FF3E9B]" />
                    <span className="text-[13px] text-gray-600">Post anonymously</span>
                  </label>
                )}

                <button className="w-full py-4 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white rounded-[16px] text-[15px] font-medium hover:shadow-lg transition-all flex items-center justify-center gap-2">
                  <Heart size={16} />
                  Post Message
                </button>
              </div>

              {/* What happens next */}
              <div className="mt-6 p-4 bg-[#F0F9FA] rounded-[16px]">
                <div className="text-[12px] text-gray-600 leading-relaxed">
                  {wallSettings.requireApproval ? (
                    <>✨ Your message will be reviewed before appearing on the wall</>
                  ) : (
                    <>✨ Your message will appear immediately on the wall</>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Share Modal */}
      {showShareModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-[32px] max-w-lg w-full p-8">
            <div className="flex items-center justify-between mb-6">
              <div className="text-[24px] font-semibold text-gray-900" style={{ fontFamily: 'Playfair Display, serif' }}>
                Share Wedding Wall
              </div>
              <button
                onClick={() => setShowShareModal(false)}
                className="w-10 h-10 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center transition-colors"
              >
                <span className="text-[20px] text-gray-600">×</span>
              </button>
            </div>

            <div className="text-[14px] text-gray-600 mb-6">
              Share this with your wedding guests so they can leave heartfelt messages
            </div>

            {/* Link */}
            <div className="p-4 bg-gray-50 rounded-[16px] border border-gray-200 mb-6">
              <div className="text-[12px] text-gray-500 mb-2">Wedding Wall URL</div>
              <div className="text-[15px] font-mono text-gray-800 break-all">{wallUrl}</div>
            </div>

            {/* QR Code placeholder */}
            <div className="p-8 bg-gradient-to-br from-gray-50 to-white rounded-[20px] border border-gray-200 mb-6 text-center">
              <QrCode size={120} className="mx-auto mb-4 text-gray-400" />
              <div className="text-[13px] text-gray-600 mb-3">Scan to leave a message</div>
              <button className="text-[13px] text-[#3A8B95] font-medium hover:underline">
                Download QR code
              </button>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              <button
                onClick={copyToClipboard}
                className="flex-1 py-3 bg-[#3A8B95] text-white rounded-full text-[14px] font-medium hover:shadow-lg transition-all"
              >
                Copy Link
              </button>
              <button
                onClick={() => setShowShareModal(false)}
                className="flex-1 py-3 border-2 border-gray-200 text-gray-700 rounded-full text-[14px] font-medium hover:bg-gray-50 transition-all"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
