import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _keySOSCount = 'analytics_sos_count';
  static const String _keyJournalCount = 'analytics_journal_count';
  static const String _keyChatCount = 'analytics_chat_count';

  // Log whenever a client uses the SOS feature
  static Future<void> logSOSUsage() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keySOSCount) ?? 0;
    await prefs.setInt(_keySOSCount, current + 1);
  }

  // Log whenever a client submits a journal entry
  static Future<void> logJournalEntry() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyJournalCount) ?? 0;
    await prefs.setInt(_keyJournalCount, current + 1);
  }

  // Log whenever a client chats with the AI guide
  static Future<void> logChatInteraction() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyChatCount) ?? 0;
    await prefs.setInt(_keyChatCount, current + 1);
  }

  // Retrieve actual live metrics for the wellness report
  static Future<Map<String, int>> getMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'sosCount': prefs.getInt(_keySOSCount) ?? 0,
      'journalCount': prefs.getInt(_keyJournalCount) ?? 0,
      'chatCount': prefs.getInt(_keyChatCount) ?? 0,
    };
  }
}