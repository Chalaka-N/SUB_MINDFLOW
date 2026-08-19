import 'package:flutter/material.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'Hello! I am your MindFlow AI companion. How are you feeling today? Feel free to share what is on your mind.'
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
    });

    // Simulate a thoughtful AI response based on keywords or general wellness support
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      
      String aiReply = "I hear you. Remember to take things one step at a time. Would you like to try a quick breathing exercise or write down your thoughts in the journal?";
      
      final lowerText = text.toLowerCase();
      if (lowerText.contains('stress') || lowerText.contains('anxious') || lowerText.contains('overwhelmed')) {
        aiReply = "It sounds like you're carrying a lot right now. Let's take a deep breath together. Inhale slowly... and exhale. You're doing the best you can.";
      } else if (lowerText.contains('happy') || lowerText.contains('good') || lowerText.contains('great')) {
        aiReply = "That's wonderful to hear! Cherish this positive energy and let's keep that momentum going through your day.";
      }

      setState(() {
        _messages.add({'sender': 'ai', 'text': aiReply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('MindFlow AI', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDFDFD),
        foregroundColor: const Color(0xFF0D2A4A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF2CB5C0) : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      border: isUser ? null : Border.all(color: Colors.grey.shade200, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        fontSize: 15,
                        color: isUser ? Colors.white : const Color(0xFF0D2A4A),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Input Field Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D2A4A).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI companion...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2CB5C0),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}