import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/models/customer_model.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const AddEditCustomerScreen({super.key, this.customerId});

  @override
  ConsumerState<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customerCodeController = TextEditingController();
  final _pinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _enableAppAccess = false;
  bool _isLoading = false;
  bool _isEdit = false;
  CustomerModel? _existingCustomer;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.customerId != null;
    if (_isEdit) {
      _loadCustomer();
    } else {
      _generateDefaultCredentials();
    }
  }

  void _generateDefaultCredentials() {
    final random = Random();
    final randomCodeNum = 10000 + random.nextInt(90000); // 5 digits
    final randomPin = 100000 + random.nextInt(900000); // 6 digits

    _customerCodeController.text = 'SM-$randomCodeNum';
    _pinController.text = '$randomPin';
  }

  Future<void> _loadCustomer() async {
    final customer = await ref.read(customerRepositoryProvider).getCustomerById(widget.customerId!);
    if (customer != null && mounted) {
      setState(() {
        _existingCustomer = customer;
        _nameController.text = customer.name;
        _customerCodeController.text = customer.customerCode.isNotEmpty
            ? customer.customerCode
            : 'SM-${10000 + Random().nextInt(90000)}';
        _phoneController.text = customer.phone;
        _addressController.text = customer.address;
        _notesController.text = customer.notes;
      });

      // Check if account already exists
      final account = await ref.read(customerRepositoryProvider).getCustomerAccount(customer.id);
      if (account != null && mounted) {
        setState(() {
          _enableAppAccess = account['is_enabled'] as bool? ?? true;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customerCodeController.dispose();
    _pinController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final customerRepo = ref.read(customerRepositoryProvider);
      final customerCode = _customerCodeController.text.trim().toUpperCase();
      final pin = _pinController.text.trim();

      String targetCustomerId;

      if (_isEdit && _existingCustomer != null) {
        targetCustomerId = _existingCustomer!.id;
        await customerRepo.updateCustomer(
          _existingCustomer!.copyWith(
            name: _nameController.text.trim(),
            customerCode: customerCode,
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim(),
          ),
        );

        // If access toggle changed or set
        if (_enableAppAccess && pin.isNotEmpty) {
          final accRes = await customerRepo.createCustomerAccount(
            customerId: targetCustomerId,
            customerCode: customerCode,
            pin: pin,
          );
          if (accRes['success'] != true) {
            throw Exception(accRes['error'] ?? 'تعذر حفظ حساب الزبون في السيرفر');
          }
        }
      } else {
        final user = ref.read(currentUserProvider);
        if (user == null) return;

        final newCustomer = await customerRepo.addCustomer(
          userId: user.id,
          name: _nameController.text.trim(),
          customerCode: customerCode,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        );
        targetCustomerId = newCustomer.id;

        // If enable app access was checked
        if (_enableAppAccess && pin.isNotEmpty) {
          final accRes = await customerRepo.createCustomerAccount(
            customerId: targetCustomerId,
            customerCode: customerCode,
            pin: pin,
          );
          if (accRes['success'] != true) {
            throw Exception(accRes['error'] ?? 'تعذر حفظ حساب الزبون في السيرفر');
          }
        }
      }

      if (!mounted) return;

      // If app access was enabled and a pin was set, show the credentials reveal dialog
      if (_enableAppAccess && pin.isNotEmpty) {
        await _showCredentialsDialog(
          customerName: _nameController.text.trim(),
          customerCode: customerCode,
          pin: pin,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.debt,
            content: Text(
              'حدث خطأ: ${e.toString().replaceAll('Exception:', '').trim()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showCredentialsDialog({
    required String customerName,
    required String customerCode,
    required String pin,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final shareText = '''
🏪 SAMI MARKET — بيانات دخول حساب الزبون
👤 الاسم: $customerName
🏷️ رمز الزبون: $customerCode
🔑 الشيفرة (PIN): $pin
''';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.payment, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.customerAccountCreated, style: AppTextStyles.titleMedium)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.saveCredentialsWarning,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Customer Code Box
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
                      Text(customerCode, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
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

            // PIN Box
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
                      Text(pin, style: AppTextStyles.titleLarge.copyWith(color: AppColors.payment, letterSpacing: 2)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppColors.payment),
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
            icon: const Icon(Icons.share_rounded, size: 18),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editCustomer : l10n.addCustomer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Header
              Text('المعلومات الأساسية', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.customerName} *',
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                validator: (v) => Validators.required(v, fieldName: l10n.customerName),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: Validators.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  prefixIcon: const Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),

              // Customer App Access Switch Section
              Row(
                children: [
                  const Icon(Icons.smartphone_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.enableCustomerAccess, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        Text(l10n.enableCustomerAccessDesc, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableAppAccess,
                    onChanged: (val) {
                      setState(() {
                        _enableAppAccess = val;
                        if (val && _pinController.text.isEmpty) {
                          _generateDefaultCredentials();
                        }
                      });
                    },
                  ),
                ],
              ),

              if (_enableAppAccess) ...[
                const SizedBox(height: 16),
                Card(
                  color: AppColors.primary.withAlpha(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.primary.withAlpha(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Customer Code field
                        TextFormField(
                          controller: _customerCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: l10n.customerCode,
                            hintText: 'SM-48291',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh_rounded),
                              tooltip: 'توليد كود تلقائي',
                              onPressed: () {
                                final code = 'SM-${10000 + Random().nextInt(90000)}';
                                _customerCodeController.text = code;
                              },
                            ),
                          ),
                          validator: (v) {
                            if (_enableAppAccess && (v == null || v.trim().isEmpty)) {
                              return 'رمز الزبون مطلوب لتفعيل الدخول';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // PIN field
                        TextFormField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          decoration: InputDecoration(
                            labelText: l10n.customerPin,
                            hintText: l10n.customerPinHint,
                            counterText: '',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh_rounded),
                              tooltip: 'توليد شيفرة عشوائية',
                              onPressed: () {
                                final pin = '${100000 + Random().nextInt(900000)}';
                                _pinController.text = pin;
                              },
                            ),
                          ),
                          validator: (v) {
                            if (_enableAppAccess && (v == null || v.trim().length < 4)) {
                              return 'الشيفرة يجب أن تكون 4 أرقام على الأقل';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
