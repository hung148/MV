'use strict';
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const { handler } = require('./handler.cjs');
const root = path.resolve(__dirname, '../../build/ssr');
const types = { '.css': 'text/css', '.js': 'text/javascript', '.mjs': 'text/javascript', '.webp': 'image/webp', '.mp4': 'video/mp4', '.ico': 'image/x-icon', '.png': 'image/png', '.xml': 'application/xml', '.txt': 'text/plain' };
const server = http.createServer((req, res) => {
  let pathname;
  try { pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname); } catch { res.statusCode = 400; return res.end('Bad request'); }
  const file = path.resolve(root, '.' + pathname);
  if (!file.startsWith(root + path.sep) || !fs.existsSync(file) || !fs.statSync(file).isFile()) return handler(req, res);
  if (!['GET', 'HEAD'].includes(req.method)) { res.statusCode = 405; return res.end(); }
  res.setHeader('Content-Type', types[path.extname(file)] || 'application/octet-stream');
  const size = fs.statSync(file).size;
  const range = req.headers.range?.match(/^bytes=(\d+)-(\d*)$/);
  let start = range ? Number(range[1]) : 0;
  let end = range && range[2] ? Number(range[2]) : size - 1;
  if (start >= size || end >= size || start > end) { res.statusCode = 416; res.setHeader('Content-Range', `bytes */${size}`); return res.end(); }
  res.setHeader('Accept-Ranges', 'bytes');
  res.setHeader('Content-Length', end - start + 1);
  if (range) { res.statusCode = 206; res.setHeader('Content-Range', `bytes ${start}-${end}/${size}`); }
  if (req.method === 'HEAD') return res.end();
  fs.createReadStream(file, { start, end }).pipe(res);
});
if (require.main === module) server.listen(Number(process.env.PORT || 3000), '127.0.0.1', () => console.log(`MV SSR preview: http://127.0.0.1:${server.address().port}`));
module.exports = { server };
