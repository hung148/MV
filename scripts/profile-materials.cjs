// Local-only diagnostic controls; never included in the production build.
const { server } = require('../functions/site/dev.cjs');
function probe() {
  let skipReveals = false;
  const originalAnimate = Element.prototype.animate;
  Element.prototype.animate = function(frames, options) { const animation = originalAnimate.call(this, frames, skipReveals && !options?.timeline ? {...options,duration:0,delay:0} : options); return animation; };
  const panel = document.createElement('div');
  panel.style.cssText = 'position:fixed;z-index:99999;right:8px;top:80px;background:white;color:black;padding:12px;max-width:500px;font:12px monospace';
  const output = document.createElement('pre');
  output.id = 'materials-profile';
  output.style.whiteSpace = 'pre-wrap';
  for (const mode of ['baseline', 'no-photo-motion', 'photo-layer', 'no-reveals', 'contained', 'no-timelines']) {
    const button = document.createElement('button');
    button.textContent = 'Profile ' + mode;
    button.onclick = async () => {
      skipReveals = mode === 'no-reveals';
      const photo = document.querySelector('.home-owner-photo img');
      photo.style.willChange = mode === 'photo-layer' ? 'transform' : '';
      photo.style.setProperty('scale', mode === 'no-photo-motion' ? '1' : '', 'important');
      document.querySelectorAll('.home-materials, .home-owner').forEach(e=>e.style.contain=mode==='contained'?'layout paint':'');
      const material = document.querySelector('.home-material-grid').closest('section');
      const start = material.getBoundingClientRect().top + scrollY - innerHeight;
      scrollTo({top:start,behavior:'instant'});
      output.textContent = 'Running ' + mode;
      if(mode==='no-timelines') document.querySelectorAll('.hero-media,.home-owner-photo img').forEach(e=>e.getAnimations().forEach(a=>a.cancel()));
      await new Promise(resolve => setTimeout(resolve, 700));
      const frames = [], shifts = [], longFrames = [];
      const loaf = new PerformanceObserver(list=>longFrames.push(...list.getEntries().map(e=>({duration:e.duration,render:e.renderStart-e.startTime,style:e.styleAndLayoutStart-e.startTime,scripts:e.scripts?.map(s=>({duration:s.duration,source:s.sourceURL,fn:s.sourceFunctionName,layout:s.forcedStyleAndLayoutDuration}))}))));
      loaf.observe({type:'long-animation-frame'});
      const observer = new PerformanceObserver(list => shifts.push(...list.getEntries().map(e => ({value:e.value,sources:e.sources?.map(s=>s.node?.className)}))));
      observer.observe({type:'layout-shift'});
      const began = performance.now();
      let previous = began, lastY = scrollY;
      await new Promise(resolve => {
        function frame(now) {
          frames.push({dt:now-previous,dy:scrollY-lastY,height:document.documentElement.scrollHeight,top:material.getBoundingClientRect().top+scrollY});
          previous = now; lastY = scrollY;
          if(now-began<3500) {
            document.body.dispatchEvent(new WheelEvent('wheel',{deltaY:80,bubbles:true,cancelable:true}));
            requestAnimationFrame(frame);
          } else resolve();
        }
        requestAnimationFrame(frame);
      });
      observer.disconnect(); loaf.disconnect();
      const times = frames.slice(2).map(f=>f.dt).sort((a,b)=>a-b);
      output.textContent = JSON.stringify({mode,frames:frames.length,p95:times[Math.floor(times.length*.95)],max:Math.max(...times),stalls:times.filter(t=>t>34).length,slowFrames:frames.filter(f=>f.dt>34),backwards:frames.filter(f=>f.dy<0).length,heights:[...new Set(frames.map(f=>f.height))],longFrames,materialPositions:[...new Set(frames.map(f=>f.top))],shifts},null,2);
    };
    panel.append(button);
  }
  panel.append(output);document.body.append(panel);
}
server.prependListener('request', (_req,res) => {
  const end = res.end;
  res.end = function(body,...args) {
    if(typeof body==='string' && String(res.getHeader('Content-Type')).startsWith('text/html')) body=body.replace('</body>',`<script>(${probe.toString()})()</script></body>`);
    return end.call(this,body,...args);
  };
});
server.listen(3006,'127.0.0.1',()=>console.log('Materials profile: http://127.0.0.1:3006'));
