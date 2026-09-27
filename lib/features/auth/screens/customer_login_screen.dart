import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/customer_auth_service.dart';
import '../../../data/models/customer_account_model.dart';
import '../../../core/widgets/dark_glass_container.dart';

class CustomerLoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onBackToRoles;

  const CustomerLoginScreen({super.key, required this.onBackToRoles});

  @override
  ConsumerState<CustomerLoginScreen> createState() =>
      _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(customerAuthServiceProvider);
    final code = _codeController.text.trim().toUpperCase();
    final pin = _pinController.text.trim();

    final result = await authService.login(customerCode: code, pin: pin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Save session
      final session = CustomerSession(
        customerId: result['customer_id'] as String,
        customerCode: result['customer_code'] as String,
        customerName: result['customer_name'] as String,
        phone: result['phone'] as String? ?? '',
        marketName: result['market_name'] as String? ?? 'SAMI MARKET',
        pin: pin,
      );

      ref.read(customerSessionProvider.notifier).setSession(session);
      ref.read(activeRoleProvider.notifier).state = AppRole.customer;
    } else {
      final error = result['error'] as String?;

      String message;
      if (error == 'NOT_FOUND') {
        message = 'رمز الزبون غير موجود. تأكد من إدخال الرمز الصحيح.';
      } else if (error == 'ACCOUNT_DISABLED') {
        message = 'تم تعطيل هذا الحساب من قبل صاحب الماركت.';
      } else if (error == 'ACCOUNT_LOCKED') {
        message =
            'تم قفل الحساب مؤقتاً لكثرة المحاولات الخاطئة. يرجى الانتظار 15 دقيقة.';
      } else if (error == 'INVALID_PIN') {
        final remaining = result['attempts_remaining'];
        message = 'الشيفرة غير صحيحة. المتبقي: $remaining محاولات.';
      } else {
        message = 'تعذر تسجيل الدخول. يرجى التحقق من اتصال الإنترنت.';
      }

      setState(() => _errorMessage = message);
    }
  }

  void _showForgotPinDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.forgotPin),
        content: Text(l10n.forgotPinMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget formContent = Column(
      children: [
        // Error alert box
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.15)
                  : AppColors.debt.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppColors.debt.withValues(alpha: 0.3)
                    : AppColors.debt.withAlpha(80),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.debt,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.debt,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Login Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Customer Code Field
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.customerCode,
                  hintText: 'SM-48291',
                  prefixIcon: const Icon(Icons.tag_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'يرجى إدخال رمز الزبون';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // PIN Field
              TextFormField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: l10n.customerPin,
                  hintText: l10n.customerPinHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'يرجى إدخال الشيفرة السرية';
                  }
                  if (v.trim().length < 4) {
                    return 'الشيفرة يجب أن تكون 4 أرقام على الأقل';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 8),

              // Forgot PIN button
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => _showForgotPinDialog(l10n),
                  child: Text(l10n.forgotPin),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.loginButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isDark) {
      formContent = DarkGlassContainer(
        backgroundColor: const Color(0xFF16161A),
        child: formContent,
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.backToRoleSelection,
          onPressed: () {
            ref.read(activeRoleProvider.notifier).state = AppRole.none;
            widget.onBackToRoles();
          },
        ),
        title: Text(l10n.customerLogin),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(l10n.customerLogin, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  l10n.customerLoginSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                formContent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
