// Keep delayed words as ordinary hidden text, not hundreds of backwards-filled
// animation layers. Only create an animation when its word is due to appear.
export function startRevealSequence(sequence, play, clock = {
  now: () => performance.now(),
  set: (callback, delay) => setTimeout(callback, delay),
  clear: timer => clearTimeout(timer),
}) {
  const started = clock.now();
  let index = 0, timer, finished = false;
  for (const { word } of sequence) word.classList.add('text-reveal-waiting');
  function advance() {
    timer = undefined;
    if (finished) return;
    const elapsed = clock.now() - started;
    while (index < sequence.length && sequence[index].delay <= elapsed) {
      const { word, frames, delay } = sequence[index++];
      // Preserve the original timeline after a busy frame, without replaying
      // effects whose full duration passed while the page was inactive.
      try {
        if (elapsed - delay < 550) play(word, frames, {
          duration: 550, delay: delay - elapsed, fill: 'backwards',
        });
      } finally { word.classList.remove('text-reveal-waiting'); }
    }
    if (index < sequence.length) timer = clock.set(advance, Math.max(0, sequence[index].delay - elapsed));
  }
  advance();
  return () => {
    finished = true;
    if (timer !== undefined) clock.clear(timer);
    for (; index < sequence.length; index++) sequence[index].word.classList.remove('text-reveal-waiting');
  };
}
