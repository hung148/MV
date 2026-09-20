'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { notification, queueQuoteNotification } = require('../functions/quote-notification.cjs');
const quote = { fullName: '<Buyer>', email: 'buyer@example.com', phone: '555-0100', company: 'A&B', details: '<script>example</script>', files: [] };

test('notification supports text-only quotes and escapes customer HTML', () => {
  const mail = notification('test-quote', quote);
  assert.equal(mail.replyTo, quote.email);
  assert.deepEqual(mail.to, ['minhvu@mvmanufacturing.com']);
  assert.match(mail.message.html, /&lt;Buyer&gt;/);
  assert.doesNotMatch(mail.message.html, /<script>/);
  assert.match(mail.message.text, /test-quote/);
});

test('maximum upload sizes produce a small notification, not a Firestore-sized attachment', () => {
  const mail = notification('large-quote', { ...quote, files: Array.from({ length: 5 }, (_, i) => ({ name: `${i}-part.step`, size: 10 * 1024 * 1024 })) });
  assert.ok(Buffer.byteLength(JSON.stringify(mail)) < 10000);
  assert.equal(mail.message.attachments, undefined);
  assert.match(mail.message.html, /4-part.step/);
  assert.match(mail.message.html, /owner sign-in required/);
});

test('duplicate event deliveries create only one notification', async () => {
  const saved = new Map();
  const db = { collection(name) { assert.equal(name, 'mail'); return { doc(id) { return { async create(data) { if (saved.has(id)) throw Object.assign(new Error('exists'), { code: 6 }); saved.set(id, data); } }; } }; } };
  assert.equal(await queueQuoteNotification(db, 'q1', quote), 'queued');
  assert.equal(await queueQuoteNotification(db, 'q1', quote), 'already-queued');
  assert.equal(saved.size, 1);
});

test('transient notification errors propagate so Firebase can retry', async () => {
  const db = { collection() { return { doc() { return { async create() { throw Object.assign(new Error('offline'), { code: 14 }); } }; } }; } };
  await assert.rejects(queueQuoteNotification(db, 'q2', quote), /offline/);
});
