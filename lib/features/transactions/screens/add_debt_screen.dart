import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  final String customerId;

  const AddDebtScreen({super.key, required this.customerId});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final amount = double.parse(
        _amountController.text.replaceAll(RegExp(r'[^\d.]'), ''),
      );

      final sanitizedDesc = Validators.sanitize(_descriptionController.text);

      await ref
          .read(transactionRepositoryProvider)
          .addDebt(
            userId: user.id,
            customerId: widget.customerId,
            amount: amount,
            description: sanitizedDesc,
            date: _selectedDate,
          );

      // Send automatic notification to the customer
      try {
        await ref
            .read(notificationServiceProvider)
            .sendNotification(
              message: 'تم إضافة دين جديد على حسابك بمبلغ $amount',
              customerIds: [widget.customerId],
            );
      } catch (_) {
        // Silent catch: notification sending shouldn't block local success
      }

      // Trigger sync if online
      final isOnline = await ref.read(connectivityServiceProvider).isConnected;
      if (!isOnline && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.offlineSaved),
            backgroundColor: AppColors.warning,
          ),
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('حدث خطأ')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addDebt)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount input (prominent)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF16161A).withValues(alpha: 0.55)
                      : AppColors.debtLight,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark
                      ? Border.all(
                          color: AppColors.debt.withValues(alpha: 0.3),
                          width: 1.2,
                        )
                      : null,
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: AppColors.debt.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.amount,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.debt,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.moneyLarge.copyWith(
                        color: isDark ? Colors.white : AppColors.debt,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: AppTextStyles.moneyLarge.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.debt.withAlpha(80),
                        ),
                        suffixText: '₺',
                        suffixStyle: AppTextStyles.moneyMedium.copyWith(
                          color: isDark ? Colors.white : AppColors.debt,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      validator: Validators.amount,
                      autofocus: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.note_outlined),
                  hintText: 'مثال: مواد غذائية',
                ),
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.date),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: isDark
                      ? AppTextStyles.bodyMedium.copyWith(color: Colors.white)
                      : AppTextStyles.bodyMedium,
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : AppColors.debt,
                    foregroundColor: isDark ? Colors.white : Colors.white,
                    side: isDark
                        ? const BorderSide(
                            color: AppColors.darkBorder,
                            width: 1.2,
                          )
                        : BorderSide.none,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.addDebt,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
