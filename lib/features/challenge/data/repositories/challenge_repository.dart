import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/challenge/data/datasources/challenge_datasource.dart';
import 'package:artsphere/features/challenge/data/datasources/local/challenge_local_datasource.dart';
import 'package:artsphere/features/challenge/data/datasources/remote/challenge_remote_datasource.dart';
import 'package:artsphere/features/challenge/data/models/challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/create/create_challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/edit/edit_challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/hive/challenge_hive_model.dart';
import 'package:artsphere/features/challenge/domain/entities/challenge_entity.dart';
import 'package:artsphere/features/challenge/domain/repositories/challenge_repository.dart';
import 'package:artsphere/features/challenge/domain/usecases/create_challenge_usecase.dart';
import 'package:artsphere/features/challenge/domain/usecases/edit_challenge_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final challengeRepositoryProvider = Provider<IChallengeRepository>((ref) {
  return ChallengeRepository(
    challengeLocalDatasource: ref.read(challengeLocalDatasourceProvider),
    challengeRemoteDatasource: ref.read(challengeRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ChallengeRepository implements IChallengeRepository {
  final IChallengeRemoteDatasource _challengeRemoteDatasource;
  final IChallengeLocalDatasource _challengeLocalDatasource;
  final NetworkInfo _networkInfo;

  ChallengeRepository({
    required IChallengeRemoteDatasource challengeRemoteDatasource,
    required IChallengeLocalDatasource challengeLocalDatasource,
    required NetworkInfo networkInfo,
  }) : _challengeLocalDatasource = challengeLocalDatasource,
       _challengeRemoteDatasource = challengeRemoteDatasource,
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

        final entity = createdAPI.toEntity();

        // Optional: cache created challenge so it appears offline too
        if ((entity.challengeId ?? "").trim().isNotEmpty) {
          final hive = ChallengeHiveModel.fromEntity(entity);
          await _challengeLocalDatasource.cacheDiscoverChallenges([hive]);
        }

        return Right(entity);
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

        final entity = editedChallenge.toEntity();

        // Optional: update cache
        if ((entity.challengeId ?? "").trim().isNotEmpty) {
          final hive = ChallengeHiveModel.fromEntity(entity);
          await _challengeLocalDatasource.cacheDiscoverChallenges([hive]);
        }

        return Right(entity);
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

        // ✅ cache discover/all challenges
        final hiveList = challengeEntities
            .where((e) => (e.challengeId ?? "").trim().isNotEmpty)
            .map((e) => ChallengeHiveModel.fromEntity(e))
            .toList();

        await _challengeLocalDatasource.cacheDiscoverChallenges(hiveList);

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
      try {
        final cached = _challengeLocalDatasource.getCachedDiscoverChallenges();
        if (cached.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "No cached challenges available"),
          );
        }
        final entities = cached.map((c) => c.toEntity()).toList();
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
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
        final entity = challenge.toEntity();

        // ✅ cache details by id (store in same challenge box)
        if ((entity.challengeId ?? "").trim().isNotEmpty) {
          final hive = ChallengeHiveModel.fromEntity(entity);
          await _challengeLocalDatasource.cacheDiscoverChallenges([hive]);
        }

        return Right(entity);
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
      try {
        final cached = _challengeLocalDatasource.getCachedChallengeDetails(
          challengeId,
        );
        if (cached == null) {
          return Left(
            LocalDatabaseFailure(message: "No cached challenge details"),
          );
        }
        return Right(cached.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ChallengeEntity>>> getMyChallenges() async {
    if (await _networkInfo.isConnected) {
      try {
        final challenges = await _challengeRemoteDatasource.getMyChallenges();
        final challengeEntities = ChallengeApiModel.toEntityList(challenges);

        // ✅ cache my challenges too (optional but recommended)
        final hiveList = challengeEntities
            .where((e) => (e.challengeId ?? "").trim().isNotEmpty)
            .map((e) => ChallengeHiveModel.fromEntity(e))
            .toList();
        await _challengeLocalDatasource.cacheMyChallenges(hiveList);

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
      try {
        final cached = _challengeLocalDatasource.getCachedMyChallenges();
        if (cached.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "No cached challenges available"),
          );
        }
        final entities = cached.map((c) => c.toEntity()).toList();
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllMyChallenges() async {
    if (await _networkInfo.isConnected) {
      try {
        await _challengeRemoteDatasource.deleteAllMyChallenges();

        // Optional: clear cached "my challenges" list
        await _challengeLocalDatasource.cacheMyChallenges([]);

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
  Future<Either<Failure, bool>> deleteChallenge(String challengeId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _challengeRemoteDatasource.deleteChallenge(challengeId);

        // Optional: also refresh cached discover list next time.
        // (You could remove just this id if you add a helper, but not necessary.)
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
