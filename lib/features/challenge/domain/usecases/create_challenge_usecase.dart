import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/challenge/data/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateChallengeUsecaseParams extends Equatable {
  final String challengeTitle;
  final String challengeDescription;
  final String challengeMedia;
  final DateTime endsAt;
  const CreateChallengeUsecaseParams({
    required this.challengeTitle,
    required this.challengeDescription,
    required this.challengeMedia,
    required this.endsAt,
  });
  @override
  List<Object?> get props => [
    challengeTitle,
    challengeDescription,
    challengeMedia,
    endsAt,
  ];
}

final createChallengeUsecaseProvider = Provider<CreateChallengeUsecase>((ref) {
  return CreateChallengeUsecase(
    challengeRepository: ref.read(challengeRepositoryProvider),
  );
});

class CreateChallengeUsecase
    implements
        UsecaseWithParams<ChallengeEntity, CreateChallengeUsecaseParams> {
  final IChallengeRepository _challengeRepository;
  CreateChallengeUsecase({required IChallengeRepository challengeRepository})
    : _challengeRepository = challengeRepository;

  @override
  Future<Either<Failure, ChallengeEntity>> call(
    CreateChallengeUsecaseParams params,
  ) {
    return _challengeRepository.createChallenge(params: params);
  }
}
