export type TaskType = 'quote' | 'invoice' | 'social' | 'admin' | 'other';

export interface JobTask {
  id: string;
  title: string;
  type: TaskType;
  done: boolean;
  createdAt: number;
  linkedSessionCount: number;
}

export type SessionCategory = 'invoicing' | 'quoting' | 'social' | 'admin' | 'other';

export interface SessionRecord {
  id: string;
  category: SessionCategory;
  durationMin: number;
  completedAt: number;
  earned: number;
  taskId: string | null;
}

export type ItemZone = 'workshop' | 'garage' | 'van';

export interface WorkshopItem {
  id: string;
  name: string;
  zone: ItemZone;
  cost: number;
  emoji: string;
}

export interface AppState {
  materials: number;
  totalSessionsCompleted: number;
  totalFocusMinutes: number;
  unlockedItemIds: string[];
  tasks: JobTask[];
  sessionHistory: SessionRecord[];
  blockedApps: string[];
  streak: number;
  lastSessionDay: string | null;
}
