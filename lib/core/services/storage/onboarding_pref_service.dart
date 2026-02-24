import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';

final onboardingPrefServiceProvider = Provider<OnboardingPrefService>((ref) {
  return OnboardingPrefService(prefs: ref.read(sharedPreferencesProvider));
});

class OnboardingPrefService {
  final SharedPreferences _prefs;
  OnboardingPrefService({required SharedPreferences prefs}) : _prefs = prefs;

  static const _keySeen = "seen_onboarding";

  bool hasSeen() => _prefs.getBool(_keySeen) ?? false;
  Future<void> setSeen(bool v) => _prefs.setBool(_keySeen, v);
}
