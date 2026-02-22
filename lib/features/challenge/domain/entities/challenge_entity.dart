import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class ChallengeEntity extends Equatable {
  final String? challengeId;

  final UserEntity? challengerId;
  final String? challengeTitle;
  final String? challengeDescription;
  final String? challengeMedia;

  final int? submissionCount;
  final String? status;
  final DateTime? endsAt;

  final DateTime? createdAt;

  const ChallengeEntity({
    this.challengeId,
    this.challengerId,
    this.challengeTitle,
    this.challengeDescription,
    this.challengeMedia,
    this.submissionCount,
    this.status,
    this.createdAt,
    this.endsAt,
  });

  @override
  List<Object?> get props => [
    challengeId,
    challengerId,
    challengeTitle,
    challengeDescription,
    challengeMedia,
    submissionCount,
    status,
    createdAt,
    endsAt,
  ];
}
