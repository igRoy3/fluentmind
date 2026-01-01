/// Game Difficulty System Models for FluentMind
/// Provides 3-level difficulty with adaptive adjustment based on real user performance

// ===================
// DIFFICULTY LEVELS
// ===================

enum GameDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case GameDifficulty.beginner:
        return 'Beginner';
      case GameDifficulty.intermediate:
        return 'Intermediate';
      case GameDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get emoji {
    switch (this) {
      case GameDifficulty.beginner:
        return '🌱';
      case GameDifficulty.intermediate:
        return '🌿';
      case GameDifficulty.advanced:
        return '🌳';
    }
  }

  String get description {
    switch (this) {
      case GameDifficulty.beginner:
        return 'Relaxed pace, forgiving scoring';
      case GameDifficulty.intermediate:
        return 'Balanced challenge, standard scoring';
      case GameDifficulty.advanced:
        return 'Fast-paced, precision required';
    }
  }
}

// ===================
// DIFFICULTY SETTINGS PER GAME
// ===================

/// Base class for difficulty-specific game settings
class DifficultySettings {
  // Time settings
  final int timeLimitSeconds;
  final int bonusTimePerCorrect;

  // Scoring
  final int basePointsPerCorrect;
  final int penaltyPerWrong;
  final double comboMultiplier;
  final int perfectRoundBonus;

  // Tolerance
  final int maxErrorsAllowed;
  final int hintCount;
  final bool showHints;

  // Content complexity
  final int contentComplexityLevel; // 1-3
  final int minItemCount;
  final int maxItemCount;

  // XP multiplier
  final double xpMultiplier;

  const DifficultySettings({
    required this.timeLimitSeconds,
    this.bonusTimePerCorrect = 0,
    required this.basePointsPerCorrect,
    required this.penaltyPerWrong,
    this.comboMultiplier = 1.0,
    this.perfectRoundBonus = 0,
    this.maxErrorsAllowed = 999,
    this.hintCount = 0,
    this.showHints = false,
    this.contentComplexityLevel = 1,
    this.minItemCount = 4,
    this.maxItemCount = 6,
    this.xpMultiplier = 1.0,
  });
}

// ===================
// GAME-SPECIFIC DIFFICULTY CONFIGURATIONS
// ===================

/// Math Speed Game Difficulty
class MathSpeedDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 10,
      penaltyPerWrong: 0,
      comboMultiplier: 1.1,
      perfectRoundBonus: 20,
      maxErrorsAllowed: 10,
      hintCount: 3,
      showHints: true,
      contentComplexityLevel: 1, // Addition, subtraction only, numbers 1-20
      minItemCount: 4,
      maxItemCount: 4,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 2,
      basePointsPerCorrect: 15,
      penaltyPerWrong: 5,
      comboMultiplier: 1.25,
      perfectRoundBonus: 35,
      maxErrorsAllowed: 5,
      hintCount: 1,
      showHints: true,
      contentComplexityLevel: 2, // +, -, ×, numbers 1-50
      minItemCount: 4,
      maxItemCount: 4,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 45,
      bonusTimePerCorrect: 1,
      basePointsPerCorrect: 25,
      penaltyPerWrong: 10,
      comboMultiplier: 1.5,
      perfectRoundBonus: 50,
      maxErrorsAllowed: 3,
      hintCount: 0,
      showHints: false,
      contentComplexityLevel: 3, // +, -, ×, ÷, numbers 1-100
      minItemCount: 4,
      maxItemCount: 4,
      xpMultiplier: 1.5,
    ),
  };

  static MathSpeedContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return MathSpeedContent(
          operators: ['+', '-'],
          minNumber: 1,
          maxNumber: 20,
          allowNegativeResults: false,
        );
      case GameDifficulty.intermediate:
        return MathSpeedContent(
          operators: ['+', '-', '×'],
          minNumber: 1,
          maxNumber: 50,
          allowNegativeResults: false,
        );
      case GameDifficulty.advanced:
        return MathSpeedContent(
          operators: ['+', '-', '×', '÷'],
          minNumber: 1,
          maxNumber: 100,
          allowNegativeResults: true,
        );
    }
  }
}

class MathSpeedContent {
  final List<String> operators;
  final int minNumber;
  final int maxNumber;
  final bool allowNegativeResults;

