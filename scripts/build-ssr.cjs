'use strict';
const fs = require('node:fs');
const path = require('node:path');
const { render, routes } = require('../functions/site/render.cjs');
const root = path.resolve(__dirname, '..');
const output = path.join(root, 'build/ssr');
fs.mkdirSync(output, { recursive: true });
fs.cpSync(path.join(root, 'functions/site/public'), path.join(output, 'site'), { recursive: true });
fs.cpSync(path.join(root, 'assets'), path.join(output, 'assets'), { recursive: true });
fs.copyFileSync(path.join(root, 'web/favicon.ico'), path.join(output, 'favicon.ico'));
fs.writeFileSync(path.join(output, 'robots.txt'), 'User-agent: *\nAllow: /\nSitemap: https://www.mvmanufacturing.com/sitemap.xml\n');
fs.writeFileSync(path.join(output, 'sitemap.xml'), `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${Object.keys(routes).map(route => `<url><loc>https://www.mvmanufacturing.com${route}</loc></url>`).join('')}</urlset>`);
// Validate every render during the build, but do not emit index.html: Hosting
// must reach the SSR function for page requests, including direct deep links.
for (const route of Object.keys(routes)) {
  const html = render(route);
  if (!html.includes('<h1>') || html.includes('flutter_bootstrap')) throw new Error(`Invalid SSR document: ${route}`);
  for (const [, asset] of html.matchAll(/(?:src|href)="(\/(?:assets|site)\/[^"?]+)"/g)) {
    if (!fs.existsSync(path.join(output, asset))) throw new Error(`Missing asset ${asset} on ${route}`);
  }
}
console.log(`Built SSR assets in ${output}; verified ${Object.keys(routes).length} server-rendered routes.`);
