import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/gamification_models.dart';

// ===================
// GAMIFICATION STATE
// ===================

class GamificationState {
  final bool isLoading;
  final UserProgress userProgress;
  final List<XPEvent> recentXPEvents;
  final List<Achievement> achievements;
  final Map<String, WordMastery> wordMasteryMap;
  final SessionSummary? lastSessionSummary;
  final String? error;

  // Animation triggers
  final bool showXPAnimation;
  final int pendingXP;
  final bool showLevelUpAnimation;
  final int? newLevel;
  final bool showAchievementAnimation;
  final Achievement? unlockedAchievement;
  final bool showStreakAnimation;
  final List<Achievement> recentlyUnlockedAchievements;

  const GamificationState({
    this.isLoading = false,
    this.userProgress = const UserProgress(),
    this.recentXPEvents = const [],
    this.achievements = const [],
    this.wordMasteryMap = const {},
    this.lastSessionSummary,
    this.error,
    this.showXPAnimation = false,
    this.pendingXP = 0,
    this.showLevelUpAnimation = false,
    this.newLevel,
    this.showAchievementAnimation = false,
    this.unlockedAchievement,
    this.showStreakAnimation = false,
    this.recentlyUnlockedAchievements = const [],
  });

  // Getter for newly unlocked achievements (for UI display)
  List<Achievement> get newAchievements => recentlyUnlockedAchievements;

  GamificationState copyWith({
    bool? isLoading,
    UserProgress? userProgress,
    List<XPEvent>? recentXPEvents,
    List<Achievement>? achievements,
    Map<String, WordMastery>? wordMasteryMap,
    SessionSummary? lastSessionSummary,
    String? error,
    bool? showXPAnimation,
    int? pendingXP,
    bool? showLevelUpAnimation,
    int? newLevel,
    bool? showAchievementAnimation,
    Achievement? unlockedAchievement,
    bool? showStreakAnimation,
    List<Achievement>? recentlyUnlockedAchievements,
    bool clearAnimations = false,
    bool clearLastSession = false,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      userProgress: userProgress ?? this.userProgress,
      recentXPEvents: recentXPEvents ?? this.recentXPEvents,
      achievements: achievements ?? this.achievements,
      wordMasteryMap: wordMasteryMap ?? this.wordMasteryMap,
      lastSessionSummary: clearLastSession
          ? null
          : (lastSessionSummary ?? this.lastSessionSummary),
      error: error,
      showXPAnimation: clearAnimations
          ? false
          : (showXPAnimation ?? this.showXPAnimation),
      pendingXP: clearAnimations ? 0 : (pendingXP ?? this.pendingXP),
      showLevelUpAnimation: clearAnimations
          ? false
          : (showLevelUpAnimation ?? this.showLevelUpAnimation),
      newLevel: clearAnimations ? null : (newLevel ?? this.newLevel),
      showAchievementAnimation: clearAnimations
          ? false
          : (showAchievementAnimation ?? this.showAchievementAnimation),
      unlockedAchievement: clearAnimations
          ? null
          : (unlockedAchievement ?? this.unlockedAchievement),
      showStreakAnimation: clearAnimations
          ? false
          : (showStreakAnimation ?? this.showStreakAnimation),
      recentlyUnlockedAchievements: clearAnimations
          ? const []
          : (recentlyUnlockedAchievements ?? this.recentlyUnlockedAchievements),
    );
  }
}

