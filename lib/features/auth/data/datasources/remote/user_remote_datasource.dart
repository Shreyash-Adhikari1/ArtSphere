import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/api/api_endpoints.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:artsphere/features/auth/data/datasources/user_datasource.dart';
import 'package:artsphere/features/auth/data/models/edit_profile_api_model.dart';
import 'package:artsphere/features/auth/data/models/user_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// User Remote DAtasource Provider
// Reads API Client provider
final userRemoteDatasourceProvider = Provider<IUserRemoteDatasource>((ref) {
  return UserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class UserRemoteDatasource implements IUserRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  UserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<UserApiModel?> getProfile() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getProfile,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final user = UserApiModel.fromJson(data);
      return user;
    }
    return null;
  }

  @override
  Future<UserApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final user = UserApiModel.fromJson(data);

      // save user session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
      );
      // Save Token
      final token = response.data['token'] as String?;
      await _tokenService.saveToken(token!);

      return user;
    }

    return null;
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<UserApiModel> registerUser(UserApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: model.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final registeredUser = UserApiModel.fromJson(data);
      return registeredUser;
    }

    return model;
  }

  @override
  Future<EditProfileApiModel> editProfile(EditProfileApiModel model) async {
    final formData = FormData.fromMap({
      if (model.fullName != null) 'fullName': model.fullName,
      if (model.username != null) 'username': model.username,
      if (model.phoneNumber != null) 'phoneNumber': model.phoneNumber,
      if (model.address != null) 'address': model.address,

      if (model.avatar != null)
        'profile-image': await MultipartFile.fromFile(
          model.avatar!,
          filename: model.avatar!.split('/').last,
        ),
    });
    // get token to move further
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.editProfile,
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final editedUser = EditProfileApiModel.fromJson(data);
      return editedUser;
    }
    return model;
  }

  @override
  Future<UserApiModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
}
