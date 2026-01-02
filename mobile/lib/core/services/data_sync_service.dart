// Data Sync Service - Handles local storage + Firebase cloud sync
// Ensures data persists across app reinstalls and devices

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_journey.dart';

/// Keys for local storage
class StorageKeys {
  static const String userStats = 'user_stats_v1';
  static const String gameHighScores = 'game_high_scores_v1';
  static const String achievements = 'achievements_v1';
  static const String learnedWords = 'learned_words_v1';
  static const String voiceRecordings = 'voice_recordings_v1';
  static const String dailySessions = 'daily_sessions_v1';
  static const String userProfile = 'user_profile_v1';
  static const String lastSyncTime = 'last_sync_time';
}

/// Model for game high scores
class GameHighScores {
  final Map<String, int> scores; // gameId -> highScore
  final Map<String, int> timesPlayed; // gameId -> playCount
  final int totalScore;
  final DateTime? lastUpdated;

  GameHighScores({
    this.scores = const {},
    this.timesPlayed = const {},
    this.totalScore = 0,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'scores': scores,
    'timesPlayed': timesPlayed,
    'totalScore': totalScore,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory GameHighScores.fromJson(Map<String, dynamic> json) => GameHighScores(
    scores: Map<String, int>.from(json['scores'] ?? {}),
    timesPlayed: Map<String, int>.from(json['timesPlayed'] ?? {}),
    totalScore: json['totalScore'] ?? 0,
    lastUpdated: json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'])
        : null,
  );

  GameHighScores copyWith({
    Map<String, int>? scores,
    Map<String, int>? timesPlayed,
    int? totalScore,
    DateTime? lastUpdated,
  }) => GameHighScores(
    scores: scores ?? this.scores,
    timesPlayed: timesPlayed ?? this.timesPlayed,
    totalScore: totalScore ?? this.totalScore,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

/// Model for user statistics
class UserStats {
  final int currentStreak;
  final int longestStreak;
  final int totalWordsLearned;
  final int totalRecordings;
  final int totalMinutesPracticed;
  final int totalGameSessions;
  final double avgFluencyScore;
  final DateTime? lastActiveDate;
  final List<DateTime> activeDates; // For streak calculation

  UserStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWordsLearned = 0,
    this.totalRecordings = 0,
    this.totalMinutesPracticed = 0,
    this.totalGameSessions = 0,
    this.avgFluencyScore = 0.0,
    this.lastActiveDate,
    this.activeDates = const [],
  });

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalWordsLearned': totalWordsLearned,
    'totalRecordings': totalRecordings,
    'totalMinutesPracticed': totalMinutesPracticed,
    'totalGameSessions': totalGameSessions,
    'avgFluencyScore': avgFluencyScore,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'activeDates': activeDates.map((d) => d.toIso8601String()).toList(),
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    totalWordsLearned: json['totalWordsLearned'] ?? 0,
    totalRecordings: json['totalRecordings'] ?? 0,
    totalMinutesPracticed: json['totalMinutesPracticed'] ?? 0,
    totalGameSessions: json['totalGameSessions'] ?? 0,
    avgFluencyScore: (json['avgFluencyScore'] ?? 0.0).toDouble(),
    lastActiveDate: json['lastActiveDate'] != null
        ? DateTime.parse(json['lastActiveDate'])
        : null,
    activeDates:
        (json['activeDates'] as List<dynamic>?)
            ?.map((d) => DateTime.parse(d))
            .toList() ??
        [],
  );

  UserStats copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalWordsLearned,
    int? totalRecordings,
    int? totalMinutesPracticed,
    int? totalGameSessions,
    double? avgFluencyScore,
    DateTime? lastActiveDate,
    List<DateTime>? activeDates,
  }) => UserStats(
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
    totalRecordings: totalRecordings ?? this.totalRecordings,
    totalMinutesPracticed: totalMinutesPracticed ?? this.totalMinutesPracticed,
    totalGameSessions: totalGameSessions ?? this.totalGameSessions,
    avgFluencyScore: avgFluencyScore ?? this.avgFluencyScore,
    lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    activeDates: activeDates ?? this.activeDates,
  );
}

