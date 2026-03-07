import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';

/// Call this from any page or widget to open the quote dialog.
///
/// Example:
///   ElevatedButton(
///     onPressed: () => showQuoteDialog(context),
///     child: const Text('Get a Quote'),
///   )
void showQuoteDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const QuoteFormDialog(),
  );
}

/// The dialog widget itself. Can also be used directly if needed.
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

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance.collection('quotes').add({
        'fullName':    _nameController.text.trim(),
        'email':       _emailController.text.trim(),
        'phone':       _phoneController.text.trim(),
        'company':     _companyController.text.trim(),
        'details':     _detailsController.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
        'status':      'new',
      });
      setState(() {
        _isSuccess = true;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('🔴 Firestore error: $e');
      debugPrint('🔴 Stack: $stack');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(32),
        child: _isSuccess ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  // ── Success screen ──────────────────────────────────────────────────────────

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quote Request Sent!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          "We've received your request and will be in touch shortly. "
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

  // ── Form ────────────────────────────────────────────────────────────────────

  Widget _buildForm() {
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
            const Divider(height: 40),

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
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
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
              maxLines: 4,
              maxLength: 1000,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please describe your project';
                if (v.trim().length < 10) return 'Please provide more detail (min 10 chars)';
                return null;
              },
            ),

            // Error banner
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

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ShopStyles.primaryButton,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send Inquiry',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            // Location footer
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