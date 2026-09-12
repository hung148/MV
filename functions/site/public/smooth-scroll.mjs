import Lenis from './vendor/lenis.mjs';

// Wheel input adds distance to a bounded reserve. Reversing drops old momentum.
export function addScrollReserve(reserve, delta) {
  const base = reserve * delta < 0 ? 0 : reserve;
  return Math.max(-360, Math.min(360, base + delta));
}

export function drainScrollReserve(reserve, velocity, elapsedMs, speedLimit = 400) {
  const seconds = Math.max(0, Math.min(32, elapsedMs)) / 1000;
  if (!seconds) return { distance: 0, velocity };
  if (reserve * velocity < 0) velocity = 0;
  const desired = Math.sign(reserve) * Math.min(speedLimit, Math.abs(reserve) * 5);
  velocity += (desired - velocity) * (1 - Math.exp(-14 * seconds));
  velocity = Math.sign(velocity) * Math.min(speedLimit, Math.abs(velocity));
  const distance = Math.sign(reserve) * Math.min(Math.abs(reserve), Math.abs(velocity) * seconds);
  return { distance, velocity };
}

export function initSmoothScroll(onScrollFrame = () => {}) {
  const preference = matchMedia('(prefers-reduced-motion: reduce)');
  const lifecycle = new AbortController();
  const { signal } = lifecycle;
  let lenis, frame = 0, reserve = 0, velocity = 0, lastTime = 0;
  let position = window.scrollY, lastPosition = window.scrollY;
  let busy = false, lastBusyCheck = -Infinity;
  let currentLimit = 160;
  function animationBusy(time) {
    if (time - lastBusyCheck < 100) return busy;
    lastBusyCheck = time;
    // Offscreen word animations are finished by the visibility observer.
    // Avoid measuring every animated word during a scroll frame.
    busy = !!document.querySelector('#main .motion-active');
    const video = document.querySelector('#main video');
    if (video) {
      busy ||= !video.paused && video.readyState < 3;
    }
    return busy;
  }
  function reset() {
    cancelAnimationFrame(frame); frame = 0;
    reserve = velocity = 0;
    position = lastPosition = window.scrollY;
    lenis?.scrollTo(position, { immediate: true, force: true });
  }
  function tick(time) {
    frame = 0;
    if (!lenis) return;
    if (Math.abs(window.scrollY - lastPosition) > 2) { reset(); return; }
    const elapsed = time - lastTime;
    const targetLimit = animationBusy(time) ? 160 : 400;
    // Avoid a sudden velocity change when an entrance starts or completes.
    currentLimit += (targetLimit - currentLimit) * (1 - Math.exp(-6 * Math.min(32, Math.max(0, elapsed)) / 1000));
    const step = drainScrollReserve(reserve, velocity, elapsed, currentLimit);
    lastTime = time;
    velocity = step.velocity;
    reserve -= step.distance;
    position = Math.max(0, Math.min(lenis.limit, position + step.distance));
    lenis.scrollTo(position, { immediate: true, force: true });
    lastPosition = window.scrollY;
    onScrollFrame();
    if (Math.abs(reserve) < .5 || (position <= 0 && reserve < 0) || (position >= lenis.limit && reserve > 0)) {
      reserve = velocity = 0;
      return;
    }
    frame = requestAnimationFrame(tick);
  }
  function sync() {
    const blocked = preference.matches || document.hidden
      || document.body.classList.contains('modal-open')
      || document.documentElement.classList.contains('menu-open');
    if (blocked) { reset(); lenis?.destroy(); lenis = undefined; return; }
    if (lenis) return;
    lenis = new Lenis({
      autoRaf: false, syncTouch: false,
      virtualScroll(data) {
        const event = data.event;
        if (event.type !== 'wheel') { reset(); return false; }
        if (!event.cancelable || event.ctrlKey || event.shiftKey || Math.abs(data.deltaX) > Math.abs(data.deltaY)
          || event.target.closest?.('dialog, textarea, input, select, #navigation, [data-lenis-prevent]')) {
          reset(); return false;
        }
        event.preventDefault();
        if (!frame) position = lastPosition = window.scrollY;
        if (reserve * data.deltaY < 0) velocity = 0;
        reserve = addScrollReserve(reserve, data.deltaY);
        if (!frame && reserve) { lastTime = performance.now(); frame = requestAnimationFrame(tick); }
        return false;
      },
    });
  }
  document.addEventListener('keydown', event => {
    if (['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End', ' ', 'Escape'].includes(event.key)) reset();
  }, { capture: true, signal });
  document.addEventListener('pointerdown', reset, { passive: true, signal });
  document.addEventListener('focusin', reset, { signal });
  window.addEventListener('resize', reset, { passive: true, signal });
  window.addEventListener('pagehide', () => { reset(); lenis?.destroy(); lenis = undefined; }, { signal });
  window.addEventListener('pageshow', sync, { signal });
  document.addEventListener('visibilitychange', sync, { signal });
  preference.addEventListener('change', sync, { signal });
  const overlays = new MutationObserver(sync);
  overlays.observe(document.body, { attributes: true, attributeFilter: ['class'] });
  overlays.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });
  sync();
  return () => { lifecycle.abort(); overlays.disconnect(); reset(); lenis?.destroy(); };
}
