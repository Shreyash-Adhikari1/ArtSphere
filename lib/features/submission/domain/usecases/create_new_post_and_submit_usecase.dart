import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/submission/data/repositories/submission_repository.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:artsphere/features/submission/domain/repositories/submission_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateNewPostAndSubmitUsecaseParams extends Equatable {
  final String challengeId;
  final PostEntity post;
  final String mediaPath;

  const CreateNewPostAndSubmitUsecaseParams({
    required this.challengeId,
    required this.post,
    required this.mediaPath,
  });

  @override
  List<Object?> get props => [challengeId, post, mediaPath];
}

final createNewPostAndSubmitUsecaseProvider =
    Provider<CreateNewPostAndSubmitUsecase>((ref) {
      return CreateNewPostAndSubmitUsecase(
        submissionRepository: ref.read(submissionRepositoryProvider),
      );
    });

class CreateNewPostAndSubmitUsecase
    implements
        UsecaseWithParams<
          SubmissionEntity,
          CreateNewPostAndSubmitUsecaseParams
        > {
  final ISubmissionRepository _submissionRepository;

  CreateNewPostAndSubmitUsecase({
    required ISubmissionRepository submissionRepository,
  }) : _submissionRepository = submissionRepository;

  @override
  Future<Either<Failure, SubmissionEntity>> call(
    CreateNewPostAndSubmitUsecaseParams params,
  ) {
    return _submissionRepository.createNewPostAndSubmit(
      challengeId: params.challengeId,
      post: params.post,
      mediaPath: params.mediaPath,
    );
  }
}
