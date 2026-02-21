import 'package:artsphere/features/follow/data/models/follow_api_model.dart';

abstract interface class IFollowRemoteDatasource {
  // follow/unfollow operations
  Future<FollowApiModel> followUser(String targetUserId);
  Future<FollowApiModel> unfollowUser(String targetUserId);

  // get operations
  Future<List<FollowApiModel>> getMyFollowers();
  Future<List<FollowApiModel>> getMyFollowing();
  Future<List<FollowApiModel>> getUsersFollowers(String userId);
  Future<List<FollowApiModel>> getUsersFollowing(String userId);
}
