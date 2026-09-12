# MV Manufacturing website

The web site serves **server-rendered HTML** through Firebase Hosting and the
`ssrSite` HTTP function. All five routes contain their headings, copy, links,
gallery, and quote form in the initial response. Flutter source and native
platform projects remain available, including pre-existing uncommitted work.

## Local development

Use Node.js 24, matching the existing Firebase Functions runtime.

```sh
npm run dev
```

Open http://127.0.0.1:3000. No new npm dependencies are required for the website
build or preview. After editing source, restart `npm run dev` to copy assets and
reload server modules. `npm run build` builds public assets; `npm test` checks
routes, HTTP behavior, assets, and quote workflows without writing to Firebase.

## Source

- `functions/site/content.cjs`: metadata and shared business copy.
- `functions/site/render.cjs`: HTML templates and shared components.
- `functions/site/public/styles.css`: responsive layouts and CSS motion.
- `functions/site/public/client.js`: native dialogs, navigation, gallery, video.
- `functions/site/public/quote.js`: Firebase loaded only when submitting a quote.
- `functions/site/public/quote-workflow.mjs`: validation and retryable uploads.
- `functions/site/handler.cjs`: shared local/production HTTP handler.
- `scripts/build-ssr.cjs`: asset build and render validation.

Server output is route-specific HTML, not a prerendered Flutter splash screen.
There is no React hydration or Flutter engine. Interaction still runs in the
browser: SSR cannot execute hover, scrolling, playback, or file selection on
the server. Without JavaScript, content and navigation work, gallery links open
the original images, and the quote section provides email/telephone alternatives.

## Performance findings

Original Flutter code findings (before the SSR migration and media optimization):

- `GalleryPage.didChangeDependencies` precaches all 43 images on entry.
- The home filmstrip calls `setState` on each horizontal scroll update.
- Services, Capabilities, About, and Gallery use eager Columns inside the route's
  `SingleChildScrollView`; the gallery has a shrink-wrapped grid.
- Full-screen video, gallery image motion, word reveals, counters, and page fades
  compete for rendering resources. The Services video is about 16.5 MB.
- `web/index.html` installs a non-passive window wheel listener and loads two
  Firebase compatibility scripts in addition to Flutter's Firebase integration.

The HTML implementation uses native scrolling, lazy thumbnails, localized
filmstrip updates, and browser-managed entrance animations. Videos are optimized
720p H.264 files (about 0.8–1.4 MB), and pause offscreen or in hidden tabs.
Playback honors reduced motion/data saver and includes a play/pause control.

Internal navigation fetches the destination's complete SSR HTML while leaving
the current page visible. It prepares the next video in its final DOM position
and waits for advancing video frames before the page swap. The decoder is not
recreated during the swap. Hero entrance animations start only at that point.
Preparation is bounded to 1.5 seconds; blocked or unavailable media falls back
to the poster and manual playback. Direct visits and no-JS navigation still use
ordinary SSR document loads. Page observers and listeners are disposed on swaps,
while the shared quote form remains mounted so its state is preserved.

Flutter's [web guidance](https://docs.flutter.dev/platform-integration/web)
describes its app-centric rendering model. SSR improves document delivery;
smooth scrolling also depends on browser rendering cost and device performance.

## Quote compatibility

The form keeps the existing `quotes/{id}` Firestore schema and
`quotes/{id}/{filename}` Storage paths, validation limits, honeypot, and time trap.
It omits `files` at creation, then adds the field after uploads, including `[]`
for text-only requests. This matches `onQuoteWithFiles`' absent-to-present trigger;
the old client created `files: []` immediately, preventing that trigger from firing.
Retries reuse an acknowledged quote and completed uploads. The payload is frozen
once submission starts. A lost create acknowledgement can still require checking
Firebase before resubmission; exactly-once delivery is not guaranteed. Email
delivery remains the existing Firebase extension's job.

Storage rules use the documented interpolated document path and
`request.time - duration.value(10, 'm')` timestamp comparison. See
[Storage rule reference](https://firebase.google.com/docs/reference/security/storage).
The existing v1 trigger uses its explicit v1 import alongside the v2 SSR function.
Notification HTML escapes customer-provided strings.

## Deployment

Firebase Hosting now targets `build/ssr`, rewriting pages to `ssrSite` in
`us-central1`. The live site is unchanged until deployment. Do not use the old
Flutter hosting deployment instructions for this website.

Install the Firebase CLI and authenticate to the existing `mv-web-35fcc` project.
Install the existing Functions lockfile dependencies if absent, then deploy:

```sh
npm ci --prefix functions
npm run deploy:ssr
```

This deploys SSR, the compatible quote notification function, corrected Storage
rules, and Hosting together. Cloud Functions billing must be enabled. Hosting
serves media/static files directly; HTML uses CDN caching. The rewrite's `pinTag`
couples Hosting to its SSR function revision. See
[Firebase Hosting rewrites](https://firebase.google.com/docs/hosting/full-config).

Local verification covers HTML routes, links, 404/redirect/HEAD/method behavior,
media range requests, gallery assets, quote validation, and retries with mocked
Firebase. No real quote/email was sent. Browser frame-rate profiling, deployed
rule compilation, uploads, and email delivery still need staging verification
before production release.
