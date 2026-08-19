import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; 
import 'edit_profile_screen.dart'; 
import 'auth_screen.dart'; 
import 'wellness_report_screen.dart'; // 👈 Added import for the wellness report!

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Loading...';
  String _userRole = '';
  String _email = ''; 
  String _dob = '';   
  
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'No Name Set';
      _userRole = prefs.getString('user_occupation') ?? 'Add your occupation'; 
      _email = prefs.getString('user_email') ?? '';
      _dob = prefs.getString('user_dob') ?? '';
      
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = themeNotifier.value == ThemeMode.dark; 
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Reset App Data',
            style: TextStyle(color: Color(0xFFF16E73), fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will clear all saved journals, moods, and profile settings. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF16E73), 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => AuthScreen(isLogin: false)),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text('Reset All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthScreen(isLogin: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);
    final cardColor = isDark ? const Color(0xFF14244B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2CB5C0), width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: isDark ? const Color(0xFF0D2A4A) : const Color(0xFFF8F9FA),
                      child: Icon(Icons.person_rounded, size: 50, color: isDark ? Colors.white : const Color(0xFF0D2A4A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              _userName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _userRole,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF546E7A),
              ),
            ),
            
            if (_email.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "📧 $_email  |  🎂 $_dob",
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
              ),
            ],
            
            const SizedBox(height: 30),

            _buildSectionHeader('Preferences', isDark),
            _buildSwitchTile(
              icon: Icons.notifications_active_rounded,
              title: 'Daily Reminders',
              color: const Color(0xFFA5C953),
              value: _notificationsEnabled,
              cardColor: cardColor,
              textColor: textColor,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                _savePreference('notifications_enabled', val);
              },
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              color: const Color(0xFF9163A6),
              value: _darkModeEnabled,
              cardColor: cardColor,
              textColor: textColor,
              onChanged: (val) {
                setState(() => _darkModeEnabled = val);
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                _savePreference('dark_mode_enabled', val);
              },
            ),

            const SizedBox(height: 20),
            
            // 📊 BEHAVIORAL ANALYTICS SECTION
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
                  MaterialPageRoute(builder: (context) => const WellnessReportScreen()),
                );
              },
            ),

            const SizedBox(height: 20),
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
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
                if (result == true) {
                  _loadProfileData(); 
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
          ],
        ),
      ),
    );
  }

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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}