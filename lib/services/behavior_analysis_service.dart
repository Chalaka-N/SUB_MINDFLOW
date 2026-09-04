import 'package:firebase_auth/firebase_auth.dart';

import 'mood_service.dart';

class BehaviorAnalysisService {
  // ============================================================
  // ANALYZE CURRENT USER'S MOOD BEHAVIOR
  // ============================================================

  static Future<Map<String, dynamic>> analyzeMoodBehavior() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    // Get existing mood history.
    final List<Map<String, dynamic>> moods = await MoodService.getMoodHistory();

    // ------------------------------------------------------------
    // Basic counters
    // ------------------------------------------------------------

    int energeticCount = 0;
    int calmCount = 0;
    int stressedCount = 0;
    int drainedCount = 0;

    for (final moodEntry in moods) {
      final String mood = moodEntry['mood']?.toString().toLowerCase() ?? '';

      switch (mood) {
        case 'energetic':
          energeticCount++;
          break;

        case 'calm':
          calmCount++;
          break;

        case 'stressed':
          stressedCount++;
          break;

        case 'drained':
          drainedCount++;
          break;
      }
    }

    // ------------------------------------------------------------
    // Total entries
    // ------------------------------------------------------------

    final int totalEntries = moods.length;

    // ------------------------------------------------------------
    // Find most frequent mood
    // ------------------------------------------------------------

    final Map<String, int> moodCounts = {
      'Energetic': energeticCount,
      'Calm': calmCount,
      'Stressed': stressedCount,
      'Drained': drainedCount,
    };

    String? mostFrequentMood;
    int highestCount = 0;

    moodCounts.forEach((mood, count) {
      if (count > highestCount) {
        highestCount = count;
        mostFrequentMood = mood;
      }
    });

    // ------------------------------------------------------------
    // Latest mood
    // ------------------------------------------------------------

    String? latestMood;

    if (moods.isNotEmpty) {
      latestMood = moods.first['mood']?.toString();
    }

    // ------------------------------------------------------------
    // Calculate percentages
    // ------------------------------------------------------------

    double energeticPercentage = 0;
    double calmPercentage = 0;
    double stressedPercentage = 0;
    double drainedPercentage = 0;

    if (totalEntries > 0) {
      energeticPercentage = (energeticCount / totalEntries) * 100;
      calmPercentage = (calmCount / totalEntries) * 100;
      stressedPercentage = (stressedCount / totalEntries) * 100;
      drainedPercentage = (drainedCount / totalEntries) * 100;
    }

    // ------------------------------------------------------------
    // Most frequent mood percentage
    // ------------------------------------------------------------

    double mostFrequentMoodPercentage = 0;

    if (totalEntries > 0) {
      mostFrequentMoodPercentage = (highestCount / totalEntries) * 100;
    }

    // ------------------------------------------------------------
    // Determine basic behavior state
    // ------------------------------------------------------------

    String behaviorStatus;

    if (totalEntries == 0) {
      behaviorStatus = 'No mood data yet';
    } else if (stressedCount > calmCount &&
        stressedCount > energeticCount &&
        stressedCount > drainedCount) {
      behaviorStatus = 'Stress appears frequently';
    } else if (drainedCount > calmCount &&
        drainedCount > energeticCount &&
        drainedCount > stressedCount) {
      behaviorStatus = 'Low energy appears frequently';
    } else if (calmCount >= stressedCount &&
        calmCount >= drainedCount &&
        calmCount >= energeticCount) {
      behaviorStatus = 'Generally calm';
    } else if (energeticCount > stressedCount &&
        energeticCount > drainedCount &&
        energeticCount > calmCount) {
      behaviorStatus = 'Generally energetic';
    } else {
      behaviorStatus = 'Mixed mood pattern';
    }

    // ------------------------------------------------------------
    // Detect recent trend
    // ------------------------------------------------------------

    String moodTrend = 'Not enough data';

    if (moods.length >= 2) {
      final String latest = moods[0]['mood']?.toString().toLowerCase() ?? '';

      final String previous = moods[1]['mood']?.toString().toLowerCase() ?? '';

      if (latest == previous) {
        moodTrend = 'Mood appears consistent';
      } else if (latest == 'calm' || latest == 'energetic') {
        moodTrend = 'Recent mood appears positive';
      } else if (latest == 'stressed' || latest == 'drained') {
        moodTrend = 'Recent mood needs attention';
      } else {
        moodTrend = 'Mood is changing';
      }
    }