  const MathSpeedContent({
    required this.operators,
    required this.minNumber,
    required this.maxNumber,
    this.allowNegativeResults = false,
  });
}

/// Memory Match Game Difficulty
class MemoryMatchDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 120,
      bonusTimePerCorrect: 5,
      basePointsPerCorrect: 15,
      penaltyPerWrong: 0,
      comboMultiplier: 1.1,
      perfectRoundBonus: 30,
      maxErrorsAllowed: 20,
      contentComplexityLevel: 1,
      minItemCount: 8, // 4 pairs
      maxItemCount: 8,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 20,
      penaltyPerWrong: 5,
      comboMultiplier: 1.3,
      perfectRoundBonus: 50,
      maxErrorsAllowed: 10,
      contentComplexityLevel: 2,
      minItemCount: 12, // 6 pairs
      maxItemCount: 12,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 2,
      basePointsPerCorrect: 30,
      penaltyPerWrong: 10,
      comboMultiplier: 1.5,
      perfectRoundBonus: 75,
      maxErrorsAllowed: 5,
      contentComplexityLevel: 3,
      minItemCount: 16, // 8 pairs
      maxItemCount: 20, // up to 10 pairs
      xpMultiplier: 1.5,
    ),
  };

  static MemoryMatchContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return MemoryMatchContent(
          pairCount: 4,
          revealTimeMs: 1500,
          matchType: MatchType.identical,
        );
      case GameDifficulty.intermediate:
        return MemoryMatchContent(
          pairCount: 6,
          revealTimeMs: 1000,
          matchType: MatchType.identical,
        );
      case GameDifficulty.advanced:
        return MemoryMatchContent(
          pairCount: 8,
          revealTimeMs: 700,
          matchType: MatchType.related, // Match word with definition
        );
    }
  }
}

enum MatchType { identical, related }

class MemoryMatchContent {
  final int pairCount;
  final int revealTimeMs;
  final MatchType matchType;

  const MemoryMatchContent({
    required this.pairCount,
    required this.revealTimeMs,
    required this.matchType,
  });
}

/// Word Scramble Game Difficulty
class WordScrambleDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 10,
      basePointsPerCorrect: 20,
      penaltyPerWrong: 0,
      comboMultiplier: 1.15,
      perfectRoundBonus: 25,
      maxErrorsAllowed: 999,
      hintCount: 5,
      showHints: true,
      contentComplexityLevel: 1,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 5,
      basePointsPerCorrect: 30,
      penaltyPerWrong: 5,
      comboMultiplier: 1.3,
      perfectRoundBonus: 40,
      maxErrorsAllowed: 5,
      hintCount: 2,
      showHints: true,
      contentComplexityLevel: 2,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 45,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 50,
      penaltyPerWrong: 15,
      comboMultiplier: 1.5,
      perfectRoundBonus: 60,
      maxErrorsAllowed: 3,
      hintCount: 0,
      showHints: false,
      contentComplexityLevel: 3,
      xpMultiplier: 1.5,
    ),
  };

  static WordScrambleContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return WordScrambleContent(
          minWordLength: 4,
          maxWordLength: 6,
          showFirstLetter: true,
          showLastLetter: true,
        );
      case GameDifficulty.intermediate:
        return WordScrambleContent(
          minWordLength: 6,
          maxWordLength: 9,
          showFirstLetter: true,
          showLastLetter: false,
        );
      case GameDifficulty.advanced:
        return WordScrambleContent(
          minWordLength: 8,
          maxWordLength: 12,
          showFirstLetter: false,
          showLastLetter: false,
        );
    }
  }
}

class WordScrambleContent {
  final int minWordLength;
  final int maxWordLength;
  final bool showFirstLetter;
  final bool showLastLetter;

  const WordScrambleContent({
    required this.minWordLength,
    required this.maxWordLength,
    required this.showFirstLetter,
    required this.showLastLetter,
  });
}

