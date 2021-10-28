import 'package:json_annotation/json_annotation.dart';
import 'package:youthapp/models/organisation.dart';
import 'package:youthapp/models/user.dart';
part 'comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(required: true, disallowNullValue: true)
  String commentId;

  @JsonKey(required: true)
  String content;

  User? mpUser;
  Organisation? organisation;
  String? parentComment;

  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  bool? wasEdited;
  int? numLikes;
  int? numDislikes;
  int? numComments;

  bool? hasLiked;
  bool? hasDisliked;

  Comment({required this.commentId, required this.content,
    this.mpUser, this.organisation, this.parentComment,
    this.status, this.createdAt, this.updatedAt,
    this.wasEdited, this.numLikes, this.numDislikes, this.numComments,
    this.hasLiked, this.hasDisliked,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

}