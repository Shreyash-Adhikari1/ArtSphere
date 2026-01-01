import 'package:artsphere/features/auth/data/models/user_hive_model.dart';

abstract interface class IUserDatasource {
  Future<bool>registerUser(UserHiveModel model);
  Future<UserHiveModel?> loginUser(String email, String password);
  Future<UserHiveModel?> getCurrentUser();
  Future<bool>logout();

  // Extra Methods: Doesnt Have to be in DOMAIN LAYER repository

  // Method to check if email exixts
  Future<bool> isEmailExists(String email);
}