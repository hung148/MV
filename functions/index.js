const functions = require("firebase-functions/v1");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

// Full HTML documents for the public website; Firebase Hosting serves assets.
exports.ssrSite = require('firebase-functions/v2/https').onRequest(
  { region: 'us-central1', memory: '256MiB', maxInstances: 10 },
  require('./site/handler.cjs').handler,
);

// Firestore events can be delivered more than once. Retry transient errors and
// create one deterministic email document per finalized quote.
const { queueQuoteNotification } = require('./quote-notification.cjs');
exports.onQuoteWithFiles = functions.runWith({ failurePolicy: true }).firestore
  .document('quotes/{quoteId}')
  .onUpdate(async change => {
    const before = change.before.data();
    const after = change.after.data();
    if (Object.hasOwn(before, 'files') || !Array.isArray(after.files)) return null;
    const result = await queueQuoteNotification(getFirestore(), change.after.id, after);
    console.log(`Quote notification ${result}: ${change.after.id}`);
    return null;
  });
