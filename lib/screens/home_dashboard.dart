import 'package:flutter/material.dart';
import 'mood_logger_screen.dart';
import 'journal_screen.dart';
import 'stress_pop_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  // 👇 ADDED: Function to calculate the time of day dynamically
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ The Custom Logo Graphic
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 180, 
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),

          // 👇 FIXED: Greeting Section is now dynamic!
          Text(
            _getGreeting(), // Automatically checks the time
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF546E7A), // Slate Gray
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ready to find your flow?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D2A4A), // Deep Navy from logo
            ),
          ),
          const SizedBox(height: 30),

          // Daily Focus Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Soft Light Grey
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2CB5C0).withValues(alpha: 0.3), // Teal border
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5C953).withValues(alpha: 0.2), // Light Green
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFFA5C953), // Leaf Green from logo
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Focus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2CB5C0), // Teal from logo
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Balance. Focus. Thrive.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2A4A), // Deep Navy
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 🛑 SOS Quick Calm Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StressPopScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF16E73), // Coral color for SOS alert
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF16E73).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'HIGH STRESS? Tap for Quick Calm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Quick Actions Grid
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D2A4A), // Deep Navy
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.spa_rounded,
                  label: 'Log Mood',
                  color: const Color(0xFF9163A6), // Purple from logo
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodLoggerScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit_note_rounded,
                  label: 'Journal',
                  color: const Color(0xFFF16E73), // Coral from logo
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JournalScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build quick action cards 
  Widget _buildActionCard({
    required IconData icon, 
    required String label, 
    required Color color,
    required VoidCallback onTap, 
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14), 
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 36, color: color),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,   
                    fontWeight: FontWeight.w600,
                    color: color, 
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}