import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/usecases/create_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/edit_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/get_feed_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/get_following_feed_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/get_my_posts_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/get_user_posts_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/like_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/unlike_post_usecase.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postViewModelProvider = NotifierProvider<PostViewModel, PostState>(
  () => PostViewModel(),
);

class PostViewModel extends Notifier<PostState> {
  late final CreatePostUsecase _createPost;
  late final EditPostUsecase _editPost;

  late final GetFeedUsecase _getFeed;
  late final GetFollowingFeedUsecase _getFollowingFeed;
  late final GetMyPostsUsecase _getMyPosts;
  late final GetUserPostsUsecase _getUserPosts;

  late final DeletePostUsecase _deletePost;
  late final LikePostUsecase _likePost;
  late final UnlikePostUsecase _unlikePost;

  @override
  PostState build() {
    _createPost = ref.read(createPostUsecaseProvider);
    _editPost = ref.read(editPostUsecaseProvider);

    _getFeed = ref.read(getFeedUsecaseProvider);
    _getFollowingFeed = ref.read(getFollowingFeedUsecaseProvider);
    _getMyPosts = ref.read(getMyPostsUsecaseProvider);
    _getUserPosts = ref.read(getUserPostsUsecaseProvider);

    _deletePost = ref.read(deletePostUsecaseProvider);
    _likePost = ref.read(likePostUsecaseProvider);
    _unlikePost = ref.read(unlikePostUsecaseProvider);

    return const PostState();
  }

  // -------------------------
  // Helpers
  // -------------------------

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  bool _isLikeBusy(String postId) => state.likeBusy[postId] == true;

  void _setLikeBusy(String postId, bool busy) {
    final next = {...state.likeBusy, postId: busy};
    state = state.copyWith(likeBusy: next);
  }

  List<PostEntity> _replacePostInList(
    List<PostEntity> list,
    PostEntity updated,
  ) {
    return list
        .map(
          (p) => (p.postId != null && p.postId == updated.postId) ? updated : p,
        )
        .toList();
  }

  List<PostEntity> _removePostFromList(List<PostEntity> list, String postId) {
    return list.where((p) => p.postId != postId).toList();
  }

  // -------------------------
  // Feed loaders
  // -------------------------

