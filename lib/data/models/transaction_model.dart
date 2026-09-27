import 'package:equatable/equatable.dart';

/// Transaction data model
class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String customerId;
  final String type; // 'debt' or 'payment'
  final double amount;
  final String description;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? customerName; // For display in lists

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.type,
    required this.amount,
    this.description = '',
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.customerName,
  });

  bool get isDebt => type == 'debt';
  bool get isPayment => type == 'payment';

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? customerId,
    String? type,
    double? amount,
    String? description,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? customerName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      customerName: customerName ?? this.customerName,
    );
  }

  /// From Supabase JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      customerId: json['customer_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String).toLocal()
          : null,
    );
  }

  /// To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_id': customerId,
      'type': type,
      'amount': amount,
      'description': description,
      'is_deleted': isDeleted,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, customerId, type, amount, isDeleted];
}
