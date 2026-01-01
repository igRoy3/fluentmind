import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/game_instructions_dialog.dart';
import '../widgets/subtle_feedback.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GamePlayScreen({super.key, required this.gameId});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _timeLeft = 60;
  int _score = 0;
  int _currentQuestion = 0;
  bool _gameOver = false;
  bool _showInstructions = true;
  bool _gameStarted = false;

  // Subtle feedback controller
  final GlobalKey<SubtleFeedbackOverlayState> _feedbackKey =
      GlobalKey<SubtleFeedbackOverlayState>();

  // Math Speed game variables
  int _num1 = 0;
  int _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];

  // Memory Match game variables
  List<int> _cards = [];
  List<bool> _revealed = [];
  int? _firstCard;
  int? _secondCard;
  int _matches = 0;
  bool _canTap = true;

  // Word Scramble game variables
  String _originalWord = '';
  String _scrambledWord = '';
  final TextEditingController _answerController = TextEditingController();
  final List<String> _words = [
    'flutter',
    'programming',
    'language',
    'developer',
    'algorithm',
    'function',
    'variable',
    'constant',
    'interface',
    'abstract',
    'eloquent',
    'serenity',
    'ambition',
    'curiosity',
    'harmony',
  ];

  // Logic Sequence game variables
  List<int> _sequence = [];
  int _missingIndex = 0;
  int _correctSequenceAnswer = 0;
  List<int> _sequenceOptions = [];

  // Category Sort game variables
  String _currentCategory1 = '';
  String _currentCategory2 = '';
  String _currentItem = '';
  int _correctCategory = 0; // 1 or 2
  List<String> _category1Items = [];
  List<String> _category2Items = [];
  final Map<String, List<String>> _categories = {
    'Fruits': ['Apple', 'Banana', 'Orange', 'Mango', 'Grape', 'Kiwi', 'Peach'],
    'Vegetables': [
      'Carrot',
      'Broccoli',
      'Spinach',
      'Potato',
      'Onion',
      'Tomato',
      'Pepper',
    ],
    'Animals': ['Dog', 'Cat', 'Elephant', 'Lion', 'Tiger', 'Rabbit', 'Horse'],
    'Vehicles': [
      'Car',
      'Bus',
      'Train',
      'Plane',
      'Boat',
      'Bicycle',
      'Motorcycle',
    ],
    'Colors': ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange', 'Pink'],
    'Sports': [
      'Football',
      'Basketball',
      'Tennis',
      'Swimming',
      'Golf',
      'Cricket',
      'Hockey',
    ],
    'Countries': [
      'USA',
      'Japan',
      'France',
      'Brazil',
      'India',
      'Germany',
      'Australia',
    ],
    'Instruments': [
      'Piano',
      'Guitar',
      'Violin',
      'Drums',
      'Flute',
      'Trumpet',
      'Saxophone',
    ],
  };

  // Pattern Recognition game variables
  List<List<bool>> _pattern = [];
  List<List<bool>> _userPattern = [];
  bool _showPattern = true;
  int _patternSize = 3;
  int _patternLevel = 1;

  @override
  void initState() {
    super.initState();
    // Show instructions first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameInstructions();
    });
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
        _startTimer();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });
  }

  // ==================== MATH SPEED ====================
  void _generateMathQuestion() {
    final random = Random();
    final operators = ['+', '-', '×'];
    _operator = operators[random.nextInt(operators.length)];

    switch (_operator) {
      case '+':
        _num1 = random.nextInt(50) + 1;
        _num2 = random.nextInt(50) + 1;
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
        _num1 = random.nextInt(50) + 25;
        _num2 = random.nextInt(_num1);
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _num1 = random.nextInt(12) + 1;
        _num2 = random.nextInt(12) + 1;
        _correctAnswer = _num1 * _num2;
        break;
    }

    _options = [_correctAnswer];
    while (_options.length < 4) {
      int wrongAnswer = _correctAnswer + random.nextInt(20) - 10;
      if (wrongAnswer != _correctAnswer &&
          wrongAnswer > 0 &&
          !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();
    setState(() {});
  }

  void _checkMathAnswer(int answer) {
    if (answer == _correctAnswer) {
      setState(() {
        _score += 10;
        _currentQuestion++;
      });
      _showCorrectFeedback();
      _generateMathQuestion();
    } else {
      setState(() {
        _score = max(0, _score - 5);
      });
      _showIncorrectFeedback();
    }
  }

  // ==================== MEMORY MATCH ====================
  void _initializeMemoryGame() {
    final pairs = [1, 2, 3, 4, 5, 6, 7, 8];
    _cards = [...pairs, ...pairs];
    _cards.shuffle();
    _revealed = List.filled(_cards.length, false);
    _matches = 0;
    setState(() {});
  }

  void _handleCardTap(int index) {
    if (!_canTap || _revealed[index]) return;

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
          _matches++;
          _score += 20;
        });
        _showCorrectFeedback();
        _firstCard = null;
        _secondCard = null;
        _canTap = true;

        if (_matches == 8) {
          setState(() {
            _score += _timeLeft * 2;
          });
          _endGame();
        }
      } else {
        _showIncorrectFeedback();
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
    ];
    return colors[value - 1];
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
    ];
    return icons[value - 1];
  }

  // ==================== WORD SCRAMBLE ====================
  void _generateWordScramble() {
    final random = Random();
    _originalWord = _words[random.nextInt(_words.length)];
    final chars = _originalWord.split('');
    chars.shuffle();
    _scrambledWord = chars.join();
    if (_scrambledWord == _originalWord) {
      _generateWordScramble();
    }
    _answerController.clear();
    setState(() {});
  }

  void _checkWordAnswer() {
    if (_answerController.text.toLowerCase().trim() == _originalWord) {
      setState(() {
        _score += 15;
        _currentQuestion++;
      });
      _showCorrectFeedback();
      _generateWordScramble();
    } else if (_answerController.text.isNotEmpty) {
      _showIncorrectFeedback();
    }
  }

  // ==================== LOGIC SEQUENCE ====================
  void _generateLogicSequence() {
    final random = Random();
    final patternTypes = ['arithmetic', 'geometric', 'fibonacci', 'square'];
    final patternType = patternTypes[random.nextInt(patternTypes.length)];

    _sequence = [];
    int start = random.nextInt(10) + 1;
    int step = random.nextInt(5) + 2;

    switch (patternType) {
      case 'arithmetic':
        // e.g., 2, 5, 8, 11, 14 (add 3)
        for (int i = 0; i < 6; i++) {
          _sequence.add(start + (i * step));
        }
        break;
      case 'geometric':
        // e.g., 2, 4, 8, 16, 32 (multiply by 2)
        int factor = random.nextInt(2) + 2;
        int val = start;
        for (int i = 0; i < 6; i++) {
          _sequence.add(val);
          val *= factor;
        }
        break;
      case 'fibonacci':
        // e.g., 1, 1, 2, 3, 5, 8
        _sequence = [1, 1];
        for (int i = 2; i < 6; i++) {
          _sequence.add(_sequence[i - 1] + _sequence[i - 2]);
        }
        break;
      case 'square':
        // e.g., 1, 4, 9, 16, 25
        for (int i = 1; i <= 6; i++) {
          _sequence.add(i * i);
        }
        break;
    }

    // Pick a random position to hide
    _missingIndex = random.nextInt(4) + 1; // Avoid first and last
    _correctSequenceAnswer = _sequence[_missingIndex];

    // Generate options
    _sequenceOptions = [_correctSequenceAnswer];
    while (_sequenceOptions.length < 4) {
      int wrongAnswer = _correctSequenceAnswer + random.nextInt(20) - 10;
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
      setState(() {
        _score += 15;
        _currentQuestion++;
      });
      _showCorrectFeedback();
      _generateLogicSequence();
    } else {
      setState(() {
        _score = max(0, _score - 5);
      });
      _showIncorrectFeedback();
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
      // Completed all items in this category pair
      _initializeCategorySort();
      return;
    }

    // Randomly pick from either category
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
      setState(() {
        _score += 10;
        _currentQuestion++;
      });
      _showCorrectFeedback();
      _generateCategoryItem();
    } else {
      setState(() {
        _score = max(0, _score - 5);
      });
      _showIncorrectFeedback();
    }
  }

  // ==================== PATTERN RECOGNITION ====================
  void _initializePatternGame() {
    _patternSize = 3;
    _patternLevel = 1;
    _generatePattern();
  }

  void _generatePattern() {
    final random = Random();
    int activeCells = _patternLevel + 2; // Start with 3 active cells

    _pattern = List.generate(
      _patternSize,
      (_) => List.generate(_patternSize, (_) => false),
    );
    _userPattern = List.generate(
      _patternSize,
      (_) => List.generate(_patternSize, (_) => false),
    );

    // Randomly activate cells
    int activated = 0;
    while (activated < activeCells) {
      int row = random.nextInt(_patternSize);
      int col = random.nextInt(_patternSize);
      if (!_pattern[row][col]) {
        _pattern[row][col] = true;
        activated++;
      }
    }

    // Show pattern for a short time
    setState(() {
      _showPattern = true;
    });

    Future.delayed(Duration(milliseconds: 1500 + (_patternLevel * 200)), () {
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
      setState(() {
        _score += 20 + (_patternLevel * 5);
        _currentQuestion++;
        _patternLevel++;
        if (_patternLevel > 5 && _patternSize < 5) {
          _patternSize++;
          _patternLevel = 1;
        }
      });
      _showCorrectFeedback();
      _generatePattern();
    } else {
      setState(() {
        _score = max(0, _score - 10);
      });
      _showIncorrectFeedback();
      // Reset user pattern
      _userPattern = List.generate(
        _patternSize,
        (_) => List.generate(_patternSize, (_) => false),
      );
    }
  }

  // ==================== FEEDBACK HELPERS ====================
  void _showCorrectFeedback() {
    HapticFeedback.lightImpact();
    _feedbackKey.currentState?.showCorrect();
  }

  void _showIncorrectFeedback() {
    HapticFeedback.mediumImpact();
    _feedbackKey.currentState?.showIncorrect();
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gameOver = true;
    });
    ref
        .read(brainGamesProvider.notifier)
        .updateHighScore(widget.gameId, _score);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () {
            _timer?.cancel();
            context.pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, color: AppColors.primary, size: 20),
            const SizedBox(width: 4),
            Text(
              '$_timeLeft s',
              style: TextStyle(
                color: _timeLeft <= 10 ? Colors.red : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Score: $_score',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SubtleFeedbackOverlay(
        key: _feedbackKey,
        child: _gameOver ? _buildGameOverScreen() : _buildGameContent(),
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
        return Center(child: Text('Game not found'));
    }
  }

  Widget _buildMathGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              '$_num1 $_operator $_num2 = ?',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _options.map((option) {
              return SizedBox(
                width: 140,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _checkMathAnswer(option),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '$option',
                    style: const TextStyle(
                      fontSize: 24,
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

  Widget _buildMemoryGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _handleCardTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _revealed[index]
                    ? _getCardColor(_cards[index])
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _revealed[index]
                    ? Icon(
                        _getCardIcon(_cards[index]),
                        color: Colors.white,
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
    );
  }

  Widget _buildWordScrambleGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Unscramble the word',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              _scrambledWord.toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: AppColors.primary,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 40),
          TextField(
            controller: _answerController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 4),
            decoration: InputDecoration(
              hintText: 'Type your answer',
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
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
              child: const Text('Submit', style: TextStyle(fontSize: 18)),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLogicSequenceGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Find the missing number',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isHidden
                        ? AppColors.primary.withOpacity(0.2)
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
                        fontSize: 20,
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
          const SizedBox(height: 40),
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

  Widget _buildCategorySortGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Sort the item into the correct category',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          // Current Item to Sort
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
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
          // Category Buttons
          Row(
            children: [
              Expanded(
                child: _CategoryButton(
                  category: _currentCategory1,
                  icon: _getCategoryIcon(_currentCategory1),
                  color: Colors.blue,
                  onTap: () => _checkCategoryAnswer(1),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CategoryButton(
                  category: _currentCategory2,
                  icon: _getCategoryIcon(_currentCategory2),
                  color: Colors.orange,
                  onTap: () => _checkCategoryAnswer(2),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
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

  Widget _buildPatternRecognitionGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _showPattern ? 'Memorize the pattern!' : 'Recreate the pattern',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _showPattern
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
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
          // Pattern Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
                child: const Text(
                  'Check Pattern',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: AppColors.accentYellow,
                      ).animate().scale(
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 16),
                      Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (_currentQuestion > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$_currentQuestion correct answers',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _score = 0;
                                  _currentQuestion = 0;
                                  _timeLeft = 60;
                                  _gameOver = false;
                                });
                                _initializeGame();
                                _startTimer();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Play Again'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String category;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _CategoryButton({
    required this.category,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
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
}
