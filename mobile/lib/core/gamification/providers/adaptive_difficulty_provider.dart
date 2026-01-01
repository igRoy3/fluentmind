/// Adaptive Difficulty Engine for FluentMind
/// Automatically adjusts game difficulty based on real user performance

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/game_difficulty_models.dart';

// ===================
// ADAPTIVE DIFFICULTY ENGINE
// ===================

class AdaptiveDifficultyEngine {
  static const String _storageKey = 'adaptive_difficulty_data';

  // Thresholds for automatic difficulty adjustment
  static const double _accuracyUpgradeThreshold = 0.85; // 85% accuracy
  static const double _accuracyDowngradeThreshold = 0.50; // 50% accuracy
  static const int _consistencySessionsRequired = 3;
  static const double _speedBonusThreshold = 0.75; // Complete in 75% of time

  /// Determines recommended difficulty based on performance history
  static GameDifficulty recommendDifficulty({
    required GamePerformanceStats stats,
    required GameDifficulty currentDifficulty,
  }) {
    if (stats.totalPlays < 3) {
      // Not enough data, stick with current
      return currentDifficulty;
    }

    final recentSessions = stats.recentSessions
        .take(5)
        .toList(); // Last 5 sessions
    if (recentSessions.isEmpty) return currentDifficulty;

    // Calculate recent performance metrics
    final avgAccuracy =
        recentSessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
        recentSessions.length;
    final avgCompletionRatio = _calculateCompletionRatio(recentSessions);
    final consistentPerformance = _isConsistentlyPerforming(recentSessions);

    // Check for upgrade conditions
    if (_shouldUpgrade(
      avgAccuracy,
      avgCompletionRatio,
      consistentPerformance,
      currentDifficulty,
    )) {
      return _getNextDifficulty(currentDifficulty);
    }

    // Check for downgrade conditions
    if (_shouldDowngrade(avgAccuracy, recentSessions, currentDifficulty)) {
      return _getPreviousDifficulty(currentDifficulty);
    }

    return currentDifficulty;
  }

  static bool _shouldUpgrade(
    double avgAccuracy,
    double avgCompletionRatio,
    bool consistentPerformance,
    GameDifficulty current,
  ) {
    if (current == GameDifficulty.advanced) return false;

    return avgAccuracy >= _accuracyUpgradeThreshold &&
        avgCompletionRatio <= _speedBonusThreshold &&
        consistentPerformance;
  }

  static bool _shouldDowngrade(
    double avgAccuracy,
    List<GameSession> sessions,
    GameDifficulty current,
  ) {
    if (current == GameDifficulty.beginner) return false;

    // Downgrade if struggling consistently
    final strugglingCount = sessions
        .where((s) => s.accuracy < _accuracyDowngradeThreshold)
        .length;
    return strugglingCount >= 3 || avgAccuracy < _accuracyDowngradeThreshold;
  }

  static double _calculateCompletionRatio(List<GameSession> sessions) {
    if (sessions.isEmpty) return 1.0;
    // This would compare actual time to expected time
    // For now, use a simplified version
    return sessions.first.completionTime.inSeconds / 60.0;
  }

  static bool _isConsistentlyPerforming(List<GameSession> sessions) {
    if (sessions.length < _consistencySessionsRequired) return false;

    final accuracies = sessions.map((s) => s.accuracy).toList();
    final avgAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;

    // Check variance - consistent if all within 15% of average
    return accuracies.every((a) => (a - avgAccuracy).abs() < 0.15);
  }

  static GameDifficulty _getNextDifficulty(GameDifficulty current) {
    switch (current) {
      case GameDifficulty.beginner:
        return GameDifficulty.intermediate;
      case GameDifficulty.intermediate:
        return GameDifficulty.advanced;
      case GameDifficulty.advanced:
        return GameDifficulty.advanced;
    }
  }

