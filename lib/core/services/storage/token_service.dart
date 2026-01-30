import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(prefs: ref.read(sharedPreferencesProvider));
});

class TokenService {
  final SharedPreferences _prefs;
  TokenService({required SharedPreferences prefs}) : _prefs = prefs;
  static const String _tokenKey = 'auth_token';

  // Save token: secure storage
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // get token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // remove token
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }
}
