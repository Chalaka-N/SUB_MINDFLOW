import 'package:flutter/material.dart';

import 'mood_logger_screen.dart';
import 'journal_screen.dart';
import 'stress_pop_screen.dart';

import '../services/behavior_analysis_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // ============================================================
  // BEHAVIOR ANALYSIS STATE
  // ============================================================

  bool _isLoadingAnalysis = true;

  Map<String, dynamic>? _analysis;

  String? _analysisError;

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadBehaviorAnalysis();
  }

  // ============================================================
  // LOAD BEHAVIOR ANALYSIS
  // ============================================================

  Future<void> _loadBehaviorAnalysis() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAnalysis = true;
      _analysisError = null;
    });

    try {
      debugPrint('======================================');
      debugPrint('🏠 HOME DASHBOARD');
      debugPrint('🧠 Loading behavior analysis...');

      final result = await BehaviorAnalysisService.analyzeMoodBehavior();

      debugPrint('✅ Dashboard behavior analysis loaded');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _analysis = result;
        _isLoadingAnalysis = false;
      });
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('🔥 DASHBOARD ANALYSIS ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack trace: $stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _isLoadingAnalysis = false;
        _analysisError = e.toString();
      });
    }
  }

  // ============================================================
  // OPEN MOOD LOGGER
  // ============================================================

  Future<void> _openMoodLogger() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoodLoggerScreen()),
    );

    // Refresh dashboard after returning from Mood Logger.
    if (result == true && mounted) {
      await _loadBehaviorAnalysis();
    }
  }

  // ============================================================
  // OPEN JOURNAL
  // ============================================================

  void _openJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalScreen()),
    );
  }

  // ============================================================
  // OPEN QUICK CALM
  // ============================================================

  void _openQuickCalm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StressPopScreen()),
    );
  }

  // ============================================================
  // GET GREETING
  // ============================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  // ============================================================
  // GET CURRENT MOOD
  // ============================================================

  String _getLatestMood() {
    if (_analysis == null) {
      return 'No mood yet';
    }

    return _analysis!['latestMood']?.toString() ?? 'No mood yet';
  }

  // ============================================================
  // GET BEHAVIOR STATUS
  // ============================================================

  String _getBehaviorStatus() {
    if (_analysis == null) {
      return 'No analysis available';
    }

    return _analysis!['behaviorStatus']?.toString() ?? 'No analysis available';
  }

  // ============================================================
  // GET INSIGHT
  // ============================================================

  String _getInsight() {
    if (_analysis == null) {
      return 'Start logging your mood to discover patterns.';
    }

    return _analysis!['insight']?.toString() ??
        'Continue logging your mood to discover patterns.';
  }

  // ============================================================
  // GET MOOD COLOR
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
        return const Color(0xFF2CB5C0);
    }
  }

  // ============================================================
  // GET MOOD ICON
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
        return Icons.psychology_rounded;
    }
  }

  // ============================================================
  // BUILD SMART MOOD CARD
  // ============================================================

  Widget _buildMoodInsightCard() {
    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------

    if (_isLoadingAnalysis) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2CB5C0).withValues(alpha: 0.25),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF2CB5C0),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Analyzing your recent mood...',
                style: TextStyle(fontSize: 15, color: Color(0xFF546E7A)),
              ),
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------
    // ERROR
    // ------------------------------------------------------------

    if (_analysisError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF16E73).withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFF16E73),
              size: 30,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Unable to load your mood analysis.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D2A4A),
                ),
              ),
            ),
            IconButton(
              onPressed: _loadBehaviorAnalysis,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFF16E73)),
            ),
          ],
        ),
      );
    }

    // ------------------------------------------------------------
    // ANALYSIS DATA
    // ------------------------------------------------------------

    final String latestMood = _getLatestMood();
    final String behaviorStatus = _getBehaviorStatus();
    final String insight = _getInsight();

    final Color moodColor = _getMoodColor(latestMood);
    final IconData moodIcon = _getMoodIcon(latestMood);

    final int totalEntries = _analysis?['totalEntries'] as int? ?? 0;

    // ------------------------------------------------------------
    // NO MOOD DATA
    // ------------------------------------------------------------

    if (totalEntries == 0) {
      return GestureDetector(
        onTap: _openMoodLogger,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2CB5C0).withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2CB5C0).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mood_rounded,
                  color: Color(0xFF2CB5C0),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Mood',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2CB5C0),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Log your first mood',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2A4A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap here to start tracking how you feel.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF2CB5C0),
              ),
            ],
          ),
        ),
      );
    }

    // ------------------------------------------------------------
    // NORMAL MOOD DATA
    // ------------------------------------------------------------

    return GestureDetector(
      onTap: _showMoodAnalysis,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: moodColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: moodColor.withValues(alpha: 0.30),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // HEADER
            // ------------------------------------------------------

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: moodColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(moodIcon, color: moodColor, size: 27),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Your Current State',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2A4A),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17,
                  color: moodColor,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------------
            // LATEST MOOD
            // ------------------------------------------------------
            const Text(
              'Latest Mood',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF546E7A),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              latestMood,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: moodColor,
              ),
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------------
            // BEHAVIOR STATUS
            // ------------------------------------------------------
            const Text(
              'Mood Pattern',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF546E7A),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              behaviorStatus,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D2A4A),
              ),
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------------
            // INSIGHT
            // ------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: moodColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF546E7A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Tap to view detailed mood analysis',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: moodColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHOW FULL MOOD ANALYSIS
  // ============================================================

  Future<void> _showMoodAnalysis() async {
    if (_analysis == null || !mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0B1733)
        : const Color(0xFFFDFDFD);

    final textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);

    final secondaryColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF546E7A);

    final totalEntries = _analysis!['totalEntries'] as int? ?? 0;

    final energeticCount = _analysis!['energeticCount'] as int? ?? 0;

    final calmCount = _analysis!['calmCount'] as int? ?? 0;

    final stressedCount = _analysis!['stressedCount'] as int? ?? 0;

    final drainedCount = _analysis!['drainedCount'] as int? ?? 0;

    final latestMood = _analysis!['latestMood']?.toString() ?? 'No mood yet';

    final mostFrequentMood =
        _analysis!['mostFrequentMood']?.toString() ?? 'Not enough data';

    final moodTrend = _analysis!['moodTrend']?.toString() ?? 'Not enough data';

    final behaviorStatus =
        _analysis!['behaviorStatus']?.toString() ?? 'No analysis available';

    final insight =
        _analysis!['insight']?.toString() ?? 'Continue logging your mood.';

    final repeatedStress = _analysis!['repeatedStress'] as bool? ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.82,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  Row(
                    children: [
                      const Icon(
                        Icons.psychology_rounded,
                        color: Color(0xFF2CB5C0),
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mood Analysis',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close_rounded, color: textColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Based on your recorded mood history',
                    style: TextStyle(fontSize: 15, color: secondaryColor),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: [
                        // ------------------------------------------
                        // CURRENT PATTERN
                        // ------------------------------------------

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2CB5C0)
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF2CB5C0)
                                  .withValues(alpha: 0.30),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Pattern',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2CB5C0),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                behaviorStatus,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ------------------------------------------
                        // LATEST MOOD
                        // ------------------------------------------
                        _buildDetailCard(
                          title: 'Latest Mood',
                          value: latestMood,
                          icon: _getMoodIcon(latestMood),
                          color: _getMoodColor(latestMood),
                          textColor: textColor,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        // ------------------------------------------
                        // MOST FREQUENT
                        // ------------------------------------------
                        _buildDetailCard(
                          title: 'Most Frequent Mood',
                          value: mostFrequentMood,
                          icon: Icons.emoji_emotions_rounded,
                          color: const Color(0xFF9163A6),
                          textColor: textColor,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        // ------------------------------------------
                        // TREND
                        // ------------------------------------------
                        _buildDetailCard(
                          title: 'Mood Trend',
                          value: moodTrend,
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF2CB5C0),
                          textColor: textColor,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 10),

                        // ------------------------------------------
                        // TOTAL ENTRIES
                        // ------------------------------------------
                        _buildDetailCard(
                          title: 'Total Mood Entries',
                          value: '$totalEntries',
                          icon: Icons.analytics_rounded,
                          color: const Color(0xFFA5C953),
                          textColor: textColor,
                          isDark: isDark,
                        ),

                        const SizedBox(height: 18),

                        // ------------------------------------------
                        // MOOD COUNTS
                        // ------------------------------------------
                        Text(
                          'Mood History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildMoodCountRow(
                          'Energetic',
                          energeticCount,
                          const Color(0xFFA5C953),
                          Icons.bolt_rounded,
                          isDark,
                        ),

                        const SizedBox(height: 8),

                        _buildMoodCountRow(
                          'Calm',
                          calmCount,
                          const Color(0xFF2CB5C0),
                          Icons.water_drop_rounded,
                          isDark,
                        ),

                        const SizedBox(height: 8),

                        _buildMoodCountRow(
                          'Stressed',
                          stressedCount,
                          const Color(0xFFF16E73),
                          Icons.waves_rounded,
                          isDark,
                        ),

                        const SizedBox(height: 8),

                        _buildMoodCountRow(
                          'Drained',
                          drainedCount,
                          const Color(0xFF9163A6),
                          Icons.battery_0_bar_rounded,
                          isDark,
                        ),

                        const SizedBox(height: 18),

                        // ------------------------------------------
                        // REPEATED STRESS
                        // ------------------------------------------
                        if (repeatedStress)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF16E73)
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF16E73)
                                    .withValues(alpha: 0.30),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFF16E73),
                                  size: 25,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Repeated stress detected in your recent mood entries.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (repeatedStress) const SizedBox(height: 16),

                        // ------------------------------------------
                        // INSIGHT
                        // ------------------------------------------
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF14244B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : const Color(0xFFE0F7FA),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    color: Color(0xFFA5C953),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'MindFlow Insight',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                insight,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL CARD
  // ============================================================

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14244B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : const Color(0xFFE0F7FA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOOD COUNT ROW
  // ============================================================

  Widget _buildMoodCountRow(
    String mood,
    int count,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14244B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : const Color(0xFFE0F7FA),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mood,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // LOGO
          // ======================================================

          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // GREETING
          // ======================================================
          Text(
            _getGreeting(),
            style: const TextStyle(fontSize: 16, color: Color(0xFF546E7A)),
          ),

          const SizedBox(height: 4),

          const Text(
            'Ready to find your flow?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D2A4A),
            ),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // SMART MOOD / BEHAVIOR CARD
          // ======================================================
          _buildMoodInsightCard(),

          const SizedBox(height: 24),

          // ======================================================
          // DAILY FOCUS CARD
          // ======================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2CB5C0).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5C953).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFFA5C953),
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Focus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2CB5C0),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Balance. Focus. Thrive.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2A4A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // QUICK CALM
          // ======================================================
          GestureDetector(
            onTap: _openQuickCalm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF16E73),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF16E73).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'HIGH STRESS? Tap for Quick Calm',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // QUICK ACTIONS
          // ======================================================
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D2A4A),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.spa_rounded,
                  label: 'Log Mood',
                  color: const Color(0xFF9163A6),
                  onTap: _openMoodLogger,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit_note_rounded,
                  label: 'Journal',
                  color: const Color(0xFFF16E73),
                  onTap: _openJournal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION CARD
  // ============================================================

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 36, color: color),

                const SizedBox(height: 12),

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
