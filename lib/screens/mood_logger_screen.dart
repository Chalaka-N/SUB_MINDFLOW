import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/mood_service.dart';
import '../services/behavior_analysis_service.dart';

class MoodLoggerScreen extends StatefulWidget {
  const MoodLoggerScreen({super.key});

  @override
  State<MoodLoggerScreen> createState() => _MoodLoggerScreenState();
}

class _MoodLoggerScreenState extends State<MoodLoggerScreen> {
  int? _selectedMoodIndex;

  bool _isSaving = false;
  bool _isLoadingHistory = false;
  bool _isAnalyzingBehavior = false;

  final List<Map<String, dynamic>> _moods = [
    {
      'label': 'Energetic',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFA5C953),
    },
    {
      'label': 'Calm',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF2CB5C0),
    },
    {
      'label': 'Stressed',
      'icon': Icons.waves_rounded,
      'color': const Color(0xFFF16E73),
    },
    {
      'label': 'Drained',
      'icon': Icons.battery_0_bar_rounded,
      'color': const Color(0xFF9163A6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedMood();
  }

  // ============================================================
  // LOAD LAST LOCAL MOOD
  // ============================================================

  Future<void> _loadSavedMood() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _selectedMoodIndex = prefs.getInt('saved_mood_index');
      });
    } catch (e) {
      debugPrint('🔥 Error loading saved mood: $e');
    }
  }

  // ============================================================
  // SAVE MOOD
  // ============================================================

  Future<void> _saveMood() async {
    if (_selectedMoodIndex == null || _isSaving) {
      return;
    }

    final selectedMood = _moods[_selectedMoodIndex!];
    final String moodLabel = selectedMood['label'].toString();

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('saved_mood_index', _selectedMoodIndex!);

      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No authenticated user found.');
      }

      debugPrint('======================================');
      debugPrint('😊 SAVING MOOD');
      debugPrint('🆔 UID: ${user.uid}');
      debugPrint('😊 Mood: $moodLabel');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moodLogs')
          .add({
            'mood': moodLabel,
            'moodIndex': _selectedMoodIndex,
            'timestamp': FieldValue.serverTimestamp(),
            'createdAt': Timestamp.now(),
          });

      debugPrint('✅ Mood saved to Firestore');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'latestMood': moodLabel,
        'latestMoodIndex': _selectedMoodIndex,
        'latestMoodUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Latest mood updated in profile');
      debugPrint('======================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged: $moodLabel!'),
          backgroundColor: selectedMood['color'] as Color,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('🔥 MOOD SAVE ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack trace: $stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save your mood.\n\n$e'),
          backgroundColor: const Color(0xFFF16E73),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isSaving = false;
      });
    }
  }

  // ============================================================
  // SHOW MOOD HISTORY
  // ============================================================

  Future<void> _showMoodHistory() async {
    if (_isLoadingHistory) return;

    setState(() {
      _isLoadingHistory = true;
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
        _isLoadingHistory = false;
      });

      await _displayMoodHistory(moods);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('🔥 MOOD HISTORY ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack trace: $stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _isLoadingHistory = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load mood history.\n\n$e'),
          backgroundColor: const Color(0xFFF16E73),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // ANALYZE MOOD BEHAVIOR
  // ============================================================

  Future<void> _analyzeMoodBehavior() async {
    if (_isAnalyzingBehavior) return;

    setState(() {
      _isAnalyzingBehavior = true;
    });

    try {
      debugPrint('======================================');
      debugPrint('🧠 STARTING BEHAVIOR ANALYSIS');

      final analysis = await BehaviorAnalysisService.analyzeMoodBehavior();

      debugPrint('✅ BEHAVIOR ANALYSIS COMPLETED');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _isAnalyzingBehavior = false;
      });

      await _displayBehaviorAnalysis(analysis);
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('🔥 BEHAVIOR ANALYSIS ERROR');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Stack trace: $stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _isAnalyzingBehavior = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to analyze your mood behavior.\n\n$e'),
          backgroundColor: const Color(0xFFF16E73),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DISPLAY IMPROVED BEHAVIOR ANALYSIS
  // ============================================================

  Future<void> _displayBehaviorAnalysis(Map<String, dynamic> analysis) async {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0B1733)
        : const Color(0xFFFDFDFD);

    final cardColor = isDark ? const Color(0xFF14244B) : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);

    final secondaryColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF546E7A);

    final int totalEntries = analysis['totalEntries'] as int? ?? 0;

    final int energeticCount = analysis['energeticCount'] as int? ?? 0;

    final int calmCount = analysis['calmCount'] as int? ?? 0;

    final int stressedCount = analysis['stressedCount'] as int? ?? 0;

    final int drainedCount = analysis['drainedCount'] as int? ?? 0;

    final double energeticPercentage =
        (analysis['energeticPercentage'] as num?)?.toDouble() ?? 0;

    final double calmPercentage =
        (analysis['calmPercentage'] as num?)?.toDouble() ?? 0;

    final double stressedPercentage =
        (analysis['stressedPercentage'] as num?)?.toDouble() ?? 0;

    final double drainedPercentage =
        (analysis['drainedPercentage'] as num?)?.toDouble() ?? 0;

    final double mostFrequentMoodPercentage =
        (analysis['mostFrequentMoodPercentage'] as num?)?.toDouble() ?? 0;

    final String mostFrequentMood =
        analysis['mostFrequentMood']?.toString() ?? 'Not enough data';

    final String latestMood =
        analysis['latestMood']?.toString() ?? 'No mood yet';

    final String behaviorStatus =
        analysis['behaviorStatus']?.toString() ?? 'No analysis available';

    final String moodTrend =
        analysis['moodTrend']?.toString() ?? 'Not enough data';

    final bool repeatedStress = analysis['repeatedStress'] as bool? ?? false;

    final String insight =
        analysis['insight']?.toString() ??
        'Continue logging your mood to discover patterns.';

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
            height: MediaQuery.of(context).size.height * 0.88,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9163A6)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: Color(0xFF9163A6),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mood Analysis',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your emotional pattern',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryColor,
                              ),
                            ),
                          ],
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

                  const SizedBox(height: 18),

                  // ==================================================
                  // CURRENT PATTERN
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2CB5C0).withValues(alpha: 0.16),
                          const Color(0xFF9163A6).withValues(alpha: 0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2CB5C0).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              color: Color(0xFF2CB5C0),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Current Pattern',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2CB5C0),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          behaviorStatus,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '$totalEntries mood entries analyzed',
                          style: TextStyle(fontSize: 13, color: secondaryColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // LATEST + TREND
                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: _getMoodIcon(latestMood),
                          title: 'Latest Mood',
                          value: latestMood,
                          color: _getMoodColor(latestMood),
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          cardColor: cardColor,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.trending_up_rounded,
                          title: 'Mood Trend',
                          value: moodTrend,
                          color: const Color(0xFF2CB5C0),
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          cardColor: cardColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Mood Breakdown',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildMoodPercentageCard(
                          title: 'Energetic',
                          count: energeticCount,
                          percentage: energeticPercentage,
                          icon: Icons.bolt_rounded,
                          color: const Color(0xFFA5C953),
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          cardColor: cardColor,
                        ),

                        const SizedBox(height: 10),

                        _buildMoodPercentageCard(
                          title: 'Calm',
                          count: calmCount,
                          percentage: calmPercentage,
                          icon: Icons.water_drop_rounded,
                          color: const Color(0xFF2CB5C0),
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          cardColor: cardColor,
                        ),

                        const SizedBox(height: 10),

                        _buildMoodPercentageCard(
                          title: 'Stressed',
                          count: stressedCount,
                          percentage: stressedPercentage,
                          icon: Icons.waves_rounded,
                          color: const Color(0xFFF16E73),
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          cardColor: cardColor,
                        ),

                        const SizedBox(height: 10),

                        _buildMoodPercentageCard(
                          title: 'Drained',
                          count: drainedCount,
                          percentage: drainedPercentage,
                          icon: Icons.battery_0_bar_rounded,
                          color: const Color(0xFF9163A6),
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                          cardColor: cardColor,
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // DOMINANT MOOD
                        // ==================================================
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : const Color(0xFFE0F7FA),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _getMoodColor(mostFrequentMood)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getMoodIcon(mostFrequentMood),
                                  color: _getMoodColor(mostFrequentMood),
                                  size: 26,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Most Frequent Mood',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      mostFrequentMood,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                '${mostFrequentMoodPercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _getMoodColor(mostFrequentMood),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // REPEATED STRESS
                        // ==================================================
                        if (repeatedStress)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF16E73)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFF16E73)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFF16E73),
                                  size: 27,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Repeated Stress Detected',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Stress has appeared in multiple recent entries.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (repeatedStress) const SizedBox(height: 14),

                        // ==================================================
                        // PERSONALIZED INSIGHT
                        // ==================================================
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2CB5C0)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF2CB5C0)
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_rounded,
                                    color: Color(0xFF2CB5C0),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Personalized Insight',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

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
  // MOOD PERCENTAGE CARD
  // ============================================================

  Widget _buildMoodPercentageCard({
    required String title,
    required int count,
    required double percentage,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color secondaryColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 23),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),

              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color textColor,
    required Color secondaryColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 112,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPLAY MOOD HISTORY
  // ============================================================

  Future<void> _displayMoodHistory(List<Map<String, dynamic>> moods) async {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0B1733)
        : const Color(0xFFFDFDFD);

    final textColor = isDark ? Colors.white : const Color(0xFF0D2A4A);

    final secondaryColor = isDark
        ? Colors.grey.shade400
        : const Color(0xFF546E7A);

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
            height: MediaQuery.of(context).size.height * 0.78,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mood History',
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
                    'Your recent mood entries',
                    style: TextStyle(fontSize: 15, color: secondaryColor),
                  ),

                  const SizedBox(height: 20),

                  if (moods.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mood_bad_rounded,
                              size: 70,
                              color: secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No mood entries yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start logging your mood to build your history.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: moods.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final moodData = moods[index];

                          final String mood =
                              moodData['mood']?.toString() ?? 'Unknown';

                          final String dateText = _formatMoodDate(
                            moodData['timestamp'],
                          );

                          final Color moodColor = _getMoodColor(mood);

                          final IconData moodIcon = _getMoodIcon(mood);

                          return Container(
                            padding: const EdgeInsets.all(16),
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
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: moodColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    moodIcon,
                                    color: moodColor,
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mood,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        dateText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
  // MOOD DATE FORMATTER
  // ============================================================

  String _formatMoodDate(dynamic timestamp) {
    DateTime? date;

    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    }

    if (date == null) {
      return 'Recently';
    }

    final String hour = date.hour == 0
        ? '12'
        : date.hour > 12
        ? '${date.hour - 12}'
        : '${date.hour}';

    final String minute = date.minute.toString().padLeft(2, '0');

    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        'at $hour:$minute $period';
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
          'Log Your Mood',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you feeling right now?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Select the emotion that best describes your current state of mind.',
                style: TextStyle(fontSize: 16, color: secondaryTextColor),
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
                    final mood = _moods[index];

                    final bool isSelected = _selectedMoodIndex == index;

                    final Color moodColor = mood['color'] as Color;

                    return GestureDetector(
                      onTap: _isSaving || _isAnalyzingBehavior
                          ? null
                          : () {
                              setState(() {
                                _selectedMoodIndex = index;
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? moodColor.withValues(alpha: 0.1)
                              : cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? moodColor
                                : isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: moodColor.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mood['icon'] as IconData,
                              size: 48,
                              color: isSelected
                                  ? moodColor
                                  : isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              mood['label'].toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? moodColor
                                    : isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MOOD HISTORY BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _isSaving || _isLoadingHistory || _isAnalyzingBehavior
                      ? null
                      : _showMoodHistory,

                  icon: _isLoadingHistory
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2CB5C0),
                          ),
                        )
                      : const Icon(Icons.history_rounded),

                  label: Text(
                    _isLoadingHistory
                        ? 'Loading History...'
                        : 'View Mood History',
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2CB5C0),
                    side: const BorderSide(color: Color(0xFF2CB5C0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // ANALYZE MOOD BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _isSaving || _isLoadingHistory || _isAnalyzingBehavior
                      ? null
                      : _analyzeMoodBehavior,

                  icon: _isAnalyzingBehavior
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF9163A6),
                          ),
                        )
                      : const Icon(Icons.psychology_rounded),

                  label: Text(
                    _isAnalyzingBehavior
                        ? 'Analyzing Behavior...'
                        : 'Analyze My Mood',
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9163A6),
                    side: const BorderSide(color: Color(0xFF9163A6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // SAVE BUTTON
              // ==================================================
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

                  onPressed:
                      _selectedMoodIndex != null &&
                          !_isSaving &&
                          !_isLoadingHistory &&
                          !_isAnalyzingBehavior
                      ? _saveMood
                      : null,

                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Entry',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
