export type MascotMood = 'idle' | 'working' | 'celebrating' | 'paused';

const MOOD_LINES: Record<MascotMood, string[]> = {
  idle: ["Ready when you are, boss.", "Pick a job and let's clock in.", "Tools are sharp and ready."],
  working: ["On it! Stay on the clock.", "Don't touch that phone, we're mid-job.", "Almost got this nailed down."],
  celebrating: ["Job done! Nice work.", "That's a wrap — pay day!", "Knocked it out of the park."],
  paused: ["Taking five? Fair enough.", "Clock's paused, come back soon."],
};

export function mascotLine(mood: MascotMood, seed: number): string {
  const lines = MOOD_LINES[mood];
  return lines[seed % lines.length];
}

export function Mascot({ mood, size = 140 }: { mood: MascotMood; size?: number }) {
  const bodyClass = mood === 'working' ? 'animate-bob' : mood === 'celebrating' ? 'animate-bounce-in' : '';
  const armClass = mood === 'working' ? 'animate-swing' : '';

  return (
    <div className={`relative select-none ${bodyClass}`} style={{ width: size, height: size }}>
      <svg viewBox="0 0 100 100" width={size} height={size} role="img" aria-label="Buddy the Apprentice mascot">
        {/* body */}
        <rect x="30" y="52" width="40" height="34" rx="10" fill="#f6a821" />
        {/* head */}
        <circle cx="50" cy="40" r="22" fill="#ffd9a0" />
        {/* hard hat */}
        <path d="M25 34 a25 20 0 0 1 50 0 z" fill="#f6a821" stroke="#c97e0f" strokeWidth="2" />
        <rect x="22" y="32" width="56" height="6" rx="3" fill="#c97e0f" />
        {/* face */}
        {mood === 'celebrating' ? (
          <>
            <path d="M42 42 q3 4 6 0" stroke="#2b2320" strokeWidth="2.5" fill="none" strokeLinecap="round" />
            <path d="M52 42 q3 4 6 0" stroke="#2b2320" strokeWidth="2.5" fill="none" strokeLinecap="round" />
          </>
        ) : (
          <>
            <circle cx="44" cy="41" r="2.4" fill="#2b2320" />
            <circle cx="56" cy="41" r="2.4" fill="#2b2320" />
          </>
        )}
        <path
          d={mood === 'paused' ? 'M44 50 q6 -2 12 0' : mood === 'celebrating' ? 'M42 48 q8 8 16 0' : 'M43 49 q7 5 14 0'}
          stroke="#2b2320"
          strokeWidth="2.5"
          fill="none"
          strokeLinecap="round"
        />
        {/* arm + tool */}
        <g className={armClass} style={{ transformOrigin: '72px 58px' }}>
          <rect x="68" y="56" width="8" height="24" rx="4" fill="#ffd9a0" />
          <rect x="70" y="74" width="18" height="6" rx="3" fill="#8a8a8a" transform="rotate(30 70 74)" />
        </g>
        <rect x="24" y="56" width="8" height="24" rx="4" fill="#ffd9a0" />
        {/* legs */}
        <rect x="36" y="84" width="10" height="12" rx="3" fill="#4a4238" />
        <rect x="54" y="84" width="10" height="12" rx="3" fill="#4a4238" />
      </svg>
      {mood === 'celebrating' && (
        <span className="absolute -top-2 left-1/2 -translate-x-1/2 text-2xl" style={{ animation: 'pop 0.9s ease-out forwards' }}>
          ⭐
        </span>
      )}
    </div>
  );
}
