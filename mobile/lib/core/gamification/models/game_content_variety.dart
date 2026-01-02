/// Game Content Variety System for FluentMind
/// Ensures minimal repetition and maintains engagement through smart content rotation
library;

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_difficulty_models.dart';

// ===================
// CONTENT VARIETY ENGINE
// ===================

class ContentVarietyEngine {
  static const int _maxHistoryPerCategory = 50;
  static const double _recentContentAvoidanceWeight = 0.8;

  /// Select content avoiding recent items
  static T selectWithVariety<T>({
    required List<T> availableContent,
    required List<String> recentlyUsedIds,
    required String Function(T) getId,
    int minTimeSinceLastUse = 3, // Minimum sessions before reuse
  }) {
    if (availableContent.isEmpty) {
      throw Exception('No content available');
    }

    // Filter out recently used content
    final eligibleContent = availableContent.where((item) {
      final id = getId(item);
      final lastUseIndex = recentlyUsedIds.indexOf(id);
      return lastUseIndex == -1 || lastUseIndex >= minTimeSinceLastUse;
    }).toList();

    // If all content was recently used, use weighted random selection
    if (eligibleContent.isEmpty) {
      return _weightedRandomSelection(availableContent, recentlyUsedIds, getId);
    }

    // Random selection from eligible content
    final random = Random();
    return eligibleContent[random.nextInt(eligibleContent.length)];
  }

  static T _weightedRandomSelection<T>(
    List<T> content,
    List<String> recentlyUsedIds,
    String Function(T) getId,
  ) {
    final random = Random();
    final weights = <double>[];

    for (final item in content) {
      final id = getId(item);
      final lastUseIndex = recentlyUsedIds.indexOf(id);

      if (lastUseIndex == -1) {
        weights.add(1.0);
      } else {
        // Lower weight for more recently used items
        weights.add(
          (lastUseIndex / recentlyUsedIds.length) *
              _recentContentAvoidanceWeight,
        );
      }
    }

    // Normalize weights
    final totalWeight = weights.reduce((a, b) => a + b);
    final normalizedWeights = weights.map((w) => w / totalWeight).toList();

    // Weighted random selection
    double randomValue = random.nextDouble();
    double cumulativeWeight = 0;

    for (int i = 0; i < content.length; i++) {
      cumulativeWeight += normalizedWeights[i];
      if (randomValue <= cumulativeWeight) {
        return content[i];
      }
    }

    return content.last;
  }
}

// ===================
// CONTENT HISTORY TRACKER
// ===================

class ContentHistoryTracker {
  static const String _storageKey = 'content_history';

  Map<String, List<String>> _history = {};

  ContentHistoryTracker() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      _history = decoded.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_history));
  }

  /// Record that content was used
  Future<void> recordContentUsage(String category, String contentId) async {
    _history[category] ??= [];
    _history[category]!.insert(0, contentId);

    // Trim history to max size
    if (_history[category]!.length >
        ContentVarietyEngine._maxHistoryPerCategory) {
      _history[category] = _history[category]!
          .take(ContentVarietyEngine._maxHistoryPerCategory)
          .toList();
    }

    await _saveHistory();
  }

  /// Get recent content IDs for a category
  List<String> getRecentContent(String category) {
    return _history[category] ?? [];
  }

  /// Clear history for a category
  Future<void> clearHistory(String category) async {
    _history.remove(category);
    await _saveHistory();
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    _history = {};
    await _saveHistory();
  }
}

// ===================
// WORD POOLS BY DIFFICULTY
// ===================

