import 'package:json_annotation/json_annotation.dart';
part 'leaderboard-entity.g.dart';

@JsonSerializable()
class LeaderboardEntity {
  @JsonKey(required: true, disallowNullValue: true)
  String userId;

  @JsonKey(required: true, disallowNullValue: true)
  String name;

  @JsonKey(required: true)
  String type;

  @JsonKey(required: true)
  String school;

  @JsonKey(required: true)
  int value;

  String? profilePicUrl;

  LeaderboardEntity({required this.userId, required this.name, required this.type,
  required this.school, required this.value, this.profilePicUrl});

  factory LeaderboardEntity.fromJson(Map<String, dynamic> json) => _$LeaderboardEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntityToJson(this);
}