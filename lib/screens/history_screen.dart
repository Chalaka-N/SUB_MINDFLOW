import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _savedJournal = '';
  String _savedMood = 'None logged yet';
  Color _moodColor = Colors.grey;
  IconData _moodIcon = Icons.sentiment_neutral_rounded;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  // 📥 Load saved data from SharedPreferences
  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Journal
    final journalText = prefs.getString('saved_journal_entry') ?? '';

    // Load Mood
    final moodIndex = prefs.getInt('saved_mood_index');
    String moodLabel = 'None logged yet';
    Color moodColor = Colors.grey.shade400;
    IconData moodIcon = Icons.sentiment_neutral_rounded;

    if (moodIndex != null) {
      final moods = [
        {'label': 'Energetic', 'icon': Icons.bolt_rounded, 'color': const Color(0xFFA5C953)},
        {'label': 'Calm', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFF2CB5C0)},
        {'label': 'Stressed', 'icon': Icons.waves_rounded, 'color': const Color(0xFFF16E73)},
        {'label': 'Drained', 'icon': Icons.battery_0_bar_rounded, 'color': const Color(0xFF9163A6)},
      ];
      if (moodIndex >= 0 && moodIndex < moods.length) {
        moodLabel = moods[moodIndex]['label'] as String;
        moodColor = moods[moodIndex]['color'] as Color;
        moodIcon = moods[moodIndex]['icon'] as IconData;
      }
    }

    setState(() {
      _savedJournal = journalText;
      _savedMood = moodLabel;
      _moodColor = moodColor;
      _moodIcon = moodIcon;
    });
  }

  // 📝 NEW: Function to handle editing the journal entry
  Future<void> _showEditDialog() async {
    TextEditingController editController = TextEditingController(text: _savedJournal);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Journal Entry',
            style: TextStyle(
              color: Color(0xFF0D2A4A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: editController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Update your thoughts...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF2CB5C0).withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2CB5C0), width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF546E7A))),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save updated text to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('saved_journal_entry', editController.text);
                
                // Update the UI immediately
                setState(() {
                  _savedJournal = editController.text;
                });
                
                // Close the dialog box
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF16E73), // Coral
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Activity History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDFDFD),
        foregroundColor: const Color(0xFF0D2A4A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistoryData,
        color: const Color(0xFF2CB5C0),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Your Recent Reflections',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2A4A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pull down to refresh your latest entries.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 24),

            // 🌟 Latest Mood Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _moodColor.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _moodColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _moodColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_moodIcon, color: _moodColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest Logged State',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF546E7A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _savedMood,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _moodColor == Colors.grey ? const Color(0xFF0D2A4A) : _moodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📝 Latest Journal Entry Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF16E73).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF16E73).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF16E73).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: Color(0xFFF16E73),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Saved Journal Entry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2A4A),
                          ),
                        ),
                      ),
                      // 👇 NEW: Edit Button (Only shows if an entry exists)
                      if (_savedJournal.isNotEmpty)
                        IconButton(
                          onPressed: _showEditDialog,
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFFF16E73), // Coral color to match the theme
                            size: 22,
                          ),
                          tooltip: 'Edit Entry',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _savedJournal.isNotEmpty
                        ? _savedJournal
                        : 'No journal entries saved yet. Head over to the Journal tab to write your thoughts!',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: _savedJournal.isNotEmpty ? const Color(0xFF0D2A4A) : Colors.grey.shade400,
                      fontStyle: _savedJournal.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}