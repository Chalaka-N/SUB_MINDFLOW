import 'package:flutter/material.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling right now?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B3E), // Flow Blue
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap an icon to log your current mood.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF546E7A), // Slate Gray
            ),
          ),
          const SizedBox(height: 40),

          // Mood Selection Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodIcon(
                icon: Icons.sentiment_very_dissatisfied_rounded,
                label: 'Struggling',
                color: const Color(0xFF546E7A), // Slate Gray
              ),
              _buildMoodIcon(
                icon: Icons.sentiment_neutral_rounded,
                label: 'Okay',
                color: const Color(0xFFFF9F6A), // Action Coral
              ),
              _buildMoodIcon(
                icon: Icons.sentiment_very_satisfied_rounded,
                label: 'Great',
                color: const Color(0xFF14D3C9), // Teal
              ),
            ],
          ),
          const SizedBox(height: 50),

          // Recent Logs Placeholder
          const Text(
            'Recent Logs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B3E),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0F7FA), width: 2), // Mind Lavender
            ),
            child: const Row(
              children: [
                Icon(Icons.sentiment_very_satisfied_rounded, color: Color(0xFF14D3C9)),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feeling Great',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Today at 10:30 AM',
                      style: TextStyle(color: Color(0xFF546E7A), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for mood buttons
  Widget _buildMoodIcon({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 48, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1B3E),
          ),
        ),
      ],
    );
  }
}