// ===================
// GAMIFICATION PROVIDER
// ===================

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
      return GamificationNotifier();
    });

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState()) {
    _loadProgress();
  }

  // ===================
  // PERSISTENCE
  // ===================

  Future<void> _loadProgress() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user progress
      final progressJson = prefs.getString('user_progress');
      UserProgress userProgress = const UserProgress();

      if (progressJson != null) {
        final data = jsonDecode(progressJson) as Map<String, dynamic>;
        userProgress = UserProgress(
          totalXP: data['totalXP'] ?? 0,
          level: data['level'] ?? 1,
          levelTitle: data['levelTitle'] ?? 'Beginner',
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
          lastPlayedDate: data['lastPlayedDate'] != null
              ? DateTime.parse(data['lastPlayedDate'])
              : null,
          totalWordsLearned: data['totalWordsLearned'] ?? 0,
          totalWordsMastered: data['totalWordsMastered'] ?? 0,
          totalGamesPlayed: data['totalGamesPlayed'] ?? 0,
          totalCorrectAnswers: data['totalCorrectAnswers'] ?? 0,
          totalAnswers: data['totalAnswers'] ?? 0,
          xpByCategory: Map<String, int>.from(data['xpByCategory'] ?? {}),
          gamesByMode: Map<String, int>.from(data['gamesByMode'] ?? {}),
          unlockedAchievements: List<String>.from(
            data['unlockedAchievements'] ?? [],
          ),
          dailyGoal: _parseDailyGoal(data['dailyGoal']),
          weeklyStats: _parseWeeklyStats(data['weeklyStats']),
        );
      }

      // Check and update streak
      userProgress = _checkAndUpdateStreak(userProgress);

      // Load achievements with progress
      final achievements = _loadAchievementsWithProgress(userProgress);

      // Load word mastery
      final masteryJson = prefs.getString('word_mastery');
      Map<String, WordMastery> wordMasteryMap = {};
      if (masteryJson != null) {
        final data = jsonDecode(masteryJson) as Map<String, dynamic>;
        data.forEach((key, value) {
          wordMasteryMap[key] = WordMastery(
            word: value['word'],
            level: MasteryLevel.values[value['level'] ?? 0],
            timesCorrect: value['timesCorrect'] ?? 0,
            timesSeen: value['timesSeen'] ?? 0,
            consecutiveCorrect: value['consecutiveCorrect'] ?? 0,
            lastReviewed: DateTime.parse(value['lastReviewed']),
            nextReview: DateTime.parse(value['nextReview']),
            accuracy: (value['accuracy'] ?? 0).toDouble(),
          );
        });
      }

      state = state.copyWith(
        isLoading: false,
        userProgress: userProgress,
        achievements: achievements,
        wordMasteryMap: wordMasteryMap,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load progress: $e',
      );
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progress = state.userProgress;

      final progressData = {
        'totalXP': progress.totalXP,
        'level': progress.level,
        'levelTitle': progress.levelTitle,
        'currentStreak': progress.currentStreak,
        'longestStreak': progress.longestStreak,
        'lastPlayedDate': progress.lastPlayedDate?.toIso8601String(),
        'totalWordsLearned': progress.totalWordsLearned,
        'totalWordsMastered': progress.totalWordsMastered,
        'totalGamesPlayed': progress.totalGamesPlayed,
        'totalCorrectAnswers': progress.totalCorrectAnswers,
        'totalAnswers': progress.totalAnswers,
        'xpByCategory': progress.xpByCategory,
        'gamesByMode': progress.gamesByMode,
        'unlockedAchievements': progress.unlockedAchievements,
        'dailyGoal': {
          'targetXP': progress.dailyGoal.targetXP,
          'earnedXP': progress.dailyGoal.earnedXP,
          'targetWords': progress.dailyGoal.targetWords,
          'learnedWords': progress.dailyGoal.learnedWords,
          'targetGames': progress.dailyGoal.targetGames,
          'playedGames': progress.dailyGoal.playedGames,
          'date': progress.dailyGoal.date?.toIso8601String(),
          'isComplete': progress.dailyGoal.isComplete,
        },
        'weeklyStats': {
          'dailyXP': progress.weeklyStats.dailyXP,
          'dailyGames': progress.weeklyStats.dailyGames,
          'weeklyXPTotal': progress.weeklyStats.weeklyXPTotal,
          'weeklyGamesTotal': progress.weeklyStats.weeklyGamesTotal,
          'avgAccuracy': progress.weeklyStats.avgAccuracy,
          'strongestSkill': progress.weeklyStats.strongestSkill,
          'weakestSkill': progress.weeklyStats.weakestSkill,
        },
      };

      await prefs.setString('user_progress', jsonEncode(progressData));

      // Save word mastery
      final masteryData = <String, dynamic>{};
      state.wordMasteryMap.forEach((key, value) {
        masteryData[key] = {
          'word': value.word,
          'level': value.level.index,
          'timesCorrect': value.timesCorrect,
          'timesSeen': value.timesSeen,
          'consecutiveCorrect': value.consecutiveCorrect,
          'lastReviewed': value.lastReviewed.toIso8601String(),
          'nextReview': value.nextReview.toIso8601String(),
          'accuracy': value.accuracy,
        };
      });
      await prefs.setString('word_mastery', jsonEncode(masteryData));
    } catch (e) {
      // Handle save error silently
    }
  }

  DailyGoal _parseDailyGoal(Map<String, dynamic>? data) {
    if (data == null) return const DailyGoal();
    return DailyGoal(
      targetXP: data['targetXP'] ?? 100,
      earnedXP: data['earnedXP'] ?? 0,
      targetWords: data['targetWords'] ?? 10,
      learnedWords: data['learnedWords'] ?? 0,
      targetGames: data['targetGames'] ?? 3,
      playedGames: data['playedGames'] ?? 0,
      date: data['date'] != null ? DateTime.parse(data['date']) : null,
      isComplete: data['isComplete'] ?? false,
    );
  }

  WeeklyStats _parseWeeklyStats(Map<String, dynamic>? data) {
    if (data == null) return const WeeklyStats();
    return WeeklyStats(
      dailyXP: List<int>.from(data['dailyXP'] ?? [0, 0, 0, 0, 0, 0, 0]),
      dailyGames: List<int>.from(data['dailyGames'] ?? [0, 0, 0, 0, 0, 0, 0]),
      weeklyXPTotal: data['weeklyXPTotal'] ?? 0,
      weeklyGamesTotal: data['weeklyGamesTotal'] ?? 0,
      avgAccuracy: (data['avgAccuracy'] ?? 0).toDouble(),
      strongestSkill: data['strongestSkill'] ?? '',
      weakestSkill: data['weakestSkill'] ?? '',
    );
  }

  UserProgress _checkAndUpdateStreak(UserProgress progress) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (progress.lastPlayedDate == null) {
      return progress;
    }

    final lastPlayed = DateTime(
      progress.lastPlayedDate!.year,
      progress.lastPlayedDate!.month,
      progress.lastPlayedDate!.day,
    );

    final daysSinceLastPlay = today.difference(lastPlayed).inDays;

    if (daysSinceLastPlay > 1) {
      // Streak broken
      return progress.copyWith(currentStreak: 0);
    }

    return progress;
  }

  List<Achievement> _loadAchievementsWithProgress(UserProgress progress) {
    return Achievements.all.map((achievement) {
      final isUnlocked = progress.unlockedAchievements.contains(achievement.id);
      int currentValue = 0;

      // Calculate current value based on achievement type
      switch (achievement.id) {
        case 'streak_3':
        case 'streak_7':
        case 'streak_30':
        case 'streak_100':
          currentValue = progress.currentStreak;
          break;
        case 'xp_100':
        case 'xp_1000':
        case 'xp_5000':
        case 'xp_10000':
          currentValue = progress.totalXP;
          break;
        case 'games_10':
        case 'games_50':
        case 'games_100':
          currentValue = progress.totalGamesPlayed;
          break;
        case 'words_10':
        case 'words_50':
          currentValue = progress.totalWordsLearned;
          break;
        case 'words_mastered_10':
        case 'words_mastered_50':
          currentValue = progress.totalWordsMastered;
          break;
        case 'first_game':
          currentValue = progress.totalGamesPlayed > 0 ? 1 : 0;
          break;
        case 'level_10':
          currentValue = progress.level;
          break;
        case 'all_modes':
          currentValue = progress.gamesByMode.length;
          break;
        default:
          currentValue = 0;
      }

      final progressValue = achievement.targetValue > 0
          ? (currentValue / achievement.targetValue).clamp(0.0, 1.0)
          : 0.0;

      return achievement.copyWith(
        unlockedAt: isUnlocked ? DateTime.now() : null,
        progress: progressValue,
        currentValue: currentValue,
      );
    }).toList();
  }

  // ===================
  // XP MANAGEMENT
  // ===================

  void awardXP(int amount, XPEventType type, String description) {
    if (amount == 0) return;

    final now = DateTime.now();
    final oldLevel = state.userProgress.level;
    final newTotalXP = state.userProgress.totalXP + amount;
    final newLevel = LevelSystem.getLevelForXP(newTotalXP);
    final leveledUp = newLevel > oldLevel;

    // Create XP event
    final event = XPEvent(
      type: type,
      amount: amount,
      description: description,
      timestamp: now,
    );

    // Update daily goal
    final dailyGoal = _updateDailyGoal(
      state.userProgress.dailyGoal,
      xpEarned: amount,
    );

    // Update weekly stats
    final weeklyStats = _updateWeeklyStats(
      state.userProgress.weeklyStats,
      xpEarned: amount,
    );

    // Update user progress
    final newProgress = state.userProgress.copyWith(
      totalXP: newTotalXP,
      level: newLevel,
      levelTitle: LevelSystem.getTitleForLevel(newLevel),
      dailyGoal: dailyGoal,
      weeklyStats: weeklyStats,
    );

    state = state.copyWith(
      userProgress: newProgress,
      recentXPEvents: [event, ...state.recentXPEvents.take(49)],
      showXPAnimation: true,
      pendingXP: amount,
      showLevelUpAnimation: leveledUp,
      newLevel: leveledUp ? newLevel : null,
    );

    // Check for achievements
    _checkAchievements();

    _saveProgress();
  }

  void clearXPAnimation() {
    state = state.copyWith(showXPAnimation: false, pendingXP: 0);
  }

  void clearLevelUpAnimation() {
    state = state.copyWith(showLevelUpAnimation: false, newLevel: null);
  }

  void clearAchievementAnimation() {
    state = state.copyWith(
      showAchievementAnimation: false,
      unlockedAchievement: null,
    );
  }

  void clearAllAnimations() {
    state = state.copyWith(clearAnimations: true);
  }

  // ===================
  // STREAK MANAGEMENT
  // ===================

  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayed = state.userProgress.lastPlayedDate;

    bool isNewDay = true;
    int newStreak = state.userProgress.currentStreak;
    bool showAnimation = false;

    if (lastPlayed != null) {
      final lastPlayedDate = DateTime(
        lastPlayed.year,
        lastPlayed.month,
        lastPlayed.day,
      );
      final daysSinceLastPlay = today.difference(lastPlayedDate).inDays;

      if (daysSinceLastPlay == 0) {
        // Same day, no streak change
        isNewDay = false;
      } else if (daysSinceLastPlay == 1) {
        // Consecutive day, increment streak
        newStreak = state.userProgress.currentStreak + 1;
        showAnimation = true;

        // Award streak bonus
        if (newStreak == 3) {
          awardXP(
            XPRewards.streakBonus3Days,
            XPEventType.streakBonus,
            '3-day streak bonus!',
          );
        } else if (newStreak == 7) {
          awardXP(
            XPRewards.streakBonus7Days,
            XPEventType.streakBonus,
            '7-day streak bonus!',
          );
        } else if (newStreak == 30) {
          awardXP(
            XPRewards.streakBonus30Days,
            XPEventType.streakBonus,
            '30-day streak bonus!',
          );
        }
      } else {
        // Streak broken, start fresh
        newStreak = 1;
      }
    } else {
      // First time playing
      newStreak = 1;
      showAnimation = true;
    }

    final longestStreak = newStreak > state.userProgress.longestStreak
        ? newStreak
        : state.userProgress.longestStreak;

    // Award first game of day bonus
    if (isNewDay) {
      awardXP(
        XPRewards.firstGameOfDay,
        XPEventType.firstGameOfDay,
        'First game of the day!',
      );
    }

    state = state.copyWith(
      userProgress: state.userProgress.copyWith(
        currentStreak: newStreak,
        longestStreak: longestStreak,
        lastPlayedDate: now,
      ),
      showStreakAnimation: showAnimation,
    );

    _checkAchievements();
    _saveProgress();
  }

  void clearStreakAnimation() {
    state = state.copyWith(showStreakAnimation: false);
  }

  // ===================
  // GAME COMPLETION
  // ===================

  void completeGame({
    required String mode,
    required int questionsAnswered,
    required int correctAnswers,
    required int comboMax,
    required Duration duration,
    required List<String> wordsLearned,
    required List<String> weakWords,
  }) {
    final accuracy = questionsAnswered > 0
        ? correctAnswers / questionsAnswered
        : 0.0;
    final isPerfect = accuracy >= 1.0;
    final wrongAnswers = questionsAnswered - correctAnswers;

    // Calculate total XP earned
    int totalXP = 0;

    // Base XP for correct answers
    totalXP += correctAnswers * XPRewards.correctAnswer;

    // Combo bonuses
    if (comboMax >= 5) {
      totalXP += (comboMax - 4) * XPRewards.comboBonus;
    }

    // Perfect round bonus
    if (isPerfect && questionsAnswered >= 5) {
      totalXP += XPRewards.perfectRound;
    }

    // No mistakes bonus
    if (wrongAnswers == 0 && questionsAnswered >= 3) {
      totalXP += XPRewards.noMistakesBonus;
    }

    // Daily challenge bonus
    if (mode == 'dailyChallenge') {
      totalXP += XPRewards.dailyChallengeComplete;
    }

    // Award the XP
    awardXP(totalXP, XPEventType.correctAnswer, 'Game completed: $mode');

    // Update game stats
    final gamesByMode = Map<String, int>.from(state.userProgress.gamesByMode);
    gamesByMode[mode] = (gamesByMode[mode] ?? 0) + 1;

    final dailyGoal = _updateDailyGoal(
      state.userProgress.dailyGoal,
      gamesPlayed: 1,
      wordsLearned: wordsLearned.length,
    );

    final weeklyStats = _updateWeeklyStats(
      state.userProgress.weeklyStats,
      gamesPlayed: 1,
      accuracy: accuracy,
    );

    // Update mastery for learned words
    final masteryMap = Map<String, WordMastery>.from(state.wordMasteryMap);
    int newMastered = 0;

    for (final word in wordsLearned) {
      final existing = masteryMap[word];
      if (existing != null) {
        final newMastery = _updateWordMastery(existing, true);
        masteryMap[word] = newMastery;
        if (newMastery.level == MasteryLevel.mastered &&
            existing.level != MasteryLevel.mastered) {
          newMastered++;
        }
      } else {
        masteryMap[word] = WordMastery(
          word: word,
          level: MasteryLevel.learning,
          timesCorrect: 1,
          timesSeen: 1,
          consecutiveCorrect: 1,
          lastReviewed: DateTime.now(),
          nextReview: DateTime.now().add(const Duration(hours: 4)),
          accuracy: 1.0,
        );
      }
    }

    // Update mastery for weak words
    for (final word in weakWords) {
      final existing = masteryMap[word];
      if (existing != null) {
        masteryMap[word] = _updateWordMastery(existing, false);
      }
    }

    // Generate feedback
    final feedback = SessionFeedback.generate(
      accuracy: accuracy,
      combo: comboMax,
      streak: state.userProgress.currentStreak,
      weakWords: weakWords,
      gameMode: mode,
    );

    // Check for new level
    final oldLevel = state.userProgress.level;
    final newLevel = LevelSystem.getLevelForXP(state.userProgress.totalXP);
    final leveledUp = newLevel > oldLevel;

    // Check for newly unlocked achievements
    final newAchievements = _getNewlyUnlockedAchievements();

    // Create session summary
    final summary = SessionSummary(
      totalXPEarned: totalXP,
      questionsAnswered: questionsAnswered,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      accuracy: accuracy,
      comboMax: comboMax,
      duration: duration,
      wordsLearned: wordsLearned,
      wordsMastered: masteryMap.entries
          .where((e) => e.value.level == MasteryLevel.mastered)
          .map((e) => e.key)
          .take(5)
          .toList(),
      weakWords: weakWords,
      isPerfect: isPerfect,
      leveledUp: leveledUp,
      newLevel: leveledUp ? newLevel : null,
      newAchievements: newAchievements,
      feedback: feedback,
    );

    state = state.copyWith(
      userProgress: state.userProgress.copyWith(
        totalGamesPlayed: state.userProgress.totalGamesPlayed + 1,
        totalCorrectAnswers:
            state.userProgress.totalCorrectAnswers + correctAnswers,
        totalAnswers: state.userProgress.totalAnswers + questionsAnswered,
        totalWordsLearned:
            state.userProgress.totalWordsLearned + wordsLearned.length,
        totalWordsMastered: state.userProgress.totalWordsMastered + newMastered,
        gamesByMode: gamesByMode,
        dailyGoal: dailyGoal,
        weeklyStats: weeklyStats,
      ),
      wordMasteryMap: masteryMap,
      lastSessionSummary: summary,
    );

    // Update streak
    updateStreak();

    _checkAchievements();
    _saveProgress();
  }

  WordMastery _updateWordMastery(WordMastery existing, bool correct) {
    final now = DateTime.now();
    final newTimesCorrect = correct
        ? existing.timesCorrect + 1
        : existing.timesCorrect;
    final newTimesSeen = existing.timesSeen + 1;
    final newConsecutive = correct ? existing.consecutiveCorrect + 1 : 0;
    final newAccuracy = newTimesSeen > 0 ? newTimesCorrect / newTimesSeen : 0.0;

    final newLevel = WordMastery.calculateLevel(
      newTimesCorrect,
      newTimesSeen,
      newAccuracy,
    );

    // Calculate next review based on spaced repetition
    Duration nextReviewInterval;
    if (correct) {
      switch (newConsecutive) {
        case 1:
          nextReviewInterval = const Duration(hours: 4);
          break;
        case 2:
          nextReviewInterval = const Duration(hours: 12);
          break;
        case 3:
          nextReviewInterval = const Duration(days: 1);
          break;
        case 4:
          nextReviewInterval = const Duration(days: 3);
          break;
        default:
          nextReviewInterval = const Duration(days: 7);
      }
    } else {
      nextReviewInterval = const Duration(hours: 1);
    }

    return existing.copyWith(
      level: newLevel,
      timesCorrect: newTimesCorrect,
      timesSeen: newTimesSeen,
      consecutiveCorrect: newConsecutive,
      lastReviewed: now,
      nextReview: now.add(nextReviewInterval),
      accuracy: newAccuracy,
    );
  }

  DailyGoal _updateDailyGoal(
    DailyGoal current, {
    int xpEarned = 0,
    int gamesPlayed = 0,
    int wordsLearned = 0,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Reset if it's a new day
    if (current.date == null || !_isSameDay(current.date!, today)) {
      return DailyGoal(
        targetXP: current.targetXP,
        earnedXP: xpEarned,
        targetWords: current.targetWords,
        learnedWords: wordsLearned,
        targetGames: current.targetGames,
        playedGames: gamesPlayed,
        date: today,
        isComplete: false,
      );
    }

    final newEarnedXP = current.earnedXP + xpEarned;
    final newLearnedWords = current.learnedWords + wordsLearned;
    final newPlayedGames = current.playedGames + gamesPlayed;

    final isComplete =
        newEarnedXP >= current.targetXP &&
        newLearnedWords >= current.targetWords &&
        newPlayedGames >= current.targetGames;

    return current.copyWith(
      earnedXP: newEarnedXP,
      learnedWords: newLearnedWords,
      playedGames: newPlayedGames,
      isComplete: isComplete,
    );
  }

  WeeklyStats _updateWeeklyStats(
    WeeklyStats current, {
    int xpEarned = 0,
    int gamesPlayed = 0,
    double accuracy = 0,
  }) {
    final now = DateTime.now();
    final dayIndex = now.weekday - 1; // 0 = Monday

    final newDailyXP = List<int>.from(current.dailyXP);
    newDailyXP[dayIndex] = newDailyXP[dayIndex] + xpEarned;

    final newDailyGames = List<int>.from(current.dailyGames);
    newDailyGames[dayIndex] = newDailyGames[dayIndex] + gamesPlayed;

    final weeklyXPTotal = newDailyXP.reduce((a, b) => a + b);
    final weeklyGamesTotal = newDailyGames.reduce((a, b) => a + b);

    // Calculate average accuracy (simplified)
    final newAvgAccuracy = gamesPlayed > 0
        ? (current.avgAccuracy * current.weeklyGamesTotal + accuracy) /
              (current.weeklyGamesTotal + gamesPlayed)
        : current.avgAccuracy;

    return current.copyWith(
      dailyXP: newDailyXP,
      dailyGames: newDailyGames,
      weeklyXPTotal: weeklyXPTotal,
      weeklyGamesTotal: weeklyGamesTotal,
      avgAccuracy: newAvgAccuracy,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ===================
  // ACHIEVEMENTS
  // ===================

  void _checkAchievements() {
    final progress = state.userProgress;
    final updatedAchievements = <Achievement>[];
    Achievement? newlyUnlocked;

    for (final achievement in state.achievements) {
      if (achievement.isUnlocked) {
        updatedAchievements.add(achievement);
        continue;
      }

      int currentValue = 0;

      switch (achievement.id) {
        case 'streak_3':
        case 'streak_7':
        case 'streak_30':
        case 'streak_100':
          currentValue = progress.currentStreak;
          break;
        case 'xp_100':
        case 'xp_1000':
        case 'xp_5000':
        case 'xp_10000':
          currentValue = progress.totalXP;
          break;
        case 'games_10':
        case 'games_50':
        case 'games_100':
          currentValue = progress.totalGamesPlayed;
          break;
        case 'words_10':
        case 'words_50':
          currentValue = progress.totalWordsLearned;
          break;
        case 'words_mastered_10':
        case 'words_mastered_50':
          currentValue = progress.totalWordsMastered;
          break;
        case 'first_game':
          currentValue = progress.totalGamesPlayed > 0 ? 1 : 0;
          break;
        case 'level_10':
          currentValue = progress.level;
          break;
        case 'all_modes':
          currentValue = progress.gamesByMode.length;
          break;
        case 'perfect_game':
          currentValue = state.lastSessionSummary?.isPerfect == true ? 1 : 0;
          break;
        case 'combo_10':
        case 'combo_25':
          currentValue = state.lastSessionSummary?.comboMax ?? 0;
          break;
        default:
          currentValue = 0;
      }

      final progressValue = achievement.targetValue > 0
          ? (currentValue / achievement.targetValue).clamp(0.0, 1.0)
          : 0.0;

      if (currentValue >= achievement.targetValue && !achievement.isUnlocked) {
        // Achievement unlocked!
        final unlockedAchievement = achievement.copyWith(
          unlockedAt: DateTime.now(),
          progress: 1.0,
          currentValue: currentValue,
        );
        updatedAchievements.add(unlockedAchievement);
        newlyUnlocked = unlockedAchievement;

        // Award XP for achievement
        awardXP(
          achievement.xpReward,
          XPEventType.achievementUnlocked,
          'Achievement: ${achievement.name}',
        );

        // Update unlocked achievements list
        state = state.copyWith(
          userProgress: state.userProgress.copyWith(
            unlockedAchievements: [
              ...state.userProgress.unlockedAchievements,
              achievement.id,
            ],
          ),
        );
      } else {
        updatedAchievements.add(
          achievement.copyWith(
            progress: progressValue,
            currentValue: currentValue,
          ),
        );
      }
    }

    state = state.copyWith(
      achievements: updatedAchievements,
      showAchievementAnimation: newlyUnlocked != null,
      unlockedAchievement: newlyUnlocked,
    );
  }

  List<Achievement> _getNewlyUnlockedAchievements() {
    return state.achievements
        .where(
          (a) =>
              a.isUnlocked &&
              a.unlockedAt != null &&
              DateTime.now().difference(a.unlockedAt!).inMinutes < 1,
        )
        .toList();
  }

  // ===================
  // GETTERS
  // ===================

  List<Achievement> get unlockedAchievements =>
      state.achievements.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements =>
      state.achievements.where((a) => !a.isUnlocked && !a.isSecret).toList();

  List<WordMastery> get masteredWords => state.wordMasteryMap.values
      .where((w) => w.level == MasteryLevel.mastered)
      .toList();

  List<WordMastery> get wordsToReview {
    final now = DateTime.now();
    return state.wordMasteryMap.values
        .where((w) => w.nextReview.isBefore(now))
        .toList()
      ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
  }

  // ===================
  // DAILY GOAL MANAGEMENT
  // ===================

  void setDailyGoal({int? targetXP, int? targetWords, int? targetGames}) {
    state = state.copyWith(
      userProgress: state.userProgress.copyWith(
        dailyGoal: state.userProgress.dailyGoal.copyWith(
          targetXP: targetXP,
          targetWords: targetWords,
          targetGames: targetGames,
        ),
      ),
    );
    _saveProgress();
  }
}
