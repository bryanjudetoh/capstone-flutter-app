import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/models/reward.dart';
part 'notif.g.dart';

@JsonSerializable()
class Notif {
  @JsonKey(required: true, disallowNullValue: true)
  String notificationId;

  String? title;
  String? content;
  String? receiverGroup;
  String? status;
  DateTime? createdAt;
  Organisation? organisation;

  Activity? activity;
  Reward? reward;


  Notif({required this.notificationId, this.title, this.content, this.receiverGroup,
    this.status, this.createdAt, this.organisation, this.activity, this.reward});

  factory Notif.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}