import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mv/models/quote_model.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';
import 'package:mv/widgets/hover_lift.dart';

/// Call this from any page or widget to open the quote dialog.
///
/// Example:
///   ElevatedButton(
///     onPressed: () => showQuoteDialog(context),
///     child: const Text('Get a Quote'),
///   )
void showQuoteDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.85, end: 1.0).animate(curved);
      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
      return FadeTransition(
        opacity: opacity,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
        QuoteFormDialog(key: UniqueKey()),
  );
}

// ─── Allowed file extensions ──────────────────────────────────────────────────
const _allowedExtensions = {
  'step', 'stp', 'iges', 'igs', 'stl', 'dxf', 'dwg', 'pdf', 'png', 'jpg', 'jpeg', 'zip',
};

const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
const int _maxFileCount = 5;

// ─── MIME type mapping ────────────────────────────────────────────────────────
const _mimeMap = <String, String>{
  'pdf': 'application/pdf',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'zip': 'application/zip',
  'step': 'application/octet-stream',
  'stp': 'application/octet-stream',
  'iges': 'application/octet-stream',
  'igs': 'application/octet-stream',
  'stl': 'application/octet-stream',
  'dxf': 'application/dxf',
  'dwg': 'application/dwg',
};

String? _mimeTypeFor(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  return _mimeMap[ext];
}

class QuoteFormDialog extends StatefulWidget {
  const QuoteFormDialog({super.key});

  @override
  State<QuoteFormDialog> createState() => _QuoteFormDialogState();
}

