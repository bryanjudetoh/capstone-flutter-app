// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['userId', 'firstName', 'lastName'],
    disallowNullValues: const ['userId'],
  );
  return User(
    userId: json['userId'] as String,
    email: json['email'] as String?,
    mobile: json['mobile'] as String?,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    gender: json['gender'] as String?,
    age: json['age'] as int?,
    dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
    address1: json['address1'] as String?,
    address2: json['address2'] as String?,
    address3: json['address3'] as String?,
    postalCode: json['postalCode'] as String?,
    countryCode: json['countryCode'] as String?,
    city: json['city'] as String?,
    school: json['school'] as String?,
    roleId: json['roleId'] as String?,
    role: json['role'] as String?,
    userType: json['userType'] as String?,
    loginType: json['loginType'] as String?,
    enabled: json['enabled'] as bool?,
    verified: json['verified'] as bool?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    lastLogin: json['lastLogin'] == null
        ? null
        : DateTime.parse(json['lastLogin'] as String),
    profilePicUrl: json['profilePicUrl'] as String?,
    potionBalance: json['potionBalance'] as Map<String, dynamic>?,
    elixirBalance: json['elixirBalance'] as int?,
    rewardList: (json['rewardList'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList(),
    numFriends: json['numFriends'] as int?,
    isFriend: json['isFriend'] as bool?,
    multipliers: (json['multipliers'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'mobile': instance.mobile,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'age': instance.age,
      'dob': instance.dob?.toIso8601String(),
      'address1': instance.address1,
      'address2': instance.address2,
      'address3': instance.address3,
      'postalCode': instance.postalCode,
      'countryCode': instance.countryCode,
      'city': instance.city,
      'school': instance.school,
      'roleId': instance.roleId,
      'role': instance.role,
      'userType': instance.userType,
      'loginType': instance.loginType,
      'enabled': instance.enabled,
      'verified': instance.verified,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'profilePicUrl': instance.profilePicUrl,
      'potionBalance': instance.potionBalance,
      'elixirBalance': instance.elixirBalance,
      'rewardList': instance.rewardList,
      'numFriends': instance.numFriends,
      'isFriend': instance.isFriend,
      'multipliers': instance.multipliers,
    };
