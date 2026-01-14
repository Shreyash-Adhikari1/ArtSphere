import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:artsphere/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart'; 

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      final userSessionService= ref.read(userSessionServiceProvider);
      final isLoggedIn = userSessionService.isLoggedIn();
      if (isLoggedIn) {
        AppRoutes.pushReplacement(context, HomeScreen());
      }else{
        AppRoutes.pushReplacement(context, OnboardingScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFFFFF6ED),
        child: Center(
          child: Image.asset('assets/images/artsphere_logo.png'),
        ),
      ),
    );
  }
}
