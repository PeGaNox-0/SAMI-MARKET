import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (_emailController.text.trim().isEmpty) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            _emailController.text.trim(),
          );
      setState(() => _sent = true);
    } catch (e) {
      // Still show success to prevent email enumeration
      setState(() => _sent = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetPassword)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read_outlined,
                      size: 64, color: AppColors.payment),
                  const SizedBox(height: 24),
                  Text(
                    'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.login),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.resetPasswordMessage, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendReset,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.sendResetLink),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
