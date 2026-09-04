import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';
import '../services/location_service.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({super.key, required this.isLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  String _errorMessage = '';
  bool _isLoading = false;

  // Location consent
  bool _locationConsent = false;

  @override
  void initState() {
    super.initState();

    _isLogin = widget.isLogin;
  }

  // ============================================================
  // DATE OF BIRTH PICKER
  // ============================================================

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
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ============================================================
  // GET AND SAVE INITIAL LOCATION
  // ============================================================

  Future<void> _saveInitialLocation(String uid) async {
    try {
      debugPrint('');
      debugPrint('======================================');
      debugPrint('📍 INITIAL LOCATION SETUP');
      debugPrint('======================================');

      debugPrint('📍 Location consent: $_locationConsent');

      // ----------------------------------------------------------
      // USER DID NOT GIVE CONSENT
      // ----------------------------------------------------------

      if (!_locationConsent) {
        debugPrint('ℹ️ Location consent not given.');
        debugPrint('ℹ️ Skipping location request.');

        return;
      }

      // ----------------------------------------------------------
      // GET CURRENT LOCATION
      // ----------------------------------------------------------

      debugPrint('📍 Requesting current device location...');

      final Map<String, dynamic>? locationData =
          await LocationService.getLocationData();

      // ----------------------------------------------------------
      // LOCATION COULD NOT BE OBTAINED
      // ----------------------------------------------------------

      if (locationData == null) {
        debugPrint('⚠️ Location could not be obtained.');

        // We don't fail account creation because of location.
        //
        // The user can still use MindFlow and manually enable/update
        // their location later from the Profile screen.

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'locationAvailable': false,
        }, SetOptions(merge: true));

        debugPrint('ℹ️ Account creation will continue without location.');

        return;
      }

      // ----------------------------------------------------------
      // EXTRACT LOCATION
      // ----------------------------------------------------------

      final double latitude = (locationData['latitude'] as num).toDouble();

      final double longitude = (locationData['longitude'] as num).toDouble();

      final dynamic accuracy = locationData['accuracy'];

      debugPrint('📍 Latitude: $latitude');
      debugPrint('📍 Longitude: $longitude');
      debugPrint('📍 Accuracy: $accuracy');

      // ----------------------------------------------------------
      // SAVE LOCATION TO FIRESTORE
      // ----------------------------------------------------------

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'latitude': latitude,
        'longitude': longitude,
        'locationAccuracy': accuracy,
        'locationAvailable': true,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Initial location saved to Firestore');

      debugPrint('======================================');
      debugPrint('✅ INITIAL LOCATION COMPLETE');
      debugPrint('======================================');
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('🔥 INITIAL LOCATION ERROR');
      debugPrint('🔥 $e');
      debugPrint('======================================');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      // IMPORTANT:
      // Location failure should NOT prevent the user from
      // completing account creation.

      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'locationAvailable': false,
        }, SetOptions(merge: true));
      } catch (firestoreError) {
        debugPrint(
          '🔥 Could not save locationAvailable status: '
          '$firestoreError',
        );
      }
    }
  }

  // ============================================================
  // AUTHENTICATION + FIRESTORE
  // ============================================================

  Future<void> _authenticate() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _errorMessage = '';
    });

    // ==========================================================
    // BASIC VALIDATION
    // ==========================================================

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty';
      });
      return;
    }

    // ==========================================================
    // SIGNUP VALIDATION
    // ==========================================================

    if (!_isLogin) {
      final String name = _nameController.text.trim();
      final String dob = _dobController.text.trim();

      if (name.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your name';
        });
        return;
      }

      if (dob.isEmpty) {
        setState(() {
          _errorMessage = 'Please select your Date of Birth';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // LOGIN
      // ========================================================

      if (_isLogin) {
        debugPrint('======================================');
        debugPrint('🔐 Firebase Authentication: LOGIN');
        debugPrint('📧 Email: $email');

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        debugPrint('✅ Firebase login successful');

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
      // ========================================================
      // SIGN UP
      // ========================================================
      else {
        final String name = _nameController.text.trim();
        final String dob = _dobController.text.trim();

        debugPrint('======================================');
        debugPrint('📝 Firebase Authentication: SIGN UP');
        debugPrint('📧 Email: $email');
        debugPrint('📍 Location consent: $_locationConsent');
        debugPrint('======================================');

        // ------------------------------------------------------
        // STEP 1: CREATE FIREBASE AUTHENTICATION ACCOUNT
        // ------------------------------------------------------

        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final User? user = userCredential.user;

        if (user == null) {
          throw Exception('Firebase did not return a user.');
        }

        debugPrint('✅ Firebase account created');
        debugPrint('🆔 Firebase UID: ${user.uid}');

        // ------------------------------------------------------
        // STEP 2: SAVE DISPLAY NAME TO FIREBASE AUTH
        // ------------------------------------------------------

        await user.updateDisplayName(name);

        debugPrint('✅ Display name saved');

        // ------------------------------------------------------
        // STEP 3: SAVE PROFILE TO CLOUD FIRESTORE
        // ------------------------------------------------------

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'dateOfBirth': dob,

          // ====================================================
          // LOCATION CONSENT
          // ====================================================
          'locationConsent': _locationConsent,

          // Initially false.
          // It will be updated to true if GPS location is
          // successfully obtained.
          'locationAvailable': false,

          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ User profile saved to Firestore');
        debugPrint('📁 Collection: users');
        debugPrint('📄 Document: ${user.uid}');
        debugPrint('📍 Location consent saved: $_locationConsent');

        // ------------------------------------------------------
        // STEP 4: GET INITIAL LOCATION
        // ------------------------------------------------------

        if (_locationConsent) {
          debugPrint('');
          debugPrint('📍 User gave location consent.');
          debugPrint('📍 Starting initial location request...');

          await _saveInitialLocation(user.uid);
        } else {
          debugPrint('');
          debugPrint('ℹ️ User did not give location consent.');
          debugPrint('ℹ️ Location request skipped.');
        }

        // ------------------------------------------------------
        // STEP 5: CONTINUE TO ONBOARDING
        // ------------------------------------------------------

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
    // ==========================================================
    // FIREBASE AUTH ERROR
    // ==========================================================
    on FirebaseAuthException catch (e) {
      debugPrint('======================================');
      debugPrint('🔥 FIREBASE AUTH ERROR');
      debugPrint('🔥 Code: ${e.code}');
      debugPrint('🔥 Message: ${e.message}');
      debugPrint('======================================');

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email address.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'weak-password':
          message = 'Password is too weak. Please use a stronger password.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Authentication failed. Please try again.';
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
    // ==========================================================
    // OTHER ERROR
    // ==========================================================
    catch (e) {
      debugPrint('======================================');
      debugPrint('🔥 FIRESTORE / UNEXPECTED ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Account created, but we could not save your profile. '
            'Please try again.';
        _isLoading = false;
      });
    }

    // ==========================================================
    // STOP LOADING
    // ==========================================================

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ==================================================
                // HEADER ICON
                // ==================================================

                Icon(
                  _isLogin
                      ? Icons.lock_outline_rounded
                      : Icons.person_add_alt_1_rounded,
                  size: 80,
                  color: const Color(0xFF2CB5C0),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // WELCOME TITLE
                // ==================================================
                Text(
                  'Welcome to MindFlow',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? 'Enter your credentials to unlock your journal.'
                      : 'Enter your details to create a secure account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF546E7A),
                  ),
                ),

                const SizedBox(height: 40),

                // ==================================================
                // SIGN UP ONLY FIELDS
                // ==================================================
                if (!_isLogin) ...[
                  // ------------------------------------------------
                  // FULL NAME
                  // ------------------------------------------------

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // DATE OF BIRTH
                  // ------------------------------------------------
                  TextField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // LOCATION CONSENT
                  // ==================================================
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF14244B)
                          : const Color(0xFFF7FBFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: CheckboxListTile(
                      value: _locationConsent,

                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _locationConsent = value ?? false;
                              });
                            },

                      activeColor: const Color(0xFF2CB5C0),

                      controlAffinity: ListTileControlAffinity.leading,

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      title: Text(
                        'Allow location-based recommendations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),

                      subtitle: const Text(
                        'MindFlow may use your location to provide '
                        'personalized suggestions based on nearby places.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Color(0xFF546E7A),
                        ),
                      ),
                    ),
                  ),
                ],

                // ==================================================
                // EMAIL
                // ==================================================
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PASSWORD
                // ==================================================
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.password_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // ==================================================
                // ERROR MESSAGE
                // ==================================================
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFF16E73),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // ==================================================
                // ACTION BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B3E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // SWITCH LOGIN / SIGN UP
                // ==================================================
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = '';

                            // Reset consent when switching modes.
                            if (_isLogin) {
                              _locationConsent = false;
                            }
                          });
                        },

                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign Up"
                        : 'Already have an account? Login',
                    style: const TextStyle(
                      color: Color(0xFF2CB5C0),
                      fontWeight: FontWeight.bold,
                    ),
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
