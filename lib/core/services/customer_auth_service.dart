import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/customer_account_model.dart';
import '../../data/models/transaction_model.dart';
import 'fcm_service.dart';

/// App user roles
enum AppRole {
  none,
  admin,
  customer,
}

/// Active role state provider
final activeRoleProvider = StateProvider<AppRole>((ref) => AppRole.none);

// ─────────────────────────────────────────────
// Persistent customer session
// ─────────────────────────────────────────────

const _kSessionKey = 'customer_session_v1';

/// Loads the saved session from disk (called once at startup)
Future<CustomerSession?> loadSavedCustomerSession() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_kSessionKey);
  if (json == null) return null;
  try {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return CustomerSession(
      customerId: map['customer_id'] as String,
      customerCode: map['customer_code'] as String,
      customerName: map['customer_name'] as String,
      phone: map['phone'] as String? ?? '',
      marketName: map['market_name'] as String? ?? 'SAMI MARKET',
      pin: map['pin'] as String,
    );
  } catch (_) {
    return null;
  }
}

/// Saves session to disk
Future<void> saveCustomerSession(CustomerSession session) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kSessionKey,
    jsonEncode({
      'customer_id': session.customerId,
      'customer_code': session.customerCode,
      'customer_name': session.customerName,
      'phone': session.phone,
      'market_name': session.marketName,
      'pin': session.pin,
    }),
  );
}

/// Clears session from disk
Future<void> clearCustomerSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kSessionKey);
}

/// Customer session state provider — persisted to SharedPreferences
final customerSessionProvider =
    StateNotifierProvider<CustomerSessionNotifier, CustomerSession?>(
  (ref) => CustomerSessionNotifier(ref),
);

class CustomerSessionNotifier extends StateNotifier<CustomerSession?> {
  final Ref _ref;

  CustomerSessionNotifier(this._ref) : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    final saved = await loadSavedCustomerSession();
    if (saved != null) {
      state = saved;
      // Auto-register device token on restore to keep tokens active
      Future.microtask(() => _ref.read(fcmServiceProvider).registerDeviceToken());
    }
  }

  Future<void> setSession(CustomerSession session) async {
    state = session;
    await saveCustomerSession(session);
    // Register token upon login
    await _ref.read(fcmServiceProvider).registerDeviceToken();
  }

  Future<void> clearSession() async {
    // Unregister token upon logout before clearing state
    await _ref.read(fcmServiceProvider).unregisterDeviceToken();
    state = null;
    await clearCustomerSession();
  }
}

// ─────────────────────────────────────────────
// Customer authentication service
// ─────────────────────────────────────────────

/// Customer authentication service
class CustomerAuthService {
  final SupabaseClient _supabase;

  CustomerAuthService(this._supabase);

  /// Authenticate customer using Customer Code + PIN
  Future<Map<String, dynamic>> login({
    required String customerCode,
    required String pin,
  }) async {
    try {
      final res = await _supabase.rpc('customer_verify_login', params: {
        'p_customer_code': customerCode.trim().toUpperCase(),
        'p_pin': pin.trim(),
      });

      final data = Map<String, dynamic>.from(res as Map);
      return data;
    } catch (e) {
      return {'success': false, 'error': 'NETWORK_ERROR', 'message': e.toString()};
    }
  }

  /// Get live customer portal data (balance, totals, transaction ledger)
  Future<Map<String, dynamic>> getPortalData({
    required String customerId,
    required String pin,
  }) async {
    try {
      final res = await _supabase.rpc('customer_get_portal_data', params: {
        'p_customer_id': customerId,
        'p_pin': pin,
      });

      final data = Map<String, dynamic>.from(res as Map);
      return data;
    } catch (e) {
      return {'success': false, 'error': 'NETWORK_ERROR', 'message': e.toString()};
    }
  }

  /// Change customer PIN
  Future<Map<String, dynamic>> changePin({
    required String customerId,
    required String currentPin,
    required String newPin,
  }) async {
    try {
      final res = await _supabase.rpc('customer_change_pin', params: {
        'p_customer_id': customerId,
        'p_current_pin': currentPin,
        'p_new_pin': newPin,
      });

      final data = Map<String, dynamic>.from(res as Map);
      return data;
    } catch (e) {
      return {'success': false, 'error': 'NETWORK_ERROR', 'message': e.toString()};
    }
  }
}

/// Customer auth service provider
final customerAuthServiceProvider = Provider<CustomerAuthService>((ref) {
  return CustomerAuthService(Supabase.instance.client);
});

/// Customer portal live data provider (stream / auto-refreshable)
final customerPortalDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final session = ref.watch(customerSessionProvider);
  if (session == null) return {};

  final service = ref.watch(customerAuthServiceProvider);
  final data = await service.getPortalData(
    customerId: session.customerId,
    pin: session.pin,
  );

  if (data['success'] == true) {
    // Parse transactions list
    final rawTx = (data['transactions'] as List?) ?? [];
    final transactions = rawTx.map((t) {
      final m = Map<String, dynamic>.from(t as Map);
      return TransactionModel(
        id: m['id'] as String,
        userId: '',
        customerId: session.customerId,
        type: m['type'] as String,
        amount: (m['amount'] as num).toDouble(),
        description: m['description'] as String? ?? '',
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['created_at'] as String),
      );
    }).toList();

    return {
      'customer_id': data['customer_id'],
      'customer_name': data['customer_name'],
      'customer_code': data['customer_code'],
      'phone': data['phone'],
      'market_name': data['market_name'],
      'balance': (data['balance'] as num?)?.toDouble() ?? 0.0,
      'total_debts': (data['total_debts'] as num?)?.toDouble() ?? 0.0,
      'total_payments': (data['total_payments'] as num?)?.toDouble() ?? 0.0,
      'transactions': transactions,
    };
  }

  return {};
});

