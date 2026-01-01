import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_association_models.dart';
import '../data/word_association_data.dart';

// ===================
// State Classes
// ===================

class WordAssociationState {
  final bool isLoading;
  final GameMode currentMode;
  final GameSession? currentSession;
  final GameQuestion? currentQuestion;
  final List<GameQuestion> questionQueue;
  final int currentQuestionIndex;
  final bool isAnswered;
  final bool? lastAnswerCorrect;
  final String? lastExplanation;
  final Map<String, WordProgress> wordProgress;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final int dailyChallengesCompleted;
  final DateTime? lastPlayedDate;
  final String? error;

  const WordAssociationState({
    this.isLoading = false,
    this.currentMode = GameMode.association,
    this.currentSession,
    this.currentQuestion,
    this.questionQueue = const [],
    this.currentQuestionIndex = 0,
    this.isAnswered = false,
    this.lastAnswerCorrect,
    this.lastExplanation,
    this.wordProgress = const {},
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.dailyChallengesCompleted = 0,
    this.lastPlayedDate,
    this.error,
  });

  bool get isGameActive => currentSession != null && currentQuestion != null;
  bool get hasMoreQuestions => currentQuestionIndex < questionQueue.length - 1;
  int get questionsRemaining => questionQueue.length - currentQuestionIndex - 1;
  double get sessionProgress => questionQueue.isEmpty
      ? 0
      : (currentQuestionIndex + 1) / questionQueue.length;

  WordAssociationState copyWith({
    bool? isLoading,
    GameMode? currentMode,
    GameSession? currentSession,
    GameQuestion? currentQuestion,
    List<GameQuestion>? questionQueue,
    int? currentQuestionIndex,
    bool? isAnswered,
    bool? lastAnswerCorrect,
    String? lastExplanation,
    Map<String, WordProgress>? wordProgress,
    int? totalXP,
    int? currentStreak,
    int? longestStreak,
    int? dailyChallengesCompleted,
    DateTime? lastPlayedDate,
    String? error,
    bool clearSession = false,
    bool clearAnswer = false,
  }) {
    return WordAssociationState(
      isLoading: isLoading ?? this.isLoading,
      currentMode: currentMode ?? this.currentMode,
      currentSession: clearSession
          ? null
          : (currentSession ?? this.currentSession),
      currentQuestion: clearSession
          ? null
          : (currentQuestion ?? this.currentQuestion),
      questionQueue: clearSession
          ? const []
          : (questionQueue ?? this.questionQueue),
      currentQuestionIndex: clearSession
          ? 0
          : (currentQuestionIndex ?? this.currentQuestionIndex),
      isAnswered: clearAnswer ? false : (isAnswered ?? this.isAnswered),
      lastAnswerCorrect: clearAnswer
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      lastExplanation: clearAnswer
          ? null
          : (lastExplanation ?? this.lastExplanation),
      wordProgress: wordProgress ?? this.wordProgress,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      error: error,
    );
  }
}

// ===================
// Game Notifier
// ===================

class WordAssociationNotifier extends StateNotifier<WordAssociationState> {
  final Random _random = Random();

  WordAssociationNotifier() : super(const WordAssociationState()) {
    _loadProgress();
  }

