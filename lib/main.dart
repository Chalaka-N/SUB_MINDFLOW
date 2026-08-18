import 'package:flutter/material.dart';

void main() {
  runApp(const MindFlowApp());
}

class MindFlowApp extends StatelessWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindFlow',
      debugShowCheckedModeBanner: false,
      // 🎨 The MindFlow Global Theme
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDFDFD), // Cloud White
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D1B3E),       // Flow Blue
          secondary: Color(0xFF14D3C9),     // Teal
          tertiary: Color(0xFFFF9F6A),      // Action Coral
          surface: Color(0xFFE0F7FA),       // Mind Lavender
          onSurface: Color(0xFF546E7A),     // Slate Gray
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B3E), // Flow Blue
          foregroundColor: Color(0xFFFDFDFD), // Cloud White
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MindFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Teal Accent Icon
            const Icon(
              Icons.all_inclusive_rounded, // Resembles your infinity logo
              size: 100,
              color: Color(0xFF14D3C9), // Teal
            ),
            const SizedBox(height: 24),
            // Primary Brand Text
            const Text(
              'MindFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D1B3E), // Flow Blue
              ),
            ),
            const SizedBox(height: 8),
            // Secondary Neutral Text
            const Text(
              'Navigate your mind.\nChart your flow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF546E7A), // Slate Gray
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            // Highlight Call-to-Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F6A), // Action Coral
                foregroundColor: const Color(0xFFFDFDFD), // Cloud White
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              onPressed: () {
                // TODO: Navigate to Login/Signup Screen
              },
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}