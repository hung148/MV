import { createMotionController } from './motion-controller.mjs';
// Localized motion only: never rebuild page content on a scroll frame.
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
export const motion = createMotionController(reducedMotion);
const animate = (element, frames, options) => motion.play(element, frames, options);
window.addEventListener('pagehide', () => motion.finish());

export function revealDialog(dialog) {
  return animate(dialog, [{ opacity: 0, transform: 'scale(.85)' }, { opacity: 1, transform: 'scale(1)' }], { duration: 350 });
}
export function initMotion() {
  const lifecycle = new AbortController();
  const signal = lifecycle.signal;
  const cleanup = [];
  let disposed = false;
  // Only finish entrances once the hero leaves view, rather than animating offscreen.
  const heroVisibility = new IntersectionObserver(entries => {
    for (const entry of entries) if (!entry.isIntersecting) {
      entry.target.querySelectorAll('.motion-active').forEach(element => {
        element.getAnimations().forEach(animation => { try { animation.finish(); } catch { animation.cancel(); } });
      });
    }
  });
  if (document.querySelector('.hero')) heroVisibility.observe(document.querySelector('.hero'));

  // Hero entrance is server-rendered CSS; no module, font, or timer gate.
  // Count once when visible. SSR retains the final value for no-JS/reduced-motion.
  const counterObserver = new IntersectionObserver(entries => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      counterObserver.unobserve(entry.target);
      const element = entry.target;
      const original = element.textContent;
      const numbers = original.match(/[\d,]+(?:\.\d+)?/g);
      if (reducedMotion.matches || numbers?.length !== 1) continue;
      const number = numbers[0];
      const end = Number(number.replaceAll(',', ''));
      const precision = number.split('.')[1]?.length || 0;
      element.setAttribute('aria-label', original);
      const span = document.createElement('span');
      span.setAttribute('aria-hidden', 'true');
      element.replaceChildren(span);
      const start = performance.now();
      function tick(now) {
        const t = Math.min(1, (now - start) / 1200);
        if (disposed || t === 1 || reducedMotion.matches) { element.textContent = original; return; }
        const value = end * (1 - (1 - t) ** 3);
        const formatted = number.includes(',')
          ? Math.round(value).toLocaleString('en-US') : value.toFixed(precision);
        span.textContent = original.replace(number, formatted);
        requestAnimationFrame(tick);
      }
      requestAnimationFrame(tick);
    }
  }, { threshold: .35 });
  document.querySelectorAll('.section .stats strong').forEach(element => counterObserver.observe(element));

  // Same cosine falloff and thumbnail sizes as _GalleryFilmstrip in Flutter.
  const strip = document.querySelector('.filmstrip');
  if (strip) {
    const tiles = [...strip.querySelectorAll('.gallery-item')];
    tiles.forEach(tile => {
      const slot = document.createElement('div');
      slot.className = 'filmstrip-slot';
      tile.before(slot); slot.append(tile); return slot;
    });
    let size = 240, slotWidth = 267.2, inset = 0, width = 0, maxScale = 1.25;
    let frame = 0;
    const previousScales = new Map();
    function paint() {
      frame = 0;
      // Let each slot follow its image's visible width so zoom never eats
      // into the gap. Resolve the neighboring widths together before painting.
      const slots = tiles.map(tile => tile.parentElement);
      const center = strip.getBoundingClientRect().left + width / 2;
      const gap = innerWidth < 600 ? 18 : 24;
      for (let pass = 0; pass < 3; pass++) {
        const scales = slots.map(slot => {
          const rect = slot.getBoundingClientRect();
          const distance = Math.abs(rect.left + rect.width / 2 - center);
          const t = Math.min(1, distance / (size * 1.6));
          return reducedMotion.matches ? 1 : .85 + (maxScale - .85) * (1 + Math.cos(Math.PI * t)) / 2;
        });
        tiles.forEach((tile, i) => {
          const rounded = scales[i].toFixed(4);
          slots[i].style.flexBasis = `${size * scales[i] + gap}px`;
          if (previousScales.get(tile) !== rounded) {
            tile.style.transform = `scale(${rounded})`;
            previousScales.set(tile, rounded);
          }
        });
      }
    }
    function schedule() { if (!frame) frame = requestAnimationFrame(paint); }
    function measure() {
      const mobile = innerWidth < 600;
      size = mobile ? 160 : innerWidth < 1024 ? 200 : 240;
      maxScale = mobile ? 1.15 : 1.25;
      // Keep neighbors closer instead of reserving the maximum zoom for every tile.
      slotWidth = size * maxScale + (mobile ? 18 : 24);
      width = strip.clientWidth;
      inset = Math.max(0, width / 2 - slotWidth / 2);
      strip.style.paddingInline = `${inset}px`;
      strip.style.setProperty('--filmstrip-size', `${size}px`);
      strip.style.setProperty('--filmstrip-slot', `${slotWidth}px`);
      strip.style.setProperty('--filmstrip-height', `${size * maxScale}px`);
      schedule();
    }
    strip.addEventListener('scroll', schedule, { passive: true, signal });
    const resize = new ResizeObserver(measure);
    resize.observe(strip);
    cleanup.push(() => { resize.disconnect(); cancelAnimationFrame(frame); });
    window.addEventListener('resize', measure, { passive: true, signal });
    reducedMotion.addEventListener('change', schedule, { signal });
    measure();
  }

  // No perpetual polling: rotation is scheduled only while visible and active.
  const galleryHero = document.querySelector('.hero img.hero-media');
  if (galleryHero) {
    const images = [...document.querySelectorAll('.gallery-grid [data-gallery]')].map(link => link.href);
    let index = 0, visible = false, timer, pending = false;
    let drift;
    const allowed = () => !disposed && visible && !document.hidden && !reducedMotion.matches
      && !document.body.classList.contains('modal-open')
      && !document.documentElement.classList.contains('menu-open');
    function synchronize() {
      clearTimeout(timer);
      if (disposed) return;
      if (!allowed()) { drift?.pause(); return; }
      if (!drift) {
        drift = galleryHero.animate([{ transform: 'scale(1.02)' }, { transform: 'scale(1.08)' }], {
          duration: 8000, iterations: Infinity, direction: 'alternate', easing: 'linear',
        });
      } else drift.play();
      if (!pending && images.length > 1) timer = setTimeout(rotate, 8000);
    }
    async function rotate() {
      if (!allowed()) return;
      pending = true;
      const next = new Image();
      next.src = images[(index + 1) % images.length];
      try {
        await next.decode();
        if (!allowed()) return;
        next.className = 'hero-media gallery-incoming'; next.alt = '';
        next.style.transform = getComputedStyle(galleryHero).transform;
        galleryHero.after(next);
        await animate(next, [{ opacity: 0 }, { opacity: 1 }], { duration: 1200, easing: 'ease-in-out' });
        galleryHero.src = next.src;
        index = (index + 1) % images.length;
      } catch { /* Keep the current photo when the next one cannot load. */ }
      finally { next.remove(); pending = false; synchronize(); }
    }
    const visibility = new IntersectionObserver(entries => { visible = entries[0].isIntersecting; synchronize(); });
    visibility.observe(galleryHero);
    cleanup.push(() => { visibility.disconnect(); clearTimeout(timer); drift?.cancel(); });
    document.addEventListener('visibilitychange', synchronize, { signal });
    reducedMotion.addEventListener('change', () => {
      if (reducedMotion.matches) { drift?.cancel(); drift = null; }
      synchronize();
    }, { signal });
    const overlays = new MutationObserver(synchronize);
    cleanup.push(() => overlays.disconnect());
    overlays.observe(document.body, { attributes: true, attributeFilter: ['class'] });
    overlays.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });
    window.addEventListener('pagehide', () => { clearTimeout(timer); drift?.pause(); }, { signal });
    window.addEventListener('pageshow', synchronize, { signal });
  }

  return () => {
    disposed = true;
    lifecycle.abort();
    heroVisibility.disconnect();
    counterObserver.disconnect();
    cleanup.forEach(dispose => dispose());
    motion.finish();
  };
}
