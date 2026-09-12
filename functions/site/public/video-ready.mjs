// Resolve only after moving frames, without trapping navigation on slow/blocked media.
export function waitForMovingVideo(video, signal, timeoutMs = 1500) {
  return new Promise(resolve => {
    let timer, frame, firstTime, settled = false;
    function finish(reason) {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      if (frame !== undefined) video.cancelVideoFrameCallback?.(frame);
      video.removeEventListener('playing', playing);
      video.removeEventListener('error', failed);
      signal.removeEventListener('abort', aborted);
      video.dataset.navigationReady = reason;
      resolve(reason);
    }
    const failed = () => finish('unavailable');
    const aborted = () => finish('aborted');
    function nextFrame(now, metadata) {
      if (firstTime !== undefined && metadata.mediaTime > firstTime) return finish('moving');
      firstTime = metadata.mediaTime;
      frame = video.requestVideoFrameCallback(nextFrame);
    }
    function playing() { if (!video.requestVideoFrameCallback) finish('playing'); }
    if (signal.aborted) return aborted();
    signal.addEventListener('abort', aborted, { once: true });
    video.addEventListener('error', failed, { once: true });
    video.addEventListener('playing', playing, { once: true });
    timer = setTimeout(() => finish('timeout'), timeoutMs);
    if (video.requestVideoFrameCallback) frame = video.requestVideoFrameCallback(nextFrame);
    video.play().then(() => { if (!video.requestVideoFrameCallback) finish('playing'); }).catch(failed);
  });
}
