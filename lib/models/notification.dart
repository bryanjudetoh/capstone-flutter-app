import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/models/reward.dart';

import 'activity.dart';
part 'notification.g.dart';

@JsonSerializable()
class Notif {
  @JsonKey(required: true, disallowNullValue: true)
  String notificationId;

  @JsonKey(required: true, disallowNullValue: true)
  String title;

  @JsonKey(required: true, disallowNullValue: true)
  String content;

  @JsonKey(required: true, disallowNullValue: true)
  DateTime scheduledTime;

  @JsonKey(required: true, disallowNullValue: true)
  bool hasRead;

  Organisation organisation;
  bool isSystemTriggered;
  String receiverGroup;

  Activity? activity;
  Reward? reward;

  Notif({required this.notificationId, required this.title, required this.content, required this.scheduledTime, required this.hasRead,
    required this.organisation, required this.isSystemTriggered, required this.receiverGroup, this.activity, this.reward,
  });

  factory Notif.fromJson(Map<String, dynamic> json) => _$NotifFromJson(json);

  Map<String, dynamic> toJson() => _$NotifToJson(this);
}