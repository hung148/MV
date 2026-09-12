'use strict';
const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { server } = require('../functions/site/dev.cjs');
const { routes } = require('../functions/site/content.cjs');
test('hero video buffers before stylesheets and reuses that decoder when mounted', () => {
  const vm = require('node:vm');
  const { render } = require('../functions/site/render.cjs');
  const html = render('/services');
  const startup = html.match(/<head><meta charset="utf-8"><script>(.*?)<\/script>/s)?.[1];
  const mount = html.match(/<\/video><script>(.*?)<\/script>/s)?.[1];
  assert.ok(startup, 'Media discovery must precede blocking stylesheets');
  assert.ok(mount);
  for (const settings of [
    { reduced: false, saveData: false, hidden: false },
    { reduced: true, saveData: false, hidden: false },
    { reduced: false, saveData: true, hidden: false },
    { reduced: false, saveData: false, hidden: true },
  ]) {
    let plays = 0;
    let mounted;
    const callbacks = {};
    const video = {
      play() { plays++; return Promise.resolve(); },
      getAttribute(name) { return this[name]; },
      setAttribute(name, value) { this[name] = value; },
    };
    const context = {
      document: { hidden: settings.hidden, createElement: () => video,
        currentScript: { previousElementSibling: {
          attributes: [{ name: 'class', value: 'hero-media' }, { name: 'preload', value: 'none' }],
          replaceWith(element) { mounted = element; },
        } } },
      window: { addEventListener(name, callback) { callbacks[name] = callback; } },
      navigator: { connection: { saveData: settings.saveData } },
      matchMedia: () => ({ matches: settings.reduced }),
    };
    vm.runInNewContext(startup, context);
    const allowed = !settings.reduced && !settings.saveData;
    assert.equal(video.src, allowed ? '/assets/videos/services_hero_bg.mp4' : undefined);
    assert.equal(plays, 0);
    vm.runInNewContext(mount, context);
    assert.equal(mounted, video, 'Keep the preloaded element, not a second decoder');
    assert.equal(video.preload, 'auto');
    assert.equal(plays, allowed && !settings.hidden ? 1 : 0);
    context.document.hidden = false;
    callbacks.pagereveal();
    assert.equal(plays > 0, allowed, 'Activation must start video even if HTML parsed while hidden');
    assert.equal(context.window.__heroVideo, undefined);
  }
});
test('navigation waits for advancing video frames, not just a play request or still frame', async () => {
  const { waitForMovingVideo } = await import('../functions/site/public/video-ready.mjs');
  const video = new EventTarget();
  video.dataset = {};
  video.play = () => Promise.resolve();
  let callback;
  video.requestVideoFrameCallback = cb => { callback = cb; return 1; };
  video.cancelVideoFrameCallback = () => {};
  const controller = new AbortController();
  let finished = false;
  const ready = waitForMovingVideo(video, controller.signal).then(result => { finished = true; return result; });
  video.dispatchEvent(new Event('playing'));
  callback(0, { mediaTime: 0 });
  callback(16, { mediaTime: 0 });
  await Promise.resolve();
  assert.equal(finished, false, 'A still frame must not reveal the destination');
  callback(33, { mediaTime: 1 / 30 });
  assert.equal(await ready, 'moving');
});

test('video preparation releases navigation on cancellation, autoplay rejection and timeout', async () => {
  const { waitForMovingVideo } = await import('../functions/site/public/video-ready.mjs');
  for (const reason of ['aborted', 'unavailable', 'timeout']) {
    const video = new EventTarget();
    video.dataset = {};
    video.play = () => reason === 'unavailable' ? Promise.reject(new Error('Blocked')) : Promise.resolve();
    video.requestVideoFrameCallback = () => 1;
    let canceled = false;
    video.cancelVideoFrameCallback = () => { canceled = true; };
    const controller = new AbortController();
    const result = waitForMovingVideo(video, controller.signal, 5);
    if (reason === 'aborted') controller.abort();
    assert.equal(await result, reason);
    assert.equal(canceled, true);
  }
});

