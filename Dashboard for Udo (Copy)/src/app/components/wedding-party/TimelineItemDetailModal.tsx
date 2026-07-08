import { X, Save, Trash2, Send, Users, Clock, MapPin, AlertTriangle, Bell } from 'lucide-react';
import { useState } from 'react';

interface TimelineItemDetailModalProps {
  item: any;
  onClose: () => void;
  onSave: (updated: any) => void;
  onDelete: () => void;
  onNotifyPeople: () => void;
}

export default function TimelineItemDetailModal({
  item,
  onClose,
  onSave,
  onDelete,
  onNotifyPeople
}: TimelineItemDetailModalProps) {
  const [editedData, setEditedData] = useState(item);

  const handleSave = () => {
    onSave(editedData);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center">
      <div className="bg-white w-full sm:max-w-2xl sm:rounded-2xl rounded-t-3xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-gray-900">Timeline Event Details</h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full">
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Title */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Event Title</label>
            <input
              type="text"
              value={editedData.title}
              onChange={(e) => setEditedData({ ...editedData, title: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Time Range */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Start Time</label>
              <input
                type="time"
                value={editedData.startTime}
                onChange={(e) => setEditedData({ ...editedData, startTime: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">End Time</label>
              <input
                type="time"
                value={editedData.endTime}
                onChange={(e) => setEditedData({ ...editedData, endTime: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
              />
            </div>
          </div>

          {/* Duration Warning */}
          {editedData.startTime !== item.startTime && (
            <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex items-start gap-3">
              <AlertTriangle size={20} className="text-amber-600 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium text-amber-900">Time Change Detected</p>
                <p className="text-sm text-amber-700 mt-1">
                  This will affect 4 following events. Auto-adjustment is enabled.
                </p>
              </div>
            </div>
          )}

          {/* Location */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
            <input
              type="text"
              value={editedData.location}
              onChange={(e) => setEditedData({ ...editedData, location: e.target.value })}
              placeholder="e.g., Bridal Suite, Ceremony Venue"
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Owner/Coordinator */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Event Coordinator</label>
            <select
              value={editedData.owner}
              onChange={(e) => setEditedData({ ...editedData, owner: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            >
              <option>Emily Rodriguez - Maid of Honor</option>
              <option>Sarah Martinez - Bridesmaid</option>
              <option>James Wilson - Best Man</option>
              <option>Wedding Planner</option>
              <option>Bride</option>
            </select>
          </div>

          {/* Affected People */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Affected People</label>
            <div className="bg-gray-50 rounded-xl p-4">
              <div className="flex flex-wrap gap-2">
                <span className="px-3 py-1.5 bg-white border border-gray-200 rounded-full text-sm">
                  Emily Rodriguez
                </span>
                <span className="px-3 py-1.5 bg-white border border-gray-200 rounded-full text-sm">
                  Sarah Martinez
                </span>
                <span className="px-3 py-1.5 bg-white border border-gray-200 rounded-full text-sm">
                  Jessica Moore
                </span>
                <button className="px-3 py-1.5 bg-[#FF3E9B] text-white rounded-full text-sm hover:bg-[#e63587]">
                  + Add Person
                </button>
              </div>
            </div>
          </div>

          {/* Linked Responsibilities */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Linked Responsibilities</label>
            <div className="bg-gray-50 rounded-xl p-4 space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-700">Setup floral arrangements</span>
                <span className="text-xs px-2 py-1 bg-green-100 text-green-700 rounded-full">Completed</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-700">Coordinate photographer arrival</span>
                <span className="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded-full">In Progress</span>
              </div>
              <button className="text-sm text-[#FF3E9B] hover:underline">+ Link Responsibility</button>
            </div>
          </div>

          {/* Transport Coordination */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Transport Details</label>
            <textarea
              placeholder="e.g., Shared car from hotel at 9:30 AM"
              rows={2}
              value={editedData.transport || ''}
              onChange={(e) => setEditedData({ ...editedData, transport: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Notes */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Notes</label>
            <textarea
              placeholder="Add any additional notes or instructions..."
              rows={3}
              value={editedData.notes || ''}
              onChange={(e) => setEditedData({ ...editedData, notes: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Status */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              value={editedData.status || 'scheduled'}
              onChange={(e) => setEditedData({ ...editedData, status: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            >
              <option value="scheduled">Scheduled</option>
              <option value="confirmed">Confirmed</option>
              <option value="in-progress">In Progress</option>
              <option value="at-risk">At Risk</option>
              <option value="delayed">Delayed</option>
              <option value="completed">Completed</option>
            </select>
          </div>

          {/* Dependencies */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Depends On</label>
            <div className="bg-gray-50 rounded-xl p-4">
              <div className="text-sm text-gray-600 mb-2">
                <Clock size={16} className="inline mr-2" />
                Hair & Makeup (must complete 30 min before)
              </div>
              <button className="text-sm text-[#FF3E9B] hover:underline">+ Add Dependency</button>
            </div>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="sticky bottom-0 bg-gray-50 border-t border-gray-200 px-6 py-4 flex flex-wrap gap-3">
          <button
            onClick={handleSave}
            className="flex items-center gap-2 px-6 py-2.5 bg-[#FF3E9B] text-white rounded-xl hover:bg-[#e63587] transition-colors"
          >
            <Save size={18} />
            Save Changes
          </button>
          <button
            onClick={onNotifyPeople}
            className="flex items-center gap-2 px-6 py-2.5 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors"
          >
            <Bell size={18} />
            Notify Affected People
          </button>
          <button
            onClick={() => {
              if (confirm('Are you sure you want to delete this timeline event?')) {
                onDelete();
                onClose();
              }
            }}
            className="flex items-center gap-2 px-6 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-colors ml-auto"
          >
            <Trash2 size={18} />
            Delete Event
          </button>
        </div>
      </div>
    </div>
  );
}
