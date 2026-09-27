import '../../../../data/models/customer_model.dart';
import '../../../../data/models/transaction_model.dart';

/// Snapshot data for generating an Account Statement PDF
class AccountStatementData {
  final CustomerModel customer;
  final String marketName;
  final String statementNumber;
  final DateTime generatedAt;
  final double totalDebts;
  final double totalPayments;
  final double remainingDebt;
  final List<TransactionModel> transactions; // Chronologically sorted or formatted

  const AccountStatementData({
    required this.customer,
    this.marketName = 'SAMI MARKET',
    required this.statementNumber,
    required this.generatedAt,
    required this.totalDebts,
    required this.totalPayments,
    required this.remainingDebt,
    required this.transactions,
  });

  bool get isFullyPaid => remainingDebt <= 0.0001;
}
