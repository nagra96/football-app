import { useEffect, useRef, useState } from 'react';
import { useAppStore } from '../store/AppStore';
import { CATEGORY_LABELS, DURATIONS, TASK_TYPE_TO_CATEGORY } from '../data/catalog';
import type { SessionCategory } from '../types';
import { Mascot, mascotLine, type MascotMood } from './Mascot';

function formatTime(totalSeconds: number) {
  const m = Math.floor(totalSeconds / 60)
    .toString()
    .padStart(2, '0');
  const s = Math.floor(totalSeconds % 60)
    .toString()
    .padStart(2, '0');
  return `${m}:${s}`;
}

export function TimerScreen() {
  const { state, dispatch } = useAppStore();
  const openTasks = state.tasks.filter((t) => !t.done);

  const [category, setCategory] = useState<SessionCategory>('admin');
  const [durationMin, setDurationMin] = useState<number>(25);
  const [taskId, setTaskId] = useState<string>('');

  const [secondsLeft, setSecondsLeft] = useState<number | null>(null);
  const [running, setRunning] = useState(false);
  const [justCompleted, setJustCompleted] = useState<{ earned: number } | null>(null);
  const [distractionCount, setDistractionCount] = useState(0);
  const hiddenAtRef = useRef<number | null>(null);

  useEffect(() => {
    if (!running || secondsLeft === null) return;
    if (secondsLeft <= 0) {
      const reward = DURATIONS.find((d) => d.minutes === durationMin)?.reward ?? 5;
      dispatch({ type: 'COMPLETE_SESSION', category, durationMin, earned: reward, taskId: taskId || null });
      setRunning(false);
      setJustCompleted({ earned: reward });
      return;
    }
    const id = window.setInterval(() => setSecondsLeft((s) => (s !== null ? s - 1 : s)), 1000);
    return () => window.clearInterval(id);
  }, [running, secondsLeft, category, durationMin, taskId, dispatch]);

  useEffect(() => {
    function onVisibility() {
      if (!running) return;
      if (document.hidden) {
        hiddenAtRef.current = Date.now();
      } else if (hiddenAtRef.current) {
        setDistractionCount((c) => c + 1);
        hiddenAtRef.current = null;
      }
    }
    document.addEventListener('visibilitychange', onVisibility);
    return () => document.removeEventListener('visibilitychange', onVisibility);
  }, [running]);

  const sessionActive = secondsLeft !== null && !justCompleted;
  const totalSeconds = durationMin * 60;
  const progress = sessionActive ? 1 - (secondsLeft as number) / totalSeconds : 0;

  function startSession() {
    setSecondsLeft(durationMin * 60);
    setRunning(true);
    setJustCompleted(null);
    setDistractionCount(0);
  }

  function cancelSession() {
    setSecondsLeft(null);
    setRunning(false);
  }

  function acknowledgeCompletion() {
    setSecondsLeft(null);
    setJustCompleted(null);
  }

  let mood: MascotMood = 'idle';
  if (justCompleted) mood = 'celebrating';
  else if (sessionActive && running) mood = 'working';
  else if (sessionActive && !running) mood = 'paused';

  return (
    <div className="flex flex-col items-center gap-6 px-4 py-6">
      <Mascot mood={mood} />
      <p className="text-sm text-amber-900/70 dark:text-amber-200/70 italic min-h-5">
        {mascotLine(mood, Math.floor(Date.now() / 30000))}
      </p>

      {justCompleted ? (
        <div className="flex flex-col items-center gap-4 text-center">
          <h2 className="text-2xl font-bold text-amber-900 dark:text-amber-200">Job done!</h2>
          <p className="text-stone-600 dark:text-stone-300">
            You earned <span className="font-semibold text-amber-600">+{justCompleted.earned} materials 🧱</span>
          </p>
          {distractionCount > 0 && (
            <p className="text-xs text-stone-500">
              Left the site {distractionCount} time{distractionCount > 1 ? 's' : ''} mid-shift — try to stay on the clock next time.
            </p>
          )}
          <button
            onClick={acknowledgeCompletion}
            className="rounded-full bg-amber-500 px-6 py-2.5 font-semibold text-white shadow hover:bg-amber-600 active:scale-95 transition"
          >
            Back to the site
          </button>
        </div>
      ) : sessionActive ? (
        <div className="flex flex-col items-center gap-5 w-full max-w-sm">
          <div className="relative flex items-center justify-center">
            <svg width="180" height="180" className="-rotate-90">
              <circle cx="90" cy="90" r="80" strokeWidth="12" className="stroke-amber-100 dark:stroke-stone-700" fill="none" />
              <circle
                cx="90"
                cy="90"
                r="80"
                strokeWidth="12"
                fill="none"
                strokeLinecap="round"
                className="stroke-amber-500 transition-all duration-1000"
                strokeDasharray={2 * Math.PI * 80}
                strokeDashoffset={2 * Math.PI * 80 * (1 - progress)}
              />
            </svg>
            <span className="absolute text-3xl font-bold tabular-nums text-stone-800 dark:text-stone-100">
              {formatTime(secondsLeft as number)}
            </span>
          </div>

          <div className="rounded-xl bg-amber-50 dark:bg-stone-800 border border-amber-200 dark:border-stone-700 px-4 py-2 text-sm text-center text-amber-800 dark:text-amber-200 w-full">
            🚧 <strong>Focus Mode</strong> — {state.blockedApps.length > 0 ? state.blockedApps.join(', ') : 'no apps blocked'}
            {' '}
            should stay closed while you're on the clock.
          </div>

          <div className="flex gap-3">
            <button
              onClick={() => setRunning((r) => !r)}
              className="rounded-full bg-amber-500 px-6 py-2.5 font-semibold text-white shadow hover:bg-amber-600 active:scale-95 transition"
            >
              {running ? 'Pause' : 'Resume'}
            </button>
            <button
              onClick={cancelSession}
              className="rounded-full bg-stone-200 dark:bg-stone-700 px-6 py-2.5 font-semibold text-stone-700 dark:text-stone-200 hover:bg-stone-300 dark:hover:bg-stone-600 active:scale-95 transition"
            >
              Cancel
            </button>
          </div>
        </div>
      ) : (
        <div className="flex flex-col gap-5 w-full max-w-sm">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wide text-stone-500 mb-2">What are you working on?</label>
            <div className="grid grid-cols-2 gap-2">
              {(Object.keys(CATEGORY_LABELS) as SessionCategory[]).map((c) => (
                <button
                  key={c}
                  onClick={() => setCategory(c)}
                  className={`rounded-lg px-3 py-2 text-sm font-medium border transition ${
                    category === c
                      ? 'bg-amber-500 border-amber-500 text-white'
                      : 'bg-white dark:bg-stone-800 border-stone-200 dark:border-stone-700 text-stone-600 dark:text-stone-300 hover:border-amber-300'
                  }`}
                >
                  {CATEGORY_LABELS[c]}
                </button>
              ))}
            </div>
          </div>

          {openTasks.length > 0 && (
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wide text-stone-500 mb-2">Link a task (optional)</label>
              <select
                value={taskId}
                onChange={(e) => {
                  const id = e.target.value;
                  setTaskId(id);
                  const t = state.tasks.find((task) => task.id === id);
                  if (t) setCategory(TASK_TYPE_TO_CATEGORY[t.type]);
                }}
                className="w-full rounded-lg border border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-800 px-3 py-2 text-sm text-stone-700 dark:text-stone-200"
              >
                <option value="">No specific task</option>
                {openTasks.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.title}
                  </option>
                ))}
              </select>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wide text-stone-500 mb-2">On the Clock for</label>
            <div className="grid grid-cols-3 gap-2">
              {DURATIONS.map((d) => (
                <button
                  key={d.minutes}
                  onClick={() => setDurationMin(d.minutes)}
                  className={`flex flex-col items-center rounded-lg px-3 py-3 border transition ${
                    durationMin === d.minutes
                      ? 'bg-amber-500 border-amber-500 text-white'
                      : 'bg-white dark:bg-stone-800 border-stone-200 dark:border-stone-700 text-stone-600 dark:text-stone-300 hover:border-amber-300'
                  }`}
                >
                  <span className="font-bold">{d.label}</span>
                  <span className="text-[11px] opacity-80">{d.hint}</span>
                </button>
              ))}
            </div>
          </div>

          <button
            onClick={startSession}
            className="rounded-full bg-amber-500 px-6 py-3 font-semibold text-white shadow hover:bg-amber-600 active:scale-95 transition"
          >
            Clock In 🔨
          </button>
        </div>
      )}
    </div>
  );
}
