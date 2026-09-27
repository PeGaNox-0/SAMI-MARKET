import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// =====================
// TABLE DEFINITIONS
// =====================

/// Local customers table — mirrors Supabase customers
class LocalCustomers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get name => text()();
  TextColumn get customerCode => text().withDefault(const Constant('')).named('customer_code')();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get syncStatus => text().withDefault(const Constant('pending')).named('sync_status')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local transactions table — mirrors Supabase transactions
class LocalTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get customerId => text().named('customer_id')();
  TextColumn get type => text()(); // 'debt' or 'payment'
  RealColumn get amount => real()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false)).named('is_deleted')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get syncStatus => text().withDefault(const Constant('pending')).named('sync_status')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue for tracking pending operations
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text().named('table_name')();
  TextColumn get recordId => text().named('record_id')();
  TextColumn get operation => text()(); // 'insert', 'update', 'delete'
  TextColumn get data => text()(); // JSON payload
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  IntColumn get retryCount => integer().withDefault(const Constant(0)).named('retry_count')();
}

/// Local temporary customers table — purely offline, no sync
class LocalTemporaryCustomers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get name => text()();
  RealColumn get debtAmount => real().named('debt_amount')();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

// =====================
// DATABASE
// =====================

@DriftDatabase(tables: [LocalCustomers, LocalTransactions, SyncQueue, LocalTemporaryCustomers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndices();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(localCustomers, localCustomers.customerCode);
          }
          if (from < 3) {
            await m.createTable(localTemporaryCustomers);
          }
          if (from < 4) {
            await m.addColumn(localTemporaryCustomers, localTemporaryCustomers.description);
          }
        },
        beforeOpen: (details) async {
          await _createIndices();
        },
      );

  Future<void> _createIndices() async {
    try {
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tx_customer ON local_transactions(customer_id, is_deleted, created_at DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tx_user ON local_transactions(user_id, is_deleted, created_at DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_cust_user ON local_customers(user_id, is_active);',
      );
    } catch (_) {}
  }

  // =====================
  // CUSTOMER OPERATIONS
  // =====================

  /// Get all active customers for a user, optionally filtered
  Future<List<LocalCustomer>> getCustomers(
    String userId, {
    String? search,
    bool? hasDebt,
  }) async {
    final query = select(localCustomers)
      ..where((c) => c.userId.equals(userId) & c.isActive.equals(true) & c.customerCode.equals('TEMP').not());

    if (search != null && search.isNotEmpty) {
      query.where(
        (c) => c.name.contains(search) | c.phone.contains(search) | c.customerCode.contains(search),
      );
    }

    query.orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.get();
  }

  /// Stream active customers for a user in real-time
  Stream<List<LocalCustomer>> watchCustomers(
    String userId, {
    String? search,
  }) {
    final query = select(localCustomers)
      ..where((c) => c.userId.equals(userId) & c.isActive.equals(true) & c.customerCode.equals('TEMP').not());

    if (search != null && search.isNotEmpty) {
      query.where(
        (c) => c.name.contains(search) | c.phone.contains(search) | c.customerCode.contains(search),
      );
    }

    query.orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.watch();
  }

  /// Stream single customer by ID
  Stream<LocalCustomer?> watchCustomerById(String id) {
    return (select(localCustomers)..where((c) => c.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Stream single customer by ID with live calculated balance (single SQL query)
  Stream<({LocalCustomer customer, double balance})?> watchCustomerWithBalanceById(String id) {
    final query = customSelect(
      'SELECT c.*, '
      'COALESCE((SELECT SUM(CASE WHEN t.type = \'debt\' THEN t.amount ELSE -t.amount END) '
      '          FROM local_transactions t '
      '          WHERE t.customer_id = c.id AND t.is_deleted = 0), 0.0) AS balance '
      'FROM local_customers c '
      'WHERE c.id = ?;',
      variables: [Variable.withString(id)],
      readsFrom: {localCustomers, localTransactions},
    );

    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return (
        customer: localCustomers.map(row.data),
        balance: (row.data['balance'] as num?)?.toDouble() ?? 0.0,
      );
    });
  }

  /// Stream active customers with balance in a single SQL query (No N+1)
  Stream<List<({LocalCustomer customer, double balance})>> watchCustomersWithBalance(
    String userId, {
    String? search,
  }) {
    String searchFilter = '';
    final vars = <Variable>[Variable.withString(userId)];
    if (search != null && search.trim().isNotEmpty) {
      searchFilter = ' AND (c.name LIKE ? OR c.phone LIKE ? OR c.customer_code LIKE ?)';
      final searchPattern = '%${search.trim()}%';
      vars.addAll([
        Variable.withString(searchPattern),
        Variable.withString(searchPattern),
        Variable.withString(searchPattern),
      ]);
    }

    final query = customSelect(
      'SELECT c.*, '
      'COALESCE((SELECT SUM(CASE WHEN t.type = \'debt\' THEN t.amount ELSE -t.amount END) '
      '          FROM local_transactions t '
      '          WHERE t.customer_id = c.id AND t.is_deleted = 0), 0.0) AS balance '
      'FROM local_customers c '
      'WHERE c.user_id = ? AND c.is_active = 1 AND c.customer_code != \'TEMP\''
      '$searchFilter '
      'ORDER BY c.name COLLATE NOCASE ASC;',
      variables: vars,
      readsFrom: {localCustomers, localTransactions},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return (
          customer: localCustomers.map(row.data),
          balance: (row.data['balance'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    });
  }

  /// Get active customers with balance in a single SQL query (Future, No N+1)
  Future<List<({LocalCustomer customer, double balance})>> getCustomersWithBalance(
    String userId, {
    String? search,
  }) async {
    String searchFilter = '';
    final vars = <Variable>[Variable.withString(userId)];
    if (search != null && search.trim().isNotEmpty) {
      searchFilter = ' AND (c.name LIKE ? OR c.phone LIKE ? OR c.customer_code LIKE ?)';
      final searchPattern = '%${search.trim()}%';
      vars.addAll([
        Variable.withString(searchPattern),
        Variable.withString(searchPattern),
        Variable.withString(searchPattern),
      ]);
    }

    final rows = await customSelect(
      'SELECT c.*, '
      'COALESCE((SELECT SUM(CASE WHEN t.type = \'debt\' THEN t.amount ELSE -t.amount END) '
      '          FROM local_transactions t '
      '          WHERE t.customer_id = c.id AND t.is_deleted = 0), 0.0) AS balance '
      'FROM local_customers c '
      'WHERE c.user_id = ? AND c.is_active = 1 AND c.customer_code != \'TEMP\''
      '$searchFilter '
      'ORDER BY c.name COLLATE NOCASE ASC;',
      variables: vars,
      readsFrom: {localCustomers, localTransactions},
    ).get();

    return rows.map((row) {
      return (
        customer: localCustomers.map(row.data),
        balance: (row.data['balance'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Get single customer by ID
  Future<LocalCustomer?> getCustomerById(String id) {
    return (select(localCustomers)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert or update a customer
  Future<void> upsertCustomer(LocalCustomersCompanion customer) {
    return into(localCustomers).insertOnConflictUpdate(customer);
  }

  /// Batch insert or update customers atomically
  Future<void> upsertCustomersBatch(List<LocalCustomersCompanion> customers) {
    if (customers.isEmpty) return Future.value();
    return batch((b) {
      b.insertAllOnConflictUpdate(localCustomers, customers);
    });
  }

  /// Soft-delete a customer
  Future<void> archiveCustomer(String id) {
    return (update(localCustomers)..where((c) => c.id.equals(id))).write(
      LocalCustomersCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Hard-delete a customer and all their transactions from local SQLite
  Future<void> deleteCustomerPermanently(String id) async {
    await (delete(localTransactions)..where((t) => t.customerId.equals(id))).go();
    await (delete(localCustomers)..where((c) => c.id.equals(id))).go();
  }

  // =====================
  // TRANSACTION OPERATIONS
  // =====================

  /// Stream transactions for a customer with optional pagination
  Stream<List<LocalTransaction>> watchTransactionsByCustomer(
    String customerId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    final query = select(localTransactions)
      ..where((t) =>
          t.customerId.equals(customerId) & t.isDeleted.equals(false));

    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    if (startDate != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.watch();
  }

  /// Stream total count of non-deleted transactions for a customer
  Stream<int> watchCustomerTransactionsCount(String customerId) {
    return customSelect(
      'SELECT COUNT(*) as cnt FROM local_transactions WHERE customer_id = ? AND is_deleted = 0',
      variables: [Variable.withString(customerId)],
      readsFrom: {localTransactions},
    ).map((row) => row.read<int>('cnt')).watchSingle();
  }

  /// Stream recent transactions for a user
  Stream<List<LocalTransaction>> watchRecentTransactions(
    String userId, {
    int limit = 10,
  }) {
    return (select(localTransactions)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Stream all non-deleted transactions for a user
  Stream<List<LocalTransaction>> watchAllTransactions(String userId) {
    return (select(localTransactions)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Stream all non-deleted transactions for a user within a specific date range
  Stream<List<LocalTransaction>> watchTransactionsByDateRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return (select(localTransactions)
          ..where((t) =>
              t.userId.equals(userId) &
              t.isDeleted.equals(false) &
              t.createdAt.isBiggerOrEqualValue(startDate) &
              t.createdAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get non-deleted transactions for a user within a specific date range
  Future<List<LocalTransaction>> getTransactionsByDateRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return (select(localTransactions)
          ..where((t) =>
              t.userId.equals(userId) &
              t.isDeleted.equals(false) &
              t.createdAt.isBiggerOrEqualValue(startDate) &
              t.createdAt.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Get transactions for a customer
  Future<List<LocalTransaction>> getTransactionsByCustomer(
    String customerId, {
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final query = select(localTransactions)
      ..where((t) =>
          t.customerId.equals(customerId) & t.isDeleted.equals(false));

    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    if (startDate != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  /// Get recent transactions for a user
  Future<List<LocalTransaction>> getRecentTransactions(
    String userId, {
    int limit = 10,
  }) {
    return (select(localTransactions)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Stream transactions with customer name in date range (Single JOIN query, No N+1)
  Stream<List<({LocalTransaction transaction, String? customerName})>>
      watchTransactionsWithCustomerByDateRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final query = customSelect(
      'SELECT t.*, c.name AS customer_name '
      'FROM local_transactions t '
      'LEFT JOIN local_customers c ON t.customer_id = c.id '
      'WHERE t.user_id = ? '
      '  AND t.is_deleted = 0 '
      '  AND t.created_at >= ? '
      '  AND t.created_at <= ? '
      'ORDER BY t.created_at DESC;',
      variables: [
        Variable.withString(userId),
        Variable<DateTime>(startDate),
        Variable<DateTime>(endDate),
      ],
      readsFrom: {localTransactions, localCustomers},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return (
          transaction: localTransactions.map(row.data),
          customerName: row.data['customer_name'] as String?,
        );
      }).toList();
    });
  }

  /// Stream recent transactions with customer name (Single JOIN query, No N+1)
  Stream<List<({LocalTransaction transaction, String? customerName})>>
      watchRecentTransactionsWithCustomer(
    String userId, {
    int limit = 10,
  }) {
    final query = customSelect(
      'SELECT t.*, c.name AS customer_name '
      'FROM local_transactions t '
      'LEFT JOIN local_customers c ON t.customer_id = c.id '
      'WHERE t.user_id = ? AND t.is_deleted = 0 '
      'ORDER BY t.created_at DESC '
      'LIMIT ?;',
      variables: [
        Variable.withString(userId),
        Variable<int>(limit),
      ],
      readsFrom: {localTransactions, localCustomers},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return (
          transaction: localTransactions.map(row.data),
          customerName: row.data['customer_name'] as String?,
        );
      }).toList();
    });
  }

  /// Get recent transactions with customer name (Future, Single JOIN query, No N+1)
  Future<List<({LocalTransaction transaction, String? customerName})>>
      getRecentTransactionsWithCustomer(
    String userId, {
    int limit = 10,
  }) async {
    final rows = await customSelect(
      'SELECT t.*, c.name AS customer_name '
      'FROM local_transactions t '
      'LEFT JOIN local_customers c ON t.customer_id = c.id '
      'WHERE t.user_id = ? AND t.is_deleted = 0 '
      'ORDER BY t.created_at DESC '
      'LIMIT ?;',
      variables: [
        Variable.withString(userId),
        Variable<int>(limit),
      ],
      readsFrom: {localTransactions, localCustomers},
    ).get();

    return rows.map((row) {
      return (
        transaction: localTransactions.map(row.data),
        customerName: row.data['customer_name'] as String?,
      );
    }).toList();
  }

  /// Insert or update a transaction
  Future<void> upsertTransaction(LocalTransactionsCompanion transaction) {
    return into(localTransactions).insertOnConflictUpdate(transaction);
  }

  /// Batch insert or update transactions atomically
  Future<void> upsertTransactionsBatch(List<LocalTransactionsCompanion> transactions) {
    if (transactions.isEmpty) return Future.value();
    return batch((b) {
      b.insertAllOnConflictUpdate(localTransactions, transactions);
    });
  }

  /// Soft-delete a transaction
  Future<void> softDeleteTransaction(String id) {
    return (update(localTransactions)..where((t) => t.id.equals(id))).write(
      LocalTransactionsCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Permanently delete a transaction from local SQLite
  Future<void> deleteTransactionPermanently(String id) {
    return (delete(localTransactions)..where((t) => t.id.equals(id))).go();
  }

  /// Calculate customer balance from transactions (instant SQL aggregation with index)
  Future<double> getCustomerBalance(String customerId) async {
    try {
      final result = await customSelect(
        'SELECT COALESCE(SUM(CASE WHEN type = \'debt\' THEN amount ELSE -amount END), 0.0) AS balance '
        'FROM local_transactions '
        'WHERE customer_id = ? AND is_deleted = 0;',
        variables: [Variable.withString(customerId)],
        readsFrom: {localTransactions},
      ).getSingle();

      return (result.data['balance'] as num).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  /// Get total outstanding debt for a user (instant SQL aggregation with index)
  Future<double> getTotalOutstandingDebt(String userId) async {
    try {
      final result = await customSelect(
        'SELECT COALESCE(SUM(CASE WHEN type = \'debt\' THEN amount ELSE -amount END), 0.0) AS total '
        'FROM local_transactions '
        'WHERE user_id = ? AND is_deleted = 0;',
        variables: [Variable.withString(userId)],
        readsFrom: {localTransactions},
      ).getSingle();

      final total = (result.data['total'] as num).toDouble();
      return total > 0 ? total : 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Get customers with debt count (instant SQL aggregation)
  Future<int> getCustomersWithDebtCount(String userId) async {
    try {
      final result = await customSelect(
        'SELECT COUNT(*) AS cnt FROM ('
        '  SELECT customer_id FROM local_transactions '
        '  WHERE user_id = ? AND is_deleted = 0 '
        '  GROUP BY customer_id '
        '  HAVING SUM(CASE WHEN type = \'debt\' THEN amount ELSE -amount END) > 0'
        ');',
        variables: [Variable.withString(userId)],
        readsFrom: {localTransactions},
      ).getSingle();

      return (result.data['cnt'] as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  /// Get today's stats
  Future<Map<String, double>> getTodayStats(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final transactions = await (select(localTransactions)
          ..where((t) =>
              t.userId.equals(userId) &
              t.isDeleted.equals(false) &
              t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay)))
        .get();

    double debtsToday = 0;
    double paymentsToday = 0;

    for (final t in transactions) {
      if (t.type == 'debt') {
        debtsToday += t.amount;
      } else {
        paymentsToday += t.amount;
      }
    }

    return {
      'debts_today': debtsToday,
      'payments_today': paymentsToday,
    };
  }

  // =====================
  // SYNC QUEUE OPERATIONS
  // =====================

  /// Add to sync queue
  Future<void> addToSyncQueue(SyncQueueCompanion entry) {
    return into(syncQueue).insert(entry);
  }

  /// Get pending sync items
  Future<List<SyncQueueData>> getPendingSyncItems() {
    return (select(syncQueue)
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)])
          ..limit(50))
        .get();
  }

  /// Remove synced item from queue
  Future<void> removeSyncItem(int id) {
    return (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Get pending sync count
  Future<int> getPendingSyncCount() async {
    final queueItems = await (select(syncQueue)).get();
    final pendingTx = await (select(localTransactions)..where((t) => t.syncStatus.equals('pending'))).get();
    final pendingCust = await (select(localCustomers)..where((c) => c.syncStatus.equals('pending'))).get();
    return queueItems.length + pendingTx.length + pendingCust.length;
  }

  /// Get all local transactions with sync_status = 'pending'
  Future<List<LocalTransaction>> getPendingTransactions() {
    return (select(localTransactions)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Get all local customers with sync_status = 'pending'
  Future<List<LocalCustomer>> getPendingCustomers() {
    return (select(localCustomers)..where((c) => c.syncStatus.equals('pending'))).get();
  }

  /// Mark records as synced
  Future<void> markCustomerSynced(String id) {
    return (update(localCustomers)..where((c) => c.id.equals(id))).write(
      const LocalCustomersCompanion(syncStatus: Value('synced')),
    );
  }

  Future<void> markTransactionSynced(String id) {
    return (update(localTransactions)..where((t) => t.id.equals(id))).write(
      const LocalTransactionsCompanion(syncStatus: Value('synced')),
    );
  }

  // =====================
  // BACKUP / RESTORE
  // =====================

  /// Export all data as maps for backup
  Future<Map<String, dynamic>> exportAllData(String userId) async {
    final customers = await (select(localCustomers)
          ..where((c) => c.userId.equals(userId)))
        .get();
    final transactions = await (select(localTransactions)
          ..where((t) => t.userId.equals(userId)))
        .get();

    return {
      'customers': customers
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'phone': c.phone,
                'address': c.address,
                'notes': c.notes,
                'is_active': c.isActive,
                'created_at': c.createdAt.toIso8601String(),
                'updated_at': c.updatedAt.toIso8601String(),
              })
          .toList(),
      'transactions': transactions
          .map((t) => {
                'id': t.id,
                'customer_id': t.customerId,
                'type': t.type,
                'amount': t.amount,
                'description': t.description,
                'is_deleted': t.isDeleted,
                'created_at': t.createdAt.toIso8601String(),
                'updated_at': t.updatedAt.toIso8601String(),
                'deleted_at': t.deletedAt?.toIso8601String(),
              })
          .toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // =====================
  // TEMPORARY CUSTOMER OPERATIONS
  // =====================

  Stream<List<LocalCustomer>> watchTemporaryCustomers(String userId) {
    return (select(localCustomers)
          ..where((c) => c.userId.equals(userId) & c.customerCode.equals('TEMP') & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
        .watch();
  }

  /// Stream temporary customers with live calculated balance (single SQL query, No N+1)
  Stream<List<({LocalCustomer customer, double balance})>> watchTemporaryCustomersWithBalance(String userId) {
    final query = customSelect(
      'SELECT c.*, '
      'COALESCE((SELECT SUM(CASE WHEN t.type = \'debt\' THEN t.amount ELSE -t.amount END) '
      '          FROM local_transactions t '
      '          WHERE t.customer_id = c.id AND t.is_deleted = 0), 0.0) AS balance '
      'FROM local_customers c '
      'WHERE c.user_id = ? AND c.customer_code = \'TEMP\' AND c.is_active = 1 '
      'ORDER BY c.created_at DESC;',
      variables: [Variable.withString(userId)],
      readsFrom: {localCustomers, localTransactions},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return (
          customer: localCustomers.map(row.data),
          balance: (row.data['balance'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    });
  }

  Future<List<LocalCustomer>> getTemporaryCustomers(String userId) {
    return (select(localCustomers)
          ..where((c) => c.userId.equals(userId) & c.customerCode.equals('TEMP') & c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
        .get();
  }

  Future<void> addTemporaryCustomer(LocalTemporaryCustomersCompanion customer) {
    return into(localTemporaryCustomers).insert(customer);
  }

  Future<void> updateTemporaryCustomer({
    required String id,
    required String name,
    required String description,
  }) {
    return (update(localTemporaryCustomers)..where((c) => c.id.equals(id)))
        .write(LocalTemporaryCustomersCompanion(
          name: Value(name),
          description: Value(description),
        ));
  }

  Future<void> deleteTemporaryCustomer(String id) {
    return (delete(localTemporaryCustomers)..where((c) => c.id.equals(id))).go();
  }

  Future<List<String>> getOrphanedTransactionIds() async {
    final rows = await customSelect(
      'SELECT id FROM local_transactions WHERE customer_id NOT IN (SELECT id FROM local_customers);'
    ).get();
    return rows.map((row) => row.read<String>('id')).toList();
  }

  Future<void> deleteOrphanedTransactions() async {
    await customStatement(
      'DELETE FROM local_transactions WHERE customer_id NOT IN (SELECT id FROM local_customers);'
    );
  }

  Future<void> fixOldTransactionsTimezones() async {
    await customStatement(
      'UPDATE local_transactions SET created_at = created_at - 10800, updated_at = updated_at - 10800;'
    );
    await customStatement(
      'UPDATE local_transactions SET deleted_at = deleted_at - 10800 WHERE deleted_at IS NOT NULL;'
    );
  }
}

// =====================
// DATABASE CONNECTION
// =====================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'omar_app.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        rawDb.execute('PRAGMA journal_mode = WAL;');
        rawDb.execute('PRAGMA synchronous = NORMAL;');
        rawDb.execute('PRAGMA temp_store = MEMORY;');
        rawDb.execute('PRAGMA cache_size = -64000;');
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}

/// Provider for the local database
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
