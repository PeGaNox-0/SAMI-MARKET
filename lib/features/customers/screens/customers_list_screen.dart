import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../dashboard/screens/dashboard_screen.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'send_notification_screen.dart';
import '../../../core/widgets/dark_glass_container.dart';

/// Customer list stream provider with live updates
final customerListProvider = StreamProvider.autoDispose
    .family<List<CustomerModel>, ({String? search, String? filter})>((
      ref,
      params,
    ) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const Stream.empty();
      final repo = ref.watch(customerRepositoryProvider);
      return repo.watchCustomers(
        userId: user.id,
        search: params.search,
        filter: params.filter,
      );
    });

/// Current search query
final customerSearchProvider = StateProvider<String>((ref) => '');

/// Current filter
final customerFilterProvider = StateProvider<String>((ref) => 'all');

class CustomersListScreen extends ConsumerWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final search = ref.watch(customerSearchProvider);
    final filter = ref.watch(customerFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(
      customerListProvider((
        search: search.isEmpty ? null : search,
        filter: filter,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bullhorn, size: 20),
            tooltip: l10n.sendNotification,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SendNotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 20),
            tooltip: 'تحديث',
            onPressed: () {
              ref.invalidate(customerListProvider);
              ref.invalidate(dashboardStatsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchCustomer,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
                  ),
                ),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                        onPressed: () =>
                            ref.read(customerSearchProvider.notifier).state =
                                '',
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(customerSearchProvider.notifier).state = v,
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.all,
                  value: 'all',
                  current: filter,
                  ref: ref,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.hasDebt,
                  value: 'has_debt',
                  current: filter,
                  ref: ref,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.fullyPaid,
                  value: 'paid',
                  current: filter,
                  ref: ref,
                ),
              ],
            ),
          ),

          // Customer list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(customerListProvider);
                ref.invalidate(dashboardStatsProvider);
              },
              child: customersAsync.when(
                data: (customers) {
                  if (customers.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.users,
                                size: 64,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noCustomers,
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noCustomersMessage,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 4,
                      bottom: 100,
                    ),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final balance = customer.balance ?? 0;
                      final hasDebt = balance > 0;

                      Widget tileContent = ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : (hasDebt
                                    ? AppColors.debt.withAlpha(25)
                                    : AppColors.payment.withAlpha(25)),
                          child: Text(
                            customer.name.isNotEmpty ? customer.name[0] : '?',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : (hasDebt
                                        ? AppColors.debt
                                        : AppColors.payment),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                customer.name,
                                style: AppTextStyles.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (customer.customerCode.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : AppColors.primary.withAlpha(60),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '#${customer.customerCode}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: customer.phone.isNotEmpty
                            ? Text(
                                customer.phone,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              )
                            : null,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(balance, locale: locale),
                              style: AppTextStyles.moneyMedium.copyWith(
                                color: hasDebt
                                    ? AppColors.debt
                                    : AppColors.payment,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              hasDebt ? l10n.remainingDebt : l10n.fullyPaid,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await Navigator.of(
                            context,
                          ).pushNamed('/customers/${customer.id}');
                          ref.invalidate(customerListProvider);
                          ref.invalidate(dashboardStatsProvider);
                        },
                      );

                      if (isDark) {
                        return DarkGlassContainer(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.zero,
                          borderRadius: 16,
                          backgroundColor: const Color(0xFF16161A),
                          child: tileContent,
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: tileContent,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(
              context,
            ).pushNamed('/customers/add');
            if (result == true) {
              ref.invalidate(customerListProvider);
              ref.invalidate(dashboardStatsProvider);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.userPlus, size: 20),
          label: Text(l10n.addCustomer),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final WidgetRef ref;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(customerFilterProvider.notifier).state = value;
        }
      },
      selectedColor: isDark
          ? Colors.white.withValues(alpha: 0.15)
          : AppColors.primary.withAlpha(25),
      backgroundColor: isDark ? Colors.transparent : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? (isDark ? Colors.white : AppColors.primary)
              : (isDark ? AppColors.darkBorder : Colors.transparent),
          width: 1.2,
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? Colors.white : AppColors.primary)
            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
