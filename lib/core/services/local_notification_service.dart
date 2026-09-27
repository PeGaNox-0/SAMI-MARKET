import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/customer_portal/screens/customer_shell.dart';

/// Global navigator key or callback for handling notification tap navigation
final notificationTapHandlerProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService(ref);
});

class LocalNotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  LocalNotificationService(this._ref);

  /// Initialize local notifications plugin
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Request Android 13+ permission
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  void _handleNotificationTap(String? payload) {
    if (payload == 'customer_notifications') {
      // Switch customer tab to notifications tab (index 2)
      try {
        _ref.read(customerNavIndexProvider.notifier).state = 2;
      } catch (e) {
        debugPrint('Error switching to notifications tab: $e');
      }
    }
  }

  /// Show instant system notification on device
  Future<void> showNotification({
    int id = 1,
    required String title,
    required String body,
    String payload = 'customer_notifications',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'sami_market_alerts',
      'تنبيهات سامي ماركت',
      channelDescription: 'إشعارات وتنبيهات الحساب والديون من سامي ماركت',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
