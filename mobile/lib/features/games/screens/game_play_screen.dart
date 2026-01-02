import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/gamification/models/game_difficulty_models.dart';
import '../widgets/game_instructions_dialog.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GamePlayScreen({super.key, required this.gameId});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen>
    with TickerProviderStateMixin {
  // Core game state
  int _score = 0;
  int _currentQuestion = 0;
  bool _gameOver = false;
  bool _showInstructions = true;
  bool _gameStarted = false;

  // Health-based system (hearts/lives)
  int _maxLives = 3;
  int _currentLives = 3;
  int _combo = 0;
  int _maxCombo = 0;

  // Difficulty settings
  GameDifficulty _difficulty = GameDifficulty.intermediate;

  // Animation controllers
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _shakeAnimation;

  // Math Speed game variables
  int _num1 = 0;
  int _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  bool _showingFeedback = false;
  int? _selectedAnswer;
  bool? _lastAnswerCorrect;

  // Memory Match game variables
  List<int> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  int? _firstCard;
  int? _secondCard;
  int _matches = 0;
  bool _canTap = true;
  int _pairCount = 6;

  // Word Scramble game variables
  String _originalWord = '';
  String _scrambledWord = '';
  String _hint = '';
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  // Word lists by difficulty - REAL difficulty progression
  final List<String> _beginnerWords = [
    // 3-5 letter simple words
    'cat', 'dog', 'sun', 'run', 'hat', 'cup', 'red', 'big',
    'book', 'tree', 'fish', 'bird', 'home', 'play', 'love',
    'star', 'moon', 'rain', 'snow', 'blue', 'cake', 'ball',
  ];
  final List<String> _intermediateWords = [
    // 6-8 letter moderately complex words
    'garden', 'planet', 'bridge', 'frozen', 'bright', 'silver',
    'orange', 'purple', 'window', 'friend', 'travel', 'nature',
    'stream', 'flower', 'summer', 'winter', 'golden', 'castle',
    'jungle', 'island', 'market', 'museum', 'rocket', 'secret',
  ];
  final List<String> _advancedWords = [
    // 9-14 letter challenging words with difficult letter patterns
    'phenomenon', 'psychology', 'archaeology', 'choreography',
    'xylophone', 'hypothesis', 'catastrophe', 'constellation',
    'bibliography', 'kaleidoscope', 'onomatopoeia', 'entrepreneur',
    'questionnaire', 'surveillance', 'acquaintance', 'chrysanthemum',
    'labyrinth', 'silhouette', 'pneumonia', 'bureaucracy',
  ];

  // Logic Sequence game variables
  List<int> _sequence = [];
  int _missingIndex = 0;
  int _correctSequenceAnswer = 0;
  List<int> _sequenceOptions = [];
  String _patternHint = '';

  // Category Sort game variables
  String _currentCategory1 = '';
  String _currentCategory2 = '';
  String _currentItem = '';
  int _correctCategory = 0;
  List<String> _category1Items = [];
  List<String> _category2Items = [];
  // Easy categories (very distinct)
  final Map<String, List<String>> _beginnerCategories = {
    'Fruits': ['Apple', 'Banana', 'Orange', 'Grape', 'Mango', 'Peach'],
    'Animals': ['Dog', 'Cat', 'Elephant', 'Lion', 'Bird', 'Fish'],
    'Colors': ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'],
    'Numbers': ['One', 'Two', 'Three', 'Four', 'Five', 'Six'],
  };

  // Intermediate categories (somewhat related)
  final Map<String, List<String>> _intermediateCategories = {
    'Mammals': ['Dog', 'Cat', 'Elephant', 'Whale', 'Bat', 'Dolphin'],
    'Birds': ['Eagle', 'Sparrow', 'Penguin', 'Owl', 'Parrot', 'Flamingo'],
    'Vegetables': [
      'Carrot',
      'Broccoli',
      'Spinach',
      'Potato',
      'Onion',
      'Pepper',
    ],
    'Fruits': ['Apple', 'Banana', 'Orange', 'Mango', 'Grape', 'Kiwi'],
    'Land Vehicles': ['Car', 'Bus', 'Train', 'Bicycle', 'Motorcycle', 'Truck'],
    'Water Vehicles': ['Boat', 'Ship', 'Submarine', 'Canoe', 'Yacht', 'Ferry'],
  };

  // Advanced categories (tricky/confusing pairs)
  final Map<String, List<String>> _advancedCategories = {
    'Fruits': [
      'Tomato',
      'Avocado',
      'Olive',
      'Pepper',
      'Cucumber',
      'Pumpkin',
    ], // Botanical fruits
    'Vegetables': [
      'Carrot',
      'Potato',
      'Onion',
      'Celery',
      'Lettuce',
      'Spinach',
    ], // Culinary veggies
    'Insects': [
      'Ant',
      'Bee',
      'Butterfly',
      'Beetle',
      'Dragonfly',
      'Grasshopper',
    ],
    'Arachnids': [
      'Spider',
      'Scorpion',
      'Tick',
      'Mite',
      'Tarantula',
      'Harvestman',
    ],
    'Reptiles': ['Snake', 'Lizard', 'Crocodile', 'Turtle', 'Gecko', 'Iguana'],
    'Amphibians': [
      'Frog',
      'Toad',
      'Salamander',
      'Newt',
      'Axolotl',
      'Caecilian',
    ],
    'Herbs': ['Basil', 'Mint', 'Oregano', 'Thyme', 'Rosemary', 'Parsley'],
    'Spices': ['Cinnamon', 'Pepper', 'Cumin', 'Turmeric', 'Paprika', 'Ginger'],
  };

  // Active categories (set based on difficulty)
  Map<String, List<String>> _categories = {};

  // Pattern Recognition game variables
  List<List<bool>> _pattern = [];
  List<List<bool>> _userPattern = [];
  bool _showPattern = true;
  int _patternSize = 3;
  int _patternLevel = 1;
  int _activeCells = 3;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Get difficulty from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final difficultyIndex =
          int.tryParse(
            GoRouterState.of(context).uri.queryParameters['difficulty'] ?? '1',
          ) ??
          1;
      _difficulty = GameDifficulty.values[difficultyIndex.clamp(0, 2)];
      _setupDifficulty();
      _showGameInstructions();
    });
  }

  void _setupDifficulty() {
    switch (_difficulty) {
      case GameDifficulty.beginner:
        _maxLives = 5;
        _currentLives = 5;
        _pairCount = 4; // 8 cards total
        _patternSize = 3; // 3x3 grid
        _activeCells = 3; // Only 3 cells to remember
        _categories = Map.from(_beginnerCategories);
        break;
      case GameDifficulty.intermediate:
        _maxLives = 3;
        _currentLives = 3;
        _pairCount = 6; // 12 cards total
        _patternSize = 4; // 4x4 grid
        _activeCells = 6; // 6 cells to remember
        _categories = Map.from(_intermediateCategories);
        break;
      case GameDifficulty.advanced:
        _maxLives = 2;
        _currentLives = 2;
        _pairCount = 8; // 16 cards total
        _patternSize = 5; // 5x5 grid
        _activeCells = 9; // 9 cells to remember
        _categories = Map.from(_advancedCategories);
        break;
    }
  }

  void _showGameInstructions() {
    showGameInstructions(
      context,
      gameId: widget.gameId,
      onStart: () {
        setState(() {
          _showInstructions = false;
          _gameStarted = true;
        });
        _initializeGame();
      },
    );
  }

  void _initializeGame() {
    switch (widget.gameId) {
      case 'math_speed':
        _generateMathQuestion();
        break;
      case 'memory_match':
        _initializeMemoryGame();
        break;
      case 'word_scramble':
        _generateWordScramble();
        break;
      case 'logic_sequence':
        _generateLogicSequence();
        break;
      case 'category_sort':
        _initializeCategorySort();
        break;
      case 'pattern_recognition':
        _initializePatternGame();
        break;
    }
  }

  void _loseLife() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);

    setState(() {
      _currentLives--;
      _combo = 0;
      if (_currentLives <= 0) {
        _endGame();
      }
    });
  }

  void _gainPoints(int base) {
    HapticFeedback.lightImpact();
    setState(() {
      _combo++;
      if (_combo > _maxCombo) _maxCombo = _combo;

      // Combo multiplier
      double multiplier = 1.0 + (_combo * 0.1);
      if (_combo >= 5) multiplier = 1.5;
      if (_combo >= 10) multiplier = 2.0;

      _score += (base * multiplier).round();
      _currentQuestion++;
    });
  }

  void _endGame() {
    setState(() {
      _gameOver = true;
    });
    ref
        .read(brainGamesProvider.notifier)
        .updateHighScore(widget.gameId, _score);
  }

  // ==================== MATH SPEED ====================
  void _generateMathQuestion() {
    final random = Random();

    switch (_difficulty) {
      case GameDifficulty.beginner:
        // Simple single-digit addition/subtraction
        _operator = random.nextBool() ? '+' : '-';
        if (_operator == '+') {
          _num1 = random.nextInt(9) + 1; // 1-9
          _num2 = random.nextInt(9) + 1; // 1-9
          _correctAnswer = _num1 + _num2; // Max 18
        } else {
          _num1 = random.nextInt(10) + 5; // 5-14
          _num2 = random.nextInt(_num1 - 1) + 1; // Always positive result
          _correctAnswer = _num1 - _num2;
        }
        // Easy wrong answers (spread out)
        _options = [_correctAnswer];
        while (_options.length < 4) {
          int wrong =
              _correctAnswer +
              (random.nextInt(5) + 1) * (random.nextBool() ? 1 : -1);
          if (wrong > 0 &&
              wrong != _correctAnswer &&
              !_options.contains(wrong)) {
            _options.add(wrong);
          }
        }
        break;

      case GameDifficulty.intermediate:
        // Two-digit operations with multiplication
        final ops = ['+', '-', '×'];
        _operator = ops[random.nextInt(ops.length)];
        switch (_operator) {
          case '+':
            _num1 = random.nextInt(50) + 20; // 20-69
            _num2 = random.nextInt(40) + 10; // 10-49
            _correctAnswer = _num1 + _num2;
            break;
          case '-':
            _num1 = random.nextInt(50) + 30; // 30-79
            _num2 = random.nextInt(30) + 5; // 5-34
            _correctAnswer = _num1 - _num2;
            break;
          case '×':
            _num1 = random.nextInt(10) + 3; // 3-12
            _num2 = random.nextInt(8) + 2; // 2-9
            _correctAnswer = _num1 * _num2;
            break;
        }
        // Medium wrong answers (closer together)
        _options = [_correctAnswer];
        while (_options.length < 4) {
          int wrong =
              _correctAnswer +
              (random.nextInt(8) + 1) * (random.nextBool() ? 1 : -1);
          if (wrong > 0 &&
              wrong != _correctAnswer &&
              !_options.contains(wrong)) {
            _options.add(wrong);
          }
        }
        break;

      case GameDifficulty.advanced:
        // Large numbers, all 4 operations, tricky wrong answers
        final advOps = ['+', '-', '×', '÷'];
        _operator = advOps[random.nextInt(advOps.length)];
        switch (_operator) {
          case '+':
            _num1 = random.nextInt(200) + 100; // 100-299
            _num2 = random.nextInt(150) + 50; // 50-199
            _correctAnswer = _num1 + _num2;
            break;
          case '-':
            _num1 = random.nextInt(200) + 100; // 100-299
            _num2 = random.nextInt(80) + 20; // 20-99
            _correctAnswer = _num1 - _num2;
            break;
          case '×':
            _num1 = random.nextInt(15) + 6; // 6-20
            _num2 = random.nextInt(12) + 4; // 4-15
            _correctAnswer = _num1 * _num2;
            break;
          case '÷':
            // Ensure clean division
            _num2 = random.nextInt(10) + 3; // 3-12
            _correctAnswer = random.nextInt(15) + 5; // 5-19
            _num1 = _num2 * _correctAnswer;
            break;
        }
        // Tricky wrong answers (very close to correct)
        _options = [_correctAnswer];
        while (_options.length < 4) {
          int wrong =
              _correctAnswer +
              (random.nextInt(4) + 1) * (random.nextBool() ? 1 : -1);
          // Add transposition errors for multiplication
          if (_operator == '×' && random.nextInt(3) == 0) {
            wrong = _num1 * (_num2 + 1); // Common multiplication mistake
          }
          if (wrong > 0 &&
              wrong != _correctAnswer &&
              !_options.contains(wrong)) {
            _options.add(wrong);
          }
        }
        break;
    }
    _options.shuffle();

    setState(() {
      _selectedAnswer = null;
      _lastAnswerCorrect = null;
      _showingFeedback = false;
    });
  }

  void _checkMathAnswer(int answer) {
    if (_showingFeedback) return;

    setState(() {
      _selectedAnswer = answer;
      _showingFeedback = true;
      _lastAnswerCorrect = answer == _correctAnswer;
    });

    if (answer == _correctAnswer) {
      _gainPoints(
        _difficulty == GameDifficulty.advanced
            ? 25
            : _difficulty == GameDifficulty.intermediate
            ? 15
            : 10,
      );
    } else {
      _loseLife();
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_gameOver) {
        _generateMathQuestion();
      }
    });
  }

  // ==================== MEMORY MATCH ====================
  void _initializeMemoryGame() {
    final pairs = List.generate(_pairCount, (i) => i + 1);
    _cards = [...pairs, ...pairs];
    _cards.shuffle();
    _revealed = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _matches = 0;
    _firstCard = null;
    _secondCard = null;
    setState(() {});
  }

  void _handleCardTap(int index) {
    if (!_canTap || _revealed[index] || _matched[index]) return;

    HapticFeedback.selectionClick();
    setState(() {
      _revealed[index] = true;
    });

    if (_firstCard == null) {
      _firstCard = index;
    } else {
      _secondCard = index;
      _canTap = false;

      if (_cards[_firstCard!] == _cards[_secondCard!]) {
        setState(() {
          _matched[_firstCard!] = true;
          _matched[_secondCard!] = true;
          _matches++;
        });
        _gainPoints(20);
        _firstCard = null;
        _secondCard = null;
        _canTap = true;

        if (_matches == _pairCount) {
          _endGame();
        }
      } else {
        _loseLife();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _revealed[_firstCard!] = false;
              _revealed[_secondCard!] = false;
              _firstCard = null;
              _secondCard = null;
              _canTap = true;
            });
          }
        });
      }
    }
  }

  Color _getCardColor(int value) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[(value - 1) % colors.length];
  }

  IconData _getCardIcon(int value) {
    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.lightbulb,
      Icons.music_note,
      Icons.bolt,
      Icons.diamond,
      Icons.local_florist,
      Icons.sunny,
      Icons.cloud,
      Icons.pets,
    ];
    return icons[(value - 1) % icons.length];
  }

  // ==================== WORD SCRAMBLE ====================
  void _generateWordScramble() {
    final random = Random();
    List<String> wordList;

    switch (_difficulty) {
      case GameDifficulty.beginner:
        wordList = _beginnerWords;
        break;
      case GameDifficulty.intermediate:
        wordList = _intermediateWords;
        break;
      case GameDifficulty.advanced:
        wordList = _advancedWords;
        break;
    }

    _originalWord = wordList[random.nextInt(wordList.length)];
    final chars = _originalWord.split('');
    chars.shuffle();
    _scrambledWord = chars.join();

    if (_scrambledWord == _originalWord) {
      _generateWordScramble();
      return;
    }

    // Generate hint based on difficulty
    switch (_difficulty) {
      case GameDifficulty.beginner:
        _hint =
            'First letter: ${_originalWord[0].toUpperCase()}, Last letter: ${_originalWord[_originalWord.length - 1]}';
        break;
      case GameDifficulty.intermediate:
        _hint = 'First letter: ${_originalWord[0].toUpperCase()}';
        break;
      case GameDifficulty.advanced:
        _hint = '${_originalWord.length} letters';
        break;
    }

    _answerController.clear();
    setState(() {});
  }

  void _checkWordAnswer() {
    if (_answerController.text.toLowerCase().trim() == _originalWord) {
      _gainPoints(
        _difficulty == GameDifficulty.advanced
            ? 50
            : _difficulty == GameDifficulty.intermediate
            ? 30
            : 20,
      );
      _generateWordScramble();
    } else if (_answerController.text.isNotEmpty) {
      _loseLife();
      _answerController.clear();
    }
  }

  // ==================== LOGIC SEQUENCE ====================
  void _generateLogicSequence() {
    final random = Random();
    _sequence = [];

    switch (_difficulty) {
      case GameDifficulty.beginner:
        // Simple +2, +3, +5, or +10 patterns
        final steps = [2, 3, 5, 10];
        final step = steps[random.nextInt(steps.length)];
        final start = random.nextInt(5) + 1;
        for (int i = 0; i < 5; i++) {
          _sequence.add(start + (i * step));
        }
        _patternHint = 'Add $step each time';
        _missingIndex = random.nextInt(3) + 1; // Hide middle elements only
        break;

      case GameDifficulty.intermediate:
        // Multiple pattern types
        final patternType = random.nextInt(4);
        switch (patternType) {
          case 0: // Arithmetic with larger steps
            final step = random.nextInt(7) + 4; // 4-10
            final start = random.nextInt(10) + 5;
            for (int i = 0; i < 6; i++) {
              _sequence.add(start + (i * step));
            }
            _patternHint = 'Arithmetic sequence';
            break;
          case 1: // Geometric (×2 or ×3)
            final factor = random.nextInt(2) + 2;
            int val = random.nextInt(3) + 2;
            for (int i = 0; i < 6; i++) {
              _sequence.add(val);
              val *= factor;
            }
            _patternHint = 'Multiply pattern';
            break;
          case 2: // Square numbers
            for (int i = 1; i <= 6; i++) {
              _sequence.add(i * i);
            }
            _patternHint = 'Perfect squares';
            break;
          case 3: // Even or odd numbers
            final isEven = random.nextBool();
            for (int i = 0; i < 6; i++) {
              _sequence.add(isEven ? (i + 1) * 2 : (i * 2) + 1);
            }
            _patternHint = isEven ? 'Even numbers' : 'Odd numbers';
            break;
        }
        _missingIndex = random.nextInt(4) + 1;
        break;

      case GameDifficulty.advanced:
        // Complex patterns - NO hints
        final patternType = random.nextInt(6);
        switch (patternType) {
          case 0: // Fibonacci
            _sequence = [1, 1];
            for (int i = 2; i < 7; i++) {
              _sequence.add(_sequence[i - 1] + _sequence[i - 2]);
            }
            break;
          case 1: // Cube numbers
            for (int i = 1; i <= 6; i++) {
              _sequence.add(i * i * i);
            }
            break;
          case 2: // Triangular numbers (1, 3, 6, 10, 15, 21)
            for (int i = 1; i <= 6; i++) {
              _sequence.add((i * (i + 1)) ~/ 2);
            }
            break;
          case 3: // Prime numbers
            _sequence = [2, 3, 5, 7, 11, 13];
            break;
          case 4: // Alternating +3, +5 pattern
            int val = random.nextInt(5) + 1;
            for (int i = 0; i < 6; i++) {
              _sequence.add(val);
              val += (i % 2 == 0) ? 3 : 5;
            }
            break;
          case 5: // Doubling then adding (×2+1)
            int val = random.nextInt(3) + 1;
            for (int i = 0; i < 6; i++) {
              _sequence.add(val);
              val = val * 2 + 1;
            }
            break;
        }
        _patternHint = 'Find the pattern'; // No real hint for advanced
        _missingIndex = random.nextInt(4) + 1;
        break;
    }

    _correctSequenceAnswer = _sequence[_missingIndex];

    // Generate wrong options based on difficulty
    _sequenceOptions = [_correctSequenceAnswer];
    final spread = _difficulty == GameDifficulty.beginner
        ? 5
        : _difficulty == GameDifficulty.intermediate
        ? 3
        : 2;
    while (_sequenceOptions.length < 4) {
      int wrongAnswer =
          _correctSequenceAnswer + (random.nextInt(spread * 2 + 1) - spread);
      // For advanced, add pattern-based wrong answers
      if (_difficulty == GameDifficulty.advanced && random.nextBool()) {
        wrongAnswer = _sequence[(_missingIndex + 1) % _sequence.length];
      }
      if (wrongAnswer != _correctSequenceAnswer &&
          wrongAnswer > 0 &&
          !_sequenceOptions.contains(wrongAnswer)) {
        _sequenceOptions.add(wrongAnswer);
      }
    }
    _sequenceOptions.shuffle();
    setState(() {});
  }

  void _checkSequenceAnswer(int answer) {
    if (answer == _correctSequenceAnswer) {
      _gainPoints(_difficulty == GameDifficulty.advanced ? 30 : 15);
      _generateLogicSequence();
    } else {
      _loseLife();
    }
  }

  // ==================== CATEGORY SORT ====================
  void _initializeCategorySort() {
    final categoryNames = _categories.keys.toList();
    categoryNames.shuffle();
    _currentCategory1 = categoryNames[0];
    _currentCategory2 = categoryNames[1];
    _category1Items = List.from(_categories[_currentCategory1]!);
    _category2Items = List.from(_categories[_currentCategory2]!);
    _generateCategoryItem();
  }

  void _generateCategoryItem() {
    final random = Random();

    if (_category1Items.isEmpty && _category2Items.isEmpty) {
      _initializeCategorySort();
      return;
    }

    if (_category1Items.isEmpty) {
      _correctCategory = 2;
      _currentItem = _category2Items.removeAt(
        random.nextInt(_category2Items.length),
      );
    } else if (_category2Items.isEmpty) {
      _correctCategory = 1;
      _currentItem = _category1Items.removeAt(
        random.nextInt(_category1Items.length),
      );
    } else {
      _correctCategory = random.nextBool() ? 1 : 2;
      if (_correctCategory == 1) {
        _currentItem = _category1Items.removeAt(
          random.nextInt(_category1Items.length),
        );
      } else {
        _currentItem = _category2Items.removeAt(
          random.nextInt(_category2Items.length),
        );
      }
    }
    setState(() {});
  }

  void _checkCategoryAnswer(int selectedCategory) {
    if (selectedCategory == _correctCategory) {
      _gainPoints(10);
      _generateCategoryItem();
    } else {
      _loseLife();
    }
  }

  // ==================== PATTERN RECOGNITION ====================
  void _initializePatternGame() {
    _patternLevel = 1;
    _generatePattern();
  }

  void _generatePattern() {
    final random = Random();

    // Scale cells with level AND difficulty
    int baseCells;
    int cellsPerLevel;
    int showTime;

    switch (_difficulty) {
      case GameDifficulty.beginner:
        baseCells = 2; // Start with just 2 cells
        cellsPerLevel = 1; // Add 1 per level
        showTime = 3000; // 3 seconds to memorize
        break;
      case GameDifficulty.intermediate:
        baseCells = 4; // Start with 4 cells
        cellsPerLevel = 1; // Add 1 per level
        showTime = 2000; // 2 seconds
        break;
      case GameDifficulty.advanced:
        baseCells = 6; // Start with 6 cells
        cellsPerLevel = 2; // Add 2 per level
        showTime = 1200; // Only 1.2 seconds!
        break;
    }

    int cells = baseCells + (_patternLevel - 1) * cellsPerLevel;
    cells = cells.clamp(2, _patternSize * _patternSize - 1);

    _pattern = List.generate(
      _patternSize,
      (_) => List.generate(_patternSize, (_) => false),
    );
    _userPattern = List.generate(
      _patternSize,
      (_) => List.generate(_patternSize, (_) => false),
    );

    int activated = 0;
    while (activated < cells) {
      int row = random.nextInt(_patternSize);
      int col = random.nextInt(_patternSize);
      if (!_pattern[row][col]) {
        _pattern[row][col] = true;
        activated++;
      }
    }

    setState(() {
      _showPattern = true;
    });

    // Reduce show time as level increases for advanced
    if (_difficulty == GameDifficulty.advanced) {
      showTime = (showTime - (_patternLevel * 100)).clamp(600, 1200);
    }

    Future.delayed(Duration(milliseconds: showTime), () {
      if (mounted) {
        setState(() {
          _showPattern = false;
        });
      }
    });
  }

  void _togglePatternCell(int row, int col) {
    if (_showPattern) return;
    HapticFeedback.selectionClick();
    setState(() {
      _userPattern[row][col] = !_userPattern[row][col];
    });
  }

  void _checkPattern() {
    bool correct = true;
    for (int i = 0; i < _patternSize; i++) {
      for (int j = 0; j < _patternSize; j++) {
        if (_pattern[i][j] != _userPattern[i][j]) {
          correct = false;
          break;
        }
      }
    }

    if (correct) {
      _gainPoints(20 + (_patternLevel * 5));
      setState(() {
        _patternLevel++;
      });
      _generatePattern();
    } else {
      _loseLife();
      _userPattern = List.generate(
        _patternSize,
        (_) => List.generate(_patternSize, (_) => false),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_showInstructions && !_gameStarted) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: _gameOver ? _buildGameOverScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Top Bar with Lives, Score, Combo
        _buildTopBar(isDark),

        // Game Content
        Expanded(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _shakeAnimation.value * (Random().nextBool() ? 1 : -1),
                  0,
                ),
                child: child,
              );
            },
            child: _buildGameContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Lives (Hearts)
          Row(
            children: List.generate(_maxLives, (index) {
              final isActive = index < _currentLives;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child:
                    Icon(
                          isActive ? Icons.favorite : Icons.favorite_border,
                          color: isActive ? Colors.red : Colors.grey.shade400,
                          size: 24,
                        )
                        .animate(target: isActive ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          duration: 200.ms,
                        ),
              );
            }),
          ),

          const Spacer(),

          // Combo indicator
          if (_combo > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_combo}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 200.ms),

          const SizedBox(width: 12),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$_score',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    switch (widget.gameId) {
      case 'math_speed':
        return _buildMathGame();
      case 'memory_match':
        return _buildMemoryGame();
      case 'word_scramble':
        return _buildWordScrambleGame();
      case 'logic_sequence':
        return _buildLogicSequenceGame();
      case 'category_sort':
        return _buildCategorySortGame();
      case 'pattern_recognition':
        return _buildPatternRecognitionGame();
      default:
        return const Center(child: Text('Game not found'));
    }
  }

  // ==================== MATH SPEED UI ====================
  Widget _buildMathGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Question counter
          Text(
            'Question ${_currentQuestion + 1}',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Math equation card - POLISHED
          Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.cardDark, AppColors.surfaceDark]
                        : [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Numbers and operator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMathNumber(_num1, isDark),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _operator,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildMathNumber(_num2, isDark),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Equals line
                    Container(
                      width: 200,
                      height: 3,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question mark
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const Spacer(),

          // Answer options - 2x2 Grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: _options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isCorrect = option == _correctAnswer;
              Color bgColor;
              Color textColor;

              if (_showingFeedback && isSelected) {
                bgColor = isCorrect ? Colors.green : Colors.red;
                textColor = Colors.white;
              } else if (_showingFeedback && isCorrect) {
                bgColor = Colors.green.withOpacity(0.2);
                textColor = Colors.green;
              } else {
                bgColor = isDark ? AppColors.cardDark : Colors.white;
                textColor = isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary;
              }

              return GestureDetector(
                onTap: () => _checkMathAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_showingFeedback && isSelected && isCorrect)
                            ? Colors.green.withOpacity(0.3)
                            : Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: (_showingFeedback && isSelected)
                          ? (isCorrect ? Colors.green : Colors.red)
                          : (isDark ? Colors.white10 : Colors.grey.shade200),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$option',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMathNumber(int number, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
    );
  }

  // ==================== MEMORY MATCH UI ====================
  Widget _buildMemoryGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int crossAxisCount = _pairCount <= 4 ? 4 : (_pairCount <= 6 ? 4 : 4);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Matches: $_matches / $_pairCount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final isRevealed = _revealed[index];
                final isMatched = _matched[index];

                return GestureDetector(
                  onTap: () => _handleCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? _getCardColor(_cards[index]).withOpacity(0.3)
                          : (isRevealed
                                ? _getCardColor(_cards[index])
                                : (isDark ? AppColors.cardDark : Colors.white)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isMatched)
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: isMatched
                          ? Border.all(
                              color: _getCardColor(_cards[index]),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isRevealed || isMatched
                          ? Icon(
                              _getCardIcon(_cards[index]),
                              color: isMatched
                                  ? _getCardColor(_cards[index])
                                  : Colors.white,
                              size: 32,
                            )
                          : Icon(
                              Icons.question_mark,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              size: 24,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WORD SCRAMBLE UI ====================
  Widget _buildWordScrambleGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          Text(
            'Unscramble the Word',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Scrambled word display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _scrambledWord.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _hint,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 32),

          // Answer input
          TextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.none,
            style: TextStyle(
              fontSize: 24,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Type your answer',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                letterSpacing: 2,
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 24,
              ),
            ),
            onSubmitted: (_) => _checkWordAnswer(),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _checkWordAnswer,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // ==================== LOGIC SEQUENCE UI ====================
  Widget _buildLogicSequenceGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          Text(
            'Find the Missing Number',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          if (_difficulty == GameDifficulty.beginner) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hint: $_patternHint',
                style: TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Sequence display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_sequence.length, (index) {
                final isHidden = index == _missingIndex;
                return Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isHidden
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHidden
                          ? AppColors.primary
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                      width: isHidden ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isHidden ? '?' : '${_sequence[index]}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isHidden
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 32),

          // Options
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _sequenceOptions.map((option) {
              return SizedBox(
                width: 100,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _checkSequenceAnswer(option),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '$option',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // ==================== CATEGORY SORT UI ====================
  Widget _buildCategorySortGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          Text(
            'Sort into the correct category',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Item to sort
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  _currentItem,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 40),

          // Category buttons
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  _currentCategory1,
                  Colors.blue,
                  1,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryButton(
                  _currentCategory2,
                  Colors.orange,
                  2,
                  isDark,
                ),
              ),
            ],
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    String category,
    Color color,
    int categoryNum,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _checkCategoryAnswer(categoryNum),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getCategoryIcon(category), color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fruits':
        return Icons.apple;
      case 'Vegetables':
        return Icons.eco;
      case 'Animals':
        return Icons.pets;
      case 'Vehicles':
        return Icons.directions_car;
      case 'Colors':
        return Icons.palette;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Countries':
        return Icons.public;
      case 'Instruments':
        return Icons.music_note;
      default:
        return Icons.category;
    }
  }

  // ==================== PATTERN RECOGNITION UI ====================
  Widget _buildPatternRecognitionGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _showPattern
                  ? Colors.orange.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _showPattern ? '👀 Memorize!' : '🧠 Recreate the pattern',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _showPattern ? Colors.orange : AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Level $_patternLevel',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Pattern grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _patternSize,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _patternSize * _patternSize,
              itemBuilder: (context, index) {
                final row = index ~/ _patternSize;
                final col = index % _patternSize;
                final isActive = _showPattern
                    ? _pattern[row][col]
                    : _userPattern[row][col];

                return GestureDetector(
                  onTap: () => _togglePatternCell(row, col),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.surfaceDark
                                : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 32),

          if (!_showPattern)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _checkPattern,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Check Pattern',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // ==================== GAME OVER SCREEN ====================
  Widget _buildGameOverScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child:
            Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 50,
                          color: Colors.white,
                        ),
                      ).animate().scale(
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Game Over!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Score',
                              '$_score',
                              AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              'Correct Answers',
                              '$_currentQuestion',
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              'Max Combo',
                              '${_maxCombo}x',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Exit',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _score = 0;
                                  _currentQuestion = 0;
                                  _currentLives = _maxLives;
                                  _combo = 0;
                                  _maxCombo = 0;
                                  _gameOver = false;
                                });
                                _initializeGame();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Play Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
