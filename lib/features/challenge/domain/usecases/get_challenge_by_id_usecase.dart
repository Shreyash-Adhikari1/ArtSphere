import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/challenge/data/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetChallengeByIdUsecaseParams extends Equatable {
  final String challengeId;
  const GetChallengeByIdUsecaseParams({required this.challengeId});
  @override
  List<Object?> get props => [challengeId];
}

final getChallengeByIdUsecaseProvider = Provider<GetChallengeByIdUsecase>((
  ref,
) {
  return GetChallengeByIdUsecase(
    challengeRepository: ref.read(challengeRepositoryProvider),
  );
});

class GetChallengeByIdUsecase
    implements
        UsecaseWithParams<ChallengeEntity, GetChallengeByIdUsecaseParams> {
  final IChallengeRepository _challengeRepository;
  GetChallengeByIdUsecase({required IChallengeRepository challengeRepository})
    : _challengeRepository = challengeRepository;
  @override
  Future<Either<Failure, ChallengeEntity>> call(
    GetChallengeByIdUsecaseParams params,
  ) {
    return _challengeRepository.getChallengeById(params.challengeId);
  }
}
