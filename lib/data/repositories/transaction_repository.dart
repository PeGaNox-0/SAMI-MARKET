import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../datasources/local/app_database.dart';
import '../models/transaction_model.dart';
import '../models/daily_report_model.dart';
import '../../core/services/sync_service.dart';

/// Transaction repository — offline-first with reactive Drift streams & Supabase sync
class TransactionRepository {
  final AppDatabase _db;
  final SyncService? _syncService;
  static const _uuid = Uuid();

  TransactionRepository(this._db, [this._syncService]);

  /// Stream transactions for a customer in real-time with optional pagination
  Stream<List<TransactionModel>> watchTransactionsByCustomer(
    String customerId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return _db
        .watchTransactionsByCustomer(
          customerId,
          type: type,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
          offset: offset,
        )
        .map((transactions) => transactions
            .map((t) => TransactionModel(
                  id: t.id,
                  userId: t.userId,
                  customerId: t.customerId,
                  type: t.type,
                  amount: t.amount,
                  description: t.description,
                  isDeleted: t.isDeleted,
                  createdAt: t.createdAt,
                  updatedAt: t.updatedAt,
                  deletedAt: t.deletedAt,
                ))
            .toList());
  }

  /// Stream total count of transactions for a customer
  Stream<int> watchCustomerTransactionsCount(String customerId) {
    return _db.watchCustomerTransactionsCount(customerId);
  }

  /// Stream recent transactions for dashboard (Single JOIN query, No N+1)
  Stream<List<TransactionModel>> watchRecentTransactions(
    String userId, {
    int limit = 10,
  }) {
    return _db.watchRecentTransactionsWithCustomer(userId, limit: limit).map((rows) {
      return rows.map((item) {
        final t = item.transaction;
        return TransactionModel(
          id: t.id,
          userId: t.userId,
          customerId: t.customerId,
          type: t.type,
          amount: t.amount,
          description: t.description,
          isDeleted: t.isDeleted,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
          deletedAt: t.deletedAt,
          customerName: item.customerName,
        );
      }).toList();
    });
  }

  /// Stream all transactions for a user
  Stream<List<TransactionModel>> watchAllTransactions(String userId) {
    return _db.watchAllTransactions(userId).map((transactions) => transactions
        .map((t) => TransactionModel(
              id: t.id,
              userId: t.userId,
              customerId: t.customerId,
              type: t.type,
              amount: t.amount,
              description: t.description,
              isDeleted: t.isDeleted,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
              deletedAt: t.deletedAt,
            ))
        .toList());
  }

  /// Stream dashboard statistics live
  Stream<Map<String, dynamic>> watchDashboardStats(String userId) {
    return _db.watchAllTransactions(userId).asyncMap((_) async {
      final totalDebt = await _db.getTotalOutstandingDebt(userId);
      final customersWithDebt = await _db.getCustomersWithDebtCount(userId);
      final todayStats = await _db.getTodayStats(userId);
      final recentTransactions = await getRecentTransactions(userId, limit: 10);

      return {
        'total_debt': totalDebt,
        'customers_with_debt': customersWithDebt,
        'payments_today': todayStats['payments_today'] ?? 0.0,
        'debts_today': todayStats['debts_today'] ?? 0.0,
        'recent_transactions': recentTransactions,
      };
    });
  }

  /// Stream customer balance
  Stream<double> watchCustomerBalance(String customerId) {
    return _db
        .watchTransactionsByCustomer(customerId)
        .map((transactions) {
      double totalDebt = 0;
      double totalPayments = 0;
      for (final t in transactions) {
        if (t.type == 'debt') {
          totalDebt += t.amount;
        } else {
          totalPayments += t.amount;
        }
      }
      return totalDebt - totalPayments;
    });
  }

