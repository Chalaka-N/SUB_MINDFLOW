import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../services/location_service.dart';
import 'edit_profile_screen.dart';
import 'auth_screen.dart';
import 'wellness_report_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ============================================================
  // PROFILE DATA
  // ============================================================

  String _userName = 'Loading...';
  String _userRole = '';
  String _email = '';
  String _dob = '';

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  bool _isLoadingProfile = true;

  // ============================================================
  // LOCATION DATA
  // ============================================================

  double? _latitude;
  double? _longitude;

  bool _isGettingLocation = false;
  bool _locationSaved = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfileData() async {
    debugPrint('');
    debugPrint('==============================================');
    debugPrint('👤 PROFILE LOAD STARTED');
    debugPrint('==============================================');

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      // ----------------------------------------------------------
      // CHECK FIREBASE AUTH
      // ----------------------------------------------------------

      if (user == null) {
        debugPrint('❌ No Firebase user is currently signed in');

        if (!mounted) return;

        setState(() {
          _userName = 'No User';
          _userRole = 'Not signed in';
          _email = '';
          _dob = '';
          _isLoadingProfile = false;
        });

        return;
      }

      debugPrint('🆔 UID: ${user.uid}');
      debugPrint('📧 AUTH EMAIL: ${user.email}');
      debugPrint('👤 AUTH DISPLAY NAME: ${user.displayName}');

      // ----------------------------------------------------------
      // GET FIRESTORE DOCUMENT
      // ----------------------------------------------------------

      final DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid);

      debugPrint('📂 Firestore path: users/${user.uid}');

      final DocumentSnapshot<Map<String, dynamic>> document = await userRef
          .get();

      // ----------------------------------------------------------
      // DOCUMENT EXISTS
      // ----------------------------------------------------------

      if (document.exists) {
        debugPrint('✅ FIRESTORE DOCUMENT EXISTS');

        final Map<String, dynamic>? data = document.data();

        debugPrint('📦 FIRESTORE DATA: $data');

        if (data != null) {
          debugPrint('----------------------------------------------');
          debugPrint('Firestore name: ${data['name']}');
          debugPrint('Firestore email: ${data['email']}');
          debugPrint('Firestore DOB: ${data['dateOfBirth']}');
          debugPrint('Firestore occupation: ${data['occupation']}');
          debugPrint('Firestore latitude: ${data['latitude']}');
          debugPrint('Firestore longitude: ${data['longitude']}');
          debugPrint('----------------------------------------------');
        }

        // --------------------------------------------------------
        // GET VALUES SAFELY
        // --------------------------------------------------------

        String firestoreName = '';

        if (data != null && data['name'] != null) {
          firestoreName = data['name'].toString().trim();
        }

        String firestoreEmail = '';

        if (data != null && data['email'] != null) {
          firestoreEmail = data['email'].toString().trim();
        }

        String firestoreDob = '';

        if (data != null && data['dateOfBirth'] != null) {
          firestoreDob = data['dateOfBirth'].toString().trim();
        }

        String firestoreOccupation = '';

        if (data != null && data['occupation'] != null) {
          firestoreOccupation = data['occupation'].toString().trim();
        }

        // --------------------------------------------------------
        // LOAD SAVED LOCATION
        // --------------------------------------------------------

        double? savedLatitude;
        double? savedLongitude;

        if (data != null && data['latitude'] != null) {
          savedLatitude = (data['latitude'] as num).toDouble();
        }

        if (data != null && data['longitude'] != null) {
          savedLongitude = (data['longitude'] as num).toDouble();
        }

        // --------------------------------------------------------
        // FALLBACKS
        // --------------------------------------------------------

        final String finalName = firestoreName.isNotEmpty
            ? firestoreName
            : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : 'No Name Set');

        final String finalEmail = firestoreEmail.isNotEmpty
            ? firestoreEmail
            : (user.email ?? '');

        final String finalDob = firestoreDob;

        final String finalOccupation = firestoreOccupation.isNotEmpty
            ? firestoreOccupation
            : 'Add your occupation';

        debugPrint('==============================================');
        debugPrint('✅ FINAL PROFILE VALUES');
        debugPrint('👤 NAME: $finalName');
        debugPrint('📧 EMAIL: $finalEmail');
        debugPrint('🎂 DOB: $finalDob');
        debugPrint('💼 OCCUPATION: $finalOccupation');
        debugPrint('📍 LATITUDE: $savedLatitude');
        debugPrint('📍 LONGITUDE: $savedLongitude');
        debugPrint('==============================================');

        // --------------------------------------------------------
        // UPDATE UI
        // --------------------------------------------------------

        if (!mounted) return;

        setState(() {
          _userName = finalName;
          _email = finalEmail;
          _dob = finalDob;
          _userRole = finalOccupation;

          _latitude = savedLatitude;
          _longitude = savedLongitude;

          _locationSaved = savedLatitude != null && savedLongitude != null;

          _isLoadingProfile = false;
        });
      } else {
        // --------------------------------------------------------
        // DOCUMENT DOES NOT EXIST
        // --------------------------------------------------------

        debugPrint('⚠️ FIRESTORE DOCUMENT DOES NOT EXIST');

        final String fallbackName = user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'No Name Set';

        final String fallbackEmail = user.email ?? '';

        if (!mounted) return;

        setState(() {
          _userName = fallbackName;
          _email = fallbackEmail;
          _dob = '';
          _userRole = 'Add your occupation';
          _isLoadingProfile = false;
        });
      }

      // ----------------------------------------------------------
      // LOCAL SETTINGS
      // ----------------------------------------------------------

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

        _darkModeEnabled = themeNotifier.value == ThemeMode.dark;
      });

      debugPrint('✅ PROFILE LOAD COMPLETED');
      debugPrint('==============================================');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==============================================');
      debugPrint('🔥 PROFILE LOAD ERROR');
      debugPrint('🔥 $e');
      debugPrint('==============================================');
      debugPrint('$stackTrace');
      debugPrint('==============================================');

      if (!mounted) return;

      setState(() {
        _userName = 'Unable to load profile';
        _userRole = 'Please try again';
        _email = '';
        _dob = '';
        _isLoadingProfile = false;
      });
    }
  }

  // ============================================================
  // GET AND SAVE CURRENT LOCATION
  // ============================================================

  Future<void> _getAndSaveLocation() async {
    if (_isGettingLocation) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      debugPrint('');
      debugPrint('==============================================');
      debugPrint('📍 LOCATION REQUEST STARTED');
      debugPrint('==============================================');

      final locationData = await LocationService.getLocationData();

      if (locationData == null) {
        if (!mounted) return;

        setState(() {
          _isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get your location. Please allow location access and try again.',
            ),
          ),
        );

        return;
      }

      final double latitude = (locationData['latitude'] as num).toDouble();

      final double longitude = (locationData['longitude'] as num).toDouble();

      debugPrint('📍 Latitude: $latitude');
      debugPrint('📍 Longitude: $longitude');

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No signed-in user found.');
      }

      // ----------------------------------------------------------
      // SAVE LOCATION TO FIRESTORE
      // ----------------------------------------------------------

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'latitude': latitude,
        'longitude': longitude,
        'locationAccuracy': locationData['accuracy'],
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ LOCATION SAVED TO FIRESTORE');

      if (!mounted) return;

      setState(() {
        _latitude = latitude;
        _longitude = longitude;
        _locationSaved = true;
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your current location has been saved securely.'),
        ),
      );

      debugPrint('==============================================');
      debugPrint('✅ LOCATION PROCESS COMPLETED');
      debugPrint('==============================================');
    } catch (e) {
      debugPrint('==============================================');
      debugPrint('🔥 LOCATION ERROR');
      debugPrint('🔥 $e');
      debugPrint('==============================================');

      if (!mounted) return;

      setState(() {
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while getting your location.'),
        ),
      );
    }
  }

  // ============================================================
  // SAVE LOCAL PREFERENCE
  // ============================================================

  Future<void> _savePreference(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  // ============================================================
  // RESET APP DATA
  // ============================================================

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Reset App Data',
            style: TextStyle(
              color: Color(0xFFF16E73),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This will clear all saved journals, moods, and profile settings. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF16E73),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();

                await prefs.clear();

                if (!mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(isLogin: false),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      debugPrint('🚪 Logging out...');

      await FirebaseAuth.instance.signOut();

      debugPrint('✅ Firebase logout successful');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(isLogin: true),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('🔥 Logout error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out. Please try again.')),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);

    final Color cardColor = isDark ? const Color(0xFF14244B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: RefreshIndicator(
        onRefresh: _loadProfileData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              // ==================================================
              // AVATAR
              // ==================================================

              Container(
                padding: const EdgeInsets.all(4),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2CB5C0),
                    width: 2.5,
                  ),
                ),

                child: CircleAvatar(
                  radius: 46,

                  backgroundColor: isDark
                      ? const Color(0xFF0D2A4A)
                      : const Color(0xFFF8F9FA),

                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: isDark ? Colors.white : const Color(0xFF0D2A4A),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // NAME
              // ==================================================
              if (_isLoadingProfile)
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2CB5C0),
                )
              else
                Text(
                  _userName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

              const SizedBox(height: 5),

              // ==================================================
              // OCCUPATION
              // ==================================================
              Text(
                _userRole,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? Colors.grey.shade400
                      : const Color(0xFF546E7A),
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // EMAIL
              // ==================================================
              if (_email.isNotEmpty)
                Text(
                  '📧 $_email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),

              // ==================================================
              // DOB
              // ==================================================
              if (_dob.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '🎂 $_dob',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // ==================================================
              // PREFERENCES
              // ==================================================
              _buildSectionHeader('Preferences', isDark),

              _buildSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: 'Daily Reminders',
                color: const Color(0xFFA5C953),
                value: _notificationsEnabled,
                cardColor: cardColor,
                textColor: textColor,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });

                  _savePreference('notifications_enabled', value);
                },
              ),

              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                color: const Color(0xFF9163A6),
                value: _darkModeEnabled,
                cardColor: cardColor,
                textColor: textColor,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });

                  themeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;

                  _savePreference('dark_mode_enabled', value);
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // LOCATION & CONTEXT
              // ==================================================
              _buildSectionHeader('Location & Context', isDark),

              _buildLocationTile(
                cardColor: cardColor,
                textColor: textColor,
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // WELLNESS
              // ==================================================
              _buildSectionHeader('Wellness Analytics', isDark),

              _buildActionTile(
                icon: Icons.analytics_rounded,
                title: 'Behavioral Wellness Report',
                color: const Color(0xFF2CB5C0),
                cardColor: cardColor,
                textColor: textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WellnessReportScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // ACCOUNT MANAGEMENT
              // ==================================================
              _buildSectionHeader('Account Management', isDark),

              _buildActionTile(
                icon: Icons.edit_note_rounded,
                title: 'Edit Profile Information',
                color: const Color(0xFF2CB5C0),
                cardColor: cardColor,
                textColor: textColor,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );

                  if (result == true) {
                    await _loadProfileData();
                  }
                },
              ),

              _buildActionTile(
                icon: Icons.delete_outline_rounded,
                title: 'Clear Stored App Data',
                color: const Color(0xFFF16E73),
                cardColor: cardColor,
                textColor: const Color(0xFFF16E73),
                onTap: _showResetDialog,
              ),

              const SizedBox(height: 12),

              _buildActionTile(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                color: Colors.grey,
                cardColor: cardColor,
                textColor: Colors.grey,
                onTap: _logout,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION TILE
  // ============================================================

  Widget _buildLocationTile({
    required Color cardColor,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),

                decoration: BoxDecoration(
                  color: const Color(0xFF2CB5C0).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF2CB5C0),
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _locationSaved
                          ? 'Location available for contextual features'
                          : 'Allow location access to enable context awareness',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : const Color(0xFF546E7A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_locationSaved && _latitude != null && _longitude != null) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: const Color(0xFF2CB5C0).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: Color(0xFF2CB5C0),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Latitude: ${_latitude!.toStringAsFixed(5)}\n'
                      'Longitude: ${_longitude!.toStringAsFixed(5)}',
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),

                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFFA5C953),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,

            child: ElevatedButton.icon(
              onPressed: _isGettingLocation ? null : _getAndSaveLocation,

              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.location_searching_rounded),

              label: Text(
                _isGettingLocation
                    ? 'Getting Location...'
                    : _locationSaved
                    ? 'Update My Location'
                    : 'Use My Current Location',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B3E),
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your location is only requested when you choose to use this feature.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),

        child: Text(
          title,

          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF546E7A),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required Color color,
    required bool value,
    required Color cardColor,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),

      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),

          child: Icon(icon, color: color, size: 22),
        ),

        title: Text(
          title,

          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),

        trailing: Switch.adaptive(
          value: value,
          activeColor: color,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),

      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),

          child: Icon(icon, color: color, size: 22),
        ),

        title: Text(
          title,

          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),

        onTap: onTap,
      ),
    );
  }
}
