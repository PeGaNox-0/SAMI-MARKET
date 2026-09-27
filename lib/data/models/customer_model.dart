import 'package:equatable/equatable.dart';

/// Customer data model
class CustomerModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String customerCode; // Unique custom code / number for fast search
  final String phone;
  final String address;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? balance; // Calculated from transactions, NOT stored

  const CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    this.customerCode = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.balance,
  });

  CustomerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? customerCode,
    String? phone,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? balance,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      customerCode: customerCode ?? this.customerCode,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      balance: balance ?? this.balance,
    );
  }

  /// From Supabase JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      customerCode: json['customer_code'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// To Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'customer_code': customerCode,
      'phone': phone,
      'address': address,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, name, customerCode, phone, address, notes, isActive];
}
