import 'package:artsphere/app/theme/app_theme.dart';
import 'package:artsphere/core/themes/theme_notifier.dart';
import 'package:artsphere/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: applicationTheme(),

      // Dark Theme
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      ),

      themeMode: themeMode,

      home: const SplashScreen(),
    );
  }
}
