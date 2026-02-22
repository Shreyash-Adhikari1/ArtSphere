// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_challenge_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditChallengeApiModel _$EditChallengeApiModelFromJson(
  Map<String, dynamic> json,
) => EditChallengeApiModel(
  challengeTitle: json['challengeTitle'] as String?,
  challengeDescription: json['challengeDescription'] as String?,
  endsAt: json['endsAt'] == null
      ? null
      : DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$EditChallengeApiModelToJson(
  EditChallengeApiModel instance,
) => <String, dynamic>{
  'challengeTitle': ?instance.challengeTitle,
  'challengeDescription': ?instance.challengeDescription,
  'endsAt': ?instance.endsAt?.toIso8601String(),
};
