import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/user.dart';
part 'friend-request.g.dart';

@JsonSerializable()
class FriendRequest {
  @JsonKey(required: true, disallowNullValue: true)
  String friendRequestId;

  @JsonKey(required: true)
  DateTime requestDate;

  @JsonKey(required: true)
  User mpUser;

  FriendRequest({required this.friendRequestId, required this.requestDate, required this.mpUser});

  factory FriendRequest.fromJson(Map<String, dynamic> json) => _$FriendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);
}