import 'dart:io';

import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/models/comment/comment_api_model.dart';
import 'package:artsphere/features/post/data/models/post/create/create_post_api_model.dart';
import 'package:artsphere/features/post/data/models/post/post_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRemoteDatasourceProvider = Provider<IPostRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return PostRemoteDatasource(apiClient: apiClient, tokenservice: tokenService);
});

class PostRemoteDatasource implements IPostRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  PostRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenservice,
  }) : _apiClient = apiClient,
       _tokenService = tokenservice;

  @override
  Future<PostApiModel> createPost(
    CreatePostApiModel post,
    String mediaPath,
  ) async {
    final file = File(mediaPath);

    if (!await file.exists()) {
      throw Exception("File not found: $mediaPath");
    }

    final formData = FormData.fromMap({
      "post-images": await MultipartFile.fromFile(
        mediaPath,
        filename: mediaPath.split(Platform.pathSeparator).last,
      ),

      // normal fields
      "caption": post.caption ?? "",
      "mediaType": post.mediaType ?? "image",
      "visibility": post.visibility ?? "public",

      // tags[] (backend should accept this)
      "tags": post.tags ?? [],
    });
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createPost,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: "multipart/form-data",
      ),
    );

    if (response.data["success"] == true) {
      final postJson = Map<String, dynamic>.from(response.data["post"]);
      return PostApiModel.fromJson(postJson);
    }

    throw Exception(response.data["message"] ?? "Failed to create post");
  }

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
