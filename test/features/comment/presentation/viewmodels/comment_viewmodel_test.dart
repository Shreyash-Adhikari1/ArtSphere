import 'dart:async';

import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/domain/usecases/create_comment_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/delete_comment_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/like_comment_usecase.dart';
import 'package:artsphere/features/comment/domain/usecases/unlike_comment_usecase.dart';
import 'package:artsphere/features/comment/presentation/states/comment_state.dart';
import 'package:artsphere/features/comment/presentation/viewmodels/comment_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// =======================
// Mocks
// =======================
class MockCreateCommentUsecase extends Mock implements CreateCommentUsecase {}

class MockGetCommentsUsecase extends Mock implements GetCommentsUsecase {}

class MockLikeCommentUsecase extends Mock implements LikeCommentUsecase {}

class MockUnlikeCommentUsecase extends Mock implements UnlikeCommentUsecase {}

class MockDeleteCommentUsecase extends Mock implements DeleteCommentUsecase {}

// =======================
// Fakes for any()
// =======================
class FakeGetCommentsParams extends Fake implements GetCommentsUsecaseParams {}

class FakeCreateCommentParams extends Fake
    implements CreateCommentUsecaseParams {}

class FakeDeleteCommentParams extends Fake
    implements DeleteCommentUsecaseParams {}

class FakeLikeCommentParams extends Fake implements LikeCommentUsecaseParams {}

class FakeUnlikeCommentParams extends Fake
    implements UnlikeCommentUsecaseParams {}

void main() {
  late MockCreateCommentUsecase mockCreate;
  late MockGetCommentsUsecase mockGet;
  late MockLikeCommentUsecase mockLike;
  late MockUnlikeCommentUsecase mockUnlike;
  late MockDeleteCommentUsecase mockDelete;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        createCommentUsecaseProvider.overrideWithValue(mockCreate),
        getCommentsUsecaseProvider.overrideWithValue(mockGet),
        likeCommentUsecaseProvider.overrideWithValue(mockLike),
        unlikeCommentUsecaseProvider.overrideWithValue(mockUnlike),
        deleteCommentUsecaseProvider.overrideWithValue(mockDelete),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeGetCommentsParams());
    registerFallbackValue(FakeCreateCommentParams());
    registerFallbackValue(FakeDeleteCommentParams());
    registerFallbackValue(FakeLikeCommentParams());
    registerFallbackValue(FakeUnlikeCommentParams());
  });

  setUp(() {
    mockCreate = MockCreateCommentUsecase();
    mockGet = MockGetCommentsUsecase();
    mockLike = MockLikeCommentUsecase();
    mockUnlike = MockUnlikeCommentUsecase();
    mockDelete = MockDeleteCommentUsecase();

    // Safe defaults
    when(
      () => mockGet(any()),
    ).thenAnswer((_) async => const Right(<CommentEntity>[]));
    when(() => mockCreate(any())).thenAnswer(
      (_) async => Right(
        const CommentEntity(
          commentId: "c-new",
          postId: "p1",
          commentText: "hi",
        ),
      ),
    );
    when(() => mockDelete(any())).thenAnswer((_) async => const Right(true));
    when(() => mockLike(any())).thenAnswer((_) async => const Right(true));
    when(() => mockUnlike(any())).thenAnswer((_) async => const Right(true));
  });

  // =========================================================
  // TEST 1: loadComments success -> sets activePostId, fills comments, loading false
  // =========================================================
  test('loadComments success -> sets comments and turns off loading', () async {
    final comments = [
      const CommentEntity(commentId: "c1", postId: "p1", commentText: "first"),
      const CommentEntity(commentId: "c2", postId: "p1", commentText: "second"),
    ];

    when(() => mockGet(any())).thenAnswer((_) async => Right(comments));

    final container = makeContainer();
    addTearDown(container.dispose);

    final vm = container.read(commentViewModelProvider.notifier);

    await vm.loadComments("p1");

    final state = container.read(commentViewModelProvider);
    expect(state.activePostId, "p1");
    expect(state.commentsLoading, false);
    expect(state.comments, comments);
    expect(state.errorMessage, isNull);

    verify(() => mockGet(any())).called(1);
  });

  // =========================================================
  // TEST 2: loadComments ignores stale response if user switched activePostId mid-flight
  // =========================================================
  test(
    'loadComments -> stale response ignored when activePostId changes (Completer)',
    () async {
      final completer = Completer<Either<Failure, List<CommentEntity>>>();
      when(() => mockGet(any())).thenAnswer((_) async => completer.future);

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(commentViewModelProvider.notifier);

      // Start request for p1
      final future = vm.loadComments("p1");

      // Simulate user switching to another post before p1 returns
      vm.state = vm.state.copyWith(activePostId: "p2");

      // Complete old p1 request
      completer.complete(
        const Right([
          CommentEntity(
            commentId: "c-stale",
            postId: "p1",
            commentText: "ignored",
          ),
        ]),
      );

      await future;

      final state = container.read(commentViewModelProvider);

      // Must ignore stale response
      expect(state.activePostId, "p2");
      expect(state.comments, isEmpty);

      // NOTE: commentsLoading may remain true until loadComments("p2") is called.
      verify(() => mockGet(any())).called(1);
    },
  );

  // =========================================================
  // TEST 3: createComment success -> prepends only if still on same activePostId
  // =========================================================
  test(
    'createComment success -> prepends comment when activePostId matches',
    () async {
      final created = const CommentEntity(
        commentId: "c3",
        postId: "p1",
        commentText: "new",
      );

      when(() => mockCreate(any())).thenAnswer((_) async => Right(created));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(commentViewModelProvider.notifier);

      // Seed comments for p1
      vm.state = const CommentState(
        activePostId: "p1",
        comments: [
          CommentEntity(commentId: "c1", postId: "p1", commentText: "old"),
        ],
      );

      final result = await vm.createComment(postId: "p1", commentText: "new");
      expect(result, created);

      final state = container.read(commentViewModelProvider);
      expect(state.actionLoading, false);
      expect(state.comments.first.commentId, "c3");
      verify(() => mockCreate(any())).called(1);
    },
  );

  // =========================================================
  // TEST 4: toggleLike unlike failure -> rolls back + sets error + clears busy flag
  // =========================================================
  test(
    'toggleLike unlike failure -> rollback comment and set errorMessage',
    () async {
      const failure = ApiFailure(message: "Unlike failed", statusCode: 400);

      final original = const CommentEntity(
        commentId: "c1",
        postId: "p1",
        commentText: "hello",
        likeCount: 2,
        likedBy: ["me"],
      );

      when(
        () => mockUnlike(any()),
      ).thenAnswer((_) async => const Left(failure));

      final container = makeContainer();
      addTearDown(container.dispose);

      final vm = container.read(commentViewModelProvider.notifier);
      vm.state = CommentState(comments: [original]);

      await vm.toggleLike(
        comment: original,
        currentlyLiked: true,
        myUserId: "me",
      );

      final state = container.read(commentViewModelProvider);

      // rollback to original
      expect(state.comments.first, original);
      expect(state.errorMessage, failure.message);
      expect(state.likeBusy["c1"], false);

      verify(() => mockUnlike(any())).called(1);
      verifyNever(() => mockLike(any()));
    },
  );
}
