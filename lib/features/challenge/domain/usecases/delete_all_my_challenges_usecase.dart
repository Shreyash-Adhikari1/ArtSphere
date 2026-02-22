import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/challenge/data/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteAllMyChallengesUsecaseProvider =
    Provider<DeleteAllMyChallengesUsecase>((ref) {
      return DeleteAllMyChallengesUsecase(
        challengeRepository: ref.read(challengeRepositoryProvider),
      );
    });

class DeleteAllMyChallengesUsecase implements UsecaseWithoutParams<bool> {
  final IChallengeRepository _challengeRepository;
  DeleteAllMyChallengesUsecase({
    required IChallengeRepository challengeRepository,
  }) : _challengeRepository = challengeRepository;
  @override
  Future<Either<Failure, bool>> call() {
    return _challengeRepository.deleteAllMyChallenges();
  }
}
