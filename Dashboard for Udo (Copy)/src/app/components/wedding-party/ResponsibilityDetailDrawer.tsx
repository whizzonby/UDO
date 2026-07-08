import { X, Save, Trash2, Send, UserPlus, Calendar, Clock, MapPin, AlertCircle, Flag } from 'lucide-react';
import { useState } from 'react';

interface ResponsibilityDetailDrawerProps {
  responsibility: any;
  people: any[];
  onClose: () => void;
  onSave: (updated: any) => void;
  onDelete: () => void;
  onSendBuzz: () => void;
  onReassign: () => void;
}

export default function ResponsibilityDetailDrawer({
  responsibility,
  people,
  onClose,
  onSave,
  onDelete,
  onSendBuzz,
  onReassign
}: ResponsibilityDetailDrawerProps) {
  const [editedData, setEditedData] = useState(responsibility);

  const handleSave = () => {
    onSave(editedData);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center">
      <div className="bg-white w-full sm:max-w-2xl sm:rounded-2xl rounded-t-3xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-gray-900">Responsibility Details</h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full">
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Title */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
            <input
              type="text"
              value={editedData.title}
              onChange={(e) => setEditedData({ ...editedData, title: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
            <textarea
              value={editedData.description}
              onChange={(e) => setEditedData({ ...editedData, description: e.target.value })}
              rows={4}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Assigned Person */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Assigned Person</label>
            <select
              value={editedData.owner}
              onChange={(e) => setEditedData({ ...editedData, owner: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            >
              {people.map(person => (
                <option key={person.id} value={person.name}>{person.name} - {person.role}</option>
              ))}
            </select>
          </div>

          {/* Backup Person */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Backup Person (Optional)</label>
            <select
              value={editedData.backupOwner || ''}
              onChange={(e) => setEditedData({ ...editedData, backupOwner: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            >
              <option value="">None</option>
              {people.map(person => (
                <option key={person.id} value={person.name}>{person.name} - {person.role}</option>
              ))}
            </select>
          </div>

          {/* Due Date and Time */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Due Date</label>
              <input
                type="date"
                value="2026-06-15"
                className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Due Time</label>
              <input
                type="time"
                value="14:00"
                className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
              />
            </div>
          </div>

          {/* Location */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
            <input
              type="text"
              value={editedData.location}
              onChange={(e) => setEditedData({ ...editedData, location: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Linked Event */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Linked Timeline Event</label>
            <select className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent">
              <option>None</option>
              <option>Hair & Makeup - 10:00 AM</option>
              <option>Photography - 2:00 PM</option>
              <option>Ceremony - 4:00 PM</option>
              <option>Reception - 6:00 PM</option>
            </select>
          </div>

          {/* Dependencies */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Dependencies</label>
            <input
              type="text"
              placeholder="e.g., Florist delivery confirmed"
              value={editedData.dependencies?.join(', ') || ''}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Priority */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Priority</label>
            <select
              value={editedData.urgency}
              onChange={(e) => setEditedData({ ...editedData, urgency: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
          </div>

          {/* Status */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              value={editedData.status}
              onChange={(e) => setEditedData({ ...editedData, status: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            >
              <option value="assigned">Assigned</option>
              <option value="viewed">Viewed</option>
              <option value="acknowledged">Acknowledged</option>
              <option value="in-progress">In Progress</option>
              <option value="delayed">Delayed</option>
              <option value="needs-help">Needs Help</option>
              <option value="escalated">Escalated</option>
              <option value="completed">Completed</option>
            </select>
          </div>

          {/* Notes */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Notes</label>
            <textarea
              placeholder="Add any additional notes..."
              rows={3}
              className="w-full px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#FF3E9B] focus:border-transparent"
            />
          </div>

          {/* Communication History */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Communication History</label>
            <div className="bg-gray-50 rounded-xl p-4 space-y-2">
              <div className="text-sm text-gray-600">
                <span className="font-medium">2h ago:</span> Sent reminder via WhatsApp
              </div>
              <div className="text-sm text-gray-600">
                <span className="font-medium">1d ago:</span> Task assigned
              </div>
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
            onClick={() => {
              setEditedData({ ...editedData, status: 'completed' });
              handleSave();
            }}
            className="flex items-center gap-2 px-6 py-2.5 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-colors"
          >
            Mark Complete
          </button>
          <button
            onClick={onSendBuzz}
            className="flex items-center gap-2 px-6 py-2.5 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors"
          >
            <Send size={18} />
            Send Buzz
          </button>
          <button
            onClick={onReassign}
            className="flex items-center gap-2 px-6 py-2.5 bg-purple-600 text-white rounded-xl hover:bg-purple-700 transition-colors"
          >
            <UserPlus size={18} />
            Reassign
          </button>
          <button
            onClick={() => {
              if (confirm('Are you sure you want to delete this responsibility?')) {
                onDelete();
                onClose();
              }
            }}
            className="flex items-center gap-2 px-6 py-2.5 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-colors ml-auto"
          >
            <Trash2 size={18} />
            Delete
          </button>
        </div>
      </div>
    </div>
  );
}
