import { revealDialog, initMotion } from './motion.js';
import { installNavigation } from './navigation.mjs';
// Progressive enhancement: all page content and navigation arrive as HTML.
document.documentElement.classList.add('js');
const menuButton = document.querySelector('.menu-toggle');
const nav = document.querySelector('#navigation');
menuButton.innerHTML = '<span class="menu-bars" aria-hidden="true"><i></i><i></i><i></i></span>';
const menuBackdrop = document.createElement('div');
menuBackdrop.className = 'menu-backdrop';
menuBackdrop.setAttribute('aria-hidden', 'true');
document.querySelector('.site-header').before(menuBackdrop);
menuBackdrop.addEventListener('click', closeMenu);
const compactNavigation = matchMedia('(max-width: 1023px)');
function syncNavigation() {
  menuButton.hidden = !compactNavigation.matches;
  nav.inert = compactNavigation.matches && !nav.classList.contains('is-open');
  if (!compactNavigation.matches) closeMenu();
}
syncNavigation();
compactNavigation.addEventListener('change', syncNavigation);
function closeMenu() {
  nav.classList.remove('is-open');
  nav.inert = compactNavigation.matches;
  menuButton.setAttribute('aria-expanded', 'false');
  document.documentElement.classList.remove('menu-open');
}
menuButton.addEventListener('click', () => {
  const open = nav.classList.toggle('is-open');
  menuButton.setAttribute('aria-expanded', String(open));
  nav.inert = !open;
  document.documentElement.classList.toggle('menu-open', open);
});
document.addEventListener('keydown', event => { if (event.key === 'Escape') closeMenu(); });
document.addEventListener('click', event => { if (!event.target.closest('.site-header')) closeMenu(); });
nav.addEventListener('click', event => { if (event.target.closest('a')) closeMenu(); });
// Let the browser keep the old document visible until the next SSR page is ready.
// Cross-document View Transitions handle the visual swap where supported.
let navigating = false;
window.addEventListener('pageswap', () => { navigating = true; });
window.addEventListener('pageshow', () => { navigating = false; closeMenu(); });
// Native dialogs provide keyboard focus containment, Escape, and focus restoration.
const quoteSection = document.querySelector('#quote');
const quoteDialog = document.createElement('dialog');
quoteDialog.className = 'quote-dialog';
quoteDialog.setAttribute('aria-labelledby', 'quote-title');
quoteSection.before(quoteDialog);
quoteDialog.append(quoteSection);
quoteSection.querySelector('[data-close-quote]').hidden = false;
let quoteModule;
let openedAt;
async function openQuote() {
  openedAt ??= Date.now();
  quoteDialog.showModal();
  revealDialog(quoteDialog);
  document.body.classList.add('modal-open');
  try {
    quoteModule ??= import('./quote.js').then(module => { module.initQuote(openedAt); return module; }).catch(error => { quoteModule = null; throw error; });
    await quoteModule;
  } catch {
    document.querySelector('#quote-status').textContent = 'The form could not load. Check your connection and reopen it, or call (669) 243-9228.';
  }
}
document.addEventListener('click', event => { if (event.target.closest('[data-quote]')) { event.preventDefault(); openQuote(); } });
quoteSection.querySelector('[data-close-quote]').addEventListener('click', () => quoteDialog.close());
// Stop an unenhanced form from navigating or exposing contact details in a URL.
document.querySelector('#quote-form').addEventListener('submit', event => event.preventDefault());
if (location.hash === '#quote') openQuote();
window.addEventListener('hashchange', () => { if (location.hash === '#quote' && !quoteDialog.open) openQuote(); });

const lightbox = document.querySelector('#lightbox');
let links = [...document.querySelectorAll('[data-gallery]')];
let index = 0;
function showImage(next) {
  index = (next + links.length) % links.length;
  const image = document.querySelector('#lightbox-image');
  image.src = links[index].href;
  image.alt = links[index].querySelector('img').alt;
  document.querySelector('#gallery-count').textContent = `${index + 1} / ${links.length}`;
}
document.addEventListener('click', event => {
  const link = event.target.closest('[data-gallery]');
  const i = links.indexOf(link);
  if (i < 0) return;
  event.preventDefault(); showImage(i); lightbox.showModal(); revealDialog(lightbox); document.body.classList.add('modal-open');
});