  Future<void> loadDiscoverFeed() async {
    state = state.copyWith(discoverLoading: true, clearError: true);

    final result = await _getFeed();

    result.fold(
      (failure) {
        state = state.copyWith(
          discoverLoading: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(discoverLoading: false, discoverPosts: posts);
      },
    );
  }

  Future<void> loadFollowingFeed() async {
    state = state.copyWith(followingLoading: true, clearError: true);

    final result = await _getFollowingFeed();

    result.fold(
      (failure) {
        state = state.copyWith(
          followingLoading: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(followingLoading: false, followingPosts: posts);
      },
    );
  }

  Future<void> loadMyPosts() async {
    state = state.copyWith(myPostsLoading: true, clearError: true);

    final result = await _getMyPosts();

    result.fold(
      (failure) {
        state = state.copyWith(
          myPostsLoading: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(myPostsLoading: false, myPosts: posts);
      },
    );
  }

  Future<void> loadUserPosts(String userId) async {
    state = state.copyWith(userPostsLoading: true, clearError: true);

    final result = await _getUserPosts(
      GetUserPostsUsecaseParams(userId: userId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          userPostsLoading: false,
          errorMessage: failure.message,
        );
      },
      (posts) {
        state = state.copyWith(userPostsLoading: false, userPosts: posts);
      },
    );
  }

  // -------------------------
  // Create post
  // -------------------------

  Future<PostEntity?> createPost({
    required String mediaPath,
    String mediaType = "image",
    String? caption,
    List<String>? tags,
    String visibility = "public",
  }) async {
    state = state.copyWith(actionLoading: true, clearError: true);

    final params = CreatePostUsecaseParams(
      mediaPath: mediaPath,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
      visibility: visibility,
    );

    final result = await _createPost(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          actionLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (createdPost) {
        // Instant UI update (add to top)
        final updatedDiscover = [createdPost, ...state.discoverPosts];
        final updatedMyPosts = [createdPost, ...state.myPosts];

        state = state.copyWith(
          actionLoading: false,
          discoverPosts: updatedDiscover,
          myPosts: updatedMyPosts,
        );

        return createdPost;
      },
    );
  }

  // -------------------------
  // Edit post
  // -------------------------

  Future<bool> editPost({
    required String postId,
    String? caption,
    List<String>? tags,
    String? visibility,
  }) async {
    state = state.copyWith(actionLoading: true, clearError: true);

    final params = EditPostUsecaseParams(
      postId: postId,
      caption: caption,
      tags: tags,
      visibility: visibility,
    );

    final result = await _editPost(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          actionLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) async {
        // easiest: refresh discover/my posts if you want true sync
        state = state.copyWith(actionLoading: false);
        // optional: await loadDiscoverFeed(); await loadMyPosts();
        return true;
      },
    );
  }

  // -------------------------
  // Delete post (optimistic remove)
  // -------------------------

  Future<bool> deletePost(String postId) async {
    state = state.copyWith(actionLoading: true, clearError: true);

    // optimistic: remove from lists immediately
    final oldDiscover = state.discoverPosts;
    final oldFollowing = state.followingPosts;
    final oldMyPosts = state.myPosts;
    final oldUserPosts = state.userPosts;

    state = state.copyWith(
      discoverPosts: _removePostFromList(oldDiscover, postId),
      followingPosts: _removePostFromList(oldFollowing, postId),
      myPosts: _removePostFromList(oldMyPosts, postId),
      userPosts: _removePostFromList(oldUserPosts, postId),
    );

    final result = await _deletePost(DeletePostUsecaseParams(postId: postId));

    return result.fold(
      (failure) {
        // rollback
        state = state.copyWith(
          actionLoading: false,
          discoverPosts: oldDiscover,
          followingPosts: oldFollowing,
          myPosts: oldMyPosts,
          userPosts: oldUserPosts,
          errorMessage: failure.message,
        );
        return false;
      },
      (ok) {
        state = state.copyWith(actionLoading: false);
        return ok;
      },
    );
  }

  // -------------------------
  // Like / Unlike (optimistic)
  // -------------------------

  Future<void> toggleLike({
    required PostEntity post,
    required bool currentlyLiked,
    required String myUserId,
  }) async {
    final postId = post.postId;
    if (postId == null) return;
    if (_isLikeBusy(postId)) return;

    _setLikeBusy(postId, true);
    clearError();

    // optimistic update: bump likeCount
    final currentCount = post.likeCount ?? 0;
    final newCount = currentlyLiked
        ? (currentCount - 1).clamp(0, 999999)
        : currentCount + 1;
    final oldLikedBy = post.likedBy ?? const [];

    final newLikedBy = currentlyLiked
        ? oldLikedBy.where((id) => id != myUserId).toList()
        : [...oldLikedBy, myUserId];

    final updated = PostEntity(
      postId: post.postId,
      author: post.author,
      media: post.media,
      mediaType: post.mediaType,
      caption: post.caption,
      tags: post.tags,
      visibility: post.visibility,
      likeCount: newCount,
      likedBy: newLikedBy,
      commentCount: post.commentCount,
      commentedBy: post.commentedBy,
      isChallengeSubmission: post.isChallengeSubmission,
      createdAt: post.createdAt,
    );

    state = state.copyWith(
      discoverPosts: _replacePostInList(state.discoverPosts, updated),
      followingPosts: _replacePostInList(state.followingPosts, updated),
      myPosts: _replacePostInList(state.myPosts, updated),
      userPosts: _replacePostInList(state.userPosts, updated),
    );

    final result = currentlyLiked
        ? await _unlikePost(UnlikePostUsecaseParams(postId: postId))
        : await _likePost(LikePostUsecaseParams(postId: postId));

    result.fold(
      (failure) {
        // rollback
        state = state.copyWith(
          discoverPosts: _replacePostInList(state.discoverPosts, post),
          followingPosts: _replacePostInList(state.followingPosts, post),
          myPosts: _replacePostInList(state.myPosts, post),
          userPosts: _replacePostInList(state.userPosts, post),
          errorMessage: failure.message,
        );
      },
      (_) {
        // keep optimistic state
      },
    );

    _setLikeBusy(postId, false);
  }
}
