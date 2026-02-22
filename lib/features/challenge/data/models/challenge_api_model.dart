import 'package:artsphere/features/challenge/data/models/helper/challenge_user_api_model.dart';
import 'package:artsphere/features/challenge/data/models/helper/challenge_user_converter.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_api_model.g.dart';

@JsonSerializable()
class ChallengeApiModel {
  @JsonKey(name: "_id")
  final String? challengeId;
  @JsonKey(
    fromJson: ChallengeUserConverter.fromJson,
    toJson: ChallengeUserConverter.toJson,
  )
  final ChallengeUserApiModel? challengerId;

  final String? challengeTitle;
  final String? challengeDescription;
  final String? challengeMedia;

  final int? submissionCount;
  final List<String>? submitters;
  final List<String>? submittedPosts;
  final String? status;
  final DateTime? endsAt;
  final DateTime? createdAt;

  const ChallengeApiModel({
    this.challengeId,
    this.challengerId,
    this.challengeDescription,
    this.challengeTitle,
    this.challengeMedia,
    this.status,
    this.submissionCount,
    this.createdAt,
    this.endsAt,
    this.submitters,
    this.submittedPosts,
  });

  factory ChallengeApiModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeApiModelToJson(this);

  ChallengeEntity toEntity() {
    return ChallengeEntity(
      challengeId: challengeId,
      challengerId: challengerId?.toEntity(),
      challengeTitle: challengeTitle,
      challengeDescription: challengeDescription,
      challengeMedia: challengeMedia,
      status: status,
      submissionCount: submissionCount,
      createdAt: createdAt,
      endsAt: endsAt,
    );
  }

  factory ChallengeApiModel.fromEntity(ChallengeEntity challenge) {
    return ChallengeApiModel(
      challengeId: challenge.challengeId,
      challengerId: challenge.challengerId == null
          ? null
          : ChallengeUserApiModel(
              id: challenge.challengerId!.userId,
              username: challenge.challengerId!.username,
              avatar: challenge.challengerId!.avatar,
            ),
      challengeTitle: challenge.challengeTitle,
      challengeDescription: challenge.challengeDescription,
      challengeMedia: challenge.challengeMedia,
      status: challenge.status,
      submissionCount: challenge.submissionCount,
      createdAt: challenge.createdAt,
      endsAt: challenge.endsAt,
    );
  }

  // To Entity List
  static List<ChallengeEntity> toEntityList(List<ChallengeApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
