import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/analytics_service.dart';

class WellnessReportScreen extends StatefulWidget {
  const WellnessReportScreen({super.key});

  @override
  State<WellnessReportScreen> createState() => _WellnessReportScreenState();
}

class _WellnessReportScreenState extends State<WellnessReportScreen> {
  Map<String, int> _metrics = {'sosCount': 0, 'journalCount': 0, 'chatCount': 0};
  bool _isLoading = true;
  String _aiEvaluation = 'Analyzing client behavioral telemetry online...';
  String _aiSolutions = 'Generating personalized dynamic solutions...';

  // 🔑 Your live online API key
  final String apiKey = 'AIzaSyDXgY_nJvFsIv4V_u1JGyIII5pHYSnIP6Y';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataAndGenerateLiveReport();
  }

  Future<void> _loadDataAndGenerateLiveReport() async {
    final data = await AnalyticsService.getMetrics();
    setState(() {
      _metrics = data;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // 🧠 Dynamic prompt forcing Gemini to build custom, situational solutions online
      final prompt = '''
      You are an expert clinical psychologist AI analyzing a wellness app user's live telemetry data online.
      Here are their exact live metrics:
      - SOS Stress Resets (Panic/Anger spikes handled): ${_metrics['sosCount']}
      - Journal entries logged (Reflective processing): ${_metrics['journalCount']}
      - AI Chat check-ins (Conversational venting/guidance): ${_metrics['chatCount']}

      CRITICAL INSTRUCTION: Do not give generic or fixed advice. Look at these specific usage numbers and deduce their current emotional state (e.g., if chats/SOS are high, they are undergoing acute stress; if journals are high, they are reflective). 
      
      Provide two distinct sections separated strictly by the text "|||":
      1. An "Engagement Pattern" evaluation analyzing their psychological state based on these metrics.
      2. A strictly personalized, numbered set of actionable solutions (e.g., 01. ..., 02. ...) tailored entirely to what this specific client's data reveals they need right now.

      Keep the tone professional, highly customized, and empathetic.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text != null && text.contains('|||')) {
        final parts = text.split('|||');
        setState(() {
          _aiEvaluation = parts[0].trim();
          _aiSolutions = parts[1].trim();
          _isLoading = false;
        });
      } else {
        setState(() {
          _aiEvaluation = text ?? 'Online analysis complete.';
          _aiSolutions = '01. Adjust baseline habits according to current session frequency.\n02. Engage in targeted deep-breathing.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback if offline
      setState(() {
        _aiEvaluation = 'Offline mode: Tracking ${_metrics['chatCount']} chats, ${_metrics['journalCount']} journals, and ${_metrics['sosCount']} SOS resets.';
        _aiSolutions = '01. Reconnect to the internet to allow Gemini to analyze your live psychological state.\n02. Continue utilizing your tracking tools.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final totalActivity = (_metrics['sosCount'] ?? 0) + (_metrics['journalCount'] ?? 0) + (_metrics['chatCount'] ?? 0);
    final String wellnessStatus = totalActivity > 5 ? 'Highly Active & Engaged' : totalActivity > 2 ? 'Building Steady Habits' : 'Initial Exploration Phase';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavioral Wellness Report', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2CB5C0)))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D1B3E), Color(0xFF2CB5C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client Activity & Stress Analysis',
                        style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wellnessStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricBadge('SOS Resets', '${_metrics['sosCount']}'),
                          _buildMetricBadge('Journals', '${_metrics['journalCount']}'),
                          _buildMetricBadge('AI Chats', '${_metrics['chatCount']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Gemini Online Clinical Evaluation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInsightCard('Engagement Pattern', _aiEvaluation, Icons.insights_rounded, isDark),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Dynamic Personalized Action Plan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInsightCard('Custom Solutions', _aiSolutions, Icons.lightbulb_rounded, isDark),
              ],
            ),
    );
  }

Widget _buildMetricBadge(String label, String value) {
  return Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );
}

Widget _buildInsightCard(String title, String description, IconData icon, bool isDark) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF14244B) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2CB5C0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2CB5C0)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );
}
}