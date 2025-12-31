import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GamePlayScreen({super.key, required this.gameId});

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  late Timer _timer;
  int _timeLeft = 60;
  int _score = 0;
  int _currentQuestion = 0; // Used for tracking progress
  bool _gameOver = false;

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

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
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

  void _initializeMemoryGame() {
    final pairs = [1, 2, 3, 4, 5, 6, 7, 8];
    _cards = [...pairs, ...pairs];
    _cards.shuffle();
    _revealed = List.filled(_cards.length, false);
    _matches = 0;
    setState(() {});
  }

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

  void _checkMathAnswer(int answer) {
    if (answer == _correctAnswer) {
      setState(() {
        _score += 10;
        _currentQuestion++;
      });
      _generateMathQuestion();
    } else {
      setState(() {
        _score = max(0, _score - 5);
      });
    }
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
        _firstCard = null;
        _secondCard = null;
        _canTap = true;

        if (_matches == 8) {
          // Bonus for completing the game
          setState(() {
            _score += _timeLeft * 2;
          });
          _endGame();
        }
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _revealed[_firstCard!] = false;
            _revealed[_secondCard!] = false;
            _firstCard = null;
            _secondCard = null;
            _canTap = true;
          });
        });
      }
    }
  }

  void _checkWordAnswer() {
    if (_answerController.text.toLowerCase().trim() == _originalWord) {
      setState(() {
        _score += 15;
        _currentQuestion++;
      });
      _generateWordScramble();
    }
  }

  void _endGame() {
    _timer.cancel();
    setState(() {
      _gameOver = true;
    });
    ref
        .read(brainGamesProvider.notifier)
        .updateHighScore(widget.gameId, _score);
  }

  @override
  void dispose() {
    _timer.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _timer.cancel();
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
      body: _gameOver ? _buildGameOverScreen() : _buildGameContent(),
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
