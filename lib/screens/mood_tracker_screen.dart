import 'package:flutter/material.dart';

import '../services/mood_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<Map<String, dynamic>> _moodHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  // ============================================================
  // LOAD MOOD HISTORY
  // ============================================================

  Future<void> _loadMoodHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('======================================');
      debugPrint('📊 LOADING MOOD HISTORY');

      final moods = await MoodService.getMoodHistory();

      debugPrint('📊 Mood entries found: ${moods.length}');

      for (final mood in moods) {
        debugPrint('😊 Mood: ${mood['mood']}');
        debugPrint('🆔 ID: ${mood['id']}');
        debugPrint('⏰ Timestamp: ${mood['timestamp']}');
        debugPrint('--------------------------------------');
      }

      debugPrint('✅ MOOD HISTORY LOADED');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _moodHistory = moods;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('🔥 MOOD HISTORY ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack trace: $stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // MOOD COLOR
  // ============================================================

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'energetic':
        return const Color(0xFFA5C953);

      case 'calm':
        return const Color(0xFF2CB5C0);

      case 'stressed':
        return const Color(0xFFF16E73);

      case 'drained':
        return const Color(0xFF9163A6);

      default:
        return const Color(0xFF546E7A);
    }
  }

  // ============================================================
  // MOOD ICON
  // ============================================================

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'energetic':
        return Icons.bolt_rounded;

      case 'calm':
        return Icons.water_drop_rounded;

      case 'stressed':
        return Icons.waves_rounded;

      case 'drained':
        return Icons.battery_0_bar_rounded;

      default:
        return Icons.mood_rounded;
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDateTime(dynamic timestamp) {
    try {
      DateTime? dateTime;

      if (timestamp == null) {
        return 'Time unavailable';
      }

      // Firestore Timestamp has a toDate() method.
      if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        try {
          dateTime = timestamp.toDate() as DateTime;
        } catch (_) {
          dateTime = null;
        }
      }

      if (dateTime == null) {
        return 'Time unavailable';
      }

      final hour = dateTime.hour == 0
          ? 12
          : dateTime.hour > 12
          ? dateTime.hour - 12
          : dateTime.hour;

      final minute = dateTime.minute.toString().padLeft(2, '0');

      final period = dateTime.hour >= 12 ? 'PM' : 'AM';

      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} • '
          '$hour:$minute $period';
    } catch (_) {
      return 'Time unavailable';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0B1733)
        : const Color(0xFFFDFDFD);

    final textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);

    final secondaryTextColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF546E7A);

    final cardColor = isDark ? const Color(0xFF14244B) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Mood History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadMoodHistory,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: SafeArea(
        child: _buildBody(
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          cardColor: cardColor,
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardColor,
  }) {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF2CB5C0)),
            const SizedBox(height: 16),
            Text(
              'Loading your mood history...',
              style: TextStyle(fontSize: 15, color: secondaryTextColor),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF16E73).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFF16E73),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Unable to load mood history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Something went wrong while loading your mood entries.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: secondaryTextColor),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _loadMoodHistory,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2A4A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // EMPTY HISTORY
    // ----------------------------------------------------------

    if (_moodHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2CB5C0).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mood_rounded,
                  size: 54,
                  color: Color(0xFF2CB5C0),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'No mood entries yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Start logging your mood and your history will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: secondaryTextColor),
              ),
            ],
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // HISTORY
    // ----------------------------------------------------------

    return RefreshIndicator(
      color: const Color(0xFF2CB5C0),
      onRefresh: _loadMoodHistory,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // ------------------------------------------------------
          // HEADER
          // ------------------------------------------------------

          Text(
            'Your Mood Journey',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Here you can see the moods you have logged over time.',
            style: TextStyle(fontSize: 15, color: secondaryTextColor),
          ),

          const SizedBox(height: 24),

          // ------------------------------------------------------
          // TOTAL ENTRIES CARD
          // ------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : const Color(0xFFE0F7FA),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2CB5C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Color(0xFF2CB5C0),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total mood entries',
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${_moodHistory.length}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ------------------------------------------------------
          // HISTORY TITLE
          // ------------------------------------------------------
          Text(
            'Recent Logs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------
          // HISTORY LIST
          // ------------------------------------------------------
          ..._moodHistory.map(
            (moodEntry) => _buildMoodCard(
              moodEntry: moodEntry,
              cardColor: cardColor,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOOD CARD
  // ============================================================

  Widget _buildMoodCard({
    required Map<String, dynamic> moodEntry,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final String mood = moodEntry['mood']?.toString() ?? 'Unknown';

    final Color moodColor = _getMoodColor(mood);

    final IconData moodIcon = _getMoodIcon(mood);

    final dynamic timestamp = moodEntry['timestamp'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // MOOD ICON
          // ------------------------------------------------------

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(moodIcon, size: 30, color: moodColor),
          ),

          const SizedBox(width: 16),

          // ------------------------------------------------------
          // MOOD INFORMATION
          // ------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: moodColor,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: secondaryTextColor,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        _formatDateTime(timestamp),
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
