'use client';

import { useState } from 'react';
import { Eye, Edit, Send, Users, Sparkles, Calendar, Mail, MessageSquare, Link as LinkIcon, Check, Play, Heart, ArrowRight, Download, Share2 } from 'lucide-react';

interface InvitationStudioProps {
  onShowPreview: () => void;
  onEditContent: () => void;
  onChangeTheme: () => void;
  onSendInvitations: () => void;
}

export default function InvitationStudio({
  onShowPreview,
  onEditContent,
  onChangeTheme,
  onSendInvitations
}: InvitationStudioProps) {
  const [selectedTemplate, setSelectedTemplate] = useState('modern-editorial');

  const templates = [
    { id: 'modern-editorial', name: 'Modern Editorial', style: 'Clean & Contemporary', color: 'Linear Gradient', mood: 'Sophisticated' },
    { id: 'romantic-minimal', name: 'Romantic Minimal', style: 'Soft & Elegant', color: 'Blush & Ivory', mood: 'Intimate' },
    { id: 'luxury-blacktie', name: 'Luxury Black Tie', style: 'Dark & Dramatic', color: 'Black & Gold', mood: 'Formal' },
    { id: 'tropical-destination', name: 'Tropical Destination', style: 'Vibrant & Fresh', color: 'Coral & Teal', mood: 'Adventurous' },
    { id: 'soft-garden', name: 'Soft Garden', style: 'Floral & Organic', color: 'Sage & Cream', mood: 'Natural' },
    { id: 'coastal-elegant', name: 'Coastal Elegant', style: 'Breezy & Refined', color: 'Navy & Sand', mood: 'Relaxed' }
  ];

  return (
    <div className="space-y-8">
      {/* Page intro */}
      <div>
        <p className="text-[15px] text-gray-600" style={{ lineHeight: 1.6 }}>
          Create a beautiful digital invitation that feels personal and memorable.
        </p>
      </div>

      {/* Creative Studio Layout - Two Column */}
      <div className="grid md:grid-cols-2 gap-8">
        {/* LEFT - Large Live Invitation Preview */}
        <div className="relative bg-gradient-to-br from-[#FAFAFA] via-white to-[#F0F9FA] rounded-[32px] p-12 shadow-xl border border-gray-100 overflow-hidden">
          {/* Subtle floral texture overlay */}
          <div className="absolute inset-0 opacity-[0.03]" style={{
            backgroundImage: 'radial-gradient(circle at 1px 1px, #FF3E9B 1px, transparent 0)',
            backgroundSize: '40px 40px'
          }} />

          {/* Animated shimmer effect */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-shimmer" style={{
            animation: 'shimmer 3s infinite',
            backgroundSize: '200% 100%'
          }} />

          <div className="relative z-10">
          {/* Invitation Card */}
          <div className="bg-white rounded-[24px] p-12 shadow-2xl border border-gray-100/50" style={{
            boxShadow: '0 20px 60px rgba(0,0,0,0.08), 0 8px 20px rgba(0,0,0,0.04)'
          }}>
            <div className="text-center">
              {/* Header */}
              <div className="mb-8">
                <div className="text-[11px] tracking-[0.3em] text-gray-500 uppercase mb-6">
                  Together with their families
                </div>

                {/* Couple Names - Premium Typography */}
                <h1 className="text-[48px] leading-tight mb-4" style={{
                  fontFamily: 'Playfair Display, serif',
                  fontWeight: 600,
                  letterSpacing: '0.02em',
                  background: 'linear-gradient(135deg, #FF3E9B, #FF88BA)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent'
                }}>
                  Olivia & Jordan
                </h1>

                {/* Subtitle */}
                <p className="text-[15px] text-gray-600 italic leading-relaxed max-w-md mx-auto mb-8">
                  request the honor of your presence at their wedding
                </p>

                {/* Decorative Divider */}
                <div className="flex items-center justify-center gap-3 mb-8">
                  <div className="h-px w-12 bg-gradient-to-r from-transparent to-[#FF3E9B]" />
                  <Heart size={16} className="text-[#FF3E9B]" fill="#FF3E9B" />
                  <div className="h-px w-12 bg-gradient-to-l from-transparent to-[#FF3E9B]" />
                </div>

                {/* Date & Venue */}
                <div className="mb-8">
                  <div className="text-[32px] mb-3" style={{
                    fontFamily: 'Playfair Display, serif',
                    fontWeight: 600,
                    color: '#FF3E9B'
                  }}>
                    June 14, 2026
                  </div>
                  <div className="text-[16px] text-gray-700 mb-2">Sunset Gardens</div>
                  <div className="text-[15px] text-gray-600">San Diego, California</div>
                </div>

                {/* Quote */}
                <div className="py-6 border-t border-b border-gray-100">
                  <p className="text-[13px] text-gray-600 italic leading-relaxed">
                    "Love is friendship set to music"
                  </p>
                </div>

                {/* RSVP Button Preview */}
                <div className="mt-8">
                  <button className="px-8 py-3 bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] text-white rounded-full text-[14px] font-medium shadow-lg hover:shadow-xl transition-all">
                    RSVP Now
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Live Preview Badge */}
          <div className="mt-6 flex items-center justify-center gap-2 text-[12px] text-gray-500">
            <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
            <span>Live preview • Updates in real-time</span>
          </div>
        </div>
        </div>

        {/* RIGHT - Creative Controls Panel (Stacked) */}
        <div className="space-y-4">
          {/* 1. EDIT DESIGN - Largest, Primary Action */}
          <button
            onClick={onEditContent}
            className="w-full group bg-gradient-to-br from-[#FFF5F8] to-white rounded-[24px] p-6 border-2 border-[#FF3E9B]/20 hover:border-[#FF3E9B] hover:shadow-2xl hover:-translate-y-1 transition-all text-left overflow-hidden relative"
          >
            <div className="flex items-start gap-4 mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#FF3E9B] to-[#FF88BA] flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform">
                <Edit className="text-white" size={20} />
              </div>
              <div className="flex-1">
                <div className="text-[18px] font-semibold text-gray-900 mb-1">Edit Design</div>
                <div className="text-[13px] text-gray-600 mb-2 leading-relaxed">
                  Customize typography, layout, photos, spacing, and invitation sections in real time.
                </div>
                <div className="text-[11px] text-[#FF3E9B] font-medium">Live visual editing studio →</div>
              </div>
            </div>

            {/* Mini Mockup Preview */}
            <div className="bg-white/80 backdrop-blur-sm rounded-[16px] p-4 border border-gray-100">
              <div className="flex items-center gap-3 mb-3">
                {/* Typography slider preview */}
                <div className="flex-1">
                  <div className="text-[10px] text-gray-500 mb-1">Typography</div>
                  <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-[#FF3E9B] to-[#FF88BA] w-2/3" />
                  </div>
                </div>
                {/* Spacing control preview */}
                <div className="flex-1">
                  <div className="text-[10px] text-gray-500 mb-1">Spacing</div>
                  <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] w-3/4" />
                  </div>
                </div>
              </div>
              {/* Color palette chips */}
              <div className="flex items-center gap-2">
                <div className="text-[10px] text-gray-500">Colors:</div>
                <div className="flex gap-1">
                  <div className="w-5 h-5 rounded-full bg-[#FF3E9B] border-2 border-white shadow-sm" />
                  <div className="w-5 h-5 rounded-full bg-[#3A8B95] border-2 border-white shadow-sm" />
                  <div className="w-5 h-5 rounded-full bg-gray-900 border-2 border-white shadow-sm" />
                  <div className="w-5 h-5 rounded-full bg-white border-2 border-gray-200" />
                </div>
              </div>
            </div>
          </button>

          {/* 2. CHANGE THEME - Visual Template Carousel */}
          <button
            onClick={onChangeTheme}
            className="w-full group bg-white rounded-[24px] p-6 border-2 border-gray-200 hover:border-[#FF88BA] hover:shadow-2xl hover:-translate-y-1 transition-all text-left"
          >
            <div className="flex items-start gap-4 mb-4">
              <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF88BA] to-[#FFB3D6] flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform">
                <Sparkles className="text-white" size={18} />
              </div>
              <div className="flex-1">
                <div className="text-[16px] font-semibold text-gray-900 mb-1">Change Theme</div>
                <div className="text-[12px] text-gray-600 mb-2">
                  Explore professionally designed invitation experiences.
                </div>
                <div className="text-[10px] text-gray-500">Modern • Editorial • Luxury • Romantic</div>
              </div>
            </div>

            {/* Mini scrolling template carousel */}
            <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
              {['Editorial', 'Beach', 'Black Tie', 'Floral'].map((theme, idx) => (
                <div key={idx} className="flex-shrink-0 w-16 h-20 rounded-lg bg-gradient-to-br from-gray-50 to-white border border-gray-200 flex items-center justify-center">
                  <div className="text-[8px] text-center text-gray-600 leading-tight px-1">{theme}</div>
                </div>
              ))}
            </div>
          </button>

          {/* 3. PREVIEW - Segmented Guest Views */}
          <button
            onClick={onShowPreview}
            className="w-full group bg-gradient-to-br from-[#F0F9FA] to-white rounded-[24px] p-5 border-2 border-[#3A8B95]/20 hover:border-[#3A8B95] hover:shadow-2xl hover:-translate-y-1 transition-all text-left"
          >
            <div className="flex items-start gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-[#3A8B95] flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform">
                <Eye className="text-white" size={18} />
              </div>
              <div className="flex-1">
                <div className="text-[15px] font-semibold text-gray-900 mb-1">Live Guest Preview</div>
                <div className="text-[11px] text-gray-600 mb-2">
                  Experience exactly what each guest sees.
                </div>
                <div className="text-[10px] text-[#3A8B95] font-medium">Dynamic personalized views</div>
              </div>
            </div>

            {/* Segmented preview snippets */}
            <div className="grid grid-cols-4 gap-1.5">
              {['Attending', 'Travelling', 'Party', 'Pending'].map((type, idx) => (
                <div key={idx} className="bg-white/80 rounded-lg p-2 border border-gray-100">
                  <div className="text-[9px] text-gray-500 text-center leading-tight">{type}</div>
                </div>
              ))}
            </div>
          </button>

          {/* 4. PERSONALIZE - Guest Segmentation Diagram */}
          <button
            className="w-full group bg-white rounded-[20px] p-5 border-2 border-gray-200 hover:border-[#66D0BC] hover:shadow-xl hover:-translate-y-1 transition-all text-left"
          >
            <div className="flex items-start gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#66D0BC] to-[#3A8B95] flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform">
                <Users className="text-white" size={18} />
              </div>
              <div className="flex-1">
                <div className="text-[15px] font-semibold text-gray-900 mb-1">Personalize Guest Access</div>
                <div className="text-[11px] text-gray-600 mb-2">
                  Control what each guest group sees and experiences.
                </div>
                <div className="text-[10px] text-[#3A8B95] font-medium">Smart dynamic guest journeys</div>
              </div>
            </div>

            {/* Mini segmentation diagram */}
            <div className="space-y-1.5">
              <div className="flex items-center gap-2 text-[9px]">
                <div className="w-2 h-2 rounded-full bg-[#FF3E9B]" />
                <span className="text-gray-600">Wedding Party → Rehearsal Dinner</span>
              </div>
              <div className="flex items-center gap-2 text-[9px]">
                <div className="w-2 h-2 rounded-full bg-[#3A8B95]" />
                <span className="text-gray-600">Travelling Guests → Hotels</span>
              </div>
              <div className="flex items-center gap-2 text-[9px]">
                <div className="w-2 h-2 rounded-full bg-[#FF88BA]" />
                <span className="text-gray-600">VIP Guests → Private Events</span>
              </div>
            </div>
          </button>

          {/* 5. SEND - Campaign Intelligence */}
          <button
            onClick={onSendInvitations}
            className="w-full group bg-gradient-to-br from-white to-[#FAFAFA] rounded-[20px] p-5 border-2 border-gray-200 hover:border-[#FF3E9B] hover:shadow-xl hover:-translate-y-1 transition-all text-left"
          >
            <div className="flex items-start gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF3E9B] to-[#FF88BA] flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform">
                <Send className="text-white" size={18} />
              </div>
              <div className="flex-1">
                <div className="text-[15px] font-semibold text-gray-900 mb-1">Send & Track</div>
                <div className="text-[11px] text-gray-600 mb-2">
                  Deliver invitations and monitor engagement in real time.
                </div>
                <div className="text-[10px] text-gray-500">Email • SMS • WhatsApp • Link</div>
              </div>
            </div>

            {/* Tiny analytics preview */}
            <div className="grid grid-cols-2 gap-2">
              <div className="bg-white rounded-lg p-2 border border-gray-100">
                <div className="text-[16px] font-semibold text-[#3A8B95]">74%</div>
                <div className="text-[9px] text-gray-500">Opened</div>
              </div>
              <div className="bg-white rounded-lg p-2 border border-gray-100">
                <div className="text-[16px] font-semibold text-[#FF3E9B]">18</div>
                <div className="text-[9px] text-gray-500">Pending</div>
              </div>
            </div>
          </button>
        </div>
      </div>

      {/* Template Gallery */}
      <div className="bg-white rounded-[24px] p-8 shadow-sm border border-gray-100">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
              Invitation templates
            </h3>
            <p className="text-[13px] text-gray-600">Choose a style that reflects your celebration</p>
          </div>
        </div>

        {/* Horizontally Scrollable Templates */}
        <div className="relative -mx-8 px-8">
          <div className="flex gap-6 overflow-x-auto pb-4 snap-x snap-mandatory scrollbar-hide">
            {templates.map((template) => (
              <div
                key={template.id}
                onClick={() => setSelectedTemplate(template.id)}
                className={`flex-shrink-0 w-80 snap-start cursor-pointer group transition-all ${
                  selectedTemplate === template.id ? 'scale-105' : ''
                }`}
              >
                {/* Template Preview Card */}
                <div className={`rounded-[20px] overflow-hidden border-2 transition-all ${
                  selectedTemplate === template.id
                    ? 'border-[#FF3E9B] shadow-2xl'
                    : 'border-gray-200 shadow-lg hover:border-[#FF88BA] hover:shadow-xl'
                }`}>
                  {/* Preview Image/Area */}
                  <div className="aspect-[3/4] bg-gradient-to-br from-gray-50 to-white flex items-center justify-center p-8 relative overflow-hidden">
                    {/* Simulated template preview */}
                    <div className="text-center">
                      <div className="text-[11px] tracking-widest text-gray-400 uppercase mb-3">You're Invited</div>
                      <div className="text-[24px] mb-3" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
                        {template.name.split(' ')[0]} & {template.name.split(' ')[1] || 'Love'}
                      </div>
                      <div className="w-16 h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent mx-auto mb-3" />
                      <div className="text-[11px] text-gray-500">June 14, 2026</div>
                    </div>

                    {/* Animation badge */}
                    {template.id === 'modern-editorial' && (
                      <div className="absolute top-3 right-3 px-2 py-1 bg-white/90 backdrop-blur-sm rounded-full text-[10px] font-medium text-[#3A8B95] flex items-center gap-1">
                        <Play size={10} />
                        Animated
                      </div>
                    )}
                  </div>

                  {/* Template Info */}
                  <div className="p-4 bg-white">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <div className="text-[15px] font-semibold text-gray-900 mb-1">{template.name}</div>
                        <div className="text-[12px] text-gray-600">{template.style}</div>
                      </div>
                      {selectedTemplate === template.id && (
                        <div className="w-6 h-6 rounded-full bg-[#FF3E9B] flex items-center justify-center">
                          <Check size={14} className="text-white" />
                        </div>
                      )}
                    </div>

                    {/* Color palette indicator */}
                    <div className="flex items-center gap-2 mb-3">
                      <div className="flex gap-1">
                        <div className="w-4 h-4 rounded-full bg-[#FF3E9B]" />
                        <div className="w-4 h-4 rounded-full bg-[#3A8B95]" />
                        <div className="w-4 h-4 rounded-full bg-gray-100" />
                      </div>
                      <span className="text-[11px] text-gray-500">{template.mood}</span>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-2">
                      <button className="flex-1 py-2 bg-[#FF3E9B] text-white rounded-full text-[12px] font-medium hover:bg-[#c14d68] transition-colors">
                        Apply Theme
                      </button>
                      <button className="px-4 py-2 border border-gray-200 rounded-full text-[12px] font-medium text-gray-700 hover:bg-gray-50 transition-colors">
                        Preview
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Delivery Channels */}
      <div className="bg-white rounded-[24px] p-8 shadow-sm border border-gray-100">
        <h3 className="text-[24px] text-gray-900 mb-6" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Delivery options
        </h3>

        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          {[
            { icon: Mail, label: 'Email', desc: 'Send beautiful emails', color: '#3A8B95' },
            { icon: MessageSquare, label: 'SMS', desc: 'Text message delivery', color: '#FF3E9B' },
            { icon: Send, label: 'WhatsApp', desc: 'Share via WhatsApp', color: '#66D0BC' },
            { icon: LinkIcon, label: 'Shareable Link', desc: 'Copy & share anywhere', color: '#FF88BA' },
            { icon: Download, label: 'Apple Wallet', desc: 'Save to wallet', color: '#3A8B95' },
            { icon: Calendar, label: 'Calendar Invite', desc: 'Add to calendar', color: '#FF3E9B' }
          ].map((channel, idx) => {
            const Icon = channel.icon;
            return (
              <button
                key={idx}
                className="p-5 rounded-[20px] border border-gray-200 hover:border-[#FF3E9B] hover:shadow-lg transition-all text-left group"
              >
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0" style={{
                    backgroundColor: `${channel.color}15`
                  }}>
                    <Icon size={18} style={{ color: channel.color }} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[14px] font-medium text-gray-900 mb-1">{channel.label}</div>
                    <div className="text-[12px] text-gray-500">{channel.desc}</div>
                  </div>
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Analytics - Soft Insights */}
      <div className="bg-gradient-to-br from-[#F0F9FA] to-[#FFF5F8] rounded-[24px] p-8 border border-[#3A8B95]/20">
        <h3 className="text-[24px] text-gray-900 mb-6" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Invitation insights
        </h3>

        <div className="grid md:grid-cols-3 gap-6">
          <div className="bg-white/80 backdrop-blur-sm rounded-[20px] p-6">
            <div className="text-[36px] font-semibold text-[#3A8B95] mb-2">74%</div>
            <div className="text-[13px] text-gray-700 mb-3">Guests opened their invitation</div>
            <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
              <div className="h-full bg-gradient-to-r from-[#3A8B95] to-[#66D0BC] rounded-full" style={{ width: '74%' }} />
            </div>
          </div>

          <div className="bg-white/80 backdrop-blur-sm rounded-[20px] p-6">
            <div className="text-[36px] font-semibold text-[#FF3E9B] mb-2">86</div>
            <div className="text-[13px] text-gray-700 mb-1">Guests have RSVP'd</div>
            <div className="text-[12px] text-gray-500">Most responded within 24 hours</div>
          </div>

          <div className="bg-white/80 backdrop-blur-sm rounded-[20px] p-6">
            <div className="flex items-center gap-2 mb-3">
              <Heart size={18} className="text-[#FF88BA]" fill="#FF88BA" />
              <span className="text-[13px] text-gray-700 font-medium">Popular section</span>
            </div>
            <div className="text-[15px] text-gray-800 mb-1">Hotel Information</div>
            <div className="text-[12px] text-gray-500">Travelling guests engaged most</div>
          </div>
        </div>
      </div>

      {/* Recent Activity - Timeline */}
      <div className="bg-white rounded-[24px] p-8 shadow-sm border border-gray-100">
        <h3 className="text-[20px] text-gray-900 mb-6" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
          Recent activity
        </h3>

        <div className="space-y-4">
          {[
            { name: 'Sarah Johnson', action: 'viewed invitation', time: '2 minutes ago', avatar: 'SJ', color: '#FF3E9B' },
            { name: 'Michael Chen', action: "RSVP'd attending", time: '15 minutes ago', avatar: 'MC', color: '#3A8B95' },
            { name: 'Emily Rodriguez', action: 'selected meal preference', time: '1 hour ago', avatar: 'ER', color: '#FF88BA' }
          ].map((activity, idx) => (
            <div key={idx} className="flex items-center gap-4">
              {/* Avatar */}
              <div
                className="w-10 h-10 rounded-full flex items-center justify-center text-[13px] font-semibold text-white flex-shrink-0"
                style={{
                  background: `linear-gradient(135deg, ${activity.color}, ${activity.color}99)`
                }}
              >
                {activity.avatar}
              </div>

              {/* Content */}
              <div className="flex-1">
                <div className="text-[14px] text-gray-800">
                  <span className="font-medium">{activity.name}</span> {activity.action}
                </div>
                <div className="text-[12px] text-gray-500">{activity.time}</div>
              </div>

              {/* Timeline connector */}
              {idx < 2 && (
                <div className="absolute left-[65px] w-px h-10 bg-gray-200 translate-y-10" />
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
