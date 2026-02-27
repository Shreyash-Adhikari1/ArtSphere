import 'package:artsphere/core/error/failures.dart';
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
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// =======================
// Mocks
// =======================
class MockCreatePostUsecase extends Mock implements CreatePostUsecase {}

class MockEditPostUsecase extends Mock implements EditPostUsecase {}

class MockGetFeedUsecase extends Mock implements GetFeedUsecase {}

class MockGetFollowingFeedUsecase extends Mock
    implements GetFollowingFeedUsecase {}

class MockGetMyPostsUsecase extends Mock implements GetMyPostsUsecase {}

class MockGetUserPostsUsecase extends Mock implements GetUserPostsUsecase {}

class MockDeletePostUsecase extends Mock implements DeletePostUsecase {}

class MockLikePostUsecase extends Mock implements LikePostUsecase {}

class MockUnlikePostUsecase extends Mock implements UnlikePostUsecase {}

// =======================
// Fakes for any()
// =======================
class FakeCreatePostParams extends Fake implements CreatePostUsecaseParams {}

class FakeEditPostParams extends Fake implements EditPostUsecaseParams {}

class FakeGetUserPostsParams extends Fake
    implements GetUserPostsUsecaseParams {}

class FakeDeletePostParams extends Fake implements DeletePostUsecaseParams {}

class FakeLikePostParams extends Fake implements LikePostUsecaseParams {}

class FakeUnlikePostParams extends Fake implements UnlikePostUsecaseParams {}

