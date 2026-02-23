// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submitted_post_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmittedPostApiModel _$SubmittedPostApiModelFromJson(
  Map<String, dynamic> json,
) => SubmittedPostApiModel(
  id: json['_id'] as String?,
  author: AuthorConverter.fromJson(json['author']),
  media: json['media'] as String?,
  caption: json['caption'] as String?,
  likeCount: (json['likeCount'] as num?)?.toInt(),
  commentCount: (json['commentCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$SubmittedPostApiModelToJson(
  SubmittedPostApiModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'author': AuthorConverter.toJson(instance.author),
  'media': instance.media,
  'caption': instance.caption,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
};
