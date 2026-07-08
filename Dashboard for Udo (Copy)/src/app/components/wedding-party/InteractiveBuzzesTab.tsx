import { useState } from 'react';
import { Send, MessageSquare, Check, Clock, Eye, Heart, ThumbsUp, Plus, Filter, Search, X, Mail, Phone, Bell } from 'lucide-react';

interface Buzz {
  id: string;
  message: string;
  recipients: string;
  channel: 'WhatsApp' | 'SMS' | 'Email' | 'Push';
  tone: string;
  sentAt: string;
  deliveryStatus: 'sent' | 'delivered' | 'read';
  reactions: { emoji: string; count: number }[];
  readBy: string[];
}

interface BuzzesTabProps {
  buzzes: Buzz[];
  people: any[];
  onSendBuzz: (buzz: any) => void;
}

export default function InteractiveBuzzesTab({ buzzes, people, onSendBuzz }: BuzzesTabProps) {
  const [showComposer, setShowComposer] = useState(false);
  const [selectedBuzz, setSelectedBuzz] = useState<string | null>(null);
  const [filterChannel, setFilterChannel] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [composerData, setComposerData] = useState({
    recipients: [] as string[],
    channel: 'WhatsApp' as 'WhatsApp' | 'SMS' | 'Email',
    tone: 'gentle',
    message: '',
    scheduledTime: null as string | null
  });

  const filteredBuzzes = buzzes.filter(b => {
    const matchesChannel = filterChannel === 'all' || b.channel === filterChannel;
    const matchesSearch = b.message.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         b.recipients.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesChannel && matchesSearch;
  });

  const recipientGroups = [
    { id: 'all', name: 'All wedding party', count: people.length },
    { id: 'bridesmaids', name: 'Bridesmaids', count: people.filter(p => p.role.includes('Bridesmaid')).length },
    { id: 'groomsmen', name: 'Groomsmen', count: people.filter(p => p.role.includes('Best Man')).length },
    { id: 'honor', name: 'Maid of Honor & Best Man', count: 2 }
  ];

  const messageTemplates = [
    { id: 't1', title: 'Rehearsal Reminder', message: 'Hi everyone 💛 rehearsal begins at 5:30 PM. Please arrive 15 minutes early so we can begin calmly and on time.' },
    { id: 't2', title: 'Timeline Update', message: 'Small timeline adjustment: hair & makeup now starts at 10:00 AM instead of 9:30 AM. Updated schedule in your portal.' },
    { id: 't3', title: 'Travel Confirmation', message: 'Quick travel check-in: please confirm your arrival details in the travel tab when you have a moment. Thank you! ✨' },
    { id: 't4', title: 'Thank You', message: 'Thank you for being part of our special day. Your love and support means everything to us 💕' }
  ];

  const toneOptions = [
    { id: 'gentle', label: 'Gentle', description: 'Warm and calming' },
    { id: 'excited', label: 'Excited', description: 'Joyful and energetic' },
    { id: 'calm', label: 'Calm', description: 'Professional and clear' },
    { id: 'loving', label: 'Loving', description: 'Heartfelt and emotional' },
    { id: 'urgent', label: 'Urgent', description: 'Time-sensitive' }
  ];

  const handleSendBuzz = () => {
    if (composerData.message && composerData.recipients.length > 0) {
      onSendBuzz({
        ...composerData,
        recipients: composerData.recipients.join(', '),
        sentAt: 'Just now',
        deliveryStatus: 'sent',
        reactions: [],
        readBy: []
      });
      setShowComposer(false);
      setComposerData({
        recipients: [],
        channel: 'WhatsApp',
        tone: 'gentle',
        message: '',
        scheduledTime: null
      });
    }
  };

  return (
    <div className="space-y-6">
      {/* Header with Actions */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-[24px] text-gray-900 mb-2" style={{ fontFamily: 'Playfair Display, serif', fontWeight: 600 }}>
            Buzzes
          </h3>
          <p className="text-[13px] text-gray-600">Elegant communication with your wedding party</p>
        </div>
        <button
          onClick={() => setShowComposer(true)}
          className="px-6 py-3 bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white rounded-xl hover:shadow-lg transition-all flex items-center gap-2 font-medium"
        >
          <Plus size={18} />
          New Buzz
        </button>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-4 gap-4">
        <div className="bg-gradient-to-br from-blue-50 to-white rounded-xl p-4 border border-blue-100">
          <div className="text-sm text-gray-600 mb-1">Total Sent</div>
          <div className="text-2xl font-bold text-blue-600">{buzzes.length}</div>
        </div>
        <div className="bg-gradient-to-br from-green-50 to-white rounded-xl p-4 border border-green-100">
          <div className="text-sm text-gray-600 mb-1">Delivered</div>
          <div className="text-2xl font-bold text-green-600">
            {buzzes.filter(b => b.deliveryStatus === 'delivered' || b.deliveryStatus === 'read').length}
          </div>
        </div>
        <div className="bg-gradient-to-br from-purple-50 to-white rounded-xl p-4 border border-purple-100">
          <div className="text-sm text-gray-600 mb-1">Read</div>
          <div className="text-2xl font-bold text-purple-600">
            {buzzes.filter(b => b.deliveryStatus === 'read').length}
          </div>
        </div>
        <div className="bg-gradient-to-br from-amber-50 to-white rounded-xl p-4 border border-amber-100">
          <div className="text-sm text-gray-600 mb-1">Reactions</div>
          <div className="text-2xl font-bold text-amber-600">
            {buzzes.reduce((sum, b) => sum + b.reactions.reduce((s, r) => s + r.count, 0), 0)}
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="flex items-center gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            placeholder="Search buzzes..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
          />
        </div>
        <div className="flex gap-2 bg-white rounded-xl border border-gray-200 p-1">
          {['all', 'WhatsApp', 'SMS', 'Email', 'Push'].map(channel => (
            <button
              key={channel}
              onClick={() => setFilterChannel(channel)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                filterChannel === channel ? 'bg-[#FF3E9B] text-white' : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              {channel === 'all' ? 'All' : channel}
            </button>
          ))}
        </div>
      </div>

      {/* Buzzes List */}
      <div className="space-y-3">
        {filteredBuzzes.map((buzz) => (
          <div
            key={buzz.id}
            onClick={() => setSelectedBuzz(selectedBuzz === buzz.id ? null : buzz.id)}
            className="bg-white rounded-2xl border-2 border-gray-200 p-5 hover:border-[#FF3E9B] transition-all cursor-pointer"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                  buzz.channel === 'WhatsApp' ? 'bg-green-100' :
                  buzz.channel === 'SMS' ? 'bg-blue-100' :
                  buzz.channel === 'Email' ? 'bg-purple-100' :
                  'bg-amber-100'
                }`}>
                  {buzz.channel === 'WhatsApp' && <MessageSquare size={18} className="text-green-600" />}
                  {buzz.channel === 'SMS' && <Phone size={18} className="text-blue-600" />}
                  {buzz.channel === 'Email' && <Mail size={18} className="text-purple-600" />}
                  {buzz.channel === 'Push' && <Bell size={18} className="text-amber-600" />}
                </div>
                <div>
                  <div className="text-sm font-semibold text-gray-900">{buzz.recipients}</div>
                  <div className="text-xs text-gray-600">via {buzz.channel} • {buzz.sentAt}</div>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <span className={`px-3 py-1 text-xs rounded-full font-medium ${
                  buzz.deliveryStatus === 'read' ? 'bg-green-100 text-green-700' :
                  buzz.deliveryStatus === 'delivered' ? 'bg-blue-100 text-blue-700' :
                  'bg-gray-100 text-gray-700'
                }`}>
                  {buzz.deliveryStatus === 'read' && <><Eye size={12} className="inline mr-1" />Read</>}
                  {buzz.deliveryStatus === 'delivered' && <><Check size={12} className="inline mr-1" />Delivered</>}
                  {buzz.deliveryStatus === 'sent' && <><Clock size={12} className="inline mr-1" />Sent</>}
                </span>
              </div>
            </div>

            <div className="text-sm text-gray-700 mb-3">{buzz.message}</div>

            {buzz.reactions.length > 0 && (
              <div className="flex items-center gap-3 mb-3">
                {buzz.reactions.map((reaction, idx) => (
                  <button
                    key={idx}
                    className="flex items-center gap-1 px-3 py-1.5 bg-gray-100 rounded-full hover:bg-gray-200 transition-colors"
                  >
                    <span>{reaction.emoji}</span>
                    <span className="text-xs font-medium text-gray-700">{reaction.count}</span>
                  </button>
                ))}
              </div>
            )}

            {selectedBuzz === buzz.id && (
              <div className="pt-4 border-t border-gray-200 space-y-3">
                <div>
                  <div className="text-xs text-gray-500 mb-2">READ BY</div>
                  <div className="flex flex-wrap gap-2">
                    {people.slice(0, buzz.readBy.length).map((person) => (
                      <span key={person.id} className="px-3 py-1 bg-green-50 text-green-700 text-xs rounded-full">
                        {person.name}
                      </span>
                    ))}
                  </div>
                </div>
                <div className="flex gap-2">
                  <button className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm hover:bg-blue-700 flex items-center gap-2">
                    <Send size={14} />
                    Resend
                  </button>
                  <button className="px-4 py-2 bg-purple-600 text-white rounded-lg text-sm hover:bg-purple-700 flex items-center gap-2">
                    <MessageSquare size={14} />
                    Follow Up
                  </button>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Buzz Composer Modal */}
      {showComposer && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-4" onClick={() => setShowComposer(false)}>
          <div className="bg-white rounded-t-3xl sm:rounded-2xl w-full sm:max-w-3xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between rounded-t-3xl sm:rounded-t-2xl">
              <h3 className="text-xl font-semibold text-gray-900">Create Buzz</h3>
              <button onClick={() => setShowComposer(false)} className="p-2 hover:bg-gray-100 rounded-full">
                <X size={20} className="text-gray-600" />
              </button>
            </div>

            <div className="p-6 space-y-6">
              {/* Recipients */}
              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-3">Recipients</label>
                <div className="grid grid-cols-2 gap-2">
                  {recipientGroups.map(group => (
                    <button
                      key={group.id}
                      onClick={() => {
                        if (composerData.recipients.includes(group.id)) {
                          setComposerData({
                            ...composerData,
                            recipients: composerData.recipients.filter(r => r !== group.id)
                          });
                        } else {
                          setComposerData({
                            ...composerData,
                            recipients: [...composerData.recipients, group.id]
                          });
                        }
                      }}
                      className={`p-4 rounded-xl border-2 transition-all text-left ${
                        composerData.recipients.includes(group.id)
                          ? 'border-[#FF3E9B] bg-pink-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="flex items-center justify-between mb-1">
                        <span className="font-medium text-gray-900">{group.name}</span>
                        {composerData.recipients.includes(group.id) && (
                          <Check size={18} className="text-[#FF3E9B]" />
                        )}
                      </div>
                      <span className="text-sm text-gray-600">{group.count} people</span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Channel Selection */}
              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-3">Channel</label>
                <div className="flex gap-2">
                  {['WhatsApp', 'SMS', 'Email'].map(channel => (
                    <button
                      key={channel}
                      onClick={() => setComposerData({ ...composerData, channel: channel as any })}
                      className={`flex-1 p-4 rounded-xl border-2 transition-all ${
                        composerData.channel === channel
                          ? 'border-[#FF3E9B] bg-pink-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="text-center">
                        <div className="font-medium text-gray-900">{channel}</div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Tone Selection */}
              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-3">Tone</label>
                <div className="grid grid-cols-3 gap-2">
                  {toneOptions.map(tone => (
                    <button
                      key={tone.id}
                      onClick={() => setComposerData({ ...composerData, tone: tone.id })}
                      className={`p-3 rounded-xl border-2 transition-all text-left ${
                        composerData.tone === tone.id
                          ? 'border-[#FF3E9B] bg-pink-50'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <div className="font-medium text-sm text-gray-900 mb-1">{tone.label}</div>
                      <div className="text-xs text-gray-600">{tone.description}</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Templates */}
              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-3">Templates (optional)</label>
                <div className="space-y-2">
                  {messageTemplates.map(template => (
                    <button
                      key={template.id}
                      onClick={() => setComposerData({ ...composerData, message: template.message })}
                      className="w-full p-3 rounded-xl border border-gray-200 hover:border-[#FF3E9B] transition-all text-left"
                    >
                      <div className="font-medium text-sm text-gray-900 mb-1">{template.title}</div>
                      <div className="text-xs text-gray-600 line-clamp-1">{template.message}</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Message */}
              <div>
                <label className="block text-sm font-semibold text-gray-900 mb-2">Message</label>
                <textarea
                  value={composerData.message}
                  onChange={(e) => setComposerData({ ...composerData, message: e.target.value })}
                  placeholder="Write your message..."
                  rows={6}
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
                />
                <div className="text-xs text-gray-500 mt-2">{composerData.message.length} characters</div>
              </div>

              {/* Schedule Option */}
              <div className="flex items-center gap-3">
                <input
                  type="checkbox"
                  id="schedule"
                  className="h-5 w-5 text-[#FF3E9B] rounded"
                  onChange={(e) => {
                    if (!e.target.checked) {
                      setComposerData({ ...composerData, scheduledTime: null });
                    }
                  }}
                />
                <label htmlFor="schedule" className="text-sm text-gray-700 flex-1">
                  Schedule for later
                </label>
                {composerData.scheduledTime !== null && (
                  <input
                    type="datetime-local"
                    className="px-3 py-2 border border-gray-300 rounded-lg text-sm"
                    onChange={(e) => setComposerData({ ...composerData, scheduledTime: e.target.value })}
                  />
                )}
              </div>
            </div>

            <div className="sticky bottom-0 bg-gray-50 border-t border-gray-200 px-6 py-4 flex items-center justify-between rounded-b-3xl sm:rounded-b-2xl">
              <button
                onClick={() => setShowComposer(false)}
                className="px-6 py-2.5 bg-white border-2 border-gray-300 text-gray-700 rounded-xl hover:bg-gray-50 transition-colors font-medium"
              >
                Cancel
              </button>
              <button
                onClick={handleSendBuzz}
                disabled={composerData.message === '' || composerData.recipients.length === 0}
                className="px-8 py-2.5 bg-gradient-to-r from-[#FF88BA] to-[#FF3E9B] text-white rounded-xl hover:shadow-lg transition-all font-semibold flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Send size={18} />
                {composerData.scheduledTime ? 'Schedule Buzz' : 'Send Buzz'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
