import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Tracks word performance across a vocabulary learning session
class WordPerformance {
  final String word;
  final String definition;
  final String example;
  final String partOfSpeech;
  int flashcardAttempts;
  int flashcardCorrect;
  int quizAttempts;
  int quizCorrect;
  int matchingAttempts;
  int matchingCorrect;
  int spellingAttempts;
  int spellingCorrect;

  WordPerformance({
    required this.word,
    required this.definition,
    required this.example,
    required this.partOfSpeech,
    this.flashcardAttempts = 0,
    this.flashcardCorrect = 0,
    this.quizAttempts = 0,
    this.quizCorrect = 0,
    this.matchingAttempts = 0,
    this.matchingCorrect = 0,
    this.spellingAttempts = 0,
    this.spellingCorrect = 0,
  });

  /// Total attempts across all game modes
  int get totalAttempts =>
      flashcardAttempts + quizAttempts + matchingAttempts + spellingAttempts;

  /// Total correct answers across all game modes
  int get totalCorrect =>
      flashcardCorrect + quizCorrect + matchingCorrect + spellingCorrect;

  /// Mastery percentage (0-100)
  int get masteryPercent {
    if (totalAttempts == 0) return 0;
    return ((totalCorrect / totalAttempts) * 100).round();
  }

  /// Whether this word needs more review (less than 100% mastery)
  bool get needsReview => masteryPercent < 100;

  /// Mastery level (0-5 stars) based on performance
  int get masteryLevel {
    if (totalAttempts == 0) return 0;
    final percent = masteryPercent;
    if (percent >= 100) return 5;
    if (percent >= 80) return 4;
    if (percent >= 60) return 3;
    if (percent >= 40) return 2;
    if (percent >= 20) return 1;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'definition': definition,
    'example': example,
    'partOfSpeech': partOfSpeech,
    'flashcardAttempts': flashcardAttempts,
    'flashcardCorrect': flashcardCorrect,
    'quizAttempts': quizAttempts,
    'quizCorrect': quizCorrect,
    'matchingAttempts': matchingAttempts,
    'matchingCorrect': matchingCorrect,
    'spellingAttempts': spellingAttempts,
    'spellingCorrect': spellingCorrect,
  };

  factory WordPerformance.fromJson(Map<String, dynamic> json) =>
      WordPerformance(
        word: json['word'] ?? '',
        definition: json['definition'] ?? '',
        example: json['example'] ?? '',
        partOfSpeech: json['partOfSpeech'] ?? '',
        flashcardAttempts: json['flashcardAttempts'] ?? 0,
        flashcardCorrect: json['flashcardCorrect'] ?? 0,
        quizAttempts: json['quizAttempts'] ?? 0,
        quizCorrect: json['quizCorrect'] ?? 0,
        matchingAttempts: json['matchingAttempts'] ?? 0,
        matchingCorrect: json['matchingCorrect'] ?? 0,
        spellingAttempts: json['spellingAttempts'] ?? 0,
        spellingCorrect: json['spellingCorrect'] ?? 0,
      );
}

/// Vocabulary session state
class VocabSessionState {
  final String categoryName;
  final List<WordPerformance> sessionWords;
  final DateTime startedAt;
  final bool isActive;

  VocabSessionState({
    required this.categoryName,
    required this.sessionWords,
    required this.startedAt,
    this.isActive = true,
  });

  /// Total XP earned in this session
  int get totalXpEarned {
    int xp = 0;
    for (final word in sessionWords) {
      xp += word.flashcardCorrect * 10;
      xp += word.quizCorrect * 15;
      xp += word.matchingCorrect * 12;
      xp += word.spellingCorrect * 20;
    }
    return xp;
  }

  /// Overall session mastery percentage
  int get overallMasteryPercent {
    if (sessionWords.isEmpty) return 0;
    final totalAttempts = sessionWords.fold<int>(
      0,
      (sum, w) => sum + w.totalAttempts,
    );
    final totalCorrect = sessionWords.fold<int>(
      0,
      (sum, w) => sum + w.totalCorrect,
    );
    if (totalAttempts == 0) return 0;
    return ((totalCorrect / totalAttempts) * 100).round();
  }

  /// Words that need more review
  List<WordPerformance> get wordsNeedingReview =>
      sessionWords.where((w) => w.needsReview && w.totalAttempts > 0).toList();

