// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['participantId', 'userId', 'activity'],
    disallowNullValues: const ['participantId', 'userId', 'activity'],
  );
  return Participant(
    participantId: json['participantId'] as String,
    userId: json['userId'] as String,
    activity: Activity.fromJson(json['activity'] as Map<String, dynamic>),
    status: json['status'] as String?,
    attendancePercent: (json['attendancePercent'] as num?)?.toDouble(),
    registeredDate: json['registeredDate'] == null
        ? null
        : DateTime.parse(json['registeredDate'] as String),
    acceptedDate: json['acceptedDate'] == null
        ? null
        : DateTime.parse(json['acceptedDate'] as String),
    testimonial: json['testimonial'] as String?,
    submittedRating: (json['submittedRating'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'userId': instance.userId,
      'activity': instance.activity.toJson(),
      'status': instance.status,
      'attendancePercent': instance.attendancePercent,
      'registeredDate': instance.registeredDate?.toIso8601String(),
      'acceptedDate': instance.acceptedDate?.toIso8601String(),
      'testimonial': instance.testimonial,
      'submittedRating': instance.submittedRating,
    };
