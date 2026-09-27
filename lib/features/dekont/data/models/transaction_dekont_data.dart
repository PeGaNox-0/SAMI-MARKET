import '../../../../data/models/customer_model.dart';
import '../../../../data/models/transaction_model.dart';

/// Snapshot data for generating a single Transaction Dekont / Receipt PDF
class TransactionDekontData {
  final CustomerModel customer;
  final TransactionModel transaction;
  final String marketName;
  final String referenceNumber;
  final double beforeBalance;
  final double afterBalance;

  const TransactionDekontData({
    required this.customer,
    required this.transaction,
    this.marketName = 'SAMI MARKET',
    required this.referenceNumber,
    required this.beforeBalance,
    required this.afterBalance,
  });

  bool get isDebt => transaction.isDebt;
  bool get isPayment => transaction.isPayment;
}
