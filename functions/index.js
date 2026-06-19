const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onNewQuote = functions.firestore
  .document("quotes/{quoteId}")
  .onCreate(async (snap) => {
    const quote = snap.data();

    await admin.firestore().collection("mail").add({
      to: ["minhvu@mvmanufacturing.com"],
      message: {
        subject: `New Quote Request from ${quote.fullName}`,
        html: `
          <h2>New Quote Request</h2>
          <p><strong>Name:</strong> ${quote.fullName}</p>
          <p><strong>Email:</strong> ${quote.email}</p>
          <p><strong>Phone:</strong> ${quote.phone}</p>
          <p><strong>Company:</strong> ${quote.company}</p>
          <p><strong>Project Details:</strong></p>
          <p>${quote.details}</p>
          <hr/>
          <p>Submitted at: ${new Date().toLocaleString()}</p>
        `,
      },
    });
  });