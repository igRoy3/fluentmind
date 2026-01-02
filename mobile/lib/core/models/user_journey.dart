// User Journey Data Models for FluentMind
// These models track the user's complete learning journey with real data

/// User's primary learning goal
enum LearningGoal {
  expandVocabulary('Expand my vocabulary'),
  sharpenFocus('Sharpen my focus & memory'),
  thinkFaster('Think faster & smarter'),
  speakConfidently('Speak more confidently');

  final String description;
  const LearningGoal(this.description);
}

/// Daily commitment level
enum DailyCommitment {
  light(5, 'Quick practice'),
  moderate(10, 'Focused session'),
  intensive(15, 'Deep learning');

  final int minutes;
  final String label;
  const DailyCommitment(this.minutes, this.label);
}

/// Energy level for session intensity
enum EnergyLevel {
  quick('I have 5 min', 5),
  focused('I\'m ready to focus', 10),
  challenge('Challenge me', 15);

  final String label;
  final int minutes;
  const EnergyLevel(this.label, this.minutes);
}

/// User's onboarding profile captured on first launch
class UserProfile {
  final String id;
  final String? name;
  final LearningGoal primaryGoal;
  final DailyCommitment commitment;
  final DateTime createdAt;
  final String? baselineRecordingPath;
  final int initialVocabularyLevel;
  final int initialFluencyLevel;

