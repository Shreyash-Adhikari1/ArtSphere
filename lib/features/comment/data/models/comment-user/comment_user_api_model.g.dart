// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentUserApiModel _$CommentUserApiModelFromJson(Map<String, dynamic> json) =>
    CommentUserApiModel(
      id: json['_id'] as String?,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$CommentUserApiModelToJson(
  CommentUserApiModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'username': instance.username,
  'avatar': instance.avatar,
};