  /// Get transactions for a customer (Future)
  Future<List<TransactionModel>> getTransactionsByCustomer(
    String customerId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final transactions = await _db.getTransactionsByCustomer(
      customerId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );

    return transactions
        .map((t) => TransactionModel(
              id: t.id,
              userId: t.userId,
              customerId: t.customerId,
              type: t.type,
              amount: t.amount,
              description: t.description,
              isDeleted: t.isDeleted,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
              deletedAt: t.deletedAt,
            ))
        .toList();
  }

  /// Get recent transactions for dashboard (Future, Single JOIN query, No N+1)
  Future<List<TransactionModel>> getRecentTransactions(
    String userId, {
    int limit = 10,
  }) async {
    final rows = await _db.getRecentTransactionsWithCustomer(userId, limit: limit);
    return rows.map((item) {
      final t = item.transaction;
      return TransactionModel(
        id: t.id,
        userId: t.userId,
        customerId: t.customerId,
        type: t.type,
        amount: t.amount,
        description: t.description,
        isDeleted: t.isDeleted,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
        deletedAt: t.deletedAt,
        customerName: item.customerName,
      );
    }).toList();
  }

  /// Add a debt transaction
  Future<TransactionModel> addDebt({
    required String userId,
    required String customerId,
    required double amount,
    String description = '',
    DateTime? date,
  }) async {
    return _addTransaction(
      userId: userId,
      customerId: customerId,
      type: 'debt',
      amount: amount,
      description: description,
      date: date,
    );
  }

  /// Add a payment transaction
  Future<TransactionModel> addPayment({
    required String userId,
    required String customerId,
    required double amount,
    String description = '',
    DateTime? date,
  }) async {
    return _addTransaction(
      userId: userId,
      customerId: customerId,
      type: 'payment',
      amount: amount,
      description: description,
      date: date,
    );
  }

  Future<TransactionModel> _addTransaction({
    required String userId,
    required String customerId,
    required String type,
    required double amount,
    String description = '',
    DateTime? date,
  }) async {
    final id = _uuid.v4();
    final now = date ?? DateTime.now();

    final transaction = TransactionModel(
      id: id,
      userId: userId,
      customerId: customerId,
      type: type,
      amount: amount,
      description: description,
      createdAt: now,
      updatedAt: now,
    );

    final payload = transaction.toJson();
    payload.remove('customer_name');
    bool directSynced = false;

    // 1. Direct Instant Cloud Sync: push directly to Supabase if online
    try {
      await Supabase.instance.client.from('transactions').upsert(payload);
      directSynced = true;
    } catch (_) {}

    // 2. Save locally with appropriate sync status
    await _db.upsertTransaction(LocalTransactionsCompanion.insert(
      id: id,
      userId: userId,
      customerId: customerId,
      type: type,
      amount: amount,
      description: Value(description),
      createdAt: now,
      updatedAt: now,
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    // 3. Fallback: if direct sync failed, queue for background sync
    if (!directSynced) {
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'transactions',
        recordId: id,
        operation: 'insert',
        data: jsonEncode(payload),
        createdAt: DateTime.now(),
      ));
      _syncService?.syncPendingChanges();
    }

    return transaction;
  }

  /// Edit a transaction
  Future<void> editTransaction({
    required String id,
    required double newAmount,
    required String newDescription,
  }) async {
    final now = DateTime.now();

    final existing = await _db.getRecentTransactions('', limit: 1000);
    final tx = existing.where((t) => t.id == id).firstOrNull;
    if (tx == null) return;

    final payload = {
      'id': id,
      'amount': newAmount,
      'description': newDescription,
      'updated_at': now.toUtc().toIso8601String(),
    };
    bool directSynced = false;

    try {
      await Supabase.instance.client
          .from('transactions')
          .update(payload)
          .eq('id', id);
      directSynced = true;
    } catch (_) {}

    await _db.upsertTransaction(LocalTransactionsCompanion(
      id: Value(id),
      userId: Value(tx.userId),
      customerId: Value(tx.customerId),
      type: Value(tx.type),
      amount: Value(newAmount),
      description: Value(newDescription),
      isDeleted: Value(tx.isDeleted),
      createdAt: Value(tx.createdAt),
      updatedAt: Value(now),
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    if (!directSynced) {
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'transactions',
        recordId: id,
        operation: 'update',
        data: jsonEncode(payload),
        createdAt: now,
      ));
      _syncService?.syncPendingChanges();
    }
  }

