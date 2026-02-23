import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/follow/data/datasources/follow_datasource.dart';
import 'package:artsphere/features/follow/data/models/follow_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followRemoteDatasourceProvider = Provider<IFollowRemoteDatasource>((ref) {
  return FollowRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class FollowRemoteDatasource implements IFollowRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  FollowRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;
  @override
  Future<FollowApiModel> followUser(String targetUserId) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.followUser(targetUserId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final followJson = Map<String, dynamic>.from(response.data["data"]);
      return FollowApiModel.fromJson(followJson);
    }
    throw Exception(response.data["message"] ?? "Failed to follow user");
  }

  @override
  Future<FollowApiModel> unfollowUser(String targetUserId) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.unfollowUser(targetUserId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final unfollowJson = Map<String, dynamic>.from(response.data["data"]);
      return FollowApiModel.fromJson(unfollowJson);
    }
    throw Exception(response.data["message"] ?? "Failed to unfollow user");
  }

  @override
  Future<List<FollowApiModel>> getMyFollowers() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getMyFollowers,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final List followData = response.data["data"] as List;
      final follower = followData
          .map(
            (json) => FollowApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return follower;
    }
    throw Exception(response.data["message"] ?? "Failed to get followers");
  }

  @override
  Future<List<FollowApiModel>> getMyFollowing() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getMyFollowing,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final List followData = response.data["data"] as List;
      final following = followData
          .map(
            (json) => FollowApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return following;
    }
    throw Exception(response.data["message"] ?? "Failed to get following");
  }

  @override
  Future<List<FollowApiModel>> getUsersFollowers(String userId) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getUsersFollowers(userId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final List data = (response.data['data'] as List?) ?? [];
      final followers = data
          .map(
            (json) => FollowApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return followers;
    }
    throw Exception(
      response.data["message"] ?? "Failed to get users followers",
    );
  }

  @override
  Future<List<FollowApiModel>> getUsersFollowing(String userId) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getUsersFollowing(userId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.data["success"] == true) {
      final List data = (response.data['data'] as List?) ?? [];
      final following = data
          .map(
            (json) => FollowApiModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
      return following;
    }
    throw Exception(
      response.data["message"] ?? "Failed to get users following",
    );
  }

  @override
  Future<bool> getIsFollowingStatus(String targetUserId) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.getIsFollowingStatus(targetUserId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (response.data["success"] == true) {
      return response.data["isFollowing"] == true;
    }
    throw Exception(
      response.data["message"] ?? "Failed to fetch follow status",
    );
  }
}
