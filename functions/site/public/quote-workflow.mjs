export const mimeTypes = Object.freeze({ pdf: 'application/pdf', png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', zip: 'application/zip', step: 'application/octet-stream', stp: 'application/octet-stream', iges: 'application/octet-stream', igs: 'application/octet-stream', stl: 'application/octet-stream', dxf: 'application/dxf', dwg: 'application/dwg' });
export function validateFile(file) {
  const extension = file.name.split('.').pop().toLowerCase();
  if (!Object.hasOwn(mimeTypes, extension)) return `“${file.name}” is not a supported file type.`;
  if (file.size > 10 * 1024 * 1024) return `“${file.name}” exceeds the 10 MB limit.`;
  if (!file.size) return `“${file.name}” is empty.`;
  return null;
}
export function validateFields(fields, elapsed) {
  for (const [key, label, max] of [['fullName', 'Full Name', 100], ['email', 'Email', 100], ['phone', 'Phone', 30], ['company', 'Company', 100], ['details', 'Project Details', 1000]]) {
    if (!fields[key]?.trim() || fields[key].length > max) return `Please enter ${label} (up to ${max} characters).`;
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fields.email)) return 'Please enter a valid email address.';
  if (fields.details.length < 10) return 'Please provide at least 10 characters of project details.';
  if (fields._hp || elapsed < 2000) return 'Please review your details and try again.';
  return null;
}
// A retry reuses the acknowledged document and completed uploads. The files field
// is deliberately absent at creation, then finalized even for a text-only quote:
// the existing email function triggers on that absent → present transition.
export async function submitQuote(api, state, fields, files, onProgress) {
  if (!state.reference) state.reference = await api.create(fields);
  state.completed ??= new Map();
  for (let i = 0; i < files.length; i++) {
    if (state.completed.has(i)) continue;
    const file = files[i];
    const name = `${i + 1}-${file.name.replace(/[^\w.\-]/g, '_').replace(/_+/g, '_')}`;
    const type = mimeTypes[file.name.split('.').pop().toLowerCase()];
    await api.upload(state.reference, name, file, type, progress => onProgress(i, progress));
    state.completed.set(i, { name, size: file.size, type });
  }
  await api.finalize(state.reference, [...state.completed.values()]);
}
