import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IPostRepository {
  Future<Either<Failure, bool>> createPost(PostEntity post);
  Future<Either<Failure, PostEntity>> likePost(String postId, String userId);
  Future<Either<Failure, PostEntity>> unlikePost(String postId, String userId);
  Future<Either<Failure, List<PostEntity>>> getMyPosts(String userId);
  Future<Either<Failure, PostEntity>> deletePost(String postId);
  Future<Either<Failure, PostEntity>> commentOnPost(
    String postId,
    String userId,
  );
  Future<Either<Failure, PostEntity>> deleteComment(
    String postId,
    String userId,
  );
}
