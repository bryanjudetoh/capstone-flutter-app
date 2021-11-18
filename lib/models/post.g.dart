// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['postId', 'content'],
    disallowNullValues: const ['postId'],
  );
  return Post(
    postId: json['postId'] as String,
    content: json['content'] as String,
    mediaContentUrls: (json['mediaContentUrls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    mpUser: json['mpUser'] == null
        ? null
        : User.fromJson(json['mpUser'] as Map<String, dynamic>),
    organisation: json['organisation'] == null
        ? null
        : Organisation.fromJson(json['organisation'] as Map<String, dynamic>),
    sharedActivity: json['sharedActivity'] == null
        ? null
        : Activity.fromJson(json['sharedActivity'] as Map<String, dynamic>),
    sharedReward: json['sharedReward'] == null
        ? null
        : Reward.fromJson(json['sharedReward'] as Map<String, dynamic>),
    wasEdited: json['wasEdited'] as bool?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    numLikes: json['numLikes'] as int?,
    numDislikes: json['numDislikes'] as int?,
    numComments: json['numComments'] as int?,
    hasLiked: json['hasLiked'] as bool?,
    hasDisliked: json['hasDisliked'] as bool?,
  );
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'postId': instance.postId,
      'content': instance.content,
      'mediaContentUrls': instance.mediaContentUrls,
      'mpUser': instance.mpUser,
      'organisation': instance.organisation,
      'sharedActivity': instance.sharedActivity,
      'sharedReward': instance.sharedReward,
      'wasEdited': instance.wasEdited,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'numLikes': instance.numLikes,
      'numDislikes': instance.numDislikes,
      'numComments': instance.numComments,
      'hasLiked': instance.hasLiked,
      'hasDisliked': instance.hasDisliked,
    };
