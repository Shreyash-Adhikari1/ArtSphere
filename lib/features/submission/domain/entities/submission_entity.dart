import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:equatable/equatable.dart';

class SubmissionEntity extends Equatable {
  final String? submissionId;
  final String challengeId;
  final String submitterId;
  final PostEntity submittedPostId;
  final DateTime? createdAt;

  const SubmissionEntity({
    this.submissionId,
    required this.challengeId,
    required this.submitterId,
    required this.submittedPostId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    submissionId,
    challengeId,
    submitterId,
    submittedPostId,
    createdAt,
  ];
}
