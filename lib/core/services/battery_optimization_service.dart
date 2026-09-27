import 'package:flutter/services.dart';

class BatteryOptimizationService {
  static const _channel = MethodChannel('com.example.omar_app/battery_optimization');

  /// Check if the app is ignoring battery optimizations (unrestricted background)
  static Future<bool> isIgnored() async {
    try {
      final ignored = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return ignored ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request the user to ignore battery optimizations (unrestricted background)
  static Future<void> requestIgnore() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }
}
