import 'package:json_annotation/json_annotation.dart';
import 'activity.dart';
part 'participant.g.dart';

@JsonSerializable(explicitToJson: true)
class Participant {
  @JsonKey(required: true, disallowNullValue: true)
  String participantId;

  @JsonKey(required: true, disallowNullValue: true)
  String userId;

  @JsonKey(required: true, disallowNullValue: true)
  Activity activity;

  String? status;
  double? attendancePercent;
  DateTime? registeredDate;
  DateTime? acceptedDate;

  String? testimonial;
  double? submittedRating;
  int? awardedPotions;
  int? multiplier;

  Participant({required this.participantId, required this.userId, required this.activity,
    this.status, this.attendancePercent, this.registeredDate, this.acceptedDate, this.testimonial,
    this.submittedRating, this.awardedPotions, this.multiplier,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}