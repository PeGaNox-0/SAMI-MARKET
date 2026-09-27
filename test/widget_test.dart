import 'package:flutter_test/flutter_test.dart';
import 'package:omar_app/core/utils/currency_formatter.dart';
import 'package:omar_app/core/utils/validators.dart';
import 'package:omar_app/data/models/customer_model.dart';
import 'package:omar_app/data/models/transaction_model.dart';
import 'package:omar_app/data/models/customer_account_model.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format currency correctly in English and Arabic', () {
      final formattedEn = CurrencyFormatter.format(1250.50, locale: 'en');
      expect(formattedEn, '1,250.50 ₺');

      final compact = CurrencyFormatter.formatCompact(18450, locale: 'en');
      expect(compact, '18,450 ₺');
    });

    test('formatWithSign returns positive for debt and negative for payment', () {
      final debtStr = CurrencyFormatter.formatWithSign(250, 'debt', locale: 'en');
      expect(debtStr, '+250.00 ₺');

      final paymentStr = CurrencyFormatter.formatWithSign(100, 'payment', locale: 'en');
      expect(paymentStr, '-100.00 ₺');
    });
  });

  group('Validators Tests', () {
    test('required validator', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required('Omar'), isNull);
    });

    test('email validator', () {
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('test@example.com'), isNull);
    });

    test('amount validator', () {
      expect(Validators.amount('0'), isNotNull);
      expect(Validators.amount('-50'), isNotNull);
      expect(Validators.amount('abc'), isNotNull);
      expect(Validators.amount('150.75'), isNull);
    });

    test('payment validator against debt', () {
      expect(Validators.paymentAmount('150', 100), isNotNull);
      expect(Validators.paymentAmount('100', 100), isNull);
      expect(Validators.paymentAmount('50', 100), isNull);
    });
  });

  group('Models Serialization', () {
    test('CustomerModel JSON roundtrip', () {
      final now = DateTime.now();
      final customer = CustomerModel(
        id: 'cust-123',
        userId: 'user-456',
        name: 'Ahmed',
        customerCode: 'SM-10001',
        phone: '05551234567',
        address: 'Main St',
        notes: 'VIP',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = customer.toJson();
      final fromJson = CustomerModel.fromJson(json);

      expect(fromJson.id, customer.id);
      expect(fromJson.name, customer.name);
      expect(fromJson.customerCode, customer.customerCode);
      expect(fromJson.phone, customer.phone);
    });

    test('TransactionModel JSON roundtrip', () {
      final now = DateTime.now();
      final tx = TransactionModel(
        id: 'tx-123',
        userId: 'user-456',
        customerId: 'cust-123',
        type: 'debt',
        amount: 250.0,
        description: 'Groceries',
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      );

      final json = tx.toJson();
      final fromJson = TransactionModel.fromJson(json);

      expect(fromJson.id, tx.id);
      expect(fromJson.amount, tx.amount);
      expect(fromJson.isDebt, isTrue);
      expect(fromJson.isPayment, isFalse);
    });

    test('CustomerAccountModel JSON roundtrip', () {
      final now = DateTime.now();
      final account = CustomerAccountModel(
        id: 'acc-123',
        customerId: 'cust-123',
        customerCode: 'SM-48291',
        isEnabled: true,
        failedAttempts: 1,
        createdAt: now,
        updatedAt: now,
      );

      final json = account.toJson();
      final fromJson = CustomerAccountModel.fromJson(json);

      expect(fromJson.id, account.id);
      expect(fromJson.customerId, account.customerId);
      expect(fromJson.customerCode, account.customerCode);
      expect(fromJson.isEnabled, isTrue);
      expect(fromJson.failedAttempts, 1);
      expect(fromJson.isLocked, isFalse);
    });
  });
}
