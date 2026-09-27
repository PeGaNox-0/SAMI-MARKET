import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../datasources/local/app_database.dart';
import '../models/customer_model.dart';
import '../../core/services/sync_service.dart';

/// Customer repository — offline-first with reactive Drift streams & Supabase sync
class CustomerRepository {
  final AppDatabase _db;
  final SyncService? _syncService;
  static const _uuid = Uuid();

  CustomerRepository(this._db, [this._syncService]);

  /// Stream customers for real-time live updates (Single SQL query, No N+1)
  Stream<List<CustomerModel>> watchCustomers({
    required String userId,
    String? search,
    String? filter, // 'all', 'has_debt', 'paid'
  }) {
    return _db.watchCustomersWithBalance(userId, search: search).map((rows) {
      final customers = <CustomerModel>[];
      for (final item in rows) {
        final c = item.customer;
        final balance = item.balance;

        // Apply debt filter
        if (filter == 'has_debt' && balance <= 0) continue;
        if (filter == 'paid' && balance > 0) continue;

        customers.add(CustomerModel(
          id: c.id,
          userId: c.userId,
          name: c.name,
          customerCode: c.customerCode,
          phone: c.phone,
          address: c.address,
          notes: c.notes,
          isActive: c.isActive,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
          balance: balance,
        ));
      }
      return customers;
    });
  }

  /// Stream single customer with balance (Single SQL query, No N+1)
  Stream<CustomerModel?> watchCustomerById(String id) {
    return _db.watchCustomerWithBalanceById(id).map((item) {
      if (item == null) return null;
      final c = item.customer;
      return CustomerModel(
        id: c.id,
        userId: c.userId,
        name: c.name,
        customerCode: c.customerCode,
        phone: c.phone,
        address: c.address,
        notes: c.notes,
        isActive: c.isActive,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        balance: item.balance,
      );
    });
  }

  /// Get all customers for current user with optional filtering (Future, Single SQL query, No N+1)
  Future<List<CustomerModel>> getCustomers({
    required String userId,
    String? search,
    String? filter,
  }) async {
    final rows = await _db.getCustomersWithBalance(userId, search: search);

    final customers = <CustomerModel>[];
    for (final item in rows) {
      final c = item.customer;
      final balance = item.balance;

      if (filter == 'has_debt' && balance <= 0) continue;
      if (filter == 'paid' && balance > 0) continue;

      customers.add(CustomerModel(
        id: c.id,
        userId: c.userId,
        name: c.name,
        customerCode: c.customerCode,
        phone: c.phone,
        address: c.address,
        notes: c.notes,
        isActive: c.isActive,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        balance: balance,
      ));
    }
    return customers;
  }

  /// Get single customer with balance (Future)
  Future<CustomerModel?> getCustomerById(String id) async {
    final c = await _db.getCustomerById(id);
    if (c == null) return null;

    final balance = await _db.getCustomerBalance(id);
    return CustomerModel(
      id: c.id,
      userId: c.userId,
      name: c.name,
      customerCode: c.customerCode,
      phone: c.phone,
      address: c.address,
      notes: c.notes,
      isActive: c.isActive,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      balance: balance,
    );
  }

