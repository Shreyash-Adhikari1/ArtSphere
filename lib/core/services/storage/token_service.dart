import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artsphere/core/services/storage/secure_storage_service.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(storage: ref.read(secureStorageProvider));
});

class TokenService {
  final dynamic _storage; // FlutterSecureStorage
  TokenService({required dynamic storage}) : _storage = storage;

  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
