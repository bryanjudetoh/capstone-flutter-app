// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard-entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntity _$LeaderboardEntityFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['userId', 'name', 'type', 'school', 'value'],
    disallowNullValues: const ['userId', 'name'],
  );
  return LeaderboardEntity(
    userId: json['userId'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    school: json['school'] as String,
    value: json['value'] as int,
    profilePicUrl: json['profilePicUrl'] as String?,
  );
}

Map<String, dynamic> _$LeaderboardEntityToJson(LeaderboardEntity instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'type': instance.type,
      'school': instance.school,
      'value': instance.value,
      'profilePicUrl': instance.profilePicUrl,
    };
