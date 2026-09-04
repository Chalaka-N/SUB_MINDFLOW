import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/analytics_service.dart';
import '../services/behavior_analysis_service.dart';

// ============================================================
// MUSIC RECOMMENDATION
// ============================================================

class MusicRecommendation {
  final String song;
  final String artist;
  final String youtubeUrl;

  MusicRecommendation({
    required this.song,
    required this.artist,
    required this.youtubeUrl,
  });
}

// ============================================================
// CHAT MESSAGE
// ============================================================

class ChatMessage {
  final String text;
  final bool isUser;
  final MusicRecommendation? musicRecommendation;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.musicRecommendation,
  });
}

// ============================================================
// AI CHAT SCREEN
// ============================================================

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // CHAT
  // ============================================================

  final List<ChatMessage> _messages = [];

  late final GenerativeModel _model;
  late ChatSession _chatSession;

  late final GenerativeModel _musicModel;

  bool _isLoading = false;

  // ============================================================
  // BEHAVIOR ANALYSIS
  // ============================================================

  Map<String, dynamic>? _behaviorAnalysis;

  // ============================================================
  // MIND FLOW AI INSTRUCTIONS
  // ============================================================

  static const String _systemInstruction = '''
You are MindFlow Guide, the built-in AI wellness companion inside the MindFlow app.

Your personality:
- Warm
- Calm
- Friendly
- Empathetic
- Natural
- Respectful
- Non-judgmental
- Encouraging

Your main goal is to have a natural conversation with the user and help them
reflect, understand what they are experiencing, and find practical ways forward.

IMPORTANT CONVERSATION STYLE:

1. Talk like a supportive human companion, not a textbook or chatbot.

2. First understand what the user is saying.
If they share an emotion or difficult experience, acknowledge it naturally.

3. Do NOT give advice immediately after every message.
Sometimes the best response is simply to listen, acknowledge, and ask a natural
follow-up question.

4. Do NOT turn normal conversations into wellness lectures.

5. If the user is joking, chatting casually, asking a simple question, or talking
about something unrelated to wellbeing, respond naturally and casually.

6. Match the user's emotional tone.
If they are happy, you can be positive.
If they are sad, be gentle.
If they are frustrated, be understanding.
If they are casual, remain casual.

7. Keep responses concise and easy to read.
Usually use 2-5 short paragraphs or a few useful bullet points.

8. Do not repeat the user's entire message back to them.

9. Do not start every emotional response with phrases such as:
"I'm sorry you're going through this."
Use natural variation.

10. Ask ONE gentle follow-up question when it genuinely helps continue
the conversation. Do not ask unnecessary questions.

11. Give practical suggestions when appropriate, such as:
- taking a short break
- breathing exercises
- grounding
- walking
- journaling
- organizing tasks
- sleep routines
- talking to someone trusted

12. Do not overwhelm the user with many suggestions.

13. Never diagnose mental or physical illnesses.

14. Do not claim to be a doctor, psychologist, therapist, or emergency service.

15. If the user describes serious mental-health crisis, self-harm, suicide,
or immediate danger, respond with empathy and encourage them to seek immediate
support from a trusted person and appropriate professional or emergency services.

16. Never judge the user's feelings.

17. Remember relevant information from the CURRENT conversation.

18. Do not invent personal information about the user.

PERSONALIZED BEHAVIOR CONTEXT:

MindFlow may provide recent mood-analysis information about the user.

Use this information only when relevant to the current message.

Do NOT mention:
- internal analysis
- percentages
- counters
- UID values
- database information
- technical implementation details

unless the user specifically asks about their mood history or analysis.

Do NOT assume the behavior analysis explains why the user currently feels a
certain way.

Treat behavior analysis as supporting context, NOT a diagnosis.

If the behavior context indicates a recurring pattern such as stress or low
energy, you may gently acknowledge it when relevant.

If the current message is unrelated to wellbeing, do not force behavior
information into the response.

MindFlow should feel like a supportive companion that listens first, responds
naturally, and helps the user think clearly.

MindFlow is not a replacement for professional medical or mental-health care.
''';

  // ============================================================
  // MUSIC AI INSTRUCTIONS
  // ============================================================

  static const String _musicSystemInstruction = '''
You are the music recommendation assistant for MindFlow.

Recommend ONE real song only when music could genuinely help the user's
current emotional context.

Examples:

Stress:
calming, peaceful, relaxing, instrumental

Sad:
comforting, gentle, emotionally supportive

Happy:
upbeat, positive, energetic

Studying:
focus, instrumental, concentration

Motivation:
uplifting, energetic, motivational

IMPORTANT:

1. Recommend only ONE song.

2. Recommend a real song and real artist.

3. Never invent songs or artists.

4. Do not recommend music for serious crisis, self-harm, suicide,
or immediate danger.

5. If music is not appropriate, return exactly:

NONE

6. Return ONLY:

SONG: song name
ARTIST: artist name

Do not add explanations.
Do not add markdown.
Do not add a YouTube URL.
''';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      systemInstruction: Content.system(_systemInstruction),
    );

    _chatSession = _model.startChat();

    _musicModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      systemInstruction: Content.system(_musicSystemInstruction),
    );

    _messages.add(
      ChatMessage(
        text:
            "Hi there! 👋 I'm your MindFlow Guide.\n\n"
            "I'm here to listen and help you reflect on how you're feeling. "
            "What's on your mind today?",
        isUser: false,
      ),
    );

    _loadBehaviorAnalysis();
  }

  // ============================================================
  // LOAD BEHAVIOR ANALYSIS
  // ============================================================

  Future<void> _loadBehaviorAnalysis() async {
    try {
      debugPrint('🧠 Loading behavior context...');

      final result = await BehaviorAnalysisService.analyzeMoodBehavior();

      if (!mounted) return;

      _behaviorAnalysis = result;

      debugPrint('✅ AI Chat behavior context loaded');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Behavior analysis error: $e');
      debugPrint('$stackTrace');

      _behaviorAnalysis = null;
    }
  }

  // ============================================================
  // BUILD BEHAVIOR CONTEXT
  // ============================================================

  String _buildBehaviorContext() {
    final analysis = _behaviorAnalysis;

    if (analysis == null) {
      return '';
    }

    final int totalEntries = analysis['totalEntries'] as int? ?? 0;

    if (totalEntries == 0) {
      return '';
    }

    final String latestMood = analysis['latestMood']?.toString() ?? 'Unknown';

    final String mostFrequentMood =
        analysis['mostFrequentMood']?.toString() ?? 'Unknown';

    final String moodTrend = analysis['moodTrend']?.toString() ?? 'Unknown';

    final String behaviorStatus =
        analysis['behaviorStatus']?.toString() ?? 'Unknown';

    final bool repeatedStress = analysis['repeatedStress'] as bool? ?? false;

    final String insight = analysis['insight']?.toString() ?? '';

    return '''
PRIVATE BEHAVIOR CONTEXT:

Latest mood: $latestMood
Most frequent mood: $mostFrequentMood
Mood trend: $moodTrend
Behavior status: $behaviorStatus
Repeated stress: $repeatedStress
Insight: $insight

Use this only if it genuinely helps answer the current message.
Do not mention that you received this context.
Do not expose technical information.
Do not diagnose the user.
Do not assume this context explains the user's current feelings.
''';
  }

  // ============================================================
  // GET MUSIC RECOMMENDATION
  // ============================================================

  Future<MusicRecommendation?> _getMusicRecommendation({
    required String userMessage,
    required String aiResponse,
  }) async {
    try {
      debugPrint('🎵 Music AI analyzing conversation...');

      final musicPrompt =
          '''
User's current message:

$userMessage

MindFlow's response:

$aiResponse

Decide whether ONE music recommendation would genuinely
be helpful for this user at this moment.

If appropriate, recommend ONE real song.

Return ONLY:

SONG: song name
ARTIST: artist name

Otherwise return:

NONE
''';

      final musicSession = _musicModel.startChat();

      final response = await musicSession.sendMessage(
        Content.text(musicPrompt),
      );

      final result = response.text?.trim();

      debugPrint('🎵 Music AI response: $result');

      if (result == null || result.isEmpty || result.toUpperCase() == 'NONE') {
        return null;
      }

      final songMatch = RegExp(
        r'SONG:\s*(.+)',
        caseSensitive: false,
      ).firstMatch(result);

      final artistMatch = RegExp(
        r'ARTIST:\s*(.+)',
        caseSensitive: false,
      ).firstMatch(result);

      if (songMatch == null || artistMatch == null) {
        return null;
      }

      final String? song = songMatch.group(1)?.trim();
      final String? artist = artistMatch.group(1)?.trim();

      if (song == null || artist == null || song.isEmpty || artist.isEmpty) {
        return null;
      }

      final String searchQuery = Uri.encodeComponent('$song $artist');

      final String youtubeUrl =
          'https://www.youtube.com/results?search_query=$searchQuery';

      debugPrint('🎵 Music recommendation: $song - $artist');

      return MusicRecommendation(
        song: song,
        artist: artist,
        youtubeUrl: youtubeUrl,
      );
    } catch (e, stackTrace) {
      debugPrint('⚠️ Music recommendation error: $e');
      debugPrint('$stackTrace');

      return null;
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));

      _isLoading = true;
    });

    _controller.clear();

    _scrollToBottom();

    // ==========================================================
    // ANALYTICS
    // ==========================================================

    try {
      await AnalyticsService.logChatInteraction();
    } catch (e) {
      debugPrint('Analytics error: $e');
    }

    // ==========================================================
    // MAIN GEMINI RESPONSE
    // ==========================================================

    try {
      debugPrint('🚀 Sending message to Firebase AI Logic');

      final String behaviorContext = _buildBehaviorContext();

      final String prompt = behaviorContext.isNotEmpty
          ? '''
$behaviorContext

USER MESSAGE:
$text

Respond naturally as MindFlow Guide.
Listen first.
Keep the response concise.
Do not force wellness advice if it is not appropriate.
'''
          : text;

      final response = await _chatSession.sendMessage(Content.text(prompt));

      final responseText = response.text;

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      final String cleanResponse = responseText.trim();

      debugPrint('✅ Gemini response received');

      if (!mounted) return;

      // ========================================================
      // IMPORTANT:
      // SHOW AI RESPONSE IMMEDIATELY
      // ========================================================

      final int aiMessageIndex = _messages.length;

      setState(() {
        _messages.add(ChatMessage(text: cleanResponse, isUser: false));

        _isLoading = false;
      });

      _scrollToBottom();

      // ========================================================
      // MUSIC RUNS AFTER AI RESPONSE IS ALREADY VISIBLE
      // ========================================================

      _getMusicRecommendation(userMessage: text, aiResponse: cleanResponse)
          .then((musicRecommendation) {
            if (!mounted || musicRecommendation == null) {
              return;
            }

            // Make sure the expected AI message still exists.
            if (aiMessageIndex >= _messages.length) {
              return;
            }

            final currentMessage = _messages[aiMessageIndex];

            // Safety check: make sure it is still the AI message.
            if (currentMessage.isUser) {
              return;
            }

            setState(() {
              _messages[aiMessageIndex] = ChatMessage(
                text: currentMessage.text,
                isUser: false,
                musicRecommendation: musicRecommendation,
              );
            });

            _scrollToBottom();

            debugPrint('🎵 Music card added after AI response');
          })
          .catchError((error) {
            debugPrint('🎵 Background music error: $error');
          });
    } catch (e, stackTrace) {
      debugPrint('🔥 GEMINI/FIREBASE AI ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _messages.add(
          ChatMessage(
            text:
                "I'm sorry, I couldn't connect to MindFlow AI right now.\n\n"
                "Please try sending your message again.",
            isUser: false,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  // ============================================================
  // OPEN YOUTUBE
  // ============================================================

  Future<void> _openYouTube(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      final bool launched = await launchUrl(uri, webOnlyWindowName: '_blank');

      if (!launched) {
        debugPrint('⚠️ Could not open YouTube.');
      }
    } catch (e) {
      debugPrint('⚠️ YouTube opening error: $e');
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // NEW CONVERSATION
  // ============================================================

  void _startNewConversation() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _messages.clear();

      _messages.add(
        ChatMessage(
          text:
              "New conversation started. 🌿\n\n"
              "I'm here with you. What would you like to talk about?",
          isUser: false,
        ),
      );

      _chatSession = _model.startChat();
    });

    _scrollToBottom();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : const Color(0xFF0D1B3E);

    final Color backgroundColor = isDark
        ? const Color(0xFF0B1630)
        : const Color(0xFFFDFDFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'MindFlow Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'New conversation',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _startNewConversation,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];

                  return _buildMessageBubble(
                    message: message,
                    isDark: isDark,
                    textColor: textColor,
                  );
                },
              ),
            ),

            if (_isLoading) _buildTypingIndicator(isDark: isDark),

            _buildInputArea(isDark: isDark),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble({
    required ChatMessage message,
    required bool isDark,
    required Color textColor,
  }) {
    final bool isUser = message.isUser;

    final Color bubbleColor = isUser
        ? const Color(0xFF2CB5C0)
        : isDark
        ? const Color(0xFF14244B)
        : const Color(0xFFE0F7FA);

    final Color messageTextColor = isUser ? Colors.white : textColor;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: messageTextColor,
                ),
              ),
            ),

            if (!isUser && message.musicRecommendation != null)
              _buildMusicCard(
                music: message.musicRecommendation!,
                isDark: isDark,
                textColor: textColor,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MUSIC CARD
  // ============================================================

  Widget _buildMusicCard({
    required MusicRecommendation music,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2C52) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2CB5C0).withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF2CB5C0).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Color(0xFF2CB5C0),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Music for your moment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            music.song,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            music.artist,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _openYouTube(music.youtubeUrl);
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 21),
              label: const Text('Listen on YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CB5C0),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TYPING INDICATOR
  // ============================================================

  Widget _buildTypingIndicator({required bool isDark}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14244B) : const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2CB5C0),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'MindFlow is thinking...',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT AREA
  // ============================================================

  Widget _buildInputArea({required bool isDark}) {
    final Color inputColor = isDark ? const Color(0xFF14244B) : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1630) : const Color(0xFFFDFDFD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Share how you feel...',
                filled: true,
                fillColor: inputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF2CB5C0),
                    width: 1.2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) {
                if (!_isLoading) {
                  _sendMessage();
                }
              },
            ),
          ),

          const SizedBox(width: 8),

          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0D1B3E),
            ),
            child: IconButton(
              tooltip: 'Send',
              icon: Icon(
                _isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                color: Colors.white,
              ),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
