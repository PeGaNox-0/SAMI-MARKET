import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/models/customer_model.dart';
import 'add_temporary_customer_dialog.dart';
import 'edit_temporary_customer_dialog.dart';

/// Temporary customer list stream provider
final temporaryCustomerListProvider =
    StreamProvider.autoDispose<List<CustomerModel>>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const Stream.empty();
      final repo = ref.watch(customerRepositoryProvider);
      return repo.watchTemporaryCustomers(user.id);
    });

final tempCustomerSearchProvider = StateProvider<String>((ref) => '');
final tempCustomerFilterProvider = StateProvider<String>((ref) => 'all');

class TemporaryCustomersScreen extends ConsumerWidget {
  const TemporaryCustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final search = ref.watch(tempCustomerSearchProvider);
    final filter = ref.watch(tempCustomerFilterProvider);

    final asyncTemps = ref.watch(temporaryCustomerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الزبائن المؤقتين'),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.rotateRight, size: 20),
            tooltip: 'تحديث',
            onPressed: () {
              ref.invalidate(temporaryCustomerListProvider);
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
                            ref
                                    .read(tempCustomerSearchProvider.notifier)
                                    .state =
                                '',
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(tempCustomerSearchProvider.notifier).state = v,
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
                ref.invalidate(temporaryCustomerListProvider);
              },
              child: asyncTemps.when(
                data: (temps) {
                  // Apply search and filter
                  var filtered = temps;
                  if (search.isNotEmpty) {
                    filtered = filtered
                        .where(
                          (c) => c.name.toLowerCase().contains(
                            search.toLowerCase(),
                          ),
                        )
                        .toList();
                  }
                  if (filter == 'has_debt') {
                    filtered = filtered
                        .where((c) => (c.balance ?? 0) > 0)
                        .toList();
                  } else if (filter == 'paid') {
                    filtered = filtered
                        .where((c) => (c.balance ?? 0) <= 0)
                        .toList();
                  }

                  if (filtered.isEmpty) {
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
                                FontAwesomeIcons.usersSlash,
                                size: 48,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا يوجد زبائن مؤقتين',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'قم بإضافة زبون مؤقت بالضغط على زر الإضافة',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      final balance = customer.balance ?? 0;
                      final hasDebt = balance > 0;

                      return RepaintBoundary(
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: hasDebt
                                  ? AppColors.debt.withAlpha(25)
                                  : AppColors.payment.withAlpha(25),
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name[0]
                                    : '?',
                                style: TextStyle(
                                  color: hasDebt
                                      ? AppColors.debt
                                      : AppColors.payment,
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
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (customer.notes.isNotEmpty) ...[
                                  Text(
                                    customer.notes,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                ],
                                Row(
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.clock,
                                      size: 11,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormatter.formatRelativeWithTime(
                                        customer.createdAt,
                                        locale: locale,
                                      ),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textHint,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.penToSquare,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) =>
                                          EditTemporaryCustomerDialog(
                                            customer: customer,
                                          ),
                                    );
                                    if (result == true) {
                                      ref.invalidate(
                                        temporaryCustomerListProvider,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(
                                        balance,
                                        locale: locale,
                                      ),
                                      style: AppTextStyles.moneyMedium.copyWith(
                                        color: hasDebt
                                            ? AppColors.debt
                                            : AppColors.payment,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'زبون مؤقت',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.debt,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    'تسديد الدين',
                                    style: AppTextStyles.titleLarge,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'هل قام هذا الزبون المؤقت بتسديد دينه بالكامل؟',
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.clock,
                                            size: 12,
                                            color: AppColors.textHint,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'وقت تسجيل الدين: ${DateFormatter.formatRelativeWithTime(customer.createdAt, locale: locale)}',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'سيتم حذف هذا الزبون نهائياً ولن يظهر بعد الآن.',
                                        style: TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.payment,
                                        foregroundColor: AppColors.surface,
                                      ),
                                      child: const Text('نعم، تم التسديد'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await ref
                                    .read(customerRepositoryProvider)
                                    .deleteTemporaryCustomer(customer.id);
                                ref.invalidate(temporaryCustomerListProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم تسجيل التسديد وحذف الزبون المؤقت.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (ctx) => const AddTemporaryCustomerDialog(),
            );
            if (result == true) {
              ref.invalidate(temporaryCustomerListProvider);
            }
          },
          icon: const FaIcon(FontAwesomeIcons.stopwatch, size: 18),
          label: const Text('إضافة مؤقت'),
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(tempCustomerFilterProvider.notifier).state = value;
        }
      },
      selectedColor: AppColors.primary.withAlpha(25),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
