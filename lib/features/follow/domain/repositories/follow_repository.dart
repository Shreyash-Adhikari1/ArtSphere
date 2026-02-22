import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IFollowRepository {
  // follow/unfollow methods
  Future<Either<Failure, FollowEntity>> follow(String followingId);
  Future<Either<Failure, FollowEntity>> unfollow(String followingId);

  // follow get methods
  Future<Either<Failure, List<FollowEntity>>> getMyFollowers();
  Future<Either<Failure, List<FollowEntity>>> getMyFollowing();
  Future<Either<Failure, List<FollowEntity>>> getUsersFollowers(String userId);
  Future<Either<Failure, List<FollowEntity>>> getUsersFollowing(String userId);

  Future<Either<Failure, bool>> getIsFollowingStatus(String targetUserId);
}
