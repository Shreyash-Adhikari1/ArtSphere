// import 'package:artsphere/screens/home/home_screen.dart';
import 'package:artsphere/features/splash/presentation/pages/splash_page.dart';
import 'package:artsphere/themes/app_theme.dart';
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