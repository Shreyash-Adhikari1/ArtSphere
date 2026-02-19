import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/comment/data/datasources/comment_datasource.dart';
import 'package:artsphere/features/comment/data/models/comment_api_model.dart';
import 'package:artsphere/features/comment/data/models/create/create_comment_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentRemoteDatasourceProvider = Provider<ICommentRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return CommentRemoteDatasource(
    apiClient: apiClient,
    tokenservice: tokenService,
  );
});

class CommentRemoteDatasource implements ICommentRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  CommentRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenservice,
  }) : _apiClient = apiClient,
       _tokenService = tokenservice;

  // Methods Implementation
  @override
  Future<CommentApiModel> createComment(
    String postId,
    CreateCommentApiModel comment,
  ) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.createComment(postId),
      data: comment.toJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: Headers.jsonContentType,
      ),
    );

    if (response.data['success'] == true) {
      final commentJson = Map<String, dynamic>.from(response.data["comment"]);
      return CommentApiModel.fromJson(commentJson);
    }

    throw Exception(response.data["message"] ?? "Failed to create comment");
  }

  @override
  Future<List<CommentApiModel>> getCommentsForPost(String postId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getCommentsForPost(postId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data["success"] == true) {
      final List commentData = response.data["comments"] as List;
      final comments = commentData
          .map(
            (json) => CommentApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return comments;
    }
    throw Exception(
      response.data["message"] ?? "Failed to get comments for post",
    );
  }

  @override
  Future<CommentApiModel> getCommentById(String commentId) async {
    // TODO: implement getCommentById
    throw UnimplementedError();
  }

  @override
  Future<List<CommentApiModel>> getCommentsByUser(String userId) async {
    // TODO: implement getCommentsByUser
    throw UnimplementedError();
  }

  @override
  Future<bool> likeComment(String commentId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.likeComment(commentId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to like comment");
  }

  @override
  Future<bool> unlikeComment(String commentId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.unlikeComment(commentId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to unlike comment");
  }

  @override
  Future<bool> deleteComment(String commentId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deleteComment(commentId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to delete comment");
  }
}
