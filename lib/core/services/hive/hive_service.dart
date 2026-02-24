import 'package:artsphere/core/constants/hive_table_constant.dart';
import 'package:artsphere/features/auth/data/models/hive/user_hive_model.dart';
import 'package:artsphere/features/post/data/models/hive/post_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

// Hivfe Srevice Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  static const String _cachedProfileKey = "__cached_profile__";
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  // RegisterAdapter
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.postTypeId)) {
      Hive.registerAdapter(PostHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<PostHiveModel>(HiveTableConstant.postTable);
    await Hive.openBox(HiveTableConstant.metaTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ================================================= User Queries =====================================================================//

  // Makina a box for user things.
  Box<UserHiveModel> get _userBox => Hive.box(HiveTableConstant.userTable);
  Box<PostHiveModel> get _postBox => Hive.box(HiveTableConstant.postTable);
  Box get _metaBox => Hive.box(HiveTableConstant.metaTable);

  // register user
  Future<UserHiveModel> registerUser(UserHiveModel model) async {
    await _userBox.put(model.userId, model);
    return model;
  }

  // User Login
  Future<UserHiveModel?> loginUser(String email, String password) async {
    final users = _userBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // user logout
  Future<void> logout() async {
    await _userBox.delete(_cachedProfileKey);
  }

  // Get Current User.
  UserHiveModel? getCurrentUser(String userId) {
    return _userBox.get(userId);
  }

  bool isEmailExists(String email) {
    final users = _userBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // Save last known profile (from API) for offline viewing
  Future<void> cacheMyProfile(UserHiveModel model) async {
    await _userBox.put(_cachedProfileKey, model);
  }

  // Read last known cached profile (offline)
  UserHiveModel? getCachedMyProfile() {
    return _userBox.get(_cachedProfileKey);
  }

  // ===================== POSTS CACHE =====================

  Future<void> cacheDiscoverPosts(
    List<PostHiveModel> posts, {
    int limit = 5,
  }) async {
    final trimmed = posts.take(limit).toList();

    // store posts by id
    for (final p in trimmed) {
      if (p.postId.trim().isEmpty) continue;
      await _postBox.put(p.postId, p);
    }

    // store index list
    final ids = trimmed
        .map((e) => e.postId)
        .where((id) => id.trim().isNotEmpty)
        .toList();
    await _metaBox.put(HiveTableConstant.keyDiscoverPostIds, ids);
  }

  Future<void> cacheMyPosts(List<PostHiveModel> posts, {int limit = 5}) async {
    final trimmed = posts.take(limit).toList();

    for (final p in trimmed) {
      if (p.postId.trim().isEmpty) continue;
      await _postBox.put(p.postId, p);
    }

    final ids = trimmed
        .map((e) => e.postId)
        .where((id) => id.trim().isNotEmpty)
        .toList();
    await _metaBox.put(HiveTableConstant.keyMyPostIds, ids);
  }

  List<PostHiveModel> getCachedDiscoverPosts() {
    final ids =
        (_metaBox.get(HiveTableConstant.keyDiscoverPostIds) as List?)
            ?.cast<String>() ??
        [];
    return ids
        .map((id) => _postBox.get(id))
        .whereType<PostHiveModel>()
        .toList();
  }

  Future<void> cacheFollowingPosts(
    List<PostHiveModel> posts, {
    int limit = 5,
  }) async {
    final trimmed = posts.take(limit).toList();

    for (final p in trimmed) {
      if (p.postId.trim().isEmpty) continue;
      await _postBox.put(p.postId, p);
    }

    final ids = trimmed
        .map((e) => e.postId)
        .where((id) => id.trim().isNotEmpty)
        .toList();
    await _metaBox.put(HiveTableConstant.keyFollowingPostIds, ids);
  }

  List<PostHiveModel> getCachedFollowingPosts() {
    final ids =
        (_metaBox.get(HiveTableConstant.keyFollowingPostIds) as List?)
            ?.cast<String>() ??
        [];
    return ids
        .map((id) => _postBox.get(id))
        .whereType<PostHiveModel>()
        .toList();
  }

  List<PostHiveModel> getCachedMyPosts() {
    final ids =
        (_metaBox.get(HiveTableConstant.keyMyPostIds) as List?)
            ?.cast<String>() ??
        [];
    return ids
        .map((id) => _postBox.get(id))
        .whereType<PostHiveModel>()
        .toList();
  }

  Future<void> clearPostCache() async {
    await _postBox.clear();
    await _metaBox.delete(HiveTableConstant.keyDiscoverPostIds);
    await _metaBox.delete(HiveTableConstant.keyMyPostIds);
    await _metaBox.delete(HiveTableConstant.keyFollowingPostIds);
  }
}
