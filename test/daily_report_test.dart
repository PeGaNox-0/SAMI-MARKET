import 'package:flutter_test/flutter_test.dart';
import 'package:omar_app/data/models/daily_report_model.dart';
import 'package:omar_app/data/models/transaction_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tx1 = TransactionModel(
    id: 'tx-1',
    userId: 'u1',
    customerId: 'c1',
    type: 'debt',
    amount: 150.0,
    description: 'شراء خبز ومواد تموينية',
    createdAt: DateTime(2026, 8, 16, 10, 30),
    updatedAt: DateTime(2026, 8, 16, 10, 30),
    customerName: 'محمد أحمد',
  );

  final tx2 = TransactionModel(
    id: 'tx-2',
    userId: 'u1',
    customerId: 'c2',
    type: 'debt',
    amount: 300.0,
    description: 'شراء منظفات',
    createdAt: DateTime(2026, 8, 16, 14, 0),
    updatedAt: DateTime(2026, 8, 16, 14, 0),
    customerName: 'خالد علي',
  );

  final tx3 = TransactionModel(
    id: 'tx-3',
    userId: 'u1',
    customerId: 'c1',
    type: 'payment',
    amount: 100.0,
    description: 'دفعة نقدية',
    createdAt: DateTime(2026, 8, 16, 18, 45),
    updatedAt: DateTime(2026, 8, 16, 18, 45),
    customerName: 'محمد أحمد',
  );

  group('DailyReportModel Unit Tests', () {
    test('Calculates aggregated statistics accurately for a day', () {
      final transactions = [tx1, tx2, tx3];
      final totalDebt = transactions
          .where((t) => t.isDebt)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      final totalPayments = transactions
          .where((t) => t.isPayment)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      final debtsCount = transactions.where((t) => t.isDebt).length;
      final paymentsCount = transactions.where((t) => t.isPayment).length;
      final uniqueCustomers = transactions.map((t) => t.customerId).toSet().length;

      final report = DailyReportModel(
        startDate: DateTime(2026, 8, 16, 0, 0, 0),
        endDate: DateTime(2026, 8, 16, 23, 59, 59),
        totalDebt: totalDebt,
        totalPayments: totalPayments,
        netBalance: totalDebt - totalPayments,
        debtsCount: debtsCount,
        paymentsCount: paymentsCount,
        uniqueCustomersCount: uniqueCustomers,
        transactions: transactions,
      );

      expect(report.totalDebt, 450.0);
      expect(report.totalPayments, 100.0);
      expect(report.netBalance, 350.0);
      expect(report.debtsCount, 2);
      expect(report.paymentsCount, 1);
      expect(report.totalOperations, 3);
      expect(report.uniqueCustomersCount, 2);
      expect(report.hasTransactions, true);
    });

    test('Handles empty day correctly', () {
      final start = DateTime(2026, 8, 15, 0, 0, 0);
      final end = DateTime(2026, 8, 15, 23, 59, 59);
      final emptyReport = DailyReportModel.empty(start, end);

      expect(emptyReport.totalDebt, 0.0);
      expect(emptyReport.totalPayments, 0.0);
      expect(emptyReport.netBalance, 0.0);
      expect(emptyReport.debtsCount, 0);
      expect(emptyReport.paymentsCount, 0);
      expect(emptyReport.totalOperations, 0);
      expect(emptyReport.uniqueCustomersCount, 0);
      expect(emptyReport.hasTransactions, false);
    });
  });
}
