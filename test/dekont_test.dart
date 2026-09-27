import 'package:flutter_test/flutter_test.dart';
import 'package:omar_app/data/models/customer_model.dart';
import 'package:omar_app/data/models/transaction_model.dart';
import 'package:omar_app/features/dekont/services/dekont_calculator.dart';
import 'package:omar_app/features/dekont/services/pdf_dekont_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyCustomer = CustomerModel(
    id: 'cust-123456',
    userId: 'user-999',
    name: 'أحمد محمد',
    customerCode: 'SM-48291',
    phone: '+905551234567',
    address: 'إسطنبول',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final tx1 = TransactionModel(
    id: 'tx-001',
    userId: 'user-999',
    customerId: 'cust-123456',
    type: 'debt',
    amount: 300.0,
    description: 'شراء مواد غذائية',
    createdAt: DateTime(2026, 8, 10, 10, 0),
    updatedAt: DateTime(2026, 8, 10, 10, 0),
  );

  final tx2 = TransactionModel(
    id: 'tx-002',
    userId: 'user-999',
    customerId: 'cust-123456',
    type: 'debt',
    amount: 250.0,
    description: 'شراء لحوم وخضار',
    createdAt: DateTime(2026, 8, 12, 14, 30),
    updatedAt: DateTime(2026, 8, 12, 14, 30),
  );

  final tx3 = TransactionModel(
    id: 'tx-003',
    userId: 'user-999',
    customerId: 'cust-123456',
    type: 'payment',
    amount: 200.0,
    description: 'دفعة نقدية',
    createdAt: DateTime(2026, 8, 14, 11, 15),
    updatedAt: DateTime(2026, 8, 14, 11, 15),
  );

  group('DekontCalculator Statement Tests', () {
    test('Calculates totals, remaining balance, and statement snapshot correctly', () {
      final statement = DekontCalculator.buildStatementData(
        customer: dummyCustomer,
        transactions: [tx1, tx2, tx3],
      );

      expect(statement.totalDebts, 550.0);
      expect(statement.totalPayments, 200.0);
      expect(statement.remainingDebt, 350.0);
      expect(statement.isFullyPaid, false);
      expect(statement.transactions.length, 3);
      expect(statement.statementNumber.contains('SM-48291'), true);
    });

    test('Handles fully paid customer correctly', () {
      final fullPayment = TransactionModel(
        id: 'tx-004',
        userId: 'user-999',
        customerId: 'cust-123456',
        type: 'payment',
        amount: 350.0,
        createdAt: DateTime(2026, 8, 15),
        updatedAt: DateTime(2026, 8, 15),
      );

      final statement = DekontCalculator.buildStatementData(
        customer: dummyCustomer,
        transactions: [tx1, tx2, tx3, fullPayment],
      );

      expect(statement.totalDebts, 550.0);
      expect(statement.totalPayments, 550.0);
      expect(statement.remainingDebt, 0.0);
      expect(statement.isFullyPaid, true);
    });

    test('Handles empty transaction history gracefully', () {
      final statement = DekontCalculator.buildStatementData(
        customer: dummyCustomer,
        transactions: [],
      );

      expect(statement.totalDebts, 0.0);
      expect(statement.totalPayments, 0.0);
      expect(statement.remainingDebt, 0.0);
      expect(statement.isFullyPaid, true);
      expect(statement.transactions, isEmpty);
    });
  });

  group('DekontCalculator Transaction Dekont Tests', () {
    test('Calculates Before and After balances accurately for payment transaction', () {
      final dekont = DekontCalculator.buildTransactionDekontData(
        customer: dummyCustomer,
        targetTransaction: tx3,
        allTransactions: [tx1, tx2, tx3],
      );

      // Before tx3 (debts 300 + 250 = 550)
      expect(dekont.beforeBalance, 550.0);
      // Payment of 200 -> After balance = 350
      expect(dekont.afterBalance, 350.0);
      expect(dekont.referenceNumber.startsWith('TXN-'), true);
    });

    test('Calculates Before and After balances accurately for debt transaction', () {
      final dekont = DekontCalculator.buildTransactionDekontData(
        customer: dummyCustomer,
        targetTransaction: tx2,
        allTransactions: [tx1, tx2, tx3],
      );

      // Before tx2 (debt 300)
      expect(dekont.beforeBalance, 300.0);
      // Debt of 250 -> After balance = 550
      expect(dekont.afterBalance, 550.0);
    });

    test('Deterministic transaction reference stability', () {
      final dekont1 = DekontCalculator.buildTransactionDekontData(
        customer: dummyCustomer,
        targetTransaction: tx3,
        allTransactions: [tx1, tx2, tx3],
      );
      final dekont2 = DekontCalculator.buildTransactionDekontData(
        customer: dummyCustomer,
        targetTransaction: tx3,
        allTransactions: [tx1, tx2, tx3],
      );

      expect(dekont1.referenceNumber, dekont2.referenceNumber);
    });
  });

  group('PdfDekontGenerator PDF Tests', () {
    test('Generates non-empty valid PDF bytes for Arabic Account Statement', () async {
      final statement = DekontCalculator.buildStatementData(
        customer: dummyCustomer,
        transactions: [tx1, tx2, tx3],
      );

      final bytes = await PdfDekontGenerator.generateAccountStatement(
        data: statement,
        languageCode: 'ar',
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('Generates non-empty valid PDF bytes for English Account Statement', () async {
      final statement = DekontCalculator.buildStatementData(
        customer: dummyCustomer,
        transactions: [tx1, tx2, tx3],
      );

      final bytes = await PdfDekontGenerator.generateAccountStatement(
        data: statement,
        languageCode: 'en',
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('Generates non-empty valid PDF bytes for Transaction Dekont', () async {
      final dekont = DekontCalculator.buildTransactionDekontData(
        customer: dummyCustomer,
        targetTransaction: tx3,
        allTransactions: [tx1, tx2, tx3],
      );

      final bytes = await PdfDekontGenerator.generateTransactionDekont(
        data: dekont,
        languageCode: 'ar',
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('Generates multi-page Account Statement with 60 transactions without crashing or freezing', () async {
      final manyTransactions = List.generate(60, (index) {
        return TransactionModel(
          id: 'tx-many-$index',
          userId: 'user-999',
          customerId: 'cust-123456',
          type: index % 3 == 0 ? 'payment' : 'debt',
          amount: (index + 1) * 15.0,
          description: 'حركة تجريبية رقم $index',
          createdAt: DateTime(2026, 1, 1).add(Duration(days: index)),
          updatedAt: DateTime(2026, 1, 1).add(Duration(days: index)),
        );
      });

      final statement = DekontCalculator.buildStatementData(
        customer: dummyCustomer,
        transactions: manyTransactions,
      );

      final bytes = await PdfDekontGenerator.generateAccountStatement(
        data: statement,
        languageCode: 'ar',
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(2000));
    });
  });
}
