import 'package:artsphere/features/comment/data/models/comment_api_model.dart';

abstract interface class ICommentRemoteDatasource {
  Future<CommentApiModel> createComment(CommentApiModel comment);
  Future<bool> deleteComment(String commentId);
  Future<CommentApiModel> likeComment(String commentId, String userId);
  Future<CommentApiModel> unlikeComment(String commentId, String userId);
  Future<List<CommentApiModel>> getCommentsByUser(String userId);
  Future<CommentApiModel> getCommentById(String commentId);
}