  static GameDifficulty _getPreviousDifficulty(GameDifficulty current) {
    switch (current) {
      case GameDifficulty.beginner:
        return GameDifficulty.beginner;
      case GameDifficulty.intermediate:
        return GameDifficulty.beginner;
      case GameDifficulty.advanced:
        return GameDifficulty.intermediate;
    }
  }

  /// Calculates XP with difficulty multiplier
  static int calculateXPWithDifficulty({
    required int baseXP,
    required GameDifficulty difficulty,
    required double accuracy,
    required bool isPerfect,
    required int maxCombo,
    required Duration completionTime,
    required int expectedTimeSeconds,
  }) {
    double xp = baseXP.toDouble();

    // Apply difficulty multiplier
    final settings = _getSettingsForGame('default', difficulty);
    xp *= settings.xpMultiplier;

    // Accuracy bonus
    if (accuracy >= 0.9) {
      xp *= 1.2; // 20% bonus for 90%+ accuracy
    } else if (accuracy >= 0.8) {
      xp *= 1.1; // 10% bonus for 80%+ accuracy
    }

    // Perfect round bonus
    if (isPerfect) {
      xp += settings.perfectRoundBonus;
    }

    // Combo bonus
    if (maxCombo >= 5) {
      xp += (maxCombo - 4) * settings.comboMultiplier * 5;
    }

    // Speed bonus (completed faster than expected)
    final timeRatio = completionTime.inSeconds / expectedTimeSeconds;
    if (timeRatio < 0.7) {
      xp *= 1.15; // 15% bonus for being 30% faster
    } else if (timeRatio < 0.85) {
      xp *= 1.08; // 8% bonus for being 15% faster
    }

    return xp.round();
  }

  static DifficultySettings _getSettingsForGame(
    String gameId,
    GameDifficulty difficulty,
  ) {
    // Default settings if game-specific not found
    return DifficultySettings(
      timeLimitSeconds: 60,
      basePointsPerCorrect: 10,
      penaltyPerWrong: 0,
      xpMultiplier: difficulty == GameDifficulty.beginner
          ? 0.8
          : difficulty == GameDifficulty.intermediate
          ? 1.0
          : 1.5,
    );
  }
}

// ===================
// PERFORMANCE TRACKER PROVIDER
// ===================

