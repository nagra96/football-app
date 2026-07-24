import { useAppStore } from '../store/AppStore';
import { WORKSHOP_ITEMS, ZONE_ICONS, ZONE_LABELS } from '../data/catalog';
import type { ItemZone } from '../types';

export function WorkshopScreen() {
  const { state, dispatch } = useAppStore();
  const zones: ItemZone[] = ['workshop', 'garage', 'van'];

  return (
    <div className="flex flex-col gap-6 px-4 py-6 max-w-lg mx-auto w-full">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-bold text-stone-800 dark:text-stone-100">Build Your Site</h2>
        <span className="rounded-full bg-amber-100 dark:bg-stone-800 text-amber-700 dark:text-amber-300 px-3 py-1 text-sm font-semibold">
          🧱 {state.materials}
        </span>
      </div>

      {zones.map((zone) => {
        const items = WORKSHOP_ITEMS.filter((i) => i.zone === zone);
        const unlockedInZone = items.filter((i) => state.unlockedItemIds.includes(i.id)).length;
        return (
          <div key={zone} className="flex flex-col gap-2">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-semibold text-stone-600 dark:text-stone-300">
                {ZONE_ICONS[zone]} {ZONE_LABELS[zone]}
              </h3>
              <span className="text-xs text-stone-400">
                {unlockedInZone}/{items.length}
              </span>
            </div>
            <div className="grid grid-cols-2 gap-2">
              {items.map((item) => {
                const unlocked = state.unlockedItemIds.includes(item.id);
                const canAfford = state.materials >= item.cost;
                return (
                  <div
                    key={item.id}
                    className={`flex flex-col items-center gap-1 rounded-xl border px-3 py-3 text-center ${
                      unlocked
                        ? 'border-amber-300 bg-amber-50 dark:bg-stone-800 dark:border-amber-700'
                        : 'border-stone-200 dark:border-stone-700 bg-white dark:bg-stone-900'
                    }`}
                  >
                    <span className={`text-3xl ${unlocked ? '' : 'grayscale opacity-50'}`}>{item.emoji}</span>
                    <span className="text-xs font-medium text-stone-700 dark:text-stone-200">{item.name}</span>
                    {unlocked ? (
                      <span className="text-[11px] text-amber-600 font-semibold">Built ✓</span>
                    ) : (
                      <button
                        disabled={!canAfford}
                        onClick={() => dispatch({ type: 'UNLOCK_ITEM', id: item.id, cost: item.cost })}
                        className={`text-[11px] font-semibold rounded-full px-2 py-1 mt-1 ${
                          canAfford
                            ? 'bg-amber-500 text-white hover:bg-amber-600'
                            : 'bg-stone-100 dark:bg-stone-800 text-stone-400 cursor-not-allowed'
                        }`}
                      >
                        🧱 {item.cost}
                      </button>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}