  /// Add new customer — pushes directly to Supabase if online, saves locally
  Future<CustomerModel> addCustomer({
    required String userId,
    required String name,
    String customerCode = '',
    String phone = '',
    String address = '',
    String notes = '',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final customer = CustomerModel(
      id: id,
      userId: userId,
      name: name,
      customerCode: customerCode,
      phone: phone,
      address: address,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      balance: 0,
    );

    final payload = customer.toJson();
    payload.remove('balance');
    bool directSynced = false;

    // 1. Direct Instant Cloud Sync
    try {
      await Supabase.instance.client.from('customers').upsert(payload);
      directSynced = true;
    } catch (_) {}

    // 2. Save locally to SQLite
    await _db.upsertCustomer(LocalCustomersCompanion.insert(
      id: id,
      userId: userId,
      name: name,
      customerCode: Value(customerCode),
      phone: Value(phone),
      address: Value(address),
      notes: Value(notes),
      createdAt: now,
      updatedAt: now,
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    // 3. Fallback: Queue for background sync
    if (!directSynced) {
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'customers',
        recordId: id,
        operation: 'insert',
        data: jsonEncode(payload),
        createdAt: now,
      ));
      _syncService?.syncPendingChanges();
    }

    return customer;
  }

  /// Update customer — pushes directly to Supabase if online, saves locally
  Future<void> updateCustomer(CustomerModel customer) async {
    final now = DateTime.now();
    final updated = customer.copyWith(updatedAt: now);

    final payload = updated.toJson();
    payload.remove('balance');
    bool directSynced = false;

    try {
      await Supabase.instance.client.from('customers').update(payload).eq('id', updated.id);
      directSynced = true;
    } catch (_) {}

    await _db.upsertCustomer(LocalCustomersCompanion(
      id: Value(updated.id),
      userId: Value(updated.userId),
      name: Value(updated.name),
      customerCode: Value(updated.customerCode),
      phone: Value(updated.phone),
      address: Value(updated.address),
      notes: Value(updated.notes),
      isActive: Value(updated.isActive),
      createdAt: Value(updated.createdAt),
      updatedAt: Value(now),
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    if (!directSynced) {
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'customers',
        recordId: updated.id,
        operation: 'update',
        data: jsonEncode(payload),
        createdAt: now,
      ));
      _syncService?.syncPendingChanges();
    }
  }

  /// Hard-delete customer — removes from local SQLite and Supabase permanently
  Future<void> archiveCustomer(String id) async {
    // 1. Delete from local SQLite (customer + their transactions)
    await _db.deleteCustomerPermanently(id);

    // 2. Delete from Supabase directly (no sync queue — immediate)
    try {
      // 2a. Delete transactions of this customer from Supabase first
      await Supabase.instance.client
          .from('transactions')
          .delete()
          .eq('customer_id', id);

      // 2b. Now delete the customer from Supabase
      await Supabase.instance.client
          .from('customers')
          .delete()
          .eq('id', id);
    } catch (_) {
      // If offline, the local record is gone. Supabase will be cleaned
      // next time the record is missing or can be handled via DB cascade.
    }
  }

  final Map<String, Map<String, dynamic>> _customerAccountsCache = {};

  /// Admin: Enable / Create customer application access with PIN
  Future<Map<String, dynamic>> createCustomerAccount({
    required String customerId,
    required String customerCode,
    required String pin,
  }) async {
    try {
      final cleanCode = customerCode.trim().toUpperCase();

      // 1. Instant sync: Ensure customer record is pushed to Supabase first
      final localCustomer = await getCustomerById(customerId);
      if (localCustomer != null) {
        final payload = localCustomer.copyWith(customerCode: cleanCode).toJson();
        payload.remove('balance');
        await Supabase.instance.client.from('customers').upsert(payload);
      }

      // Also trigger pending sync queue
      _syncService?.syncPendingChanges();

      // 2. Call Supabase RPC to create or update customer_accounts
      final response = await Supabase.instance.client.rpc(
        'admin_create_customer_account',
        params: {
          'p_customer_id': customerId,
          'p_customer_code': cleanCode,
          'p_pin': pin.trim(),
        },
      );
      final map = Map<String, dynamic>.from(response as Map);
      if (map['success'] == true) {
        _customerAccountsCache[customerId] = {
          'id': map['account_id'] ?? '',
          'customer_id': customerId,
          'customer_code': cleanCode,
          'is_enabled': true,
          'failed_attempts': 0,
          'last_login_at': null,
          'created_at': DateTime.now().toIso8601String(),
        };
      }
      return map;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Admin: Reset customer PIN
  Future<Map<String, dynamic>> resetCustomerPin({
    required String customerId,
    required String newPin,
  }) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'admin_reset_customer_pin',
        params: {
          'p_customer_id': customerId,
          'p_new_pin': newPin.trim(),
        },
      );
      final map = Map<String, dynamic>.from(response as Map);
      if (map['success'] == true && _customerAccountsCache.containsKey(customerId)) {
        _customerAccountsCache[customerId] = {
          ..._customerAccountsCache[customerId]!,
          'failed_attempts': 0,
        };
      }
      return map;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Admin: Toggle customer access (Enable/Disable)
  Future<Map<String, dynamic>> setCustomerAccess({
    required String customerId,
    required bool enabled,
  }) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'admin_set_customer_access',
        params: {
          'p_customer_id': customerId,
          'p_enabled': enabled,
        },
      );
      final map = Map<String, dynamic>.from(response as Map);
      if (map['success'] == true && _customerAccountsCache.containsKey(customerId)) {
        _customerAccountsCache[customerId] = {
          ..._customerAccountsCache[customerId]!,
          'is_enabled': enabled,
        };
      }
      return map;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Admin: Fetch customer account status with fast memory cache + background revalidation
  Future<Map<String, dynamic>?> getCustomerAccount(String customerId, {bool forceRefresh = false}) async {
    // 1. If cached and not forced, return immediately (0ms latency)
    if (!forceRefresh && _customerAccountsCache.containsKey(customerId)) {
      // Revalidate in background asynchronously without blocking the UI
      _fetchAccountFromSupabase(customerId).then((remote) {
        if (remote != null) {
          _customerAccountsCache[customerId] = remote;
        }
      }).catchError((_) {});
      return _customerAccountsCache[customerId];
    }

    // 2. Fetch from Supabase
    final data = await _fetchAccountFromSupabase(customerId);
    if (data != null) {
      _customerAccountsCache[customerId] = data;
    }
    return data ?? _customerAccountsCache[customerId];
  }

  Future<Map<String, dynamic>?> _fetchAccountFromSupabase(String customerId) async {
    try {
      final data = await Supabase.instance.client
          .from('customer_accounts')
          .select('id, customer_id, customer_code, is_enabled, failed_attempts, last_login_at, created_at')
          .eq('customer_id', customerId)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return null;
    }
  }

  /// Invalidate memory cache for a customer account
  void invalidateCustomerAccountCache(String customerId) {
    _customerAccountsCache.remove(customerId);
  }

  // =====================
  // TEMPORARY CUSTOMERS (LOCAL ONLY)
  // =====================

  /// Add a temporary customer (now synced to Supabase)
  Future<void> addTemporaryCustomer({
    required String userId,
    required String name,
    required double amount,
    String? description,
  }) async {
    final customerId = _uuid.v4();
    final transactionId = _uuid.v4();
    final now = DateTime.now();

    final customerModel = CustomerModel(
      id: customerId,
      userId: userId,
      name: name,
      customerCode: 'TEMP',
      phone: '',
      address: '',
      notes: description ?? '',
      createdAt: now,
      updatedAt: now,
      balance: amount,
    );

    final transactionPayload = {
      'id': transactionId,
      'user_id': userId,
      'customer_id': customerId,
      'type': 'debt',
      'amount': amount,
      'description': description ?? 'دين زبون مؤقت أولى',
      'is_deleted': false,
      'created_at': now.toUtc().toIso8601String(),
      'updated_at': now.toUtc().toIso8601String(),
    };

    bool directSynced = false;
    try {
      final custPayload = customerModel.toJson();
      custPayload.remove('balance');
      await Supabase.instance.client.from('customers').upsert(custPayload);
      await Supabase.instance.client.from('transactions').upsert(transactionPayload);
      directSynced = true;
    } catch (_) {}

    // 1. Save customer locally with customerCode = 'TEMP'
    await _db.upsertCustomer(LocalCustomersCompanion.insert(
      id: customerId,
      userId: userId,
      name: name,
      customerCode: const Value('TEMP'),
      phone: const Value(''),
      address: const Value(''),
      notes: Value(description ?? ''),
      createdAt: now,
      updatedAt: now,
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    // 2. Create initial debt transaction locally
    await _db.upsertTransaction(LocalTransactionsCompanion.insert(
      id: transactionId,
      userId: userId,
      customerId: customerId,
      type: 'debt',
      amount: amount,
      description: Value(description ?? 'دين زبون مؤقت أولى'),
      createdAt: now,
      updatedAt: now,
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    // 3. Fallback: Queue for sync if direct push failed
    if (!directSynced) {
      final custPayload = customerModel.toJson();
      custPayload.remove('balance');
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'customers',
        recordId: customerId,
        operation: 'insert',
        data: jsonEncode(custPayload),
        createdAt: now,
      ));

      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'transactions',
        recordId: transactionId,
        operation: 'insert',
        data: jsonEncode(transactionPayload),
        createdAt: now,
      ));

      _syncService?.syncPendingChanges();
    }
  }

  /// Watch temporary customers (mapped to CustomerModel, single SQL query, No N+1)
  Stream<List<CustomerModel>> watchTemporaryCustomers(String userId) {
    return _db.watchTemporaryCustomersWithBalance(userId).map((rows) {
      return rows.map((item) {
        final c = item.customer;
        return CustomerModel(
          id: c.id,
          userId: c.userId,
          name: c.name,
          customerCode: c.customerCode,
          phone: c.phone,
          address: c.address,
          notes: c.notes,
          isActive: c.isActive,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
          balance: item.balance,
        );
      }).toList();
    });
  }

  /// Update a temporary customer's details and debt amount (synced directly to Supabase)
  Future<void> updateTemporaryCustomer({
    required String id,
    required String name,
    required double amount,
    required String description,
  }) async {
    final now = DateTime.now();

    // 1. Get existing customer from local DB
    final existing = await _db.getCustomerById(id);
    if (existing == null) return;

    final customerModel = CustomerModel(
      id: existing.id,
      userId: existing.userId,
      name: name,
      customerCode: existing.customerCode,
      phone: existing.phone,
      address: existing.address,
      notes: description,
      isActive: existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: now,
    );

    // 2. Find or create the primary debt transaction for this temporary customer
    final transactions = await _db.getTransactionsByCustomer(id);
    final debtTx = transactions.where((t) => t.type == 'debt').firstOrNull;
    final transactionId = debtTx?.id ?? _uuid.v4();
    final txCreatedAt = debtTx?.createdAt ?? now;

    final transactionPayload = {
      'id': transactionId,
      'user_id': existing.userId,
      'customer_id': id,
      'type': 'debt',
      'amount': amount,
      'description': description.isNotEmpty
          ? description
          : (debtTx?.description.isNotEmpty == true
              ? debtTx!.description
              : 'دين زبون مؤقت أولى'),
      'is_deleted': false,
      'created_at': txCreatedAt.toUtc().toIso8601String(),
      'updated_at': now.toUtc().toIso8601String(),
    };

    // 3. Direct Live Cloud Sync to Supabase
    bool directSynced = false;
    try {
      final custPayload = customerModel.toJson();
      custPayload.remove('balance');
      await Supabase.instance.client.from('customers').upsert(custPayload);
      await Supabase.instance.client.from('transactions').upsert(transactionPayload);
      directSynced = true;
    } catch (e) {
      // Offline fallback
    }

    // 4. Update customer locally
    await _db.upsertCustomer(LocalCustomersCompanion(
      id: Value(existing.id),
      userId: Value(existing.userId),
      name: Value(name),
      customerCode: Value(existing.customerCode),
      phone: Value(existing.phone),
      address: Value(existing.address),
      notes: Value(description),
      isActive: Value(existing.isActive),
      createdAt: Value(existing.createdAt),
      updatedAt: Value(now),
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    // 5. Update debt transaction locally
    await _db.upsertTransaction(LocalTransactionsCompanion(
      id: Value(transactionId),
      userId: Value(existing.userId),
      customerId: Value(id),
      type: const Value('debt'),
      amount: Value(amount),
      description: Value(description.isNotEmpty
          ? description
          : (debtTx?.description.isNotEmpty == true
              ? debtTx!.description
              : 'دين زبون مؤقت أولى')),
      isDeleted: const Value(false),
      createdAt: Value(txCreatedAt),
      updatedAt: Value(now),
      syncStatus: Value(directSynced ? 'synced' : 'pending'),
    ));

    // 6. Fallback: Queue for sync if direct push failed
    if (!directSynced) {
      final custPayload = customerModel.toJson();
      custPayload.remove('balance');
      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'customers',
        recordId: id,
        operation: 'update',
        data: jsonEncode(custPayload),
        createdAt: now,
      ));

      await _db.addToSyncQueue(SyncQueueCompanion.insert(
        entityTable: 'transactions',
        recordId: transactionId,
        operation: 'update',
        data: jsonEncode(transactionPayload),
        createdAt: now,
      ));

      _syncService?.syncPendingChanges();
    }
  }

  /// Delete temporary customer (when paid) - hard delete from both SQLite and Supabase
  Future<void> deleteTemporaryCustomer(String id) async {
    await archiveCustomer(id);
  }
}

/// Provider for customer repository
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  return CustomerRepository(db, syncService);
});
