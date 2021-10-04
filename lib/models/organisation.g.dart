// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organisation _$OrganisationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['organisationId', 'name'],
    disallowNullValues: const ['organisationId'],
  );
  return Organisation(
    organisationId: json['organisationId'] as String,
    name: json['name'] as String,
    email: json['email'] as String?,
    countryCode: json['countryCode'] as String?,
    website: json['website'] as String?,
    orgDisplayPicUrl: json['orgDisplayPicUrl'] as String?,
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
      'orgDisplayPicUrl': instance.orgDisplayPicUrl,
    };
