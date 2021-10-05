// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['sessionId'],
    disallowNullValues: const ['sessionId'],
  );
  return Session(
    sessionId: json['sessionId'] as String,
    name: json['name'] as String?,
    venue: json['venue'] as String?,
    description: json['description'] as String?,
    seqNum: json['seqNum'] as int?,
    startTime: json['startTime'] == null
        ? null
        : DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] == null
        ? null
        : DateTime.parse(json['endTime'] as String),
  );
}

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'sessionId': instance.sessionId,
      'name': instance.name,
      'venue': instance.venue,
      'description': instance.description,
      'seqNum': instance.seqNum,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
    };
