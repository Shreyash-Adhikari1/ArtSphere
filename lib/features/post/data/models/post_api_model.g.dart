// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiModel _$PostApiModelFromJson(Map<String, dynamic> json) => PostApiModel(
  postId: json['_id'] as String?,
  author: AuthorConverter.fromJson(json['author']),
  media: json['media'] as String?,
  mediaType: json['mediaType'] as String?,
  caption: json['caption'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  visibility: json['visibility'] as String?,
  likeCount: (json['likeCount'] as num?)?.toInt(),
  likedBy: (json['likedBy'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  commentCount: (json['commentCount'] as num?)?.toInt(),
  commentedBy: (json['commentedBy'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isChallengeSubmission: json['isChallengeSubmission'] as bool?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PostApiModelToJson(PostApiModel instance) =>
    <String, dynamic>{
      '_id': instance.postId,
      'author': AuthorConverter.toJson(instance.author),
      'media': instance.media,
      'mediaType': instance.mediaType,
      'caption': instance.caption,
      'tags': instance.tags,
      'visibility': instance.visibility,
      'likeCount': instance.likeCount,
      'likedBy': instance.likedBy,
      'commentCount': instance.commentCount,
      'commentedBy': instance.commentedBy,
      'isChallengeSubmission': instance.isChallengeSubmission,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
