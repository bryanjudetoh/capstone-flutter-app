// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notif.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notif _$NotificationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['notificationId'],
    disallowNullValues: const ['notificationId'],
  );
  return Notif(
    notificationId: json['notificationId'] as String,
    title: json['title'] as String?,
    content: json['content'] as String?,
    receiverGroup: json['receiverGroup'] as String?,
    status: json['status'] as String?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    organisation: json['organisation'] == null
        ? null
        : Organisation.fromJson(json['organisation'] as Map<String, dynamic>),
    activity: json['activity'] == null
        ? null
        : Activity.fromJson(json['activity'] as Map<String, dynamic>),
    reward: json['reward'] == null
        ? null
        : Reward.fromJson(json['reward'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NotificationToJson(Notif instance) =>
    <String, dynamic>{
      'notificationId': instance.notificationId,
      'title': instance.title,
      'content': instance.content,
      'receiverGroup': instance.receiverGroup,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'organisation': instance.organisation,
      'activity': instance.activity,
      'reward': instance.reward,
    };
