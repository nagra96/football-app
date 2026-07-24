import { useState } from 'react';
import { useAppStore } from '../store/AppStore';
import { TASK_TYPE_LABELS } from '../data/catalog';
import type { TaskType } from '../types';

const TYPE_ICON: Record<TaskType, string> = {
  quote: '📝',
  invoice: '💷',
  social: '📱',
  admin: '🗂️',
  other: '📌',
};

export function TasksScreen() {
  const { state, dispatch } = useAppStore();
  const [title, setTitle] = useState('');
  const [type, setType] = useState<TaskType>('quote');

  function addTask(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = title.trim();
    if (!trimmed) return;
    dispatch({ type: 'ADD_TASK', title: trimmed, taskType: type });
    setTitle('');
  }

  const open = state.tasks.filter((t) => !t.done);
  const done = state.tasks.filter((t) => t.done);

  return (
    <div className="flex flex-col gap-6 px-4 py-6 max-w-lg mx-auto w-full">
      <h2 className="text-lg font-bold text-stone-800 dark:text-stone-100">The Job List</h2>

      <form onSubmit={addTask} className="flex flex-col gap-2">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="e.g. Send quote to Mrs. Patel"
          className="rounded-lg border border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-800 px-3 py-2 text-sm text-stone-700 dark:text-stone-200"
        />
        <div className="flex gap-2">
          <select
            value={type}
            onChange={(e) => setType(e.target.value as TaskType)}
            className="flex-1 rounded-lg border border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-800 px-3 py-2 text-sm text-stone-700 dark:text-stone-200"
          >
            {(Object.keys(TASK_TYPE_LABELS) as TaskType[]).map((t) => (
              <option key={t} value={t}>
                {TYPE_ICON[t]} {TASK_TYPE_LABELS[t]}
              </option>
            ))}
          </select>
          <button
            type="submit"
            className="rounded-lg bg-amber-500 px-4 py-2 text-sm font-semibold text-white hover:bg-amber-600 active:scale-95 transition"
          >
            Add
          </button>
        </div>
      </form>

      <div className="flex flex-col gap-2">
        {open.length === 0 && done.length === 0 && (
          <p className="text-sm text-stone-500 text-center py-6">No jobs on the board yet. Add a quote or invoice to chase.</p>
        )}
        {open.map((t) => (
          <TaskRow key={t.id} id={t.id} title={t.title} type={t.type} done={t.done} linked={t.linkedSessionCount} />
        ))}
        {done.length > 0 && (
          <>
            <p className="text-xs font-semibold uppercase tracking-wide text-stone-400 mt-4 mb-1">Wrapped up</p>
            {done.map((t) => (
              <TaskRow key={t.id} id={t.id} title={t.title} type={t.type} done={t.done} linked={t.linkedSessionCount} />
            ))}
          </>
        )}
      </div>
    </div>
  );
}

function TaskRow({
  id,
  title,
  type,
  done,
  linked,
}: {
  id: string;
  title: string;
  type: TaskType;
  done: boolean;
  linked: number;
}) {
  const { dispatch } = useAppStore();
  return (
    <div
      className={`flex items-center gap-3 rounded-lg border px-3 py-2 ${
        done
          ? 'border-stone-200 dark:border-stone-800 bg-stone-50 dark:bg-stone-900 opacity-60'
          : 'border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-800'
      }`}
    >
      <button
        onClick={() => dispatch({ type: 'TOGGLE_TASK', id })}
        className={`h-5 w-5 shrink-0 rounded border flex items-center justify-center text-xs ${
          done ? 'bg-amber-500 border-amber-500 text-white' : 'border-stone-300 dark:border-stone-600'
        }`}
        aria-label={done ? 'Mark as not done' : 'Mark as done'}
      >
        {done ? '✓' : ''}
      </button>
      <span className="text-lg">{TYPE_ICON[type]}</span>
      <div className="flex-1 min-w-0">
        <p className={`text-sm text-stone-700 dark:text-stone-200 truncate ${done ? 'line-through' : ''}`}>{title}</p>
        {linked > 0 && <p className="text-[11px] text-stone-400">{linked} focus session{linked > 1 ? 's' : ''} logged</p>}
      </div>
      <button
        onClick={() => dispatch({ type: 'DELETE_TASK', id })}
        className="text-stone-400 hover:text-red-500 text-sm px-1"
        aria-label="Delete task"
      >
        ✕
      </button>
    </div>
  );
}
