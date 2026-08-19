import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  // 💾 Save the user and mark onboarding as complete
  Future<void> _completeSignup() async {
    if (_nameController.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    await prefs.setString('user_name', _nameController.text.trim());

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is active
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔄 Page Indicator
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _currentPage == 2 ? null : () => _pageController.jumpToPage(2),
                  child: Text(
                    _currentPage == 2 ? '' : 'Skip',
                    style: const TextStyle(color: Color(0xFF546E7A), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // 📖 Swipeable Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  // PAGE 1: Welcome
                  _buildPage(
                    icon: Icons.spa_rounded,
                    color: const Color(0xFF2CB5C0), // Teal
                    title: 'Welcome to MindFlow',
                    description: 'Your personal space to navigate stress and find your calm.',
                    textColor: textColor,
                  ),
                  
                  // PAGE 2: The "Heads Up" Explanation
                  _buildPage(
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFF16E73), // Coral
                    title: 'What is this app?',
                    description: 'When everything feels off: High stress? Low energy? Tap the SOS button for instant kinetic relief, or log your mood to track your mental flow over time.',
                    textColor: textColor,
                  ),
                  
                  // PAGE 3: The "Sign Up" Screen
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 80, color: Color(0xFF9163A6)),
                        const SizedBox(height: 32),
                        Text(
                          'Let\'s get started',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'What should we call you?',
                          style: TextStyle(fontSize: 16, color: Color(0xFF546E7A)),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF2CB5C0), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔘 Navigation Controls
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots indicator
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? const Color(0xFF2CB5C0) : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next / Start Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == 2) {
                        _completeSignup();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B3E), // Navy
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(_currentPage == 2 ? 'Start Flowing' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for the first two pages
  Widget _buildPage({required IconData icon, required Color color, required String title, required String description, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 80, color: color),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF546E7A), height: 1.5),
          ),
        ],
      ),
    );
  }
}