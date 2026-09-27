import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/widgets/dark_glass_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onBackToRoles;

  const LoginScreen({super.key, this.onRegisterTap, this.onBackToRoles});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Pull data from cloud after login
      final user = authRepo.currentUser;
      if (user != null) {
        final syncService = ref.read(syncServiceProvider);
        await syncService.pullFromCloud(user.id);
      }
    } catch (e) {
      setState(() {
        _error = 'فشل تسجيل الدخول. يرجى التحقق من البريد وكلمة المرور.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget formContent = Column(
      children: [
        // Form
        Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: Validators.password,
              ),
            ],
          ),
        ),

        // Forgot password
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/forgot-password');
            },
            child: Text(l10n.forgotPassword),
          ),
        ),

        // Error
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withValues(alpha: 0.15)
                  : AppColors.debtLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.debt.withValues(alpha: 0.3)),
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
                    _error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.debt,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Login button
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
                : Text(l10n.login),
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
      appBar: widget.onBackToRoles != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.backToRoleSelection,
                onPressed: widget.onBackToRoles,
              ),
              title: Text(l10n.marketOwner),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Title
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
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.appTitle, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  l10n.login,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                formContent,

                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.dontHaveAccount, style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: widget.onRegisterTap,
                      child: Text(l10n.createAccount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