    // ------------------------------------------------------------
    // Detect repeated stress
    // ------------------------------------------------------------

    bool repeatedStress = false;

    if (moods.length >= 2) {
      int recentStressCount = 0;

      final int entriesToCheck = moods.length >= 3 ? 3 : moods.length;

      for (int i = 0; i < entriesToCheck; i++) {
        final String mood = moods[i]['mood']?.toString().toLowerCase() ?? '';

        if (mood == 'stressed') {
          recentStressCount++;
        }
      }

      repeatedStress = recentStressCount >= 2;
    }

    // ------------------------------------------------------------
    // Generate personalized insight
    // ------------------------------------------------------------

    String insight;

    if (totalEntries == 0) {
      insight = 'Start logging your mood regularly to discover patterns.';
    } else if (repeatedStress) {
      insight =
          'Stress has appeared repeatedly in your recent entries. '
          'Consider taking a short break and giving yourself some time to relax.';
    } else if (stressedPercentage >= 50) {
      insight =
          'Stress makes up a large part of your recent mood history. '
          'Pay attention to activities or situations that may be affecting you.';
    } else if (drainedPercentage >= 50) {
      insight =
          'Low energy appears frequently in your mood history. '
          'Consider giving yourself enough rest and recovery time.';
    } else if (calmPercentage >= 50) {
      insight =
          'Calm is your most common recent mood. '
          'Your recent entries suggest a relatively balanced state.';
    } else if (energeticPercentage >= 50) {
      insight =
          'Energetic is your most common recent mood. '
          'Your recent entries show a positive energy pattern.';
    } else {
      insight =
          'Your mood history shows a mixture of emotions. '
          'Continue logging your mood to reveal clearer patterns.';
    }

    // ------------------------------------------------------------
    // Build analysis result
    // ------------------------------------------------------------

    final Map<String, dynamic> analysis = {
      'userId': user.uid,

      // Basic information
      'totalEntries': totalEntries,

      // Counts
      'energeticCount': energeticCount,
      'calmCount': calmCount,
      'stressedCount': stressedCount,
      'drainedCount': drainedCount,

      // Percentages
      'energeticPercentage': energeticPercentage,
      'calmPercentage': calmPercentage,
      'stressedPercentage': stressedPercentage,
      'drainedPercentage': drainedPercentage,

      // Dominant mood
      'mostFrequentMood': mostFrequentMood,
      'mostFrequentMoodCount': highestCount,
      'mostFrequentMoodPercentage': mostFrequentMoodPercentage,

      // Latest mood
      'latestMood': latestMood,

      // Analysis
      'behaviorStatus': behaviorStatus,
      'moodTrend': moodTrend,
      'repeatedStress': repeatedStress,
      'insight': insight,
    };

    // ------------------------------------------------------------
    // Debug output
    // ------------------------------------------------------------

    print('======================================');
    print('🧠 BEHAVIOR ANALYSIS');
    print('🆔 UID: ${user.uid}');
    print('📊 Total mood entries: $totalEntries');

    print(
      '⚡ Energetic: $energeticCount '
      '(${energeticPercentage.toStringAsFixed(1)}%)',
    );

    print(
      '🌊 Calm: $calmCount '
      '(${calmPercentage.toStringAsFixed(1)}%)',
    );

    print(
      '😣 Stressed: $stressedCount '
      '(${stressedPercentage.toStringAsFixed(1)}%)',
    );

    print(
      '🔋 Drained: $drainedCount '
      '(${drainedPercentage.toStringAsFixed(1)}%)',
    );

    print('🏆 Most frequent mood: $mostFrequentMood');
    print(
      '📈 Dominant mood percentage: '
      '${mostFrequentMoodPercentage.toStringAsFixed(1)}%',
    );

    print('😊 Latest mood: $latestMood');
    print('📈 Mood trend: $moodTrend');
    print('⚠️ Repeated stress: $repeatedStress');
    print('🧠 Behavior status: $behaviorStatus');
    print('💡 Insight: $insight');

    print('======================================');

    return analysis;
  }
}
