import 'package:artsphere/features/comment/data/models/comment_api_model.dart';
import 'package:artsphere/features/comment/data/models/create/create_comment_api_model.dart';

abstract interface class ICommentRemoteDatasource {
  // Create
  Future<CommentApiModel> createComment(CreateCommentApiModel comment);

  // Get
  Future<List<CommentApiModel>> getCommentsByUser(String userId);
  Future<CommentApiModel> getCommentById(String commentId);

  // Like/Unlike
  Future<CommentApiModel> likeComment(String commentId, String userId);
  Future<CommentApiModel> unlikeComment(String commentId, String userId);

  // Delete
  Future<bool> deleteComment(String commentId);
}
