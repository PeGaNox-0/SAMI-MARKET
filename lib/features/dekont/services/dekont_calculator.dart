import '../../../../data/models/customer_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../data/models/account_statement_data.dart';
import '../data/models/transaction_dekont_data.dart';

/// Calculation engine for generating accurate Account Statements and Transaction Dekonts
class DekontCalculator {
  DekontCalculator._();

  /// Build an AccountStatementData snapshot from customer and transaction list
  static AccountStatementData buildStatementData({
    required CustomerModel customer,
    required List<TransactionModel> transactions,
    String marketName = 'SAMI MARKET',
    DateTime? timestamp,
  }) {
    final activeTx = transactions.where((t) => !t.isDeleted).toList();

    // Sort newest first for statement display
    activeTx.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    double totalDebts = 0.0;
    double totalPayments = 0.0;

    for (final t in activeTx) {
      if (t.isDebt) {
        totalDebts += t.amount;
      } else if (t.isPayment) {
        totalPayments += t.amount;
      }
    }

    final remainingDebt = totalDebts - totalPayments;
    final now = timestamp ?? DateTime.now();

    // Stable, clean reference number
    final code = customer.customerCode.isNotEmpty
        ? customer.customerCode
        : customer.id.replaceAll('-', '').substring(0, 6).toUpperCase();
    final timeHex = (now.millisecondsSinceEpoch ~/ 1000).toRadixString(16).toUpperCase();
    final statementNumber = 'STM-$code-$timeHex';

    return AccountStatementData(
      customer: customer,
      marketName: marketName,
      statementNumber: statementNumber,
      generatedAt: now,
      totalDebts: totalDebts,
      totalPayments: totalPayments,
      remainingDebt: remainingDebt,
      transactions: activeTx,
    );
  }

  /// Build a TransactionDekontData snapshot with mathematically computed before/after balances
  static TransactionDekontData buildTransactionDekontData({
    required CustomerModel customer,
    required TransactionModel targetTransaction,
    required List<TransactionModel> allTransactions,
    String marketName = 'SAMI MARKET',
  }) {
    // 1. Filter out deleted transactions
    final activeList = allTransactions.where((t) => !t.isDeleted).toList();

    // 2. Ensure target is in list if not already present
    if (!activeList.any((t) => t.id == targetTransaction.id)) {
      activeList.add(targetTransaction);
    }

    // 3. Sort chronologically (oldest first) with deterministic ID tie-breaker
    activeList.sort((a, b) {
      final cmp = a.createdAt.compareTo(b.createdAt);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

    // 4. Compute running balance before targetTransaction
    double runningBalance = 0.0;

    for (final t in activeList) {
      if (t.id == targetTransaction.id) {
        break; // Stop at target
      }
      if (t.isDebt) {
        runningBalance += t.amount;
      } else if (t.isPayment) {
        runningBalance -= t.amount;
      }
    }

    final beforeBalance = runningBalance;
    final afterBalance = targetTransaction.isDebt
        ? beforeBalance + targetTransaction.amount
        : beforeBalance - targetTransaction.amount;

    // Stable transaction reference derived from the UUID
    final cleanId = targetTransaction.id.replaceAll('-', '').toUpperCase();
    final refSuffix = cleanId.length >= 8 ? cleanId.substring(0, 8) : cleanId;
    final referenceNumber = 'TXN-$refSuffix';

    return TransactionDekontData(
      customer: customer,
      transaction: targetTransaction,
      marketName: marketName,
      referenceNumber: referenceNumber,
      beforeBalance: beforeBalance,
      afterBalance: afterBalance,
    );
  }
}
