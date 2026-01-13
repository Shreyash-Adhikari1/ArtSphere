import 'package:artsphere/app/app.dart';
import 'package:artsphere/core/services/hive/hive_service.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();

  // Shared Preferences object : because shared prefs is async and provider is sync 

  // Shared Prefs object
  final sharedPrefs= await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
    child: MyApp()));
}
