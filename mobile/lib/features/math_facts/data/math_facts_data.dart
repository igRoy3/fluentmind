// Math Facts Data - Tables, Squares, Cubes
// Provides data generation for learning and practice modes

import 'dart:math';

/// Types of math facts
enum MathFactType { table, square, cube }

/// Practice mode options
enum PracticeMode {
  squares('Squares Only', '²', 'Practice squares from 1² to 25²'),
  cubes('Cubes Only', '³', 'Practice cubes from 1³ to 15³'),
  mixed('Mixed Challenge', '∑', 'Tables, Squares & Cubes combined');

  final String title;
  final String symbol;
  final String description;
  const PracticeMode(this.title, this.symbol, this.description);
}

/// Practice level (MCQ or NumPad)
enum PracticeLevel {
  level1(
    'Level 1',
    'Multiple Choice',
    'Choose the correct answer from 4 options',
  ),
  level2('Level 2', 'Number Pad', 'Type the answer using number pad');

  final String title;
  final String subtitle;
  final String description;
  const PracticeLevel(this.title, this.subtitle, this.description);
}

/// A single math fact (for learning)
class MathFact {
  final MathFactType type;
  final int baseNumber;
  final int multiplier; // Only used for tables
  final int result;

  const MathFact({
    required this.type,
    required this.baseNumber,
    this.multiplier = 0,
    required this.result,
  });

  String get expression {
    switch (type) {
      case MathFactType.table:
        return '$baseNumber × $multiplier';
      case MathFactType.square:
        return '$baseNumber²';
      case MathFactType.cube:
        return '$baseNumber³';
    }
  }

  String get fullEquation => '$expression = $result';
}

/// A practice question
class MathQuestion {
  final MathFactType type;
  final String question;
  final int correctAnswer;
  final List<int> options; // For MCQ mode
  final String hint;

  const MathQuestion({
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });
}

/// Math Facts Data Generator
class MathFactsGenerator {
  static final Random _random = Random();

  // ==================
  // LEARNING DATA
  // ==================

  /// Get all tables from 11 to 20
  static List<List<MathFact>> getAllTables() {
    return List.generate(10, (i) => getTableFor(i + 11));
  }

  /// Get a specific multiplication table (1 to 10)
  static List<MathFact> getTableFor(int n) {
    return List.generate(10, (i) {
      final multiplier = i + 1;
      return MathFact(
        type: MathFactType.table,
        baseNumber: n,
        multiplier: multiplier,
        result: n * multiplier,
      );
    });
  }

  /// Get all squares from 1 to 25
  static List<MathFact> getAllSquares() {
    return List.generate(25, (i) {
      final n = i + 1;
      return MathFact(type: MathFactType.square, baseNumber: n, result: n * n);
    });
  }

  /// Get all cubes from 1 to 15
  static List<MathFact> getAllCubes() {
    return List.generate(15, (i) {
      final n = i + 1;
      return MathFact(
        type: MathFactType.cube,
        baseNumber: n,
        result: n * n * n,
      );
    });
  }

  // ==================
  // PRACTICE QUESTIONS
  // ==================

  /// Generate a random question based on practice mode
  static MathQuestion generateQuestion(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.squares:
        return _generateSquareQuestion();
      case PracticeMode.cubes:
        return _generateCubeQuestion();
      case PracticeMode.mixed:
        return _generateMixedQuestion();
    }
  }

  static MathQuestion _generateSquareQuestion() {
    final n = _random.nextInt(25) + 1; // 1 to 25
    final answer = n * n;
    return MathQuestion(
      type: MathFactType.square,
      question: '$n² = ?',
      correctAnswer: answer,
      options: _generateOptions(answer, MathFactType.square, n),
      hint: '$n × $n',
    );
  }

  static MathQuestion _generateCubeQuestion() {
    final n = _random.nextInt(15) + 1; // 1 to 15
    final answer = n * n * n;
    return MathQuestion(
      type: MathFactType.cube,
      question: '$n³ = ?',
      correctAnswer: answer,
      options: _generateOptions(answer, MathFactType.cube, n),
      hint: '$n × $n × $n',
    );
  }

  static MathQuestion _generateMixedQuestion() {
    final type = _random.nextInt(3); // 0: table, 1: square, 2: cube

    switch (type) {
      case 0: // Table (11-20)
        return _generateTableQuestion();
      case 1: // Square
        return _generateSquareQuestion();
      case 2: // Cube
      default:
        return _generateCubeQuestion();
    }
  }

  static MathQuestion _generateTableQuestion() {
    final baseNum = _random.nextInt(10) + 11; // 11 to 20
    final multiplier = _random.nextInt(10) + 1; // 1 to 10
    final answer = baseNum * multiplier;
    return MathQuestion(
      type: MathFactType.table,
      question: '$baseNum × $multiplier = ?',
      correctAnswer: answer,
      options: _generateOptions(
        answer,
        MathFactType.table,
        baseNum,
        multiplier,
      ),
      hint: 'Table of $baseNum',
    );
  }

  /// Generate 4 options including the correct answer
  static List<int> _generateOptions(
    int correctAnswer,
    MathFactType type,
    int baseNum, [
    int multiplier = 0,
  ]) {
    final options = <int>{correctAnswer};

    // Add "near miss" wrong answers based on type
    switch (type) {
      case MathFactType.table:
        // Common mistakes: adjacent multipliers
        if (multiplier > 1) {
          options.add(baseNum * (multiplier - 1));
        }
        if (multiplier < 10) {
          options.add(baseNum * (multiplier + 1));
        }
        // Adjacent base numbers
        options.add((baseNum - 1) * multiplier);
        options.add((baseNum + 1) * multiplier);
        break;

      case MathFactType.square:
        // Adjacent squares
        if (baseNum > 1) {
          options.add((baseNum - 1) * (baseNum - 1));
        }
        options.add((baseNum + 1) * (baseNum + 1));
        // Common mistake: double instead of square
        options.add(baseNum * 2);
        break;

      case MathFactType.cube:
        // Adjacent cubes
        if (baseNum > 1) {
          options.add((baseNum - 1) * (baseNum - 1) * (baseNum - 1));
        }
        options.add((baseNum + 1) * (baseNum + 1) * (baseNum + 1));
        // Common mistake: square instead of cube
        options.add(baseNum * baseNum);
        break;
    }

    // Fill remaining with random variations
    while (options.length < 4) {
      final offset = _random.nextInt(20) - 10;
      final newOption = correctAnswer + offset;
      if (newOption > 0 && newOption != correctAnswer) {
        options.add(newOption);
      }
    }

    // Take exactly 4 and shuffle
    final optionList = options.take(4).toList()..shuffle();
    return optionList;
  }

  // ==================
  // UTILITY
  // ==================

  /// Get color for fact type
  static int getColorForType(MathFactType type) {
    switch (type) {
      case MathFactType.table:
        return 0xFF6C5CE7; // Purple
      case MathFactType.square:
        return 0xFF00B894; // Green
      case MathFactType.cube:
        return 0xFFE17055; // Orange
    }
  }

  /// Get icon for fact type
  static String getIconForType(MathFactType type) {
    switch (type) {
      case MathFactType.table:
        return '×';
      case MathFactType.square:
        return '²';
      case MathFactType.cube:
        return '³';
    }
  }
}
