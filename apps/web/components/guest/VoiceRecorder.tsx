'use client';

import { useRef, useState } from 'react';
import { Mic, Square, Trash2 } from 'lucide-react';

export default function VoiceRecorder({ onRecorded }: { onRecorded: (file: File | null) => void }) {
  const [recording, setRecording] = useState(false);
  const [seconds, setSeconds] = useState(0);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const streamRef = useRef<MediaStream | null>(null);

  const start = async () => {
    setError(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      streamRef.current = stream;
      chunksRef.current = [];
      const recorder = new MediaRecorder(stream);
      recorder.ondataavailable = event => {
        if (event.data.size > 0) chunksRef.current.push(event.data);
      };
      recorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: recorder.mimeType || 'audio/webm' });
        const file = new File([blob], 'voice-message.webm', { type: blob.type });
        setPreviewUrl(URL.createObjectURL(blob));
        onRecorded(file);
        streamRef.current?.getTracks().forEach(track => track.stop());
      };
      mediaRecorderRef.current = recorder;
      recorder.start();
      setRecording(true);
      setSeconds(0);
      timerRef.current = setInterval(() => setSeconds(s => s + 1), 1000);
    } catch {
      setError("Couldn't access your microphone. Please allow microphone access and try again.");
    }
  };

  const stop = () => {
    mediaRecorderRef.current?.stop();
    setRecording(false);
    if (timerRef.current) clearInterval(timerRef.current);
  };

  const discard = () => {
    setPreviewUrl(null);
    onRecorded(null);
    setSeconds(0);
  };

  const format = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  if (previewUrl) {
    return (
      <div className="rounded-xl border border-gray-200 p-3 space-y-2">
        <audio controls src={previewUrl} className="w-full" />
        <button
          type="button"
          onClick={discard}
          className="flex items-center gap-1 text-xs text-red-500 font-medium"
        >
          <Trash2 size={14} /> Discard recording
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <button
        type="button"
        onClick={recording ? stop : start}
        className={`w-full py-3 rounded-xl text-sm font-semibold flex items-center justify-center gap-2 ${
          recording ? 'bg-red-500 text-white' : 'bg-gray-100 text-gray-700'
        }`}
      >
        {recording ? <Square size={16} /> : <Mic size={16} />}
        {recording ? `Recording... ${format(seconds)} (tap to stop)` : 'Record a voice message'}
      </button>
      {error && <p className="text-xs text-red-500">{error}</p>}
    </div>
  );
}
