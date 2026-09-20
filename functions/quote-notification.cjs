'use strict';
const escape = value => String(value ?? '').replace(/[&<>"']/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);

function notification(quoteId, quote) {
  const files = quote.files.map(file => `<li>${escape(file.name)} (${Number(file.size) || 0} bytes)</li>`).join('');
  // Firestore documents are limited to 1 MiB. Never embed CAD files/base64 in mail.
  // The owner uses authenticated Firebase Console access to retrieve drawings.
  const storageURL = `https://console.firebase.google.com/project/mv-web-35fcc/storage/mv-web-35fcc.firebasestorage.app/files/~2Fquotes~2F${encodeURIComponent(quoteId)}`;
  return {
    to: ['minhvu@mvmanufacturing.com'],
    replyTo: quote.email,
    message: {
      subject: `New Quote Request — ${String(quote.fullName).replace(/[\r\n]/g, ' ')} — ${quoteId}`,
      text: `Quote ID: ${quoteId}\nName: ${quote.fullName}\nEmail: ${quote.email}\nPhone: ${quote.phone}\nCompany: ${quote.company}\n\n${quote.details}\n\nFiles: ${quote.files.map(file => file.name).join(', ') || 'None'}\nView uploaded files (owner sign-in required): ${storageURL}`,
      html: `<h2>New Quote Request</h2><p><strong>Reference:</strong> ${escape(quoteId)}</p><p><strong>Name:</strong> ${escape(quote.fullName)}</p><p><strong>Email:</strong> ${escape(quote.email)}</p><p><strong>Phone:</strong> ${escape(quote.phone)}</p><p><strong>Company:</strong> ${escape(quote.company)}</p><p style="white-space:pre-wrap">${escape(quote.details)}</p>${files ? `<h3>Uploaded files</h3><ul>${files}</ul><p><a href="${storageURL}">View drawings in Firebase Console</a> (owner sign-in required).</p>` : '<p>No files attached.</p>'}`,
    },
  };
}

async function queueQuoteNotification(db, quoteId, quote) {
  try {
    await db.collection('mail').doc(`quote-${quoteId}`).create(notification(quoteId, quote));
    return 'queued';
  } catch (error) {
    // Event redelivery or an ambiguous write acknowledgement must not resend mail.
    if (error.code === 6 || error.code === 'already-exists') return 'already-queued';
    throw error;
  }
}
module.exports = { notification, queueQuoteNotification };
