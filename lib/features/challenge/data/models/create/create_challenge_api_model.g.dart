// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_challenge_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateChallengeApiModel _$CreateChallengeApiModelFromJson(
  Map<String, dynamic> json,
) => CreateChallengeApiModel(
  challengeTitle: json['challengeTitle'] as String,
  challengeDescription: json['challengeDescription'] as String,
  endsAt: DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$CreateChallengeApiModelToJson(
  CreateChallengeApiModel instance,
) => <String, dynamic>{
  'challengeTitle': instance.challengeTitle,
  'challengeDescription': instance.challengeDescription,
  'endsAt': instance.endsAt.toIso8601String(),
};
