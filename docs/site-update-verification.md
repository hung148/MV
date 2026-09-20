# September 2026 site update

Five free Pexels photos are assigned exclusively to Services, Capabilities, or About. Gallery retains actual MV work. Captions identify stock imagery as illustrative, not MV equipment or completed work.

Source links, credits, and asset sizes are in `functions/site/photo-credits.json`. `scripts/optimize-page-images.py` creates 480/960/1600px WebP variants with metadata removed from selected JPEGs in `outputs/cnc-sources`. Only optimized assets are served. License: https://www.pexels.com/license/.

Resources and its three guides were removed at the owner’s request. The five main pages retain server-rendered headings, canonical URLs, metadata, WebPage structured data, and sitemap entries. About now uses Daniel Smyth’s CNC cutting photo (Pexels 10406128), optimized to 10.7/27.0/60.9 kB.

The bare domain redirects to www with HTTP 301, preserving paths and query strings, including when Firebase forwards the public host. Both live domains returned 200 during the pre-deployment check on September 18, 2026. The changes require deployment and live rechecking.

## Facts awaiting the owner

- Machine models, travel, workholding, and part-size limits.
ITAR Registered is restored on Capabilities following the user’s explicit confirmation. No other certification claims have been added.
- Other certifications and documentation: unsupported AS9100D, PPAP, and RoHS badges were removed.
- Approved testimonials, client logos, and documented project outcomes. None were fabricated.

Existing CMM and grinder model-free specification cards were replaced with a project-fit summary rather than presenting them as a verified CNC machine list.

## Quote notification behavior

The browser confirms that the quote was saved and displays its request reference. It does not claim email delivery. Text-only requests still finalize the files array. Upload retries reuse acknowledged quotes and completed files.

Notifications use deterministic `mail/quote-{id}` documents with atomic creation and retries on transient failures. Duplicate events cannot create another notification. Drawings remain in Storage: email links to authenticated Firebase Console access rather than embedding large files in a Firestore document. Firestore documents have a 1 MiB size limit; the previous 20 MB attachment budget could exceed that limit.

The Trigger Email extension still handles SMTP delivery. Queue creation is not proof of delivery. Local tests use mocks and do not send mail.

## Live checks after deployment

1. Confirm the Trigger Email extension watches `mail` and its SMTP configuration is healthy.
2. Submit a clearly identified test quote using an approved contact address; record the displayed reference.
3. Confirm `quotes/{id}` contains finalized files and `mail/quote-{id}` has delivery state `SUCCESS`. Investigate delivery errors if not.
4. Confirm receipt at `minhvu@mvmanufacturing.com`, reply-to behavior, and owner access to drawings in Storage. Test both text-only and file requests.
5. Verify non-www home/deep links return 301 to www while preserving query strings, and www pages return 200.

Deployment and a real test email were not performed during this local update.

## Scroll adjustment

Wheel speed cap is now 800 px/s (previously 400). The controller consumes at most 32 ms per displayed frame, retaining unspent input after a stall instead of jumping up to 80 px. Touch, keyboard, reduced-motion, and nested controls remain native. The owner-photo zoom layer is prepared within 400 px of the viewport and released offscreen.

Local first-pass Materials profiling found rendering stalls with stable document height, stable section position, no layout shifts, and no backward scroll. Repeated warm passes were smooth. `scripts/profile-materials.cjs` provides local-only comparison controls; it is not shipped.

Final local first-pass comparison: 17 ms p95 frame interval, two intervals above 34 ms (maximum 116.7 ms), stable section/document geometry, and no backward motion. Catch-up movement during those stalls was 25.5–26 px, down from 80 px. A synchronous scroll-position read immediately after each write was removed. Occasional cold rendering stalls remain; these measurements do not establish their GPU/driver cause or guarantee frame timing on other hardware. All 32 automated tests passed; the final scrolling edit also passed all 26 SSR/motion tests.