/// Logic Sequence Game Difficulty
class LogicSequenceDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 8,
      basePointsPerCorrect: 20,
      penaltyPerWrong: 0,
      comboMultiplier: 1.2,
      perfectRoundBonus: 30,
      maxErrorsAllowed: 10,
      hintCount: 3,
      showHints: true,
      contentComplexityLevel: 1,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 5,
      basePointsPerCorrect: 30,
      penaltyPerWrong: 5,
      comboMultiplier: 1.35,
      perfectRoundBonus: 45,
      maxErrorsAllowed: 5,
      hintCount: 1,
      showHints: true,
      contentComplexityLevel: 2,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 45,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 50,
      penaltyPerWrong: 15,
      comboMultiplier: 1.6,
      perfectRoundBonus: 70,
      maxErrorsAllowed: 3,
      hintCount: 0,
      showHints: false,
      contentComplexityLevel: 3,
      xpMultiplier: 1.5,
    ),
  };

  static LogicSequenceContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return LogicSequenceContent(
          sequenceLength: 5,
          patternTypes: [PatternType.addition],
          maxStep: 5,
        );
      case GameDifficulty.intermediate:
        return LogicSequenceContent(
          sequenceLength: 6,
          patternTypes: [PatternType.addition, PatternType.multiplication],
          maxStep: 10,
        );
      case GameDifficulty.advanced:
        return LogicSequenceContent(
          sequenceLength: 7,
          patternTypes: [
            PatternType.addition,
            PatternType.multiplication,
            PatternType.fibonacci,
            PatternType.alternating,
          ],
          maxStep: 20,
        );
    }
  }
}

enum PatternType { addition, multiplication, fibonacci, alternating }

class LogicSequenceContent {
  final int sequenceLength;
  final List<PatternType> patternTypes;
  final int maxStep;

  const LogicSequenceContent({
    required this.sequenceLength,
    required this.patternTypes,
    required this.maxStep,
  });
}

/// Category Sort Game Difficulty
class CategorySortDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 10,
      penaltyPerWrong: 0,
      comboMultiplier: 1.1,
      perfectRoundBonus: 25,
      maxErrorsAllowed: 10,
      contentComplexityLevel: 1,
      minItemCount: 8,
      maxItemCount: 10,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 2,
      basePointsPerCorrect: 15,
      penaltyPerWrong: 5,
      comboMultiplier: 1.25,
      perfectRoundBonus: 40,
      maxErrorsAllowed: 5,
      contentComplexityLevel: 2,
      minItemCount: 12,
      maxItemCount: 15,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 45,
      bonusTimePerCorrect: 1,
      basePointsPerCorrect: 25,
      penaltyPerWrong: 10,
      comboMultiplier: 1.5,
      perfectRoundBonus: 60,
      maxErrorsAllowed: 3,
      contentComplexityLevel: 3,
      minItemCount: 16,
      maxItemCount: 20,
      xpMultiplier: 1.5,
    ),
  };

  static CategorySortContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return CategorySortContent(
          categoryCount: 2,
          itemsPerCategory: 4,
          categoryTypes: [CategoryType.obvious], // Fruits vs Vehicles
        );
      case GameDifficulty.intermediate:
        return CategorySortContent(
          categoryCount: 2,
          itemsPerCategory: 6,
          categoryTypes: [CategoryType.similar], // Fruits vs Vegetables
        );
      case GameDifficulty.advanced:
        return CategorySortContent(
          categoryCount: 3,
          itemsPerCategory: 5,
          categoryTypes: [CategoryType.abstract], // Emotions, Actions, Objects
        );
    }
  }
}

enum CategoryType { obvious, similar, abstract }

class CategorySortContent {
  final int categoryCount;
  final int itemsPerCategory;
  final List<CategoryType> categoryTypes;

  const CategorySortContent({
    required this.categoryCount,
    required this.itemsPerCategory,
    required this.categoryTypes,
  });
}

