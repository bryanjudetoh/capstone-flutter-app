// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['commentId', 'content'],
    disallowNullValues: const ['commentId'],
  );
  return Comment(
    commentId: json['commentId'] as String,
    content: json['content'] as String,
    mpUser: json['mpUser'] == null
        ? null
        : User.fromJson(json['mpUser'] as Map<String, dynamic>),
    organisation: json['organisation'] == null
        ? null
        : Organisation.fromJson(json['organisation'] as Map<String, dynamic>),
    parentComment: json['parentComment'] as String?,
    status: json['status'] as String?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    wasEdited: json['wasEdited'] as bool?,
    numLikes: json['numLikes'] as int?,
    numDislikes: json['numDislikes'] as int?,
    numComments: json['numComments'] as int?,
    hasLiked: json['hasLiked'] as bool?,
    hasDisliked: json['hasDisliked'] as bool?,
  );
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'commentId': instance.commentId,
      'content': instance.content,
      'mpUser': instance.mpUser,
      'organisation': instance.organisation,
      'parentComment': instance.parentComment,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'wasEdited': instance.wasEdited,
      'numLikes': instance.numLikes,
      'numDislikes': instance.numDislikes,
      'numComments': instance.numComments,
      'hasLiked': instance.hasLiked,
      'hasDisliked': instance.hasDisliked,
    };
