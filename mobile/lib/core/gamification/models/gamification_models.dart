/// Gamification Models for FluentMind
/// Includes XP, Levels, Streaks, Achievements, and Progress Tracking
library;

// ===================
// XP & LEVELING SYSTEM
// ===================

/// XP rewards for different actions
class XPRewards {
  static const int correctAnswer = 10;
  static const int perfectRound = 25;
  static const int dailyChallengeComplete = 50;
  static const int streakBonus3Days = 30;
  static const int streakBonus7Days = 75;
  static const int streakBonus30Days = 200;
  static const int firstGameOfDay = 15;
  static const int fastAnswer = 5; // Bonus for quick answers
  static const int noMistakesBonus = 20;
  static const int comboBonus = 5; // Per consecutive correct
  static const int wordMastered = 30;
  static const int levelUp = 100;

  // Penalties (reduced XP, never negative)
  static const int repeatedMistake = -3;
  static const int hintUsed = -2;
}

/// Level thresholds and titles
class LevelSystem {
  static const List<int> xpThresholds = [
    0, // Level 1
    100, // Level 2
    250, // Level 3
    500, // Level 4
    850, // Level 5
    1300, // Level 6
    1900, // Level 7
    2700, // Level 8
    3700, // Level 9
    5000, // Level 10
    6500, // Level 11
    8500, // Level 12
    11000, // Level 13
    14000, // Level 14
    18000, // Level 15
    23000, // Level 16
    29000, // Level 17
    36000, // Level 18
    45000, // Level 19
    55000, // Level 20
  ];

  static const List<String> levelTitles = [
    'Beginner', // 1
    'Novice', // 2
    'Learner', // 3
    'Student', // 4
    'Explorer', // 5
    'Practitioner', // 6
    'Achiever', // 7
    'Skilled', // 8
    'Advanced', // 9
    'Expert', // 10
    'Master', // 11
    'Champion', // 12
    'Virtuoso', // 13
    'Sage', // 14
    'Scholar', // 15
    'Luminary', // 16
    'Prodigy', // 17
    'Genius', // 18
    'Legend', // 19
    'Grandmaster', // 20
  ];

  // Alias for convenience
  static List<String> get titles => levelTitles;

  static int getLevelForXP(int xp) {
    for (int i = xpThresholds.length - 1; i >= 0; i--) {
      if (xp >= xpThresholds[i]) return i + 1;
    }
    return 1;
  }

  static String getTitleForLevel(int level) {
    if (level < 1) return levelTitles[0];
    if (level > levelTitles.length) return levelTitles.last;
    return levelTitles[level - 1];
  }

  static int getXPForNextLevel(int currentLevel) {
    if (currentLevel >= xpThresholds.length) return xpThresholds.last;
    return xpThresholds[currentLevel];
  }

  static double getLevelProgress(int xp) {
    final level = getLevelForXP(xp);
    if (level >= xpThresholds.length) return 1.0;

    final currentLevelXP = xpThresholds[level - 1];
    final nextLevelXP = xpThresholds[level];
    final progress = (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }
}

// ===================
// USER PROGRESS
// ===================

class UserProgress {
  final int totalXP;
  final int level;
  final String levelTitle;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPlayedDate;
  final int totalWordsLearned;
  final int totalWordsMastered;
  final int totalGamesPlayed;
  final int totalCorrectAnswers;
  final int totalAnswers;
  final Map<String, int> xpByCategory;
  final Map<String, int> gamesByMode;
  final List<String> unlockedAchievements;
  final DailyGoal dailyGoal;
  final WeeklyStats weeklyStats;

  const UserProgress({
    this.totalXP = 0,
    this.level = 1,
    this.levelTitle = 'Beginner',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPlayedDate,
    this.totalWordsLearned = 0,
    this.totalWordsMastered = 0,
    this.totalGamesPlayed = 0,
    this.totalCorrectAnswers = 0,
    this.totalAnswers = 0,
    this.xpByCategory = const {},
    this.gamesByMode = const {},
    this.unlockedAchievements = const [],
    this.dailyGoal = const DailyGoal(),
    this.weeklyStats = const WeeklyStats(),
  });

