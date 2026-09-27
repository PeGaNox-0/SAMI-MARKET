import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Server/network failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم']);
}

/// Local database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'حدث خطأ في قاعدة البيانات المحلية']);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'خطأ في المصادقة']);
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'بيانات غير صالحة']);
}

/// Sync failures
class SyncFailure extends Failure {
  const SyncFailure([super.message = 'فشل المزامنة. بياناتك آمنة محلياً وسيتم المحاولة تلقائياً']);
}
