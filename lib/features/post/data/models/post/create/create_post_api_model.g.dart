// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostApiModel _$CreatePostApiModelFromJson(Map<String, dynamic> json) =>
    CreatePostApiModel(
      caption: json['caption'] as String?,
      mediaType: json['mediaType'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      visibility: json['visibility'] as String?,
    );

Map<String, dynamic> _$CreatePostApiModelToJson(CreatePostApiModel instance) =>
    <String, dynamic>{
      'caption': instance.caption,
      'mediaType': instance.mediaType,
      'tags': instance.tags,
      'visibility': instance.visibility,
    };
