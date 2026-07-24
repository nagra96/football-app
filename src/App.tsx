import { useState } from 'react';
import { AppProvider, useAppStore } from './store/AppStore';
import { TimerScreen } from './components/TimerScreen';
import { TasksScreen } from './components/TasksScreen';
import { WorkshopScreen } from './components/WorkshopScreen';
import { SettingsScreen } from './components/SettingsScreen';

type Tab = 'clock' | 'tasks' | 'workshop' | 'settings';

const TABS: { id: Tab; label: string; icon: string }[] = [
  { id: 'clock', label: 'Clock', icon: '⏱️' },
  { id: 'tasks', label: 'Jobs', icon: '📋' },
  { id: 'workshop', label: 'Workshop', icon: '🏗️' },
  { id: 'settings', label: 'Settings', icon: '⚙️' },
];

function Shell() {
  const [tab, setTab] = useState<Tab>('clock');
  const { state } = useAppStore();

  return (
    <div className="min-h-svh flex flex-col bg-[#fdf6ea] dark:bg-[#14110d]">
      <header className="flex items-center justify-between px-4 py-3 border-b border-amber-200/60 dark:border-stone-800">
        <div className="flex items-center gap-2">
          <span className="text-xl">👷</span>
          <div>
            <h1 className="text-sm font-bold text-stone-800 dark:text-stone-100 leading-none">Site Buddy</h1>
            <p className="text-[11px] text-stone-500 leading-none mt-0.5">Buddy the Apprentice</p>
          </div>
        </div>
        <span className="rounded-full bg-amber-100 dark:bg-stone-800 text-amber-700 dark:text-amber-300 px-3 py-1 text-xs font-semibold">
          🧱 {state.materials}
        </span>
      </header>

      <main className="flex-1 overflow-y-auto">
        {tab === 'clock' && <TimerScreen />}
        {tab === 'tasks' && <TasksScreen />}
        {tab === 'workshop' && <WorkshopScreen />}
        {tab === 'settings' && <SettingsScreen />}
      </main>

      <nav className="grid grid-cols-4 border-t border-amber-200/60 dark:border-stone-800 bg-white/80 dark:bg-stone-900/80 backdrop-blur">
        {TABS.map((t) => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`flex flex-col items-center gap-0.5 py-2.5 text-xs font-medium transition ${
              tab === t.id ? 'text-amber-600' : 'text-stone-400 hover:text-stone-600 dark:hover:text-stone-300'
            }`}
          >
            <span className="text-lg leading-none">{t.icon}</span>
            {t.label}
          </button>
        ))}
      </nav>
    </div>
  );
}

function App() {
  return (
    <AppProvider>
      <div className="max-w-md mx-auto min-h-svh shadow-xl">
        <Shell />
      </div>
    </AppProvider>
  );
}

export default App;