  double get accuracy =>
      totalAnswers > 0 ? totalCorrectAnswers / totalAnswers : 0;

  // Computed properties for UI
  int get currentLevelXP {
    final prevLevelXP = level > 1 ? LevelSystem.xpThresholds[level - 1] : 0;
    return totalXP - prevLevelXP;
  }

  int get xpToNextLevel {
    if (level >= LevelSystem.xpThresholds.length) return 0;
    final currentThreshold = LevelSystem.xpThresholds[level - 1];
    final nextThreshold = LevelSystem.xpThresholds[level];
    return nextThreshold - currentThreshold;
  }

  double get levelProgress {
    if (xpToNextLevel == 0) return 1.0;
    return (currentLevelXP / xpToNextLevel).clamp(0.0, 1.0);
  }

  double get averageAccuracy => accuracy;

  UserProgress copyWith({
    int? totalXP,
    int? level,
    String? levelTitle,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPlayedDate,
    int? totalWordsLearned,
    int? totalWordsMastered,
    int? totalGamesPlayed,
    int? totalCorrectAnswers,
    int? totalAnswers,
    Map<String, int>? xpByCategory,
    Map<String, int>? gamesByMode,
    List<String>? unlockedAchievements,
    DailyGoal? dailyGoal,
    WeeklyStats? weeklyStats,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      totalWordsMastered: totalWordsMastered ?? this.totalWordsMastered,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      xpByCategory: xpByCategory ?? this.xpByCategory,
      gamesByMode: gamesByMode ?? this.gamesByMode,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      weeklyStats: weeklyStats ?? this.weeklyStats,
    );
  }
}

// ===================
// DAILY GOALS
// ===================

class DailyGoal {
  final int targetXP;
  final int earnedXP;
  final int targetWords;
  final int learnedWords;
  final int targetGames;
  final int playedGames;
  final DateTime? date;
  final bool isComplete;

  const DailyGoal({
    this.targetXP = 100,
    this.earnedXP = 0,
    this.targetWords = 10,
    this.learnedWords = 0,
    this.targetGames = 3,
    this.playedGames = 0,
    this.date,
    this.isComplete = false,
  });

  // Aliases for UI compatibility
  int get xpTarget => targetXP;
  int get xpEarned => earnedXP;
  int get wordsTarget => targetWords;
  int get gamesTarget => targetGames;
  int get gamesPlayed => playedGames;
  bool get isCompleted => isComplete || overallProgress >= 1.0;

  double get xpProgress =>
      targetXP > 0 ? (earnedXP / targetXP).clamp(0.0, 1.0) : 0;
  double get wordsProgress =>
      targetWords > 0 ? (learnedWords / targetWords).clamp(0.0, 1.0) : 0;
  double get gamesProgress =>
      targetGames > 0 ? (playedGames / targetGames).clamp(0.0, 1.0) : 0;
  double get overallProgress =>
      (xpProgress + wordsProgress + gamesProgress) / 3;

