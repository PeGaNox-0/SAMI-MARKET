import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddTemporaryCustomerDialog extends ConsumerStatefulWidget {
  const AddTemporaryCustomerDialog({super.key});

  @override
  ConsumerState<AddTemporaryCustomerDialog> createState() =>
      _AddTemporaryCustomerDialogState();
}

class _AddTemporaryCustomerDialogState
    extends ConsumerState<AddTemporaryCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not found');

      final amount = double.parse(_amountController.text);
      
      await ref.read(customerRepositoryProvider).addTemporaryCustomer(
            userId: user.id,
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
            content: Text('Error adding temporary customer: $e'),
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
      title: Text('إضافة زبون مؤقت', style: AppTextStyles.titleLarge),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  v == null || v.isEmpty ? 'يرجى إدخال اسم الزبون' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FaIcon(FontAwesomeIcons.dollarSign, size: 18),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'يرجى إدخال المبلغ';
                if (double.tryParse(v) == null) return 'قيمة غير صالحة';
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
              : const Text('حفظ'),
        ),
      ],
    );
  }
}
