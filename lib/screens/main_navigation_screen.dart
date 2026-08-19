import 'package:flutter/material.dart';
import 'home_dashboard.dart'; 
import 'journal_screen.dart'; 
import 'profile_screen.dart'; 
import 'ai_chat_screen.dart'; // 👈 1. Updated import
import 'history_screen.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // 🗂️ The 5 core screens we can navigate to using the bottom bar
  final List<Widget> _screens = [
    const HomeDashboard(),
    const JournalScreen(hideBackButton: true), 
    const HistoryScreen(), 
    const AIChatScreen(), // 👈 2. Updated to use the fully connected Gemini screen!
    const ProfileScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), 
      body: _screens[_currentIndex],
      
      // 🧭 The Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D2A4A).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; 
            });
          },
          backgroundColor: const Color(0xFFFFFFFF), 
          selectedItemColor: const Color(0xFF2CB5C0), 
          unselectedItemColor: const Color(0xFF546E7A).withValues(alpha: 0.5), 
          showSelectedLabels: true,
          showUnselectedLabels: false, 
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_rounded), 
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}