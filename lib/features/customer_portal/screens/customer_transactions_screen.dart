import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/services/customer_auth_service.dart';
import '../../../core/services/fcm_service.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/widgets/dark_glass_container.dart';

final customerTxFilterProvider = StateProvider<String>((ref) => 'all');

class CustomerTransactionsScreen extends ConsumerWidget {
  const CustomerTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(customerTxFilterProvider);
    final portalDataAsync = ref.watch(customerPortalDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(customerPortalDataProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.all),
                  selected: filter == 'all',
                  onSelected: (s) {
                    if (s) {
                      ref.read(customerTxFilterProvider.notifier).state = 'all';
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.debt),
                  selected: filter == 'debt',
                  onSelected: (s) {
                    if (s) {
                      ref.read(customerTxFilterProvider.notifier).state =
                          'debt';
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.payment),
                  selected: filter == 'payment',
                  onSelected: (s) {
                    if (s) {
                      ref.read(customerTxFilterProvider.notifier).state =
                          'payment';
                    }
                  },
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(customerPortalDataProvider),
              child: portalDataAsync.when(
                data: (data) {
                  final allTx =
                      (data['transactions'] as List<TransactionModel>?) ?? [];

                  // Handle navigation redirection from notification tap
                  final targetTxId = ref.watch(
                    selectedNotificationTransactionIdProvider,
                  );
                  if (targetTxId != null && allTx.isNotEmpty) {
                    try {
                      final tx = allTx.firstWhere((t) => t.id == targetTxId);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showDetailsSheet(context, tx, l10n, locale);
                        ref
                                .read(
                                  selectedNotificationTransactionIdProvider
                                      .notifier,
                                )
                                .state =
                            null;
                      });
                    } catch (_) {}
                  }

                  final filteredTx = allTx.where((t) {
                    if (filter == 'debt') return t.isDebt;
                    if (filter == 'payment') return t.isPayment;
                    return true;
                  }).toList();

                  if (filteredTx.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTransactions,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredTx.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTx[index];
                      final isDebt = tx.isDebt;
                      final color = isDebt ? AppColors.debt : AppColors.payment;

                      Widget tileContent = Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : (isDebt
                                          ? AppColors.debtLight
                                          : AppColors.paymentLight),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: FaIcon(
                                  isDebt
                                      ? FontAwesomeIcons.arrowUp
                                      : FontAwesomeIcons.arrowDown,
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
                                  if (tx.description.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      tx.description,
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
                                    DateFormatter.formatWithTime(
                                      tx.createdAt,
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
                                    tx.amount,
                                    tx.type,
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
                          onTap: () =>
                              _showDetailsSheet(context, tx, l10n, locale),
                          child: tileContent,
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              _showDetailsSheet(context, tx, l10n, locale),
                          child: tileContent,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(l10n.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsSheet(
    BuildContext context,
    TransactionModel tx,
    AppLocalizations l10n,
    String locale,
  ) {
    final isDebt = tx.isDebt;
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
                            tx.createdAt,
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
                      tx.amount,
                      tx.type,
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
                  child: tx.description.isNotEmpty
                      ? SelectableText(
                          tx.description,
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
