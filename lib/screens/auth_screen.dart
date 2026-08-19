import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin; // Tells the screen whether to show Login or Sign Up
  
  const AuthScreen({super.key, required this.isLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  Future<void> _authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    final password = _passwordController.text.trim();
    
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password cannot be empty');
      return;
    }

    if (_isLogin) {
      // 🔐 LOGIN LOGIC
      final savedPassword = prefs.getString('user_password');
      if (password == savedPassword) {
        _goToHome();
      } else {
        setState(() => _errorMessage = 'Incorrect password. Try again.');
      }
    } else {
      // 📝 SIGN UP LOGIC
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _errorMessage = 'Please enter your name');
        return;
      }
      await prefs.setString('user_name', name);
      await prefs.setString('user_password', password);
      await prefs.setBool('has_account', true); // Mark that they have an account
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isLogin ? Icons.lock_outline_rounded : Icons.person_add_alt_1_rounded,
                  size: 80,
                  color: const Color(0xFF2CB5C0),
                ),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Enter your password to unlock your journal.' : 'Secure your personal data with a password.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF546E7A)),
                ),
                const SizedBox(height: 40),

                // Only show Name field if Signing Up
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Hides the text for security
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.password_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                
                // Error Message Display
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Color(0xFFF16E73), fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 32),

                // Main Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B3E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle between Login and Sign Up
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = ''; // Clear errors on switch
                    });
                  },
                  child: Text(
                    _isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Login',
                    style: const TextStyle(color: Color(0xFF2CB5C0), fontWeight: FontWeight.bold),
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