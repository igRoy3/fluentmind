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
import '../../../core/gamification/providers/adaptive_difficulty_provider.dart';
import '../../../core/services/user_journey_service.dart';
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

  // Session tracking
  DateTime? _gameStartTime;
  int _correctAnswers = 0;

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
  String _userAnswer = ''; // User typed answer
  bool _showingFeedback = false;
  bool? _lastAnswerCorrect;

  // Math Speed Timer
  Timer? _mathTimer;
  int _mathTimeLeft = 0;
  int _mathTimeTotal = 0; // Total time for progress calculation

  // Memory Match game variables
  List<int> _cards = [];
  List<bool> _revealed = [];
  List<bool> _matched = [];
  int? _firstCard;
  int? _secondCard;
  int _matches = 0;
  bool _canTap = true;
  int _pairCount = 6;

  // Memory Match Timer
  Timer? _memoryTimer;
  int _memoryTimeLeft = 0;
  int _memoryTimeTotal = 0; // Time per set based on difficulty

  // Word Scramble game variables
  String _originalWord = '';
  String _scrambledWord = '';
  String _hint = '';
  String _lastFailedWord = ''; // Store the word to show on game over
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  // Word lists by difficulty - REAL difficulty progression
  final List<String> _beginnerWords = [
    // 3-5 letter simple words
    'cat', 'dog', 'sun', 'run', 'hat', 'cup', 'red', 'big',
    'book', 'tree', 'fish', 'bird', 'home', 'play', 'love',
    'star', 'moon', 'rain', 'snow', 'blue', 'cake', 'ball',
    'jump', 'swim', 'hand', 'foot', 'door', // 5 new words
  ];
  final List<String> _intermediateWords = [
    // 6-8 letter moderately complex words
    'garden', 'planet', 'bridge', 'frozen', 'bright', 'silver',
    'orange', 'purple', 'window', 'friend', 'travel', 'nature',
    'stream', 'flower', 'summer', 'winter', 'golden', 'castle',
    'jungle', 'island', 'market', 'museum', 'rocket', 'secret',
    'ancient', 'harmony', 'thunder', 'courage', 'mystery', // 5 new words
  ];
  final List<String> _advancedWords = [
    // 9-14 letter challenging words with difficult letter patterns
    'phenomenon', 'psychology', 'archaeology', 'choreography',
    'xylophone', 'hypothesis', 'catastrophe', 'constellation',
    'bibliography', 'kaleidoscope', 'onomatopoeia', 'entrepreneur',
    'questionnaire', 'surveillance', 'acquaintance', 'chrysanthemum',
    'labyrinth', 'silhouette', 'pneumonia', 'bureaucracy',
    'Renaissance',
    'magnificent',
    'perpendicular',
    'circumstances',
    'unprecedented', // 5 new words
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
    'Fruits': [
      'Apple',
      'Banana',
      'Orange',
      'Grape',
      'Mango',
      'Peach',
      'Cherry',
      'Melon',
      'Plum',
      'Pear',
      'Kiwi',
    ],
    'Animals': [
      'Dog',
      'Cat',
      'Elephant',
      'Lion',
      'Bird',
      'Fish',
      'Tiger',
      'Bear',
      'Rabbit',
      'Deer',
      'Wolf',
    ],
    'Colors': [
      'Red',
      'Blue',
      'Green',
      'Yellow',
      'Purple',
      'Orange',
      'Pink',
      'Brown',
      'Black',
      'White',
      'Gray',
    ],
    'Numbers': [
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Zero',
    ],
  };

  // Intermediate categories (somewhat related)
  final Map<String, List<String>> _intermediateCategories = {
    'Mammals': [
      'Dog',
      'Cat',
      'Elephant',
      'Whale',
      'Bat',
      'Dolphin',
      'Horse',
      'Deer',
      'Tiger',
      'Bear',
      'Wolf',
    ],
    'Birds': [
      'Eagle',
      'Sparrow',
      'Penguin',
      'Owl',
      'Parrot',
      'Flamingo',
      'Hawk',
      'Swan',
      'Crow',
      'Robin',
      'Dove',
    ],
    'Vegetables': [
      'Carrot',
      'Broccoli',
      'Spinach',
      'Potato',
      'Onion',
      'Pepper',
      'Tomato',
      'Cabbage',
      'Lettuce',
      'Corn',
      'Bean',
    ],
    'Fruits': [
      'Apple',
      'Banana',
      'Orange',
      'Mango',
      'Grape',
      'Kiwi',
      'Pineapple',
      'Strawberry',
      'Watermelon',
      'Peach',
      'Lemon',
    ],
    'Land Vehicles': [
      'Car',
      'Bus',
      'Train',
      'Bicycle',
      'Motorcycle',
      'Truck',
      'Van',
      'Taxi',
      'Scooter',
      'Tram',
      'Jeep',
    ],
    'Water Vehicles': [
      'Boat',
      'Ship',
      'Submarine',
      'Canoe',
      'Yacht',
      'Ferry',
      'Kayak',
      'Raft',
      'Cruiser',
      'Sailboat',
      'Jetski',
    ],
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
      'Zucchini',
      'Eggplant',
      'Squash',
      'Okra',
      'Pea',
    ], // Botanical fruits
    'Vegetables': [
      'Carrot',
      'Potato',
      'Onion',
      'Celery',
      'Lettuce',
      'Spinach',
      'Radish',
      'Beet',
      'Turnip',
      'Garlic',
      'Leek',
    ], // Culinary veggies
    'Insects': [
      'Ant',
      'Bee',
      'Butterfly',
      'Beetle',
      'Dragonfly',
      'Grasshopper',
      'Moth',
      'Wasp',
      'Cricket',
      'Fly',
      'Ladybug',
    ],
    'Arachnids': [
      'Spider',
      'Scorpion',
      'Tick',
      'Mite',
      'Tarantula',
      'Harvestman',
      'Vinegaroon',
      'Pseudoscorpion',
      'Whipspider',
      'Solpugid',
      'Opilion',
    ],
    'Reptiles': [
      'Snake',
      'Lizard',
      'Crocodile',
      'Turtle',
      'Gecko',
      'Iguana',
      'Chameleon',
      'Komodo',
      'Python',
      'Viper',
      'Cobra',
    ],
    'Amphibians': [
      'Frog',
      'Toad',
      'Salamander',
      'Newt',
      'Axolotl',
      'Caecilian',
      'Mudpuppy',
      'Siren',
      'Hellbender',
      'Olm',
      'Eft',
    ],
    'Herbs': [
      'Basil',
      'Mint',
      'Oregano',
      'Thyme',
      'Rosemary',
      'Parsley',
      'Cilantro',
      'Dill',
      'Chives',
      'Sage',
      'Tarragon',
    ],
    'Spices': [
      'Cinnamon',
      'Pepper',
      'Cumin',
      'Turmeric',
      'Paprika',
      'Ginger',
      'Cardamom',
      'Clove',
      'Nutmeg',
      'Saffron',
      'Coriander',
    ],
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

  Color _withOpacity(Color color, double opacity) {
    final clamped = opacity.clamp(0.0, 1.0);
    return color.withValues(alpha: clamped);
  }

  // Show quit confirmation dialog
  void _showQuitDialog() {
    // Pause timer if running
    _mathTimer?.cancel();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _withOpacity(AppColors.accentYellow, 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.pause_circle_filled,
                color: AppColors.accentYellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Game Paused',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What would you like to do?',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _withOpacity(AppColors.primary, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Current Score: $_score',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resume button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Restart timer if it was a math game
                  if (widget.gameId == 'math_speed' &&
                      !_gameOver &&
                      !_showingFeedback) {
                    _startMathTimer();
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume Game'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Restart button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartGame();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Restart Game'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // End game and save
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _endGame();
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('End & Save Score'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.accentGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Quit without saving
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  this.context.pop();
                },
                icon: Icon(Icons.exit_to_app_rounded, color: AppColors.error),
                label: Text(
                  'Quit Without Saving',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Restart the current game
  void _restartGame() {
    _mathTimer?.cancel();
    _memoryTimer?.cancel();
    setState(() {
      _score = 0;
      _currentQuestion = 0;
      _gameOver = false;
      _currentLives = _maxLives;
      _combo = 0;
      _maxCombo = 0;
      _correctAnswers = 0;
      _showingFeedback = false;
      _lastAnswerCorrect = null;
      _lastFailedWord = '';
    });
    _initializeGame();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Reset shake controller when animation completes to prevent residual movement
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

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
      onCancel: () {
        // Navigate back to games screen when Maybe Later is pressed
        if (mounted && context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _initializeGame() {
    // Track when game started for session recording
    _gameStartTime = DateTime.now();
    _correctAnswers = 0;

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

    var shouldEndGame = false;
    setState(() {
      _currentLives = max(0, _currentLives - 1);
      _combo = 0;
      if (_currentLives == 0) {
        shouldEndGame = true;
      }
    });

    if (shouldEndGame) {
      _endGame();
    }
  }

  void _gainPoints(int base) {
    HapticFeedback.lightImpact();
    setState(() {
      _combo++;
      _correctAnswers++; // Track correct answers for session
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

    // Update old provider (for backwards compatibility)
    ref
        .read(brainGamesProvider.notifier)
        .updateHighScore(widget.gameId, _score);

    // Record session with adaptive difficulty provider for persistence
    _recordGameSession();

    // Check for game-related achievements
    _checkGameAchievements();
  }

  Future<void> _checkGameAchievements() async {
    final journeyService = ref.read(userJourneyServiceProvider);
    final stats = await journeyService.getJourneyStats();

    // Check achievements based on games played and score
    await journeyService.checkGameAchievements(
      gamesPlayed: stats.totalGameSessions + 1,
      highScore: _score,
      gameId: widget.gameId,
    );
  }

  Future<void> _recordGameSession() async {
    final endTime = DateTime.now();
    final duration = _gameStartTime != null
        ? endTime.difference(_gameStartTime!)
        : const Duration(minutes: 1);

    // Calculate wrong answers
    final wrongAnswers = (_maxLives - _currentLives).clamp(0, _maxLives);

    // Create a completed session
    final session = GameSession(
      id: '${widget.gameId}_${endTime.millisecondsSinceEpoch}',
      gameId: widget.gameId,
      difficulty: _difficulty,
      startedAt: _gameStartTime ?? endTime.subtract(duration),
      endedAt: endTime,
      score: _score,
      questionsAnswered: _currentQuestion,
      correctAnswers: _correctAnswers,
      wrongAnswers: wrongAnswers,
      maxCombo: _maxCombo,
      completionTime: duration,
    );

    // Save to persistent storage
    await ref.read(gamePerformanceProvider.notifier).completeSession(session);
  }

  // ==================== MATH SPEED ====================
  void _generateMathQuestion() {
    final random = Random();
    _mathTimer?.cancel(); // Cancel any existing timer

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
        _mathTimeTotal = 15; // 15 seconds for beginner
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
        _mathTimeTotal = 10; // 10 seconds for intermediate
        break;

      case GameDifficulty.advanced:
        // Large numbers, all 4 operations
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
        _mathTimeTotal = 7; // 7 seconds for advanced
        break;
    }

    setState(() {
      _userAnswer = '';
      _lastAnswerCorrect = null;
      _showingFeedback = false;
      _mathTimeLeft = _mathTimeTotal;
    });

    // Start the timer
    _startMathTimer();
  }

  void _startMathTimer() {
    _mathTimer?.cancel();
    _mathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameOver || _showingFeedback) {
        timer.cancel();
        return;
      }

      setState(() {
        _mathTimeLeft--;
      });

      // Time's up!
      if (_mathTimeLeft <= 0) {
        timer.cancel();
        _onMathTimeUp();
      }
    });
  }

  void _onMathTimeUp() {
    if (_showingFeedback || _gameOver) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _showingFeedback = true;
      _lastAnswerCorrect = false;
    });
    _loseLife();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && !_gameOver) {
        _generateMathQuestion();
      }
    });
  }

  void _onNumberPadTap(String value) {
    if (_showingFeedback || _gameOver) return;

    HapticFeedback.selectionClick();
    setState(() {
      if (_userAnswer.length < 6) {
        // Max 6 digits
        _userAnswer += value;
      }
    });
  }

  void _onBackspaceTap() {
    if (_showingFeedback || _gameOver || _userAnswer.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
    });
  }

  void _onSubmitAnswer() {
    if (_showingFeedback || _gameOver || _userAnswer.isEmpty) return;

    _mathTimer?.cancel();
    final answer = int.tryParse(_userAnswer) ?? -1;
    final isCorrect = answer == _correctAnswer;

    HapticFeedback.mediumImpact();
    setState(() {
      _showingFeedback = true;
      _lastAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      // Bonus points for time remaining
      int basePoints = _difficulty == GameDifficulty.advanced
          ? 25
          : _difficulty == GameDifficulty.intermediate
          ? 15
          : 10;
      int timeBonus = (_mathTimeLeft * 2); // 2 points per second remaining
      _gainPoints(basePoints + timeBonus);
    } else {
      _loseLife();
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
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

    // Set time based on difficulty (reduced for more challenge)
    switch (_difficulty) {
      case GameDifficulty.beginner:
        _memoryTimeTotal = 45; // 45 seconds
        break;
      case GameDifficulty.intermediate:
        _memoryTimeTotal = 35; // 35 seconds
        break;
      case GameDifficulty.advanced:
        _memoryTimeTotal = 25; // 25 seconds
        break;
    }
    _memoryTimeLeft = _memoryTimeTotal;

    // Start timer
    _startMemoryTimer();

    setState(() {});
  }

  void _startMemoryTimer() {
    _memoryTimer?.cancel();
    _memoryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        _memoryTimeLeft--;
      });

      if (_memoryTimeLeft <= 0) {
        timer.cancel();
        _handleMemoryTimeUp();
      }
    });
  }

  void _handleMemoryTimeUp() {
    if (_gameOver) return;

    // Check if all pairs are already matched (user won)
    if (_matches >= _pairCount) {
      _memoryTimer?.cancel();
      _endGame();
      return;
    }

    // Reset current selection
    if (_firstCard != null) {
      _revealed[_firstCard!] = false;
    }
    if (_secondCard != null) {
      _revealed[_secondCard!] = false;
    }
    _firstCard = null;
    _secondCard = null;
    _canTap = true;

    // Lose a life
    _loseLife();

    // If still alive, reset timer for next attempt
    if (_currentLives > 0 && !_gameOver) {
      setState(() {
        _memoryTimeLeft = _memoryTimeTotal;
      });
      _startMemoryTimer();
    }
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

        // Reset timer on successful match (only if game not finished)
        if (_matches < _pairCount) {
          setState(() {
            _memoryTimeLeft = _memoryTimeTotal;
          });
        }

        if (_matches == _pairCount) {
          _memoryTimer?.cancel();
          _endGame();
        }
      } else {
        // Wrong match - just flip cards back, NO life deducted
        // Lives are only lost when timer runs out
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

    // Avoid unbounded recursion; try a few shuffles and fall back.
    var scrambled = _originalWord;
    for (int i = 0; i < 8; i++) {
      chars.shuffle();
      scrambled = chars.join();
      if (scrambled != _originalWord) break;
    }
    if (scrambled == _originalWord) {
      scrambled = chars.reversed.join();
    }
    _scrambledWord = scrambled;

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
    if (_answerController.text.toLowerCase().trim() ==
        _originalWord.toLowerCase()) {
      _gainPoints(
        _difficulty == GameDifficulty.advanced
            ? 50
            : _difficulty == GameDifficulty.intermediate
            ? 30
            : 20,
      );
      _generateWordScramble();
    } else if (_answerController.text.isNotEmpty) {
      // Store the word for game over display before losing life
      _lastFailedWord = _originalWord;
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
    final int baseCells = _activeCells;
    int cellsPerLevel;
    int showTime;

    switch (_difficulty) {
      case GameDifficulty.beginner:
        cellsPerLevel = 1; // Add 1 per level
        showTime = 3000; // 3 seconds to memorize
        break;
      case GameDifficulty.intermediate:
        cellsPerLevel = 1; // Add 1 per level
        showTime = 2000; // 2 seconds
        break;
      case GameDifficulty.advanced:
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
    outerLoop:
    for (int i = 0; i < _patternSize; i++) {
      for (int j = 0; j < _patternSize; j++) {
        if (_pattern[i][j] != _userPattern[i][j]) {
          correct = false;
          break outerLoop;
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
    _mathTimer?.cancel();
    _memoryTimer?.cancel();
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
              // Only apply shake offset when animation is actually running
              final shakeValue = _shakeAnimation.value;
              if (shakeValue == 0) {
                return child!;
              }
              // Use sin function for smooth left-right oscillation instead of random
              final offset = shakeValue * sin(_shakeController.value * pi * 8);
              return Transform.translate(
                offset: Offset(offset, 0),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button - shows quit dialog instead of instant exit
          GestureDetector(
            onTap: _showQuitDialog,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
          ),

          SizedBox(width: isSmallScreen ? 10 : 16),

          // Lives (Hearts)
          Row(
            children: List.generate(_maxLives, (index) {
              final isActive = index < _currentLives;
              return Padding(
                padding: EdgeInsets.only(right: isSmallScreen ? 2 : 4),
                child:
                    Icon(
                          isActive ? Icons.favorite : Icons.favorite_border,
                          color: isActive ? Colors.red : Colors.grey.shade400,
                          size: isSmallScreen ? 18 : 24,
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
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: isSmallScreen ? 12 : 16,
                  ),
                  SizedBox(width: isSmallScreen ? 2 : 4),
                  Text(
                    '${_combo}x',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 11 : 14,
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 200.ms),

          SizedBox(width: isSmallScreen ? 8 : 12),

          // Score
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 10 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: _withOpacity(AppColors.primary, 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: AppColors.primary,
                  size: isSmallScreen ? 14 : 18,
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                Text(
                  '$_score',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 13 : 16,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final timerProgress = _mathTimeTotal > 0
        ? _mathTimeLeft / _mathTimeTotal
        : 0.0;
    final isLowTime = _mathTimeLeft <= 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: Column(
        children: [
          // Timer Bar with animated progress
          _buildTimerBar(isDark, timerProgress, isLowTime, isSmallScreen),

          SizedBox(height: isSmallScreen ? 8 : 12),

          // Math equation card - Compact
          Expanded(
            flex: 3,
            child: _buildMathEquationCard(isDark, isSmallScreen),
          ),

          SizedBox(height: isSmallScreen ? 8 : 12),

          // Answer display box
          _buildAnswerDisplay(isDark, isSmallScreen),

          SizedBox(height: isSmallScreen ? 8 : 12),

          // Number pad
          Expanded(flex: 4, child: _buildNumberPad(isDark, isSmallScreen)),
        ],
      ),
    );
  }

  Widget _buildTimerBar(
    bool isDark,
    double progress,
    bool isLowTime,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: isSmallScreen ? 14 : 18,
                color: isLowTime
                    ? Colors.red
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Text(
                '${_mathTimeLeft}s',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: isLowTime ? Colors.red : AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Q${_currentQuestion + 1}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                isLowTime
                    ? Colors.red
                    : (progress > 0.5 ? Colors.green : Colors.orange),
              ),
              minHeight: isSmallScreen ? 6 : 8,
            ),
          ).animate(target: isLowTime ? 1 : 0).shake(hz: 4, duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildMathEquationCard(bool isDark, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 14 : 20,
        horizontal: isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _showingFeedback
              ? (_lastAnswerCorrect == true
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.red.shade400, Colors.red.shade600])
              : (isDark
                    ? [AppColors.cardDark, AppColors.surfaceDark]
                    : [Colors.white, Colors.grey.shade50]),
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: _showingFeedback
                ? (_lastAnswerCorrect == true
                      ? _withOpacity(Colors.green, 0.3)
                      : _withOpacity(Colors.red, 0.3))
                : _withOpacity(AppColors.primary, 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Equation row
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_num1',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 32 : 42,
                    fontWeight: FontWeight.bold,
                    color: _showingFeedback
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 16,
                  ),
                  child: Container(
                    width: isSmallScreen ? 36 : 48,
                    height: isSmallScreen ? 36 : 48,
                    decoration: BoxDecoration(
                      color: _showingFeedback
                          ? _withOpacity(Colors.white, 0.2)
                          : _withOpacity(AppColors.primary, 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _operator,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: _showingFeedback
                              ? Colors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '$_num2',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 32 : 42,
                    fontWeight: FontWeight.bold,
                    color: _showingFeedback
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 16,
                  ),
                  child: Text(
                    '=',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: _showingFeedback
                          ? Colors.white
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                    ),
                  ),
                ),
                Text(
                  '?',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 32 : 42,
                    fontWeight: FontWeight.bold,
                    color: _showingFeedback ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Feedback message
          if (_showingFeedback) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _lastAnswerCorrect == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: Colors.white,
                  size: isSmallScreen ? 18 : 24,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Flexible(
                  child: Text(
                    _lastAnswerCorrect == true
                        ? 'Correct! +${(_mathTimeLeft * 2)} time bonus'
                        : 'Answer: $_correctAnswer',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerDisplay(bool isDark, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      height: isSmallScreen ? 55 : 70,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(
          color: _userAnswer.isNotEmpty
              ? AppColors.primary
              : (isDark ? Colors.white12 : Colors.grey.shade300),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _userAnswer.isEmpty ? 'Type your answer' : _userAnswer,
          style: TextStyle(
            fontSize: _userAnswer.isEmpty
                ? (isSmallScreen ? 14 : 18)
                : (isSmallScreen ? 28 : 36),
            fontWeight: _userAnswer.isEmpty ? FontWeight.w400 : FontWeight.bold,
            color: _userAnswer.isEmpty
                ? (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            letterSpacing: _userAnswer.isEmpty ? 0 : (isSmallScreen ? 2 : 4),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(bool isDark, bool isSmallScreen) {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Expanded(
          child: _buildNumberRow(['1', '2', '3'], isDark, isSmallScreen),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        // Row 2: 4, 5, 6
        Expanded(
          child: _buildNumberRow(['4', '5', '6'], isDark, isSmallScreen),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        // Row 3: 7, 8, 9
        Expanded(
          child: _buildNumberRow(['7', '8', '9'], isDark, isSmallScreen),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        // Row 4: Backspace, 0, Submit
        Expanded(child: _buildBottomRow(isDark, isSmallScreen)),
      ],
    );
  }

  Widget _buildNumberRow(
    List<String> numbers,
    bool isDark,
    bool isSmallScreen,
  ) {
    return Row(
      children: numbers.map((digit) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: _buildNumberButton(digit, isDark, isSmallScreen),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number, bool isDark, bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _onNumberPadTap(number),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: _withOpacity(Colors.black, isDark ? 0.2 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRow(bool isDark, bool isSmallScreen) {
    return Row(
      children: [
        // Backspace button
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: GestureDetector(
              onTap: _onBackspaceTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: _withOpacity(Colors.orange, 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.backspace_outlined,
                    size: isSmallScreen ? 22 : 28,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ),
          ),
        ),
        // 0 button
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: _buildNumberButton('0', isDark, isSmallScreen),
          ),
        ),
        // Submit button
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: GestureDetector(
              onTap: _onSubmitAnswer,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _userAnswer.isNotEmpty
                      ? const LinearGradient(
                          colors: [Colors.green, Colors.teal],
                        )
                      : null,
                  color: _userAnswer.isEmpty
                      ? (isDark ? AppColors.surfaceDark : Colors.grey.shade200)
                      : null,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  boxShadow: [
                    if (_userAnswer.isNotEmpty)
                      BoxShadow(
                        color: _withOpacity(Colors.green, 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: isSmallScreen ? 28 : 36,
                    color: _userAnswer.isNotEmpty
                        ? Colors.white
                        : (isDark ? AppColors.textSecondaryDark : Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== MEMORY MATCH UI ====================
  Widget _buildMemoryGame() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    int crossAxisCount = _pairCount <= 4 ? 4 : (_pairCount <= 6 ? 4 : 4);

    // Calculate timer color based on time left
    Color timerColor;
    if (_memoryTimeLeft <= 10) {
      timerColor = Colors.red;
    } else if (_memoryTimeLeft <= 20) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.green;
    }

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          // Timer and Matches row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Matches counter
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: isSmallScreen ? 14 : 18,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      '$_matches / $_pairCount',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Timer display
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: _withOpacity(timerColor, 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _withOpacity(timerColor, 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: isSmallScreen ? 14 : 18,
                      color: timerColor,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      '${_memoryTimeLeft}s',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Timer progress bar
          SizedBox(height: isSmallScreen ? 8 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _memoryTimeTotal > 0
                  ? _memoryTimeLeft / _memoryTimeTotal
                  : 0,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              minHeight: isSmallScreen ? 4 : 6,
            ),
          ),

          SizedBox(height: isSmallScreen ? 10 : 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                crossAxisSpacing: isSmallScreen ? 6 : 10,
                mainAxisSpacing: isSmallScreen ? 6 : 10,
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
                          ? _withOpacity(_getCardColor(_cards[index]), 0.3)
                          : (isRevealed
                                ? _getCardColor(_cards[index])
                                : (isDark ? AppColors.cardDark : Colors.white)),
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 12 : 16,
                      ),
                      boxShadow: [
                        if (!isMatched)
                          BoxShadow(
                            color: _withOpacity(
                              Colors.black,
                              isDark ? 0.3 : 0.1,
                            ),
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
                              size: isSmallScreen ? 24 : 32,
                            )
                          : Icon(
                              Icons.question_mark,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              size: isSmallScreen ? 18 : 24,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          const Spacer(),

          Text(
            'Unscramble the Word',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Scrambled word display
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 20 : 32,
              horizontal: isSmallScreen ? 16 : 24,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _withOpacity(AppColors.primary, 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _scrambledWord.toUpperCase(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isSmallScreen ? 4 : 8,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _withOpacity(Colors.white, 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _hint,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      color: _withOpacity(Colors.white, 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: isSmallScreen ? 20 : 32),

          // Answer input
          TextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.none,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 24,
              letterSpacing: isSmallScreen ? 2 : 4,
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
                fontSize: isSmallScreen ? 14 : null,
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 14 : 20,
                horizontal: isSmallScreen ? 16 : 24,
              ),
            ),
            onSubmitted: (_) => _checkWordAnswer(),
          ),

          SizedBox(height: isSmallScreen ? 14 : 20),

          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: _checkWordAnswer,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Calculate sequence item size based on screen and sequence length
    final availableWidth =
        screenWidth - (isSmallScreen ? 32 : 48) - 32; // padding
    final itemWidth = (availableWidth / _sequence.length).clamp(36.0, 50.0);

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          const Spacer(),

          Text(
            'Find the Missing Number',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          if (_difficulty == GameDifficulty.beginner) ...[
            SizedBox(height: isSmallScreen ? 6 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: _withOpacity(AppColors.primary, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hint: $_patternHint',
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Sequence display
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 16 : 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _withOpacity(Colors.black, isDark ? 0.2 : 0.08),
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
                  width: itemWidth,
                  height: itemWidth,
                  margin: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isHidden
                        ? _withOpacity(AppColors.primary, 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                    border: Border.all(
                      color: isHidden
                          ? AppColors.primary
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                      width: isHidden ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          isHidden ? '?' : '${_sequence[index]}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: isHidden
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: isSmallScreen ? 20 : 32),

          // Options
          Wrap(
            spacing: isSmallScreen ? 10 : 16,
            runSpacing: isSmallScreen ? 10 : 16,
            children: _sequenceOptions.map((option) {
              return SizedBox(
                width: isSmallScreen ? 80 : 100,
                height: isSmallScreen ? 46 : 56,
                child: ElevatedButton(
                  onPressed: () => _checkSequenceAnswer(option),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 12 : 16,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$option',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 10 : 16),

          Text(
            'Sort into the correct category',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Item to sort
          Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 32 : 48,
                  vertical: isSmallScreen ? 20 : 28,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _withOpacity(AppColors.primary, 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _currentItem,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9)),

          SizedBox(height: isSmallScreen ? 28 : 40),

          // Category buttons
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  _currentCategory1,
                  Colors.blue,
                  1,
                  isDark,
                  isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 16),
              Expanded(
                child: _buildCategoryButton(
                  _currentCategory2,
                  Colors.orange,
                  2,
                  isDark,
                  isSmallScreen,
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
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: () => _checkCategoryAnswer(categoryNum),
      child: Container(
        height: isSmallScreen ? 110 : 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
          border: Border.all(color: _withOpacity(color, 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: _withOpacity(color, 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
              decoration: BoxDecoration(
                color: _withOpacity(color, 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: color,
                size: isSmallScreen ? 24 : 32,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 10 : 16),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: _showPattern
                  ? _withOpacity(Colors.orange, 0.1)
                  : _withOpacity(AppColors.primary, 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _showPattern ? '👀 Memorize!' : '🧠 Recreate the pattern',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: _showPattern ? Colors.orange : AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 6 : 8),

          Text(
            'Level $_patternLevel',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Pattern grid
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _withOpacity(Colors.black, isDark ? 0.2 : 0.08),
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
                crossAxisSpacing: isSmallScreen ? 6 : 10,
                mainAxisSpacing: isSmallScreen ? 6 : 10,
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
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 8 : 12,
                      ),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: _withOpacity(AppColors.primary, 0.4),
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

          SizedBox(height: isSmallScreen ? 20 : 32),

          if (!_showPattern)
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 48 : 56,
              child: ElevatedButton(
                onPressed: _checkPattern,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Check Pattern',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
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
    final isWordScramble = widget.gameId == 'word_scramble';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child:
            Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: _withOpacity(Colors.black, isDark ? 0.3 : 0.1),
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
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 80 : 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _withOpacity(Colors.amber, 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: isSmallScreen ? 40 : 50,
                          color: Colors.white,
                        ),
                      ).animate().scale(
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      Text(
                        'Game Over!',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),

                      // Show the answer for Word Scramble if player failed
                      if (isWordScramble && _lastFailedWord.isNotEmpty) ...[
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 14 : 20,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: _withOpacity(Colors.blue, 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _withOpacity(Colors.blue, 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'The word was:',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _lastFailedWord.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 18 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Stats
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
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
                              isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            _buildStatRow(
                              'Correct Answers',
                              '$_currentQuestion',
                              Colors.green,
                              isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            _buildStatRow(
                              'Max Combo',
                              '${_maxCombo}x',
                              Colors.orange,
                              isSmallScreen,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Exit',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _score = 0;
                                  _currentQuestion = 0;
                                  _currentLives = _maxLives;
                                  _combo = 0;
                                  _maxCombo = 0;
                                  _correctAnswers = 0;
                                  _gameOver = false;
                                  _lastFailedWord = '';
                                });
                                _initializeGame();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Play Again',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildStatRow(
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: _withOpacity(color, 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
