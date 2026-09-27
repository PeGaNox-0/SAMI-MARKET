import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/daily_report_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dekont/services/dekont_share_service.dart';
import '../../../core/widgets/dark_glass_container.dart';

/// Report mode: 'today', 'yesterday', 'day', 'week', 'month', 'custom'
final reportModeProvider = StateProvider<String>((ref) => 'today');

/// Selected specific day
final selectedReportDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Custom date range
final reportCustomRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Filter for transactions list: 'all', 'debt', 'payment'
final reportTxFilterProvider = StateProvider<String>((ref) => 'all');

/// Stream provider for comprehensive daily & periodic report data
final dailyReportProvider = StreamProvider.autoDispose<DailyReportModel>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final mode = ref.watch(reportModeProvider);
  final selectedDay = ref.watch(selectedReportDayProvider);
  final customRange = ref.watch(reportCustomRangeProvider);
  final repo = ref.watch(transactionRepositoryProvider);

  final now = DateTime.now();
  DateTime startDate;
  DateTime endDate;

  switch (mode) {
    case 'today':
      startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case 'yesterday':
      final yest = now.subtract(const Duration(days: 1));
      startDate = DateTime(yest.year, yest.month, yest.day, 0, 0, 0);
      endDate = DateTime(yest.year, yest.month, yest.day, 23, 59, 59);
      break;
    case 'day':
      startDate = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        0,
        0,
        0,
      );
      endDate = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        23,
        59,
        59,
      );
      break;
    case 'week':
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
        0,
        0,
        0,
      );
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case 'month':
      startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case 'custom':
      if (customRange != null) {
        startDate = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
          0,
          0,
          0,
        );
        endDate = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
          23,
          59,
          59,
        );
      } else {
        startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      }
      break;
    default:
      startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  return repo.watchDailyReport(user.id, startDate: startDate, endDate: endDate);
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = ref.watch(reportModeProvider);
    final selectedDay = ref.watch(selectedReportDayProvider);
    final reportAsync = ref.watch(dailyReportProvider);
    final txFilter = ref.watch(reportTxFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyStatistics),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 20),
            tooltip: 'تحديث',
            onPressed: () => ref.invalidate(dailyReportProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyReportProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Period Mode Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _ModeChip(
                        label: l10n.today,
                        modeValue: 'today',
                        icon: FontAwesomeIcons.calendarDay,
                        currentMode: mode,
                        onSelect: () {
                          ref.read(reportModeProvider.notifier).state = 'today';
                          final now = DateTime.now();
                          ref.read(selectedReportDayProvider.notifier).state =
                              DateTime(now.year, now.month, now.day);
                        },
                      ),
                      const SizedBox(width: 8),
                      _ModeChip(
                        label: l10n.yesterday,
                        modeValue: 'yesterday',
                        icon: FontAwesomeIcons.clockRotateLeft,
                        currentMode: mode,
                        onSelect: () {
                          ref.read(reportModeProvider.notifier).state =
                              'yesterday';
                          final yest = DateTime.now().subtract(
                            const Duration(days: 1),
                          );
                          ref.read(selectedReportDayProvider.notifier).state =
                              DateTime(yest.year, yest.month, yest.day);
                        },
                      ),
                      const SizedBox(width: 8),
                      _ModeChip(
                        label: l10n.pickDay,
                        modeValue: 'day',
                        icon: FontAwesomeIcons.calendarCheck,
                        currentMode: mode,
                        onSelect: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDay,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            locale: Locale(locale),
                          );
                          if (picked != null) {
                            ref.read(selectedReportDayProvider.notifier).state =
                                picked;
                            ref.read(reportModeProvider.notifier).state = 'day';
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _ModeChip(
                        label: l10n.thisWeek,
                        modeValue: 'week',
                        icon: FontAwesomeIcons.calendarWeek,
                        currentMode: mode,
                        onSelect: () {
                          ref.read(reportModeProvider.notifier).state = 'week';
                        },
                      ),
                      const SizedBox(width: 8),
                      _ModeChip(
                        label: l10n.thisMonth,
                        modeValue: 'month',
                        icon: FontAwesomeIcons.calendarDays,
                        currentMode: mode,
                        onSelect: () {
                          ref.read(reportModeProvider.notifier).state = 'month';
                        },
                      ),
                      const SizedBox(width: 8),
                      _ModeChip(
                        label: l10n.customRange,
                        modeValue: 'custom',
                        icon: FontAwesomeIcons.calendar,
                        currentMode: mode,
                        onSelect: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            locale: Locale(locale),
                          );
                          if (range != null) {
                            ref.read(reportCustomRangeProvider.notifier).state =
                                range;
                            ref.read(reportModeProvider.notifier).state =
                                'custom';
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Interactive Date Navigation Bar (for Single Day or Range)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: _buildDateNavigationBar(
                  context,
                  ref,
                  mode,
                  selectedDay,
                  locale,
                  l10n,
                  isDark,
                ),
              ),
            ),

            // 3. Stats Data Section
            reportAsync.when(
              data: (report) {
                // Filter transactions
                final filteredTx = report.transactions.where((t) {
                  if (txFilter == 'debt') return t.isDebt;
                  if (txFilter == 'payment') return t.isPayment;
                  return true;
                }).toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 4 Financial Summary Cards in Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            children: [
                              // Debts card
                              _MetricCard(
                                title: l10n.totalDebt,
                                value: CurrencyFormatter.format(
                                  report.totalDebt,
                                  locale: locale,
                                ),
                                subtitle:
                                    '${report.debtsCount} ${l10n.operations}',
                                icon: FontAwesomeIcons.arrowUp,
                                color: AppColors.debt,
                                bgColor: isDark
                                    ? const Color(0xFF450A0A)
                                    : AppColors.debtLight,
                              ),
                              // Payments card
                              _MetricCard(
                                title: l10n.totalPayments,
                                value: CurrencyFormatter.format(
                                  report.totalPayments,
                                  locale: locale,
                                ),
                                subtitle:
                                    '${report.paymentsCount} ${l10n.operations}',
                                icon: FontAwesomeIcons.arrowDown,
                                color: AppColors.payment,
                                bgColor: isDark
                                    ? const Color(0xFF052E16)
                                    : AppColors.paymentLight,
                              ),
                              // Net movement card
                              _MetricCard(
                                title: l10n.netMovement,
                                value:
                                    '${report.netBalance >= 0 ? "+" : ""}${CurrencyFormatter.format(report.netBalance, locale: locale)}',
                                subtitle: report.netBalance >= 0
                                    ? (locale == 'ar'
                                          ? 'زيادة في الديون'
                                          : 'Debt increase')
                                    : (locale == 'ar'
                                          ? 'انخفاض في الديون'
                                          : 'Debt decrease'),
                                icon: FontAwesomeIcons.arrowRightArrowLeft,
                                color: report.netBalance > 0
                                    ? AppColors.debt
                                    : (report.netBalance < 0
                                          ? AppColors.payment
                                          : AppColors.primary),
                                bgColor: report.netBalance > 0
                                    ? (isDark
                                          ? const Color(0xFF450A0A)
                                          : AppColors.debtLight)
                                    : (report.netBalance < 0
                                          ? (isDark
                                                ? const Color(0xFF052E16)
                                                : AppColors.paymentLight)
                                          : (isDark
                                                ? const Color(0xFF1E3A8A)
                                                : AppColors.primary.withAlpha(
                                                    20,
                                                  ))),
                              ),
                              // Active customers card
                              _MetricCard(
                                title: l10n.activeCustomersCount,
                                value: '${report.uniqueCustomersCount}',
                                subtitle:
                                    '${report.totalOperations} ${l10n.operations}',
                                icon: FontAwesomeIcons.users,
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : AppColors.primary,
                                bgColor: isDark
                                    ? const Color(0xFF1E3A8A)
                                    : AppColors.primary.withAlpha(25),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Transactions Ledger Header + Filter Tabs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : AppColors.primary.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.fileInvoiceDollar,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.transactionHistory,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : AppColors.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${filteredTx.length}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Filter Pills
                              Row(
                                children: [
                                  _FilterChip(
                                    label: l10n.all,
                                    selected: txFilter == 'all',
                                    onTap: () =>
                                        ref
                                                .read(
                                                  reportTxFilterProvider
                                                      .notifier,
                                                )
                                                .state =
                                            'all',
                                  ),
                                  const SizedBox(width: 4),
                                  _FilterChip(
                                    label: l10n.debt,
                                    selected: txFilter == 'debt',
                                    color: AppColors.debt,
                                    onTap: () =>
                                        ref
                                                .read(
                                                  reportTxFilterProvider
                                                      .notifier,
                                                )
                                                .state =
                                            'debt',
                                  ),
                                  const SizedBox(width: 4),
                                  _FilterChip(
                                    label: l10n.payment,
                                    selected: txFilter == 'payment',
                                    color: AppColors.payment,
                                    onTap: () =>
                                        ref
                                                .read(
                                                  reportTxFilterProvider
                                                      .notifier,
                                                )
                                                .state =
                                            'payment',
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Transactions List or Empty State
                          if (filteredTx.isEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(
                                        0xFF16161A,
                                      ).withValues(alpha: 0.55)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border.withAlpha(80),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : AppColors.primary.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.calendarXmark,
                                      size: 32,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    l10n.noTransactionsForDate,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (mode != 'today')
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        ref
                                                .read(
                                                  reportModeProvider.notifier,
                                                )
                                                .state =
                                            'today';
                                        final now = DateTime.now();
                                        ref
                                            .read(
                                              selectedReportDayProvider
                                                  .notifier,
                                            )
                                            .state = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                        );
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.calendarDay,
                                        size: 18,
                                      ),
                                      label: Text(l10n.today),
                                    ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredTx.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final tx = filteredTx[index];
                                return _ReportTransactionCard(
                                  transaction: tx,
                                  locale: locale,
                                  l10n: l10n,
                                  onTap: () => _openTransactionDetails(
                                    context,
                                    ref,
                                    tx,
                                    l10n,
                                    locale,
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ]),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
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
                        onPressed: () => ref.invalidate(dailyReportProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the date navigation header (Previous, Date Card, Next)
  Widget _buildDateNavigationBar(
    BuildContext context,
    WidgetRef ref,
    String mode,
    DateTime selectedDay,
    String locale,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSingleDayMode =
        mode == 'today' || mode == 'yesterday' || mode == 'day';
    final isToday =
        selectedDay.year == today.year &&
        selectedDay.month == today.month &&
        selectedDay.day == today.day;

    String title;
    if (isSingleDayMode) {
      if (isToday) {
        title =
            '${l10n.today} • ${DateFormatter.formatFull(selectedDay, locale: locale)}';
      } else if (selectedDay.year == today.year &&
          selectedDay.month == today.month &&
          selectedDay.day == today.day - 1) {
        title =
            '${l10n.yesterday} • ${DateFormatter.formatFull(selectedDay, locale: locale)}';
      } else {
        title = DateFormatter.formatFull(selectedDay, locale: locale);
      }
    } else if (mode == 'week') {
      title = l10n.thisWeek;
    } else if (mode == 'month') {
      title = DateFormatter.formatMonthYear(now, locale: locale);
    } else {
      final range = ref.watch(reportCustomRangeProvider);
      if (range != null) {
        title =
            '${DateFormatter.formatShort(range.start, locale: locale)} — ${DateFormatter.formatShort(range.end, locale: locale)}';
      } else {
        title = l10n.customRange;
      }
    }

    Widget navBarContent = Row(
      children: [
        // Previous Day button
        if (isSingleDayMode)
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 20,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            tooltip: l10n.previousDay,
            onPressed: () {
              HapticFeedback.selectionClick();
              final prev = selectedDay.subtract(const Duration(days: 1));
              ref.read(selectedReportDayProvider.notifier).state = prev;
              ref.read(reportModeProvider.notifier).state = 'day';
            },
          ),

        // Date Display Card (Clickable to open DatePicker)
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              HapticFeedback.lightImpact();
              if (isSingleDayMode) {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDay,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  locale: Locale(locale),
                );
                if (picked != null) {
                  ref.read(selectedReportDayProvider.notifier).state = picked;
                  ref.read(reportModeProvider.notifier).state = 'day';
                }
              } else if (mode == 'custom') {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  locale: Locale(locale),
                );
                if (range != null) {
                  ref.read(reportCustomRangeProvider.notifier).state = range;
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendarDay,
                    size: 16,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  FaIcon(
                    FontAwesomeIcons.caretDown,
                    size: 20,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Next Day button (disabled if today)
        if (isSingleDayMode)
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 20,
              color: isToday
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : (isDark ? Colors.white : AppColors.primary),
            ),
            tooltip: l10n.nextDay,
            onPressed: isToday
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    final next = selectedDay.add(const Duration(days: 1));
                    ref.read(selectedReportDayProvider.notifier).state = next;
                    ref.read(reportModeProvider.notifier).state = 'day';
                  },
          ),
      ],
    );

    if (isDark) {
      return DarkGlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        borderRadius: 16,
        backgroundColor: const Color(0xFF16161A),
        child: navBarContent,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: navBarContent,
    );
  }

  /// Open transaction bottom sheet with Dekont sharing button
  void _openTransactionDetails(
    BuildContext context,
    WidgetRef ref,
    TransactionModel tx,
    AppLocalizations l10n,
    String locale,
  ) async {
    HapticFeedback.lightImpact();
    final customerRepo = ref.read(customerRepositoryProvider);
    final txRepo = ref.read(transactionRepositoryProvider);

    final customer = await customerRepo.getCustomerById(tx.customerId);
    var customerName = customer?.name ?? tx.customerName;

    if (customerName == null) {
      try {
        final res = await Supabase.instance.client
            .from('customers')
            .select('name')
            .eq('id', tx.customerId)
            .maybeSingle();
        if (res != null) {
          customerName = res['name'] as String?;
        }
      } catch (_) {}
    }

    customerName ??= (locale == 'ar' ? 'زبون محذوف' : 'Deleted Customer');

    final allCustomerTx = await txRepo.getTransactionsByCustomer(tx.customerId);

    if (!context.mounted) return;

    final isDebt = tx.isDebt;
    final color = isDebt ? AppColors.debt : AppColors.payment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Widget content = Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDebt ? l10n.debt : l10n.payment,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${isDebt ? "+" : "-"}${CurrencyFormatter.format(tx.amount, locale: locale)}',
                    style: AppTextStyles.moneyLarge.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Customer info
              if (customerName != null) ...[
                _buildModalRow(
                  label: l10n.customer,
                  value: customerName,
                  bold: true,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
              ],

              // Date & Time
              _buildModalRow(
                label: l10n.date,
                value: DateFormatter.formatFull(tx.createdAt, locale: locale),
                isDark: isDark,
              ),
              const SizedBox(height: 8),

              // Description if available
              if (tx.description.isNotEmpty) ...[
                _buildModalRow(
                  label: l10n.description,
                  value: tx.description,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 18),

              // [ 📄 مشاركة Dekont ] Button
              if (customer != null) ...[
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      DekontShareService.showReceiptPrinter(
                        context: context,
                        customer: customer,
                        transaction: tx,
                        allTransactions: allCustomerTx,
                        languageCode: locale,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.primary,
                      foregroundColor: isDark ? Colors.white : Colors.white,
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
                    icon: const FaIcon(FontAwesomeIcons.filePdf, size: 20),
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

              // Close Button
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.cancel),
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

  Widget _buildModalRow({
    required String label,
    required String value,
    bool bold = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Period mode selection chip
class _ModeChip extends StatelessWidget {
  final String label;
  final String modeValue;
  final dynamic icon;
  final String currentMode;
  final VoidCallback onSelect;

  const _ModeChip({
    required this.label,
    required this.modeValue,
    required this.icon,
    required this.currentMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == modeValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // High contrast light colors in Dark Mode for perfect legibility
    final unselectedBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Theme.of(context).cardColor;
    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.border;
    final unselectedTextColor = isDark ? Colors.white : AppColors.textPrimary;
    final unselectedIconColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : unselectedBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : unselectedBorder,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.primary.withAlpha(80),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : unselectedIconColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : unselectedTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Financial metric card with smooth aesthetic
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final dynamic icon;
  final Color color;
  final Color bgColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: isDark ? Colors.white : color,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTextStyles.moneyMedium.copyWith(
                    color: isDark ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textHint,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: cardContent,
    );
  }
}

/// Filter pill for transactions ledger
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? (isDark ? Colors.white : AppColors.primary);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: isDark ? 0.15 : 0.1)
              : (isDark ? Colors.transparent : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? activeColor
                : (isDark
                      ? AppColors.darkBorder
                      : AppColors.border.withAlpha(80)),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected
                ? activeColor
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Transaction card inside the daily reports ledger
class _ReportTransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String locale;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _ReportTransactionCard({
    required this.transaction,
    required this.locale,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDebt = transaction.isDebt;
    final color = isDebt ? AppColors.debt : AppColors.payment;
    final bgColor = isDebt
        ? (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.debtLight)
        : (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.paymentLight);

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Type Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                isDebt ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                color: isDark ? Colors.white : color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Customer & Time Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.customerName ??
                      (locale == 'ar' ? 'زبون محذوف' : 'Deleted Customer'),
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      DateFormatter.formatTime(
                        transaction.createdAt,
                        locale: locale,
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textHint,
                      ),
                    ),
                    if (transaction.description.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Amount & Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebt ? "+" : "-"}${CurrencyFormatter.format(transaction.amount, locale: locale)}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isDebt ? l10n.debt : l10n.payment,
                  style: TextStyle(
                    color: isDark ? Colors.white : color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
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
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        borderRadius: 14,
        backgroundColor: const Color(0xFF16161A),
        onTap: onTap,
        child: cardContent,
      );
    }

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border.withAlpha(80)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: cardContent,
      ),
    );
  }
}
