// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowUserApiModel _$FollowUserApiModelFromJson(Map<String, dynamic> json) =>
    FollowUserApiModel(
      id: json['_id'] as String?,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$FollowUserApiModelToJson(FollowUserApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'avatar': instance.avatar,
    };
