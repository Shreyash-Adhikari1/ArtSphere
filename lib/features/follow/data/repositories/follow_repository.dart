import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/core/services/connectivity/network_info.dart';
import 'package:artsphere/features/follow/data/datasources/follow_datasource.dart';
import 'package:artsphere/features/follow/data/datasources/remote/follow_remote_datasource.dart';
import 'package:artsphere/features/follow/data/models/follow_api_model.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/repositories/follow_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followRepositoryProvider = Provider<IFollowRepository>((ref) {
  return FollowRepository(
    networkInfo: ref.read(networkInfoProvider),
    followRemoteDatasource: ref.read(followRemoteDatasourceProvider),
  );
});

class FollowRepository implements IFollowRepository {
  final NetworkInfo _networkInfo;
  final IFollowRemoteDatasource _followRemoteDatasource;
  FollowRepository({
    required NetworkInfo networkInfo,
    required IFollowRemoteDatasource followRemoteDatasource,
  }) : _followRemoteDatasource = followRemoteDatasource,
       _networkInfo = networkInfo;
  @override
  Future<Either<Failure, FollowEntity>> follow(String followingId) async {
    if (await _networkInfo.isConnected) {
      try {
        if (followingId.trim().isEmpty) {
          return Left(ApiFailure(message: "Invalid user id"));
        }
        final follow = await _followRemoteDatasource.followUser(followingId);
        return Right(follow.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to follow user",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required to follow user"));
    }
  }

  @override
  Future<Either<Failure, FollowEntity>> unfollow(String followingId) async {
    if (await _networkInfo.isConnected) {
      try {
        if (followingId.trim().isEmpty) {
          return Left(ApiFailure(message: "Invalid user id"));
        }
        final unfollow = await _followRemoteDatasource.unfollowUser(
          followingId,
        );
        return Right(unfollow.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to unfollow user",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to unfollow user"),
      );
    }
  }

  @override
  Future<Either<Failure, List<FollowEntity>>> getMyFollowers() async {
    if (await _networkInfo.isConnected) {
      try {
        final myFollowers = await _followRemoteDatasource.getMyFollowers();
        final myFollowersEntities = FollowApiModel.toEntityList(myFollowers);
        return Right(myFollowersEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to get followers",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get followers"),
      );
    }
  }

  @override
  Future<Either<Failure, List<FollowEntity>>> getMyFollowing() async {
    if (await _networkInfo.isConnected) {
      try {
        final myFollowing = await _followRemoteDatasource.getMyFollowing();
        final myFollowingEntities = FollowApiModel.toEntityList(myFollowing);
        return Right(myFollowingEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Failed to get following",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get following"),
      );
    }
  }

  @override
  Future<Either<Failure, List<FollowEntity>>> getUsersFollowers(
    String userId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        if (userId.trim().isEmpty) {
          return Left(ApiFailure(message: "Invalid user id"));
        }
        final userFollowers = await _followRemoteDatasource.getUsersFollowers(
          userId,
        );
        final userFollowersEntities = FollowApiModel.toEntityList(
          userFollowers,
        );
        return Right(userFollowersEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to get users followers",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get users followers"),
      );
    }
  }

  @override
  Future<Either<Failure, List<FollowEntity>>> getUsersFollowing(
    String userId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        if (userId.trim().isEmpty) {
          return Left(ApiFailure(message: "Invalid user id"));
        }
        final userFollowing = await _followRemoteDatasource.getUsersFollowing(
          userId,
        );
        final userFollowingEntities = FollowApiModel.toEntityList(
          userFollowing,
        );
        return Right(userFollowingEntities);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to get users following",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required to get users following"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> getIsFollowingStatus(
    String targetUserId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final res = await _followRemoteDatasource.getIsFollowingStatus(
          targetUserId,
        );
        return Right(res);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data["message"] ?? "Failed to fetch follow status",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet required"));
    }
  }
}
