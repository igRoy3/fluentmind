// User Journey Service - Persistent local storage for user's learning journey
// All data is user-generated, no mock data

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/user_journey.dart';

const _uuid = Uuid();

class UserJourneyService {
  static const String _profileKey = 'user_profile';
  static const String _wordsKey = 'learned_words';
  static const String _recordingsKey = 'voice_recordings';
  static const String _sessionsKey = 'daily_sessions';
  static const String _statsKey = 'journey_stats';
  static const String _achievementsKey = 'achievements';
  static const String _dailyFocusKey = 'daily_focus';
  static const String _onboardingCompleteKey = 'onboarding_complete_v2';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ==================
  // Onboarding State
  // ==================

  Future<bool> isOnboardingComplete() async {
    await init();
    return _prefs?.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await init();
    await _prefs?.setBool(_onboardingCompleteKey, complete);
  }

  // ==================
  // User Profile
  // ==================

  Future<UserProfile?> getUserProfile() async {
    await init();
    final json = _prefs?.getString(_profileKey);
    if (json == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await init();
    await _prefs?.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile> createProfile({
    String? name,
    required LearningGoal goal,
    required DailyCommitment commitment,
  }) async {
    final profile = UserProfile(
      id: _uuid.v4(),
      name: name,
      primaryGoal: goal,
      commitment: commitment,
      createdAt: DateTime.now(),
    );
    await saveUserProfile(profile);

    // Initialize empty stats
    await saveJourneyStats(UserJourneyStats());

    return profile;
  }

  // ==================
  // Learned Words (Vocabulary Bank)
  // ==================

  Future<List<LearnedWord>> getLearnedWords() async {
    await init();
    final json = _prefs?.getString(_wordsKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => LearnedWord.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveLearnedWords(List<LearnedWord> words) async {
    await init();
    await _prefs?.setString(
      _wordsKey,
      jsonEncode(words.map((e) => e.toJson()).toList()),
    );
  }

  Future<LearnedWord> addLearnedWord({
    required String word,
    required String definition,
    required String example,
    required String partOfSpeech,
  }) async {
    final words = await getLearnedWords();

    // Check if word already exists
    if (words.any((w) => w.word.toLowerCase() == word.toLowerCase())) {
      return words.firstWhere(
        (w) => w.word.toLowerCase() == word.toLowerCase(),
      );
    }

    final newWord = LearnedWord(
      word: word,
      definition: definition,
      example: example,
      partOfSpeech: partOfSpeech,
      learnedAt: DateTime.now(),
      nextReviewAt: DateTime.now().add(
        const Duration(hours: 4),
      ), // First review in 4 hours
    );

    words.add(newWord);
    await _saveLearnedWords(words);

    // Update stats
    final stats = await getJourneyStats();
    await saveJourneyStats(
      stats.copyWith(totalWordsLearned: stats.totalWordsLearned + 1),
    );

    // Check for achievements
    await _checkVocabularyAchievements(words.length);

    return newWord;
  }

  Future<void> updateWordReview({
    required String word,
    required bool wasCorrect,
  }) async {
    final words = await getLearnedWords();
    final index = words.indexWhere(
      (w) => w.word.toLowerCase() == word.toLowerCase(),
    );
    if (index == -1) return;

    final oldWord = words[index];
    final newMastery = wasCorrect
        ? (oldWord.masteryLevel < 5 ? oldWord.masteryLevel + 1 : 5)
        : (oldWord.masteryLevel > 0 ? oldWord.masteryLevel - 1 : 0);

    // Spaced repetition intervals (in days)
    final intervals = [0.17, 1, 3, 7, 14, 30]; // 4 hours, 1 day, 3 days...
    final nextReviewDays = intervals[newMastery.clamp(0, 5)];

    words[index] = oldWord.copyWith(
      reviewCount: oldWord.reviewCount + 1,
      correctCount: wasCorrect
          ? oldWord.correctCount + 1
          : oldWord.correctCount,
      masteryLevel: newMastery,
      nextReviewAt: DateTime.now().add(
        Duration(hours: (nextReviewDays * 24).round()),
      ),
      isDecaying: false,
    );

    await _saveLearnedWords(words);

    // Update retained count if mastery >= 3
    if (newMastery >= 3 && oldWord.masteryLevel < 3) {
      final stats = await getJourneyStats();
      await saveJourneyStats(
        stats.copyWith(wordsRetained: stats.wordsRetained + 1),
      );
    }
  }

  Future<List<LearnedWord>> getWordsNeedingReview() async {
    final words = await getLearnedWords();
    final now = DateTime.now();
    return words.where((w) => w.nextReviewAt.isBefore(now)).toList();
  }

  Future<List<LearnedWord>> getDecayingWords() async {
    final words = await getLearnedWords();
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    return words
        .where(
          (w) => w.nextReviewAt.isBefore(threeDaysAgo) && w.masteryLevel < 5,
        )
        .toList();
  }

  Future<void> markDecayingWords() async {
    final words = await getLearnedWords();
    final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    bool hasChanges = false;

    for (int i = 0; i < words.length; i++) {
      if (words[i].nextReviewAt.isBefore(threeDaysAgo) &&
          words[i].masteryLevel < 5 &&
          !words[i].isDecaying) {
        words[i] = words[i].copyWith(isDecaying: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveLearnedWords(words);
    }
  }

  // ==================
  // Voice Recordings
  // ==================

  Future<List<VoiceRecording>> getVoiceRecordings() async {
    await init();
    final json = _prefs?.getString(_recordingsKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => VoiceRecording.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveVoiceRecordings(List<VoiceRecording> recordings) async {
    await init();
    await _prefs?.setString(
      _recordingsKey,
      jsonEncode(recordings.map((e) => e.toJson()).toList()),
    );
  }

  Future<VoiceRecording?> getBaselineRecording() async {
    final recordings = await getVoiceRecordings();
    try {
      return recordings.firstWhere((r) => r.isBaseline);
    } catch (e) {
      return null;
    }
  }

  Future<VoiceRecording> addVoiceRecording({
    required String filePath,
    required Duration duration,
    String? transcription,
    int hesitationCount = 0,
    int fillerWordCount = 0,
    double wordsPerMinute = 0,
    int vocabularyRichness = 0,
    List<String> advancedWordsUsed = const [],
    double fluencyScore = 0,
    double pronunciationScore = 0,
    bool isBaseline = false,
  }) async {
    final recordings = await getVoiceRecordings();

    final recording = VoiceRecording(
      id: _uuid.v4(),
      filePath: filePath,
      recordedAt: DateTime.now(),
      duration: duration,
      transcription: transcription,
      hesitationCount: hesitationCount,
      fillerWordCount: fillerWordCount,
      wordsPerMinute: wordsPerMinute,
      vocabularyRichness: vocabularyRichness,
      advancedWordsUsed: advancedWordsUsed,
      fluencyScore: fluencyScore,
      pronunciationScore: pronunciationScore,
      isBaseline: isBaseline,
    );

    recordings.add(recording);
    await _saveVoiceRecordings(recordings);

    // Update stats
    final stats = await getJourneyStats();
    await saveJourneyStats(
      stats.copyWith(totalRecordings: stats.totalRecordings + 1),
    );

    return recording;
  }

  Future<VoiceRecording?> getLatestRecording() async {
    final recordings = await getVoiceRecordings();
    if (recordings.isEmpty) return null;
    recordings.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return recordings.first;
  }

  // ==================
  // Daily Sessions
  // ==================

  Future<List<DailySession>> getDailySessions() async {
    await init();
    final json = _prefs?.getString(_sessionsKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => DailySession.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveDailySessions(List<DailySession> sessions) async {
    await init();
    await _prefs?.setString(
      _sessionsKey,
      jsonEncode(sessions.map((e) => e.toJson()).toList()),
    );
  }

  Future<DailySession> getTodaySession() async {
    final sessions = await getDailySessions();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    try {
      return sessions.firstWhere(
        (s) =>
            s.date.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            s.date.isBefore(todayStart.add(const Duration(days: 1))),
      );
    } catch (e) {
      // Create new session for today
      final newSession = DailySession(id: _uuid.v4(), date: today);
      sessions.add(newSession);
      await _saveDailySessions(sessions);
      return newSession;
    }
  }

  Future<void> updateTodaySession({
    int? addMinutes,
    String? wordLearned,
    String? wordReviewed,
    bool? reviewCorrect,
    String? recordingId,
    double? fluencyScore,
    String? highlight,
  }) async {
    final sessions = await getDailySessions();
    final today = await getTodaySession();
    final index = sessions.indexWhere((s) => s.id == today.id);

    if (index == -1) return;

    sessions[index] = today.copyWith(
      durationMinutes: addMinutes != null
          ? today.durationMinutes + addMinutes
          : today.durationMinutes,
      wordsLearned: wordLearned != null
          ? [...today.wordsLearned, wordLearned]
          : today.wordsLearned,
      wordsReviewed: wordReviewed != null
          ? [...today.wordsReviewed, wordReviewed]
          : today.wordsReviewed,
      correctReviews: reviewCorrect == true
          ? today.correctReviews + 1
          : today.correctReviews,
      totalReviews: wordReviewed != null
          ? today.totalReviews + 1
          : today.totalReviews,
      recordingIds: recordingId != null
          ? [...today.recordingIds, recordingId]
          : today.recordingIds,
      avgFluencyScore: fluencyScore ?? today.avgFluencyScore,
      highlight: highlight ?? today.highlight,
    );

    await _saveDailySessions(sessions);

    // Update journey stats
    await _updateStatsFromSession(sessions[index]);
  }

  Future<DailySession?> getYesterdaySession() async {
    final sessions = await getDailySessions();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );

    try {
      return sessions.firstWhere(
        (s) =>
            s.date.isAfter(
              yesterdayStart.subtract(const Duration(seconds: 1)),
            ) &&
            s.date.isBefore(yesterdayStart.add(const Duration(days: 1))),
      );
    } catch (e) {
      return null;
    }
  }

  // ==================
  // Journey Stats
  // ==================

  Future<UserJourneyStats> getJourneyStats() async {
    await init();
    final json = _prefs?.getString(_statsKey);
    if (json == null) return UserJourneyStats();
    try {
      return UserJourneyStats.fromJson(jsonDecode(json));
    } catch (e) {
      return UserJourneyStats();
    }
  }

  Future<void> saveJourneyStats(UserJourneyStats stats) async {
    await init();
    await _prefs?.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<void> _updateStatsFromSession(DailySession session) async {
    final stats = await getJourneyStats();
    final sessions = await getDailySessions();

    // Calculate streak
    int streak = 0;
    final sortedSessions = sessions.where((s) => s.isComplete).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedSessions.isNotEmpty) {
      DateTime checkDate = DateTime.now();
      for (final s in sortedSessions) {
        final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
        final check = DateTime(checkDate.year, checkDate.month, checkDate.day);

        if (sessionDate == check ||
            sessionDate == check.subtract(const Duration(days: 1))) {
          streak++;
          checkDate = sessionDate;
        } else {
          break;
        }
      }
    }

    // Calculate total minutes
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.durationMinutes,
    );

    await saveJourneyStats(
      stats.copyWith(
        totalDaysActive: sessions.where((s) => s.isComplete).length,
        currentStreak: streak,
        longestStreak: streak > stats.longestStreak
            ? streak
            : stats.longestStreak,
        totalMinutesPracticed: totalMinutes,
        lastSessionDate: DateTime.now(),
      ),
    );
  }

  // ==================
  // Daily Focus
  // ==================

  Future<DailyFocus> generateDailyFocus() async {
    final words = await getLearnedWords();
    final decayingWords = await getDecayingWords();
    final recordings = await getVoiceRecordings();
    final yesterday = await getYesterdaySession();

    // Priority 1: Decaying words
    if (decayingWords.isNotEmpty) {
      final word = decayingWords.first;
      return DailyFocus(
        title: 'Save "${word.word}"',
        description:
            'This word is slipping away. Quick 30-second review to save it!',
        type: FocusType.vocabulary,
        targetWord: word.word,
      );
    }

    // Priority 2: Based on yesterday's weak area
    if (yesterday != null && yesterday.wordsLearned.isNotEmpty) {
      return DailyFocus(
        title: 'Master yesterday\'s words',
        description:
            'You learned ${yesterday.wordsLearned.length} words. Let\'s make sure they stick!',
        type: FocusType.vocabulary,
      );
    }

    // Priority 3: Fluency improvement
    if (recordings.length >= 2) {
      final recent = recordings.last;
      final baseline = await getBaselineRecording();
      if (baseline != null && recent.hesitationCount > 3) {
        return DailyFocus(
          title: 'Reduce hesitations',
          description:
              'Your last session had ${recent.hesitationCount} pauses. Let\'s work on flow!',
          type: FocusType.hesitation,
          targetReduction: 2,
        );
      }
    }

    // Default: Learn new words
    return DailyFocus(
      title: 'Expand your vocabulary',
      description: 'Learn 5 new words today to grow your language skills.',
      type: FocusType.vocabulary,
    );
  }

  // ==================
  // Achievements
  // ==================

  Future<List<Achievement>> getAchievements() async {
    await init();
    final json = _prefs?.getString(_achievementsKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => Achievement.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveAchievements(List<Achievement> achievements) async {
    await init();
    await _prefs?.setString(
      _achievementsKey,
      jsonEncode(achievements.map((e) => e.toJson()).toList()),
    );
  }

  Future<Achievement?> _addAchievement({
    required String id,
    required String title,
    required String description,
    required AchievementType type,
    required String icon,
  }) async {
    final achievements = await getAchievements();

    // Don't add duplicate achievements
    if (achievements.any((a) => a.id == id)) return null;

    final achievement = Achievement(
      id: id,
      title: title,
      description: description,
      type: type,
      earnedAt: DateTime.now(),
      icon: icon,
    );

    achievements.add(achievement);
    await _saveAchievements(achievements);
    return achievement;
  }

  Future<Achievement?> _checkVocabularyAchievements(int wordCount) async {
    if (wordCount == 10) {
      return _addAchievement(
        id: 'vocab_10',
        title: 'Word Collector',
        description: 'Learned your first 10 words!',
        type: AchievementType.vocabulary,
        icon: '📚',
      );
    } else if (wordCount == 50) {
      return _addAchievement(
        id: 'vocab_50',
        title: 'Vocabulary Builder',
        description: 'Mastered 50 words!',
        type: AchievementType.vocabulary,
        icon: '🎯',
      );
    } else if (wordCount == 100) {
      return _addAchievement(
        id: 'vocab_100',
        title: 'Word Master',
        description: 'Amazing! 100 words in your vocabulary bank!',
        type: AchievementType.vocabulary,
        icon: '🏆',
      );
    }
    return null;
  }

  Future<Achievement?> checkStreakAchievements() async {
    final stats = await getJourneyStats();

    if (stats.currentStreak == 7) {
      return _addAchievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: '7 days of consistent practice!',
        type: AchievementType.streak,
        icon: '🔥',
      );
    } else if (stats.currentStreak == 30) {
      return _addAchievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: '30 days! You\'re building a real habit.',
        type: AchievementType.streak,
        icon: '⭐',
      );
    }
    return null;
  }

  // ==================
  // Greeting & Personalization
  // ==================

  Future<String> getPersonalizedGreeting() async {
    final profile = await getUserProfile();
    final stats = await getJourneyStats();
    final yesterday = await getYesterdaySession();

    // Get user name for personalized greeting
    String userName = '';
    if (profile?.name != null && profile!.name!.isNotEmpty) {
      userName = profile.name!.split(' ').first; // Use first name only
    }

    // Prioritized contextual messages

    // Streak milestones
    if (stats.currentStreak == 7) {
      return userName.isNotEmpty
          ? 'Hey $userName! 🔥 One week streak!'
          : '🔥 One week streak! You\'re building a habit.';
    }
    if (stats.currentStreak == 30) {
      return userName.isNotEmpty
          ? 'Wow $userName! 🏆 30 days! You\'re a champion.'
          : '🏆 30 days! You\'re officially dedicated.';
    }
    if (stats.currentStreak >= 3 && stats.currentStreak < 7) {
      return userName.isNotEmpty
          ? 'Hey $userName! Day ${stats.currentStreak} - keep going! 🔥'
          : 'Day ${stats.currentStreak} - keep the momentum! 🔥';
    }

    // Yesterday's progress
    if (yesterday != null && yesterday.wordsLearned.isNotEmpty) {
      final lastWord = yesterday.wordsLearned.last;
      return userName.isNotEmpty
          ? 'Hey $userName! Yesterday you nailed "$lastWord". Ready for more?'
          : 'Yesterday you nailed "$lastWord". Ready to add more?';
    }

    // For returning users with stats
    if (stats.totalWordsLearned > 0) {
      return userName.isNotEmpty
          ? 'Hey $userName! ${stats.wordsRetained} words in your vocabulary. 📚'
          : '${stats.wordsRetained} words in your vocabulary. Keep growing! 📚';
    }

    // New user
    return userName.isNotEmpty
        ? 'Welcome $userName! Ready to begin? 🚀'
        : 'Welcome! Ready to begin your journey? 🚀';
  }

  // ==================
  // Clear All Data (for testing)
  // ==================

  Future<void> clearAllData() async {
    await init();
    await _prefs?.remove(_profileKey);
    await _prefs?.remove(_wordsKey);
    await _prefs?.remove(_recordingsKey);
    await _prefs?.remove(_sessionsKey);
    await _prefs?.remove(_statsKey);
    await _prefs?.remove(_achievementsKey);
    await _prefs?.remove(_dailyFocusKey);
    await _prefs?.remove(_onboardingCompleteKey);
  }
}

// Provider
final userJourneyServiceProvider = Provider<UserJourneyService>((ref) {
  return UserJourneyService();
});
