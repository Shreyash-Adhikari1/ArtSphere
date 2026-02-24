import 'dart:io';

import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/post/data/models/create/create_post_api_model.dart';
import 'package:artsphere/features/submission/data/datasources/submission_datasource.dart';
import 'package:artsphere/features/submission/data/models/submission_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submissionRemoteDatasourceProvider =
    Provider<ISubmissionRemoteDatasource>((ref) {
      return SubmissionRemoteDatasource(
        tokenService: ref.read(tokenServiceProvider),
        apiClient: ref.read(apiClientProvider),
      );
    });

class SubmissionRemoteDatasource implements ISubmissionRemoteDatasource {
  final TokenService _tokenService;
  final ApiClient _apiClient;
  SubmissionRemoteDatasource({
    required TokenService tokenService,
    required ApiClient apiClient,
  }) : _tokenService = tokenService,
       _apiClient = apiClient;

  @override
  Future<SubmissionApiModel> submitExistingPost(
    String challengeId,
    String postId,
  ) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.submitExistingPost(challengeId),
      data: {"postId": postId},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.data['success'] == true) {
      final submitJson = response.data['submission'] as Map<String, dynamic>;
      return SubmissionApiModel.fromJson(submitJson);
    }
    throw Exception(
      response.data["message"] ?? "Failed to submit existing post",
    );
  }

  @override
  Future<SubmissionApiModel> createNewPostAndSubmit(
    String challengeId,
    CreatePostApiModel post,
    String mediaPath,
  ) async {
    final file = File(mediaPath);

    if (!await file.exists()) {
      throw Exception("File not found: $mediaPath");
    }

    final formData = FormData.fromMap({
      "challenge-submissions": await MultipartFile.fromFile(
        mediaPath,
        filename: mediaPath.split(Platform.pathSeparator).last,
      ),
      // normal fields
      "caption": post.caption ?? "",
      "mediaType": post.mediaType ?? "image",
      "visibility": post.visibility ?? "public",
      "tags": post.tags ?? [],
    });
    final token = await _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createNewPostAndSubmit(challengeId),
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: Headers.multipartFormDataContentType,
      ),
    );
    if (response.data["success"] == true) {
      final submitJson = Map<String, dynamic>.from(response.data["submission"]);
      return SubmissionApiModel.fromJson(submitJson);
    }

    throw Exception(
      response.data["message"] ?? "Failed to create post and submit",
    );
  }

  @override
  Future<List<SubmissionApiModel>> getSubmissionsForChallenge(
    String challengeId,
  ) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getSubmissionsForChallenge(challengeId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data['success'] == true) {
      final List data = response.data["submission"] as List;
      final submissions = data
          .map(
            (json) =>
                SubmissionApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return submissions;
    }
    throw Exception(
      response.data["message"] ?? "Failed to get submissions for post",
    );
  }

  @override
  Future<bool> deleteSubmission(String submissionId) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deleteSubmission(submissionId),
      options: Options(headers: {'Authorization': "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      return true;
    }
    throw Exception(response.data["message"] ?? "Failed to delete submission");
  }
}
