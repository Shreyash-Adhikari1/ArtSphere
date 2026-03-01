import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/presentation/states/comment_state.dart';
import 'package:artsphere/features/comment/presentation/viewmodels/comment_viewmodel.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/post_details_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// ---------------------------
/// Test doubles (ViewModels)
/// ---------------------------

class TestUserVm extends UserViewModel {
  TestUserVm(this._initial);
  final UserState _initial;

  @override
  UserState build() => _initial;
}

class TestPostVm extends PostViewModel {
  TestPostVm(this._initial);
  final PostState _initial;

  int toggleLikeCalls = 0;
  bool? lastCurrentlyLiked;
  String? lastMyUserId;
  String? lastPostId;

  int bumpCommentCalls = 0;
  String? lastBumpPostId;
  int? lastBumpDelta;

  @override
  PostState build() => _initial;

  @override
  Future<void> toggleLike({
    required PostEntity post,
    required bool currentlyLiked,
    required String myUserId,
  }) async {
    toggleLikeCalls++;
    lastCurrentlyLiked = currentlyLiked;
    lastMyUserId = myUserId;
    lastPostId = post.postId;
  }

  @override
  void bumpCommentCount(String postId, {int delta = 1}) {
    bumpCommentCalls++;
    lastBumpPostId = postId;
    lastBumpDelta = delta;
  }
}

class TestCommentVm extends CommentViewModel {
  TestCommentVm(
    this._initial, {
    this.autoFinishLoad = true,
    this.loadedComments = const [],
  });

  final CommentState _initial;
  final bool autoFinishLoad;
  final List<CommentEntity> loadedComments;

  int loadCalls = 0;
  String? lastLoadPostId;

  int createCalls = 0;
  String? lastCreatePostId;
  String? lastCreateText;

  @override
  CommentState build() => _initial;

  @override
  Future<void> loadComments(String postId) async {
    loadCalls++;
    lastLoadPostId = postId;

    state = state.copyWith(
      commentsLoading: true,
      activePostId: postId,
      comments: const [],
      clearError: true,
    );

    if (!autoFinishLoad) return;

    // ✅ no Timer (prevents "pending timers" failures)
    await Future<void>.microtask(() {});

    if (state.activePostId != postId) return;

    state = state.copyWith(comments: loadedComments, commentsLoading: false);
  }

  @override
  Future<CommentEntity?> createComment({
    required String postId,
    required String commentText,
  }) async {
    createCalls++;
    lastCreatePostId = postId;
    lastCreateText = commentText;

    return CommentEntity(
      commentId: 'c_new',
      postId: postId,
      commentText: commentText,
      likeCount: 0,
      likedBy: const [],
      userId: UserEntity(
        userId: 'me',
        username: 'me_user',
        fullName: 'Me',
        avatar: null,
        email: '',
        password: '',
        confirmPassword: '',
      ),
    );
  }

  @override
  Future<void> toggleLike({
    required CommentEntity comment,
    required bool currentlyLiked,
    required String myUserId,
  }) async {}

  @override
  Future<bool> deleteComment(String commentId) async => true;
}

/// ---------------------------
/// Test host
/// ---------------------------

Widget host({
  required PostEntity post,
  required TestUserVm userVm,
  required TestPostVm postVm,
  required TestCommentVm commentVm,
}) {
  return ProviderScope(
    overrides: [
      userViewModelProvider.overrideWith(() => userVm),
      postViewModelProvider.overrideWith(() => postVm),
      commentViewModelProvider.overrideWith(() => commentVm),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () => showPostDetailsModal(context, post),
                child: const Text('OPEN'),
              ),
            );
          },
        ),
      ),
    ),
  );
}

/// ---------------------------
/// Helpers
/// ---------------------------

PostEntity makePost({
  required String postId,
  String? caption,
  int? likeCount,
  List<String>? likedBy,
  int? commentCount,
  String? media,
  UserEntity? author,
}) {
  return PostEntity(
    postId: postId,
    caption: caption,
    likeCount: likeCount,
    likedBy: likedBy,
    commentCount: commentCount,
    media: media,
    author: author,
  );
}

Future<void> setLargeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

/// Use this when you DO want a settled UI (most tests)
Future<void> openModalSettled(WidgetTester tester) async {
  await tester.tap(find.text('OPEN'));
  await tester.pump(); // begin route animation
  await tester
      .pumpAndSettle(); // finish animations (only safe if no infinite anim)
}

