import 'dart:io';

import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/post/data/datasources/post_datasource.dart';
import 'package:artsphere/features/comment/data/models/comment_api_model.dart';
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
  Future<bool> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<PostApiModel> editPost(EditPostApiModel post) {
    // TODO: implement editPost
    throw UnimplementedError();
  }

  @override
  Future<List<PostApiModel>> getFeed() {
    // TODO: implement getFeed
    throw UnimplementedError();
  }

  @override
  Future<List<PostApiModel>> getFollowingFeed() {
    // TODO: implement getFollowingFeed
    throw UnimplementedError();
  }

  @override
  Future<List<PostApiModel>> getMyPosts() {
    // TODO: implement getMyPosts
    throw UnimplementedError();
  }

  @override
  Future<List<PostApiModel>> getPostsByUser(String userId) {
    // TODO: implement getPostsByUser
    throw UnimplementedError();
  }

  @override
  Future<PostApiModel> likePost(String postId, String userId) {
    // TODO: implement likePost
    throw UnimplementedError();
  }

  @override
  Future<PostApiModel> unlikePost(String postId, String userId) {
    // TODO: implement unlikePost
    throw UnimplementedError();
  }
}