  /// Words that are mastered (100%)
  List<WordPerformance> get masteredWords =>
      sessionWords.where((w) => w.masteryPercent == 100).toList();

  Map<String, dynamic> toJson() => {
    'categoryName': categoryName,
    'sessionWords': sessionWords.map((w) => w.toJson()).toList(),
    'startedAt': startedAt.toIso8601String(),
    'isActive': isActive,
  };

  factory VocabSessionState.fromJson(Map<String, dynamic> json) =>
      VocabSessionState(
        categoryName: json['categoryName'] ?? '',
        sessionWords:
            (json['sessionWords'] as List?)
                ?.map((w) => WordPerformance.fromJson(w))
                .toList() ??
            [],
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'])
            : DateTime.now(),
        isActive: json['isActive'] ?? false,
      );

  VocabSessionState copyWith({
    String? categoryName,
    List<WordPerformance>? sessionWords,
    DateTime? startedAt,
    bool? isActive,
  }) => VocabSessionState(
    categoryName: categoryName ?? this.categoryName,
    sessionWords: sessionWords ?? this.sessionWords,
    startedAt: startedAt ?? this.startedAt,
    isActive: isActive ?? this.isActive,
  );
}

/// Service for managing vocabulary learning sessions
class VocabularySessionService extends StateNotifier<VocabSessionState?> {
  SharedPreferences? _prefs;
  static const String _sessionKey = 'vocab_session';
  static const String _historyKey = 'vocab_session_history';

