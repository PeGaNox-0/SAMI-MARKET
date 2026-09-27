import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service that monitors internet connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity status
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any((r) => r != ConnectivityResult.none);
    });
  }

  /// Check current connectivity
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream provider for real-time connectivity status
final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});
