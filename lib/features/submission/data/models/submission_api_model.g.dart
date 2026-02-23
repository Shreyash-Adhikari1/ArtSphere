// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmissionApiModel _$SubmissionApiModelFromJson(Map<String, dynamic> json) =>
    SubmissionApiModel(
      submissionId: json['_id'] as String?,
      challengeId: json['challengeId'] as String,
      submitterId: json['submitterId'] as String,
      submittedPostId: PostConverter.fromJson(json['submittedPostId']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SubmissionApiModelToJson(SubmissionApiModel instance) =>
    <String, dynamic>{
      '_id': instance.submissionId,
      'challengeId': instance.challengeId,
      'submitterId': instance.submitterId,
      'submittedPostId': PostConverter.toJson(instance.submittedPostId),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
