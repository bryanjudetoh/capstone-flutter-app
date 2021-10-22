import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/organisation.dart';
part 'reward.g.dart';

@JsonSerializable()
class Reward {
  @JsonKey(required: true, disallowNullValue: true)
  String rewardId;

  @JsonKey(required: true)
  String name;

  @JsonKey(required: true)
  String description;
  List<String>? mediaContentUrls;
  int? elixirCost;
  String? type;
  String? status;
  bool? enabled;

  DateTime? rewardStartTime;
  DateTime? rewardEndTime;
  int? expiryDuration;
  DateTime? expiryDate;

  int? numClaimed;
  int? maxClaimPerUser;
  int? quantity;
  double? discount;

  Organisation? organisation;

  Reward({required this.rewardId, required this.name, required this.description, this.mediaContentUrls, this.elixirCost,
  this.type, this.status, this.enabled, this.rewardStartTime, this.rewardEndTime, this.expiryDuration,
  this.expiryDate, this.numClaimed, this.maxClaimPerUser, this.quantity, this.discount, this.organisation});

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);

  Map<String, dynamic> toJson() => _$RewardToJson(this);
}