function motionHarness() {
  const preference = new EventTarget();
  preference.matches = false;
  const classes = new Set();
  const animations = [];
  const element = {
    classList: { add: name => classes.add(name), remove: name => classes.delete(name) },
    animate() {
      let resolve, reject;
      const animation = {
        finished: new Promise((yes, no) => { resolve = yes; reject = no; }),
        canceled: false,
        cancel() { this.canceled = true; reject(new Error('Interrupted')); },
        finish() { resolve(); },
      };
      animations.push(animation);
      return animation;
    },
  };
  return { preference, element, animations, classes };
}

test('native motion interruption retains ownership of the replacement animation', async () => {
  const { createMotionController } = await import('../functions/site/public/motion-controller.mjs');
  const { preference, element, animations, classes } = motionHarness();
  const controller = createMotionController(preference);
  const first = controller.play(element, [{ opacity: 0 }, { opacity: 1 }]);
  const second = controller.play(element, [{ opacity: 1 }, { opacity: 0 }]);
  await first;
  assert.equal(animations[0].canceled, true);
  assert.equal(classes.has('motion-active'), true);
  animations[1].finish(); await second;
  assert.equal(classes.has('motion-active'), false);
  assert.equal(animations[1].canceled, true);
  controller.dispose();
});

test('reduced motion completes in-flight effects and bypasses new animations', async () => {
  const { createMotionController } = await import('../functions/site/public/motion-controller.mjs');
  const { preference, element, animations, classes } = motionHarness();
  const controller = createMotionController(preference);
  const running = controller.play(element, [{ opacity: 0 }, { opacity: 1 }]);
  preference.matches = true; preference.dispatchEvent(new Event('change'));
  await running;
  await controller.play(element, [{ opacity: 0 }, { opacity: 1 }]);
  assert.equal(animations.length, 1);
  assert.equal(classes.size, 0);
  controller.dispose();
});

test('disposing native motion resolves pending consumers without leaving layer hints', async () => {
  const { createMotionController } = await import('../functions/site/public/motion-controller.mjs');
  const { preference, element, classes } = motionHarness();
  const controller = createMotionController(preference);
  const running = controller.play(element, [{ opacity: 0 }, { opacity: 1 }]);
  controller.dispose(); await running;
  assert.equal(classes.size, 0);
});
let origin;
before(async () => {
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  origin = `http://127.0.0.1:${server.address().port}`;
});
after(() => new Promise(resolve => { server.close(resolve); server.closeAllConnections(); }));

test('all routes deliver complete, distinct HTML without executing JavaScript', async () => {
  const titles = new Set();
  for (const [route, content] of Object.entries(routes)) {
    const response = await fetch(origin + route);
    assert.equal(response.status, 200, route);
    assert.match(response.headers.get('content-type'), /text\/html/);
    const html = await response.text();
    assert.equal(html.match(/<h1>(.*?)<\/h1>/s)[1].replace(/<[^>]*>/g, ''), content.title);
    assert.doesNotMatch(html, /hero-pending/);
    assert.equal((html.match(/<h1>/g) || []).length, 1);
    assert.ok(html.includes(`rel="canonical" href="https://www.mvmanufacturing.com${route}"`));
    assert.ok(html.includes('name="fullName"'));
    assert.ok(html.includes('minhvu@mvmanufacturing.com'));
    assert.doesNotMatch(html, /flutter_bootstrap|main\.dart\.js|canvaskit|<canvas/);
    titles.add(html.match(/<title>(.*?)<\/title>/)[1]);
    for (const [, link] of html.matchAll(/href="(\/(?:services|about|capabilities|gallery)?)"/g)) assert.equal((await fetch(origin + link, { method: 'HEAD' })).status, 200);
  }
  assert.equal(titles.size, 5);
});

