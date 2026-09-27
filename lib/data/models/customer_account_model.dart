import 'package:equatable/equatable.dart';

/// Customer account model for authentication and access control
class CustomerAccountModel extends Equatable {
  final String id;
  final String customerId;
  final String? authUserId;
  final String customerCode;
  final bool isEnabled;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerAccountModel({
    required this.id,
    required this.customerId,
    this.authUserId,
    required this.customerCode,
    this.isEnabled = true,
    this.failedAttempts = 0,
    this.lockedUntil,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLocked => lockedUntil != null && lockedUntil!.isAfter(DateTime.now());

  factory CustomerAccountModel.fromJson(Map<String, dynamic> json) {
    return CustomerAccountModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      authUserId: json['auth_user_id'] as String?,
      customerCode: json['customer_code'] as String,
      isEnabled: json['is_enabled'] as bool? ?? true,
      failedAttempts: json['failed_attempts'] as int? ?? 0,
      lockedUntil: json['locked_until'] != null
          ? DateTime.parse(json['locked_until'] as String)
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'auth_user_id': authUserId,
      'customer_code': customerCode,
      'is_enabled': isEnabled,
      'failed_attempts': failedAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil!.toIso8601String(),
      if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        authUserId,
        customerCode,
        isEnabled,
        failedAttempts,
        lockedUntil,
        lastLoginAt,
      ];
}

/// Customer Portal User Session
class CustomerSession extends Equatable {
  final String customerId;
  final String customerCode;
  final String customerName;
  final String phone;
  final String marketName;
  final String pin; // Held securely in memory for portal RPC queries

  const CustomerSession({
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    this.phone = '',
    this.marketName = 'SAMI MARKET',
    required this.pin,
  });

  @override
  List<Object?> get props => [customerId, customerCode, customerName, phone, marketName];
}
