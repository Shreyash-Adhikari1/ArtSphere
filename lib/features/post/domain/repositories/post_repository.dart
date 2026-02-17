import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/domain/usecases/edit_post_usecase.dart';
import 'package:dartz/dartz.dart';

abstract interface class IPostRepository {
  // Create
  Future<Either<Failure, PostEntity>> createPost({
    required PostEntity post,
    required String mediaPath,
  });

  // Update
  Future<Either<Failure, bool>> editPost(EditPostUsecaseParams params);

  // Retireve
  Future<Either<Failure, List<PostEntity>>> getMyPosts();
  Future<Either<Failure, List<PostEntity>>> getUsersPosts(String userId);
  Future<Either<Failure, List<PostEntity>>> getFeed();
  Future<Either<Failure, List<PostEntity>>> getFollowingFeed();

  // Delete
  Future<Either<Failure, bool>> deletePost(String postId);

  //Delete
  Future<Either<Failure, PostEntity>> likePost(String postId, String userId);
  Future<Either<Failure, PostEntity>> unlikePost(String postId, String userId);
}