class WordPoolManager {
  // Beginner words (4-6 letters, common)
  static const List<WordEntry> beginnerWords = [
    WordEntry(word: 'happy', category: 'emotion', difficulty: 1),
    WordEntry(word: 'smile', category: 'emotion', difficulty: 1),
    WordEntry(word: 'house', category: 'place', difficulty: 1),
    WordEntry(word: 'water', category: 'nature', difficulty: 1),
    WordEntry(word: 'music', category: 'art', difficulty: 1),
    WordEntry(word: 'green', category: 'color', difficulty: 1),
    WordEntry(word: 'sleep', category: 'action', difficulty: 1),
    WordEntry(word: 'friend', category: 'people', difficulty: 1),
    WordEntry(word: 'dream', category: 'thought', difficulty: 1),
    WordEntry(word: 'heart', category: 'body', difficulty: 1),
    WordEntry(word: 'light', category: 'nature', difficulty: 1),
    WordEntry(word: 'space', category: 'place', difficulty: 1),
    WordEntry(word: 'story', category: 'art', difficulty: 1),
    WordEntry(word: 'magic', category: 'abstract', difficulty: 1),
    WordEntry(word: 'ocean', category: 'nature', difficulty: 1),
    WordEntry(word: 'brave', category: 'trait', difficulty: 1),
    WordEntry(word: 'peace', category: 'emotion', difficulty: 1),
    WordEntry(word: 'power', category: 'abstract', difficulty: 1),
    WordEntry(word: 'world', category: 'place', difficulty: 1),
    WordEntry(word: 'shine', category: 'action', difficulty: 1),
  ];

  // Intermediate words (6-9 letters)
  static const List<WordEntry> intermediateWords = [
    WordEntry(word: 'adventure', category: 'experience', difficulty: 2),
    WordEntry(word: 'beautiful', category: 'description', difficulty: 2),
    WordEntry(word: 'challenge', category: 'experience', difficulty: 2),
    WordEntry(word: 'discovery', category: 'experience', difficulty: 2),
    WordEntry(word: 'elephant', category: 'animal', difficulty: 2),
    WordEntry(word: 'freedom', category: 'abstract', difficulty: 2),
    WordEntry(word: 'grateful', category: 'emotion', difficulty: 2),
    WordEntry(word: 'harmony', category: 'abstract', difficulty: 2),
    WordEntry(word: 'imagine', category: 'action', difficulty: 2),
    WordEntry(word: 'journey', category: 'experience', difficulty: 2),
    WordEntry(word: 'knowledge', category: 'abstract', difficulty: 2),
    WordEntry(word: 'language', category: 'abstract', difficulty: 2),
    WordEntry(word: 'mountain', category: 'nature', difficulty: 2),
    WordEntry(word: 'navigate', category: 'action', difficulty: 2),
    WordEntry(word: 'orchestra', category: 'art', difficulty: 2),
    WordEntry(word: 'patience', category: 'trait', difficulty: 2),
    WordEntry(word: 'question', category: 'abstract', difficulty: 2),
    WordEntry(word: 'remember', category: 'action', difficulty: 2),
    WordEntry(word: 'sunshine', category: 'nature', difficulty: 2),
    WordEntry(word: 'treasure', category: 'object', difficulty: 2),
    WordEntry(word: 'universe', category: 'nature', difficulty: 2),
    WordEntry(word: 'valuable', category: 'description', difficulty: 2),
    WordEntry(word: 'wanderer', category: 'people', difficulty: 2),
    WordEntry(word: 'yesterday', category: 'time', difficulty: 2),
    WordEntry(word: 'zeppelin', category: 'object', difficulty: 2),
  ];

  // Advanced words (8-12 letters)
  static const List<WordEntry> advancedWords = [
    WordEntry(word: 'accomplishment', category: 'experience', difficulty: 3),
    WordEntry(word: 'benevolent', category: 'trait', difficulty: 3),
    WordEntry(word: 'catastrophe', category: 'event', difficulty: 3),
    WordEntry(word: 'determination', category: 'trait', difficulty: 3),
    WordEntry(word: 'effervescent', category: 'description', difficulty: 3),
    WordEntry(word: 'fundamental', category: 'abstract', difficulty: 3),
    WordEntry(word: 'grandiloquent', category: 'description', difficulty: 3),
    WordEntry(word: 'hypothetical', category: 'abstract', difficulty: 3),
    WordEntry(word: 'infrastructure', category: 'abstract', difficulty: 3),
    WordEntry(word: 'juxtaposition', category: 'abstract', difficulty: 3),
    WordEntry(word: 'kaleidoscope', category: 'object', difficulty: 3),
    WordEntry(word: 'labyrinthine', category: 'description', difficulty: 3),
    WordEntry(word: 'metamorphosis', category: 'process', difficulty: 3),
    WordEntry(word: 'nomenclature', category: 'abstract', difficulty: 3),
    WordEntry(word: 'overwhelming', category: 'description', difficulty: 3),
    WordEntry(word: 'perseverance', category: 'trait', difficulty: 3),
    WordEntry(word: 'quintessential', category: 'description', difficulty: 3),
    WordEntry(word: 'revolutionary', category: 'description', difficulty: 3),
    WordEntry(word: 'serendipitous', category: 'description', difficulty: 3),
    WordEntry(word: 'transformation', category: 'process', difficulty: 3),
    WordEntry(word: 'unprecedented', category: 'description', difficulty: 3),
    WordEntry(word: 'vulnerability', category: 'trait', difficulty: 3),
    WordEntry(word: 'wherewithal', category: 'abstract', difficulty: 3),
    WordEntry(word: 'extraordinary', category: 'description', difficulty: 3),
    WordEntry(word: 'philosophical', category: 'description', difficulty: 3),
  ];

