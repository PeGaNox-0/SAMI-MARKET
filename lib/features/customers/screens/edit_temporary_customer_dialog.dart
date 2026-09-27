import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/models/customer_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditTemporaryCustomerDialog extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const EditTemporaryCustomerDialog({
    super.key,
    required this.customer,
  });

  @override
  ConsumerState<EditTemporaryCustomerDialog> createState() =>
      _EditTemporaryCustomerDialogState();
}

class _EditTemporaryCustomerDialogState
    extends ConsumerState<EditTemporaryCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    final balance = widget.customer.balance;
    final initialAmount = (balance != null && balance > 0)
        ? (balance % 1 == 0 ? balance.toInt().toString() : balance.toString())
        : '';
    _amountController = TextEditingController(text: initialAmount);
    _descriptionController = TextEditingController(text: widget.customer.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(customerRepositoryProvider).updateTemporaryCustomer(
            id: widget.customer.id,
            name: _nameController.text.trim(),
            amount: amount,
            description: _descriptionController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء تعديل الزبون المؤقت: $e'),
            backgroundColor: AppColors.debt,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text('تعديل الزبون المؤقت', style: AppTextStyles.titleLarge),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.clock,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'وقت التسجيل: ${DateFormatter.formatRelativeWithTime(widget.customer.createdAt, locale: Localizations.localeOf(context).languageCode)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.customerName,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FaIcon(FontAwesomeIcons.user, size: 18),
                  ),
                ),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'يرجى إدخال اسم الزبون' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'مبلغ الدين',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FaIcon(FontAwesomeIcons.dollarSign, size: 18),
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'يرجى إدخال المبلغ';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) return 'قيمة غير صالحة';
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FaIcon(FontAwesomeIcons.fileLines, size: 18),
                  ),
                ),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.debt,
            foregroundColor: AppColors.surface,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('حفظ التعديل'),
        ),
      ],
    );
  }
}
