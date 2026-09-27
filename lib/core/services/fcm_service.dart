import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/customer_portal/screens/customer_shell.dart';
import '../../features/customer_portal/screens/customer_notifications_screen.dart';
import 'customer_auth_service.dart';
import 'local_notification_service.dart';

/// Provider for notification transaction ID redirection on tap
final selectedNotificationTransactionIdProvider = StateProvider<String?>(
  (ref) => null,
);

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

final fcmServiceProvider = Provider<FCMService>((ref) {
  final service = FCMService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

class FCMService {
  final Ref _ref;
  bool _isInitialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  FCMService(this._ref);

  /// Initialize FCM Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 3. Request permissions (Android 13+ / iOS)
      await _requestPermissionsIfNeeded();

      // 4. Set up FCM event listeners
      _setupListeners();

      // 5. Handle initial message (if app opened from terminated state)
      await _handleInitialMessage();

      _isInitialized = true;
      debugPrint("FCM Service initialized successfully");
    } catch (e) {
      debugPrint("FCM Initialization error: $e");
    }
  }

  /// Request permissions only if not requested before
  Future<void> _requestPermissionsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequested = prefs.getBool('fcm_permission_requested') ?? false;

    if (!hasRequested) {
      final messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');
      await prefs.setBool('fcm_permission_requested', true);
    }
  }

  /// Request/Prompt for permission manually (e.g. from settings screen)
  Future<NotificationSettings> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings;
  }

  /// Setup foreground & tap listeners
  void _setupListeners() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();

    // 1. Listen for foreground messages
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      debugPrint("Foreground message received: ${message.messageId}");
      final notification = message.notification;
      if (notification != null) {
        _ref
            .read(notificationTapHandlerProvider)
            .showNotification(
              id: message.messageId.hashCode,
              title: notification.title ?? 'تنبيه جديد',
              body: notification.body ?? '',
              payload: 'customer_notifications',
            );

        // Refresh notifications list and badge
        _ref.invalidate(customerNotifListProvider);
      }
    });

    // 2. Listen for notification clicks when app is in background (but running)
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) {
          debugPrint(
            "Notification clicked from background: ${message.messageId}",
          );
          _handleNotificationClick(message.data);
        });

    // 3. Listen for token refreshes
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((token) {
          debugPrint("FCM Token refreshed: $token");
          _updateTokenOnSupabase(token);
        });
  }

  /// Handle click/tap navigation
  void _handleNotificationClick(Map<String, dynamic> data) {
    final transactionId = data['transaction_id'] as String?;
    if (transactionId != null) {
      // 1. Switch to Transactions tab (index 1)
      _ref.read(customerNavIndexProvider.notifier).state = 1;
      // 2. Set the active transaction ID to trigger details sheet
      _ref.read(selectedNotificationTransactionIdProvider.notifier).state =
          transactionId;
    } else {
      // General notification -> switch to notifications tab (index 2)
      _ref.read(customerNavIndexProvider.notifier).state = 2;
    }
  }

  /// Handle app opened from completely closed state via notification click
  Future<void> _handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        "App launched from terminated state via notification: ${initialMessage.messageId}",
      );
      // Delay slightly to ensure widget tree is fully mounted before attempting navigation
      Future.delayed(const Duration(milliseconds: 1500), () {
        _handleNotificationClick(initialMessage.data);
      });
    }
  }

  /// Register active customer device token on Supabase
  Future<void> registerDeviceToken() async {
    try {
      final session = _ref.read(customerSessionProvider);
      if (session == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      debugPrint("Registering FCM Token: $token");
      final supabase = Supabase.instance.client;
      final res = await supabase.rpc(
        'customer_register_device',
        params: {
          'p_customer_id': session.customerId,
          'p_pin': session.pin,
          'p_fcm_token': token,
          'p_platform': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
          'p_device_name': 'Mobile Device',
        },
      );

      debugPrint("Register Device Token Result: $res");
    } catch (e) {
      debugPrint("Error registering FCM Token: $e");
    }
  }

  /// Unregister device token (called on logout)
  Future<void> unregisterDeviceToken() async {
    try {
      final session = _ref.read(customerSessionProvider);
      if (session == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      debugPrint("Unregistering FCM Token: $token");
      final supabase = Supabase.instance.client;
      await supabase.rpc(
        'customer_unregister_device',
        params: {
          'p_customer_id': session.customerId,
          'p_pin': session.pin,
          'p_fcm_token': token,
        },
      );
    } catch (e) {
      debugPrint("Error unregistering FCM Token: $e");
    }
  }

  /// Update token helper for refresh events
  Future<void> _updateTokenOnSupabase(String token) async {
    final session = _ref.read(customerSessionProvider);
    if (session == null) return;

    try {
      final supabase = Supabase.instance.client;
      await supabase.rpc(
        'customer_register_device',
        params: {
          'p_customer_id': session.customerId,
          'p_pin': session.pin,
          'p_fcm_token': token,
          'p_platform': defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
          'p_device_name': 'Mobile Device',
        },
      );
    } catch (e) {
      debugPrint("Error updating refreshed FCM Token: $e");
    }
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }
}
