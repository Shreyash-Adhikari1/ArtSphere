import 'package:artsphere/core/constants/hive_table_constant.dart';
import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'challenge_hive_model.g.dart';

// dart run build_runner build -d

@HiveType(typeId: HiveTableConstant.challengeTypeId)
class ChallengeHiveModel extends HiveObject {
  @HiveField(0)
  final String challengeId;

  @HiveField(1)
  final String? challengeTitle;

  @HiveField(2)
  final String? challengeDescription;

  @HiveField(3)
  final String? challengeMedia;

  @HiveField(4)
  final DateTime? endsAt;

  @HiveField(5)
  final int? submissionCount;

  // Challenger preview (avoid making separate model)
  @HiveField(6)
  final String? challengerId;

  @HiveField(7)
  final String? challengerUsername;

  @HiveField(8)
  final String? challengerAvatar;

  @HiveField(9)
  final DateTime? createdAt;

  ChallengeHiveModel({
    required this.challengeId,
    this.challengeTitle,
    this.challengeDescription,
    this.challengeMedia,
    this.endsAt,
    this.submissionCount,
    this.challengerId,
    this.challengerUsername,
    this.challengerAvatar,
    this.createdAt,
  });

  ChallengeEntity toEntity() {
    return ChallengeEntity(
      challengeId: challengeId,
      challengeTitle: challengeTitle,
      challengeDescription: challengeDescription,
      challengeMedia: challengeMedia,
      endsAt: endsAt,
      submissionCount: submissionCount,
      challengerId: challengerId == null && challengerUsername == null
          ? null
          : UserEntity.preview(
              userId: challengerId,
              username: challengerUsername ?? "",
              avatar: challengerAvatar,
            ),
      createdAt: createdAt,
    );
  }

  factory ChallengeHiveModel.fromEntity(ChallengeEntity c) {
    return ChallengeHiveModel(
      challengeId: c.challengeId ?? "",
      challengeTitle: c.challengeTitle,
      challengeDescription: c.challengeDescription,
      challengeMedia: c.challengeMedia,
      endsAt: c.endsAt,
      submissionCount: c.submissionCount,
      challengerId: c.challengerId?.userId,
      challengerUsername: c.challengerId?.username,
      challengerAvatar: c.challengerId?.avatar,
      createdAt: c.createdAt,
    );
  }
}
