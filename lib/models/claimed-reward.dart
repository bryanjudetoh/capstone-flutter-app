import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/reward.dart';
part 'claimed-reward.g.dart';

@JsonSerializable()
class ClaimedReward {
  @JsonKey(required: true, disallowNullValue: true)
  String claimedRewardId;

  @JsonKey(required: true)
  Reward reward;

  String? status;
  DateTime? claimDate;
  DateTime? expiryDate;


  ClaimedReward({required this.claimedRewardId, required this.reward,
  this.status, this.claimDate, this.expiryDate});

  factory ClaimedReward.fromJson(Map<String, dynamic> json) => _$ClaimedRewardFromJson(json);

  Map<String, dynamic> toJson() => _$ClaimedRewardToJson(this);
}