import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/challenge/data/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllChallengesUsecaseProvider = Provider<GetAllChallengesUsecase>((
  ref,
) {
  return GetAllChallengesUsecase(
    challengeRepository: ref.read(challengeRepositoryProvider),
  );
});

class GetAllChallengesUsecase
    implements UsecaseWithoutParams<List<ChallengeEntity>> {
  final IChallengeRepository _challengeRepository;
  GetAllChallengesUsecase({required IChallengeRepository challengeRepository})
    : _challengeRepository = challengeRepository;

  @override
  Future<Either<Failure, List<ChallengeEntity>>> call() {
    final challenges = _challengeRepository.getAllChallenges();
    return challenges;
  }
}
