import 'package:artsphere/screens/login_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding_welc.png", 
      "title": "Welcome to ArtSphere",
      "description": "Discover amazing art from talented creators around the world."
    },
    {
      "image": "assets/images/onboarding_connect.png",
      "title": "Connect with Artists",
      "description": "Follow, like, and comment on your favorite artworks."
    },
    {
      "image": "assets/images/onboarding_share.png",
      "title": "Share Your Own Art",
      "description": "Upload your creations and inspire the community."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
