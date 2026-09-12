'use strict';
const { render, routes } = require('./render.cjs');
function handler(req, res) {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.setHeader('Allow', 'GET, HEAD');
    res.statusCode = 405; return res.end('Method not allowed');
  }
  let url;
  try { url = new URL(req.url, 'http://localhost'); } catch { res.statusCode = 400; return res.end('Bad request'); }
  const path = url.pathname;
  // Match the established www canonical, preserving deep links and queries.
  // Only redirect our known alias; local previews and unknown hosts stay local.
  const host = (req.headers.host || '').toLowerCase().replace(/:\d+$/, '');
  if (host === 'mvmanufacturing.com') {
    const canonicalPath = path !== '/' && path.endsWith('/') && Object.hasOwn(routes, path.slice(0, -1)) ? path.slice(0, -1) : path;
    res.statusCode = 308;
    res.setHeader('Location', 'https://www.mvmanufacturing.com' + canonicalPath + url.search);
    return res.end();
  }
  if (path !== '/' && path.endsWith('/') && Object.hasOwn(routes, path.slice(0, -1))) {
    res.statusCode = 308; res.setHeader('Location', path.slice(0, -1) + url.search); return res.end();
  }
  const found = Object.hasOwn(routes, path);
  res.statusCode = found ? 200 : 404;
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', found ? 'public, max-age=0, s-maxage=3600, stale-while-revalidate=86400' : 'no-store');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  res.end(req.method === 'HEAD' ? undefined : render(found ? path : '/404'));
}
module.exports = { handler };
