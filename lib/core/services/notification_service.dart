import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notification model
class NotificationModel {
  final String id;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Notification service (admin side)
class NotificationService {
  final SupabaseClient _supabase;
  NotificationService(this._supabase);

  /// Admin sends a notification — pass null for customerIds to send to all
  Future<Map<String, dynamic>> sendNotification({
    required String message,
    List<String>? customerIds, // null = send to all
  }) async {
    try {
      final result = await _supabase.rpc('admin_send_notification', params: {
        'p_message': message.trim(),
        'p_customer_ids': customerIds,
      });
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Customer fetches their notifications
  Future<Map<String, dynamic>> getCustomerNotifications({
    required String customerId,
    required String pin,
  }) async {
    try {
      final result = await _supabase.rpc('customer_get_notifications', params: {
        'p_customer_id': customerId,
        'p_pin': pin,
      });
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Customer marks a single notification as read
  Future<void> markRead({
    required String customerId,
    required String notificationId,
    required String pin,
  }) async {
    try {
      await _supabase.rpc('customer_mark_notification_read', params: {
        'p_customer_id': customerId,
        'p_notification_id': notificationId,
        'p_pin': pin,
      });
    } catch (_) {}
  }

  /// Customer marks all notifications as read
  Future<void> markAllRead({
    required String customerId,
    required String pin,
  }) async {
    try {
      await _supabase.rpc('customer_mark_all_notifications_read', params: {
        'p_customer_id': customerId,
        'p_pin': pin,
      });
    } catch (_) {}
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(Supabase.instance.client);
});

