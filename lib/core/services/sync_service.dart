import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/local/app_database.dart';
import 'connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync service — Bidirectional Realtime Sync between Supabase and local SQLite
class SyncService {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  final ConnectivityService _connectivity;

  Timer? _retryTimer;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  RealtimeChannel? _customersChannel;
  RealtimeChannel? _transactionsChannel;

  bool _isSyncing = false;
  String? _activeUserId;

  SyncService(this._db, this._supabase, this._connectivity);

  /// Helper to safely parse numeric values from Postgres (which can arrive as String, num, or null)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Start listening for connectivity changes and sync when online
  void startListening([String? userId]) {
    _fixLocalTimezonesOnce();

    _connectivity.onConnectivityChanged.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        syncPendingChanges();
        if (_activeUserId != null) {
          pullFromCloud(_activeUserId!);
        }
      }
    });

    if (userId != null) {
      startRealtimeSync(userId);
    }
  }

  Future<void> _fixLocalTimezonesOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFixed = prefs.getBool('timezone_fixed_v2') ?? false;
      if (!isFixed) {
        debugPrint('SyncService: Running one-time timezone correction for transactions...');
        await _db.deleteOrphanedTransactions();
        await _db.fixOldTransactionsTimezones();
        await prefs.setBool('timezone_fixed_v2', true);
        debugPrint('SyncService: Timezone correction completed.');
      }
    } catch (e) {
      debugPrint('SyncService: Error correcting timezones: $e');
    }
  }

  /// Start Realtime subscription for the authenticated market owner
  void startRealtimeSync(String userId) {
    _activeUserId = userId;

    // 1. Initial pull to synchronize state immediately
    pullFromCloud(userId);

    // 2. Setup periodic bidirectional sync heartbeat (push pending + pull inbound) every 15s
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_activeUserId != null) {
        await syncPendingChanges();
        await pullFromCloud(_activeUserId!);
      }
    });

    // 3. Setup realtime channels with auto-reconnection
    _setupCustomersChannel(userId);
    _setupTransactionsChannel(userId);
  }

  void _setupCustomersChannel(String userId) {
    try {
      _customersChannel?.unsubscribe();
      _customersChannel = _supabase
          .channel('public:realtime_customers:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'customers',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) async {
              try {
                if (payload.eventType == PostgresChangeEvent.delete) {
                  final oldRecord = payload.oldRecord;
                  final id = oldRecord['id'] as String?;
                  if (id != null) {
                    await _db.deleteCustomerPermanently(id);
                  }
                } else {
                  final record = payload.newRecord;
                  if (record.isNotEmpty) {
                    await _db.upsertCustomer(LocalCustomersCompanion.insert(
                      id: record['id'] as String,
                      userId: record['user_id'] as String,
                      name: record['name'] as String,
                      customerCode: Value(record['customer_code'] as String? ?? ''),
                      phone: Value(record['phone'] as String? ?? ''),
                      address: Value(record['address'] as String? ?? ''),
                      notes: Value(record['notes'] as String? ?? ''),
                      isActive: Value((record['is_active'] as bool?) ?? true),
                      createdAt: DateTime.parse(record['created_at'] as String).toLocal(),
                      updatedAt: DateTime.parse(record['updated_at'] as String).toLocal(),
                      syncStatus: const Value('synced'),
                    ));
                  }
                }
              } catch (e) {
                debugPrint('Realtime customer change error: $e');
              }
            },
          )
          .subscribe((status, error) {
            debugPrint('Realtime customers channel status: $status (error: $error)');
            if (status == RealtimeSubscribeStatus.closed ||
                status == RealtimeSubscribeStatus.channelError ||
                status == RealtimeSubscribeStatus.timedOut) {
              _scheduleChannelReconnect();
            }
          });
    } catch (e) {
      debugPrint('Realtime customer channel subscription error: $e');
    }
  }

  void _setupTransactionsChannel(String userId) {
    try {
      _transactionsChannel?.unsubscribe();
      _transactionsChannel = _supabase
          .channel('public:realtime_transactions:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'transactions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) async {
              try {
                if (payload.eventType == PostgresChangeEvent.delete) {
                  final oldRecord = payload.oldRecord;
                  final id = oldRecord['id'] as String?;
                  if (id != null) {
                    await _db.deleteTransactionPermanently(id);
                  }
                } else {
                  final record = payload.newRecord;
                  if (record.isNotEmpty) {
                    await _db.upsertTransaction(LocalTransactionsCompanion.insert(
                      id: record['id'] as String,
                      userId: record['user_id'] as String,
                      customerId: record['customer_id'] as String,
                      type: record['type'] as String,
                      amount: _parseDouble(record['amount']),
                      description: Value(record['description'] as String? ?? ''),
                      isDeleted: Value((record['is_deleted'] as bool?) ?? false),
                      createdAt: DateTime.parse(record['created_at'] as String).toLocal(),
                      updatedAt: DateTime.parse(record['updated_at'] as String).toLocal(),
                      deletedAt: Value(record['deleted_at'] != null
                          ? DateTime.parse(record['deleted_at'] as String).toLocal()
                          : null),
                      syncStatus: const Value('synced'),
                    ));
                  }
                }
              } catch (e) {
                debugPrint('Realtime transaction change error: $e');
              }
            },
          )
          .subscribe((status, error) {
            debugPrint('Realtime transactions channel status: $status (error: $error)');
            if (status == RealtimeSubscribeStatus.closed ||
                status == RealtimeSubscribeStatus.channelError ||
                status == RealtimeSubscribeStatus.timedOut) {
              _scheduleChannelReconnect();
            }
          });
    } catch (e) {
      debugPrint('Realtime transaction channel subscription error: $e');
    }
  }

  void _scheduleChannelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (_activeUserId != null) {
        debugPrint('SyncService: Reconnecting realtime channels for user: $_activeUserId');
        _setupCustomersChannel(_activeUserId!);
        _setupTransactionsChannel(_activeUserId!);
      }
    });
  }

  /// Called when the app is resumed (e.g. from background or screen unlock)
  void handleAppResumed() {
    if (_activeUserId == null) return;
    debugPrint('SyncService: App resumed from background. Triggering instant sync...');
    pullFromCloud(_activeUserId!);
    syncPendingChanges();
    _setupCustomersChannel(_activeUserId!);
    _setupTransactionsChannel(_activeUserId!);
  }

  /// Push all pending local changes to Supabase
  Future<void> syncPendingChanges() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final isOnline = await _connectivity.isConnected;
      if (!isOnline) {
        _isSyncing = false;
        return;
      }

      // Sync pending customers
      await _syncCustomers();
      // Sync pending transactions
      await _syncTransactions();

      _retryTimer?.cancel();
    } catch (e) {
      // Schedule retry
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 30), syncPendingChanges);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncCustomers() async {
    // 1. Process items from syncQueue
    while (true) {
      final pendingQueue = await _db.getPendingSyncItems();
      final customerItems = pendingQueue.where((i) => i.entityTable == 'customers').toList();
      if (customerItems.isEmpty) break;

      for (final item in customerItems) {
        try {
          final data = jsonDecode(item.data) as Map<String, dynamic>;
          data.remove('balance'); // Ensure calculated fields are not sent

          switch (item.operation) {
            case 'insert':
              await _supabase.from('customers').upsert(data);
              break;
            case 'update':
              await _supabase
                  .from('customers')
                  .update(data)
                  .eq('id', item.recordId);
              break;
            case 'delete':
              await _supabase
                  .from('customers')
                  .update({'is_active': false})
                  .eq('id', item.recordId);
              break;
          }

          await _db.markCustomerSynced(item.recordId);
          await _db.removeSyncItem(item.id);
        } catch (e) {
          debugPrint('Sync customer error for ${item.recordId}: $e');
          break;
        }
      }
    }

    // 2. Safety scan: push any local customers still marked 'pending'
    try {
      final pendingLocal = await _db.getPendingCustomers();
      for (final c in pendingLocal) {
        final payload = {
          'id': c.id,
          'user_id': c.userId,
          'name': c.name,
          'customer_code': c.customerCode,
          'phone': c.phone,
          'address': c.address,
          'notes': c.notes,
          'is_active': c.isActive,
          'created_at': c.createdAt.toUtc().toIso8601String(),
          'updated_at': c.updatedAt.toUtc().toIso8601String(),
        };
        await _supabase.from('customers').upsert(payload);
        await _db.markCustomerSynced(c.id);
      }
    } catch (e) {
      debugPrint('Safety sync customers error: $e');
    }
  }

  Future<void> _syncTransactions() async {
    // 1. Process items from syncQueue
    while (true) {
      final pendingQueue = await _db.getPendingSyncItems();
      final txItems = pendingQueue.where((i) => i.entityTable == 'transactions').toList();
      if (txItems.isEmpty) break;

      for (final item in txItems) {
        try {
          final data = jsonDecode(item.data) as Map<String, dynamic>;
          data.remove('customer_name'); // Ensure display-only fields are not sent

          switch (item.operation) {
            case 'insert':
              await _supabase.from('transactions').upsert(data);
              break;
            case 'update':
              await _supabase
                  .from('transactions')
                  .update(data)
                  .eq('id', item.recordId);
              break;
            case 'delete':
              await _supabase
                  .from('transactions')
                  .update({
                    'is_deleted': true,
                    'deleted_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', item.recordId);
              break;
          }

          await _db.markTransactionSynced(item.recordId);
          await _db.removeSyncItem(item.id);
        } catch (e) {
          debugPrint('Sync transaction error for ${item.recordId}: $e');
          break;
        }
      }
    }

    // 2. Safety scan: push any local transactions still marked 'pending'
    try {
      final pendingTx = await _db.getPendingTransactions();
      for (final t in pendingTx) {
        final payload = {
          'id': t.id,
          'user_id': t.userId,
          'customer_id': t.customerId,
          'type': t.type,
          'amount': t.amount,
          'description': t.description,
          'is_deleted': t.isDeleted,
          'created_at': t.createdAt.toUtc().toIso8601String(),
          'updated_at': t.updatedAt.toUtc().toIso8601String(),
          if (t.deletedAt != null) 'deleted_at': t.deletedAt!.toUtc().toIso8601String(),
        };
        await _supabase.from('transactions').upsert(payload);
        await _db.markTransactionSynced(t.id);
      }
    } catch (e) {
      debugPrint('Safety sync transactions error: $e');
    }
  }

  /// Pull latest data from Supabase (merges into local SQLite with full pagination)
  Future<void> pullFromCloud(String userId) async {
    try {
      final isOnline = await _connectivity.isConnected;
      if (!isOnline) return;

      const int batchSize = 1000;

      // 1. Pull ALL customers with pagination
      int custOffset = 0;
      while (true) {
        final customers = await _supabase
            .from('customers')
            .select()
            .eq('user_id', userId)
            .order('created_at')
            .range(custOffset, custOffset + batchSize - 1);

        if (customers.isEmpty) break;

        final customerCompanions = customers.map((c) => LocalCustomersCompanion.insert(
          id: c['id'] as String,
          userId: c['user_id'] as String,
          name: c['name'] as String,
          customerCode: Value(c['customer_code'] as String? ?? ''),
          phone: Value(c['phone'] as String? ?? ''),
          address: Value(c['address'] as String? ?? ''),
          notes: Value(c['notes'] as String? ?? ''),
          isActive: Value(c['is_active'] as bool? ?? true),
          createdAt: DateTime.parse(c['created_at'] as String).toLocal(),
          updatedAt: DateTime.parse(c['updated_at'] as String).toLocal(),
          syncStatus: const Value('synced'),
        )).toList();

        await _db.upsertCustomersBatch(customerCompanions);

        if (customers.length < batchSize) break;
        custOffset += batchSize;
      }

      // 2. Pull ALL transactions with pagination
      int txOffset = 0;
      while (true) {
        final transactions = await _supabase
            .from('transactions')
            .select()
            .eq('user_id', userId)
            .order('created_at')
            .range(txOffset, txOffset + batchSize - 1);

        if (transactions.isEmpty) break;

        final transactionCompanions = transactions.map((t) => LocalTransactionsCompanion.insert(
          id: t['id'] as String,
          userId: t['user_id'] as String,
          customerId: t['customer_id'] as String,
          type: t['type'] as String,
          amount: _parseDouble(t['amount']),
          description: Value(t['description'] as String? ?? ''),
          isDeleted: Value((t['is_deleted'] as bool?) ?? false),
          createdAt: DateTime.parse(t['created_at'] as String).toLocal(),
          updatedAt: DateTime.parse(t['updated_at'] as String).toLocal(),
          deletedAt: Value(t['deleted_at'] != null
              ? DateTime.parse(t['deleted_at'] as String).toLocal()
              : null),
          syncStatus: const Value('synced'),
        )).toList();

        await _db.upsertTransactionsBatch(transactionCompanions);

        if (transactions.length < batchSize) break;
        txOffset += batchSize;
      }
    } catch (e) {
      debugPrint('Error pulling data from cloud: $e');
    }
  }

  void stopRealtimeSync() {
    _reconnectTimer?.cancel();
    _customersChannel?.unsubscribe();
    _transactionsChannel?.unsubscribe();
    _customersChannel = null;
    _transactionsChannel = null;
    _heartbeatTimer?.cancel();
    _activeUserId = null;
  }

  void dispose() {
    _retryTimer?.cancel();
    stopRealtimeSync();
  }
}

/// Provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = Supabase.instance.client;
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = SyncService(db, supabase, connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for pending sync count
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getPendingSyncCount();
});
