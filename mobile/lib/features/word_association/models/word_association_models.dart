/// Represents a word with its intensity level in an association chain
class AssociatedWord {
  final String word;
  final int level; // 1 = base synonym, 2 = stronger, 3 = strongest
  final String definition;

  const AssociatedWord({
    required this.word,
    required this.level,
    required this.definition,
  });

  factory AssociatedWord.fromJson(Map<String, dynamic> json) {
    return AssociatedWord(
      word: json['word'] as String,
      level: json['level'] as int,
      definition: json['definition'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'level': level,
    'definition': definition,
  };
}

/// Represents a complete word association chain
class WordAssociation {
  final String id;
  final String baseWord;
  final String baseDefinition;
  final String partOfSpeech;
  final List<AssociatedWord> associations;
  final Map<String, String> sentences;
  final String category; // emotion, action, description, etc.
  final int difficulty; // 1-3

  const WordAssociation({
    required this.id,
    required this.baseWord,
    required this.baseDefinition,
    required this.partOfSpeech,
    required this.associations,
    required this.sentences,
    required this.category,
    this.difficulty = 1,
  });

  /// Get all words in the chain including the base word
  List<String> get allWords => [baseWord, ...associations.map((a) => a.word)];

  /// Get words sorted by intensity (weakest to strongest)
  List<String> get wordsByIntensity {
    final sorted = List<AssociatedWord>.from(associations)
      ..sort((a, b) => a.level.compareTo(b.level));
    return [baseWord, ...sorted.map((a) => a.word)];
  }

  factory WordAssociation.fromJson(Map<String, dynamic> json) {
    return WordAssociation(
      id: json['id'] as String,
      baseWord: json['base_word'] as String,
      baseDefinition: json['base_definition'] as String? ?? '',
      partOfSpeech: json['part_of_speech'] as String? ?? 'adjective',
      associations: (json['associations'] as List)
          .map((a) => AssociatedWord.fromJson(a))
          .toList(),
      sentences: Map<String, String>.from(json['sentences'] as Map),
      category: json['category'] as String? ?? 'general',
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }
}

/// Tracks user progress on a specific word
class WordProgress {
  final String wordId;
  final int correctCount;
  final int incorrectCount;
  final DateTime lastPracticed;
  final DateTime nextReview;
  final int masteryLevel; // 0-5, based on spaced repetition

  const WordProgress({
    required this.wordId,
    this.correctCount = 0,
    this.incorrectCount = 0,
    required this.lastPracticed,
    required this.nextReview,
    this.masteryLevel = 0,
  });

  double get accuracy => correctCount + incorrectCount > 0
      ? correctCount / (correctCount + incorrectCount)
      : 0.0;

  bool get needsReview => DateTime.now().isAfter(nextReview);

  WordProgress copyWith({
    int? correctCount,
    int? incorrectCount,
    DateTime? lastPracticed,
    DateTime? nextReview,
    int? masteryLevel,
  }) {
    return WordProgress(
      wordId: wordId,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      nextReview: nextReview ?? this.nextReview,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }
}

/// Question types for the game
enum GameMode {
  association, // Connect related words
  context, // Choose correct word for sentence
  strengthOrdering, // Arrange words weakest → strongest
  dailyChallenge, // Mixed 5 questions
}

/// Represents a single question in the game
class GameQuestion {
  final String id;
  final GameMode mode;
  final WordAssociation wordData;
  final String? sentenceWithBlank; // For context mode
  final String? correctAnswer; // For context mode
  final List<String>? options; // For multiple choice
  final List<String>? correctOrder; // For ordering mode

  const GameQuestion({
    required this.id,
    required this.mode,
    required this.wordData,
    this.sentenceWithBlank,
    this.correctAnswer,
    this.options,
    this.correctOrder,
  });
}

/// Result of answering a question
class QuestionResult {
  final bool isCorrect;
  final int pointsEarned;
  final String explanation;
  final Duration timeTaken;

  const QuestionResult({
    required this.isCorrect,
    required this.pointsEarned,
    required this.explanation,
    required this.timeTaken,
  });
}

/// Game session statistics
class GameSession {
  final GameMode mode;
  final int totalQuestions;
  final int correctAnswers;
  final int totalScore;
  final int streak;
  final int bestStreak;
  final Duration totalTime;
  final DateTime startedAt;

  const GameSession({
    required this.mode,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.totalScore = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.totalTime = Duration.zero,
    required this.startedAt,
  });

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

  GameSession copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? totalScore,
    int? streak,
    int? bestStreak,
    Duration? totalTime,
  }) {
    return GameSession(
      mode: mode,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalScore: totalScore ?? this.totalScore,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalTime: totalTime ?? this.totalTime,
      startedAt: startedAt,
    );
  }
}
