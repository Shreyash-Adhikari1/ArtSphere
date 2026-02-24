import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ISubmissionRepository {
  Future<Either<Failure, SubmissionEntity>> submitExistingPost({
    required String challengeId,
    required String postId,
  });
  Future<Either<Failure, SubmissionEntity>> createNewPostAndSubmit({
    required String challengeId,
    required PostEntity post,
    required String mediaPath,
  });

  Future<Either<Failure, List<SubmissionEntity>>> getSubmissionsForChallenge(
    String challengeId,
  );

  Future<Either<Failure, bool>> deleteSubmission(String submissionId);
}
