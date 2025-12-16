import 'package:artsphere/screens/home/challenges_screen.dart';
import 'package:artsphere/screens/home/create_screen.dart';
import 'package:artsphere/screens/home/discover_screen.dart';
import 'package:artsphere/screens/home/profile_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> lstScreens =[
    const DiscoverScreen(),
    const CreateScreen(),
    const ChallengesScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          "Discover",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20, top: 10),
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
      body: lstScreens[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFC974A6),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: "Create",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.extension),
              label: "Challenges"
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap:(index) {
            setState(() {
              _selectedIndex=index;
            });
          },
        ),
      ),
    );
  }
}