  // ===================
  // Persistence
  // ===================

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        totalXP: prefs.getInt('word_assoc_xp') ?? 0,
        currentStreak: prefs.getInt('word_assoc_streak') ?? 0,
        longestStreak: prefs.getInt('word_assoc_longest_streak') ?? 0,
        dailyChallengesCompleted:
            prefs.getInt('word_assoc_daily_completed') ?? 0,
        lastPlayedDate: prefs.getString('word_assoc_last_played') != null
            ? DateTime.parse(prefs.getString('word_assoc_last_played')!)
            : null,
      );
      _checkDailyReset();
    } catch (e) {
      // Ignore errors, use default values
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('word_assoc_xp', state.totalXP);
      await prefs.setInt('word_assoc_streak', state.currentStreak);
      await prefs.setInt('word_assoc_longest_streak', state.longestStreak);
      await prefs.setInt(
        'word_assoc_daily_completed',
        state.dailyChallengesCompleted,
      );
      await prefs.setString(
        'word_assoc_last_played',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Ignore save errors
    }
  }

  void _checkDailyReset() {
    if (state.lastPlayedDate != null) {
      final now = DateTime.now();
      final lastPlayed = state.lastPlayedDate!;
      final daysSinceLastPlay = now.difference(lastPlayed).inDays;

      if (daysSinceLastPlay >= 1) {
        // Reset daily challenge count
        state = state.copyWith(dailyChallengesCompleted: 0);

        // Break streak if more than 1 day
        if (daysSinceLastPlay > 1) {
          state = state.copyWith(currentStreak: 0);
        }
      }
    }
  }

  // ===================
  // Game Control
  // ===================

  void startGame(GameMode mode) {
    state = state.copyWith(isLoading: true, currentMode: mode);

    final questions = _generateQuestions(mode);
    final session = GameSession(mode: mode, startedAt: DateTime.now());

    state = state.copyWith(
      isLoading: false,
      currentSession: session,
      questionQueue: questions,
      currentQuestionIndex: 0,
      currentQuestion: questions.isNotEmpty ? questions[0] : null,
      isAnswered: false,
      lastAnswerCorrect: null,
      lastExplanation: null,
    );
  }

  List<GameQuestion> _generateQuestions(GameMode mode) {
    final allWords = WordAssociationData.allWords;
    final questions = <GameQuestion>[];

    // Get words prioritizing those that need review
    final wordsToUse = _selectWordsForSession(allWords);

    switch (mode) {
      case GameMode.association:
        for (int i = 0; i < min(10, wordsToUse.length); i++) {
          questions.add(_createAssociationQuestion(wordsToUse[i]));
        }
        break;

      case GameMode.context:
        for (int i = 0; i < min(10, wordsToUse.length); i++) {
          questions.add(_createContextQuestion(wordsToUse[i]));
        }
        break;

      case GameMode.strengthOrdering:
        for (int i = 0; i < min(10, wordsToUse.length); i++) {
          questions.add(_createOrderingQuestion(wordsToUse[i]));
        }
        break;

      case GameMode.dailyChallenge:
        // Mix of all types
        final shuffled = List<WordAssociation>.from(wordsToUse)
          ..shuffle(_random);
        for (int i = 0; i < min(5, shuffled.length); i++) {
          final questionType = i % 3;
          switch (questionType) {
            case 0:
              questions.add(_createAssociationQuestion(shuffled[i]));
              break;
            case 1:
              questions.add(_createContextQuestion(shuffled[i]));
              break;
            case 2:
              questions.add(_createOrderingQuestion(shuffled[i]));
              break;
          }
        }
        break;
    }

    return questions..shuffle(_random);
  }

  List<WordAssociation> _selectWordsForSession(List<WordAssociation> allWords) {
    // Prioritize words that need review based on spaced repetition
    final needsReview = <WordAssociation>[];
    final others = <WordAssociation>[];

    for (final word in allWords) {
      final progress = state.wordProgress[word.id];
      if (progress == null || progress.needsReview || progress.accuracy < 0.7) {
        needsReview.add(word);
      } else {
        others.add(word);
      }
    }

    // Return a mix prioritizing words that need review
    needsReview.shuffle(_random);
    others.shuffle(_random);

    return [...needsReview.take(7), ...others.take(3)];
  }

  GameQuestion _createAssociationQuestion(WordAssociation word) {
    // Pick two correct associations and two distractors
    final correctAssociations = word.associations.map((a) => a.word).toList();
    final distractors = _getDistractors(word, 2);

    final options = [...correctAssociations.take(2), ...distractors]
      ..shuffle(_random);

    return GameQuestion(
      id: '${word.id}_assoc_${DateTime.now().millisecondsSinceEpoch}',
      mode: GameMode.association,
      wordData: word,
      options: options,
    );
  }

  GameQuestion _createContextQuestion(WordAssociation word) {
    // Pick a random word from the chain for the fill-in-the-blank
    final allWords = [word.baseWord, ...word.associations.map((a) => a.word)];
    final targetWord = allWords[_random.nextInt(allWords.length)];

    // Get the sentence and create a blank
    final sentence =
        word.sentences[targetWord] ?? 'Use $targetWord in a sentence.';
    final sentenceWithBlank = sentence.replaceAll(
      RegExp(targetWord, caseSensitive: false),
      '______',
    );

    // Create options including distractors
    final distractors = _getDistractors(word, 3);
    final options = [targetWord, ...distractors]..shuffle(_random);

    return GameQuestion(
      id: '${word.id}_context_${DateTime.now().millisecondsSinceEpoch}',
      mode: GameMode.context,
      wordData: word,
      sentenceWithBlank: sentenceWithBlank,
      correctAnswer: targetWord,
      options: options,
    );
  }

  GameQuestion _createOrderingQuestion(WordAssociation word) {
    // Get words in correct intensity order
    final correctOrder = word.wordsByIntensity;
    // Shuffle for the user to arrange
    final shuffledOptions = List<String>.from(correctOrder)..shuffle(_random);

    return GameQuestion(
      id: '${word.id}_order_${DateTime.now().millisecondsSinceEpoch}',
      mode: GameMode.strengthOrdering,
      wordData: word,
      options: shuffledOptions,
      correctOrder: correctOrder,
    );
  }

  List<String> _getDistractors(WordAssociation currentWord, int count) {
    final allWords = WordAssociationData.allWords;
    final distractors = <String>[];
    final currentWordSet = currentWord.allWords.toSet();

    for (final word in allWords) {
      if (word.id != currentWord.id) {
        for (final assoc in word.associations) {
          if (!currentWordSet.contains(assoc.word) &&
              !distractors.contains(assoc.word)) {
            distractors.add(assoc.word);
            if (distractors.length >= count * 2) break;
          }
        }
      }
      if (distractors.length >= count * 2) break;
    }

    distractors.shuffle(_random);
    return distractors.take(count).toList();
  }

  // ===================
  // Answer Handling
  // ===================

  void submitAssociationAnswer(List<String> selectedWords) {
    if (state.currentQuestion == null || state.isAnswered) return;

    final question = state.currentQuestion!;
    final word = question.wordData;
    final correctAssociations = word.associations.map((a) => a.word).toSet();

    // Check how many correct selections
    final correctSelections = selectedWords
        .where((w) => correctAssociations.contains(w))
        .length;
    final incorrectSelections = selectedWords
        .where((w) => !correctAssociations.contains(w))
        .length;

    final isCorrect = correctSelections >= 2 && incorrectSelections == 0;

    final explanation = isCorrect
        ? 'Excellent! "${word.baseWord}" is related to: ${word.associations.map((a) => a.word).join(", ")}.'
        : 'The correct associations for "${word.baseWord}" are: ${word.associations.map((a) => a.word).join(", ")}.';

    _processAnswer(isCorrect, explanation, word.id);
  }

  void submitContextAnswer(String selectedWord) {
    if (state.currentQuestion == null || state.isAnswered) return;

    final question = state.currentQuestion!;
    final isCorrect =
        selectedWord.toLowerCase() == question.correctAnswer?.toLowerCase();

    final word = question.wordData;
    final correctWord = question.correctAnswer!;
    final definition = correctWord == word.baseWord
        ? word.baseDefinition
        : word.associations
              .firstWhere(
                (a) => a.word == correctWord,
                orElse: () => word.associations.first,
              )
              .definition;

    final explanation = isCorrect
        ? 'Correct! "$correctWord" means: $definition'
        : 'The correct answer is "$correctWord". It means: $definition';

    _processAnswer(isCorrect, explanation, word.id);
  }

  void submitOrderingAnswer(List<String> orderedWords) {
    if (state.currentQuestion == null || state.isAnswered) return;

    final question = state.currentQuestion!;
    final correctOrder = question.correctOrder!;

    bool isCorrect = true;
    for (int i = 0; i < correctOrder.length && i < orderedWords.length; i++) {
      if (correctOrder[i] != orderedWords[i]) {
        isCorrect = false;
        break;
      }
    }

    final word = question.wordData;
    final explanation = isCorrect
        ? 'Perfect! The correct order from weakest to strongest is: ${correctOrder.join(" → ")}.'
        : 'The correct order is: ${correctOrder.join(" → ")}. Words get stronger as you go!';

    _processAnswer(isCorrect, explanation, word.id);
  }

  void _processAnswer(bool isCorrect, String explanation, String wordId) {
    // Calculate points
    final basePoints = isCorrect ? 10 : 0;
    final streakBonus = isCorrect ? min(state.currentStreak * 2, 20) : 0;
    final totalPoints = basePoints + streakBonus;

    // Update streak
    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final newLongestStreak = max(newStreak, state.longestStreak);

    // Update session
    final session = state.currentSession!;
    final newSession = session.copyWith(
      totalQuestions: session.totalQuestions + 1,
      correctAnswers: session.correctAnswers + (isCorrect ? 1 : 0),
      totalScore: session.totalScore + totalPoints,
      streak: newStreak,
      bestStreak: max(session.bestStreak, newStreak),
    );

    // Update word progress
    final progress =
        state.wordProgress[wordId] ??
        WordProgress(
          wordId: wordId,
          lastPracticed: DateTime.now(),
          nextReview: DateTime.now(),
        );

    final newProgress = _updateWordProgress(progress, isCorrect);
    final updatedProgressMap = Map<String, WordProgress>.from(
      state.wordProgress,
    );
    updatedProgressMap[wordId] = newProgress;

    state = state.copyWith(
      isAnswered: true,
      lastAnswerCorrect: isCorrect,
      lastExplanation: explanation,
      currentSession: newSession,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      totalXP: state.totalXP + totalPoints,
      wordProgress: updatedProgressMap,
    );

    _saveProgress();
  }

  WordProgress _updateWordProgress(WordProgress progress, bool isCorrect) {
    final newMastery = isCorrect
        ? min(progress.masteryLevel + 1, 5)
        : max(progress.masteryLevel - 1, 0);

    // Spaced repetition intervals (in hours)
    final intervals = [1, 4, 12, 24, 72, 168]; // 1h, 4h, 12h, 1d, 3d, 7d
    final nextReviewHours = intervals[newMastery];

    return progress.copyWith(
      correctCount: progress.correctCount + (isCorrect ? 1 : 0),
      incorrectCount: progress.incorrectCount + (isCorrect ? 0 : 1),
      lastPracticed: DateTime.now(),
      nextReview: DateTime.now().add(Duration(hours: nextReviewHours)),
      masteryLevel: newMastery,
    );
  }

  // ===================
  // Navigation
  // ===================

  void nextQuestion() {
    if (!state.hasMoreQuestions) {
      endGame();
      return;
    }

    final nextIndex = state.currentQuestionIndex + 1;
    state = state.copyWith(
      currentQuestionIndex: nextIndex,
      currentQuestion: state.questionQueue[nextIndex],
      clearAnswer: true,
    );
  }

  void endGame() {
    // Update daily challenge count if applicable
    if (state.currentMode == GameMode.dailyChallenge) {
      state = state.copyWith(
        dailyChallengesCompleted: state.dailyChallengesCompleted + 1,
      );
    }

    state = state.copyWith(lastPlayedDate: DateTime.now());

    _saveProgress();
  }

  void resetGame() {
    state = state.copyWith(clearSession: true, clearAnswer: true);
  }

  // ===================
  // Stats
  // ===================

  int get totalWordsLearned {
    return state.wordProgress.values.where((p) => p.masteryLevel >= 3).length;
  }

  int get wordsNeedingReview {
    return state.wordProgress.values.where((p) => p.needsReview).length;
  }

  double get overallAccuracy {
    if (state.wordProgress.isEmpty) return 0;
    final totalCorrect = state.wordProgress.values.fold(
      0,
      (sum, p) => sum + p.correctCount,
    );
    final totalAnswers = state.wordProgress.values.fold(
      0,
      (sum, p) => sum + p.correctCount + p.incorrectCount,
    );
    return totalAnswers > 0 ? totalCorrect / totalAnswers : 0;
  }
}

// ===================
// Provider
// ===================

final wordAssociationProvider =
    StateNotifierProvider<WordAssociationNotifier, WordAssociationState>((ref) {
      return WordAssociationNotifier();
    });
