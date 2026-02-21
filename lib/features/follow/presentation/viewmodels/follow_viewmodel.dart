import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:artsphere/features/follow/domain/usecases/follow_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/get_is_following_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/unfollow_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/get_my_followers_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/get_my_following_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/get_user_followers_usecase.dart';
import 'package:artsphere/features/follow/domain/usecases/get_user_following_usecase.dart';
import 'package:artsphere/features/follow/presentation/states/follow_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followViewModelProvider = NotifierProvider<FollowViewModel, FollowState>(
  () => FollowViewModel(),
);

class FollowViewModel extends Notifier<FollowState> {
  late final FollowUsecase _follow;
  late final UnfollowUsecase _unfollow;
  late final GetMyFollowersUsecase _getMyFollowers;
  late final GetMyFollowingUsecase _getMyFollowing;
  late final GetUserFollowersUsecase _getUserFollowers;
  late final GetUserFollowingUsecase _getUserFollowing;
  late final GetIsFollowingUsecase _getIsFollowing;

  @override
  FollowState build() {
    _follow = ref.read(followUsecaseProvider);
    _unfollow = ref.read(unfollowUsecaseProvider);
    _getMyFollowers = ref.read(getMyFollowersUsecaseProvider);
    _getMyFollowing = ref.read(getMyFollowingUsecaseProvider);
    _getUserFollowers = ref.read(getUserFollowersUsecaseProvider);
    _getUserFollowing = ref.read(getUserFollowingUsecaseProvider);
    _getIsFollowing = ref.read(getIsFollowingUsecaseProvider);
    return const FollowState();
  }

  // --- helpers ---
  void clearError() => state = state.copyWith(clearError: true);

  bool _isBusy(String userId) => state.followBusy[userId] == true;

  void _setBusy(String userId, bool busy) {
    final next = {...state.followBusy, userId: busy};
    state = state.copyWith(followBusy: next);
  }

  List<FollowEntity> _setIsFollowedByMeInList(
    List<FollowEntity> list,
    String userId,
    bool value,
  ) {
    return list.map((row) {
      final followerId = row.follower?.userId;
      final followingId = row.following?.userId;

      if (followerId == userId || followingId == userId) {
        return FollowEntity(
          followId: row.followId,
          follower: row.follower,
          following: row.following,
          isFollowActive: row.isFollowActive,
          isFollowedByMe: value,
          createdAt: row.createdAt,
        );
      }
      return row;
    }).toList();
  }

  void _setIsFollowingCache(String userId, bool value) {
    state = state.copyWith(
      isFollowingCache: {...state.isFollowingCache, userId: value},
    );
  }

  Future<void> refreshIsFollowing(String targetUserId) async {
    if (targetUserId.trim().isEmpty) return;

    final result = await _getIsFollowing(
      GetIsFollowingParams(targetUserId: targetUserId),
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (isFollowing) {
        state = state.copyWith(
          isFollowingCache: {
            ...state.isFollowingCache,
            targetUserId: isFollowing,
          },
        );
      },
    );
  }

  // --- loaders ---
  Future<void> loadMyFollowers() async {
    state = state.copyWith(loadingMyFollowers: true, clearError: true);
    final result = await _getMyFollowers();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (rows) => state = state.copyWith(myFollowers: rows),
    );
    state = state.copyWith(loadingMyFollowers: false);
  }

  Future<void> loadMyFollowing() async {
    state = state.copyWith(loadingMyFollowing: true, clearError: true);
    final result = await _getMyFollowing();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (rows) => state = state.copyWith(myFollowing: rows),
    );
    state = state.copyWith(loadingMyFollowing: false);
  }

  Future<void> loadUserFollowers(String userId) async {
    state = state.copyWith(
      loadingUserFollowers: true,
      clearError: true,
      activeUserId: userId,
      userFollowers: const [], // reset so old user list doesn't flash
    );

    final result = await _getUserFollowers(
      GetUserFollowersUsecaseParams(userId: userId),
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (rows) => state = state.copyWith(userFollowers: rows),
    );
    state = state.copyWith(loadingUserFollowers: false);
  }

  Future<void> loadUserFollowing(String userId) async {
    state = state.copyWith(
      loadingUserFollowing: true,
      clearError: true,
      activeUserId: userId,
      userFollowing: const [],
    );

    final result = await _getUserFollowing(
      GetUserFollowingUsecaseParams(userId: userId),
    );
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (rows) => state = state.copyWith(userFollowing: rows),
    );
    state = state.copyWith(loadingUserFollowing: false);
  }

  Future<void> fetchIsFollowing(
    String targetUserId, {
    bool force = false,
  }) async {
    if (targetUserId.trim().isEmpty) return;

    if (!force && state.isFollowingCache.containsKey(targetUserId)) return;

    final result = await _getIsFollowing(
      GetIsFollowingParams(targetUserId: targetUserId),
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (isFollowing) {
        state = state.copyWith(
          isFollowingCache: {
            ...state.isFollowingCache,
            targetUserId: isFollowing,
          },
        );
      },
    );
  }

  // --- actions ---
  Future<void> toggleFollow({
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    if (targetUserId.trim().isEmpty) return;
    if (_isBusy(targetUserId)) return;

    _setBusy(targetUserId, true);
    clearError();

    final nextValue = !currentlyFollowing;

    // --- snapshot for rollback ---
    final oldCache = state.isFollowingCache[targetUserId];
    final oldMyFollowers = state.myFollowers;
    final oldMyFollowing = state.myFollowing;
    final oldUserFollowers = state.userFollowers;
    final oldUserFollowing = state.userFollowing;

    // --- optimistic UI update (modal + profile both react immediately) ---
    _setIsFollowingCache(targetUserId, nextValue);

    state = state.copyWith(
      myFollowers: _setIsFollowedByMeInList(
        state.myFollowers,
        targetUserId,
        nextValue,
      ),
      myFollowing: _setIsFollowedByMeInList(
        state.myFollowing,
        targetUserId,
        nextValue,
      ),
      userFollowers: _setIsFollowedByMeInList(
        state.userFollowers,
        targetUserId,
        nextValue,
      ),
      userFollowing: _setIsFollowedByMeInList(
        state.userFollowing,
        targetUserId,
        nextValue,
      ),
    );

    final result = currentlyFollowing
        ? await _unfollow(UnfollowUsecaseParams(targetUserId: targetUserId))
        : await _follow(FollowUsecaseParams(targetUserId: targetUserId));

    result.fold(
      (failure) {
        // --- rollback everything ---
        final newCacheMap = {...state.isFollowingCache};
        if (oldCache == null) {
          newCacheMap.remove(targetUserId);
        } else {
          newCacheMap[targetUserId] = oldCache;
        }

        state = state.copyWith(
          isFollowingCache: newCacheMap,
          myFollowers: oldMyFollowers,
          myFollowing: oldMyFollowing,
          userFollowers: oldUserFollowers,
          userFollowing: oldUserFollowing,
          errorMessage: failure.message,
        );
      },
      (_) {
        // success: keep optimistic state
      },
    );

    _setBusy(targetUserId, false);
  }
}
