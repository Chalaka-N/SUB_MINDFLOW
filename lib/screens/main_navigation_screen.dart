import 'package:flutter/material.dart';
import 'home_dashboard.dart'; // Brings in your newly designed dashboard!
import 'journal_screen.dart'; // Brings in the new Journal Screen!
import 'profile_screen.dart'; // Profile screen
import 'ai_assistant_screen.dart'; // AI Assistant screen
import 'history_screen.dart'; // 👈 History screen import

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
    const HistoryScreen(), // 👈 Added History screen tab!
    const AiAssistantScreen(), 
    const ProfileScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Clean white background
      body: _screens[_currentIndex],
      
      // 🧭 The Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D2A4A).withValues(alpha: 0.05), // Soft Navy shadow
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Switches the active screen
            });
          },
          backgroundColor: const Color(0xFFFFFFFF), // Pure White
          selectedItemColor: const Color(0xFF2CB5C0), // Teal for selected tab
          unselectedItemColor: const Color(0xFF546E7A).withValues(alpha: 0.5), // Faded Slate Gray
          showSelectedLabels: true,
          showUnselectedLabels: false, // Cleaner look without unselected text
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
              icon: Icon(Icons.history_rounded), // 👈 Added History tab icon!
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