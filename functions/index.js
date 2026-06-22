const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { getStorage } = require("firebase-admin/storage");

admin.initializeApp();

// ─────────────────────────────────────────────────────────────────────────────
// Email notification on new quote with file attachments
//
// Triggers when the `files` field is ADDED to a quote doc (the client creates
// the doc first, uploads files to Storage, then updates the doc with file
// metadata — see lib/widgets/quote_form.dart _submit()).
//
// The Trigger Email Firebase Extension reads from the `mail` collection and
// handles actual delivery. We write a `mail` doc with an `attachments` array
// of { filename, content, encoding } objects.
//
// Safety: total base64 payload is capped at 20 MB (the practical limit for
// email + Cloud Function memory). If files exceed this, they are attached up
// to the cap and the rest become download links in the email body.
// ─────────────────────────────────────────────────────────────────────────────

const ATTACHMENT_CAP_BYTES = 20 * 1024 * 1024; // 20 MB
const BUCKET_NAME = process.env.GCLOUD_STORAGE_BUCKET || null;

exports.onQuoteWithFiles = functions.firestore
  .document("quotes/{quoteId}")
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only act when `files` transitions from absent → present.
    // This guards against re-sending if the doc is updated for other reasons.
    // Accepts both empty arrays (text-only quotes) and populated arrays (with files).
    if (before.files || !after.files || !Array.isArray(after.files)) {
      return null;
    }

    const quoteId = change.after.id;
    const quote = after;

    try {
      // ── Download each file from Storage and base64-encode ────────────────
      const attachments = [];
      const overflowLinks = []; // files too big to attach → included as links
      let totalBytes = 0;

      for (const meta of quote.files) {
        const size = meta.size || 0;

        // If adding this file would exceed the cap, make it a link instead.
        if (totalBytes + size > ATTACHMENT_CAP_BYTES && attachments.length > 0) {
          overflowLinks.push(meta);
          continue;
        }

        try {
          const bucket = getStorage().bucket(BUCKET_NAME);
          const filePath = `quotes/${quoteId}/${meta.name}`;
          const file = bucket.file(filePath);

          const [buffer] = await file.download();
          const content = buffer.toString("base64");

          attachments.push({
            filename: meta.name,
            content: content,
            encoding: "base64",
          });

          totalBytes += size;
        } catch (err) {
          console.error(`Failed to download ${meta.name} for quote ${quoteId}:`, err.message);
          // Fall back to link if download fails.
          overflowLinks.push(meta);
        }
      }

      // ── Build the email HTML ────────────────────────────────────────────
      let attachmentsHtml = "";
      if (attachments.length > 0) {
        attachmentsHtml = `
          <h3>Attached Files</h3>
          <p>${attachments.map((a) => a.filename).join(", ")}</p>`;
      }

      let linksHtml = "";
      if (overflowLinks.length > 0) {
        const bucketLink = BUCKET_NAME
          ? `https://storage.googleapis.com/${BUCKET_NAME}`
          : "(Firebase Console)";
        linksHtml = `
          <h3>Download Links</h3>
          <p style="color:#666;font-size:13px;">
            The following files were too large to attach to this email.
            Download them from Firebase Storage (<code>${bucketLink}/quotes/${quoteId}/</code>)
            or view the quote in the Firebase Console.
          </p>
          <ul>
            ${overflowLinks.map((f) => `<li>${f.name} (${formatBytes(f.size)})</li>`).join("")}
          </ul>`;
      }

      await admin.firestore().collection("mail").add({
        to: ["minhvu@mvmanufacturing.com"],
        message: {
          subject: `New Quote Request from ${quote.fullName}${attachments.length > 0 ? ` [${attachments.length} file${attachments.length > 1 ? "s" : ""}]` : ""}`,
          html: `
            <h2>New Quote Request</h2>
            <p><strong>Name:</strong> ${quote.fullName}</p>
            <p><strong>Email:</strong> ${quote.email}</p>
            <p><strong>Phone:</strong> ${quote.phone}</p>
            <p><strong>Company:</strong> ${quote.company}</p>
            <p><strong>Project Details:</strong></p>
            <p>${quote.details}</p>
            <hr/>
            ${attachmentsHtml}
            ${linksHtml}
            <hr/>
            <p style="color:#999;font-size:12px;">
              Quote ID: ${quoteId}<br/>
              Submitted: ${new Date().toLocaleString()}
            </p>
          `,
          ...(attachments.length > 0 ? { attachments } : {}),
        },
      });

      console.log(`Email sent for quote ${quoteId} with ${attachments.length} attachments, ${overflowLinks.length} links.`);
    } catch (err) {
      console.error(`Failed to process quote ${quoteId}:`, err);
    }
  });

// ── Utility ────────────────────────────────────────────────────────────────────

function formatBytes(bytes) {
  if (!bytes) return "?";
  if (bytes < 1024) return bytes + " B";
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB";
  return (bytes / (1024 * 1024)).toFixed(1) + " MB";
}
