import 'package:equatable/equatable.dart';

/// User profile model
class ProfileModel extends Equatable {
  final String id;
  final String fullName;
  final String marketName;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    this.marketName = '',
    this.phone = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      marketName: json['market_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'market_name': marketName,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [id, fullName, marketName, phone];
}
