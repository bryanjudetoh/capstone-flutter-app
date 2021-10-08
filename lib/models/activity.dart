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
  DateTime? registrationEndTime;

  double? registrationPrice;
  int? applicantPax;
  double? attendanceReqPercent;
  int? potions;
  List<String>? mediaContentUrls;
  bool? enabled;
  bool? approved;
  String? status;
  double? activityRating;

  List<Session>? activitySessionList;
  int? participantCount;
  DateTime? approvedDate;
  Organisation? organisation;

  bool? isBump;
  bool? isFeatured;
  bool? isRegistered;
  String? participantId;

  Activity({required this.activityId, required this.name, this.description, this.type,
    this.activityStartTime, this.activityEndTime, this.registrationEndTime,
    this.registrationPrice, this.applicantPax, this.attendanceReqPercent, this.potions,
    this.mediaContentUrls, this.enabled, this.approved, this.status, this.activitySessionList,
    this.participantCount, this.approvedDate, this.organisation, this.isBump, this.isFeatured,
    this.isRegistered, this.participantId, this.activityRating,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}