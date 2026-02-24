import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/post/data/models/edit/edit_post_api_model.dart';
import 'package:artsphere/features/post/data/models/hive/post_hive_model.dart';
import 'package:artsphere/features/post/data/models/post_api_model.dart';

abstract interface class IPostLocalDatasource {
  // cache
  Future<void> cacheFeed(List<PostHiveModel> posts, {int limit = 5});
  Future<void> cacheMyPosts(List<PostHiveModel> posts, {int limit = 5});
  Future<void> cacheFollowingFeed(List<PostHiveModel> posts, {int limit = 5});

  // read cache
  Future<List<PostHiveModel>> getCachedFeed();
  Future<List<PostHiveModel>> getCachedMyPosts();
  Future<List<PostHiveModel>> getCachedFollowingFeed();

  Future<void> clearPostCache();
}

abstract interface class IPostRemoteDatasource {
  Future<PostApiModel> createPost(CreatePostApiModel post, String mediaPath);
  Future<EditPostApiModel> editPost(String postId, EditPostApiModel post);

  Future<bool> likePost(String postId);
  Future<bool> unlikePost(String postId);

  Future<List<PostApiModel>> getMyPosts();
  Future<List<PostApiModel>> getPostsByUser(String userId);
  Future<List<PostApiModel>> getFeed();
  Future<List<PostApiModel>> getFollowingFeed();

  Future<bool> deletePost(String postId);
}
