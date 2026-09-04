import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  // ============================================================
  // FIREBASE REFERENCES
  // ============================================================

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  static User? get currentUser {
    return _auth.currentUser;
  }

  // ============================================================
  // GET CURRENT USER UID
  // ============================================================

  static String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // GET MOOD HISTORY
  // ============================================================

  static Future<List<Map<String, dynamic>>> getMoodHistory({
    int limit = 30,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodLogs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final List<Map<String, dynamic>> moodHistory = [];

      for (final document in snapshot.docs) {
        final data = document.data();

        moodHistory.add({
          'id': document.id,
          'mood': data['mood']?.toString() ?? '',
          'moodIndex': data['moodIndex'],
          'timestamp': data['timestamp'],
          'createdAt': data['createdAt'],
        });
      }

      return moodHistory;
    } catch (e) {
      throw Exception('Unable to load mood history: $e');
    }
  }

  // ============================================================
  // GET LATEST MOOD
  // ============================================================

  static Future<Map<String, dynamic>?> getLatestMood() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final document = snapshot.docs.first;

      final data = document.data();

      return {
        'id': document.id,
        'mood': data['mood']?.toString() ?? '',
        'moodIndex': data['moodIndex'],
        'timestamp': data['timestamp'],
        'createdAt': data['createdAt'],
      };
    } catch (e) {
      throw Exception('Unable to load latest mood: $e');
    }
  }

  // ============================================================
  // COUNT MOODS
  // ============================================================

  static Future<int> getMoodCount() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodLogs')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Unable to count mood entries: $e');
    }
  }

  // ============================================================
  // GET MOOD COUNTS
  //
  // Example result:
  //
  // {
  //   "Energetic": 3,
  //   "Calm": 5,
  //   "Stressed": 7,
  //   "Drained": 2
  // }
  //
  // ============================================================

  static Future<Map<String, int>> getMoodCounts() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('moodLogs')
          .get();

      final Map<String, int> moodCounts = {
        'Energetic': 0,
        'Calm': 0,
        'Stressed': 0,
        'Drained': 0,
      };

      for (final document in snapshot.docs) {
        final data = document.data();

        final String mood = data['mood']?.toString() ?? '';

        if (moodCounts.containsKey(mood)) {
          moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
        }
      }

      return moodCounts;
    } catch (e) {
      throw Exception('Unable to calculate mood counts: $e');
    }
  }
}