class _QuoteFormDialogState extends State<QuoteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _phoneController   = TextEditingController();
  final _companyController = TextEditingController();
  final _detailsController = TextEditingController();
  final _companyWebsiteController = TextEditingController();

  late final DateTime _formOpenedAt;

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  final List<_PendingFile> _pendingFiles = [];

  @override
  void initState() {
    super.initState();
    _formOpenedAt = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _detailsController.dispose();
    _companyWebsiteController.dispose();
    super.dispose();
  }

  // ─── File picker ──────────────────────────────────────────────────────────
  Future<void> _pickFiles() async {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..multiple = true
      ..accept = _allowedExtensions.map((e) => '.$e').join(',')
      ..style.display = 'none';

    // Must be attached to the DOM for the change event to fire in Flutter Web.
    web.document.body!.append(input);

    final completer = Completer<List<web.File>>();

    void onChange(web.Event _) {
      final fileList = input.files;
      final list = <web.File>[];
      if (fileList != null) {
        for (var i = 0; i < fileList.length; i++) {
          list.add(fileList.item(i)!);
        }
      }
      // Always complete (empty list = cancelled or no files selected).
      if (!completer.isCompleted) completer.complete(list);
    }

    // Also resolve on window focus in case the user dismisses without picking.
    void onFocus(web.Event _) {
      // Small delay so the change event (if any) fires first.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!completer.isCompleted) completer.complete([]);
      });
    }

    final changeHandler = onChange.toJS;
    final focusHandler  = onFocus.toJS;

    input.addEventListener('change', changeHandler);
    web.window.addEventListener('focus', focusHandler);

    input.click();

    final files = await completer.future;

    // Clean up DOM and listeners.
    input.removeEventListener('change', changeHandler);
    web.window.removeEventListener('focus', focusHandler);
    input.remove();

    if (files.isEmpty) return;

    for (final file in files) {
      if (_pendingFiles.length >= _maxFileCount) break;

      final name = file.name;
      final ext  = name.split('.').last.toLowerCase();

      if (!_allowedExtensions.contains(ext)) {
        _showInlineError('.$ext files are not supported. Allowed: ${_allowedExtensions.take(6).join(", ")}, …');
        continue;
      }

      final sizeBytes = file.size;
      if (sizeBytes > _maxFileSizeBytes) {
        _showInlineError('"$name" exceeds the 10 MB limit.');
        continue;
      }

      if (_pendingFiles.any((f) => f.name == name)) {
        _showInlineError('"$name" is already attached.');
        continue;
      }

      setState(() {
        _pendingFiles.add(_PendingFile(
          webFile: file,
          name: name,
          sizeLabel: _formatBytes(sizeBytes),
        ));
      });
    }
  }

  void _removeFile(int index) => setState(() => _pendingFiles.removeAt(index));

  void _showInlineError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _errorMessage == message) {
        setState(() => _errorMessage = null);
      }
    });
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Create Firestore doc.
      final quote = QuoteModel(
        fullName: _nameController.text.trim(),
        email:    _emailController.text.trim(),
        phone:    _phoneController.text.trim(),
        company:  _companyController.text.trim(),
        details:  _detailsController.text.trim(),
      );
      final docRef = await FirebaseFirestore.instance.collection('quotes').add({
        ...quote.toMap(),
        'submittedAt': FieldValue.serverTimestamp(),
        'status':      'new',
        '_hp':         _companyWebsiteController.text,
        '_t':          DateTime.now().difference(_formOpenedAt).inMilliseconds,
      });
      final quoteId = docRef.id;

      // Step 2: Upload files.
      final fileMetas = <Map<String, dynamic>>[];

      for (int i = 0; i < _pendingFiles.length; i++) {
        final pending = _pendingFiles[i];

        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            final safeName = pending.name
                .replaceAll(RegExp(r'[^\w\-.]'), '_')
                .replaceAll(RegExp(r'_{2,}'), '_')
                .replaceAll(RegExp(r'^_+|_+$'), '');

            final ref = FirebaseStorage.instance.ref('quotes/$quoteId/$safeName');

            // Read file bytes via FileReader.
            final reader    = web.FileReader();
            final bytesDone = Completer<Uint8List>();

            void onError(web.Event _) {
              if (!bytesDone.isCompleted) {
                bytesDone.completeError(Exception('Failed to read file: ${pending.name}'));
              }
            }

            void onLoadEnd(web.Event _) {
              if (bytesDone.isCompleted) return;
              try {
                final jsBuffer = (reader.result as JSObject).dartify() as ByteBuffer;
                bytesDone.complete(jsBuffer.asUint8List());
              } catch (e) {
                bytesDone.completeError(e);
              }
            }

            final errorHandler   = onError.toJS;
            final loadEndHandler = onLoadEnd.toJS;

            reader.addEventListener('error',   errorHandler);
            reader.addEventListener('loadend', loadEndHandler);
            reader.readAsArrayBuffer(pending.webFile!);

            final bytes = await bytesDone.future;

            reader.removeEventListener('error',   errorHandler);
            reader.removeEventListener('loadend', loadEndHandler);

            final mime = _mimeTypeFor(safeName) ?? 'application/octet-stream';
            final uploadTask = ref.putData(bytes, SettableMetadata(contentType: mime));

            uploadTask.snapshotEvents.listen((snapshot) {
              if (!mounted) return;
              final progress = snapshot.bytesTransferred / snapshot.totalBytes;
              setState(() => _pendingFiles[i].uploadProgress = progress);
            });

            await uploadTask;
            if (mounted) setState(() => _pendingFiles[i].uploadProgress = 1.0);

            fileMetas.add({
              'name': safeName,
              'size': pending.webFile!.size,
              'type': mime,
            });

            break; // success
          } catch (e) {
            if (attempt < 2) {
              await Future.delayed(Duration(seconds: 1 << attempt));
            } else {
              debugPrint('⚠️ Upload failed after 3 attempts for ${pending.name}: $e');
              rethrow;
            }
          }
        }
      }

      // Step 3: Write file metadata back to the doc.
      if (fileMetas.isNotEmpty) {
        await docRef.update({'files': fileMetas});
      }

      setState(() {
        _isSuccess = true;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('🔴 Firestore error: $e\n$stack');
      setState(() {
        _errorMessage = _friendlyError(e);
        _isLoading    = false;
      });
    }
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (raw.contains('network') || raw.contains('unavailable')) {
      return 'Network error — please check your connection and try again.';
    }
    if (raw.contains('storage') || raw.contains('upload')) {
      return 'File upload failed. Try removing attachments or using a smaller file.';
    }
    if (raw.contains('permission') || raw.contains('unauthorized')) {
      return 'Submission blocked — please refresh the page and try again.';
    }
    return 'Something went wrong. Please try again or call ${CompanyContact.phone}.';
  }

  void _showLoadingNotification(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top:   isMobile ? 20 : 24,
        right: isMobile ? 12 : 24,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              alignment: Alignment.topRight,
              child: Opacity(opacity: value, child: child),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(38),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Please wait while we submit your request…',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry?.remove());
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;
    final isMobile     = screenWidth < 600;
    final hPad         = isMobile ? 20.0 : 32.0;

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isLoading) _showLoadingNotification(context);
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 40,
          vertical:   isMobile ? 16 : 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520, maxHeight: screenHeight * 0.92),
          child: Padding(
            padding: EdgeInsets.all(hPad),
            child: _isSuccess ? _buildSuccess() : _buildForm(isMobile),
          ),
        ),
      ),
    );
  }

  // ── Success ────────────────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quote Request Sent!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          "We've received your request and will be in touch at "
          "${_emailController.text.trim()}. "
          "For urgent inquiries call ${CompanyContact.phone}.",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ShopStyles.primaryButton,
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────

  Widget _buildForm(bool isMobile) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request a Quote', style: ShopStyles.heading),
            const SizedBox(height: 8),
            Text(
              'Submit your requirements or contact us directly at ${CompanyContact.phone}',
              style: ShopStyles.body,
            ),
            Divider(height: isMobile ? 24 : 40),

            _buildField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              maxLength: 50,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              maxLength: 100,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              maxLength: 30,
              keyboardType: TextInputType.phone,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Please enter your phone number';
                if (!RegExp(r'^[0-9()+\-\s]{7,20}$').hasMatch(t)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _companyController,
              label: 'Company Name',
              icon: Icons.business_outlined,
              maxLength: 100,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your company name' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _detailsController,
              label: 'Project Details',
              icon: Icons.description_outlined,
              maxLines: isMobile ? 2 : 4,
              maxLength: 1000,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please describe your project';
                if (v.trim().length < 10) return 'Please provide more detail (min 10 chars)';
                return null;
              },
            ),

            const SizedBox(height: 16),
            _buildFileSection(),

            // Honeypot — hidden from real users, bots will fill it.
            Offstage(
              offstage: true,
              child: TextField(
                controller: _companyWebsiteController,
                decoration: const InputDecoration(
                  labelText: 'Company Website',
                  hintText: 'Leave this empty',
                ),
                autocorrect: false,
                enableSuggestions: false,
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: isMobile ? 12 : 24),

            SizedBox(
              width: double.infinity,
              child: HoverLift(
                liftPx: 2,
                addShadow: true,
                borderRadius: 8,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ShopStyles.primaryButton,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Sending…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : const Text(
                          'Send Inquiry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),

            const Divider(height: 32),
            const Text(
              'Shop Location & Hours:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(CompanyContact.fullAddress, style: ShopStyles.body),
            Text(
              'Mon–Fri: ${CompanyContact.operatingHours["Monday - Friday"]}',
              style: ShopStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  // ── File section ──────────────────────────────────────────────────────────

  Widget _buildFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Files (optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        const Text(
          'CAD drawings, blueprints, or reference images (max 5 files, 10 MB each).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        HoverLift(
          liftPx: 2,
          addShadow: false,
          borderRadius: 4,
          child: OutlinedButton.icon(
            onPressed: _isLoading || _pendingFiles.length >= _maxFileCount ? null : _pickFiles,
            icon: const Icon(Icons.attach_file, size: 18),
            label: Text(
              _pendingFiles.length >= _maxFileCount
                  ? 'Maximum $_maxFileCount files reached'
                  : 'Select Files',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: ShopStyles.primaryBlue,
              side: BorderSide(
                color: _pendingFiles.length >= _maxFileCount
                    ? Colors.grey.shade300
                    : ShopStyles.primaryBlue,
              ),
            ),
          ),
        ),
        if (_pendingFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...List.generate(_pendingFiles.length, (i) {
            final f = _pendingFiles[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          f.uploadProgress == 1.0
                              ? Icons.check_circle_outline
                              : Icons.description,
                          size: 18,
                          color: f.uploadProgress == 1.0
                              ? Colors.green.shade600
                              : ShopStyles.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(f.sizeLabel, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        const SizedBox(width: 4),
                        if (!_isLoading)
                          InkWell(
                            onTap: () => _removeFile(i),
                            child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                    if (f.uploadProgress != null && f.uploadProgress! < 1.0) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: f.uploadProgress,
                          minHeight: 3,
                          backgroundColor: Colors.blue.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(ShopStyles.primaryBlue),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── Field builder ─────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      decoration: ShopStyles.inputDecoration(label, icon).copyWith(counterText: ''),
    );
  }
}

// ─── Pending file model ───────────────────────────────────────────────────────

class _PendingFile {
  final web.File? webFile;
  final String name;
  final String sizeLabel;

  /// 0.0–1.0 while uploading, null when idle or complete.
  double? uploadProgress;

  _PendingFile({required this.webFile, required this.name, required this.sizeLabel});
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}