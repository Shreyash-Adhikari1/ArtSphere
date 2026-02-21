// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowApiModel _$FollowApiModelFromJson(Map<String, dynamic> json) =>
    FollowApiModel(
      followId: json['_id'] as String?,
      follower: FollowUserConverter.fromJson(json['follower']),
      following: FollowUserConverter.fromJson(json['following']),
      isFollowActive: json['isFollowActive'] as bool?,
      isFollowedByMe: json['isFollowedByMe'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FollowApiModelToJson(FollowApiModel instance) =>
    <String, dynamic>{
      '_id': instance.followId,
      'follower': FollowUserConverter.toJson(instance.follower),
      'following': FollowUserConverter.toJson(instance.following),
      'isFollowActive': instance.isFollowActive,
      'isFollowedByMe': instance.isFollowedByMe,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
