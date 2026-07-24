import type { ItemZone, SessionCategory, TaskType, WorkshopItem } from '../types';

export const CATEGORY_LABELS: Record<SessionCategory, string> = {
  invoicing: 'Invoicing',
  quoting: 'Quoting',
  social: 'Social & Marketing',
  admin: 'General Admin',
  other: 'Other',
};

export const TASK_TYPE_LABELS: Record<TaskType, string> = {
  quote: 'Quote to send',
  invoice: 'Invoice to chase',
  social: 'Social post',
  admin: 'Admin task',
  other: 'Other',
};

export const TASK_TYPE_TO_CATEGORY: Record<TaskType, SessionCategory> = {
  quote: 'quoting',
  invoice: 'invoicing',
  social: 'social',
  admin: 'admin',
  other: 'other',
};

export const DURATIONS = [
  { minutes: 25, label: '25 min', reward: 5, hint: 'Quick job' },
  { minutes: 45, label: '45 min', reward: 10, hint: 'Half shift' },
  { minutes: 60, label: '60 min', reward: 15, hint: 'Full clock-in' },
] as const;

export const ZONE_LABELS: Record<ItemZone, string> = {
  workshop: 'Workshop',
  garage: 'Garage',
  van: 'Van',
};

export const ZONE_ICONS: Record<ItemZone, string> = {
  workshop: '🛠️',
  garage: '🚪',
  van: '🚐',
};

export const WORKSHOP_ITEMS: WorkshopItem[] = [
  { id: 'workbench', name: 'Workbench', zone: 'workshop', cost: 10, emoji: '🪚' },
  { id: 'pegboard', name: 'Tool Pegboard', zone: 'workshop', cost: 15, emoji: '🧰' },
  { id: 'drill', name: 'Cordless Drill', zone: 'workshop', cost: 20, emoji: '🔩' },
  { id: 'shelving', name: 'Steel Shelving', zone: 'workshop', cost: 25, emoji: '🗄️' },
  { id: 'radio', name: 'Job Site Radio', zone: 'workshop', cost: 30, emoji: '📻' },
  { id: 'ladder', name: 'Step Ladder', zone: 'garage', cost: 15, emoji: '🪜' },
  { id: 'toolbox', name: 'Rolling Toolbox', zone: 'garage', cost: 20, emoji: '🧳' },
  { id: 'compressor', name: 'Air Compressor', zone: 'garage', cost: 35, emoji: '🛞' },
  { id: 'lift', name: 'Vehicle Lift', zone: 'garage', cost: 60, emoji: '⚙️' },
  { id: 'sign', name: 'Business Sign', zone: 'garage', cost: 40, emoji: '🪧' },
  { id: 'racks', name: 'Van Shelving Racks', zone: 'van', cost: 25, emoji: '📦' },
  { id: 'ladder-rack', name: 'Roof Ladder Rack', zone: 'van', cost: 35, emoji: '🚧' },
  { id: 'wrap', name: 'Custom Van Wrap', zone: 'van', cost: 50, emoji: '🎨' },
  { id: 'gps', name: 'Fleet GPS Tracker', zone: 'van', cost: 45, emoji: '📍' },
  { id: 'coffee', name: 'Site Coffee Machine', zone: 'van', cost: 20, emoji: '☕' },
];

export const SUGGESTED_BLOCKED_APPS = [
  'Instagram',
  'TikTok',
  'Facebook',
  'X / Twitter',
  'YouTube',
  'Snapchat',
];