/// Use this when you expect a spinner / infinite animation
Future<void> openModalNoSettle(WidgetTester tester) async {
  await tester.tap(find.text('OPEN'));
  await tester.pump(); // begin animation
  // Pump a bit to let the sheet appear without waiting forever.
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

/// The sheet's scrollable (DraggableScrollableSheet -> Scrollable)
Finder sheetScrollable() => find.byType(Scrollable).first;

/// Like icon button (top actions row)
Finder likeButtonFinder() => find.byWidgetPredicate((w) {
  if (w is! IconButton) return false;
  final icon = w.icon;
  return icon is Icon &&
      (icon.icon == Icons.favorite_border || icon.icon == Icons.favorite);
});

Future<void> scrollUntilCommentsBuilt(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Comments'),
    200,
    scrollable: sheetScrollable(),
  );
  await tester.pump(); // one rebuild after scroll
}

Future<void> scrollUntilLikeButtonVisible(WidgetTester tester) async {
  final likeBtn = likeButtonFinder();

  // If already visible, do nothing.
  if (tester.any(likeBtn) &&
      tester.getRect(likeBtn).overlaps(const Rect.fromLTWH(0, 0, 800, 1200))) {
    return;
  }

  await tester.scrollUntilVisible(likeBtn, 200, scrollable: sheetScrollable());
  await tester.pump();
}

Finder actionsRowFinder() {
  return find.byWidgetPredicate((w) {
    if (w is! Row) return false;

    bool hasLikeIcon = false;
    bool hasBookmark = false;
    bool hasCommentIcon = false;
    bool hasTextCount = false;

    for (final c in w.children) {
      if (c is IconButton && c.icon is Icon) {
        final icon = (c.icon as Icon).icon;
        if (icon == Icons.favorite || icon == Icons.favorite_border) {
          hasLikeIcon = true;
        }
        if (icon == Icons.bookmark_border) {
          hasBookmark = true;
        }
      }
      if (c is Icon) {
        if (c.icon == Icons.mode_comment_outlined) {
          hasCommentIcon = true;
        }
      }
      if (c is Text) {
        // likeCount and commentCount are both Text in that row
        hasTextCount = true;
      }
    }

    // This combination uniquely identifies your actions row
    return hasLikeIcon && hasBookmark && hasCommentIcon && hasTextCount;
  }).first;
}

Finder likeButtonInActionsRow() {
  final row = actionsRowFinder();
  return find.descendant(
    of: row,
    matching: find.byWidgetPredicate((w) {
      if (w is! IconButton) return false;
      final icon = w.icon;
      return icon is Icon &&
          (icon.icon == Icons.favorite || icon.icon == Icons.favorite_border);
    }),
  );
}

/// ---------------------------
/// Tests
/// ---------------------------

