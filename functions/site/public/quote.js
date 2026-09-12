import { validateFile, validateFields, submitQuote } from './quote-workflow.mjs';

let initialized = false;
let sdk;
async function getApi() {
  sdk ??= Promise.all([
    import('https://www.gstatic.com/firebasejs/12.18.0/firebase-app.js'),
    import('https://www.gstatic.com/firebasejs/12.18.0/firebase-firestore.js'),
    import('https://www.gstatic.com/firebasejs/12.18.0/firebase-storage.js'),
  ]).then(([appSdk, dbSdk, storageSdk]) => {
    const app = appSdk.initializeApp({ apiKey: 'AIzaSyCVVjKOQ-qANFlf6BEbLxs8HcE1RNE0gO8', appId: '1:997330990310:web:55926a158ca0f0c167f727', projectId: 'mv-web-35fcc', authDomain: 'mv-web-35fcc.firebaseapp.com', storageBucket: 'mv-web-35fcc.firebasestorage.app', messagingSenderId: '997330990310' });
    const db = dbSdk.getFirestore(app);
    const storage = storageSdk.getStorage(app);
    return {
      create: fields => dbSdk.addDoc(dbSdk.collection(db, 'quotes'), { ...fields, status: 'new', submittedAt: dbSdk.serverTimestamp() }),
      upload: (doc, name, file, contentType, progress) => new Promise((resolve, reject) => {
        const task = storageSdk.uploadBytesResumable(storageSdk.ref(storage, `quotes/${doc.id}/${name}`), file, { contentType });
        task.on('state_changed', snapshot => progress(snapshot.bytesTransferred / snapshot.totalBytes), reject, resolve);
      }),
      finalize: (doc, files) => dbSdk.updateDoc(doc, { files }),
    };
  }).catch(error => { sdk = null; throw error; });
  return sdk;
}
export function initQuote(openedAt) {
  if (initialized) return;
  initialized = true;
  const form = document.querySelector('#quote-form');
  const picker = document.querySelector('#quote-files');
  const list = document.querySelector('#file-list');
  const status = document.querySelector('#quote-status');
  const fieldset = form.querySelector('fieldset');
  const submit = form.querySelector('[type=submit]');
  submit.disabled = false;
  const files = [];
  const state = {};
  let busy = false;
  let done = false;
  let submittedFields;
  function message(text, error = false) { status.textContent = text; status.toggleAttribute('data-error', error); }
  function renderFiles() {
    list.replaceChildren();
    files.forEach((file, i) => {
      const li = document.createElement('li');
      const span = document.createElement('span');
      span.textContent = `${file.name} (${(file.size / 1024 / 1024).toFixed(2)} MB)`;
      const remove = document.createElement('button');
      remove.type = 'button'; remove.textContent = 'Remove'; remove.setAttribute('aria-label', `Remove ${file.name}`);
      remove.addEventListener('click', () => { if (!submittedFields) { files.splice(i, 1); renderFiles(); } });
      li.append(span, remove); list.append(li);
    });
  }
  picker.addEventListener('change', () => {
    if (submittedFields) return;
    message('');
    for (const file of picker.files) {
      const error = validateFile(file);
      if (error) { message(error, true); continue; }
      if (files.length >= 5) { message('You can attach up to 5 files.', true); break; }
      if (files.some(existing => existing.name === file.name)) { message(`“${file.name}” is already attached.`, true); continue; }
      files.push(file);
    }
    picker.value = ''; renderFiles();
  });
  form.addEventListener('submit', async event => {
    event.preventDefault();
    if (busy || done) return;
    const elapsed = Date.now() - openedAt;
    const data = new FormData(form);
    const fields = submittedFields || Object.fromEntries(['fullName', 'email', 'phone', 'company', 'details'].map(key => [key, String(data.get(key) || '').trim()]));
    if (!submittedFields) { fields._hp = String(data.get('website') || ''); fields._t = elapsed; }
    const error = validateFields(fields, fields._t);
    if (error) { message(error, true); return; }
    busy = true; fieldset.disabled = true; message('Sending your request…');
    try {
      const api = await getApi();
      submittedFields = fields;
      await submitQuote(api, state, fields, files, (i, progress) => message(`Uploading file ${i + 1} of ${files.length}: ${Math.round(progress * 100)}%`));
      done = true; message('Thank you! Your quote request has been submitted. We’ll get back to you within 24 hours.');
      submit.textContent = 'Request Submitted';
    } catch {
      message(state.reference ? 'Your details were saved, but attachments or final confirmation could not finish. Check your connection and retry. Your saved request will be reused. If more than 10 minutes have passed, call (669) 243-9228.' : 'We could not confirm your submission. Check your connection and try again, or call (669) 243-9228.', true);
      fieldset.disabled = false;
      // Freeze the payload during retries; changing files after uploading would
      // silently detach already-uploaded drawings from the saved request.
      if (submittedFields) form.querySelectorAll('input, textarea, #file-list button').forEach(input => { input.disabled = true; });
      submit.textContent = 'Retry Submission';
    } finally { busy = false; }
  });
}
