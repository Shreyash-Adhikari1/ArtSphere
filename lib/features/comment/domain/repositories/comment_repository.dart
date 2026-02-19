import 'package:artsphere/core/error/failures.dart';
import 'package:artsphere/features/comment/domain/entities/comment_entity.dart';
import 'package:artsphere/features/comment/domain/usecases/create_comment_usecase.dart';
import 'package:dartz/dartz.dart';

abstract interface class ICommentRepository {
  // Create Coment
  Future<Either<Failure, CommentEntity>> createComment(
    CreateCommentUsecaseParams params,
  );

  // Get Comment for post
  Future<Either<Failure, List<CommentEntity>>> getCommentsForPost(
    String postId,
  );

  // Like/ Unlike Comment
  Future<Either<Failure, bool>> likeComment(String commentId);
  Future<Either<Failure, bool>> unlikeComment(String commentId);

  // Delete Comment
  Future<Either<Failure, bool>> deleteComment(String commentId);
}
