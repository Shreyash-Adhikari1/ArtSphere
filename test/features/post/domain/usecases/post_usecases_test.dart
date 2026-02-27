import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/repositories/post_repository.dart';
import 'package:artsphere/features/post/domain/usecases/create_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/edit_post_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/get_feed_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/get_my_posts_usecase.dart';
import 'package:artsphere/features/post/domain/usecases/like_post_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock Repository
class MockPostRepository extends Mock implements IPostRepository {}

// Fakes (for any())
class FakeEditPostParams extends Fake implements EditPostUsecaseParams {}

class FakePostEntity extends Fake implements PostEntity {}

void main() {
  late MockPostRepository repo;

  late CreatePostUsecase createPostUsecase;
  late EditPostUsecase editPostUsecase;
  late GetFeedUsecase getFeedUsecase;
  late GetMyPostsUsecase getMyPostsUsecase;
  late DeletePostUsecase deletePostUsecase;

  setUpAll(() {
    registerFallbackValue(FakeEditPostParams());
    registerFallbackValue(FakePostEntity());
  });

  setUp(() {
    repo = MockPostRepository();

    createPostUsecase = CreatePostUsecase(postRepository: repo);
    editPostUsecase = EditPostUsecase(postRepository: repo);
    getFeedUsecase = GetFeedUsecase(postRepository: repo);
    getMyPostsUsecase = GetMyPostsUsecase(postRepository: repo);
    deletePostUsecase = DeletePostUsecase(postRepository: repo);
  });

  group('CreatePostUsecase', () {
    test(
      'calls repo.createPost(post, mediaPath) with mapped PostEntity and returns Right(PostEntity)',
      () async {
        const created = PostEntity(
          postId: "p1",
          mediaType: "image",
          caption: "hello",
          tags: ["art"],
          visibility: "public",
        );

        when(
          () => repo.createPost(
            post: any(named: 'post'),
            mediaPath: any(named: 'mediaPath'),
          ),
        ).thenAnswer((_) async => const Right(created));

        final result = await createPostUsecase(
          const CreatePostUsecaseParams(
            mediaPath: "/tmp/a.png",
            mediaType: "image",
            caption: "hello",
            tags: ["art"],
            visibility: "public",
          ),
        );

        expect(result, const Right(created));

        verify(
          () => repo.createPost(
            mediaPath: "/tmp/a.png",
            post: any(
              named: 'post',
              that: isA<PostEntity>()
                  .having((p) => p.mediaType, 'mediaType', "image")
                  .having((p) => p.caption, 'caption', "hello")
                  .having((p) => p.tags, 'tags', ["art"])
                  .having((p) => p.visibility, 'visibility', "public"),
            ),
          ),
        ).called(1);

        verifyNoMoreInteractions(repo);
      },
    );

    test('returns Left(Failure) when repo fails', () async {
      const failure = ApiFailure(message: "Upload failed", statusCode: 400);

      when(
        () => repo.createPost(
          post: any(named: 'post'),
          mediaPath: any(named: 'mediaPath'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await createPostUsecase(
        const CreatePostUsecaseParams(mediaPath: "/tmp/a.png"),
      );

      expect(result, const Left(failure));
      verify(
        () => repo.createPost(
          post: any(named: 'post'),
          mediaPath: any(named: 'mediaPath'),
        ),
      ).called(1);
    });
  });

  group('EditPostUsecase', () {
    test('calls repo.editPost(params) and returns Right(true)', () async {
      when(
        () => repo.editPost(any()),
      ).thenAnswer((_) async => const Right(true));

      const params = EditPostUsecaseParams(
        postId: "p1",
        caption: "updated",
        tags: ["tag1"],
        visibility: "private",
      );

      final result = await editPostUsecase(params);

      expect(result, const Right(true));

      verify(
        () => repo.editPost(
          any(
            that: isA<EditPostUsecaseParams>()
                .having((p) => p.postId, 'postId', "p1")
                .having((p) => p.caption, 'caption', "updated")
                .having((p) => p.tags, 'tags', ["tag1"])
                .having((p) => p.visibility, 'visibility', "private"),
          ),
        ),
      ).called(1);

      verifyNoMoreInteractions(repo);
    });
  });

  group('GetFeedUsecase', () {
    test('calls repo.getFeed() and returns Right(List<PostEntity>)', () async {
      const feed = [PostEntity(postId: "p1"), PostEntity(postId: "p2")];

      when(() => repo.getFeed()).thenAnswer((_) async => const Right(feed));

      final result = await getFeedUsecase();

      expect(result, const Right(feed));
      verify(() => repo.getFeed()).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('GetMyPostsUsecase', () {
    test(
      'calls repo.getMyPosts() and returns Right(List<PostEntity>)',
      () async {
        const mine = [PostEntity(postId: "m1"), PostEntity(postId: "m2")];

        when(
          () => repo.getMyPosts(),
        ).thenAnswer((_) async => const Right(mine));

        final result = await getMyPostsUsecase();

        expect(result, const Right(mine));
        verify(() => repo.getMyPosts()).called(1);
        verifyNoMoreInteractions(repo);
      },
    );
  });

  group('DeletePostUsecase', () {
    test('calls repo.deletePost(postId) and returns Right(true)', () async {
      when(
        () => repo.deletePost("p1"),
      ).thenAnswer((_) async => const Right(true));

      final result = await deletePostUsecase(
        const DeletePostUsecaseParams(postId: "p1"),
      );

      expect(result, const Right(true));
      verify(() => repo.deletePost("p1")).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Left(Failure) when repo fails', () async {
      const failure = ApiFailure(message: "Delete failed", statusCode: 400);
      when(
        () => repo.deletePost("p1"),
      ).thenAnswer((_) async => const Left(failure));

      final result = await deletePostUsecase(
        const DeletePostUsecaseParams(postId: "p1"),
      );

      expect(result, const Left(failure));
      verify(() => repo.deletePost("p1")).called(1);
    });
  });

  group('LikePostUsecase', () {
    late LikePostUsecase likePostUsecase;

    setUp(() {
      likePostUsecase = LikePostUsecase(postRepository: repo);
    });

    test('calls repo.likePost(postId) and returns Right(true)', () async {
      when(
        () => repo.likePost("p1"),
      ).thenAnswer((_) async => const Right(true));

      final result = await likePostUsecase(
        const LikePostUsecaseParams(postId: "p1"),
      );

      expect(result, const Right(true));

      verify(() => repo.likePost("p1")).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('returns Left(Failure) when repo.likePost fails', () async {
      const failure = ApiFailure(message: "Failed to like", statusCode: 400);

      when(
        () => repo.likePost("p1"),
      ).thenAnswer((_) async => const Left(failure));

      final result = await likePostUsecase(
        const LikePostUsecaseParams(postId: "p1"),
      );

      expect(result, const Left(failure));

      verify(() => repo.likePost("p1")).called(1);
    });
  });
}
