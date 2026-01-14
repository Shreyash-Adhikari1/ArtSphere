import 'package:artsphere/core/services/hive/hive_service.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:artsphere/features/auth/data/datasources/user_datasource.dart';
import 'package:artsphere/features/auth/data/models/user_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Local datasource Provider
final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return UserLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class UserLocalDatasource implements IUserLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  UserLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
      _userSessionService = userSessionService;

  @override
  Future<UserHiveModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<UserHiveModel?> loginUser(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      // saving User data in Shared Preferences
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          address: user.address,
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logout();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<UserHiveModel> registerUser(UserHiveModel model) async {
      return await _hiveService.registerUser(model);
  }
}
