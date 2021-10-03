import 'package:json_annotation/json_annotation.dart';
import 'organisation.dart';
import 'session.dart';
part 'activity.g.dart';

@JsonSerializable(explicitToJson: true)
class Activity{
  @JsonKey(required: true, disallowNullValue: true)
  String activityId;

  @JsonKey(required: true)
  String name;

  String? description;
  String? type;
  DateTime? activityStartTime;
  DateTime? activityEndTime;

  double? registrationPrice;
  int? applicantPax;
  double? attendanceReqPercent;
  int? potions;
  List<String>? mediaContentUrls;
  bool? enabled;
  bool? approved;
  String? status;

  List<Session>? activitySessionList;
  int? participantCount;
  DateTime? approvedDate;
  Organisation? organisation;

  Activity({required this.activityId, required this.name, this.description, this.type, this.activityStartTime, this.activityEndTime,
    this.registrationPrice, this.applicantPax, this.attendanceReqPercent, this.potions,
    this.mediaContentUrls, this.enabled, this.approved, this.status, this.activitySessionList,
    this.participantCount, this.approvedDate, this.organisation
  });

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}