  DailyGoal copyWith({
    int? targetXP,
    int? earnedXP,
    int? targetWords,
    int? learnedWords,
    int? targetGames,
    int? playedGames,
    DateTime? date,
    bool? isComplete,
  }) {
    return DailyGoal(
      targetXP: targetXP ?? this.targetXP,
      earnedXP: earnedXP ?? this.earnedXP,
      targetWords: targetWords ?? this.targetWords,
      learnedWords: learnedWords ?? this.learnedWords,
      targetGames: targetGames ?? this.targetGames,
      playedGames: playedGames ?? this.playedGames,
      date: date ?? this.date,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

// ===================
// WEEKLY STATS
// ===================

class WeeklyStats {
  final List<int> dailyXP; // Last 7 days
  final List<int> dailyGames;
  final int weeklyXPTotal;
  final int weeklyGamesTotal;
  final double avgAccuracy;
  final String strongestSkill;
  final String weakestSkill;

  const WeeklyStats({
    this.dailyXP = const [0, 0, 0, 0, 0, 0, 0],
    this.dailyGames = const [0, 0, 0, 0, 0, 0, 0],
    this.weeklyXPTotal = 0,
    this.weeklyGamesTotal = 0,
    this.avgAccuracy = 0,
    this.strongestSkill = '',
    this.weakestSkill = '',
  });

  // Aliases for UI compatibility
  int get totalXP => weeklyXPTotal;
  int get gamesPlayed => weeklyGamesTotal;

  /// Returns a list of booleans indicating completion for each day
  List<bool> get dailyCompletion => dailyGames.map((g) => g > 0).toList();

  WeeklyStats copyWith({
    List<int>? dailyXP,
    List<int>? dailyGames,
    int? weeklyXPTotal,
    int? weeklyGamesTotal,
    double? avgAccuracy,
    String? strongestSkill,
    String? weakestSkill,
  }) {
    return WeeklyStats(
      dailyXP: dailyXP ?? this.dailyXP,
      dailyGames: dailyGames ?? this.dailyGames,
      weeklyXPTotal: weeklyXPTotal ?? this.weeklyXPTotal,
      weeklyGamesTotal: weeklyGamesTotal ?? this.weeklyGamesTotal,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      strongestSkill: strongestSkill ?? this.strongestSkill,
      weakestSkill: weakestSkill ?? this.weakestSkill,
    );
  }
}

// ===================
// WORD MASTERY
// ===================

enum MasteryLevel {
  newWord, // Just introduced
  learning, // Seen 1-3 times
  familiar, // 4-7 correct answers
  strong, // 8-12 correct answers
  mastered, // 13+ correct, high accuracy
}

class WordMastery {
  final String word;
  final MasteryLevel level;
  final int timesCorrect;
  final int timesSeen;
  final int consecutiveCorrect;
  final DateTime lastReviewed;
  final DateTime nextReview;
  final double accuracy;

  const WordMastery({
    required this.word,
    this.level = MasteryLevel.newWord,
    this.timesCorrect = 0,
    this.timesSeen = 0,
    this.consecutiveCorrect = 0,
    required this.lastReviewed,
    required this.nextReview,
    this.accuracy = 0,
  });

  static MasteryLevel calculateLevel(int correct, int seen, double accuracy) {
    if (correct >= 13 && accuracy >= 0.9) return MasteryLevel.mastered;
    if (correct >= 8 && accuracy >= 0.75) return MasteryLevel.strong;
    if (correct >= 4) return MasteryLevel.familiar;
    if (seen >= 1) return MasteryLevel.learning;
    return MasteryLevel.newWord;
  }

  WordMastery copyWith({
    String? word,
    MasteryLevel? level,
    int? timesCorrect,
    int? timesSeen,
    int? consecutiveCorrect,
    DateTime? lastReviewed,
    DateTime? nextReview,
    double? accuracy,
  }) {
    return WordMastery(
      word: word ?? this.word,
      level: level ?? this.level,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesSeen: timesSeen ?? this.timesSeen,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

// ===================
// XP EVENTS
// ===================

enum XPEventType {
  correctAnswer,
  wrongAnswer,
  perfectRound,
  dailyChallenge,
  streakBonus,
  firstGameOfDay,
  fastAnswer,
  comboBonus,
  wordMastered,
  levelUp,
  achievementUnlocked,
}

class XPEvent {
  final XPEventType type;
  final int amount;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const XPEvent({
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}

// ===================
// SESSION SUMMARY
// ===================

class SessionSummary {
  final int totalXPEarned;
  final int questionsAnswered;
  final int correctAnswers;
  final int wrongAnswers;
  final double accuracy;
  final int comboMax;
  final Duration duration;
  final List<String> wordsLearned;
  final List<String> wordsMastered;
  final List<String> weakWords;
  final bool isPerfect;
  final bool leveledUp;
  final int? newLevel;
  final List<Achievement> newAchievements;
  final SessionFeedback feedback;

  const SessionSummary({
    required this.totalXPEarned,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.accuracy,
    required this.comboMax,
    required this.duration,
    this.wordsLearned = const [],
    this.wordsMastered = const [],
    this.weakWords = const [],
    this.isPerfect = false,
    this.leveledUp = false,
    this.newLevel,
    this.newAchievements = const [],
    required this.feedback,
  });
}

// ===================
// SESSION FEEDBACK
// ===================

class SessionFeedback {
  final String title;
  final String subtitle;
  final String encouragement;
  final List<String> strengths;
  final List<String> areasToImprove;
  final String recommendation;
  final List<String> wordsToReview;

  const SessionFeedback({
    required this.title,
    required this.subtitle,
    required this.encouragement,
    this.strengths = const [],
    this.areasToImprove = const [],
    required this.recommendation,
    this.wordsToReview = const [],
  });

  factory SessionFeedback.generate({
    required double accuracy,
    required int combo,
    required int streak,
    required List<String> weakWords,
    required String gameMode,
  }) {
    String title;
    String subtitle;
    String encouragement;
    List<String> strengths = [];
    List<String> areasToImprove = [];
    String recommendation;

    // Generate title based on accuracy
    if (accuracy >= 1.0) {
      title = 'Perfect! 🎉';
      subtitle = 'Flawless performance!';
      encouragement = 'You\'re absolutely crushing it!';
      strengths.add('Perfect accuracy');
    } else if (accuracy >= 0.9) {
      title = 'Excellent! 🌟';
      subtitle = 'Nearly perfect!';
      encouragement = 'You\'re doing amazing!';
      strengths.add('Outstanding accuracy');
    } else if (accuracy >= 0.8) {
      title = 'Great Job! 👏';
      subtitle = 'Very impressive!';
      encouragement = 'Keep up the fantastic work!';
      strengths.add('Strong accuracy');
    } else if (accuracy >= 0.7) {
      title = 'Good Work! 👍';
      subtitle = 'Solid performance!';
      encouragement = 'You\'re making great progress!';
    } else if (accuracy >= 0.5) {
      title = 'Keep Going! 💪';
      subtitle = 'Practice makes perfect!';
      encouragement = 'Every session makes you stronger!';
      areasToImprove.add('Focus on accuracy');
    } else {
      title = 'Don\'t Give Up! 🌱';
      subtitle = 'Learning takes time';
      encouragement = 'Each mistake is a lesson learned!';
      areasToImprove.add('Take your time with each question');
    }

    // Add combo strength if applicable
    if (combo >= 10) {
      strengths.add('Amazing combo of $combo!');
    } else if (combo >= 5) {
      strengths.add('Good combo streak');
    }

    // Add streak strength if applicable
    if (streak >= 7) {
      strengths.add('Incredible $streak-day streak!');
    } else if (streak >= 3) {
      strengths.add('Building a great streak');
    }

    // Generate recommendation
    if (weakWords.isNotEmpty) {
      recommendation =
          'Review these ${weakWords.length} words tomorrow for best retention.';
      areasToImprove.add('${weakWords.length} words need more practice');
    } else if (accuracy < 0.7) {
      recommendation = 'Try the same mode again to reinforce your learning.';
    } else if (accuracy < 0.9) {
      recommendation = 'Challenge yourself with Strength Ordering mode next!';
    } else {
      recommendation = 'You\'re ready for the Daily Challenge!';
    }

    return SessionFeedback(
      title: title,
      subtitle: subtitle,
      encouragement: encouragement,
      strengths: strengths,
      areasToImprove: areasToImprove,
      recommendation: recommendation,
      wordsToReview: weakWords,
    );
  }
}

// ===================
// ACHIEVEMENTS
// ===================

enum AchievementCategory { streak, xp, accuracy, games, words, special }

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int xpReward;
  final bool isSecret;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0
  final int currentValue;
  final int targetValue;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.xpReward = 50,
    this.isSecret = false,
    this.unlockedAt,
    this.progress = 0,
    this.currentValue = 0,
    this.targetValue = 1,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({
    DateTime? unlockedAt,
    double? progress,
    int? currentValue,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      xpReward: xpReward,
      isSecret: isSecret,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue,
    );
  }
}

// ===================
// PREDEFINED ACHIEVEMENTS
// ===================

class Achievements {
  static const List<Achievement> all = [
    // Streak Achievements
    Achievement(
      id: 'streak_3',
      name: 'Getting Started',
      description: 'Maintain a 3-day streak',
      icon: '🔥',
      category: AchievementCategory.streak,
      xpReward: 30,
      targetValue: 3,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      category: AchievementCategory.streak,
      xpReward: 75,
      targetValue: 7,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      description: 'Maintain a 30-day streak',
      icon: '🏆',
      category: AchievementCategory.streak,
      xpReward: 200,
      targetValue: 30,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Centurion',
      description: 'Maintain a 100-day streak',
      icon: '👑',
      category: AchievementCategory.streak,
      xpReward: 500,
      targetValue: 100,
    ),

    // XP Achievements
    Achievement(
      id: 'xp_100',
      name: 'First Steps',
      description: 'Earn 100 XP',
      icon: '⭐',
      category: AchievementCategory.xp,
      xpReward: 20,
      targetValue: 100,
    ),
    Achievement(
      id: 'xp_1000',
      name: 'Rising Star',
      description: 'Earn 1,000 XP',
      icon: '🌟',
      category: AchievementCategory.xp,
      xpReward: 50,
      targetValue: 1000,
    ),
    Achievement(
      id: 'xp_5000',
      name: 'XP Hunter',
      description: 'Earn 5,000 XP',
      icon: '💫',
      category: AchievementCategory.xp,
      xpReward: 100,
      targetValue: 5000,
    ),
    Achievement(
      id: 'xp_10000',
      name: 'XP Legend',
      description: 'Earn 10,000 XP',
      icon: '🏅',
      category: AchievementCategory.xp,
      xpReward: 200,
      targetValue: 10000,
    ),

    // Accuracy Achievements
    Achievement(
      id: 'perfect_game',
      name: 'Perfectionist',
      description: 'Complete a game with 100% accuracy',
      icon: '💯',
      category: AchievementCategory.accuracy,
      xpReward: 50,
      targetValue: 1,
    ),
    Achievement(
      id: 'perfect_10',
      name: 'Accuracy King',
      description: 'Complete 10 perfect games',
      icon: '🎯',
      category: AchievementCategory.accuracy,
      xpReward: 150,
      targetValue: 10,
    ),
    Achievement(
      id: 'combo_10',
      name: 'Combo Starter',
      description: 'Get a 10-answer combo',
      icon: '⚡',
      category: AchievementCategory.accuracy,
      xpReward: 30,
      targetValue: 10,
    ),
    Achievement(
      id: 'combo_25',
      name: 'Combo Master',
      description: 'Get a 25-answer combo',
      icon: '🔥',
      category: AchievementCategory.accuracy,
      xpReward: 75,
      targetValue: 25,
    ),

    // Games Achievements
    Achievement(
      id: 'games_10',
      name: 'Game On',
      description: 'Complete 10 games',
      icon: '🎮',
      category: AchievementCategory.games,
      xpReward: 30,
      targetValue: 10,
    ),
    Achievement(
      id: 'games_50',
      name: 'Dedicated Player',
      description: 'Complete 50 games',
      icon: '🎲',
      category: AchievementCategory.games,
      xpReward: 100,
      targetValue: 50,
    ),
    Achievement(
      id: 'games_100',
      name: 'Game Enthusiast',
      description: 'Complete 100 games',
      icon: '🏆',
      category: AchievementCategory.games,
      xpReward: 200,
      targetValue: 100,
    ),
    Achievement(
      id: 'daily_challenge_7',
      name: 'Challenger',
      description: 'Complete 7 daily challenges',
      icon: '📅',
      category: AchievementCategory.games,
      xpReward: 75,
      targetValue: 7,
    ),

    // Words Achievements
    Achievement(
      id: 'words_10',
      name: 'Word Collector',
      description: 'Learn 10 words',
      icon: '📚',
      category: AchievementCategory.words,
      xpReward: 20,
      targetValue: 10,
    ),
    Achievement(
      id: 'words_50',
      name: 'Vocabulary Builder',
      description: 'Learn 50 words',
      icon: '📖',
      category: AchievementCategory.words,
      xpReward: 75,
      targetValue: 50,
    ),
    Achievement(
      id: 'words_mastered_10',
      name: 'Word Master',
      description: 'Master 10 words',
      icon: '🎓',
      category: AchievementCategory.words,
      xpReward: 100,
      targetValue: 10,
    ),
    Achievement(
      id: 'words_mastered_50',
      name: 'Vocabulary Virtuoso',
      description: 'Master 50 words',
      icon: '👨‍🎓',
      category: AchievementCategory.words,
      xpReward: 250,
      targetValue: 50,
    ),

    // Special Achievements
    Achievement(
      id: 'first_game',
      name: 'Welcome!',
      description: 'Complete your first game',
      icon: '🎉',
      category: AchievementCategory.special,
      xpReward: 25,
      targetValue: 1,
    ),
    Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Play a game before 8 AM',
      icon: '🌅',
      category: AchievementCategory.special,
      xpReward: 30,
      isSecret: true,
      targetValue: 1,
    ),
    Achievement(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Play a game after 11 PM',
      icon: '🦉',
      category: AchievementCategory.special,
      xpReward: 30,
      isSecret: true,
      targetValue: 1,
    ),
    Achievement(
      id: 'weekend_warrior',
      name: 'Weekend Warrior',
      description: 'Play 5 games on a weekend',
      icon: '🏄',
      category: AchievementCategory.special,
      xpReward: 40,
      targetValue: 5,
    ),
    Achievement(
      id: 'level_10',
      name: 'Double Digits',
      description: 'Reach level 10',
      icon: '🔟',
      category: AchievementCategory.special,
      xpReward: 150,
      targetValue: 10,
    ),
    Achievement(
      id: 'all_modes',
      name: 'Mode Explorer',
      description: 'Play all game modes',
      icon: '🗺️',
      category: AchievementCategory.special,
      xpReward: 50,
      targetValue: 4,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ===================
// MOTIVATIONAL MESSAGES
// ===================

class MotivationalMessages {
  static const List<String> streakMessages = [
    "🔥 Keep the fire burning!",
    "🔥 You're on fire! Don't break the chain!",
    "⚡ Streak power activated!",
    "💪 Consistency is key!",
    "🌟 Every day counts!",
  ];

  static const List<String> encouragementMessages = [
    "You've got this! 💪",
    "Every expert was once a beginner.",
    "Small steps lead to big results!",
    "Your brain is growing stronger!",
    "Learning is a superpower! 🦸",
    "Progress, not perfection!",
    "You're doing amazing!",
    "Keep pushing forward! 🚀",
  ];

  static const List<String> comebackMessages = [
    "Welcome back! We missed you! 👋",
    "Ready to continue your journey?",
    "Let's pick up where you left off!",
    "Your brain is ready for more!",
    "Time to level up! 🎮",
  ];

  static const List<String> perfectMessages = [
    "PERFECT! You're a genius! 🧠",
    "Flawless victory! 🏆",
    "100%! Nothing can stop you!",
    "Perfect score! Amazing! 🌟",
    "You nailed every single one! 💯",
  ];

  static String getStreakMessage(int streak) {
    if (streak >= 30) return "🔥 $streak-day streak! You're a legend!";
    if (streak >= 7) return "🔥 $streak-day streak! Incredible dedication!";
    if (streak >= 3) return "🔥 $streak-day streak! Keep it going!";
    return streakMessages[DateTime.now().second % streakMessages.length];
  }

  static String getEncouragementMessage() {
    return encouragementMessages[DateTime.now().second %
        encouragementMessages.length];
  }

  static String getComebackMessage() {
    return comebackMessages[DateTime.now().second % comebackMessages.length];
  }

  static String getPerfectMessage() {
    return perfectMessages[DateTime.now().second % perfectMessages.length];
  }
}
