import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';

final biometricPrefServiceProvider = Provider<BiometricPrefService>((ref) {
  return BiometricPrefService(prefs: ref.read(sharedPreferencesProvider));
});

class BiometricPrefService {
  final SharedPreferences _prefs;
  BiometricPrefService({required SharedPreferences prefs}) : _prefs = prefs;

  static const _keyBioEnabled = "biometric_enabled";

  bool isEnabled() => _prefs.getBool(_keyBioEnabled) ?? false;
  Future<void> setEnabled(bool v) => _prefs.setBool(_keyBioEnabled, v);
}