  UserProfile({
    required this.id,
    this.name,
    required this.primaryGoal,
    required this.commitment,
    required this.createdAt,
    this.baselineRecordingPath,
    this.initialVocabularyLevel = 0,
    this.initialFluencyLevel = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'primaryGoal': primaryGoal.index,
    'commitment': commitment.index,
    'createdAt': createdAt.toIso8601String(),
    'baselineRecordingPath': baselineRecordingPath,
    'initialVocabularyLevel': initialVocabularyLevel,
    'initialFluencyLevel': initialFluencyLevel,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    primaryGoal: LearningGoal.values[json['primaryGoal']],
    commitment: DailyCommitment.values[json['commitment']],
    createdAt: DateTime.parse(json['createdAt']),
    baselineRecordingPath: json['baselineRecordingPath'],
    initialVocabularyLevel: json['initialVocabularyLevel'] ?? 0,
    initialFluencyLevel: json['initialFluencyLevel'] ?? 0,
  );

  UserProfile copyWith({
    String? name,
    LearningGoal? primaryGoal,
    DailyCommitment? commitment,
    String? baselineRecordingPath,
    int? initialVocabularyLevel,
    int? initialFluencyLevel,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    primaryGoal: primaryGoal ?? this.primaryGoal,
    commitment: commitment ?? this.commitment,
    createdAt: createdAt,
    baselineRecordingPath: baselineRecordingPath ?? this.baselineRecordingPath,
    initialVocabularyLevel:
        initialVocabularyLevel ?? this.initialVocabularyLevel,
    initialFluencyLevel: initialFluencyLevel ?? this.initialFluencyLevel,
  );
}

/// A learned word with retention tracking (spaced repetition)
class LearnedWord {
  final String word;
  final String definition;
  final String example;
  final String partOfSpeech;
  final DateTime learnedAt;
  final DateTime nextReviewAt;
  final int reviewCount;
  final int correctCount;
  final int masteryLevel; // 0-5 (0=new, 5=mastered)
  final bool isDecaying; // Not reviewed in 3+ days

  LearnedWord({
    required this.word,
    required this.definition,
    required this.example,
    required this.partOfSpeech,
    required this.learnedAt,
    required this.nextReviewAt,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.masteryLevel = 0,
    this.isDecaying = false,
  });

  double get retentionRate => reviewCount > 0 ? correctCount / reviewCount : 0;

  bool get needsReview => DateTime.now().isAfter(nextReviewAt);

  bool get isRetained => masteryLevel >= 3;

  Map<String, dynamic> toJson() => {
    'word': word,
    'definition': definition,
    'example': example,
    'partOfSpeech': partOfSpeech,
    'learnedAt': learnedAt.toIso8601String(),
    'nextReviewAt': nextReviewAt.toIso8601String(),
    'reviewCount': reviewCount,
    'correctCount': correctCount,
    'masteryLevel': masteryLevel,
    'isDecaying': isDecaying,
  };

  factory LearnedWord.fromJson(Map<String, dynamic> json) => LearnedWord(
    word: json['word'],
    definition: json['definition'],
    example: json['example'],
    partOfSpeech: json['partOfSpeech'],
    learnedAt: DateTime.parse(json['learnedAt']),
    nextReviewAt: DateTime.parse(json['nextReviewAt']),
    reviewCount: json['reviewCount'] ?? 0,
    correctCount: json['correctCount'] ?? 0,
    masteryLevel: json['masteryLevel'] ?? 0,
    isDecaying: json['isDecaying'] ?? false,
  );

  LearnedWord copyWith({
    DateTime? nextReviewAt,
    int? reviewCount,
    int? correctCount,
    int? masteryLevel,
    bool? isDecaying,
  }) => LearnedWord(
    word: word,
    definition: definition,
    example: example,
    partOfSpeech: partOfSpeech,
    learnedAt: learnedAt,
    nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    reviewCount: reviewCount ?? this.reviewCount,
    correctCount: correctCount ?? this.correctCount,
    masteryLevel: masteryLevel ?? this.masteryLevel,
    isDecaying: isDecaying ?? this.isDecaying,
  );
}

/// Voice recording with analysis metrics
class VoiceRecording {
  final String id;
  final String filePath;
  final DateTime recordedAt;
  final Duration duration;
  final String? transcription;
  final int hesitationCount;
  final int fillerWordCount;
  final double wordsPerMinute;
  final int vocabularyRichness; // Unique words used
  final List<String> advancedWordsUsed;
  final double fluencyScore;
  final double pronunciationScore;
  final bool isBaseline;

  VoiceRecording({
    required this.id,
    required this.filePath,
    required this.recordedAt,
    required this.duration,
    this.transcription,
    this.hesitationCount = 0,
    this.fillerWordCount = 0,
    this.wordsPerMinute = 0,
    this.vocabularyRichness = 0,
    this.advancedWordsUsed = const [],
    this.fluencyScore = 0,
    this.pronunciationScore = 0,
    this.isBaseline = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'recordedAt': recordedAt.toIso8601String(),
    'duration': duration.inSeconds,
    'transcription': transcription,
    'hesitationCount': hesitationCount,
    'fillerWordCount': fillerWordCount,
    'wordsPerMinute': wordsPerMinute,
    'vocabularyRichness': vocabularyRichness,
    'advancedWordsUsed': advancedWordsUsed,
    'fluencyScore': fluencyScore,
    'pronunciationScore': pronunciationScore,
    'isBaseline': isBaseline,
  };

  factory VoiceRecording.fromJson(Map<String, dynamic> json) => VoiceRecording(
    id: json['id'],
    filePath: json['filePath'],
    recordedAt: DateTime.parse(json['recordedAt']),
    duration: Duration(seconds: json['duration']),
    transcription: json['transcription'],
    hesitationCount: json['hesitationCount'] ?? 0,
    fillerWordCount: json['fillerWordCount'] ?? 0,
    wordsPerMinute: (json['wordsPerMinute'] ?? 0).toDouble(),
    vocabularyRichness: json['vocabularyRichness'] ?? 0,
    advancedWordsUsed: List<String>.from(json['advancedWordsUsed'] ?? []),
    fluencyScore: (json['fluencyScore'] ?? 0).toDouble(),
    pronunciationScore: (json['pronunciationScore'] ?? 0).toDouble(),
    isBaseline: json['isBaseline'] ?? false,
  );
}

/// Daily session tracking
class DailySession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final List<String> wordsLearned;
  final List<String> wordsReviewed;
  final int correctReviews;
  final int totalReviews;
  final List<String> recordingIds;
  final double avgFluencyScore;
  final int hesitationsReduced;
  final String? highlight; // Notable achievement

  DailySession({
    required this.id,
    required this.date,
    this.durationMinutes = 0,
    this.wordsLearned = const [],
    this.wordsReviewed = const [],
    this.correctReviews = 0,
    this.totalReviews = 0,
    this.recordingIds = const [],
    this.avgFluencyScore = 0,
    this.hesitationsReduced = 0,
    this.highlight,
  });

  bool get isComplete => durationMinutes >= 5;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'wordsLearned': wordsLearned,
    'wordsReviewed': wordsReviewed,
    'correctReviews': correctReviews,
    'totalReviews': totalReviews,
    'recordingIds': recordingIds,
    'avgFluencyScore': avgFluencyScore,
    'hesitationsReduced': hesitationsReduced,
    'highlight': highlight,
  };

  factory DailySession.fromJson(Map<String, dynamic> json) => DailySession(
    id: json['id'],
    date: DateTime.parse(json['date']),
    durationMinutes: json['durationMinutes'] ?? 0,
    wordsLearned: List<String>.from(json['wordsLearned'] ?? []),
    wordsReviewed: List<String>.from(json['wordsReviewed'] ?? []),
    correctReviews: json['correctReviews'] ?? 0,
    totalReviews: json['totalReviews'] ?? 0,
    recordingIds: List<String>.from(json['recordingIds'] ?? []),
    avgFluencyScore: (json['avgFluencyScore'] ?? 0).toDouble(),
    hesitationsReduced: json['hesitationsReduced'] ?? 0,
    highlight: json['highlight'],
  );

  DailySession copyWith({
    int? durationMinutes,
    List<String>? wordsLearned,
    List<String>? wordsReviewed,
    int? correctReviews,
    int? totalReviews,
    List<String>? recordingIds,
    double? avgFluencyScore,
    int? hesitationsReduced,
    String? highlight,
  }) => DailySession(
    id: id,
    date: date,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    wordsLearned: wordsLearned ?? this.wordsLearned,
    wordsReviewed: wordsReviewed ?? this.wordsReviewed,
    correctReviews: correctReviews ?? this.correctReviews,
    totalReviews: totalReviews ?? this.totalReviews,
    recordingIds: recordingIds ?? this.recordingIds,
    avgFluencyScore: avgFluencyScore ?? this.avgFluencyScore,
    hesitationsReduced: hesitationsReduced ?? this.hesitationsReduced,
    highlight: highlight ?? this.highlight,
  );
}

/// Today's focus card - personalized daily objective
class DailyFocus {
  final String title;
  final String description;
  final FocusType type;
  final int estimatedMinutes;
  final String? targetWord; // For vocabulary focus
  final int? targetReduction; // For hesitation focus
  final bool isCompleted;

