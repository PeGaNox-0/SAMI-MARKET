import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/services/notification_service.dart';
import '../../dekont/services/dekont_share_service.dart';
import 'customers_list_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/dark_glass_container.dart';

/// Customer detail stream provider
final customerDetailProvider = StreamProvider.autoDispose
    .family<CustomerModel?, String>((ref, customerId) {
      ref.keepAlive();
      final repo = ref.watch(customerRepositoryProvider);
      return repo.watchCustomerById(customerId);
    });

/// Page size for customer transactions
const int _kTransactionsPageSize = 25;

/// Customer transactions pagination limit provider
final customerTxLimitProvider = StateProvider.autoDispose
    .family<int, String>((ref, customerId) => _kTransactionsPageSize);

/// Total transactions count provider for customer
final customerTransactionsCountProvider = StreamProvider.autoDispose
    .family<int, String>((ref, customerId) {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.watchCustomerTransactionsCount(customerId);
    });

/// Customer transactions stream provider (paginated, progressive loading)
final customerTransactionsProvider = StreamProvider.autoDispose
    .family<List<TransactionModel>, String>((ref, customerId) {
      ref.keepAlive();
      final limit = ref.watch(customerTxLimitProvider(customerId));
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.watchTransactionsByCustomer(customerId, limit: limit);
    });

/// Customer account status provider
final customerAccountProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, customerId) async {
      final repo = ref.watch(customerRepositoryProvider);
      return repo.getCustomerAccount(customerId);
    });

class CustomerDetailsScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  static void refresh(WidgetRef ref, String customerId) {
    ref.read(customerRepositoryProvider).invalidateCustomerAccountCache(customerId);
    ref.read(customerTxLimitProvider(customerId).notifier).state = _kTransactionsPageSize;
    ref.invalidate(customerDetailProvider(customerId));
    ref.invalidate(customerTransactionsProvider(customerId));
    ref.invalidate(customerTransactionsCountProvider(customerId));
    ref.invalidate(customerAccountProvider(customerId));
    ref.invalidate(customerListProvider);
    ref.invalidate(dashboardStatsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: _CustomerAppBarTitle(customerId: customerId),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 20),
            tooltip: 'تحديث',
            onPressed: () => refresh(ref, customerId),
          ),
          _CustomerPopupMenu(customerId: customerId, locale: locale),
        ],
      ),
      body: Column(
        children: [
          // Balance header (isolated rebuild)
          _CustomerBalanceHeader(customerId: customerId, locale: locale),

          // Action buttons (Add Debt & Record Payment)
          _CustomerActionButtons(customerId: customerId),

          // Customer App Access Card (isolated rebuild)
          _CustomerAppAccessCard(customerId: customerId),

          const SizedBox(height: 12),

          // Transaction history header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l10n.transactionHistory,
                style: AppTextStyles.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Transactions list (isolated rebuild)
          Expanded(
            child: _CustomerTransactionsSection(
              customerId: customerId,
              locale: locale,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> setupNewAppAccess(
    BuildContext context,
    WidgetRef ref,
    CustomerModel customer,
    AppLocalizations l10n,
  ) async {
    final code = customer.customerCode.isNotEmpty
        ? customer.customerCode
        : 'SM-${10000 + Random().nextInt(90000)}';
    final pin = '${100000 + Random().nextInt(900000)}';

    final res = await ref
        .read(customerRepositoryProvider)
        .createCustomerAccount(
          customerId: customer.id,
          customerCode: code,
          pin: pin,
        );

    refresh(ref, customer.id);

    if (!context.mounted) return;

    if (res['success'] == true) {
      showCredentialsRevealDialog(context, customer.name, code, pin, l10n);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.debt,
          content: Text(
            'حدث خطأ: ${res['error'] ?? 'تعذر تفعيل الوصول في السيرفر'}',
          ),
        ),
      );
    }
  }

  static Future<void> resetCustomerPin(
    BuildContext context,
    WidgetRef ref,
    CustomerModel customer,
    String code,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetPin),
        content: Text(l10n.resetPinConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newPin = '${100000 + Random().nextInt(900000)}';
      final res = await ref
          .read(customerRepositoryProvider)
          .resetCustomerPin(customerId: customer.id, newPin: newPin);

      refresh(ref, customer.id);

      if (!context.mounted) return;

      if (res['success'] == true) {
        showCredentialsRevealDialog(
          context,
          customer.name,
          code,
          newPin,
          l10n,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.debt,
            content: Text(
              'حدث خطأ: ${res['error'] ?? 'تعذر إعادة تعيين الشيفرة'}',
            ),
          ),
        );
      }
    }
  }

  static void showCredentialsRevealDialog(
    BuildContext context,
    String customerName,
    String customerCode,
    String pin,
    AppLocalizations l10n,
  ) {
    final shareText =
        '''
🏪 SAMI MARKET — بيانات دخول حساب الزبون
👤 الاسم: $customerName
🏷️ رمز الزبون: $customerCode
🔑 الشيفرة (PIN): $pin
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.key, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.customerAccountCreated,
                style: AppTextStyles.titleMedium,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.saveCredentialsWarning,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.customerCode, style: AppTextStyles.labelSmall),
                      Text(
                        customerCode,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.copy,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    tooltip: l10n.copyCode,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: customerCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copiedToClipboard)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.payment.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.payment.withAlpha(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.customerPin, style: AppTextStyles.labelSmall),
                      Text(
                        pin,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.payment,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.copy,
                      color: AppColors.payment,
                      size: 20,
                    ),
                    tooltip: l10n.copyPin,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: pin));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copiedToClipboard)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => Share.share(shareText),
            icon: const FaIcon(FontAwesomeIcons.shareNodes, size: 18),
            label: const Text('مشاركة'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  static void showTransactionDetails(
    BuildContext context,
    WidgetRef ref,
    TransactionModel tx,
    AppLocalizations l10n,
    String locale, {
    CustomerModel? customer,
    List<TransactionModel>? allTransactions,
    required String customerId,
  }) {
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
                  FaIcon(
                    FontAwesomeIcons.fileLines,
                    size: 18,
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
              const SizedBox(height: 18),

              // [ 📄 مشاركة Dekont ] Button
              if (customer != null && allTransactions != null) ...[
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      DekontShareService.showReceiptPrinter(
                        context: context,
                        customer: customer,
                        transaction: tx,
                        allTransactions: allTransactions,
                        languageCode: locale,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isDark
                            ? const BorderSide(
                                color: AppColors.darkBorder,
                                width: 1.2,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.filePdf, size: 18),
                    label: Text(
                      l10n.shareDekont,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final confirmed = await showDeleteDialog(
                          context,
                          l10n,
                        );
                        if (confirmed == true) {
                          await ref
                              .read(transactionRepositoryProvider)
                              .deleteTransaction(tx.id);
                          refresh(ref, customerId);
                        }
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.trashCan,
                        color: AppColors.debt,
                        size: 18,
                      ),
                      label: Text(
                        l10n.delete,
                        style: const TextStyle(color: AppColors.debt),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.debt),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final result = await Navigator.of(
                          context,
                        ).pushNamed('/transactions/${tx.id}/edit');
                        if (result == true) {
                          refresh(ref, customerId);
                        }
                      },
                      icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 18),
                      label: Text(l10n.edit),
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

  static Future<bool?> showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.debt),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  static Future<void> sendCustomerNotification(
    BuildContext context,
    WidgetRef ref,
    CustomerModel customer,
    AppLocalizations l10n,
  ) async {
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'ar';
    final messageController = TextEditingController(
      text: (customer.balance != null && customer.balance! > 0)
          ? 'نرجو منكم التكرم بتسديد الرصيد المتبقي البالغ ${CurrencyFormatter.format(customer.balance!, locale: locale)}.'
          : '',
    );
    bool isSending = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      await showDialog(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.bullhorn,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${l10n.sendNotification} (${customer.name})'),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أدخل نص الرسالة التي ستصل للزبون كتنبيه في التطبيق:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.notificationMessageHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton.icon(
                onPressed: isSending
                    ? null
                    : () async {
                        try {
                          final msg = messageController.text.trim();
                          if (msg.isEmpty) return;

                          setDialogState(() => isSending = true);
                          HapticFeedback.lightImpact();

                          final service = ref.read(notificationServiceProvider);
                          final res = await service.sendNotification(
                            message: msg,
                            customerIds: [customer.id],
                          );

                          if (!dialogCtx.mounted) return;
                          Navigator.of(dialogCtx).pop();

                          if (!context.mounted) return;
                          if (res['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.notificationSent),
                                backgroundColor: AppColors.payment,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ: ${res['error']}'),
                                backgroundColor: AppColors.debt,
                              ),
                            );
                          }
                        } catch (e) {
                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ غير متوقع: $e'),
                                backgroundColor: AppColors.debt,
                              ),
                            );
                          }
                        }
                      },
                icon: isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const FaIcon(FontAwesomeIcons.paperPlane, size: 16),
                label: Text(l10n.sendNotificationBtn),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل فتح نافذة الإشعارات: $e'),
            backgroundColor: AppColors.debt,
          ),
        );
      }
    } finally {
      messageController.dispose();
    }
  }

  static Future<bool?> showArchiveDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.archiveConfirmTitle),
        content: Text(l10n.archiveConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.debt),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SUB-WIDGETS (ISOLATED REBUILDS)
// ─────────────────────────────────────────────

/// 1. AppBar Title (only rebuilds when name changes)
class _CustomerAppBarTitle extends ConsumerWidget {
  final String customerId;
  const _CustomerAppBarTitle({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final l10n = AppLocalizations.of(context)!;
    return customerAsync.when(
      data: (c) => Text(c?.name ?? ''),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => Text(l10n.error),
    );
  }
}

/// 2. Popup Menu
class _CustomerPopupMenu extends ConsumerWidget {
  final String customerId;
  final String locale;

  const _CustomerPopupMenu({
    required this.customerId,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'share_statement') {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.generatingPdf),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          final customer = ref.read(customerDetailProvider(customerId)).asData?.value ??
              await ref.read(customerRepositoryProvider).getCustomerById(customerId);
          final transactions = await ref
              .read(transactionRepositoryProvider)
              .getTransactionsByCustomer(customerId);
          if (customer != null && context.mounted) {
            await DekontShareService.shareAccountStatement(
              context: context,
              customer: customer,
              transactions: transactions,
              languageCode: locale,
            );
          }
        } else if (value == 'share_last_tx') {
          final customer = ref.read(customerDetailProvider(customerId)).asData?.value;
          final transactions = await ref
              .read(transactionRepositoryProvider)
              .getTransactionsByCustomer(customerId);
          if (!context.mounted) return;
          if (transactions.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.noTransactionsToShare),
                backgroundColor: AppColors.warning,
              ),
            );
          } else if (customer != null) {
            final latestTx = transactions.first;
            await DekontShareService.showReceiptPrinter(
              context: context,
              customer: customer,
              transaction: latestTx,
              allTransactions: transactions,
              languageCode: locale,
            );
          }
        } else if (value == 'edit') {
          final result = await Navigator.of(context).pushNamed('/customers/$customerId/edit');
          if (result == true) {
            CustomerDetailsScreen.refresh(ref, customerId);
          }
        } else if (value == 'archive') {
          final confirmed = await CustomerDetailsScreen.showArchiveDialog(context, l10n);
          if (confirmed == true) {
            await ref.read(customerRepositoryProvider).archiveCustomer(customerId);
            ref.invalidate(customerListProvider);
            ref.invalidate(dashboardStatsProvider);
            if (context.mounted) Navigator.of(context).pop();
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'share_statement',
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.filePdf,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(l10n.shareAccountStatement),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share_last_tx',
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.receipt,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(l10n.shareLastTransaction),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.penToSquare, size: 18),
              const SizedBox(width: 10),
              Text(l10n.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.trashCan,
                size: 18,
                color: AppColors.debt,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.delete,
                style: const TextStyle(color: AppColors.debt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 3. Balance Header (only rebuilds when customer balance updates)
class _CustomerBalanceHeader extends ConsumerWidget {
  final String customerId;
  final String locale;

  const _CustomerBalanceHeader({
    required this.customerId,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return customerAsync.when(
      data: (customer) {
        if (customer == null) return const SizedBox.shrink();
        final balance = customer.balance ?? 0;
        final hasDebt = balance > 0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDark
                ? null
                : LinearGradient(
                    colors: hasDebt
                        ? [AppColors.debt, AppColors.debt.withAlpha(180)]
                        : [
                            AppColors.payment,
                            AppColors.payment.withAlpha(180),
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
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color:
                          (hasDebt ? AppColors.debt : AppColors.payment)
                              .withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                l10n.remainingDebt,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.white.withAlpha(200),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(balance, locale: locale),
                style: AppTextStyles.moneyLarge.copyWith(
                  color: isDark
                      ? (hasDebt ? AppColors.debt : AppColors.payment)
                      : Colors.white,
                ),
              ),
              if (customer.customerCode.isNotEmpty ||
                  customer.phone.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (customer.customerCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                )
                              : null,
                        ),
                        child: Text(
                          '#${customer.customerCode}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (customer.phone.isNotEmpty)
                      Text(
                        customer.phone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : Colors.white.withAlpha(200),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        height: 140,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF16161A).withValues(alpha: 0.55)
              : Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

/// 4. Action Buttons (Static widget - zero rebuilds on data changes)
class _CustomerActionButtons extends StatelessWidget {
  final String customerId;

  const _CustomerActionButtons({required this.customerId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer(
      builder: (context, ref, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(
                    context,
                  ).pushNamed('/customers/$customerId/debt');
                  if (result == true) {
                    CustomerDetailsScreen.refresh(ref, customerId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.debt,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  l10n.addDebt,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(
                    context,
                  ).pushNamed('/customers/$customerId/pay');
                  if (result == true) {
                    CustomerDetailsScreen.refresh(ref, customerId);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.payment,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.moneyBillWave,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  l10n.addPayment,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. App Access Card (only rebuilds when account status changes)
class _CustomerAppAccessCard extends ConsumerWidget {
  final String customerId;

  const _CustomerAppAccessCard({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerDetailProvider(customerId)).asData?.value;
    if (customer == null) return const SizedBox.shrink();

    final accountAsync = ref.watch(customerAccountProvider(customerId));
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return accountAsync.when(
      data: (account) {
        if (account == null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: OutlinedButton.icon(
              onPressed: () => CustomerDetailsScreen.setupNewAppAccess(
                context,
                ref,
                customer,
                l10n,
              ),
              icon: const FaIcon(FontAwesomeIcons.mobileScreen, size: 18),
              label: Text(l10n.enableCustomerAccess),
            ),
          );
        }

        final isEnabled = account['is_enabled'] as bool? ?? true;
        final code = account['customer_code'] as String? ?? customer.customerCode;

        if (isDark) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DarkGlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              backgroundColor: isEnabled
                  ? const Color(0xFF16161A)
                  : Colors.black,
              borderColor: isEnabled
                  ? AppColors.primaryLight.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.mobileScreen,
                    color: isEnabled
                        ? AppColors.primaryLight
                        : AppColors.darkTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.appAccess,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? AppColors.payment.withValues(alpha: 0.15)
                                    : AppColors.debt.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isEnabled
                                      ? AppColors.payment.withValues(alpha: 0.3)
                                      : AppColors.debt.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                isEnabled
                                    ? l10n.accessEnabled
                                    : l10n.accessDisabled,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isEnabled
                                      ? AppColors.payment
                                      : AppColors.debt,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'رمز الدخول: $code',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.paperPlane,
                      size: 18,
                      color: AppColors.primaryLight,
                    ),
                    tooltip: l10n.sendNotification,
                    onPressed: () => CustomerDetailsScreen.sendCustomerNotification(
                      context,
                      ref,
                      customer,
                      l10n,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.lock,
                      size: 18,
                      color: Colors.white,
                    ),
                    tooltip: l10n.resetPin,
                    onPressed: () => CustomerDetailsScreen.resetCustomerPin(
                      context,
                      ref,
                      customer,
                      code,
                      l10n,
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(
                      isEnabled
                          ? FontAwesomeIcons.ban
                          : FontAwesomeIcons.circleCheck,
                      color: isEnabled
                          ? AppColors.debt
                          : AppColors.payment,
                      size: 18,
                    ),
                    tooltip: isEnabled
                        ? l10n.disableAccess
                        : l10n.enableAccess,
                    onPressed: () async {
                      await ref
                          .read(customerRepositoryProvider)
                          .setCustomerAccess(
                            customerId: customer.id,
                            enabled: !isEnabled,
                          );
                      CustomerDetailsScreen.refresh(ref, customerId);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Card(
            color: isEnabled
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.withAlpha(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isEnabled
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Colors.grey.withAlpha(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.mobileScreen,
                    color: isEnabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.appAccess,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? AppColors.payment.withAlpha(20)
                                    : AppColors.debt.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isEnabled
                                    ? l10n.accessEnabled
                                    : l10n.accessDisabled,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isEnabled
                                      ? AppColors.payment
                                      : AppColors.debt,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'رمز الدخول: $code',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.paperPlane,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    tooltip: l10n.sendNotification,
                    onPressed: () => CustomerDetailsScreen.sendCustomerNotification(
                      context,
                      ref,
                      customer,
                      l10n,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.lock, size: 18),
                    tooltip: l10n.resetPin,
                    onPressed: () => CustomerDetailsScreen.resetCustomerPin(
                      context,
                      ref,
                      customer,
                      code,
                      l10n,
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(
                      isEnabled
                          ? FontAwesomeIcons.ban
                          : FontAwesomeIcons.circleCheck,
                      color: isEnabled
                          ? AppColors.debt
                          : AppColors.payment,
                      size: 18,
                    ),
                    tooltip: isEnabled
                        ? l10n.disableAccess
                        : l10n.enableAccess,
                    onPressed: () async {
                      await ref
                          .read(customerRepositoryProvider)
                          .setCustomerAccess(
                            customerId: customer.id,
                            enabled: !isEnabled,
                          );
                      CustomerDetailsScreen.refresh(ref, customerId);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

/// 6. Transactions Section (only rebuilds when transactions update)
class _CustomerTransactionsSection extends ConsumerWidget {
  final String customerId;
  final String locale;

  const _CustomerTransactionsSection({
    required this.customerId,
    required this.locale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(customerTransactionsProvider(customerId));
    final totalCount = ref.watch(customerTransactionsCountProvider(customerId)).asData?.value;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async => CustomerDetailsScreen.refresh(ref, customerId),
      child: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Center(
                  child: Text(
                    l10n.noTransactions,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }

          final hasMore = totalCount != null && totalCount > transactions.length;

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 && hasMore) {
                final currentLimit = ref.read(customerTxLimitProvider(customerId));
                if (currentLimit <= transactions.length) {
                  ref.read(customerTxLimitProvider(customerId).notifier).state = currentLimit + _kTransactionsPageSize;
                }
              }
              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactions.length) {
                  final remaining = (totalCount ?? transactions.length) - transactions.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                        label: Text(
                          'تحميل المزيد ($remaining متبقية)',
                          style: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () {
                          ref.read(customerTxLimitProvider(customerId).notifier).state += _kTransactionsPageSize;
                        },
                      ),
                    ),
                  );
                }

                final tx = transactions[index];
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
                              style: AppTextStyles.titleSmall,
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
                              DateFormatter.formatRelative(
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

                void openDetails() {
                  final customer = ref.read(customerDetailProvider(customerId)).asData?.value;
                  CustomerDetailsScreen.showTransactionDetails(
                    context,
                    ref,
                    tx,
                    l10n,
                    locale,
                    customer: customer,
                    allTransactions: transactions,
                    customerId: customerId,
                  );
                }

                if (isDark) {
                  return DarkGlassContainer(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.zero,
                    borderRadius: 16,
                    backgroundColor: const Color(0xFF16161A),
                    onTap: openDetails,
                    child: tileContent,
                  );
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: openDetails,
                    child: tileContent,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error)),
      ),
    );
  }
}
