import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/submission/data/repositories/submission_repository.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:artsphere/features/submission/domain/repositories/submission_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitExistingPostUsecaseParams extends Equatable {
  final String challengeId;
  final String postId;
  const SubmitExistingPostUsecaseParams({
    required this.challengeId,
    required this.postId,
  });

  @override
  List<Object?> get props => [challengeId, postId];
}

final submitExistingPostUsecaseProvider = Provider<SubmitExistingPostUsecase>((
  ref,
) {
  return SubmitExistingPostUsecase(
    submissionRepository: ref.read(submissionRepositoryProvider),
  );
});

class SubmitExistingPostUsecase
    implements
        UsecaseWithParams<SubmissionEntity, SubmitExistingPostUsecaseParams> {
  final ISubmissionRepository _submissionRepository;
  SubmitExistingPostUsecase({
    required ISubmissionRepository submissionRepository,
  }) : _submissionRepository = submissionRepository;
  @override
  Future<Either<Failure, SubmissionEntity>> call(
    SubmitExistingPostUsecaseParams params,
  ) {
    return _submissionRepository.submitExistingPost(
      challengeId: params.challengeId,
      postId: params.postId,
    );
  }
}
