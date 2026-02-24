import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/submission/data/repositories/submission_repository.dart';
import 'package:artsphere/features/submission/domain/entities/submission_entity.dart';
import 'package:artsphere/features/submission/domain/repositories/submission_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetSubmissionsForChallengeUsecaseParams extends Equatable {
  final String challengeId;
  const GetSubmissionsForChallengeUsecaseParams({required this.challengeId});
  @override
  List<Object?> get props => [challengeId];
}

final getSubmissionsForChallengeUsecaseProvider =
    Provider<GetSubmissionsForChallengeUsecase>((ref) {
      return GetSubmissionsForChallengeUsecase(
        submissionRepository: ref.read(submissionRepositoryProvider),
      );
    });

class GetSubmissionsForChallengeUsecase
    implements
        UsecaseWithParams<
          List<SubmissionEntity>,
          GetSubmissionsForChallengeUsecaseParams
        > {
  final ISubmissionRepository _submissionRepository;
  GetSubmissionsForChallengeUsecase({
    required ISubmissionRepository submissionRepository,
  }) : _submissionRepository = submissionRepository;
  @override
  Future<Either<Failure, List<SubmissionEntity>>> call(
    GetSubmissionsForChallengeUsecaseParams params,
  ) {
    return _submissionRepository.getSubmissionsForChallenge(params.challengeId);
  }
}
