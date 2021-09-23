// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organisation _$OrganisationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['organisationId', 'name', 'email'],
    disallowNullValues: const ['organisationId'],
  );
  return Organisation(
    organisationId: json['organisationId'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    countryCode: json['countryCode'] as String?,
    website: json['website'] as String?,
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
  )..orgTags =
      (json['orgTags'] as List<dynamic>?)?.map((e) => e as String).toList();
}

Map<String, dynamic> _$OrganisationToJson(Organisation instance) =>
    <String, dynamic>{
      'organisationId': instance.organisationId,
      'name': instance.name,
      'email': instance.email,
      'countryCode': instance.countryCode,
      'website': instance.website,
      'orgTags': instance.orgTags,
      'roleId': instance.roleId,
      'role': instance.role,
      'userType': instance.userType,
      'loginType': instance.loginType,
      'enabled': instance.enabled,
      'verified': instance.verified,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'profilePicUrl': instance.profilePicUrl,
    };
