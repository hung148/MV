// Native Web Animations lifecycle shared by all timed effects.
// Dependencies are injectable so interruption/reduced-motion behavior is testable.
export function createMotionController(preference) {
  const active = new Map();
  const finish = () => {
    for (const animation of active.values()) {
      try { animation.finish(); } catch { animation.cancel(); }
    }
  };
  preference.addEventListener('change', onPreference);
  function onPreference() { if (preference.matches) finish(); }
  return {
    play(element, frames, options = {}) {
      active.get(element)?.cancel();
      if (preference.matches || !element.animate) return Promise.resolve();
      const animation = element.animate(frames, {
        duration: 300, easing: 'cubic-bezier(.16,1,.3,1)', ...options,
      });
      active.set(element, animation);
      element.classList.add('motion-active');
      return animation.finished.catch(() => {}).finally(() => {
        if (active.get(element) !== animation) return;
        active.delete(element);
        element.classList.remove('motion-active');
        // Restore CSS ownership; do not leave filled animation layers attached.
        animation.cancel();
      });
    },
    finish,
    dispose() {
      preference.removeEventListener('change', onPreference);
      for (const animation of active.values()) animation.cancel();
    },
  };
}
