import { createContext, useContext, useEffect, useMemo, useReducer, type ReactNode } from 'react';
import type { AppState, JobTask, SessionCategory, TaskType } from '../types';
import { useLocalStorage } from './useLocalStorage';

const STORAGE_KEY = 'site-buddy-state-v1';

const initialState: AppState = {
  materials: 0,
  totalSessionsCompleted: 0,
  totalFocusMinutes: 0,
  unlockedItemIds: [],
  tasks: [],
  sessionHistory: [],
  blockedApps: ['Instagram', 'TikTok'],
  streak: 0,
  lastSessionDay: null,
};

type Action =
  | { type: 'ADD_TASK'; title: string; taskType: TaskType }
  | { type: 'TOGGLE_TASK'; id: string }
  | { type: 'DELETE_TASK'; id: string }
  | { type: 'COMPLETE_SESSION'; category: SessionCategory; durationMin: number; earned: number; taskId: string | null }
  | { type: 'UNLOCK_ITEM'; id: string; cost: number }
  | { type: 'SET_BLOCKED_APPS'; apps: string[] };

function todayKey(): string {
  return new Date().toISOString().slice(0, 10);
}

function nextStreak(state: AppState): number {
  const today = todayKey();
  if (state.lastSessionDay === today) return state.streak;
  if (!state.lastSessionDay) return 1;
  const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
  return state.lastSessionDay === yesterday ? state.streak + 1 : 1;
}

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case 'ADD_TASK': {
      const task: JobTask = {
        id: crypto.randomUUID(),
        title: action.title,
        type: action.taskType,
        done: false,
        createdAt: Date.now(),
        linkedSessionCount: 0,
      };
      return { ...state, tasks: [task, ...state.tasks] };
    }
    case 'TOGGLE_TASK':
      return {
        ...state,
        tasks: state.tasks.map((t) => (t.id === action.id ? { ...t, done: !t.done } : t)),
      };
    case 'DELETE_TASK':
      return { ...state, tasks: state.tasks.filter((t) => t.id !== action.id) };
    case 'COMPLETE_SESSION': {
      const record = {
        id: crypto.randomUUID(),
        category: action.category,
        durationMin: action.durationMin,
        completedAt: Date.now(),
        earned: action.earned,
        taskId: action.taskId,
      };
      return {
        ...state,
        materials: state.materials + action.earned,
        totalSessionsCompleted: state.totalSessionsCompleted + 1,
        totalFocusMinutes: state.totalFocusMinutes + action.durationMin,
        sessionHistory: [record, ...state.sessionHistory].slice(0, 50),
        streak: nextStreak(state),
        lastSessionDay: todayKey(),
        tasks: action.taskId
          ? state.tasks.map((t) =>
              t.id === action.taskId ? { ...t, linkedSessionCount: t.linkedSessionCount + 1 } : t,
            )
          : state.tasks,
      };
    }
    case 'UNLOCK_ITEM':
      if (state.unlockedItemIds.includes(action.id) || state.materials < action.cost) return state;
      return {
        ...state,
        materials: state.materials - action.cost,
        unlockedItemIds: [...state.unlockedItemIds, action.id],
      };
    case 'SET_BLOCKED_APPS':
      return { ...state, blockedApps: action.apps };
    default:
      return state;
  }
}

interface Ctx {
  state: AppState;
  dispatch: React.Dispatch<Action>;
}

const AppContext = createContext<Ctx | null>(null);

export function AppProvider({ children }: { children: ReactNode }) {
  const [persisted, setPersisted] = useLocalStorage<AppState>(STORAGE_KEY, initialState);
  const [state, rawDispatch] = useReducer(reducer, persisted);

  useEffect(() => {
    setPersisted(state);
  }, [state, setPersisted]);

  const value = useMemo(() => ({ state, dispatch: rawDispatch }), [state]);

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useAppStore() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useAppStore must be used within AppProvider');
  return ctx;
}
