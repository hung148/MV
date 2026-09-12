'use strict';

// Embedded before stylesheets so CSS/font loading cannot delay media discovery.
function prepareHeroVideo(src) {
  const video = document.createElement('video');
  video.muted = true;
  video.loop = true;
  video.playsInline = true;
  video.preload = 'auto';
  // Small, local-only timing markers make startup stalls diagnosable in DevTools.
  if (typeof performance !== 'undefined') {
    const timings = [];
    const mark = event => {
      performance.mark(`hero-video:${event}`);
      timings.push({ event, ms: Math.round(performance.now()) });
      video.dataset.startupTiming = JSON.stringify(timings);
    };
    mark('created');
    for (const event of ['loadstart', 'loadeddata', 'playing', 'waiting', 'pause']) {
      video.addEventListener(event, () => mark(event), { once: true });
    }
    video.requestVideoFrameCallback?.(() => mark('first-frame'));
  }
  const allowed = () => !matchMedia('(prefers-reduced-motion: reduce)').matches && !navigator.connection?.saveData;
  if (allowed()) video.src = src;
  const start = () => {
    if (allowed() && !document.hidden) video.play().catch(() => {});
  };
  // The incoming document may still be hidden during the initial HTML parse.
  window.addEventListener('pagereveal', start, { once: true });
  window.addEventListener('pageshow', start, { once: true });
  window.__heroVideo = video;
}

exports.videoHead = src => `<script>(${prepareHeroVideo.toString()})(${JSON.stringify(src)})</script>`;
exports.videoMount = `<script>(()=>{const placeholder=document.currentScript.previousElementSibling;const video=window.__heroVideo;if(video){for(const attr of placeholder.attributes){if(attr.name!=='preload')video.setAttribute(attr.name,attr.value)}placeholder.replaceWith(video);delete window.__heroVideo;if(video.getAttribute('src')&&!document.hidden)video.play().catch(()=>{})}})()</script>`;
