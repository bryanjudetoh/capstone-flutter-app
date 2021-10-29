// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend-request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['friendRequestId', 'requestDate', 'mpUser'],
    disallowNullValues: const ['friendRequestId'],
  );
  return FriendRequest(
    friendRequestId: json['friendRequestId'] as String,
    requestDate: DateTime.parse(json['requestDate'] as String),
    mpUser: User.fromJson(json['mpUser'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'friendRequestId': instance.friendRequestId,
      'requestDate': instance.requestDate.toIso8601String(),
      'mpUser': instance.mpUser,
    };
