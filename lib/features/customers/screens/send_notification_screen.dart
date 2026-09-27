import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/customer_model.dart';
import 'customers_list_screen.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final _messageController = TextEditingController();
  bool _sendToAll = true;
  final Set<String> _selectedIds = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send(List<CustomerModel> allCustomers) async {
    final msg = _messageController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationHint),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (!_sendToAll && _selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectAtLeastOne),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final service = ref.read(notificationServiceProvider);
    final result = await service.sendNotification(
      message: msg,
      customerIds: _sendToAll ? null : _selectedIds.toList(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final count = result['sent_count'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationSentTo(count)),
          backgroundColor: AppColors.payment,
        ),
      );
      _messageController.clear();
      setState(() {
        _selectedIds.clear();
        _sendToAll = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${result['error']}'),
          backgroundColor: AppColors.debt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final customersAsync = ref.watch(
      customerListProvider((search: null, filter: 'all')),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendNotification),
        elevation: 0,
      ),
      body: customersAsync.when(
        data: (customers) => _buildBody(context, l10n, customers, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ في تحميل الزبائن')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    List<CustomerModel> customers,
    bool isDark,
  ) {
    final customersWithAccess = customers
        .where((c) => c.customerCode.isNotEmpty)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ─── Message input ───
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.campaign_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.notificationMessage,
                      style: AppTextStyles.titleMedium),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 500,
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
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ─── Recipients selector ───
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people_outline,
                        color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.selectRecipients,
                      style: AppTextStyles.titleMedium),
                ],
              ),
              const SizedBox(height: 16),

              // Toggle: all vs specific
              Row(
                children: [
                  _RecipientChip(
                    label: l10n.sendToAll,
                    icon: Icons.group,
                    selected: _sendToAll,
                    onTap: () => setState(() {
                      _sendToAll = true;
                      _selectedIds.clear();
                    }),
                  ),
                  const SizedBox(width: 10),
                  _RecipientChip(
                    label: l10n.selectCustomers,
                    icon: Icons.person_search,
                    selected: !_sendToAll,
                    onTap: () => setState(() => _sendToAll = false),
                  ),
                ],
              ),

              // Customer list (when specific is selected)
              if (!_sendToAll) ...[
                const SizedBox(height: 16),
                if (customersWithAccess.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'لا يوجد زبائن لديهم وصول للتطبيق بعد.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...customersWithAccess.map((c) {
                    final selected = _selectedIds.contains(c.id);
                    return _CustomerSelectTile(
                      customer: c,
                      selected: selected,
                      onToggle: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (selected) {
                            _selectedIds.remove(c.id);
                          } else {
                            _selectedIds.add(c.id);
                          }
                        });
                      },
                    );
                  }),
              ],

              if (!_sendToAll && _selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'تم اختيار ${_selectedIds.length} زبون',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ─── Send button ───
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _send(customers),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _isLoading ? 'جاري الإرسال...' : l10n.sendNotificationBtn,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _RecipientChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RecipientChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerSelectTile extends StatelessWidget {
  final CustomerModel customer;
  final bool selected;
  final VoidCallback onToggle;

  const _CustomerSelectTile({
    required this.customer,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withAlpha(15)
            : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: selected
              ? AppColors.primary
              : AppColors.primary.withAlpha(25),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '?',
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(customer.name, style: AppTextStyles.bodyMedium),
        subtitle: customer.customerCode.isNotEmpty
            ? Text(
                '#${customer.customerCode}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              )
            : null,
        trailing: Checkbox(
          value: selected,
          onChanged: (_) => onToggle(),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onTap: onToggle,
      ),
    );
  }
}
