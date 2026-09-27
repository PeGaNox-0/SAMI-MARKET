import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/customer_auth_service.dart';
import '../../../core/widgets/dark_glass_container.dart';
import '../../settings/screens/settings_screen.dart';

class RoleSelectionScreen extends ConsumerWidget {
  final VoidCallback onSelectAdmin;
  final VoidCallback onSelectCustomer;

  const RoleSelectionScreen({
    super.key,
    required this.onSelectAdmin,
    required this.onSelectCustomer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Bar with Language & Theme toggles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final newLocale = locale.languageCode == 'ar'
                          ? const Locale('en')
                          : const Locale('ar');
                      ref.read(localeProvider.notifier).state = newLocale;
                    },
                    icon: const Icon(Icons.language, size: 18),
                    label: Text(
                      locale.languageCode == 'ar' ? 'English' : 'العربية',
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      final newMode = themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                      ref.read(themeModeProvider.notifier).state = newMode;
                    },
                  ),
                ],
              ),

              const Spacer(),

              // SAMI MARKET Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SAMI MARKET',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseAccountType,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Title "من أنت؟"
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.whoAreYou,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Role Card 1: 👤 Customer
              _RoleCard(
                icon: Icons.person_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                title: l10n.customer,
                subtitle: l10n.customerRoleDesc,
                onTap: () {
                  ref.read(activeRoleProvider.notifier).state =
                      AppRole.customer;
                  onSelectCustomer();
                },
              ),

              const SizedBox(height: 16),

              // Role Card 2: 🏪 Market Owner (Admin)
              _RoleCard(
                icon: Icons.store_rounded,
                iconColor: AppColors.debt,
                iconBgColor: AppColors.debt.withValues(alpha: 0.1),
                title: l10n.marketOwner,
                subtitle: l10n.marketOwnerDesc,
                onTap: () {
                  ref.read(activeRoleProvider.notifier).state = AppRole.admin;
                  onSelectAdmin();
                },
              ),

              const Spacer(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return DarkGlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        backgroundColor: const Color(0xFF16161A),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.darkTextSecondary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
