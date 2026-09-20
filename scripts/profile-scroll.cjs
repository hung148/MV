'use strict';
// Local-only scroll probe: node scripts/profile-scroll.cjs, then open port 3003.
// Kept outside public assets so production pages never collect these samples.
const { server } = require('../functions/site/dev.cjs');
function probe() {
  const panel = document.createElement('aside');
  panel.style.cssText = 'position:fixed;bottom:12px;left:12px;z-index:10000;background:#fff;color:#111;padding:16px;border:2px solid #0d47a1;border-radius:8px;max-width:520px;font:14px/1.5 monospace;box-shadow:0 4px 20px #0004';
  panel.innerHTML = '<strong>Local scroll diagnostic</strong><p>Compares idle, playback, scrolling and animation costs. Temporary test changes are restored afterward.</p><button type="button">Run rendering comparisons</button><pre style="white-space:pre-wrap;margin-bottom:0;max-height:300px;overflow:auto" aria-live="polite"></pre>';
  document.body.append(panel);
  const button = panel.querySelector('button'), report = panel.querySelector('pre');
  const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
  button.addEventListener('click', async () => {
    const video = document.querySelector('video');
    const toggle = document.querySelector('.media-toggle');
    if (!video || !toggle) { report.textContent = 'Open the home page to run this check.'; return; }
    const originalY = scrollY, originalPaused = video.paused;
    button.disabled = true;
    const rows = [];
    const stalls = [];
    const observer = new PerformanceObserver(list => stalls.push(...list.getEntries()));
    const supportsLoaf = PerformanceObserver.supportedEntryTypes.includes('long-animation-frame');
    observer.observe({ type: supportsLoaf ? 'long-animation-frame' : 'longtask' });
    const animations = video.getAnimations();
    const originalStyle = video.getAttribute('style');
    try {
      for (const mode of ['idle-paused', 'idle-playing', 'scroll-playing', 'scroll-paused', 'scroll-no-transform', 'scroll-hidden-video', 'scroll-unfiltered', 'scroll-restored']) {
        const playing = mode !== 'idle-paused' && mode !== 'scroll-paused';
        scrollTo({ top: 0, behavior: 'instant' });
        await sleep(300);
        if ((!video.paused) !== playing) toggle.click();
        await sleep(500);
        if (document.hidden) throw Error('Keep the diagnostic tab visible and run again.');
        report.textContent = `Measuring ${mode}…`;
        for (const animation of animations) {
          if (mode === 'scroll-no-transform') animation.pause(); else animation.play();
        }
        video.style.visibility = mode === 'scroll-hidden-video' ? 'hidden' : '';
        // A/B the identity-filter workaround within the same page and run.
        video.style.filter = mode === 'scroll-unfiltered' ? 'none' : '';
        await sleep(200);
        stalls.length = 0;
        const before = video.getVideoPlaybackQuality?.();
        const gaps = [];
        let last, raf;
        function measure(time) {
          if (last !== undefined) gaps.push(time - last);
          last = time; raf = requestAnimationFrame(measure);
        }
        raf = requestAnimationFrame(measure);
        // Exercise the existing wheel handler at the same cadence and cap.
        for (let i = 0; i < 8; i++) {
          if (mode.startsWith('scroll')) document.querySelector('.hero').dispatchEvent(new WheelEvent('wheel', {
            deltaY: 45, bubbles: true, cancelable: true,
          }));
          await sleep(80);
        }
        await sleep(700);
        cancelAnimationFrame(raf);
        const after = video.getVideoPlaybackQuality?.();
        gaps.sort((a, b) => a - b);
        rows.push({ mode, actualVideoPlaying: !video.paused,
          p95Ms: +(gaps[Math.floor(gaps.length * .95)] || 0).toFixed(1),
          worstMs: +(gaps.at(-1) || 0).toFixed(1),
          framesOver25ms: gaps.filter(ms => ms > 25).length,
          droppedVideoFrames: after && before ? after.droppedVideoFrames - before.droppedVideoFrames : 'unavailable',
          totalVideoFrames: after && before ? after.totalVideoFrames - before.totalVideoFrames : 'unavailable',
          stalls: stalls.map(entry => ({ duration: +entry.duration.toFixed(1),
            renderMs: entry.renderStart ? +(entry.startTime + entry.duration - entry.renderStart).toFixed(1) : 0,
            scripts: entry.scripts?.map(s => ({source:s.sourceURL, function:s.sourceFunctionName,
              duration:+s.duration.toFixed(1), forcedLayoutMs:s.forcedStyleAndLayoutDuration})),
          })),
        });
      }
      report.textContent = JSON.stringify(rows, null, 2) + '\nCopy these results into the task. Frame timing measures callbacks, not GPU presentation.';
    } catch (error) { report.textContent = error.message; }
    finally {
      observer.disconnect();
      for (const animation of animations) animation.play();
      if (originalStyle === null) video.removeAttribute('style'); else video.setAttribute('style', originalStyle);
      scrollTo({ top: originalY, behavior: 'instant' });
      if (video.paused !== originalPaused) toggle.click();
      button.disabled = false;
    }
  });
  const output = document.createElement('output');
  output.id = 'scroll-profile'; output.hidden = true;
  document.body.append(output);
  let sample, timer, frame, lastFrame;
  function finish() {
    cancelAnimationFrame(frame);
    const gaps = sample.gaps.sort((a, b) => a - b);
    const video = document.querySelector('video');
    output.textContent = JSON.stringify({
      wheelEvents: sample.events, inputPixels: sample.input,
      scrollPixels: +(scrollY - sample.startY).toFixed(1),
      firstScrollMs: sample.firstScroll,
      elapsedMs: Math.round(performance.now() - sample.start),
      frames: gaps.length, p95FrameMs: +(gaps[Math.floor(gaps.length * .95)] || 0).toFixed(1),
      maxFrameMs: +(gaps.at(-1) || 0).toFixed(1),
      videoPlaying: !!video && !video.paused,
    });
    sample = undefined;
  }
  function tick(time) {
    if (lastFrame) sample.gaps.push(time - lastFrame);
    lastFrame = time; frame = requestAnimationFrame(tick);
  }
  addEventListener('wheel', event => {
    if (!sample) {
      sample = { start: performance.now(), startY: scrollY, input: 0, events: 0, gaps: [], firstScroll: null };
      lastFrame = 0; frame = requestAnimationFrame(tick);
    }
    sample.events++;
    sample.input += event.deltaY * (event.deltaMode === 1 ? 100 / 6 : event.deltaMode === 2 ? innerHeight : 1);
    clearTimeout(timer); timer = setTimeout(finish, 250);
  }, { passive: true, capture: true });
  addEventListener('scroll', () => {
    if (!sample) return;
    sample.firstScroll ??= +(performance.now() - sample.start).toFixed(1);
    clearTimeout(timer); timer = setTimeout(finish, 250);
  }, { passive: true });
}
server.prependListener('request', (_req, res) => {
  const end = res.end;
  res.end = function (body, ...args) {
    if (typeof body === 'string' && String(res.getHeader('Content-Type')).startsWith('text/html')) {
      body = body.replace('</body>', `<script>(${probe.toString()})()</script></body>`);
    }
    return end.call(this, body, ...args);
  };
});
const port = Number(process.env.PROFILE_PORT || 3003);
server.listen(port, '127.0.0.1', () => console.log(`Scroll profiling preview: http://127.0.0.1:${port}`));