  /// Soft-delete a transaction
  Future<void> deleteTransaction(String id) async {
    final now = DateTime.now();
    await _db.softDeleteTransaction(id);

    bool directSynced = false;
    try {
      await Supabase.instance.client.from('transactions').update({
        'is_deleted': true,
        'deleted_at': now.toUtc().toIso8601String(),
      }).eq('id', id);
      directSynced = true;
      await _db.markTransactionSynced(id);
    } catch (_) {}

    if (!directSynced) {
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'transactions',
        recordId: id,
        operation: 'delete',
        data: jsonEncode({
          'id': id,
          'is_deleted': true,
          'deleted_at': now.toUtc().toIso8601String(),
        }),
        createdAt: now,
      ));
      _syncService?.syncPendingChanges();
    }
  }

  /// Get customer balance (calculated from transactions)
  Future<double> getCustomerBalance(String customerId) {
    return _db.getCustomerBalance(customerId);
  }

  /// Get total outstanding debt for user
  Future<double> getTotalOutstandingDebt(String userId) {
    return _db.getTotalOutstandingDebt(userId);
  }

  /// Get customers with debt count
  Future<int> getCustomersWithDebtCount(String userId) {
    return _db.getCustomersWithDebtCount(userId);
  }

  /// Get today's stats
  Future<Map<String, double>> getTodayStats(String userId) {
    return _db.getTodayStats(userId);
  }

  /// Get report data for a date range
  Future<Map<String, double>> getReportData(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _db.getRecentTransactions(userId, limit: 100000);

    double totalDebt = 0;
    double totalPayments = 0;

    for (final t in transactions) {
      if (t.isDeleted) continue;
      if (t.createdAt.isBefore(startDate) || t.createdAt.isAfter(endDate)) continue;

      if (t.type == 'debt') {
        totalDebt += t.amount;
      } else {
        totalPayments += t.amount;
      }
    }

    return {
      'total_debt': totalDebt,
      'total_payments': totalPayments,
      'outstanding': totalDebt - totalPayments,
    };
  }

  /// Stream full daily report with transactions for a specific date range (Single JOIN query, No N+1)
  Stream<DailyReportModel> watchDailyReport(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _db
        .watchTransactionsWithCustomerByDateRange(
          userId,
          startDate: startDate,
          endDate: endDate,
        )
        .map((rows) {
      double totalDebt = 0.0;
      double totalPayments = 0.0;
      int debtsCount = 0;
      int paymentsCount = 0;
      final uniqueCustomerIds = <String>{};
      final list = <TransactionModel>[];

      for (final item in rows) {
        final t = item.transaction;
        if (t.type == 'debt') {
          totalDebt += t.amount;
          debtsCount++;
        } else {
          totalPayments += t.amount;
          paymentsCount++;
        }
        uniqueCustomerIds.add(t.customerId);

        list.add(TransactionModel(
          id: t.id,
          userId: t.userId,
          customerId: t.customerId,
          type: t.type,
          amount: t.amount,
          description: t.description,
          isDeleted: t.isDeleted,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
          deletedAt: t.deletedAt,
          customerName: item.customerName,
        ));
      }

      return DailyReportModel(
        startDate: startDate,
        endDate: endDate,
        totalDebt: totalDebt,
        totalPayments: totalPayments,
        netBalance: totalDebt - totalPayments,
        debtsCount: debtsCount,
        paymentsCount: paymentsCount,
        uniqueCustomersCount: uniqueCustomerIds.length,
        transactions: list,
      );
    });
  }
}

/// Provider for transaction repository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  return TransactionRepository(db, syncService);
});
