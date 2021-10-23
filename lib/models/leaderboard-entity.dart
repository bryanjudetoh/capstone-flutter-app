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

  int? ranking;

  LeaderboardEntity({required this.userId, required this.name, required this.type,
  required this.school, required this.value, this.profilePicUrl, this.ranking});

  factory LeaderboardEntity.fromJson(Map<String, dynamic> json) => _$LeaderboardEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntityToJson(this);
}