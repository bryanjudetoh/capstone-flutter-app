import 'package:json_annotation/json_annotation.dart';
part 'session.g.dart';

@JsonSerializable()
class Session {
  @JsonKey(required: true, disallowNullValue: true)
  String sessionId;

  String? name;
  String? venue;
  String? description;
  int? seqNum;

  DateTime? startTime;
  DateTime? endTime;

  Session({required this.sessionId, this.name, this.venue, this.description, this.seqNum,
    this.startTime, this.endTime
  });

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);
}