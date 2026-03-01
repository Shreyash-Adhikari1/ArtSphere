import 'package:artsphere/app/routes/app_routes.dart';
import 'package:artsphere/core/services/storage/onboarding_pref_service.dart';
import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:artsphere/features/auth/presentation/pages/home_screen.dart';
import 'package:artsphere/features/auth/presentation/pages/login_page.dart';
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

    Future.delayed(const Duration(seconds: 3), () async {
      final session = ref.read(userSessionServiceProvider);
      final onboarding = ref.read(onboardingPrefServiceProvider);

      final isLoggedIn = session.isLoggedIn();
      final seenOnboarding = onboarding.hasSeen();

      if (!mounted) return;

      if (isLoggedIn) {
        AppRoutes.pushReplacement(context, HomeScreen());
        return;
      }

      // Not logged in:
      // If first time → onboarding, else → login
      if (!seenOnboarding) {
        AppRoutes.pushReplacement(context, const OnboardingScreen());
      } else {
        AppRoutes.pushReplacement(context, const LoginScreen());
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
        child: Center(child: Image.asset('assets/images/artsphere_logo.png')),
      ),
    );
  }
}