  DailyFocus({
    required this.title,
    required this.description,
    required this.type,
    this.estimatedMinutes = 5,
    this.targetWord,
    this.targetReduction,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type.index,
    'estimatedMinutes': estimatedMinutes,
    'targetWord': targetWord,
    'targetReduction': targetReduction,
    'isCompleted': isCompleted,
  };

  factory DailyFocus.fromJson(Map<String, dynamic> json) => DailyFocus(
    title: json['title'],
    description: json['description'],
    type: FocusType.values[json['type']],
    estimatedMinutes: json['estimatedMinutes'] ?? 5,
    targetWord: json['targetWord'],
    targetReduction: json['targetReduction'],
    isCompleted: json['isCompleted'] ?? false,
  );
}

enum FocusType { vocabulary, fluency, pronunciation, hesitation, cognitive }

/// User's complete learning journey stats
class UserJourneyStats {
  final int totalDaysActive;
  final int currentStreak;
  final int longestStreak;
  final int totalWordsLearned;
  final int wordsRetained; // Passed retention test
  final int totalRecordings;
  final int totalMinutesPracticed;
  final int totalGameSessions; // Brain games played
  final double avgFluencyScore;
  final double fluencyImprovement; // vs baseline
  final int hesitationReduction; // vs baseline
  final DateTime? lastSessionDate;

