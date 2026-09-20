const clamp = (value, max = 1) => Math.min(max, Math.max(0, value));

// Sample every change of slope, including document boundaries. This preserves
// the original pixel-based motion even on short pages or after a resize.
export function scrollEffectFrames(kind, geometry, viewportHeight, limit) {
  const { top, height } = geometry;
  const stops = kind === 'hero'
    ? [top, top + height * .7, top + height]
    : [top - viewportHeight, top - viewportHeight * .2];
  const positions = [...new Set([0, limit, ...stops.map(y => clamp(y, limit))])].sort((a, b) => a - b);
  return positions.map(y => {
    if (kind === 'hero') return {
      offset: y / limit,
      translate: `0 ${clamp(y - top, height) * .35}px`,
      scale: String(1.2 - clamp((y - top) / (height * .7)) * .2),
    };
    return {
      offset: y / limit,
      scale: String(1.45 - clamp((viewportHeight - top + y) / (viewportHeight * .8)) * .45),
    };
  });
}

// Own these separately from timed entrances: finishing a reveal must never
// finish a scroll timeline. Unsupported browsers retain the JS fallback.
export function createScrollEffects(source, Timeline = globalThis.ScrollTimeline) {
  const effects = new Map();
  let timeline;
  const clear = () => {
    for (const animation of effects.values()) animation.cancel();
    effects.clear();
  };
  try { if (Timeline) timeline = new Timeline({ source, axis: 'block' }); } catch { /* Fallback. */ }
  return {
    sync(targets, viewportHeight, limit, reducedMotion) {
      if (!timeline || reducedMotion || limit <= 0) { clear(); return false; }
      try {
        const live = new Set(targets.map(target => target.element));
        for (const [element, animation] of effects) if (!live.has(element)) {
          animation.cancel(); effects.delete(element);
        }
        for (const { element, kind, geometry } of targets) {
          const frames = scrollEffectFrames(kind, geometry, viewportHeight, limit);
          const existing = effects.get(element);
          if (existing) existing.effect.setKeyframes(frames);
          else effects.set(element, element.animate(frames, {
            timeline, duration: 'auto', fill: 'both', easing: 'linear',
          }));
        }
        return true;
      } catch {
        clear(); timeline = undefined; return false;
      }
    },
    dispose: clear,
  };
}
