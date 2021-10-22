// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reward _$RewardFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['rewardId', 'name', 'description'],
    disallowNullValues: const ['rewardId'],
  );
  return Reward(
    rewardId: json['rewardId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    mediaContentUrls: (json['mediaContentUrls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    elixirCost: json['elixirCost'] as int?,
    type: json['type'] as String?,
    status: json['status'] as String?,
    enabled: json['enabled'] as bool?,
    rewardStartTime: json['rewardStartTime'] == null
        ? null
        : DateTime.parse(json['rewardStartTime'] as String),
    rewardEndTime: json['rewardEndTime'] == null
        ? null
        : DateTime.parse(json['rewardEndTime'] as String),
    expiryDuration: json['expiryDuration'] as int?,
    expiryDate: json['expiryDate'] == null
        ? null
        : DateTime.parse(json['expiryDate'] as String),
    numClaimed: json['numClaimed'] as int?,
    maxClaimPerUser: json['maxClaimPerUser'] as int?,
    quantity: json['quantity'] as int?,
    discount: (json['discount'] as num?)?.toDouble(),
    organisation: json['organisation'] == null
        ? null
        : Organisation.fromJson(json['organisation'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RewardToJson(Reward instance) => <String, dynamic>{
      'rewardId': instance.rewardId,
      'name': instance.name,
      'description': instance.description,
      'mediaContentUrls': instance.mediaContentUrls,
      'elixirCost': instance.elixirCost,
      'type': instance.type,
      'status': instance.status,
      'enabled': instance.enabled,
      'rewardStartTime': instance.rewardStartTime?.toIso8601String(),
      'rewardEndTime': instance.rewardEndTime?.toIso8601String(),
      'expiryDuration': instance.expiryDuration,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'numClaimed': instance.numClaimed,
      'maxClaimPerUser': instance.maxClaimPerUser,
      'quantity': instance.quantity,
      'discount': instance.discount,
      'organisation': instance.organisation,
    };
