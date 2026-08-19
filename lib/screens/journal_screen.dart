import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 Brings in the save feature!

class JournalScreen extends StatefulWidget {
  final bool hideBackButton; 
  
  const JournalScreen({super.key, this.hideBackButton = false});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // 📝 A controller to read and write the text in the box
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedJournal(); // 👈 Tells the app to load saved text right when it opens
  }

  // 📥 Function to load the saved text
  Future<void> _loadSavedJournal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textController.text = prefs.getString('saved_journal_entry') ?? ''; 
    });
  }

  // 💾 Function to save the text
  Future<void> _saveJournal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_journal_entry', _textController.text);
    
    // Hides the keyboard
    if (mounted) FocusScope.of(context).unfocus(); 
    
    // Shows the success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal Entry Saved!'),
          backgroundColor: Color(0xFFF16E73),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Journal', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDFDFD),
        foregroundColor: const Color(0xFF0D2A4A),
        elevation: 0,
        automaticallyImplyLeading: !widget.hideBackButton,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Thoughts",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2A4A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A safe space to clear your mind.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: Container(
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
                child: TextField(
                  controller: _textController, // 👈 Connects the box to our save logic
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Start writing here...',
                    hintStyle: TextStyle(color: Colors.black26),
                    border: InputBorder.none, 
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF16E73),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: _saveJournal, // 👈 Calls our new save function!
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