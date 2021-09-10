import 'package:intl/intl.dart';

class User {
  String userId, email, firstName, lastName, roleId, role, userType;
  bool enabled;
  DateTime createdAt, lastLogin;

  User({required this.userId, required this.email, required this.firstName, required this.lastName, required this.enabled,
    required this.roleId, required this.role, required this.createdAt, required this.lastLogin, required this.userType});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      enabled: json['enabled'],
      roleId: json['roleId'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      userType: json['userType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId" : userId,
      "email" : email,
      "firstName" : firstName,
      "lastName" : lastName,
      "enabled" : enabled,
      "roleId" : roleId,
      "role" : role,
      "createdAt" : createdAt,
      "lastLogin" : lastLogin,
      "userType" : userType,

    };
  }

}