test('deep links, query strings, redirects, unknown routes and methods have correct HTTP semantics', async () => {
  assert.equal((await fetch(origin + '/services?utm_source=test')).status, 200);
  const redirect = await fetch(origin + '/about/?ref=test', { redirect: 'manual' });
  assert.equal(redirect.status, 308);
  assert.equal(redirect.headers.get('location'), '/about?ref=test');
  for (const route of ['/missing', '/constructor', '/__proto__', '/missing.js']) {
    const response = await fetch(origin + route);
    assert.equal(response.status, 404);
    assert.match(await response.text(), /name="robots" content="noindex"/);
  }
  assert.equal((await fetch(origin + '/', { method: 'POST' })).status, 405);
  const head = await fetch(origin + '/capabilities', { method: 'HEAD' });
  assert.equal(head.status, 200); assert.equal(await head.text(), '');
});

test('bare domain permanently redirects to the canonical host with path and query intact', () => {
  const { handler } = require('../functions/site/handler.cjs');
  for (const method of ['GET', 'HEAD']) {
    for (const [url, destination] of [['/', '/'], ['/about/?ref=test', '/about?ref=test'], ['/services', '/services']]) {
      const headers = {};
      const response = { setHeader: (key, value) => { headers[key] = value; }, end() {} };
      handler({ method, url, headers: { host: 'mvmanufacturing.com' } }, response);
      assert.equal(response.statusCode, 308);
      assert.equal(headers.Location, 'https://www.mvmanufacturing.com' + destination);
    }
  }
});

test('sitemap URLs match each rendered canonical and robots advertises the same host', async () => {
  const sitemap = await (await fetch(origin + '/sitemap.xml')).text();
  const urls = [...sitemap.matchAll(/<loc>(.*?)<\/loc>/g)].map(match => match[1]);
  assert.deepEqual(urls.sort(), Object.keys(routes).map(route => 'https://www.mvmanufacturing.com' + route).sort());
  for (const url of urls) {
    const html = await (await fetch(origin + new URL(url).pathname)).text();
    assert.equal((html.match(/rel="canonical"/g) || []).length, 1);
    assert.ok(html.includes(`rel="canonical" href="${url}"`));
  }
  assert.match(await (await fetch(origin + '/robots.txt')).text(), /Sitemap: https:\/\/www\.mvmanufacturing\.com\/sitemap\.xml/);
});

