import 'package:artsphere/features/auth/data/models/edit_user/edit_profile_api_model.dart';
import 'package:artsphere/features/auth/data/models/user/user_api_model.dart';
import 'package:artsphere/features/auth/data/models/hive/user_hive_model.dart';

abstract interface class IUserLocalDatasource {
  Future<UserHiveModel> registerUser(UserHiveModel model);
  Future<UserHiveModel?> loginUser(String email, String password);
  Future<UserHiveModel?> getCurrentUser();
  Future<bool> logout();

  // Extra Methods: Doesnt Have to be in DOMAIN LAYER repository

  // Method to check if email exixts
  Future<bool> isEmailExists(String email);
}

abstract interface class IUserRemoteDatasource {
  Future<UserApiModel> registerUser(UserApiModel model);
  Future<UserApiModel?> getCurrentUser();
  Future<UserApiModel?> loginUser(String email, String password);
  Future<bool> logout();

  Future<UserApiModel?> getProfile();
  Future<EditProfileApiModel> editProfile(EditProfileApiModel model);
}
