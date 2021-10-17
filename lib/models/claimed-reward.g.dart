// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claimed-reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimedReward _$ClaimedRewardFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['claimedRewardId', 'reward'],
    disallowNullValues: const ['claimedRewardId'],
  );
  return ClaimedReward(
    claimedRewardId: json['claimedRewardId'] as String,
    reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
    status: json['status'] as String?,
    claimDate: json['claimDate'] == null
        ? null
        : DateTime.parse(json['claimDate'] as String),
    expiryDate: json['expiryDate'] == null
        ? null
        : DateTime.parse(json['expiryDate'] as String),
  );
}

Map<String, dynamic> _$ClaimedRewardToJson(ClaimedReward instance) =>
    <String, dynamic>{
      'claimedRewardId': instance.claimedRewardId,
      'reward': instance.reward,
      'status': instance.status,
      'claimDate': instance.claimDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
    };
