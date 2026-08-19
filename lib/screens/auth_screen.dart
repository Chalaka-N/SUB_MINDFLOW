import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart'; 
import 'onboarding_screen.dart'; // 👈 1. Added the import for the Demo screen!

class AuthScreen extends StatefulWidget {
  final bool isLogin; 
  
  const AuthScreen({super.key, required this.isLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  
  // Controllers for the 4 required fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  // 📅 Opens a professional Calendar Picker for Date of Birth
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D1B3E), 
              onPrimary: Colors.white, 
              onSurface: Color(0xFF0D1B3E), 
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats the date as YYYY-MM-DD
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password cannot be empty');
      return;
    }

    if (_isLogin) {
      // 🔐 STRICT LOGIN LOGIC
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');
      final hasAccount = prefs.getBool('has_account') ?? false;

      if (!hasAccount) {
        setState(() => _errorMessage = 'No account found. Please Sign Up first.');
        return;
      }

      if (email == savedEmail && password == savedPassword) {
        // 👇 2. IF LOGGING IN -> Skip Demo, go straight to Main App!
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        }
      } else {
        setState(() => _errorMessage = 'Incorrect email or password.');
      }
    } else {
      // 📝 SIGN UP LOGIC (Validates all 4 fields)
      final name = _nameController.text.trim();
      final dob = _dobController.text.trim();

      if (name.isEmpty) {
        setState(() => _errorMessage = 'Please enter your name');
        return;
      }
      if (dob.isEmpty) {
        setState(() => _errorMessage = 'Please select your Date of Birth');
        return;
      }

      // Save all 4 pieces of data securely to local storage
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_dob', dob);
      await prefs.setString('user_password', password);
      await prefs.setBool('has_account', true); 
      
      // 👇 3. IF SIGNING UP -> Show them the Demo Page!
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  _isLogin ? 'Welcome Back' : 'Welcome',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                ),
                
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Enter your credentials to unlock your journal.' : 'Enter your details to create a secure account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF546E7A)),
                ),
                const SizedBox(height: 40),

                // 📝 1 & 2: SIGN UP ONLY FIELDS (Name & DOB)
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _dobController,
                    readOnly: true, // Prevents manual typing, forces the calendar picker
                    onTap: _selectDate, 
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 📧 3: EMAIL FIELD (Visible for both Login and Sign Up)
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔑 4: PASSWORD FIELD (Visible for both Login and Sign Up)
                TextField(
                  controller: _passwordController,
                  obscureText: true, 
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.password_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                
                // ⚠️ ERROR MESSAGE DISPLAY
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Color(0xFFF16E73), fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 32),

                // 👉 ACTION BUTTON
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

                // 🔄 TOGGLE VIEW BUTTON
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = ''; 
                      _nameController.clear();
                      _emailController.clear();
                      _dobController.clear();
                      _passwordController.clear();
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