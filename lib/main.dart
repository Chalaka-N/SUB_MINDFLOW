import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'screens/auth_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check
  //
  // Web uses reCAPTCHA v3 instead of the temporary debug provider.
  await FirebaseAppCheck.instance.activate(
    providerWeb: ReCaptchaV3Provider(
      '6LddBZAtAAAAALxXoWn3_s7q_aL8kzOliLAbDbDQ',
    ),
    //);
    //await FirebaseAppCheck.instance.activate(
    //providerWeb: ReCaptchaV3Provider(
    //'6LddBZAtAAAAALxXoWn3_s7q_aL8kzOliLAbDbDQ',
    //),
  );

  // Load saved theme
  final prefs = await SharedPreferences.getInstance();

  final isDark = prefs.getBool('isDarkMode') ?? false;

  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MindFlow',

          themeMode: themeMode,

          theme: ThemeData(brightness: Brightness.light, useMaterial3: true),

          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),

          home: const AuthScreen(isLogin: true),
        );
      },
    );
  }
}