void main() {
  testWidgets('1) Opening modal triggers loadComments(postId) at least once', (
    tester,
  ) async {
    await setLargeSurface(tester);

    final me = UserEntity(
      userId: 'me',
      username: 'me_user',
      fullName: 'Me',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
    );

    final post = makePost(
      postId: 'p1',
      author: UserEntity(
        userId: 'u1',
        username: 'author1',
        fullName: 'Author',
        avatar: null,
        email: '',
        password: '',
        confirmPassword: '',
      ),
    );

    final userVm = TestUserVm(
      UserState(userEntity: me, status: UserStatus.success),
    );
    final postVm = TestPostVm(const PostState());
    final commentVm = TestCommentVm(const CommentState());

    await tester.pumpWidget(
      host(post: post, userVm: userVm, postVm: postVm, commentVm: commentVm),
    );

    await openModalSettled(tester);

    expect(commentVm.loadCalls, greaterThanOrEqualTo(1));
    expect(commentVm.lastLoadPostId, 'p1');
  });

  testWidgets('2) Like button calls postVm.toggleLike with correct params', (
    tester,
  ) async {
    // Make surface tall so the sheet has room
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final me = UserEntity(
      userId: 'me',
      username: 'me_user',
      fullName: 'Me',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
    );

    final post = makePost(
      postId: 'p1',
      likeCount: 0,
      likedBy: const [],
      author: UserEntity(
        userId: 'u1',
        username: 'author1',
        fullName: 'Author',
        avatar: null,
        email: '',
        password: '',
        confirmPassword: '',
      ),
    );

    final userVm = TestUserVm(
      UserState(userEntity: me, status: UserStatus.success),
    );

    // ✅ Force likeBusy false so IconButton can't become disabled
    final postVm = TestPostVm(
      PostState(discoverPosts: [post], likeBusy: const {'p1': false}),
    );

    final commentVm = TestCommentVm(const CommentState());

    await tester.pumpWidget(
      host(post: post, userVm: userVm, postVm: postVm, commentVm: commentVm),
    );

    // Open modal (settled)
    await tester.tap(find.text('OPEN'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Scroll until the actions row is visible (under the image)
    await tester.scrollUntilVisible(
      actionsRowFinder(),
      200,
      scrollable: sheetScrollable(),
    );
    await tester.pump();

    final likeBtn = likeButtonInActionsRow();
    expect(likeBtn, findsOneWidget);

    // Must be enabled
    final btnWidget = tester.widget<IconButton>(likeBtn);
    expect(btnWidget.onPressed, isNotNull);

    // Tap
    await tester.tap(likeBtn);
    await tester.pump();

    // Assertions
    expect(postVm.toggleLikeCalls, 1);
    expect(postVm.lastPostId, 'p1');
    expect(postVm.lastMyUserId, 'me');
    expect(postVm.lastCurrentlyLiked, false);
  });
  testWidgets('3) When commentsLoading=true shows CircularProgressIndicator', (
    tester,
  ) async {
    await setLargeSurface(tester);

    final me = UserEntity(
      userId: 'me',
      username: 'me_user',
      fullName: 'Me',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
    );

    final post = makePost(
      postId: 'p1',
      author: UserEntity(
        userId: 'u1',
        username: 'author1',
        fullName: 'Author',
        avatar: null,
        email: '',
        password: '',
        confirmPassword: '',
      ),
    );

    final userVm = TestUserVm(
      UserState(userEntity: me, status: UserStatus.success),
    );
    final postVm = TestPostVm(const PostState());

    // keep loading forever
    final commentVm = TestCommentVm(
      const CommentState(),
      autoFinishLoad: false,
    );

    await tester.pumpWidget(
      host(post: post, userVm: userVm, postVm: postVm, commentVm: commentVm),
    );

    // ✅ cannot use pumpAndSettle because spinner never stops animating
    await openModalNoSettle(tester);

    await scrollUntilCommentsBuilt(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('4) Sending comment calls createComment, bumps count, reloads', (
    tester,
  ) async {
    await setLargeSurface(tester);

    final me = UserEntity(
      userId: 'me',
      username: 'me_user',
      fullName: 'Me',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
    );

    final post = makePost(
      postId: 'p1',
      commentCount: 0,
      author: UserEntity(
        userId: 'u1',
        username: 'author1',
        fullName: 'Author',
        avatar: null,
        email: '',
        password: '',
        confirmPassword: '',
      ),
    );

    final userVm = TestUserVm(
      UserState(userEntity: me, status: UserStatus.success),
    );
    final postVm = TestPostVm(PostState(discoverPosts: [post]));
    final commentVm = TestCommentVm(
      const CommentState(),
      loadedComments: const [],
    );

    await tester.pumpWidget(
      host(post: post, userVm: userVm, postVm: postVm, commentVm: commentVm),
    );

    await openModalSettled(tester);

    final baselineLoads = commentVm.loadCalls;

    final textField = find.byType(TextField).first;
    await tester.enterText(textField, 'hello');
    await tester.pump();

    final sendBtn = find.byIcon(Icons.send_rounded);
    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    expect(commentVm.createCalls, 1);
    expect(commentVm.lastCreatePostId, 'p1');
    expect(commentVm.lastCreateText, 'hello');

    expect(postVm.bumpCommentCalls, 1);
    expect(postVm.lastBumpPostId, 'p1');
    expect(postVm.lastBumpDelta, 1);

    expect(commentVm.loadCalls, greaterThan(baselineLoads));
  });

  testWidgets('5) When comments empty shows "No comments yet"', (tester) async {
    await setLargeSurface(tester);

    final me = UserEntity(
      userId: 'me',
      username: 'me_user',
      fullName: 'Me',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
    );

    final post = makePost(
      postId: 'p1',
      author: UserEntity(
        userId: 'u1',
        username: 'author1',
        fullName: 'Author',
        avatar: null,
        email: '',
        password: '',
        confirmPassword: '',
      ),
    );

    final userVm = TestUserVm(
      UserState(userEntity: me, status: UserStatus.success),
    );
    final postVm = TestPostVm(const PostState());

    // load finishes with empty list
    final commentVm = TestCommentVm(
      const CommentState(),
      loadedComments: const [],
    );

    await tester.pumpWidget(
      host(post: post, userVm: userVm, postVm: postVm, commentVm: commentVm),
    );

    await openModalSettled(tester);

    await scrollUntilCommentsBuilt(tester);

    // allow the microtask loadComments completion to rebuild
    await tester.pump();

    expect(find.text('No comments yet'), findsOneWidget);
  });
}
