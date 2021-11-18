import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/user.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/models/activity.dart';
import 'package:youthapp/models/reward.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  @JsonKey(required: true, disallowNullValue: true)
  String postId;

  @JsonKey(required: true)
  String content;

  List<String>? mediaContentUrls;

  User? mpUser;
  Organisation? organisation;

  Activity? sharedActivity;
  Reward? sharedReward;

  bool? wasEdited;
  DateTime? createdAt;
  DateTime? updatedAt;

  int? numLikes;
  int? numDislikes;
  int? numComments;

  bool? hasLiked;
  bool? hasDisliked;

  Post({required this.postId, required this.content, this.mediaContentUrls,
    this.mpUser, this.organisation, this.sharedActivity, this.sharedReward,
    this.wasEdited, this.createdAt, this.updatedAt,
    this.numLikes, this.numDislikes, this.numComments, this.hasLiked, this.hasDisliked,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

}