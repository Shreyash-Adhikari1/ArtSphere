import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:dartz/dartz.dart';

abstract interface class IChallengeRepository {
  // Create and Update
  Future<Either<Failure, ChallengeEntity>> createChallenge({
    required CreateChallengeUsecaseParams params,
  });
  Future<Either<Failure, ChallengeEntity>> editChallenge(
    EditChallengeUsecaseParams params,
  );

  // Get
  Future<Either<Failure, List<ChallengeEntity>>> getAllChallenges();
  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges();
  Future<Either<Failure, ChallengeEntity>> getChallengeById(String challengeId);
  // Future<Either<Failure, List<ChallengeEntity>>> getChallengesByUser(
  //   String userId,
  // );

  // Delete
  Future<Either<Failure, bool>> deleteChallenge(String challengeId);
  Future<Either<Failure, bool>> deleteAllMyChallenges();
}
