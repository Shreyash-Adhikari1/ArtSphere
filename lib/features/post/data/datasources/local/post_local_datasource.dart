import 'package:artsphere/core/services/hive/hive_service.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/models/hive/post_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postLocalDatasourceProvider = Provider<IPostLocalDatasource>((ref) {
  return PostLocalDatasource(hiveService: ref.read(hiveServiceProvider));
});

class PostLocalDatasource implements IPostLocalDatasource {
  final HiveService _hiveService;

  PostLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<void> cacheFeed(List<PostHiveModel> posts, {int limit = 5}) async {
    await _hiveService.cacheDiscoverPosts(posts, limit: limit);
  }

  @override
  Future<void> cacheMyPosts(List<PostHiveModel> posts, {int limit = 5}) async {
    await _hiveService.cacheMyPosts(posts, limit: limit);
  }

  // If you want following feed too, we store it as "discover" OR add a new key.
  // Best: add a new key for following feed in HiveTableConstant + HiveService,
  // but for now we’ll keep it simple by caching it into discover list too
  // OR you can add dedicated methods. I’ll do dedicated methods below (recommended).

  @override
  Future<void> cacheFollowingFeed(
    List<PostHiveModel> posts, {
    int limit = 5,
  }) async {
    // ✅ Recommended: add following cache methods in HiveService (Step 2.1 below)
    await _hiveService.cacheFollowingPosts(posts, limit: limit);
  }

  @override
  Future<List<PostHiveModel>> getCachedFeed() async {
    return _hiveService.getCachedDiscoverPosts();
  }

  @override
  Future<List<PostHiveModel>> getCachedMyPosts() async {
    return _hiveService.getCachedMyPosts();
  }

  @override
  Future<List<PostHiveModel>> getCachedFollowingFeed() async {
    return _hiveService.getCachedFollowingPosts();
  }

  @override
  Future<void> clearPostCache() async {
    await _hiveService.clearPostCache();
  }
}
