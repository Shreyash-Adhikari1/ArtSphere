// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentApiModel _$CommentApiModelFromJson(Map<String, dynamic> json) =>
    CommentApiModel(
      commentId: json['_id'] as String?,
      postId: json['postId'] as String?,
      userId: CommentUserConverter.fromJson(json['userId']),
      commentText: json['commentText'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt(),
      likedBy: (json['likedBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentApiModelToJson(CommentApiModel instance) =>
    <String, dynamic>{
      '_id': instance.commentId,
      'postId': instance.postId,
      'userId': CommentUserConverter.toJson(instance.userId),
      'commentText': instance.commentText,
      'likeCount': instance.likeCount,
      'likedBy': instance.likedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
