import { createMotionController } from './motion-controller.mjs';
import { initSmoothScroll } from './smooth-scroll.mjs';
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
  // Reveal headings and supporting copy word by word in reading order.
  // Split text nodes only so inline links, line breaks and semantics survive.
  const prepared = new Map();
  function prepareText(group) {
    const sequence = [];
    let delay = 0;
    const frames = [
      { opacity: 0, transform: 'translateY(18px)' },
      { opacity: 1, transform: 'translateY(0)' },
    ];
    const blocks = group.querySelectorAll('h2, h3, p, li');
    for (const block of blocks) {
      // List items containing headings/copy already have their own sequence.
      if (block.matches('li') && block.querySelector('h2, h3, p')) continue;
      {
        const walker = document.createTreeWalker(block, NodeFilter.SHOW_TEXT);
        const nodes = [];
        while (walker.nextNode()) nodes.push(walker.currentNode);
        const words = [];
        for (const node of nodes) {
          const fragment = document.createDocumentFragment();
          for (const part of node.textContent.split(/(\s+)/)) {
            if (!part) continue;
            if (/^\s+$/.test(part)) { fragment.append(document.createTextNode(part)); continue; }
            const word = document.createElement('span');
            word.textContent = part;
            word.style.display = 'inline-block';
            fragment.append(word);
            words.push(word);
          }
          node.replaceWith(fragment);
        }
        const heading = block.matches('h2, h3');
        const cadence = heading ? 65 : 40;
        const budget = heading ? 650 : 1400;
        const step = Math.min(cadence, budget / Math.max(1, words.length));
        words.forEach((word, index) => sequence.push({ word, frames: heading ? frames : [{ opacity: 0 }, { opacity: 1 }], delay: delay + index * step }));
        delay += Math.min(budget, words.length * step) + 100;
      }
    }
    prepared.set(group, sequence);
  }
  function revealText(group) {
    if (reducedMotion.matches || group.contains(document.activeElement)) return;
    for (const { word, frames, delay } of prepared.get(group) || []) {
      animate(word, frames, { duration: 550, delay, fill: 'backwards' });
    }
  }
  const reveals = new IntersectionObserver(entries => {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue;
      reveals.unobserve(entry.target);
      // Install backwards-filled word animations before releasing the hidden state.
      try { revealText(entry.target); }
      finally { entry.target.classList.remove('text-reveal-pending'); }
    }
  }, { threshold: 0, rootMargin: '0px 0px -80px 0px' });
  const revealGroups = [...document.querySelectorAll('.home-heading, .section-heading, .home-service-body, .home-owner-points, .home-quote-notes')];
  // Never hide text that has already painted in the viewport (slow module loads,
  // restored scroll positions). Arm only below-fold groups before they enter.
  const pendingGroups = revealGroups.filter(element => element.getBoundingClientRect().top >= innerHeight);
  if (!reducedMotion.matches) pendingGroups.forEach(element => {
    prepareText(element);
    element.classList.add('text-reveal-pending');
    reveals.observe(element);
  });
  function releaseReveals() {
    reveals.disconnect();
    revealGroups.forEach(element => element.classList.remove('text-reveal-pending'));
  }
  reducedMotion.addEventListener('change', () => {
    if (reducedMotion.matches) releaseReveals();
  }, { signal });
  document.addEventListener('focusin', event => {
    const group = event.target.closest?.('.text-reveal-pending');
    if (group) { reveals.unobserve(group); group.classList.remove('text-reveal-pending'); }
  }, { signal });
  cleanup.push(releaseReveals);
  const textVisibility = new IntersectionObserver(entries => {
    for (const entry of entries) if (!entry.isIntersecting && !entry.target.classList.contains('text-reveal-pending')) {
      entry.target.querySelectorAll('.motion-active').forEach(word => {
        word.getAnimations().forEach(animation => { try { animation.finish(); } catch { animation.cancel(); } });
      });
    }
  });
  pendingGroups.forEach(group => textVisibility.observe(group));
  cleanup.push(() => { textVisibility.disconnect(); prepared.clear(); });

  // One scheduled frame, with all geometry reads before transform writes.
  // Individual translate/scale properties coexist with the gallery crossfade.
  const hero = document.querySelector('.hero');
  const showcase = document.querySelector('.home-owner-photo');
  const showcaseImage = showcase?.querySelector('img');
  const videoMedia = hero?.querySelector('video.hero-media');
  const previousMotion = new WeakMap();
  let scrollFrame = 0;
  let paintedY = null;
  let geometryDirty = true, heroGeometry, photoGeometry;
  function invalidateGeometry() { geometryDirty = true; scheduleScroll(); }
  const layoutObserver = new ResizeObserver(invalidateGeometry);
  document.querySelectorAll('#main, #main .section, #main .hero').forEach(element => layoutObserver.observe(element));
  document.fonts?.ready.then(() => { if (!disposed) invalidateGeometry(); });
  cleanup.push(() => layoutObserver.disconnect());
  function paintScroll() {
    scrollFrame = 0;
    paintedY = window.scrollY;
    // Measure document coordinates only when layout changes, not after every
    // scroll write. Scroll frames derive viewport positions without layout reads.
    if (geometryDirty) {
      const heroBounds = hero?.getBoundingClientRect();
      const photoBounds = showcase?.getBoundingClientRect();
      heroGeometry = heroBounds && { top: heroBounds.top + paintedY, height: heroBounds.height };
      photoGeometry = photoBounds && { top: photoBounds.top + paintedY };
      geometryDirty = false;
    }
    const heroRect = heroGeometry && { top: heroGeometry.top - paintedY, height: heroGeometry.height };
    const photoRect = photoGeometry && { top: photoGeometry.top - paintedY };
    const enabled = !reducedMotion.matches;
    const travel = enabled && heroRect ? Math.min(Math.max(-heroRect.top, 0), heroRect.height) * (innerWidth < 768 ? .2 : .35) : 0;
    hero?.querySelectorAll('.hero-media').forEach(media => {
      const progress = heroRect ? Math.min(1, Math.max(0, -heroRect.top / (heroRect.height * .7))) : 0;
      const translate = travel ? `0 ${travel.toFixed(2)}px` : '';
      const scale = enabled ? (1.2 - progress * .2).toFixed(6) : '';
      const previous = previousMotion.get(media);
      if (previous !== translate + scale) {
        media.style.translate = translate;
        media.style.scale = scale;
        previousMotion.set(media, translate + scale);
      }
    });
    if (showcase && photoRect) {
      const progress = Math.min(1, Math.max(0, (innerHeight - photoRect.top) / (innerHeight * .8)));
      const photo = showcaseImage;
      if (photo) {
        const scale = enabled ? (1.45 - progress * .45).toFixed(6) : '';
        if (previousMotion.get(photo) !== scale) {
          photo.style.scale = scale;
          previousMotion.set(photo, scale);
        }
      }
    }
  }
  function scheduleScroll() { if (!scrollFrame) scrollFrame = requestAnimationFrame(paintScroll); }
  window.addEventListener('scroll', () => {
    // Controlled scrolling has already painted this position in its own frame.
    if (window.scrollY !== paintedY) scheduleScroll();
  }, { passive: true, signal });
  window.addEventListener('resize', invalidateGeometry, { passive: true, signal });
  reducedMotion.addEventListener('change', scheduleScroll, { signal });
  // Update parallax in the same frame as controlled scrolling, not a frame later.
  cleanup.push(initSmoothScroll(() => {
    cancelAnimationFrame(scrollFrame);
    paintScroll();
  }));
  const videoVisibility = new IntersectionObserver(entries => {
    if (videoMedia) videoMedia.style.willChange = entries[0].isIntersecting && !reducedMotion.matches ? 'transform' : '';
  });
  if (videoMedia) videoVisibility.observe(videoMedia);
  cleanup.push(() => { videoVisibility.disconnect(); if (videoMedia) videoMedia.style.willChange = ''; });
  scheduleScroll();
  cleanup.push(() => {
    cancelAnimationFrame(scrollFrame);
    hero?.querySelectorAll('.hero-media').forEach(media => { media.style.translate = ''; media.style.scale = ''; });
    if (showcase?.querySelector('img')) showcase.querySelector('img').style.scale = '';
  });
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
      {
        const scales = slots.map(slot => {
          const rect = slot.getBoundingClientRect();
          const distance = Math.abs(rect.left + rect.width / 2 - center);
          const t = Math.min(1, distance / (size * 1.6));
          return reducedMotion.matches ? 1 : .85 + (maxScale - .85) * (1 + Math.cos(Math.PI * t)) / 2;
        });
        tiles.forEach((tile, i) => {
          const rounded = scales[i].toFixed(4);
          
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
      // Reserve stable space so scrolling never changes layout between reads.
      slotWidth = size * maxScale + (mobile ? 18 : 24);
      tiles.forEach(tile => { tile.parentElement.style.flexBasis = `${slotWidth}px`; });
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

