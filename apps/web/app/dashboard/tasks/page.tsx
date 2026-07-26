'use client';

import { useEffect, useState } from 'react';
import { Plus, Trash2 } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';

type Task = {
  id: number;
  title: string;
  due_date: string | null;
  priority: string | null;
  completed: boolean;
};

export default function DashboardTasksPage() {
  const { token } = useAuth();
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [title, setTitle] = useState('');
  const [adding, setAdding] = useState(false);

  const load = async () => {
    if (!token) return;
    try {
      const res = await api.get<{ data: Task[] }>('/plan/tasks', token);
      setTasks(res.data);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [token]);

  const addTask = async () => {
    if (!token || !title.trim()) return;
    setAdding(true);
    try {
      const res = await api.post<{ data: Task }>('/plan/tasks', { title: title.trim() }, token);
      setTasks((prev) => [...prev, res.data]);
      setTitle('');
    } finally {
      setAdding(false);
    }
  };

  const toggle = async (task: Task) => {
    if (!token) return;
    const updated = { ...task, completed: !task.completed };
    setTasks((prev) => prev.map((t) => (t.id === task.id ? updated : t)));
    await api.patch(`/plan/tasks/${task.id}`, { completed: updated.completed }, token);
  };

  const remove = async (task: Task) => {
    if (!token) return;
    setTasks((prev) => prev.filter((t) => t.id !== task.id));
    await api.delete(`/plan/tasks/${task.id}`, token);
  };

  if (loading) {
    return <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />;
  }

  return (
    <div className="max-w-2xl space-y-4">
      <h1 className="text-xl font-semibold text-gray-800">Tasks</h1>
      <div className="flex gap-2">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && addTask()}
          placeholder="Add a task..."
          className="flex-1 border border-gray-200 rounded-xl px-3 py-2 text-sm"
        />
        <button
          onClick={addTask}
          disabled={adding || !title.trim()}
          className="px-4 rounded-xl bg-[#285301] text-white disabled:opacity-50 flex items-center gap-1"
        >
          <Plus size={16} /> Add
        </button>
      </div>

      {tasks.length === 0 ? (
        <p className="text-sm text-gray-400 py-8 text-center">No tasks yet.</p>
      ) : (
        <div className="rounded-2xl border border-gray-200 bg-white divide-y divide-gray-100">
          {tasks.map((task) => (
            <div key={task.id} className="flex items-center gap-3 px-4 py-3">
              <input type="checkbox" checked={task.completed} onChange={() => toggle(task)} className="h-4 w-4 accent-[#285301]" />
              <span className={`flex-1 text-sm ${task.completed ? 'line-through text-gray-400' : 'text-gray-700'}`}>{task.title}</span>
              {task.due_date && <span className="text-xs text-gray-400">{new Date(task.due_date).toLocaleDateString()}</span>}
              <button onClick={() => remove(task)} className="text-gray-300 hover:text-red-400">
                <Trash2 size={14} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
