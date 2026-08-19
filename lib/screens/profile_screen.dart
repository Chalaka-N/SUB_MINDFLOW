import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'MindFlow User';
  String _userRole = 'Member';
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 📥 Load saved preferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Alex Morgan';
      _userRole = prefs.getString('user_role') ?? 'Daily Explorer';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      // 👇 We check the global notifier instead of just SharedPreferences to keep it in sync!
      _darkModeEnabled = themeNotifier.value == ThemeMode.dark; 
    });
  }

  // 💾 Save updated name/role
  Future<void> _saveProfileDetails(String name, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_role', role);
    setState(() {
      _userName = name;
      _userRole = role;
    });
  }

  // 💾 Save toggle switches
  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // ✏️ Edit Profile Dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final roleController = TextEditingController(text: _userRole);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Color(0xFF0D2A4A), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role / Occupation',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CB5C0), // Teal
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _saveProfileDetails(
                    nameController.text.trim(),
                    roleController.text.trim(),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🗑️ Reset Data Dialog
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
                backgroundColor: const Color(0xFFF16E73), // Coral
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await _loadProfileData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data reset successfully.'),
                      backgroundColor: Color(0xFFF16E73),
                      behavior: SnackBarBehavior.floating,
                    ),
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

  @override
  Widget build(BuildContext context) {
    // 👇 Checks if we are currently in Dark Mode to adjust text colors dynamically
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
            // 👤 Profile Avatar Section
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showEditProfileDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2CB5C0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Profile Name & Role Display
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
            const SizedBox(height: 30),

            // 🎛️ Settings Section
            _buildSectionHeader('Preferences', isDark),
            _buildSwitchTile(
              icon: Icons.notifications_active_rounded,
              title: 'Daily Reminders',
              color: const Color(0xFFA5C953), // Leaf Green
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
              color: const Color(0xFF9163A6), // Purple
              value: _darkModeEnabled,
              cardColor: cardColor,
              textColor: textColor,
              onChanged: (val) {
                // 👇 2. THIS IS THE MAGIC! It tells main.dart to flip the theme!
                setState(() => _darkModeEnabled = val);
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                _savePreference('dark_mode_enabled', val);
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
              onTap: _showEditProfileDialog,
            ),
            _buildActionTile(
              icon: Icons.delete_outline_rounded,
              title: 'Clear Stored App Data',
              color: const Color(0xFFF16E73), // Coral
              cardColor: cardColor,
              textColor: const Color(0xFFF16E73), // Always red for danger
              onTap: _showResetDialog,
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