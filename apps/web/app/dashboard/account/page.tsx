'use client';

import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';

export default function DashboardAccountPage() {
  const { user, token, updateProfile } = useAuth();
  const [firstName, setFirstName] = useState(user?.first_name ?? '');
  const [lastName, setLastName] = useState(user?.last_name ?? '');
  const [email, setEmail] = useState(user?.email ?? '');
  const [savingProfile, setSavingProfile] = useState(false);
  const [profileMessage, setProfileMessage] = useState<string | null>(null);

  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [savingPassword, setSavingPassword] = useState(false);
  const [passwordMessage, setPasswordMessage] = useState<string | null>(null);

  const saveProfile = async () => {
    setSavingProfile(true);
    setProfileMessage(null);
    try {
      await updateProfile({ first_name: firstName, last_name: lastName, email });
      setProfileMessage('Profile updated.');
    } catch (e) {
      setProfileMessage(e instanceof Error ? e.message : 'Could not update profile.');
    } finally {
      setSavingProfile(false);
    }
  };

  const savePassword = async () => {
    if (!token) return;
    setSavingPassword(true);
    setPasswordMessage(null);
    try {
      await api.post(
        '/auth/change-password',
        { current_password: currentPassword, password: newPassword, password_confirmation: confirmPassword },
        token,
      );
      setPasswordMessage('Password updated.');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (e) {
      setPasswordMessage(e instanceof Error ? e.message : 'Could not update password.');
    } finally {
      setSavingPassword(false);
    }
  };

  return (
    <div className="max-w-lg space-y-8">
      <div>
        <h1 className="text-xl font-semibold text-gray-800 mb-4">Account</h1>
        <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input value={firstName} onChange={(e) => setFirstName(e.target.value)} placeholder="First name" className="border border-gray-200 rounded-xl px-3 py-2 text-sm" />
            <input value={lastName} onChange={(e) => setLastName(e.target.value)} placeholder="Last name" className="border border-gray-200 rounded-xl px-3 py-2 text-sm" />
          </div>
          <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="Email" type="email" className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" />
          <button onClick={saveProfile} disabled={savingProfile} className="px-4 py-2 rounded-xl bg-[#285301] text-white text-sm disabled:opacity-60">
            {savingProfile ? 'Saving...' : 'Save profile'}
          </button>
          {profileMessage && <p className="text-xs text-gray-500">{profileMessage}</p>}
        </div>
      </div>

      <div>
        <h2 className="text-base font-semibold text-gray-800 mb-4">Change password</h2>
        <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-3">
          <input type="password" value={currentPassword} onChange={(e) => setCurrentPassword(e.target.value)} placeholder="Current password" className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" />
          <input type="password" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} placeholder="New password" className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" />
          <input type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} placeholder="Confirm new password" className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" />
          <button
            onClick={savePassword}
            disabled={savingPassword || !currentPassword || newPassword.length < 8 || newPassword !== confirmPassword}
            className="px-4 py-2 rounded-xl bg-[#285301] text-white text-sm disabled:opacity-60"
          >
            {savingPassword ? 'Updating...' : 'Update password'}
          </button>
          {passwordMessage && <p className="text-xs text-gray-500">{passwordMessage}</p>}
        </div>
      </div>
    </div>
  );
}
