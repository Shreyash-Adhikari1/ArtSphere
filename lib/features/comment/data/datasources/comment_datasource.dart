import 'package:artsphere/features/comment/data/models/comment_api_model.dart';
import 'package:artsphere/features/comment/data/models/create/create_comment_api_model.dart';

abstract interface class ICommentRemoteDatasource {
  // Create
  Future<CommentApiModel> createComment(
    String postId,
    CreateCommentApiModel comment,
  );

  // Get
  Future<List<CommentApiModel>> getCommentsForPost(String postId);
  Future<List<CommentApiModel>> getCommentsByUser(String userId);
  Future<CommentApiModel> getCommentById(String commentId);

  // Like/Unlike
  Future<bool> likeComment(String commentId);
  Future<bool> unlikeComment(String commentId);

  // Delete
  Future<bool> deleteComment(String commentId);
}
