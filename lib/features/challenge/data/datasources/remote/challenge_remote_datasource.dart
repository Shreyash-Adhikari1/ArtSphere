import 'dart:io';
import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/challenge/data/datasources/challenge_datasource.dart';
import 'package:artsphere/features/challenge/data/models/challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/create/create_challenge_api_model.dart';
import 'package:artsphere/features/challenge/data/models/edit/edit_challenge_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final challengeRemoteDatasourceProvider = Provider<IChallengeRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return ChallengeRemoteDatasource(
    apiClient: apiClient,
    tokenService: tokenService,
  );
});

class ChallengeRemoteDatasource implements IChallengeRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  ChallengeRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;
  @override
  Future<ChallengeApiModel> createChallenge(
    CreateChallengeApiModel challenge,
    String challengeMediaPath,
  ) async {
    final token = _tokenService.getToken();
    final file = File(challengeMediaPath);

    if (!await file.exists()) {
      throw Exception("File not found : $challengeMediaPath");
    }

    final formData = FormData.fromMap({
      "challenge-images": await MultipartFile.fromFile(
        challengeMediaPath,
        filename: challengeMediaPath.split(Platform.pathSeparator).last,
      ),
      "challengeTitle": challenge.challengeTitle,
      "challengeDescription": challenge.challengeDescription,
      "endsAt": challenge.endsAt.toIso8601String(),
    });

    final response = await _apiClient.post(
      ApiEndpoints.createChallenge,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: "multipart/form-data",
      ),
    );

    if (response.data["success"] == true) {
      final challengeJson = Map<String, dynamic>.from(
        response.data["challenge"],
      );
      return ChallengeApiModel.fromJson(challengeJson);
    }
    throw Exception(response.data["message"] ?? "Failed to create challenge");
  }

  @override
  Future<ChallengeApiModel> editChallenge(
    String challengeId,
    EditChallengeApiModel challenge,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.editChallenge(challengeId),
      data: challenge.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data['success'] == true) {
      final challengeJson = Map<String, dynamic>.from(
        response.data["challenge"],
      );
      return ChallengeApiModel.fromJson(challengeJson);
    }
    throw Exception(response.data["message"] ?? "failed to edit challenge");
  }

  @override
  Future<List<ChallengeApiModel>> getAllChallenges() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getAllChallenges,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data["success"] == true) {
      final List challengeData = response.data["challenges"] as List;
      final challenges = challengeData
          .map(
            (json) =>
                ChallengeApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return challenges;
    }
    throw Exception(response.data["message"] ?? "Failed to get all challenges");
  }

  @override
  Future<ChallengeApiModel> getChallengeById(String challengeId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getChallengeById(challengeId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data["success"] == true) {
      final challengeJson = response.data["challenge"] as Map<String, dynamic>;
      final challenge = ChallengeApiModel.fromJson(challengeJson);
      return challenge;
    }
    throw Exception(response.data["message"] ?? "Failed to get challenge");
  }

  @override
  Future<List<ChallengeApiModel>> getMyChallenges() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getMyChallenges,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data["success"] == true) {
      final List challengesData = response.data["challenges"] as List;
      final challenges = challengesData
          .map(
            (json) =>
                ChallengeApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return challenges;
    }
    throw Exception(
      response.data["message"] ?? "Failed to get challenges by user",
    );
  }

  @override
  Future<bool> deleteChallenge(String challengeId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deleteChallenge(challengeId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? "Failed to delete challenge");
  }

  @override
  Future<bool> deleteAllMyChallenges() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.delete(
      ApiEndpoints.deleteAllMyChallenges,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data['success'] == true) {
      return true;
    }
    throw Exception(
      response.data['message'] ?? "Failed to delete all challenges by user",
    );
  }
}
