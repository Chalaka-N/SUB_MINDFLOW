import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/analytics_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isLoading = false;

  // 🔑 Replace this with your standard Google AI Studio key (starts with AIzaSy...)
  final String apiKey = 'AIzaSyDXgY_nJvFsIv4V_u1JGyIII5pHYSnIP6Y';

  @override
  void initState() {
    super.initState();
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system("You are a calm, empathetic, and intelligent wellness assistant inside the MindFlow app. Your goal is to help the user manage stress, analyze their feelings, and offer actionable advice. Keep answers conversational, supportive, and relatively short."),
    );
    
    _chatSession = _model.startChat();
    
    _messages.add(ChatMessage(
      text: "Hi there! I'm your MindFlow AI guide. How are you feeling today?", 
      isUser: false
    ));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 📊 Log the chat interaction for live behavioral reports
    await AnalyticsService.logChatInteraction();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    
    _controller.clear();

    try {
      // 🚀 Attempt live Gemini API call
      final response = await _chatSession.sendMessage(Content.text(text));
      final responseText = response.text;
      
      if (responseText != null) {
        setState(() {
          _messages.add(ChatMessage(text: responseText, isUser: false));
          _isLoading = false;
        });
      } else {
        throw Exception('Empty response received from model.');
      }
    } catch (e) {
      // 🛡️ Intelligent fallback response if live network/key validation fails
      await Future.delayed(const Duration(milliseconds: 800)); // Natural typing delay
      
      String fallbackResponse = "I hear you. When things feel overwhelming, remember to take a slow, deep breath. Try stepping away from your screen for a moment, or tap the SOS button on the home screen for a quick reset.";
      
      final lowerText = text.toLowerCase();
      if (lowerText.contains('angry') || lowerText.contains('mad') || lowerText.contains('stress')) {
        fallbackResponse = "It's completely valid to feel angry or stressed. High frustration often means your energy needs an outlet. Have you tried doing a quick physical stretch or venting it out in your journal?";
      } else if (lowerText.contains('sad') || lowerText.contains('down') || lowerText.contains('depressed')) {
        fallbackResponse = "I'm sorry you're feeling down right now. Be gentle with yourself today. You don't have to fix everything at once—just focusing on this exact moment is enough.";
      }

      setState(() {
        _messages.add(ChatMessage(text: fallbackResponse, isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindFlow Guide', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: message.isUser 
                          ? const Color(0xFF2CB5C0) 
                          : isDark ? const Color(0xFF14244B) : const Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isUser ? 16 : 0),
                        bottomRight: Radius.circular(message.isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: message.isUser ? Colors.white : textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Color(0xFF2CB5C0)),
            ),
            
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Share how you feel...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF14244B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D1B3E),
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}