/// Pattern Recognition Game Difficulty
class PatternRecognitionDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 5,
      basePointsPerCorrect: 15,
      penaltyPerWrong: 0,
      comboMultiplier: 1.15,
      perfectRoundBonus: 25,
      maxErrorsAllowed: 10,
      contentComplexityLevel: 1,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 25,
      penaltyPerWrong: 5,
      comboMultiplier: 1.3,
      perfectRoundBonus: 40,
      maxErrorsAllowed: 5,
      contentComplexityLevel: 2,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 45,
      bonusTimePerCorrect: 2,
      basePointsPerCorrect: 40,
      penaltyPerWrong: 10,
      comboMultiplier: 1.5,
      perfectRoundBonus: 60,
      maxErrorsAllowed: 3,
      contentComplexityLevel: 3,
      xpMultiplier: 1.5,
    ),
  };

  static PatternRecognitionContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return PatternRecognitionContent(
          gridSize: 3,
          cellsToRemember: 3,
          showTimeMs: 2500,
        );
      case GameDifficulty.intermediate:
        return PatternRecognitionContent(
          gridSize: 4,
          cellsToRemember: 5,
          showTimeMs: 2000,
        );
      case GameDifficulty.advanced:
        return PatternRecognitionContent(
          gridSize: 5,
          cellsToRemember: 8,
          showTimeMs: 1500,
        );
    }
  }
}

class PatternRecognitionContent {
  final int gridSize;
  final int cellsToRemember;
  final int showTimeMs;

  const PatternRecognitionContent({
    required this.gridSize,
    required this.cellsToRemember,
    required this.showTimeMs,
  });
}

// ===================
// SENTENCE BUILDER GAME (NEW)
// ===================

class SentenceBuilderDifficulty {
  static const Map<GameDifficulty, DifficultySettings> settings = {
    GameDifficulty.beginner: DifficultySettings(
      timeLimitSeconds: 120,
      bonusTimePerCorrect: 10,
      basePointsPerCorrect: 20,
      penaltyPerWrong: 0,
      comboMultiplier: 1.1,
      perfectRoundBonus: 30,
      maxErrorsAllowed: 10,
      hintCount: 3,
      showHints: true,
      contentComplexityLevel: 1,
      xpMultiplier: 0.8,
    ),
    GameDifficulty.intermediate: DifficultySettings(
      timeLimitSeconds: 90,
      bonusTimePerCorrect: 5,
      basePointsPerCorrect: 30,
      penaltyPerWrong: 5,
      comboMultiplier: 1.25,
      perfectRoundBonus: 45,
      maxErrorsAllowed: 5,
      hintCount: 1,
      showHints: true,
      contentComplexityLevel: 2,
      xpMultiplier: 1.0,
    ),
    GameDifficulty.advanced: DifficultySettings(
      timeLimitSeconds: 60,
      bonusTimePerCorrect: 3,
      basePointsPerCorrect: 50,
      penaltyPerWrong: 15,
      comboMultiplier: 1.5,
      perfectRoundBonus: 70,
      maxErrorsAllowed: 3,
      hintCount: 0,
      showHints: false,
      contentComplexityLevel: 3,
      xpMultiplier: 1.5,
    ),
  };

  static SentenceBuilderContent getContent(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return SentenceBuilderContent(
          wordCount: 4,
          includeArticles: true,
          includePunctuation: false,
          sentenceType: SentenceType.simple,
        );
      case GameDifficulty.intermediate:
        return SentenceBuilderContent(
          wordCount: 6,
          includeArticles: true,
          includePunctuation: true,
          sentenceType: SentenceType.compound,
        );
      case GameDifficulty.advanced:
        return SentenceBuilderContent(
          wordCount: 8,
          includeArticles: true,
          includePunctuation: true,
          sentenceType: SentenceType.complex,
        );
    }
  }
}

enum SentenceType { simple, compound, complex }

class SentenceBuilderContent {
  final int wordCount;
  final bool includeArticles;
  final bool includePunctuation;
  final SentenceType sentenceType;

  const SentenceBuilderContent({
    required this.wordCount,
    required this.includeArticles,
    required this.includePunctuation,
    required this.sentenceType,
  });
}

// ===================
// GAME SESSION TRACKING (REAL DATA)
// ===================

class GameSession {
  final String id;
  final String gameId;
  final GameDifficulty difficulty;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int score;
  final int questionsAnswered;
  final int correctAnswers;
  final int wrongAnswers;
  final int maxCombo;
  final int hintsUsed;
  final int xpEarned;
  final Duration completionTime;
  final List<QuestionResult> questionResults;

  GameSession({
    required this.id,
    required this.gameId,
    required this.difficulty,
    required this.startedAt,
    this.endedAt,
    this.score = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.maxCombo = 0,
    this.hintsUsed = 0,
    this.xpEarned = 0,
    this.completionTime = Duration.zero,
    this.questionResults = const [],
  });