document.querySelector('[data-close-gallery]').addEventListener('click', () => lightbox.close());
document.querySelector('[data-gallery-prev]').addEventListener('click', () => showImage(index - 1));
document.querySelector('[data-gallery-next]').addEventListener('click', () => showImage(index + 1));
lightbox.addEventListener('keydown', event => {
  if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') { event.preventDefault(); showImage(index + (event.key === 'ArrowRight' ? 1 : -1)); }
});
let touchStart;
lightbox.addEventListener('touchstart', event => { touchStart = event.changedTouches[0].clientX; }, { passive: true });
lightbox.addEventListener('touchend', event => { const delta = event.changedTouches[0].clientX - touchStart; if (Math.abs(delta) > 60) showImage(index + (delta < 0 ? 1 : -1)); }, { passive: true });
for (const dialog of [quoteDialog, lightbox]) {
  dialog.addEventListener('close', () => { document.body.classList.remove('modal-open'); });
  dialog.addEventListener('click', event => { if (event.target === dialog) { const rect = dialog.getBoundingClientRect(); if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close(); } });
}

function mountPage() {
  const lifecycle = new AbortController();
  const signal = lifecycle.signal;
  const cleanups = [initMotion()];
  links = [...document.querySelectorAll('#main [data-gallery]')];
  const hero = document.querySelector('#main .hero');
  if (hero) {
    const observer = new IntersectionObserver(entries => {
      document.querySelector('.site-header').classList.toggle('past-hero', !entries[0].isIntersecting);
    }, { rootMargin: '-84px 0px 0px 0px' });
    observer.observe(hero);
    cleanups.push(() => observer.disconnect());
  }
  // Video playback is independent of page rendering.
  const video = document.querySelector('video[data-src]');
  if (video) {
    const toggle = document.querySelector('.media-toggle');
    const reduceMotion = matchMedia('(prefers-reduced-motion: reduce)');
    let userPaused = reduceMotion.matches || navigator.connection?.saveData === true;
    // Do not briefly pause early autoplay while waiting for the first IO callback.
    const initialBounds = video.getBoundingClientRect();
    let visible = initialBounds.bottom > 0 && initialBounds.top < innerHeight;
    let playPending = false;
    const canPlay = () => !signal.aborted && visible && !document.hidden && !userPaused
      && !document.documentElement.classList.contains('menu-open')
      && !document.body.classList.contains('modal-open') && !navigating;
    toggle.hidden = false;
    function updateButton() { toggle.textContent = video.paused ? 'Play video' : 'Pause video'; toggle.setAttribute('aria-label', `${video.paused ? 'Play' : 'Pause'} background video`); toggle.setAttribute('aria-pressed', String(!video.paused)); }
    async function syncPlayback() {
      if (canPlay()) {
        if (playPending || !video.paused) return;
        if (!video.getAttribute('src')) video.src = video.dataset.src;
        playPending = true;
        try { await video.play(); if (!canPlay()) video.pause(); }
        catch { /* Autoplay may be blocked; the play button remains available. */ }
        finally { playPending = false; }
      } else video.pause();
      updateButton();
    }
    const observer = new IntersectionObserver(entries => { visible = entries[0].isIntersecting; syncPlayback(); }, { threshold: 0 });
    observer.observe(video);
    // Start as soon as the visible video is available; no hero-animation gate.
    const overlays = new MutationObserver(syncPlayback);
    overlays.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] });
    overlays.observe(document.body, { attributes: true, attributeFilter: ['class'] });
    toggle.addEventListener('click', () => { userPaused = !video.paused; visible = true; syncPlayback(); }, { signal });
    video.addEventListener('play', updateButton, { signal });
    video.addEventListener('pause', updateButton, { signal });
    updateButton();
    document.addEventListener('visibilitychange', syncPlayback, { signal });
    reduceMotion.addEventListener('change', () => { userPaused = reduceMotion.matches || navigator.connection?.saveData === true; syncPlayback(); }, { signal });
    cleanups.push(() => { observer.disconnect(); overlays.disconnect(); video.pause(); });
    syncPlayback();
  }

  return () => { lifecycle.abort(); cleanups.forEach(dispose => dispose()); };
}
let disposePage = mountPage();
installNavigation({
  unmount: () => disposePage(),
  mount: () => { navigating = false; closeMenu(); disposePage = mountPage(); },
});
