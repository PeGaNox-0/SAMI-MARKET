import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/transaction_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../reports/screens/reports_screen.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/dark_glass_container.dart';

/// Dashboard stats stream provider
final dashboardStatsProvider = StreamProvider.autoDispose<Map<String, dynamic>>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Stream.empty();

    final txRepo = ref.watch(transactionRepositoryProvider);
    return txRepo.watchDashboardStats(user.id);
  },
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final connectivityAsync = ref.watch(isConnectedProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 20),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(dashboardStatsProvider),
          ),
          // Sync status indicator
          connectivityAsync.when(
            data: (isConnected) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: FaIcon(
                isConnected
                    ? FontAwesomeIcons.cloudArrowUp
                    : FontAwesomeIcons.cloudBolt,
                color: isConnected
                    ? AppColors.payment
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                size: 20,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          final totalDebt = stats['total_debt'] as double? ?? 0.0;
          final customersWithDebt = stats['customers_with_debt'] as int? ?? 0;
          final paymentsToday = stats['payments_today'] as double? ?? 0.0;
          final debtsToday = stats['debts_today'] as double? ?? 0.0;
          final recentTx =
              stats['recent_transactions'] as List<TransactionModel>? ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100,
              ),
              children: [
                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      title: l10n.totalDebt,
                      value: CurrencyFormatter.formatCompact(
                        totalDebt,
                        locale: locale,
                      ),
                      icon: FontAwesomeIcons.wallet,
                      color: AppColors.debt,
                      bgColor: AppColors.debtLight,
                      onTap: () =>
                          ref.read(navigationIndexProvider.notifier).state = 1,
                    ),
                    _StatCard(
                      title: l10n.customersWithDebt,
                      value: '$customersWithDebt',
                      icon: FontAwesomeIcons.users,
                      color: AppColors.primary,
                      bgColor: AppColors.primary.withValues(alpha: 0.1),
                      onTap: () =>
                          ref.read(navigationIndexProvider.notifier).state = 1,
                    ),
                    _StatCard(
                      title: l10n.paymentsToday,
                      value: CurrencyFormatter.formatCompact(
                        paymentsToday,
                        locale: locale,
                      ),
                      icon: FontAwesomeIcons.handHoldingDollar,
                      color: AppColors.payment,
                      bgColor: AppColors.paymentLight,
                      onTap: () {
                        ref.read(reportModeProvider.notifier).state = 'today';
                        ref.read(reportTxFilterProvider.notifier).state =
                            'payment';
                        ref.read(navigationIndexProvider.notifier).state = 3;
                      },
                    ),
                    _StatCard(
                      title: l10n.debtsToday,
                      value: CurrencyFormatter.formatCompact(
                        debtsToday,
                        locale: locale,
                      ),
                      icon: FontAwesomeIcons.fileInvoiceDollar,
                      color: AppColors.warning,
                      bgColor: AppColors.warningLight,
                      onTap: () {
                        ref.read(reportModeProvider.notifier).state = 'today';
                        ref.read(reportTxFilterProvider.notifier).state =
                            'debt';
                        ref.read(navigationIndexProvider.notifier).state = 2;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent transactions header
                Text(l10n.recentTransactions, style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),

                if (recentTx.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.fileInvoiceDollar,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noTransactions,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...recentTx.map(
                    (tx) => _TransactionTile(
                      transaction: tx,
                      locale: locale,
                      l10n: l10n,
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 48,
                color: AppColors.debt,
              ),
              const SizedBox(height: 12),
              Text(l10n.error, style: AppTextStyles.bodyLarge),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardStatsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final dynamic icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(icon, color: isDark ? Colors.white : color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.moneySmall.copyWith(
              color: isDark ? Colors.white : color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (isDark) {
      return DarkGlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        backgroundColor: const Color(0xFF16161A),
        onTap: onTap,
        child: cardContent,
      );
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: cardContent,
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final String locale;
  final AppLocalizations l10n;

  const _TransactionTile({
    required this.transaction,
    required this.locale,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebt = transaction.isDebt;
    final color = isDebt ? AppColors.debt : AppColors.payment;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget tileContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : (isDebt ? AppColors.debtLight : AppColors.paymentLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                isDebt ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                color: isDark ? Colors.white : color,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.customerName ??
                      (locale == 'ar' ? 'زبون محذوف' : 'Deleted Customer'),
                  style: AppTextStyles.titleSmall,
                ),
                if (transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  DateFormatter.formatRelative(
                    transaction.createdAt,
                    locale: locale,
                  ),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatWithSign(
                  transaction.amount,
                  transaction.type,
                  locale: locale,
                ),
                style: AppTextStyles.moneySmall.copyWith(
                  color: color,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              FaIcon(
                FontAwesomeIcons.angleLeft,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textHint,
              ),
            ],
          ),
        ],
      ),
    );

    if (isDark) {
      return DarkGlassContainer(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.zero,
        borderRadius: 16,
        backgroundColor: const Color(0xFF16161A),
        onTap: () {
          _showTransactionDetails(context, ref);
        },
        child: tileContent,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showTransactionDetails(context, ref);
        },
        child: tileContent,
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, WidgetRef ref) {
    final isDebt = transaction.isDebt;
    final color = isDebt ? AppColors.debt : AppColors.payment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Widget content = Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : (isDebt
                                ? AppColors.debtLight
                                : AppColors.paymentLight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: FaIcon(
                        isDebt
                            ? FontAwesomeIcons.arrowUp
                            : FontAwesomeIcons.arrowDown,
                        color: isDark ? Colors.white : color,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.customerName ??
                              (locale == 'ar'
                                  ? 'زبون محذوف'
                                  : 'Deleted Customer'),
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormatter.formatWithTime(
                            transaction.createdAt,
                            locale: locale,
                          ),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatWithSign(
                      transaction.amount,
                      transaction.type,
                      locale: locale,
                    ),
                    style: AppTextStyles.moneyLarge.copyWith(
                      color: color,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.noteSticky,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'تفاصيل ووصف الأغراض:',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 80,
                  maxHeight: 220,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : Colors.grey.withAlpha(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: transaction.description.isNotEmpty
                      ? SelectableText(
                          transaction.description,
                          style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                        )
                      : Text(
                          '(لا يوجد تفاصيل أو وصف مسجل لهذه العملية)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.5,
                                  )
                                : AppColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 16),
                      label: Text(l10n.cancel),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(
                          context,
                        ).pushNamed('/customers/${transaction.customerId}');
                      },
                      icon: const FaIcon(FontAwesomeIcons.user, size: 16),
                      label: const Text('صفحة الزبون'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (isDark) {
          return DarkGlassContainer(
            borderRadius: 24,
            padding: EdgeInsets.zero,
            backgroundColor: const Color(0xFF16161A),
            child: content,
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: content,
          );
        }
      },
    );
  }
}
