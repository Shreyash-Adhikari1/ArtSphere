import 'package:artsphere/features/auth/domain/entities/user_entity.dart';
import 'package:artsphere/features/auth/presentation/state/user_state.dart';
import 'package:artsphere/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/presentation/states/post_state.dart';
import 'package:artsphere/features/post/presentation/viewmodels/post_viewmodel.dart';
import 'package:artsphere/features/post/presentation/widgets/postcard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TestPostViewModel extends PostViewModel {
  int toggleLikeCalls = 0;
  bool? lastCurrentlyLiked;
  String? lastMyUserId;
  String? lastPostId;

  late PostEntity _basePost;

  void seed(PostEntity post) {
    _basePost = post;
  }

  @override
  PostState build() {
    return PostState(discoverPosts: [_basePost], likeBusy: const {});
  }

  @override
  Future<void> toggleLike({
    required PostEntity post,
    required bool currentlyLiked,
    required String myUserId,
  }) async {
    toggleLikeCalls += 1;
    lastCurrentlyLiked = currentlyLiked;
    lastMyUserId = myUserId;
    lastPostId = post.postId;

    final id = post.postId;
    if (id == null) return;

    state = state.copyWith(likeBusy: {...state.likeBusy, id: true});

    final current = post.likeCount ?? 0;
    final updated = PostEntity(
      postId: post.postId,
      author: post.author,
      media: post.media,
      mediaType: post.mediaType,
      caption: post.caption,
      tags: post.tags,
      visibility: post.visibility,
      likeCount: currentlyLiked ? (current - 1).clamp(0, 999999) : current + 1,
      likedBy: currentlyLiked
          ? (post.likedBy ?? const []).where((e) => e != myUserId).toList()
          : [...(post.likedBy ?? const []), myUserId],
      commentCount: post.commentCount,
      commentedBy: post.commentedBy,
      isChallengeSubmission: post.isChallengeSubmission,
      createdAt: post.createdAt,
    );

    state = state.copyWith(
      discoverPosts: state.discoverPosts
          .map((p) => p.postId == updated.postId ? updated : p)
          .toList(),
    );

    state = state.copyWith(likeBusy: {...state.likeBusy, id: false});
  }

  /// helper to force likeBusy for a postId
  void setBusy(String postId, bool busy) {
    state = state.copyWith(likeBusy: {...state.likeBusy, postId: busy});
  }
}

class TestUserViewModel extends UserViewModel {
  final UserEntity _user;

  TestUserViewModel(this._user);

  @override
  UserState build() {
    // return a state that has current logged in user
    return UserState(status: UserStatus.authenticated, userEntity: _user);
  }
}

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  PostEntity makePost({
    required String postId,
    required String authorId,
    required String authorUsername,
    int likeCount = 3,
    int commentCount = 2,
    List<String> likedBy = const [],
    String? caption = 'Hello caption',
    String? media,
  }) {
    final author = UserEntity(
      userId: authorId,
      username: authorUsername,
      fullName: 'Author Name',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
    );

    return PostEntity(
      postId: postId,
      author: author,
      media: media,
      mediaType: 'image',
      caption: caption,
      likeCount: likeCount,
      likedBy: likedBy,
      commentCount: commentCount,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );
  }

  Future<void> pumpPostcard(
    WidgetTester tester, {
    required PostEntity post,
    required TestPostViewModel postVm,
    required TestUserViewModel userVm,
  }) async {
    // seed before build() runs
    postVm.seed(post);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postViewModelProvider.overrideWith(() => postVm),
          userViewModelProvider.overrideWith(() => userVm),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(height: 1000, child: Center(child: SizedBox())),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postViewModelProvider.overrideWith(() => postVm),
          userViewModelProvider.overrideWith(() => userVm),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: PostcardWidget(post: post)),
          ),
        ),
      ),
    );

    await tester
        .pump(); // no pumpAndSettle (avoid hanging on animations/timers)
  }

  testWidgets('1) Renders core UI (username, caption, counts)', (tester) async {
    final myUser = UserEntity(
      userId: 'me',
      username: 'me_user',
      fullName: 'Me',
      avatar: null,
      email: '',
      password: '',
      confirmPassword: '',
      // add other required params if your UserEntity requires them
    );

    final post = makePost(
      postId: 'p1',
      authorId: 'u1',
      authorUsername: 'author1',
      likeCount: 7,
      commentCount: 4,
      caption: 'Nice post',
    );

    final postVm = TestPostViewModel();
    final userVm = TestUserViewModel(myUser);

    await pumpPostcard(tester, post: post, postVm: postVm, userVm: userVm);

    expect(find.text('@author1'), findsOneWidget);
    expect(find.text('Nice post'), findsOneWidget);

    // counts
    expect(find.text('7'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    // icons
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.mode_comment_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('2) Tapping like calls toggleLike(currentlyLiked=false)', (
    tester,
  ) async {
    final myUser = UserEntity(
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
      authorId: 'u1',
      authorUsername: 'author1',
      likedBy: const [], // not liked yet
    );

    final postVm = TestPostViewModel();
    final userVm = TestUserViewModel(myUser);

    await pumpPostcard(tester, post: post, postVm: postVm, userVm: userVm);

    final likeBtn = find.byIcon(Icons.favorite_border);
    expect(likeBtn, findsOneWidget);

    await tester.ensureVisible(likeBtn);
    await tester.pump();

    await tester.tap(likeBtn);
    await tester.pump();

    expect(postVm.toggleLikeCalls, 1);
    expect(postVm.lastCurrentlyLiked, false);
    expect(postVm.lastMyUserId, 'me');
    expect(postVm.lastPostId, 'p1');
  });

  testWidgets('3) Double-tap on media area calls toggleLike', (tester) async {
    final myUser = UserEntity(
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
      authorId: 'u1',
      authorUsername: 'author1',
      likedBy: const [],
      media: null,
    );

    final postVm = TestPostViewModel();
    final userVm = TestUserViewModel(myUser);

    await pumpPostcard(tester, post: post, postVm: postVm, userVm: userVm);

    final mediaArea = find.byType(AspectRatio);
    expect(mediaArea, findsOneWidget);

    await tester.ensureVisible(mediaArea);
    await tester.pump();

    await tester.tap(mediaArea);
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(mediaArea);

    await tester.pump(const Duration(milliseconds: 800));

    expect(postVm.toggleLikeCalls, 1);
    expect(postVm.lastCurrentlyLiked, false);
  });
  testWidgets('4) When likeBusy is true, like button is disabled', (
    tester,
  ) async {
    final myUser = UserEntity(
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
      authorId: 'u1',
      authorUsername: 'author1',
      likedBy: const [],
    );

    final postVm = TestPostViewModel();
    final userVm = TestUserViewModel(myUser);

    await pumpPostcard(tester, post: post, postVm: postVm, userVm: userVm);

    // Force busy
    postVm.setBusy('p1', true);
    await tester.pump();

    // Like IconButton uses onPressed: likeBusy ? null : toggleLike
    final likeBtn = tester.widget<IconButton>(find.byType(IconButton).first);
    expect(likeBtn.onPressed, isNull);

    // tapping should not call toggleLike
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(postVm.toggleLikeCalls, 0);
  });
}
