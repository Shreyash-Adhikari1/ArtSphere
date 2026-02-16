import 'package:artsphere/features/post/data/models/comment/comment_api_model.dart';
import 'package:artsphere/features/post/data/models/post/create/create_post_api_model.dart';
import 'package:artsphere/features/post/data/models/post/post_api_model.dart';

abstract interface class IPostRemoteDatasource {
  // Posts
  Future<PostApiModel> createPost(CreatePostApiModel post, String mediaPath);
  Future<PostApiModel> likePost(String postId, String userId);
  Future<PostApiModel> unlikePost(String postId, String userId);
  Future<List<PostApiModel>> getPostsByUser(String userId);
  Future<bool> deletePost(String postId);

  // Comments
  Future<CommentApiModel> createComment(CommentApiModel comment);
  Future<bool> deleteComment(String commentId);
  Future<CommentApiModel> likeComment(String commentId, String userId);
  Future<CommentApiModel> unlikeComment(String commentId, String userId);
  Future<List<CommentApiModel>> getCommentsByUser(String userId);
  Future<CommentApiModel> getCommentById(String commentId);
}
