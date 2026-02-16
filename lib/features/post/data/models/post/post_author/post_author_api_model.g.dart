// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_author_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAuthorApiModel _$PostAuthorApiModelFromJson(Map<String, dynamic> json) =>
    PostAuthorApiModel(
      id: json['_id'] as String?,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$PostAuthorApiModelToJson(PostAuthorApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'avatar': instance.avatar,
    };
