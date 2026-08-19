import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 Brings in local storage

class MoodLoggerScreen extends StatefulWidget {
  const MoodLoggerScreen({super.key});

  @override
  State<MoodLoggerScreen> createState() => _MoodLoggerScreenState();
}

class _MoodLoggerScreenState extends State<MoodLoggerScreen> {
  int? _selectedMoodIndex;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Energetic', 'icon': Icons.bolt_rounded, 'color': const Color(0xFFA5C953)}, 
    {'label': 'Calm', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF2CB5C0)}, 
    {'label': 'Stressed', 'icon': Icons.waves_rounded, 'color': const Color(0xFFF16E73)}, 
    {'label': 'Drained', 'icon': Icons.battery_0_bar_rounded, 'color': const Color(0xFF9163A6)}, 
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedMood(); // 👈 Loads the saved mood choice when opening the screen
  }

  // 📥 Function to load the saved mood index
  Future<void> _loadSavedMood() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMoodIndex = prefs.getInt('saved_mood_index');
    });
  }

  // 💾 Function to save the mood index
  Future<void> _saveMood() async {
    if (_selectedMoodIndex == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('saved_mood_index', _selectedMoodIndex!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged: ${_moods[_selectedMoodIndex!]['label']}!'),
          backgroundColor: _moods[_selectedMoodIndex!]['color'],
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), 
      appBar: AppBar(
        title: const Text('Log Your Mood', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDFDFD),
        foregroundColor: const Color(0xFF0D2A4A), 
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling right now?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2A4A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the emotion that best describes your current state of mind.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF546E7A), 
              ),
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedMoodIndex == index;
                  final mood = _moods[index];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMoodIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? mood['color'].withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? mood['color'] : Colors.grey.shade200,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: mood['color'].withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mood['icon'],
                            size: 48,
                            color: isSelected ? mood['color'] : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            mood['label'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? mood['color'] : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2A4A), 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _selectedMoodIndex != null ? 4 : 0,
                ),
                onPressed: _selectedMoodIndex != null ? _saveMood : null,
                child: const Text(
                  'Save Entry',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}