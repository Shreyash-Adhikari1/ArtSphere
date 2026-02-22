import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/challenge/data/datasources/challenge_datasource.dart';
import 'package:artsphere/features/challenge/data/datasources/remote/challenge_remote_datasource.dart';
import 'package:artsphere/features/challenge/data/models/challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/create/create_challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/edit/edit_challenge_api_model.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final challengeRepositoryProvider = Provider<IChallengeRepository>((ref) {
  return ChallengeRepository(
    challengeRemoteDatasource: ref.read(challengeRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ChallengeRepository implements IChallengeRepository {
  final IChallengeRemoteDatasource _challengeRemoteDatasource;
  final NetworkInfo _networkInfo;
  ChallengeRepository({
    required IChallengeRemoteDatasource challengeRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _challengeRemoteDatasource = challengeRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ChallengeEntity>> createChallenge({
    required CreateChallengeUsecaseParams params,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final createChallengeAPI = CreateChallengeApiModel(
          challengeTitle: params.challengeTitle,
          challengeDescription: params.challengeDescription,
          endsAt: params.endsAt,
        );
        final createdAPI = await _challengeRemoteDatasource.createChallenge(
          createChallengeAPI,
          params.challengeMedia,
        );
        return Right(createdAPI.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to create challenge",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to create challenge"),
      );
    }
  }

  @override
  Future<Either<Failure, ChallengeEntity>> editChallenge(
    EditChallengeUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        if (params.challengeId.trim().isEmpty) {
          return Left(ApiFailure(message: "ChallengeId is required"));
        }
        if (params.challengeTitle == null &&
            params.challengeDescription == null &&
            params.endsAt == null) {
          return Left(ApiFailure(message: "Nothing to update"));
        }
        final editAPI = EditChallengeApiModel(
          challengeTitle: params.challengeTitle,
          challengeDescription: params.challengeDescription,
          endsAt: params.endsAt,
        );
        final editedChallenge = await _challengeRemoteDatasource.editChallenge(
          params.challengeId,
          editAPI,
        );
        return Right(editedChallenge.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to edit challenge",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to edit challenge"),
      );
    }
  }

  @override
  Future<Either<Failure, List<ChallengeEntity>>> getAllChallenges() async {
    if (await _networkInfo.isConnected) {
      try {
        final challenges = await _challengeRemoteDatasource.getAllChallenges();
        final challengeEntities = ChallengeApiModel.toEntityList(challenges);
        return Right(challengeEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to get all challenges",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get all challenges"),
      );
    }
  }

  @override
  Future<Either<Failure, ChallengeEntity>> getChallengeById(
    String challengeId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final challenge = await _challengeRemoteDatasource.getChallengeById(
          challengeId,
        );
        final challengeEntity = challenge.toEntity();
        return Right(challengeEntity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to get challenge",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get challenge"),
      );
    }
  }

  @override
  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges() async {
    if (await _networkInfo.isConnected) {
      try {
        final challenges = await _challengeRemoteDatasource.getMyChallenges();
        final challengeEntities = ChallengeApiModel.toEntityList(challenges);
        return Right(challengeEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to get challenges",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get challenges"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllMyChallenges() async {
    if (await _networkInfo.isConnected) {
      try {
        await _challengeRemoteDatasource.deleteAllMyChallenges();
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ??
                "Failed to delete all challenges",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to delete all challenges"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteChalllenge(String challengeId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _challengeRemoteDatasource.deleteChallenge(challengeId);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to delete challenge",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required delete challenge"),
      );
    }
  }
}
