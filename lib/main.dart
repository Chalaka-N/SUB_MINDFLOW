import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 1. Firebase Import
import 'firebase_options.dart'; // 🔥 2. Auto-generated Firebase file
import 'screens/auth_screen.dart'; // 🔐 3. The new Auth Screen

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Ensure Flutter is initialized before using SharedPreferences and Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 Boot up Firebase!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final prefs = await SharedPreferences.getInstance();
  
  // 👇 Check if they have created an account (set in AuthScreen)
  final hasAccount = prefs.getBool('has_account') ?? false;
  
  // Load the saved dark mode preference
  final isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
  if (isDarkMode) themeNotifier.value = ThemeMode.dark;

  // Pass the hasAccount flag into the app
  runApp(MindFlowApp(hasAccount: hasAccount));
}

class MindFlowApp extends StatelessWidget {
  final bool hasAccount; // 👈 Accept the flag here

  const MindFlowApp({super.key, required this.hasAccount});

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
          
          // 👇 Decide where to send the user based on their account status
          home: AuthScreen(isLogin: hasAccount),
        );
      },
    );
  }
}