// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeApiModel _$ChallengeApiModelFromJson(Map<String, dynamic> json) =>
    ChallengeApiModel(
      challengeId: json['_id'] as String?,
      challengerId: ChallengeUserConverter.fromJson(json['challengerId']),
      challengeDescription: json['challengeDescription'] as String?,
      challengeTitle: json['challengeTitle'] as String?,
      challengeMedia: json['challengeMedia'] as String?,
      status: json['status'] as String?,
      submissionCount: (json['submissionCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      endsAt: json['endsAt'] == null
          ? null
          : DateTime.parse(json['endsAt'] as String),
      submitters: (json['submitters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      submittedPosts: (json['submittedPosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChallengeApiModelToJson(ChallengeApiModel instance) =>
    <String, dynamic>{
      '_id': instance.challengeId,
      'challengerId': ChallengeUserConverter.toJson(instance.challengerId),
      'challengeTitle': instance.challengeTitle,
      'challengeDescription': instance.challengeDescription,
      'challengeMedia': instance.challengeMedia,
      'submissionCount': instance.submissionCount,
      'submitters': instance.submitters,
      'submittedPosts': instance.submittedPosts,
      'status': instance.status,
      'endsAt': instance.endsAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
