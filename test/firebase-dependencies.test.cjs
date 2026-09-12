'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createRequire } = require('node:module');
const functionsRequire = createRequire(require.resolve('../functions/package.json'));

test('Firebase entry point loads both function generations with Admin 14', () => {
  const exported = require('../functions/index.js');
  assert.equal(typeof exported.ssrSite, 'function');
  assert.equal(typeof exported.onQuoteWithFiles, 'function');
  const { getFirestore } = functionsRequire('firebase-admin/firestore');
  assert.equal(typeof getFirestore, 'function');
});

test('Storage HTTP client creates a valid multipart body with patched UUID', async () => {
  const storageRequire = createRequire(functionsRequire.resolve('@google-cloud/storage'));
  const { Gaxios } = storageRequire('gaxios');
  const response = await new Gaxios().request({
    url: 'https://example.invalid/upload',
    method: 'POST',
    multipart: [{ headers: { 'Content-Type': 'text/plain' }, content: 'test payload' }],
    adapter: async options => {
      const boundary = options.headers['Content-Type'].split('boundary=')[1];
      assert.match(boundary, /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i);
      let body = '';
      for await (const chunk of options.body) body += chunk.toString();
      assert.ok(body.includes('test payload'));
      assert.ok(body.startsWith(`--${boundary}\r\n`));
      assert.ok(body.endsWith(`--${boundary}--`));
      return { status: 200, statusText: 'OK', headers: {}, data: 'ok', config: options };
    },
  });
  assert.equal(response.data, 'ok');
});
