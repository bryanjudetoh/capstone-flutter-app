// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notif _$NotifFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'notificationId',
      'title',
      'content',
      'scheduledTime',
      'hasRead'
    ],
    disallowNullValues: const [
      'notificationId',
      'title',
      'content',
      'scheduledTime',
      'hasRead'
    ],
  );
  return Notif(
    notificationId: json['notificationId'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    scheduledTime: DateTime.parse(json['scheduledTime'] as String),
    hasRead: json['hasRead'] as bool,
    organisation:
        Organisation.fromJson(json['organisation'] as Map<String, dynamic>),
    isSystemTriggered: json['isSystemTriggered'] as bool,
    receiverGroup: json['receiverGroup'] as String?,
    activity: json['activity'] == null
        ? null
        : Activity.fromJson(json['activity'] as Map<String, dynamic>),
    reward: json['reward'] == null
        ? null
        : Reward.fromJson(json['reward'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NotifToJson(Notif instance) => <String, dynamic>{
      'notificationId': instance.notificationId,
      'title': instance.title,
      'content': instance.content,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'hasRead': instance.hasRead,
      'organisation': instance.organisation,
      'isSystemTriggered': instance.isSystemTriggered,
      'receiverGroup': instance.receiverGroup,
      'activity': instance.activity,
      'reward': instance.reward,
    };