test('gallery retains all 43 photos, lazy loading, and working static assets', async () => {
  const html = await (await fetch(origin + '/gallery')).text();
  assert.equal((html.match(/data-gallery="/g) || []).length, 43);
  assert.equal((html.match(/loading="lazy"/g) || []).length, 43);
  const assets = new Set([...html.matchAll(/(?:href|src)="(\/(?:site|assets)\/[^"?]+)"/g)].map(match => match[1]));
  for (const asset of assets) assert.equal((await fetch(origin + asset, { method: 'HEAD' })).status, 200, asset);
  const video = await fetch(origin + '/assets/videos/home_hero_bg.mp4', { headers: { Range: 'bytes=0-99' } });
  assert.equal(video.status, 206); assert.equal((await video.arrayBuffer()).byteLength, 100);
});

test('Firebase configuration sends page requests to SSR, not the Flutter shell', () => {
  const config = require('../firebase.json');
  assert.equal(config.hosting.public, 'build/ssr');
  assert.equal(config.hosting.rewrites[0].function.functionId, 'ssrSite');
  assert.equal(fs.existsSync(path.join(__dirname, '../build/ssr/index.html')), false);
});

test('text-only quotes finalize an initially absent files field for the existing email trigger', async () => {
  const { submitQuote } = await import('../functions/site/public/quote-workflow.mjs');
  const calls = [];
  const api = {
    create: async fields => { calls.push(['create', fields]); return { id: 'test-quote' }; },
    upload: async () => assert.fail('No files to upload'),
    finalize: async (reference, files) => calls.push(['finalize', reference.id, files]),
  };
  await submitQuote(api, {}, { fullName: 'Test Customer' }, [], () => {});
  assert.equal(Object.hasOwn(calls[0][1], 'files'), false);
  assert.deepEqual(calls[1], ['finalize', 'test-quote', []]);
});

test('attachment retry reuses the saved quote and completed uploads without duplicate writes', async () => {
  const { submitQuote } = await import('../functions/site/public/quote-workflow.mjs');
  let creates = 0;
  let fail = true;
  const uploads = [];
  let finalized;
  const api = {
    create: async () => { creates++; return { id: 'test-quote' }; },
    upload: async (reference, name) => { uploads.push(name); if (name.startsWith('2-') && fail) throw new Error('Network unavailable'); },
    finalize: async (reference, files) => { finalized = files; },
  };
  const state = {};
  const files = [{ name: 'part a.step', size: 50 }, { name: 'part_a.step', size: 60 }];
  await assert.rejects(submitQuote(api, state, {}, files, () => {}));
  assert.equal(finalized, undefined);
  fail = false;
  await submitQuote(api, state, {}, files, () => {});
  assert.equal(creates, 1);
  assert.deepEqual(uploads, ['1-part_a.step', '2-part_a.step', '2-part_a.step']);
  assert.equal(finalized.length, 2);
  assert.equal(finalized[0].type, 'application/octet-stream');
});

test('quote validation agrees with current Firestore and attachment limits', async () => {
  const { validateFields, validateFile } = await import('../functions/site/public/quote-workflow.mjs');
  const fields = { fullName: 'Example', email: 'example@example.com', phone: '555-0100', company: 'Example', details: 'Test project details', _hp: '' };
  assert.equal(validateFields(fields, 2500), null);
  assert.ok(validateFields({ ...fields, company: ' ' }, 2500));
  assert.ok(validateFields({ ...fields, details: 'x'.repeat(1001) }, 2500));
  assert.ok(validateFields({ ...fields, _hp: 'bot' }, 2500));
  assert.ok(validateFields(fields, 100));
  assert.equal(validateFile({ name: 'PART.STEP', size: 10485760 }), null);
  assert.ok(validateFile({ name: 'part.pdf', size: 10485761 }));
  assert.ok(validateFile({ name: 'part.exe', size: 10 }));
});

test('scroll reserve accumulates, saturates, and reverses without old momentum', async () => {
  const { addScrollReserve } = await import('../functions/site/public/smooth-scroll.mjs');
  assert.equal(addScrollReserve(100, 80), 180);
  assert.equal(addScrollReserve(300, 1000), 360);
  assert.equal(addScrollReserve(-300, -1000), -360);
  assert.equal(addScrollReserve(300, -40), -40);
});

test('reserve drains smoothly to rest within the speed limit across refresh rates', async () => {
  const { drainScrollReserve } = await import('../functions/site/public/smooth-scroll.mjs');
  for (const hz of [30, 60, 120, 144]) {
    let reserve = 360, velocity = 0, total = 0;
    for (let i = 0; i < hz * 4 && reserve >= .5; i++) {
      const step = drainScrollReserve(reserve, velocity, 1000 / hz);
      assert.ok(step.distance >= 0 && step.distance <= 600 / hz);
      assert.ok(step.distance <= reserve);
      reserve -= step.distance; total += step.distance; velocity = step.velocity;
    }
    assert.ok(reserve < .5);
    assert.ok(total > 359.5 && total <= 360 + 1e-9);
  }
  assert.equal(drainScrollReserve(100, 0, 0).distance, 0);
  assert.ok(drainScrollReserve(-100, 400, 16).distance < 0);
  assert.ok(drainScrollReserve(360, 600, 1000).distance <= 19.2);
});

test('scroll reserve slows during animation and eases back afterward', async () => {
  const { drainScrollReserve } = await import('../functions/site/public/smooth-scroll.mjs');
  let velocity = 360;
  for (let i = 0; i < 60; i++) velocity = drainScrollReserve(360, velocity, 1000 / 60, 140).velocity;
  assert.ok(velocity < 141);
  const resumed = drainScrollReserve(360, velocity, 1000 / 60, 360);
  assert.ok(resumed.velocity > velocity && resumed.velocity < 360);
});
