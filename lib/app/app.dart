import 'package:artsphere/features/splash/presentation/pages/splash_page.dart';
import 'package:artsphere/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: applicationTheme(),
      home:SplashScreen() ,
    );
  }
}