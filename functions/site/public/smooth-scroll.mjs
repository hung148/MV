// Wheel input adds distance to a bounded reserve. Reversing drops old momentum.
export function addScrollReserve(reserve, delta) {
  const base = reserve * delta < 0 ? 0 : reserve;
  return Math.max(-360, Math.min(360, base + delta));
}

export function drainScrollReserve(reserve, velocity, elapsedMs, speedLimit = 800) {
  // Integrate delayed frames in small steps instead of discarding their time.
  // Bound long stalls so returning to a busy tab cannot produce a large jump.
  let remainingMs = Math.max(0, Math.min(100, elapsedMs));
  if (!remainingMs) return { distance: 0, velocity };
  if (reserve * velocity < 0) velocity = 0;
  let distance = 0;
  while (remainingMs > 0) {
    const stepMs = Math.min(1000 / 120, remainingMs);
    const seconds = stepMs / 1000;
    const pending = reserve - distance;
    const desired = Math.sign(pending) * Math.min(speedLimit, Math.abs(pending) * 12);
    velocity += (desired - velocity) * (1 - Math.exp(-24 * seconds));
    velocity = Math.sign(velocity) * Math.min(speedLimit, Math.abs(velocity));
    distance += Math.sign(pending) * Math.min(Math.abs(pending), Math.abs(velocity) * seconds);
    remainingMs -= stepMs;
  }
  return { distance, velocity };
}

export function initSmoothScroll(onScrollFrame = () => {}) {
  const preference = matchMedia('(prefers-reduced-motion: reduce)');
  const lifecycle = new AbortController();
  const { signal } = lifecycle;
  let enabled = false, limit = 0, frame = 0, reserve = 0, velocity = 0, lastTime = 0;
  const measure = () => { limit = Math.max(0, document.documentElement.scrollHeight - document.documentElement.clientHeight); };
  const size = new ResizeObserver(measure);
  size.observe(document.documentElement);
  size.observe(document.body);
  measure();
  let position = window.scrollY, lastPosition = window.scrollY;
  function reset() {
    cancelAnimationFrame(frame); frame = 0;
    reserve = velocity = 0;
    position = lastPosition = window.scrollY;
  }
  function tick(time) {
    frame = 0;
    if (!enabled) return;
    if (Math.abs(window.scrollY - lastPosition) > 2) { reset(); return; }
    const elapsed = time - lastTime;
    // Animation state must not change input responsiveness mid-gesture.
    // Rendering optimizations live in motion.js; input retains one predictable cap.
    // A cold image/raster frame must not become an 80px catch-up jump.
    // Keep unspent distance in reserve and resume over subsequent frames.
    const step = drainScrollReserve(reserve, velocity, Math.min(32, elapsed));
    lastTime = time;
    velocity = step.velocity;
    reserve -= step.distance;
    position = Math.max(0, Math.min(limit, position + step.distance));
    // One scroll owner, without a second library's listeners/state updates.
    window.scrollTo({ top: position, behavior: 'instant' });
    // Compare the next frame against the commanded position. Reading scrollY
    // immediately after writing forces the browser to synchronize scrolling.
    // The 2px interruption tolerance already covers device-pixel rounding.
    lastPosition = position;
    onScrollFrame();
    if (Math.abs(reserve) < .5 || (position <= 0 && reserve < 0) || (position >= limit && reserve > 0)) {
      reserve = velocity = 0;
      return;
    }
    frame = requestAnimationFrame(tick);
  }
  function sync() {
    const blocked = preference.matches || document.hidden
      || document.body.classList.contains('modal-open')
      || document.documentElement.classList.contains('menu-open');
    enabled = !blocked;
    if (blocked) reset();
  }
  // No touchmove listener: touch momentum and pinch zoom remain browser-owned.
  window.addEventListener('wheel', event => {
    if (!enabled || event.defaultPrevented || !event.cancelable || event.ctrlKey || event.shiftKey
      || Math.abs(event.deltaX) > Math.abs(event.deltaY)
      || event.target.closest?.('dialog, textarea, input, select, #navigation, [data-lenis-prevent]')) {
      reset(); return;
    }
    const delta = event.deltaY * (event.deltaMode === 1 ? 100 / 6 : event.deltaMode === 2 ? innerHeight : 1);
    if (!delta) return;
    event.preventDefault();
    if (!frame) position = lastPosition = window.scrollY;
    if (reserve * delta < 0) velocity = 0;
    reserve = addScrollReserve(reserve, delta);
    if (!frame && reserve) { lastTime = performance.now(); frame = requestAnimationFrame(tick); }
  }, { passive: false, signal });
  document.addEventListener('keydown', event => {
    if (['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End', ' ', 'Escape'].includes(event.key)) reset();
  }, { capture: true, signal });
  document.addEventListener('pointerdown', reset, { passive: true, signal });
  document.addEventListener('focusin', reset, { signal });
  let viewportWidth = innerWidth;
  window.addEventListener('resize', () => {
    measure();
    // Mobile browser chrome changes height during swipes; preserve their reserve.
    if (innerWidth !== viewportWidth) { viewportWidth = innerWidth; reset(); }
  }, { passive: true, signal });
  window.addEventListener('pagehide', () => { reset(); enabled = false; }, { signal });
  window.addEventListener('pageshow', sync, { signal });
  document.addEventListener('visibilitychange', sync, { signal });
  preference.addEventListener('change', sync, { signal });
  const overlays = new MutationObserver(sync);
  overlays.observe(document.body, { attributes: true, attributeFilter: ['class'] });
  overlays.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });
  sync();
  return () => { lifecycle.abort(); overlays.disconnect(); size.disconnect(); reset(); };
}
