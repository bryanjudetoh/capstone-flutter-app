// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organisation _$OrganisationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name'],
    disallowNullValues: const ['id'],
  );
  return Organisation(
    id: json['id'] as String,
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
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'countryCode': instance.countryCode,
      'website': instance.website,
      'orgTags': instance.orgTags,
      'orgDisplayPicUrl': instance.orgDisplayPicUrl,
    };
