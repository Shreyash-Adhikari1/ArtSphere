import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/models/comment/comment_api_model.dart';
import 'package:artsphere/features/post/data/models/post/post_api_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

final postRemoteDatasourceProvider = Provider<IPostRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PostRemoteDatasource(apiClient: apiClient);
});

class PostRemoteDatasource implements IPostRemoteDatasource {
  final ApiClient _apiClient;
  PostRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;
  @override
  Future<CommentApiModel> createComment(CommentApiModel comment) async {
    // TODO: implement createComment
    throw UnimplementedError();
    // final response = await _apiClient.post(
    //   ApiEndpoints.createComment(id),
    //   data:comment.toJson()
    // );
    // if
  }

  @override
  Future<PostApiModel> createPost(PostApiModel post) async {
    final response = await _apiClient.post(
      ApiEndpoints.createPost,
      data: post.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['post'] as Map<String, dynamic>;
      final createdPost = PostApiModel.fromJson(data);
      return createdPost;
    }
    return post;
  }

  @override
  Future<bool> deleteComment(String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }

  @override
  Future<bool> deletePost(String postId) async {
    final response = await _apiClient.delete(ApiEndpoints.deletePost(postId));

    if (response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to delete post');
    }
  }

  @override
  Future<CommentApiModel> getCommentById(String commentId) {
    // TODO: implement getCommentById
    throw UnimplementedError();
  }

  @override
  Future<List<CommentApiModel>> getCommentsByUser(String userId) {
    // TODO: implement getCommentsByUser
    throw UnimplementedError();
  }

  @override
  Future<List<PostApiModel>> getPostsByUser(String userId) {
    // TODO: implement getPostsByUser
    throw UnimplementedError();
  }

  @override
  Future<CommentApiModel> likeComment(String commentId, String userId) {
    // TODO: implement likeComment
    throw UnimplementedError();
  }

  @override
  Future<PostApiModel> likePost(String postId, String userId) {
    // TODO: implement likePost
    throw UnimplementedError();
  }

  @override
  Future<CommentApiModel> unlikeComment(String commentId, String userId) {
    // TODO: implement unlikeComment
    throw UnimplementedError();
  }

  @override
  Future<PostApiModel> unlikePost(String postId, String userId) {
    // TODO: implement unlikePost
    throw UnimplementedError();
  }
}
