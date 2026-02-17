import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/usecases/edit_post_usecase.dart';
import 'package:dartz/dartz.dart';

abstract interface class IPostRepository {
  Future<Either<Failure, PostEntity>> createPost({
    required PostEntity post,
    required String mediaPath,
  });

  Future<Either<Failure, bool>> editPost(EditPostUsecaseParams params);

  Future<Either<Failure, List<PostEntity>>> getMyPosts();
  Future<Either<Failure, List<PostEntity>>> getUsersPosts(String userId);
  Future<Either<Failure, List<PostEntity>>> getFeed();
  Future<Either<Failure, List<PostEntity>>> getFollowingFeed();

  Future<Either<Failure, bool>> deletePost(String postId);

  Future<Either<Failure, PostEntity>> likePost(String postId, String userId);
  Future<Either<Failure, PostEntity>> unlikePost(String postId, String userId);

  // You can change these later when you design comment entity properly
  Future<Either<Failure, PostEntity>> commentOnPost(
    String postId,
    String userId,
  );
  Future<Either<Failure, PostEntity>> deleteComment(
    String postId,
    String userId,
  );
}