  UserJourneyStats({
    this.totalDaysActive = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWordsLearned = 0,
    this.wordsRetained = 0,
    this.totalRecordings = 0,
    this.totalMinutesPracticed = 0,
    this.totalGameSessions = 0,
    this.avgFluencyScore = 0,
    this.fluencyImprovement = 0,
    this.hesitationReduction = 0,
    this.lastSessionDate,
  });

  double get retentionRate =>
      totalWordsLearned > 0 ? wordsRetained / totalWordsLearned : 0;

  Map<String, dynamic> toJson() => {
    'totalDaysActive': totalDaysActive,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalWordsLearned': totalWordsLearned,
    'wordsRetained': wordsRetained,
    'totalRecordings': totalRecordings,
    'totalMinutesPracticed': totalMinutesPracticed,
    'totalGameSessions': totalGameSessions,
    'avgFluencyScore': avgFluencyScore,
    'fluencyImprovement': fluencyImprovement,
    'hesitationReduction': hesitationReduction,
    'lastSessionDate': lastSessionDate?.toIso8601String(),
  };

  factory UserJourneyStats.fromJson(Map<String, dynamic> json) =>
      UserJourneyStats(
        totalDaysActive: json['totalDaysActive'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        totalWordsLearned: json['totalWordsLearned'] ?? 0,
        wordsRetained: json['wordsRetained'] ?? 0,
        totalRecordings: json['totalRecordings'] ?? 0,
        totalMinutesPracticed: json['totalMinutesPracticed'] ?? 0,
        totalGameSessions: json['totalGameSessions'] ?? 0,
        avgFluencyScore: (json['avgFluencyScore'] ?? 0).toDouble(),
        fluencyImprovement: (json['fluencyImprovement'] ?? 0).toDouble(),
        hesitationReduction: json['hesitationReduction'] ?? 0,
        lastSessionDate: json['lastSessionDate'] != null
            ? DateTime.parse(json['lastSessionDate'])
            : null,
      );

  UserJourneyStats copyWith({
    int? totalDaysActive,
    int? currentStreak,
    int? longestStreak,
    int? totalWordsLearned,
    int? wordsRetained,
    int? totalRecordings,
    int? totalMinutesPracticed,
    int? totalGameSessions,
    double? avgFluencyScore,
    double? fluencyImprovement,
    int? hesitationReduction,
    DateTime? lastSessionDate,
  }) => UserJourneyStats(
    totalDaysActive: totalDaysActive ?? this.totalDaysActive,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
    wordsRetained: wordsRetained ?? this.wordsRetained,
    totalRecordings: totalRecordings ?? this.totalRecordings,
    totalMinutesPracticed: totalMinutesPracticed ?? this.totalMinutesPracticed,
    totalGameSessions: totalGameSessions ?? this.totalGameSessions,
    avgFluencyScore: avgFluencyScore ?? this.avgFluencyScore,
    fluencyImprovement: fluencyImprovement ?? this.fluencyImprovement,
    hesitationReduction: hesitationReduction ?? this.hesitationReduction,
    lastSessionDate: lastSessionDate ?? this.lastSessionDate,
  );
}

/// Achievement earned by user (verified milestones only)
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final DateTime earnedAt;
  final String icon;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.earnedAt,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.index,
    'earnedAt': earnedAt.toIso8601String(),
    'icon': icon,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    type: AchievementType.values[json['type']],
    earnedAt: DateTime.parse(json['earnedAt']),
    icon: json['icon'],
  );
}

enum AchievementType {
  vocabulary, // Word milestones
  streak, // Consistency
  fluency, // Speaking improvement
  retention, // Memory mastery
  milestone, // General progress
}