void main() {
  late MockCreatePostUsecase mockCreatePost;
  late MockEditPostUsecase mockEditPost;
  late MockGetFeedUsecase mockGetFeed;
  late MockGetFollowingFeedUsecase mockGetFollowingFeed;
  late MockGetMyPostsUsecase mockGetMyPosts;
  late MockGetUserPostsUsecase mockGetUserPosts;
  late MockDeletePostUsecase mockDeletePost;
  late MockLikePostUsecase mockLikePost;
  late MockUnlikePostUsecase mockUnlikePost;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        createPostUsecaseProvider.overrideWithValue(mockCreatePost),
        editPostUsecaseProvider.overrideWithValue(mockEditPost),
        getFeedUsecaseProvider.overrideWithValue(mockGetFeed),
        getFollowingFeedUsecaseProvider.overrideWithValue(mockGetFollowingFeed),
        getMyPostsUsecaseProvider.overrideWithValue(mockGetMyPosts),
        getUserPostsUsecaseProvider.overrideWithValue(mockGetUserPosts),
        deletePostUsecaseProvider.overrideWithValue(mockDeletePost),
        likePostUsecaseProvider.overrideWithValue(mockLikePost),
        unlikePostUsecaseProvider.overrideWithValue(mockUnlikePost),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeCreatePostParams());
    registerFallbackValue(FakeEditPostParams());
    registerFallbackValue(FakeGetUserPostsParams());
    registerFallbackValue(FakeDeletePostParams());
    registerFallbackValue(FakeLikePostParams());
    registerFallbackValue(FakeUnlikePostParams());
  });

  setUp(() {
    mockCreatePost = MockCreatePostUsecase();
    mockEditPost = MockEditPostUsecase();
    mockGetFeed = MockGetFeedUsecase();
    mockGetFollowingFeed = MockGetFollowingFeedUsecase();
    mockGetMyPosts = MockGetMyPostsUsecase();
    mockGetUserPosts = MockGetUserPostsUsecase();
    mockDeletePost = MockDeletePostUsecase();
    mockLikePost = MockLikePostUsecase();
    mockUnlikePost = MockUnlikePostUsecase();

    // Safe defaults (so tests don't crash unexpectedly)
    when(
      () => mockGetFeed(),
    ).thenAnswer((_) async => const Right(<PostEntity>[]));
    when(
      () => mockGetFollowingFeed(),
    ).thenAnswer((_) async => const Right(<PostEntity>[]));
    when(
      () => mockGetMyPosts(),
    ).thenAnswer((_) async => const Right(<PostEntity>[]));
    when(
      () => mockGetUserPosts(any()),
    ).thenAnswer((_) async => const Right(<PostEntity>[]));
    when(
      () => mockCreatePost(any()),
    ).thenAnswer((_) async => Right(const PostEntity(postId: "new")));
    when(
      () => mockDeletePost(any()),
    ).thenAnswer((_) async => const Right(true));
    when(() => mockLikePost(any())).thenAnswer((_) async => const Right(true));
    when(
      () => mockUnlikePost(any()),
    ).thenAnswer((_) async => const Right(true));
    when(() => mockEditPost(any())).thenAnswer((_) async => const Right(true));
  });

  // =========================================================
  // TEST 1: loadDiscoverFeed success -> discoverPosts set & loading false
  // =========================================================
  test(
    'loadDiscoverFeed success -> sets discoverPosts and turns off discoverLoading',
    () async {
      final posts = [
        const PostEntity(postId: "p1"),
        const PostEntity(postId: "p2"),
      ];

      when(() => mockGetFeed()).thenAnswer((_) async => Right(posts));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(postViewModelProvider.notifier);

      await vm.loadDiscoverFeed();

      final state = container.read(postViewModelProvider);
      expect(state.discoverLoading, false);
      expect(state.discoverPosts, posts);
      expect(state.errorMessage, isNull);

      verify(() => mockGetFeed()).called(1);
    },
  );

  // =========================================================
  // TEST 2: createPost success -> prepends to discoverPosts + myPosts & returns post
  // =========================================================
  test(
    'createPost success -> prepends created post to discoverPosts & myPosts',
    () async {
      final created = const PostEntity(
        postId: "created-post",
        caption: "hello",
      );

      when(() => mockCreatePost(any())).thenAnswer((_) async => Right(created));

      final container = makeContainer();
      addTearDown(container.dispose);

      // seed state with existing lists
      container.read(postViewModelProvider.notifier);
      container.read(postViewModelProvider.notifier).state = const PostState(
        discoverPosts: [PostEntity(postId: "old1")],
        myPosts: [PostEntity(postId: "old2")],
      );

      final vm = container.read(postViewModelProvider.notifier);

      final result = await vm.createPost(mediaPath: "/tmp/a.png");

      expect(result, created);

      final state = container.read(postViewModelProvider);
      expect(state.actionLoading, false);
      expect(state.discoverPosts.first.postId, "created-post");
      expect(state.myPosts.first.postId, "created-post");
      verify(() => mockCreatePost(any())).called(1);
    },
  );

  // =========================================================
  // TEST 3: deletePost failure -> optimistic remove then rollback to old lists + error
  // =========================================================
  test(
    'deletePost failure -> rolls back lists and sets errorMessage',
    () async {
      const failure = ApiFailure(message: "Delete failed", statusCode: 400);

      when(
        () => mockDeletePost(any()),
      ).thenAnswer((_) async => const Left(failure));

      final p1 = const PostEntity(postId: "p1");
      final p2 = const PostEntity(postId: "p2");

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(postViewModelProvider.notifier);
      container.read(postViewModelProvider.notifier).state = PostState(
        discoverPosts: [p1, p2],
        followingPosts: [p1],
        myPosts: [p2],
        userPosts: [p1, p2],
      );

      final vm = container.read(postViewModelProvider.notifier);

      final ok = await vm.deletePost("p1");
      expect(ok, false);

      final state = container.read(postViewModelProvider);

      // rollback check: p1 should still exist everywhere it was
      expect(state.discoverPosts, [p1, p2]);
      expect(state.followingPosts, [p1]);
      expect(state.myPosts, [p2]);
      expect(state.userPosts, [p1, p2]);

      expect(state.actionLoading, false);
      expect(state.errorMessage, failure.message);

      verify(() => mockDeletePost(any())).called(1);
    },
  );

  // =========================================================
  // TEST 4: toggleLike (like success) -> optimistic update + calls like usecase + clears busy
  // =========================================================
  test(
    'toggleLike like success -> increments likeCount, adds myUserId, calls like usecase',
    () async {
      final post = const PostEntity(postId: "p1", likeCount: 0, likedBy: []);

      when(
        () => mockLikePost(any()),
      ).thenAnswer((_) async => const Right(true));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(postViewModelProvider.notifier);
      container.read(postViewModelProvider.notifier).state = PostState(
        discoverPosts: [post],
        myPosts: [post],
        followingPosts: const [],
        userPosts: const [],
      );

      final vm = container.read(postViewModelProvider.notifier);

      await vm.toggleLike(post: post, currentlyLiked: false, myUserId: "me");

      final state = container.read(postViewModelProvider);
      final updated = state.discoverPosts.first;

      expect(updated.likeCount, 1);
      expect(updated.likedBy, contains("me"));
      expect(state.likeBusy["p1"], false);

      verify(() => mockLikePost(any())).called(1);
      verifyNever(() => mockUnlikePost(any()));
    },
  );

  // =========================================================
  // TEST 5: toggleLike (unlike failure) -> rollback to original post + sets error + clears busy
  // =========================================================
  test(
    'toggleLike unlike failure -> rolls back post state and sets errorMessage',
    () async {
      const failure = ApiFailure(message: "Unlike failed", statusCode: 400);

      final original = const PostEntity(
        postId: "p1",
        likeCount: 5,
        likedBy: ["me"],
      );

      when(
        () => mockUnlikePost(any()),
      ).thenAnswer((_) async => const Left(failure));

      final container = makeContainer();
      addTearDown(container.dispose);

      container.read(postViewModelProvider.notifier);
      container.read(postViewModelProvider.notifier).state = PostState(
        discoverPosts: [original],
        myPosts: [original],
        followingPosts: const [],
        userPosts: const [],
      );

      final vm = container.read(postViewModelProvider.notifier);

      await vm.toggleLike(post: original, currentlyLiked: true, myUserId: "me");

      final state = container.read(postViewModelProvider);
      final after = state.discoverPosts.first;

      // Should rollback to exactly original
      expect(after, original);
      expect(state.errorMessage, failure.message);
      expect(state.likeBusy["p1"], false);

      verify(() => mockUnlikePost(any())).called(1);
      verifyNever(() => mockLikePost(any()));
    },
  );
}
