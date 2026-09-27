import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/customer_auth_service.dart';
import '../../../data/models/customer_account_model.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/widgets/dark_glass_container.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogout;

  const CustomerProfileScreen({super.key, required this.onLogout});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  Future<void> _showChangePinDialog(AppLocalizations l10n) async {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.changePin),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.debt,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: currentPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: l10n.currentPin,
                      counterText: '',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: l10n.newPin,
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.length < 4) {
                        return 'الشيفرة يجب أن تكون 4 أرقام على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: l10n.confirmNewPin,
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v != newPinController.text) {
                        return 'الشيفرة غير متطابقة';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        isSubmitting = true;
                        errorMessage = null;
                      });

                      final session = ref.read(customerSessionProvider);
                      if (session == null) return;

                      final service = ref.read(customerAuthServiceProvider);
                      final res = await service.changePin(
                        customerId: session.customerId,
                        currentPin: currentPinController.text.trim(),
                        newPin: newPinController.text.trim(),
                      );

                      if (!context.mounted) return;

                      if (res['success'] == true) {
                        // Update persisted session with new PIN
                        final updatedSession = CustomerSession(
                          customerId: session.customerId,
                          customerCode: session.customerCode,
                          customerName: session.customerName,
                          phone: session.phone,
                          marketName: session.marketName,
                          pin: newPinController.text.trim(),
                        );
                        await ref
                            .read(customerSessionProvider.notifier)
                            .setSession(updatedSession);
                        if (!context.mounted) return;
                        Navigator.of(dialogCtx).pop();
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text(l10n.pinChangedSuccess)),
                          );
                        }
                      } else {
                        setDialogState(() {
                          isSubmitting = false;
                          final err = res['error'];
                          if (err == 'INVALID_CURRENT_PIN') {
                            errorMessage = 'الشيفرة الحالية غير صحيحة.';
                          } else {
                            errorMessage =
                                'تعذر تغيير الشيفرة. يرجى المحاولة لاحقاً.';
                          }
                        });
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    currentPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
  }

  void _showLogoutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: const Text('هل أنت متأكد من تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(customerSessionProvider.notifier).clearSession();
              ref.read(activeRoleProvider.notifier).state = AppRole.none;
              widget.onLogout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.debt),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final session = ref.watch(customerSessionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final customerName = session?.customerName ?? 'الزبون';
    final customerCode = session?.customerCode ?? '';
    final marketName = session?.marketName ?? 'SAMI MARKET';

    Widget profileCardContent = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primary.withAlpha(25),
            child: Text(
              customerName.isNotEmpty ? customerName[0] : '?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customerName,
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (customerCode.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.15))
                    : null,
              ),
              child: Text(
                '#$customerCode',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            marketName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myAccount)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Profile Card
          isDark
              ? DarkGlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 16,
                  backgroundColor: const Color(0xFF16161A),
                  child: profileCardContent,
                )
              : Card(child: profileCardContent),

          const SizedBox(height: 20),

          // Security Settings
          Text(
            'الأمان',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          isDark
              ? DarkGlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 12,
                  backgroundColor: const Color(0xFF16161A),
                  child: ListTile(
                    leading: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.changePin,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'تحديث شيفرة الدخول الخاصة بك',
                      style: TextStyle(color: AppColors.darkTextSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.darkTextSecondary,
                    ),
                    onTap: () => _showChangePinDialog(l10n),
                  ),
                )
              : Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(l10n.changePin),
                    subtitle: const Text('تحديث شيفرة الدخول الخاصة بك'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
                    onTap: () => _showChangePinDialog(l10n),
                  ),
                ),

          const SizedBox(height: 20),

          // Preferences
          Text(
            l10n.settings,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          isDark
              ? DarkGlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 12,
                  backgroundColor: const Color(0xFF16161A),
                  child: Column(
                    children: [
                      // Language
                      ListTile(
                        leading: const Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                        ),
                        title: Text(
                          l10n.language,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: DropdownButton<String>(
                          value: locale.languageCode,
                          underline: const SizedBox.shrink(),
                          dropdownColor: const Color(0xFF16161A),
                          items: const [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(
                                'العربية',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(
                                'English',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(localeProvider.notifier).state = Locale(
                                val,
                              );
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.darkBorder),
                      // Theme Mode
                      ListTile(
                        leading: const Icon(
                          Icons.dark_mode_outlined,
                          color: Colors.white,
                        ),
                        title: Text(
                          l10n.theme,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: DropdownButton<ThemeMode>(
                          value: themeMode,
                          underline: const SizedBox.shrink(),
                          dropdownColor: const Color(0xFF16161A),
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(
                                l10n.systemMode,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(
                                l10n.lightMode,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(
                                l10n.darkMode,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(themeModeProvider.notifier).state = val;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Card(
                  child: Column(
                    children: [
                      // Language
                      ListTile(
                        leading: const Icon(Icons.language_rounded),
                        title: Text(l10n.language),
                        trailing: DropdownButton<String>(
                          value: locale.languageCode,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية'),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(localeProvider.notifier).state = Locale(
                                val,
                              );
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      // Theme Mode
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: Text(l10n.theme),
                        trailing: DropdownButton<ThemeMode>(
                          value: themeMode,
                          underline: const SizedBox.shrink(),
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text(l10n.systemMode),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text(l10n.lightMode),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text(l10n.darkMode),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(themeModeProvider.notifier).state = val;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.debt,
                side: const BorderSide(color: AppColors.debt),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.logout),
            ),
          ),
        ],
      ),
    );
  }
}