/// Main Data Sync Service
class DataSyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  SharedPreferences? _prefs;

  DataSyncService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ===================
  // USER STATS
  // ===================

  /// Get user stats - tries local first, then syncs from cloud
  Future<UserStats> getUserStats() async {
    await init();

    // Try local first
    final localData = _prefs?.getString(StorageKeys.userStats);
    UserStats localStats = localData != null
        ? UserStats.fromJson(jsonDecode(localData))
        : UserStats();

    // If authenticated, sync with cloud
    if (isAuthenticated) {
      try {
        final cloudStats = await _getCloudUserStats();
        if (cloudStats != null) {
          // Merge: prefer cloud data if it's newer or has more progress
          localStats = _mergeStats(localStats, cloudStats);
          await _saveUserStatsLocal(localStats);
        }
      } catch (e) {
        // If cloud fails, use local data
        print('Cloud sync failed, using local data: $e');
      }
    }

    return localStats;
  }

  /// Save user stats - saves locally and syncs to cloud
  Future<void> saveUserStats(UserStats stats) async {
    await init();
    await _saveUserStatsLocal(stats);

    if (isAuthenticated) {
      await _saveUserStatsCloud(stats);
    }
  }

  Future<void> _saveUserStatsLocal(UserStats stats) async {
    await _prefs?.setString(StorageKeys.userStats, jsonEncode(stats.toJson()));
  }

  Future<void> _saveUserStatsCloud(UserStats stats) async {
    try {
      await _firestore.collection('users').doc(currentUserId).set({
        'stats': stats.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to save stats to cloud: $e');
    }
  }

  Future<UserStats?> _getCloudUserStats() async {
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists && doc.data()?['stats'] != null) {
        return UserStats.fromJson(doc.data()!['stats']);
      }
    } catch (e) {
      print('Failed to get cloud stats: $e');
    }
    return null;
  }

  UserStats _mergeStats(UserStats local, UserStats cloud) {
    // Take the higher values (more progress)
    return UserStats(
      currentStreak: local.currentStreak > cloud.currentStreak
          ? local.currentStreak
          : cloud.currentStreak,
      longestStreak: local.longestStreak > cloud.longestStreak
          ? local.longestStreak
          : cloud.longestStreak,
      totalWordsLearned: local.totalWordsLearned > cloud.totalWordsLearned
          ? local.totalWordsLearned
          : cloud.totalWordsLearned,
      totalRecordings: local.totalRecordings > cloud.totalRecordings
          ? local.totalRecordings
          : cloud.totalRecordings,
      totalMinutesPracticed:
          local.totalMinutesPracticed > cloud.totalMinutesPracticed
          ? local.totalMinutesPracticed
          : cloud.totalMinutesPracticed,
      totalGameSessions: local.totalGameSessions > cloud.totalGameSessions
          ? local.totalGameSessions
          : cloud.totalGameSessions,
      avgFluencyScore: local.avgFluencyScore > cloud.avgFluencyScore
          ? local.avgFluencyScore
          : cloud.avgFluencyScore,
      lastActiveDate:
          (local.lastActiveDate != null &&
              (cloud.lastActiveDate == null ||
                  local.lastActiveDate!.isAfter(cloud.lastActiveDate!)))
          ? local.lastActiveDate
          : cloud.lastActiveDate,
      activeDates: _mergeActiveDates(local.activeDates, cloud.activeDates),
    );
  }

  List<DateTime> _mergeActiveDates(List<DateTime> local, List<DateTime> cloud) {
    final Set<String> dateStrings = {};
    final List<DateTime> merged = [];

    for (final date in [...local, ...cloud]) {
      final dateStr = '${date.year}-${date.month}-${date.day}';
      if (!dateStrings.contains(dateStr)) {
        dateStrings.add(dateStr);
        merged.add(DateTime(date.year, date.month, date.day));
      }
    }

    merged.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return merged.take(365).toList(); // Keep last 365 days
  }

  // ===================
  // GAME HIGH SCORES
  // ===================

  /// Get game high scores
  Future<GameHighScores> getGameHighScores() async {
    await init();

    // Try local first
    final localData = _prefs?.getString(StorageKeys.gameHighScores);
    GameHighScores localScores = localData != null
        ? GameHighScores.fromJson(jsonDecode(localData))
        : GameHighScores();

    // Sync with cloud if authenticated
    if (isAuthenticated) {
      try {
        final cloudScores = await _getCloudGameScores();
        if (cloudScores != null) {
          localScores = _mergeGameScores(localScores, cloudScores);
          await _saveGameHighScoresLocal(localScores);
        }
      } catch (e) {
        print('Cloud game scores sync failed: $e');
      }
    }

    return localScores;
  }

  /// Save game high score for a specific game
  Future<void> saveGameHighScore(
    String gameId,
    int score,
    bool isNewHigh,
  ) async {
    await init();

    final current = await getGameHighScores();
    final updatedScores = Map<String, int>.from(current.scores);
    final updatedPlayed = Map<String, int>.from(current.timesPlayed);

    // Update high score if new record
    if (isNewHigh || (updatedScores[gameId] ?? 0) < score) {
      updatedScores[gameId] = score;
    }

    // Increment play count
    updatedPlayed[gameId] = (updatedPlayed[gameId] ?? 0) + 1;

    final updated = current.copyWith(
      scores: updatedScores,
      timesPlayed: updatedPlayed,
      totalScore: updatedScores.values.fold<int>(0, (sum, s) => sum + s),
      lastUpdated: DateTime.now(),
    );

    await _saveGameHighScoresLocal(updated);

    if (isAuthenticated) {
      await _saveGameHighScoresCloud(updated);
    }
  }

  Future<void> _saveGameHighScoresLocal(GameHighScores scores) async {
    await _prefs?.setString(
      StorageKeys.gameHighScores,
      jsonEncode(scores.toJson()),
    );
  }

  Future<void> _saveGameHighScoresCloud(GameHighScores scores) async {
    try {
      await _firestore.collection('users').doc(currentUserId).set({
        'gameHighScores': scores.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to save game scores to cloud: $e');
    }
  }

  Future<GameHighScores?> _getCloudGameScores() async {
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists && doc.data()?['gameHighScores'] != null) {
        return GameHighScores.fromJson(doc.data()!['gameHighScores']);
      }
    } catch (e) {
      print('Failed to get cloud game scores: $e');
    }
    return null;
  }

  GameHighScores _mergeGameScores(GameHighScores local, GameHighScores cloud) {
    final mergedScores = <String, int>{};
    final mergedPlayed = <String, int>{};

    // Merge scores (take highest)
    final allGameIds = {...local.scores.keys, ...cloud.scores.keys};
    for (final gameId in allGameIds) {
      final localScore = local.scores[gameId] ?? 0;
      final cloudScore = cloud.scores[gameId] ?? 0;
      mergedScores[gameId] = localScore > cloudScore ? localScore : cloudScore;

      final localPlayed = local.timesPlayed[gameId] ?? 0;
      final cloudPlayed = cloud.timesPlayed[gameId] ?? 0;
      mergedPlayed[gameId] = localPlayed > cloudPlayed
          ? localPlayed
          : cloudPlayed;
    }

    return GameHighScores(
      scores: mergedScores,
      timesPlayed: mergedPlayed,
      totalScore: mergedScores.values.fold(0, (sum, s) => sum + s),
      lastUpdated: DateTime.now(),
    );
  }

  // ===================
  // ACHIEVEMENTS
  // ===================

  /// Get all achievements
  Future<List<Achievement>> getAchievements() async {
    await init();

    final localData = _prefs?.getString(StorageKeys.achievements);
    List<Achievement> localAchievements = [];

    if (localData != null) {
      try {
        final list = jsonDecode(localData) as List;
        localAchievements = list.map((e) => Achievement.fromJson(e)).toList();
      } catch (e) {
        print('Failed to parse local achievements: $e');
      }
    }

    // Sync with cloud
    if (isAuthenticated) {
      try {
        final cloudAchievements = await _getCloudAchievements();
        if (cloudAchievements.isNotEmpty) {
          localAchievements = _mergeAchievements(
            localAchievements,
            cloudAchievements,
          );
          await _saveAchievementsLocal(localAchievements);
        }
      } catch (e) {
        print('Cloud achievements sync failed: $e');
      }
    }

    return localAchievements;
  }

  /// Add a new achievement
  Future<void> addAchievement(Achievement achievement) async {
    await init();

    final current = await getAchievements();

    // Check if already exists
    if (current.any((a) => a.id == achievement.id)) return;

    final updated = [...current, achievement];
    await _saveAchievementsLocal(updated);

    if (isAuthenticated) {
      await _saveAchievementsCloud(updated);
    }
  }

  Future<void> _saveAchievementsLocal(List<Achievement> achievements) async {
    await _prefs?.setString(
      StorageKeys.achievements,
      jsonEncode(achievements.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> _saveAchievementsCloud(List<Achievement> achievements) async {
    try {
      await _firestore.collection('users').doc(currentUserId).set({
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to save achievements to cloud: $e');
    }
  }

  Future<List<Achievement>> _getCloudAchievements() async {
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists && doc.data()?['achievements'] != null) {
        final list = doc.data()!['achievements'] as List;
        return list.map((e) => Achievement.fromJson(e)).toList();
      }
    } catch (e) {
      print('Failed to get cloud achievements: $e');
    }
    return [];
  }

  List<Achievement> _mergeAchievements(
    List<Achievement> local,
    List<Achievement> cloud,
  ) {
    final Map<String, Achievement> merged = {};

    // Add all local achievements
    for (final a in local) {
      merged[a.id] = a;
    }

    // Add cloud achievements (won't override if already exists)
    for (final a in cloud) {
      merged.putIfAbsent(a.id, () => a);
    }

    // Sort by earned date (newest first)
    final list = merged.values.toList()
      ..sort((a, b) => b.earnedAt.compareTo(a.earnedAt));

    return list;
  }

  // ===================
  // STREAK MANAGEMENT
  // ===================

  /// Update streak based on activity
  Future<UserStats> updateStreak() async {
    final stats = await getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already active today
    final alreadyActiveToday = stats.activeDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );

    if (alreadyActiveToday) return stats;

    // Add today to active dates
    final updatedDates = [today, ...stats.activeDates].take(365).toList();

    // Calculate new streak
    int newStreak = 1;
    for (int i = 1; i < updatedDates.length; i++) {
      final diff = updatedDates[i - 1].difference(updatedDates[i]).inDays;
      if (diff == 1) {
        newStreak++;
      } else {
        break;
      }
    }

    final updatedStats = stats.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > stats.longestStreak
          ? newStreak
          : stats.longestStreak,
      lastActiveDate: today,
      activeDates: updatedDates,
    );

    await saveUserStats(updatedStats);
    return updatedStats;
  }

  // ===================
  // FULL SYNC
  // ===================

  /// Sync all data from cloud (useful on app launch/login)
  Future<void> syncFromCloud() async {
    if (!isAuthenticated) return;

    await init();

    try {
      // Sync stats
      final cloudStats = await _getCloudUserStats();
      if (cloudStats != null) {
        final local = await getUserStats();
        final merged = _mergeStats(local, cloudStats);
        await _saveUserStatsLocal(merged);
      }

      // Sync game scores
      final cloudScores = await _getCloudGameScores();
      if (cloudScores != null) {
        final local = await getGameHighScores();
        final merged = _mergeGameScores(local, cloudScores);
        await _saveGameHighScoresLocal(merged);
      }

      // Sync achievements
      final cloudAchievements = await _getCloudAchievements();
      if (cloudAchievements.isNotEmpty) {
        final local = await getAchievements();
        final merged = _mergeAchievements(local, cloudAchievements);
        await _saveAchievementsLocal(merged);
      }

      // Update last sync time
      await _prefs?.setString(
        StorageKeys.lastSyncTime,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Full sync failed: $e');
    }
  }

  /// Push all local data to cloud
  Future<void> pushToCloud() async {
    if (!isAuthenticated) return;

    final stats = await getUserStats();
    final scores = await getGameHighScores();
    final achievements = await getAchievements();

    await _saveUserStatsCloud(stats);
    await _saveGameHighScoresCloud(scores);
    await _saveAchievementsCloud(achievements);
  }
}

/// Provider for DataSyncService
final dataSyncServiceProvider = Provider<DataSyncService>((ref) {
  return DataSyncService();
});

/// Provider for user stats with auto-refresh
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final service = ref.watch(dataSyncServiceProvider);
  return service.getUserStats();
});

/// Provider for game high scores
final gameHighScoresProvider = FutureProvider<GameHighScores>((ref) async {
  final service = ref.watch(dataSyncServiceProvider);
  return service.getGameHighScores();
});

/// Provider for achievements from sync service
final syncedAchievementsProvider = FutureProvider<List<Achievement>>((
  ref,
) async {
  final service = ref.watch(dataSyncServiceProvider);
  return service.getAchievements();
});
