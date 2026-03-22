import 'package:flutter/foundation.dart';

enum UserRole {
  admin('ADMIN'),
  supervisor('SUPERVISOR'),
  dispatcher('DISPATCHER'),
  worker('WORKER'),
  citizen('CITIZEN');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value.toUpperCase(),
      orElse: () {
        debugPrint('WARNING: Unknown UserRole "$value", defaulting to citizen');
        return UserRole.citizen;
      },
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String orgId;
  final String? phone;
  final bool isActive;
  final bool webAccess;
  final bool mobileAccess;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.orgId,
    this.phone,
    this.isActive = true,
    this.webAccess = false,
    this.mobileAccess = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      orgId: json['org_id'] as String,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      webAccess: json['web_access'] as bool? ?? false,
      mobileAccess: json['mobile_access'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.value,
        'org_id': orgId,
        'phone': phone,
        'is_active': isActive,
        'web_access': webAccess,
        'mobile_access': mobileAccess,
      };

  bool get isWorker => role == UserRole.worker;
  bool get isCitizen => role == UserRole.citizen;
}
