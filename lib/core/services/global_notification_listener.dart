import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'customer_auth_service.dart';
import 'local_notification_service.dart';
import 'notification_service.dart';
import '../../data/models/customer_account_model.dart';
import '../../features/customer_portal/screens/customer_notifications_screen.dart';

/// Global notification listener provider — listens for realtime updates and polls as fallback
final globalNotificationListenerProvider = Provider<GlobalNotificationListener>((ref) {
  final listener = GlobalNotificationListener(ref);
  ref.onDispose(() => listener.dispose());
  return listener;
});

class GlobalNotificationListener {
  final Ref _ref;
  RealtimeChannel? _realtimeChannel;
  Timer? _pollingTimer;
  int _lastKnownCount = -1;

  GlobalNotificationListener(this._ref) {
    // Watch customer session to initialize/dispose realtime listeners
    _ref.listen<CustomerSession?>(customerSessionProvider, (previous, next) {
      if (next != null) {
        _startListening(next);
      } else {
        _stopListening();
      }
    }, fireImmediately: true);
  }

  void _startListening(CustomerSession session) {
    _stopListening();

    // 1. Initial check
    _checkNewNotifications(session, isInitial: true);

    // 2. Setup periodic check every 25 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _checkNewNotifications(session, isInitial: false);
    });

    // 3. Setup Supabase Realtime channel
    try {
      _realtimeChannel = Supabase.instance.client
          .channel('public:global_notifications:${session.customerId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'customer_id',
              value: session.customerId,
            ),
            callback: (payload) {
              final newRecord = payload.newRecord;
              final msg = newRecord['message'] as String? ?? 'لديك إشعار جديد';

              // Trigger system notification on mobile status bar
              _ref.read(notificationTapHandlerProvider).showNotification(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: 'SAMI MARKET 📢',
                    body: msg,
                    payload: 'customer_notifications',
                  );

              // Update badge and list
              _ref.invalidate(customerNotifListProvider);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Global realtime notification subscription error: $e');
    }
  }

  Future<void> _checkNewNotifications(CustomerSession session, {bool isInitial = false}) async {
    try {
      final service = _ref.read(notificationServiceProvider);
      final res = await service.getCustomerNotifications(
        customerId: session.customerId,
        pin: session.pin,
      );

      if (res['success'] == true) {
        final unreadCount = res['unread_count'] as int? ?? 0;
        final raw = (res['notifications'] as List?) ?? [];

        if (!isInitial && _lastKnownCount >= 0 && unreadCount > _lastKnownCount) {
          // New notification detected via polling
          if (raw.isNotEmpty) {
            final latest = raw.first as Map<String, dynamic>;
            final msg = latest['message'] as String? ?? 'لديك إشعار جديد';
            _ref.read(notificationTapHandlerProvider).showNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'SAMI MARKET 📢',
                  body: msg,
                  payload: 'customer_notifications',
                );
            _ref.invalidate(customerNotifListProvider);
          }
        }

        _lastKnownCount = unreadCount;
        _ref.read(customerUnreadCountProvider.notifier).state = unreadCount;
      }
    } catch (_) {}
  }

  void _stopListening() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _lastKnownCount = -1;
  }

  void dispose() {
    _stopListening();
  }
}
