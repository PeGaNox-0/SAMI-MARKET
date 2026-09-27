import 'transaction_model.dart';

/// Aggregated report data model for a single day or custom date range
class DailyReportModel {
  final DateTime startDate;
  final DateTime endDate;
  final double totalDebt;
  final double totalPayments;
  final double netBalance; // totalDebt - totalPayments
  final int debtsCount;
  final int paymentsCount;
  final int uniqueCustomersCount;
  final List<TransactionModel> transactions;

  const DailyReportModel({
    required this.startDate,
    required this.endDate,
    required this.totalDebt,
    required this.totalPayments,
    required this.netBalance,
    required this.debtsCount,
    required this.paymentsCount,
    required this.uniqueCustomersCount,
    required this.transactions,
  });

  int get totalOperations => debtsCount + paymentsCount;
  bool get hasTransactions => transactions.isNotEmpty;

  factory DailyReportModel.empty(DateTime startDate, DateTime endDate) {
    return DailyReportModel(
      startDate: startDate,
      endDate: endDate,
      totalDebt: 0.0,
      totalPayments: 0.0,
      netBalance: 0.0,
      debtsCount: 0,
      paymentsCount: 0,
      uniqueCustomersCount: 0,
      transactions: const [],
    );
  }
}
