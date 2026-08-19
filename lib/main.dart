import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart'; 

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  // 1. Check if dark mode is enabled
  final isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
  if (isDarkMode) themeNotifier.value = ThemeMode.dark;

  // 👇 Removed the hasAccount check entirely. Just run the app!
  runApp(const MindFlowApp());
}

class MindFlowApp extends StatelessWidget {
  // 👈 Removed the hasAccount variable here too
  const MindFlowApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'MindFlow',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, 
          
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFFDFDFD),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B3E),
              secondary: Color(0xFF14D3C9),
              tertiary: Color(0xFFFF9F6A),
              surface: Color(0xFFE0F7FA),
              onSurface: Color(0xFF546E7A),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D1B3E),
              foregroundColor: Color(0xFFFDFDFD),
              elevation: 0,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF091022),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2CB5C0), 
              secondary: Color(0xFFA5C953),
              tertiary: Color(0xFFF16E73), 
              surface: Color(0xFF14244B), 
              onSurface: Color(0xFFE0E0E0), 
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF091022),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            useMaterial3: true,
          ),
          
          //  ALWAYS open strictly to the Login Screen!
          home: const AuthScreen(isLogin: true),
        );
      },
    );
  }
}