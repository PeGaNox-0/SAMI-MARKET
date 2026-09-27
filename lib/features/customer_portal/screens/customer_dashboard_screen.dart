import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/services/customer_auth_service.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/widgets/dark_glass_container.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  final VoidCallback? onViewAllTransactions;

  const CustomerDashboardScreen({super.key, this.onViewAllTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final session = ref.watch(customerSessionProvider);
    final portalDataAsync = ref.watch(customerPortalDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(session?.marketName ?? 'SAMI MARKET'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(customerPortalDataProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(customerPortalDataProvider),
        child: portalDataAsync.when(
          data: (data) {
            if (data.isEmpty) {
              return Center(child: Text(l10n.error));
            }

            final customerName =
                data['customer_name'] as String? ?? session?.customerName ?? '';
            final balance = (data['balance'] as double?) ?? 0.0;
            final totalDebts = (data['total_debts'] as double?) ?? 0.0;
            final totalPayments = (data['total_payments'] as double?) ?? 0.0;
            final transactions =
                (data['transactions'] as List<TransactionModel>?) ?? [];
            final hasDebt = balance > 0;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Welcome greeting
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.primary.withAlpha(30),
                        child: Text(
                          customerName.isNotEmpty ? customerName[0] : '?',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.welcomeCustomer(customerName),
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (session?.customerCode != null)
                              Text(
                                '#${session!.customerCode}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Remaining Debt Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: hasDebt
                                ? [
                                    AppColors.debt,
                                    AppColors.debt.withAlpha(200),
                                  ]
                                : [
                                    AppColors.payment,
                                    AppColors.payment.withAlpha(200),
                                  ],
                          ),
                    color: isDark
                        ? const Color(0xFF16161A).withValues(alpha: 0.55)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark
                        ? Border.all(
                            width: 1.2,
                            color: hasDebt
                                ? AppColors.debt.withValues(alpha: 0.3)
                                : AppColors.payment.withValues(alpha: 0.3),
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: (hasDebt ? AppColors.debt : AppColors.payment)
                            .withValues(alpha: isDark ? 0.15 : 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        hasDebt ? l10n.remainingDebt : l10n.noRemainingDebt,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.white.withAlpha(220),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        CurrencyFormatter.format(balance, locale: locale),
                        style: AppTextStyles.moneyLarge.copyWith(
                          color: isDark
                              ? (hasDebt ? AppColors.debt : AppColors.payment)
                              : Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasDebt
                            ? 'المبلغ المستحق للدفع'
                            : 'حسابك خالص تماماً ✓',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.6,
                                )
                              : Colors.white.withAlpha(190),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stats row (Total debts & Total payments)
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.totalDebt,
                        value: CurrencyFormatter.format(
                          totalDebts,
                          locale: locale,
                        ),
                        icon: FontAwesomeIcons.arrowUp,
                        color: AppColors.debt,
                        bgColor: isDark
                            ? const Color(0xFF450A0A)
                            : AppColors.debtLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: l10n.totalPayments,
                        value: CurrencyFormatter.format(
                          totalPayments,
                          locale: locale,
                        ),
                        icon: FontAwesomeIcons.arrowDown,
                        color: AppColors.payment,
                        bgColor: isDark
                            ? const Color(0xFF052E16)
                            : AppColors.paymentLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.transactionHistory,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onViewAllTransactions != null &&
                        transactions.length > 3)
                      TextButton(
                        onPressed: onViewAllTransactions,
                        child: Text(l10n.viewAllTransactions),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Recent Transactions List
                if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noTransactions,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...transactions
                      .take(5)
                      .map(
                        (tx) => _CustomerTransactionCard(
                          transaction: tx,
                          locale: locale,
                          l10n: l10n,
                        ),
                      ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.debt,
                ),
                const SizedBox(height: 12),
                Text(l10n.error, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(customerPortalDataProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final dynamic icon;
  final Color color;
  final Color bgColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: isDark ? Colors.white : color,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.moneySmall.copyWith(
              color: isDark ? Colors.white : color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (isDark) {
      return DarkGlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        backgroundColor: const Color(0xFF16161A),
        borderColor: color.withValues(alpha: 0.2),
        child: cardContent,
      );
    }

    return Card(child: cardContent);
  }
}

class _CustomerTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String locale;
  final AppLocalizations l10n;

  const _CustomerTransactionCard({
    required this.transaction,
    required this.locale,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDebt = transaction.isDebt;
    final color = isDebt ? AppColors.debt : AppColors.payment;

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
                  isDebt ? l10n.debt : l10n.payment,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (transaction.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    transaction.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
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
                        : AppColors.textHint,
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
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
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
        onTap: () => _showDetailsSheet(context),
        child: tileContent,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showDetailsSheet(context);
        },
        child: tileContent,
      ),
    );
  }

  void _showDetailsSheet(BuildContext context) {
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
                          isDebt ? 'تفاصيل الدين' : 'تفاصيل الدفعة',
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
                  Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    side: isDark
                        ? const BorderSide(color: AppColors.darkBorder)
                        : null,
                  ),
                  child: Text(
                    l10n.done,
                    style: TextStyle(color: isDark ? Colors.white : null),
                  ),
                ),
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
