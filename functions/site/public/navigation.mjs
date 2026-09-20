import { waitForMovingVideo } from './video-ready.mjs';

// Fetch complete SSR HTML, preparing its media while the current page stays live.
// Direct URLs, no-JS visits and failures retain ordinary server navigation.
export function installNavigation({ unmount, mount }) {
  const paths = new Set([...document.querySelectorAll('#navigation a')].map(a => new URL(a.href).pathname));
  let committedURL = location.href;
  let pending;
  let transition;
  history.replaceState({ ...history.state, scrollY: window.scrollY }, '');
  history.scrollRestoration = 'manual';

  async function navigate(url, { pop = false, scrollY = 0 } = {}) {
    pending?.abort();
    transition?.skipTransition();
    const controller = pending = new AbortController();
    const { signal } = controller;
    let nextMain;
    let committed = false;
    try {
      const response = await fetch(url, { signal, headers: { Accept: 'text/html' } });
      if (!response.ok || response.redirected || !response.headers.get('content-type')?.includes('text/html')) throw new Error('Use document navigation');
      const page = new DOMParser().parseFromString(await response.text(), 'text/html');
      const sourceMain = page.querySelector('#main');
      if (!sourceMain || !page.querySelector('#navigation')) throw new Error('Unrecognized page');
      if (signal.aborted) return;
      nextMain = document.importNode(sourceMain, true);
      nextMain.querySelectorAll('script').forEach(script => script.remove());
      nextMain.removeAttribute('id');
      nextMain.classList.add('navigation-staging');
      nextMain.inert = true;
      nextMain.setAttribute('aria-hidden', 'true');
      const oldMain = document.querySelector('#main');
      // Insert at its final position; commit never reparents the playing video.
      oldMain.after(nextMain);
      const video = nextMain.querySelector('video[data-src]');
      const canAutoplay = !matchMedia('(prefers-reduced-motion: reduce)').matches && !navigator.connection?.saveData && !document.hidden;
      if (video && canAutoplay) {
        video.muted = true;
        video.preload = 'auto';
        video.src = video.dataset.src;
        await waitForMovingVideo(video, signal);
      }
      if (signal.aborted) return;
      const commit = () => {
        if (signal.aborted) return;
        if (!pop) {
          history.replaceState({ ...history.state, scrollY: window.scrollY }, '');
          history.pushState({ scrollY: 0 }, '', url);
        }
        unmount();
        oldMain.remove();
        nextMain.id = 'main';
        nextMain.classList.remove('navigation-staging');
        nextMain.inert = false;
        nextMain.removeAttribute('aria-hidden');
        committed = true;
        committedURL = url.href;
        document.title = page.title;
        for (const selector of ['link[rel="canonical"]', 'meta[name="description"]', 'meta[property^="og:"]', 'script[type="application/ld+json"]']) {
          document.head.querySelectorAll(selector).forEach(node => node.remove());
          page.head.querySelectorAll(selector).forEach(node => document.head.append(document.importNode(node, true)));
        }
        document.querySelectorAll('#navigation a').forEach(link => {
          if (new URL(link.href).pathname === url.pathname && !new URL(link.href).hash) link.setAttribute('aria-current', 'page');
          else link.removeAttribute('aria-current');
        });
        window.scrollTo({ top: scrollY, behavior: 'instant' });
        mount();
        nextMain.tabIndex = -1;
        nextMain.focus({ preventScroll: true });
      };
      if (document.startViewTransition && !matchMedia('(prefers-reduced-motion: reduce)').matches) {
        transition = document.startViewTransition(commit);
        await transition.updateCallbackDone;
      } else commit();
    } catch (error) {
      if (!signal.aborted) location.assign(url.href);
    } finally {
      if (!committed && nextMain) {
        nextMain.querySelectorAll('video').forEach(video => { video.pause(); video.removeAttribute('src'); video.load(); });
        nextMain.remove();
      }
      if (pending === controller) pending = undefined;
    }
  }

  document.addEventListener('click', event => {
    if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    const link = event.target.closest('a[href]');
    if (!link || link.hasAttribute('download') || (link.target && link.target !== '_self')) return;
    const url = new URL(link.href);
    if (url.origin !== location.origin || !paths.has(url.pathname) || url.hash) return;
    event.preventDefault();
    if (url.href === committedURL) { pending?.abort(); return; }
    navigate(url);
  });
  window.addEventListener('popstate', event => {
    pending?.abort();
    const url = new URL(location.href);
    if (url.pathname === new URL(committedURL).pathname && url.search === new URL(committedURL).search) { committedURL = url.href; return; }
    navigate(url, { pop: true, scrollY: event.state?.scrollY || 0 });
  });
  window.addEventListener('pagehide', () => pending?.abort());
}
