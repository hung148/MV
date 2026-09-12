const fs = require('node:fs');
for (const name of fs.readdirSync('assets/videos').filter(name => name.endsWith('.mp4'))) {
  const data = fs.readFileSync(`assets/videos/${name}`);
  const result = { name, megabytes: +(data.length / 1e6).toFixed(2), tracks: [] };
  function walk(start, end, track = null) {
    for (let pos = start; pos + 8 <= end;) {
      let size = data.readUInt32BE(pos), header = 8;
      const type = data.toString('ascii', pos + 4, pos + 8);
      if (size === 1) { size = Number(data.readBigUInt64BE(pos + 8)); header = 16; }
      if (!size) size = end - pos;
      if (size < header || pos + size > end) break;
      const p = pos + header;
      if (type === 'trak') { const t = {}; result.tracks.push(t); walk(p, pos + size, t); }
      else if (['moov','mdia','minf','stbl'].includes(type)) walk(p, pos + size, track);
      else if (track && type === 'tkhd') { track.width = data.readUInt32BE(pos + size - 8) / 65536; track.height = data.readUInt32BE(pos + size - 4) / 65536; }
      else if (track && type === 'mdhd') { const v1 = data[p] === 1; const timescale = data.readUInt32BE(p + (v1 ? 20 : 12)); const duration = v1 ? Number(data.readBigUInt64BE(p + 24)) : data.readUInt32BE(p + 16); track.seconds = +(duration / timescale).toFixed(2); track.timescale = timescale; }
      else if (track && type === 'stsd') track.codec = data.toString('ascii', p + 12, p + 16);
      else if (track && type === 'stts') { let frames = 0, ticks = 0; for (let i = 0; i < data.readUInt32BE(p + 4); i++) { const count = data.readUInt32BE(p + 8 + i * 8), delta = data.readUInt32BE(p + 12 + i * 8); frames += count; ticks += count * delta; } track.fps = +(frames * track.timescale / ticks).toFixed(2); }
      pos += size;
    }
  }
  walk(0, data.length); console.log(JSON.stringify(result));
}
