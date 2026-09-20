# Hero video scroll investigation

Measured in the connected Windows Chrome browser on 2026-09-18, using the
local SSR build and `node scripts/profile-scroll.cjs` (port 3003).

The diagnostic button compares identical wheel input with playback paused,
playing, the scroll animation frozen, and the video hidden. It also disables
the identity filter temporarily, then restores it. All temporary styles and
playback state are restored after the run. Keep the tab visible throughout.
The probe is injected only by this development server, never the public build.

## Findings

Before the identity filter, idle playback had a 17.1 ms 95th-percentile
animation-frame interval and zero dropped video frames. Scrolling with playback
had 83.3 ms p95 intervals, a 100.4 ms maximum, and 11 dropped video frames.
Pausing playback still left 66.7 ms p95 scroll intervals. Freezing the video's
scroll transform instead yielded 18.2 ms p95 and zero dropped video frames.
Hiding the video also removed the stalls. Long Animation Frame entries did not
attribute these stalls to expensive JavaScript.

Combining scale and translation into one transform did not resolve the problem
and that experiment was reverted. Adding `filter: brightness(1)` to hero videos
did: with the original parallax/zoom implementation restored, scrolling with
playback measured 17.0 ms p95, 17.2 ms maximum, zero intervals over 25 ms, and
zero dropped video frames out of 42. Video assets, dimensions, playback rate,
scroll easing, and the then-current 400 px/s speed cap were unchanged in that comparison. The later Materials update raises the cap to 800 px/s.

A subsequent same-page off/on control reproduced the regression: disabling
only the filter yielded 99.6 ms p95, 100.7 ms maximum and 12 dropped video frames
out of 39. Restoring it yielded 17.1 ms p95, 17.2 ms maximum and zero dropped
video frames out of 40. Both conditions retained the moving scroll transforms.

The evidence isolates the problem to how this Chrome/Windows configuration
composes a transformed video, rather than video bitrate or download time.
The filter is an identity operation (no intended color/brightness change),
but changes the compositing path. It is scoped to hero videos only. The exact
GPU/driver internals are not proven by these measurements, and the extra
compositing pass may have a power cost on other hardware.

These are short local comparisons of requestAnimationFrame callback intervals
and HTML video playback-quality counters, not GPU presentation timestamps or
a guarantee of performance on every device. The browser's GPU report indicates
hardware acceleration is enabled. No browser flags or system settings changed.