  VocabularySessionService() : super(null) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCurrentSession();
  }

  Future<void> _loadCurrentSession() async {
    final sessionJson = _prefs?.getString(_sessionKey);
    if (sessionJson != null) {
      try {
        final json = jsonDecode(sessionJson);
        final session = VocabSessionState.fromJson(json);
        // Only restore if session was started within the last 24 hours
        if (session.isActive &&
            DateTime.now().difference(session.startedAt).inHours < 24) {
          state = session;
        } else {
          // Session expired, clear it
          await _prefs?.remove(_sessionKey);
        }
      } catch (e) {
        // Invalid session data, clear it
        await _prefs?.remove(_sessionKey);
      }
    }
  }

  Future<void> _saveSession() async {
    if (state != null) {
      await _prefs?.setString(_sessionKey, jsonEncode(state!.toJson()));
    } else {
      await _prefs?.remove(_sessionKey);
    }
  }

  /// Start a new vocabulary session with the given words
  Future<void> startSession({
    required String categoryName,
    required List<Map<String, String>> words,
  }) async {
    final sessionWords = words
        .map(
          (w) => WordPerformance(
            word: w['word'] ?? '',
            definition: w['definition'] ?? '',
            example: w['example'] ?? '',
            partOfSpeech: w['partOfSpeech'] ?? '',
          ),
        )
        .toList();

    state = VocabSessionState(
      categoryName: categoryName,
      sessionWords: sessionWords,
      startedAt: DateTime.now(),
      isActive: true,
    );
    await _saveSession();
  }

  /// Check if a session is active
  bool get hasActiveSession => state != null && state!.isActive;

  /// Get the current session words
  List<WordPerformance> get sessionWords => state?.sessionWords ?? [];

  /// Record a flashcard attempt
  void recordFlashcard(String word, bool correct) {
    if (state == null) return;

    final updatedWords = state!.sessionWords.map((w) {
      if (w.word == word) {
        w.flashcardAttempts++;
        if (correct) w.flashcardCorrect++;
      }
      return w;
    }).toList();

    state = state!.copyWith(sessionWords: updatedWords);
    _saveSession();
  }

  /// Record a quiz attempt
  void recordQuiz(String word, bool correct) {
    if (state == null) return;

    final updatedWords = state!.sessionWords.map((w) {
      if (w.word == word) {
        w.quizAttempts++;
        if (correct) w.quizCorrect++;
      }
      return w;
    }).toList();

    state = state!.copyWith(sessionWords: updatedWords);
    _saveSession();
  }

  /// Record a matching attempt
  void recordMatching(String word, bool correct) {
    if (state == null) return;

    final updatedWords = state!.sessionWords.map((w) {
      if (w.word == word) {
        w.matchingAttempts++;
        if (correct) w.matchingCorrect++;
      }
      return w;
    }).toList();

    state = state!.copyWith(sessionWords: updatedWords);
    _saveSession();
  }

  /// Record a spelling attempt
  void recordSpelling(String word, bool correct) {
    if (state == null) return;

    final updatedWords = state!.sessionWords.map((w) {
      if (w.word == word) {
        w.spellingAttempts++;
        if (correct) w.spellingCorrect++;
      }
      return w;
    }).toList();

    state = state!.copyWith(sessionWords: updatedWords);
    _saveSession();
  }

  /// End the current session and save to history
  Future<VocabSessionState?> endSession() async {
    if (state == null) return null;

    final completedSession = state!.copyWith(isActive: false);

    // Save to history
    await _saveToHistory(completedSession);

    // Clear current session
    state = null;
    await _prefs?.remove(_sessionKey);

    return completedSession;
  }

  Future<void> _saveToHistory(VocabSessionState session) async {
    final historyJson = _prefs?.getString(_historyKey);
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      try {
        history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      } catch (e) {
        // Invalid history, start fresh
      }
    }

    // Add new session to history (keep last 50)
    history.insert(0, session.toJson());
    if (history.length > 50) {
      history = history.take(50).toList();
    }

    await _prefs?.setString(_historyKey, jsonEncode(history));
  }

  /// Get recent session history
  Future<List<VocabSessionState>> getSessionHistory({int limit = 10}) async {
    final historyJson = _prefs?.getString(_historyKey);
    if (historyJson == null) return [];

    try {
      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      return history
          .take(limit)
          .map((h) => VocabSessionState.fromJson(h))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get cumulative word performance across all sessions
  Future<Map<String, WordPerformance>> getCumulativePerformance() async {
    final history = await getSessionHistory(limit: 50);
    final performance = <String, WordPerformance>{};

    for (final session in history) {
      for (final word in session.sessionWords) {
        if (performance.containsKey(word.word)) {
          final existing = performance[word.word]!;
          existing.flashcardAttempts += word.flashcardAttempts;
          existing.flashcardCorrect += word.flashcardCorrect;
          existing.quizAttempts += word.quizAttempts;
          existing.quizCorrect += word.quizCorrect;
          existing.matchingAttempts += word.matchingAttempts;
          existing.matchingCorrect += word.matchingCorrect;
          existing.spellingAttempts += word.spellingAttempts;
          existing.spellingCorrect += word.spellingCorrect;
        } else {
          performance[word.word] = WordPerformance(
            word: word.word,
            definition: word.definition,
            example: word.example,
            partOfSpeech: word.partOfSpeech,
            flashcardAttempts: word.flashcardAttempts,
            flashcardCorrect: word.flashcardCorrect,
            quizAttempts: word.quizAttempts,
            quizCorrect: word.quizCorrect,
            matchingAttempts: word.matchingAttempts,
            matchingCorrect: word.matchingCorrect,
            spellingAttempts: word.spellingAttempts,
            spellingCorrect: word.spellingCorrect,
          );
        }
      }
    }

    return performance;
  }

  /// Get words that need review (< 100% mastery)
  Future<List<WordPerformance>> getWordsNeedingReview() async {
    final performance = await getCumulativePerformance();
    return performance.values
        .where((w) => w.needsReview && w.totalAttempts > 0)
        .toList()
      ..sort((a, b) => a.masteryPercent.compareTo(b.masteryPercent));
  }

  /// Get recently learned words with mastery
  Future<List<WordPerformance>> getRecentlyLearnedWords({int limit = 5}) async {
    final history = await getSessionHistory(limit: 10);
    final seenWords = <String>{};
    final recentWords = <WordPerformance>[];

    for (final session in history) {
      for (final word in session.sessionWords) {
        if (!seenWords.contains(word.word) && word.totalAttempts > 0) {
          seenWords.add(word.word);
          recentWords.add(word);
        }
        if (recentWords.length >= limit) break;
      }
      if (recentWords.length >= limit) break;
    }

    return recentWords;
  }
}

/// Provider for vocabulary session service
final vocabularySessionProvider =
    StateNotifierProvider<VocabularySessionService, VocabSessionState?>((ref) {
      return VocabularySessionService();
    });