class GamePerformanceTracker
    extends StateNotifier<Map<String, GamePerformanceStats>> {
  GamePerformanceTracker() : super({}) {
    _loadData();
  }

  static const _uuid = Uuid();

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AdaptiveDifficultyEngine._storageKey);
    if (data != null) {
      final Map<String, dynamic> decoded = jsonDecode(data);
      final Map<String, GamePerformanceStats> stats = {};

      decoded.forEach((key, value) {
        stats[key] = _parseGameStats(key, value);
      });

      state = stats;
    }
  }

  GamePerformanceStats _parseGameStats(
    String gameId,
    Map<String, dynamic> data,
  ) {
    return GamePerformanceStats(
      gameId: gameId,
      totalPlays: data['totalPlays'] ?? 0,
      bestScore: data['bestScore'] ?? 0,
      totalScore: data['totalScore'] ?? 0,
      avgAccuracy: (data['avgAccuracy'] ?? 0.0).toDouble(),
      avgCompletionTimeSeconds: (data['avgCompletionTimeSeconds'] ?? 0.0)
          .toDouble(),
      longestCombo: data['longestCombo'] ?? 0,
      perfectRounds: data['perfectRounds'] ?? 0,
      lastPlayedAt: data['lastPlayedAt'] != null
          ? DateTime.parse(data['lastPlayedAt'])
          : null,
    );
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};

    state.forEach((key, stats) {
      data[key] = {
        'totalPlays': stats.totalPlays,
        'bestScore': stats.bestScore,
        'totalScore': stats.totalScore,
        'avgAccuracy': stats.avgAccuracy,
        'avgCompletionTimeSeconds': stats.avgCompletionTimeSeconds,
        'longestCombo': stats.longestCombo,
        'perfectRounds': stats.perfectRounds,
        'lastPlayedAt': stats.lastPlayedAt?.toIso8601String(),
      };
    });

    await prefs.setString(
      AdaptiveDifficultyEngine._storageKey,
      jsonEncode(data),
    );
  }

  /// Start a new game session
  GameSession startSession(String gameId, GameDifficulty difficulty) {
    return GameSession(
      id: _uuid.v4(),
      gameId: gameId,
      difficulty: difficulty,
      startedAt: DateTime.now(),
    );
  }

  /// Complete a game session and update stats
  Future<void> completeSession(GameSession session) async {
    final gameId = session.gameId;
    final existing = state[gameId] ?? GamePerformanceStats(gameId: gameId);

    // Update running averages
    final newTotalPlays = existing.totalPlays + 1;
    final newTotalScore = existing.totalScore + session.score;
    final newAvgAccuracy =
        ((existing.avgAccuracy * existing.totalPlays) + session.accuracy) /
        newTotalPlays;
    final newAvgTime =
        ((existing.avgCompletionTimeSeconds * existing.totalPlays) +
            session.completionTime.inSeconds) /
        newTotalPlays;

    // Update best scores
    final newBestScore = session.score > existing.bestScore
        ? session.score
        : existing.bestScore;
    final newLongestCombo = session.maxCombo > existing.longestCombo
        ? session.maxCombo
        : existing.longestCombo;
    final newPerfectRounds =
        existing.perfectRounds + (session.isPerfect ? 1 : 0);

    // Keep last 10 sessions
    final recentSessions = [session, ...existing.recentSessions.take(9)];

    state = {
      ...state,
      gameId: existing.copyWith(
        totalPlays: newTotalPlays,
        bestScore: newBestScore,
        totalScore: newTotalScore,
        avgAccuracy: newAvgAccuracy,
        avgCompletionTimeSeconds: newAvgTime,
        longestCombo: newLongestCombo,
        perfectRounds: newPerfectRounds,
        recentSessions: recentSessions,
        lastPlayedAt: DateTime.now(),
      ),
    };

    await _saveData();
  }

  /// Get recommended difficulty for a game
  GameDifficulty getRecommendedDifficulty(
    String gameId,
    GameDifficulty currentPreference,
  ) {
    final stats = state[gameId];
    if (stats == null) return currentPreference;

    return AdaptiveDifficultyEngine.recommendDifficulty(
      stats: stats,
      currentDifficulty: currentPreference,
    );
  }

  /// Get performance stats for a specific game
  GamePerformanceStats? getGameStats(String gameId) => state[gameId];

  /// Get all game stats
  Map<String, GamePerformanceStats> get allStats => state;

  /// Calculate total XP for a session with difficulty modifiers
  int calculateSessionXP(GameSession session, int expectedTimeSeconds) {
    final baseXP = session.correctAnswers * 10 + session.maxCombo * 2;
    return AdaptiveDifficultyEngine.calculateXPWithDifficulty(
      baseXP: baseXP,
      difficulty: session.difficulty,
      accuracy: session.accuracy,
      isPerfect: session.isPerfect,
      maxCombo: session.maxCombo,
      completionTime: session.completionTime,
      expectedTimeSeconds: expectedTimeSeconds,
    );
  }
}

final gamePerformanceProvider =
    StateNotifierProvider<
      GamePerformanceTracker,
      Map<String, GamePerformanceStats>
    >((ref) {
      return GamePerformanceTracker();
    });

// ===================
// USER DIFFICULTY PREFERENCES
// ===================

