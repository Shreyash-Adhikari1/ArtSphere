import 'dart:io';
import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/post/data/models/edit/edit_post_api_model.dart';
import 'package:artsphere/features/post/data/models/post_api_model.dart';
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
  Future<EditPostApiModel> editPost(
    String postId,
    EditPostApiModel post,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.editPost(postId),
      data: post.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data["success"] == true) {
      final data = response.data["post"] as Map<String, dynamic>;
      final editedPost = EditPostApiModel.fromJson(data);
      return editedPost;
    }
    throw Exception(response.data["message"] ?? "Failed to edit post");
  }

  @override
  Future<List<PostApiModel>> getFeed() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getFeed,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final List data = response.data["posts"] as List;
      final posts = data
          .map((json) => PostApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return posts;
    }
    throw Exception(response.data["message"] ?? "Failed to fetch feed");
  }

  @override
  Future<List<PostApiModel>> getFollowingFeed() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getFollowingFeed,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final List data = response.data["posts"] as List;
      final posts = data
          .map((json) => PostApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return posts;
    }
    throw Exception(response.data["message"] ?? "Failed to fetch feed");
  }

  @override
  Future<List<PostApiModel>> getMyPosts() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getMyPosts,
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data['success'] == true) {
      final List data = response.data["posts"] as List;
      final posts = data
          .map((json) => PostApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return posts;
    }
    throw Exception(
      response.data['message'] ?? "Failed t0 fetch following feed",
    );
  }

  @override
  Future<List<PostApiModel>> getPostsByUser(String userId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getPostsByUser(userId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data['success'] == true) {
      final List<dynamic> data =
          response.data["posts"] as List<Map<String, dynamic>>;
      final posts = data
          .map((json) => PostApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return posts;
    }
    throw Exception(
      response.data['message'] ?? "Failed to fetch posts by user",
    );
  }

  @override
  Future<bool> deletePost(String postId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deletePost(postId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to delete post");
  }

  @override
  Future<bool> likePost(String postId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.likePost(postId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to like post");
  }

  @override
  Future<bool> unlikePost(String postId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.unlikePost(postId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to unlike post");
  }
}
