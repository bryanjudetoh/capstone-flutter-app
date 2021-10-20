// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard-entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntity _$LeaderboardEntityFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'type', 'school', 'value'],
    disallowNullValues: const ['name'],
  );
  return LeaderboardEntity(
    name: json['name'] as String,
    type: json['type'] as String,
    school: json['school'] as String,
    value: json['value'] as int,
  );
}

Map<String, dynamic> _$LeaderboardEntityToJson(LeaderboardEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'school': instance.school,
      'value': instance.value,
    };