class UserDifficultyPreferences
    extends StateNotifier<Map<String, GameDifficulty>> {
  UserDifficultyPreferences() : super({}) {
    _loadPreferences();
  }

  static const String _prefsKey = 'user_difficulty_preferences';

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    if (data != null) {
      final Map<String, dynamic> decoded = jsonDecode(data);
      final Map<String, GameDifficulty> preferences = {};
      decoded.forEach((key, value) {
        preferences[key] = GameDifficulty.values[value as int];
      });
      state = preferences;
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> data = {};
    state.forEach((key, value) {
      data[key] = value.index;
    });
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  /// Set difficulty preference for a game
  Future<void> setDifficulty(String gameId, GameDifficulty difficulty) async {
    state = {...state, gameId: difficulty};
    await _savePreferences();
  }

  /// Get difficulty preference for a game (defaults to intermediate)
  GameDifficulty getDifficulty(String gameId) {
    return state[gameId] ?? GameDifficulty.intermediate;
  }

  /// Set default difficulty for all games
  Future<void> setDefaultDifficulty(GameDifficulty difficulty) async {
    final games = [
      'math_speed',
      'memory_match',
      'word_scramble',
      'logic_sequence',
      'category_sort',
      'pattern_recognition',
      'sentence_builder',
    ];
    for (final game in games) {
      state = {...state, game: difficulty};
    }
    await _savePreferences();
  }
}

final userDifficultyPreferencesProvider =
    StateNotifierProvider<
      UserDifficultyPreferences,
      Map<String, GameDifficulty>
    >((ref) {
      return UserDifficultyPreferences();
    });

// ===================
// CONFIDENCE BUILDER
// ===================

/// Tracks user confidence and provides encouraging feedback
class ConfidenceMetrics {
  final int totalCorrectToday;
  final int currentStreak;
  final int improvementRate; // Percentage improvement from last week
  final List<String> recentMilestones;
  final String encouragingMessage;
  final double confidenceScore; // 0-100

  const ConfidenceMetrics({
    this.totalCorrectToday = 0,
    this.currentStreak = 0,
    this.improvementRate = 0,
    this.recentMilestones = const [],
    this.encouragingMessage = '',
    this.confidenceScore = 50.0,
  });
}

class ConfidenceBuilder {
  static const List<String> _encouragingMessages = [
    "You're getting better every day! 🌟",
    "That's the spirit! Keep going! 💪",
    "Your brain is growing stronger! 🧠",
    "Amazing progress! You should be proud! 🎉",
    "You're on fire today! 🔥",
    "Look at you go! Incredible! ⭐",
    "Every answer makes you smarter! 📚",
    "You're building something great! 🏗️",
    "Champions practice daily - like you! 🏆",
    "Your dedication is inspiring! ✨",
  ];

  static const List<String> _comebackMessages = [
    "Don't worry, mistakes help us learn! 📖",
    "You've got this! Try again! 💪",
    "Every expert was once a beginner! 🌱",
    "Learning takes time - you're doing great! ⏰",
    "One step at a time! You're improving! 👣",
  ];

  static String getEncouragingMessage(double accuracy, int streak) {
    if (accuracy >= 0.8 && streak >= 3) {
      return _encouragingMessages[DateTime.now().second %
          _encouragingMessages.length];
    } else if (accuracy < 0.5) {
      return _comebackMessages[DateTime.now().second %
          _comebackMessages.length];
    } else {
      return _encouragingMessages[DateTime.now().second %
          _encouragingMessages.length];
    }
  }

  static double calculateConfidenceScore({
    required double recentAccuracy,
    required int currentStreak,
    required int totalGamesPlayed,
    required double improvementRate,
  }) {
    double score = 50.0; // Start at neutral

    // Accuracy impact (±20 points)
    score += (recentAccuracy - 0.5) * 40;

    // Streak impact (up to +15 points)
    score += (currentStreak.clamp(0, 15)).toDouble();

    // Experience impact (up to +10 points)
    score += (totalGamesPlayed.clamp(0, 100) / 10);

    // Improvement impact (±5 points)
    score += improvementRate.clamp(-5, 5);

    return score.clamp(0, 100);
  }

  static String getConfidenceLevel(double score) {
    if (score >= 80) return 'Confident Master';
    if (score >= 65) return 'Growing Strong';
    if (score >= 50) return 'Building Momentum';
    if (score >= 35) return 'Finding Your Way';
    return 'Just Getting Started';
  }
}