  double get accuracy =>
      questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;

  double get avgTimePerQuestion => questionsAnswered > 0
      ? completionTime.inMilliseconds / questionsAnswered
      : 0;

  bool get isPerfect => wrongAnswers == 0 && questionsAnswered >= 5;

  GameSession copyWith({
    DateTime? endedAt,
    int? score,
    int? questionsAnswered,
    int? correctAnswers,
    int? wrongAnswers,
    int? maxCombo,
    int? hintsUsed,
    int? xpEarned,
    Duration? completionTime,
    List<QuestionResult>? questionResults,
  }) {
    return GameSession(
      id: id,
      gameId: gameId,
      difficulty: difficulty,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      score: score ?? this.score,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      maxCombo: maxCombo ?? this.maxCombo,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      xpEarned: xpEarned ?? this.xpEarned,
      completionTime: completionTime ?? this.completionTime,
      questionResults: questionResults ?? this.questionResults,
    );
  }
}

class QuestionResult {
  final String questionId;
  final bool isCorrect;
  final Duration responseTime;
  final String? userAnswer;
  final String correctAnswer;
  final int pointsEarned;

  const QuestionResult({
    required this.questionId,
    required this.isCorrect,
    required this.responseTime,
    this.userAnswer,
    required this.correctAnswer,
    this.pointsEarned = 0,
  });
}

// ===================
// GAME PERFORMANCE STATS (REAL DATA)
// ===================

class GamePerformanceStats {
  final String gameId;
  final int totalPlays;
  final int bestScore;
  final int totalScore;
  final double avgAccuracy;
  final double avgCompletionTimeSeconds;
  final int longestCombo;
  final int perfectRounds;
  final Map<GameDifficulty, DifficultyStats> statsByDifficulty;
  final List<GameSession> recentSessions;
  final DateTime? lastPlayedAt;

  const GamePerformanceStats({
    required this.gameId,
    this.totalPlays = 0,
    this.bestScore = 0,
    this.totalScore = 0,
    this.avgAccuracy = 0.0,
    this.avgCompletionTimeSeconds = 0.0,
    this.longestCombo = 0,
    this.perfectRounds = 0,
    this.statsByDifficulty = const {},
    this.recentSessions = const [],
    this.lastPlayedAt,
  });

  int get avgScore => totalPlays > 0 ? (totalScore / totalPlays).round() : 0;

  GamePerformanceStats copyWith({
    int? totalPlays,
    int? bestScore,
    int? totalScore,
    double? avgAccuracy,
    double? avgCompletionTimeSeconds,
    int? longestCombo,
    int? perfectRounds,
    Map<GameDifficulty, DifficultyStats>? statsByDifficulty,
    List<GameSession>? recentSessions,
    DateTime? lastPlayedAt,
  }) {
    return GamePerformanceStats(
      gameId: gameId,
      totalPlays: totalPlays ?? this.totalPlays,
      bestScore: bestScore ?? this.bestScore,
      totalScore: totalScore ?? this.totalScore,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      avgCompletionTimeSeconds:
          avgCompletionTimeSeconds ?? this.avgCompletionTimeSeconds,
      longestCombo: longestCombo ?? this.longestCombo,
      perfectRounds: perfectRounds ?? this.perfectRounds,
      statsByDifficulty: statsByDifficulty ?? this.statsByDifficulty,
      recentSessions: recentSessions ?? this.recentSessions,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}

class DifficultyStats {
  final GameDifficulty difficulty;
  final int plays;
  final int bestScore;
  final double avgAccuracy;
  final int perfectRounds;

  const DifficultyStats({
    required this.difficulty,
    this.plays = 0,
    this.bestScore = 0,
    this.avgAccuracy = 0.0,
    this.perfectRounds = 0,
  });

  DifficultyStats copyWith({
    int? plays,
    int? bestScore,
    double? avgAccuracy,
    int? perfectRounds,
  }) {
    return DifficultyStats(
      difficulty: difficulty,
      plays: plays ?? this.plays,
      bestScore: bestScore ?? this.bestScore,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      perfectRounds: perfectRounds ?? this.perfectRounds,
    );
  }
}
