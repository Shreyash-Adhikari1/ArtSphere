// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeUserApiModel _$ChallengeUserApiModelFromJson(
  Map<String, dynamic> json,
) => ChallengeUserApiModel(
  id: json['_id'] as String?,
  username: json['username'] as String?,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$ChallengeUserApiModelToJson(
  ChallengeUserApiModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'username': instance.username,
  'avatar': instance.avatar,
};
