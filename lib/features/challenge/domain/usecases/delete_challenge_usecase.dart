import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/usecases/app_usecase.dart';
import 'package:artsphere/features/challenge/data/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteChallengeUsecaseParams extends Equatable {
  final String challengeId;
  const DeleteChallengeUsecaseParams({required this.challengeId});
  @override
  List<Object?> get props => [challengeId];
}

final deleteChallengeUsecaseProvider = Provider<DeleteChallengeUsecase>((ref) {
  return DeleteChallengeUsecase(
    challengeRepository: ref.read(challengeRepositoryProvider),
  );
});

class DeleteChallengeUsecase
    implements UsecaseWithParams<bool, DeleteChallengeUsecaseParams> {
  final IChallengeRepository _challengeRepository;
  DeleteChallengeUsecase({required IChallengeRepository challengeRepository})
    : _challengeRepository = challengeRepository;
  @override
  Future<Either<Failure, bool>> call(DeleteChallengeUsecaseParams params) {
    return _challengeRepository.deleteChallenge(params.challengeId);
  }
}
