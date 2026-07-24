import { useState } from 'react';
import { useAppStore } from '../store/AppStore';
import { SUGGESTED_BLOCKED_APPS } from '../data/catalog';

export function SettingsScreen() {
  const { state, dispatch } = useAppStore();
  const [customApp, setCustomApp] = useState('');

  function toggleApp(app: string) {
    const active = state.blockedApps.includes(app);
    const next = active ? state.blockedApps.filter((a) => a !== app) : [...state.blockedApps, app];
    dispatch({ type: 'SET_BLOCKED_APPS', apps: next });
  }

  function addCustomApp(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = customApp.trim();
    if (!trimmed || state.blockedApps.includes(trimmed)) return;
    dispatch({ type: 'SET_BLOCKED_APPS', apps: [...state.blockedApps, trimmed] });
    setCustomApp('');
  }

  const hours = Math.floor(state.totalFocusMinutes / 60);
  const minutes = state.totalFocusMinutes % 60;

  return (
    <div className="flex flex-col gap-8 px-4 py-6 max-w-lg mx-auto w-full">
      <div>
        <h2 className="text-lg font-bold text-stone-800 dark:text-stone-100 mb-3">Your Stats</h2>
        <div className="grid grid-cols-3 gap-2 text-center">
          <StatCard label="Streak" value={`${state.streak}🔥`} />
          <StatCard label="Sessions" value={`${state.totalSessionsCompleted}`} />
          <StatCard label="Time on the clock" value={`${hours}h ${minutes}m`} />
        </div>
      </div>

      <div>
        <h2 className="text-lg font-bold text-stone-800 dark:text-stone-100 mb-2">App Blocking</h2>
        <p className="text-xs text-stone-500 mb-3">
          Pick the apps that pull you off the job. Site Buddy will remind you to keep them closed during a focus session.
          Real system-level blocking (iOS Screen Time / Android Digital Wellbeing) needs a native app build — this web MVP
          shows the reminder banner during your session instead.
        </p>
        <div className="flex flex-wrap gap-2 mb-3">
          {SUGGESTED_BLOCKED_APPS.map((app) => {
            const active = state.blockedApps.includes(app);
            return (
              <button
                key={app}
                onClick={() => toggleApp(app)}
                className={`rounded-full px-3 py-1.5 text-sm border transition ${
                  active
                    ? 'bg-amber-500 border-amber-500 text-white'
                    : 'bg-white dark:bg-stone-800 border-stone-200 dark:border-stone-700 text-stone-600 dark:text-stone-300'
                }`}
              >
                {app}
              </button>
            );
          })}
          {state.blockedApps
            .filter((a) => !SUGGESTED_BLOCKED_APPS.includes(a))
            .map((app) => (
              <button
                key={app}
                onClick={() => toggleApp(app)}
                className="rounded-full px-3 py-1.5 text-sm border bg-amber-500 border-amber-500 text-white"
              >
                {app} ✕
              </button>
            ))}
        </div>
        <form onSubmit={addCustomApp} className="flex gap-2">
          <input
            value={customApp}
            onChange={(e) => setCustomApp(e.target.value)}
            placeholder="Add another app or site"
            className="flex-1 rounded-lg border border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-800 px-3 py-2 text-sm text-stone-700 dark:text-stone-200"
          />
          <button type="submit" className="rounded-lg bg-stone-200 dark:bg-stone-700 px-4 py-2 text-sm font-semibold text-stone-700 dark:text-stone-200">
            Add
          </button>
        </form>
      </div>

      <div className="text-xs text-stone-400 border-t border-stone-200 dark:border-stone-700 pt-4">
        Site Buddy MVP — timer, tasks, and workshop rewards run fully offline in your browser. Your progress is saved on this device only.
      </div>
    </div>
  );
}

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-800 py-3">
      <p className="text-lg font-bold text-stone-800 dark:text-stone-100">{value}</p>
      <p className="text-[11px] text-stone-500">{label}</p>
    </div>
  );
}