  static List<WordEntry> getWordsForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return beginnerWords;
      case GameDifficulty.intermediate:
        return intermediateWords;
      case GameDifficulty.advanced:
        return advancedWords;
    }
  }

  static WordEntry selectWord(
    GameDifficulty difficulty,
    List<String> recentlyUsed,
  ) {
    final pool = getWordsForDifficulty(difficulty);
    return ContentVarietyEngine.selectWithVariety(
      availableContent: pool,
      recentlyUsedIds: recentlyUsed,
      getId: (w) => w.word,
    );
  }
}

class WordEntry {
  final String word;
  final String category;
  final int difficulty;

  const WordEntry({
    required this.word,
    required this.category,
    required this.difficulty,
  });
}

// ===================
// SENTENCE POOLS
// ===================

class SentencePoolManager {
  static const List<SentenceEntry> simpleSentences = [
    SentenceEntry(
      words: ['The', 'cat', 'sleeps', 'softly'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['Birds', 'fly', 'in', 'sky'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['She', 'reads', 'a', 'book'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['Dogs', 'love', 'to', 'play'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['The', 'sun', 'shines', 'bright'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['We', 'eat', 'healthy', 'food'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['Trees', 'grow', 'very', 'tall'],
      category: 'simple',
      difficulty: 1,
    ),
    SentenceEntry(
      words: ['Fish', 'swim', 'in', 'water'],
      category: 'simple',
      difficulty: 1,
    ),
  ];

  static const List<SentenceEntry> compoundSentences = [
    SentenceEntry(
      words: ['The', 'quick', 'brown', 'fox', 'jumps', 'high'],
      category: 'compound',
      difficulty: 2,
    ),
    SentenceEntry(
      words: ['Children', 'play', 'games', 'in', 'the', 'park'],
      category: 'compound',
      difficulty: 2,
    ),
    SentenceEntry(
      words: ['She', 'writes', 'beautiful', 'poems', 'every', 'day'],
      category: 'compound',
      difficulty: 2,
    ),
    SentenceEntry(
      words: ['The', 'musician', 'plays', 'classical', 'music', 'well'],
      category: 'compound',
      difficulty: 2,
    ),
    SentenceEntry(
      words: ['Students', 'study', 'hard', 'for', 'their', 'exams'],
      category: 'compound',
      difficulty: 2,
    ),
    SentenceEntry(
      words: ['The', 'chef', 'cooks', 'delicious', 'meals', 'daily'],
      category: 'compound',
      difficulty: 2,
    ),
  ];

  static const List<SentenceEntry> complexSentences = [
    SentenceEntry(
      words: [
        'Although',
        'it',
        'was',
        'raining',
        'they',
        'continued',
        'walking',
        'happily',
      ],
      category: 'complex',
      difficulty: 3,
    ),
    SentenceEntry(
      words: [
        'The',
        'scientist',
        'discovered',
        'a',
        'breakthrough',
        'after',
        'years',
        'of',
      ],
      category: 'complex',
      difficulty: 3,
    ),
    SentenceEntry(
      words: [
        'Because',
        'she',
        'practiced',
        'diligently',
        'her',
        'performance',
        'was',
        'excellent',
      ],
      category: 'complex',
      difficulty: 3,
    ),
    SentenceEntry(
      words: [
        'When',
        'the',
        'opportunity',
        'arose',
        'he',
        'seized',
        'it',
        'immediately',
      ],
      category: 'complex',
      difficulty: 3,
    ),
    SentenceEntry(
      words: [
        'The',
        'innovative',
        'technology',
        'revolutionized',
        'how',
        'people',
        'communicate',
        'globally',
      ],
      category: 'complex',
      difficulty: 3,
    ),
  ];

  static List<SentenceEntry> getSentencesForDifficulty(
    GameDifficulty difficulty,
  ) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return simpleSentences;
      case GameDifficulty.intermediate:
        return compoundSentences;
      case GameDifficulty.advanced:
        return complexSentences;
    }
  }

  static SentenceEntry selectSentence(
    GameDifficulty difficulty,
    List<String> recentlyUsed,
  ) {
    final pool = getSentencesForDifficulty(difficulty);
    return ContentVarietyEngine.selectWithVariety(
      availableContent: pool,
      recentlyUsedIds: recentlyUsed,
      getId: (s) => s.words.join(' '),
    );
  }
}

class SentenceEntry {
  final List<String> words;
  final String category;
  final int difficulty;

  const SentenceEntry({
    required this.words,
    required this.category,
    required this.difficulty,
  });

  String get fullSentence => words.join(' ');
}

// ===================
// MATH PROBLEM GENERATOR
// ===================

class MathProblemGenerator {
  static final Random _random = Random();

  static MathProblem generate(
    GameDifficulty difficulty,
    List<String> recentProblems,
  ) {
    final content = MathSpeedDifficulty.getContent(difficulty);
    MathProblem problem;
    int attempts = 0;

    do {
      problem = _generateProblem(content);
      attempts++;
    } while (recentProblems.contains(problem.expression) && attempts < 10);

    return problem;
  }

  static MathProblem _generateProblem(MathSpeedContent content) {
    final operator =
        content.operators[_random.nextInt(content.operators.length)];
    int num1, num2, answer;

    switch (operator) {
      case '+':
        num1 =
            _random.nextInt(content.maxNumber - content.minNumber + 1) +
            content.minNumber;
        num2 =
            _random.nextInt(content.maxNumber - content.minNumber + 1) +
            content.minNumber;
        answer = num1 + num2;
        break;
      case '-':
        num1 =
            _random.nextInt(content.maxNumber - content.minNumber + 1) +
            content.minNumber;
        num2 =
            _random.nextInt(num1) +
            content.minNumber; // Ensure non-negative result
        if (!content.allowNegativeResults && num2 > num1) {
          final temp = num1;
          num1 = num2;
          num2 = temp;
        }
        answer = num1 - num2;
        break;
      case '×':
        num1 = _random.nextInt(12) + 1;
        num2 = _random.nextInt(12) + 1;
        answer = num1 * num2;
        break;
      case '÷':
        num2 = _random.nextInt(12) + 1;
        answer = _random.nextInt(12) + 1;
        num1 = num2 * answer; // Ensure clean division
        break;
      default:
        num1 = _random.nextInt(10) + 1;
        num2 = _random.nextInt(10) + 1;
        answer = num1 + num2;
    }

    return MathProblem(
      num1: num1,
      num2: num2,
      operator: operator,
      answer: answer,
    );
  }
}

class MathProblem {
  final int num1;
  final int num2;
  final String operator;
  final int answer;

  const MathProblem({
    required this.num1,
    required this.num2,
    required this.operator,
    required this.answer,
  });

  String get expression => '$num1 $operator $num2';

  List<int> generateOptions() {
    final random = Random();
    final options = <int>{answer};

    while (options.length < 4) {
      final offset = random.nextInt(10) - 5;
      if (offset != 0) {
        options.add(answer + offset);
      }
    }

    return options.toList()..shuffle();
  }
}

// ===================
// SEQUENCE GENERATOR
// ===================

class SequenceGenerator {
  static final Random _random = Random();

  static SequenceProblem generate(GameDifficulty difficulty) {
    final content = LogicSequenceDifficulty.getContent(difficulty);
    final patternType =
        content.patternTypes[_random.nextInt(content.patternTypes.length)];

    return _generateSequence(
      patternType,
      content.sequenceLength,
      content.maxStep,
    );
  }

  static SequenceProblem _generateSequence(
    PatternType type,
    int length,
    int maxStep,
  ) {
    switch (type) {
      case PatternType.addition:
        return _generateAdditionSequence(length, maxStep);
      case PatternType.multiplication:
        return _generateMultiplicationSequence(length);
      case PatternType.fibonacci:
        return _generateFibonacciLikeSequence(length);
      case PatternType.alternating:
        return _generateAlternatingSequence(length, maxStep);
    }
  }

  static SequenceProblem _generateAdditionSequence(int length, int maxStep) {
    final start = _random.nextInt(10) + 1;
    final step = _random.nextInt(maxStep) + 1;
    final sequence = List.generate(length, (i) => start + (step * i));
    final missingIndex = _random.nextInt(length - 2) + 1; // Not first or last

    return SequenceProblem(
      sequence: sequence,
      missingIndex: missingIndex,
      answer: sequence[missingIndex],
      pattern: '+$step',
    );
  }

  static SequenceProblem _generateMultiplicationSequence(int length) {
    final start = _random.nextInt(3) + 1;
    final multiplier = _random.nextInt(2) + 2;
    final sequence = <int>[start];
    for (int i = 1; i < length; i++) {
      sequence.add(sequence.last * multiplier);
    }
    final missingIndex = _random.nextInt(length - 2) + 1;

    return SequenceProblem(
      sequence: sequence,
      missingIndex: missingIndex,
      answer: sequence[missingIndex],
      pattern: '×$multiplier',
    );
  }

  static SequenceProblem _generateFibonacciLikeSequence(int length) {
    final a = _random.nextInt(5) + 1;
    final b = _random.nextInt(5) + 1;
    final sequence = <int>[a, b];
    for (int i = 2; i < length; i++) {
      sequence.add(sequence[i - 1] + sequence[i - 2]);
    }
    final missingIndex = _random.nextInt(length - 3) + 2;

    return SequenceProblem(
      sequence: sequence,
      missingIndex: missingIndex,
      answer: sequence[missingIndex],
      pattern: 'fibonacci-like',
    );
  }

  static SequenceProblem _generateAlternatingSequence(int length, int maxStep) {
    final start = _random.nextInt(10) + 5;
    final step1 = _random.nextInt(maxStep) + 1;
    final step2 = _random.nextInt(maxStep) + 1;
    final sequence = <int>[start];
    for (int i = 1; i < length; i++) {
      if (i % 2 == 1) {
        sequence.add(sequence.last + step1);
      } else {
        sequence.add(sequence.last - step2);
      }
    }
    final missingIndex = _random.nextInt(length - 2) + 1;

    return SequenceProblem(
      sequence: sequence,
      missingIndex: missingIndex,
      answer: sequence[missingIndex],
      pattern: 'alternating +$step1/-$step2',
    );
  }
}

class SequenceProblem {
  final List<int> sequence;
  final int missingIndex;
  final int answer;
  final String pattern;

  const SequenceProblem({
    required this.sequence,
    required this.missingIndex,
    required this.answer,
    required this.pattern,
  });

  List<int> get displaySequence {
    return List.generate(sequence.length, (i) {
      return i == missingIndex ? -1 : sequence[i]; // -1 represents missing
    });
  }

  List<int> generateOptions() {
    final random = Random();
    final options = <int>{answer};

    while (options.length < 4) {
      final offset = random.nextInt(10) - 5;
      if (offset != 0) {
        options.add(answer + offset);
      }
    }

    return options.toList()..shuffle();
  }
}

// ===================
// CATEGORY DATA
// ===================

class CategoryDataManager {
  static const Map<String, List<String>> easyCategories = {
    'Fruits': [
      'Apple',
      'Banana',
      'Orange',
      'Grape',
      'Mango',
      'Strawberry',
      'Kiwi',
      'Peach',
    ],
    'Animals': [
      'Dog',
      'Cat',
      'Bird',
      'Fish',
      'Lion',
      'Tiger',
      'Bear',
      'Rabbit',
    ],
    'Colors': [
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Orange',
      'Purple',
      'Pink',
      'Black',
    ],
    'Vehicles': [
      'Car',
      'Bus',
      'Train',
      'Plane',
      'Boat',
      'Bike',
      'Truck',
      'Ship',
    ],
  };

  static const Map<String, List<String>> mediumCategories = {
    'Vegetables': [
      'Carrot',
      'Broccoli',
      'Spinach',
      'Potato',
      'Onion',
      'Tomato',
      'Pepper',
      'Corn',
    ],
    'Sports': [
      'Football',
      'Basketball',
      'Tennis',
      'Swimming',
      'Golf',
      'Cricket',
      'Hockey',
      'Baseball',
    ],
    'Countries': [
      'USA',
      'Japan',
      'France',
      'Brazil',
      'India',
      'Germany',
      'Australia',
      'Canada',
    ],
    'Instruments': [
      'Piano',
      'Guitar',
      'Violin',
      'Drums',
      'Flute',
      'Trumpet',
      'Saxophone',
      'Cello',
    ],
  };

  static const Map<String, List<String>> hardCategories = {
    'Emotions': [
      'Joy',
      'Anger',
      'Fear',
      'Surprise',
      'Disgust',
      'Sadness',
      'Trust',
      'Anticipation',
    ],
    'Abstract Concepts': [
      'Freedom',
      'Justice',
      'Truth',
      'Beauty',
      'Love',
      'Wisdom',
      'Courage',
      'Honor',
    ],
    'Scientific Terms': [
      'Atom',
      'Molecule',
      'Cell',
      'Gene',
      'Protein',
      'Electron',
      'Proton',
      'Neutron',
    ],
    'Literary Devices': [
      'Metaphor',
      'Simile',
      'Irony',
      'Allegory',
      'Hyperbole',
      'Symbolism',
      'Paradox',
      'Allusion',
    ],
  };

  static Map<String, List<String>> getCategoriesForDifficulty(
    GameDifficulty difficulty,
  ) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return easyCategories;
      case GameDifficulty.intermediate:
        return mediumCategories;
      case GameDifficulty.advanced:
        return hardCategories;
    }
  }

  static CategoryPair selectCategories(
    GameDifficulty difficulty,
    List<String> recentlyUsed,
  ) {
    final categories = getCategoriesForDifficulty(difficulty);
    final availableKeys = categories.keys
        .where((k) => !recentlyUsed.take(2).contains(k))
        .toList();

    if (availableKeys.length < 2) {
      final keys = categories.keys.toList()..shuffle();
      return CategoryPair(
        category1: keys[0],
        items1: categories[keys[0]]!,
        category2: keys[1],
        items2: categories[keys[1]]!,
      );
    }

    availableKeys.shuffle();
    return CategoryPair(
      category1: availableKeys[0],
      items1: categories[availableKeys[0]]!,
      category2: availableKeys[1],
      items2: categories[availableKeys[1]]!,
    );
  }
}

class CategoryPair {
  final String category1;
  final List<String> items1;
  final String category2;
  final List<String> items2;

  const CategoryPair({
    required this.category1,
    required this.items1,
    required this.category2,
    required this.items2,
  });

  List<CategoryItem> generateItems(int itemsPerCategory) {
    final selected1 = (List<String>.from(
      items1,
    )..shuffle()).take(itemsPerCategory);
    final selected2 = (List<String>.from(
      items2,
    )..shuffle()).take(itemsPerCategory);

    final items = <CategoryItem>[];
    for (final item in selected1) {
      items.add(
        CategoryItem(name: item, category: category1, categoryIndex: 0),
      );
    }
    for (final item in selected2) {
      items.add(
        CategoryItem(name: item, category: category2, categoryIndex: 1),
      );
    }

    items.shuffle();
    return items;
  }
}

class CategoryItem {
  final String name;
  final String category;
  final int categoryIndex;

  const CategoryItem({
    required this.name,
    required this.category,
    required this.categoryIndex,
  });
}
