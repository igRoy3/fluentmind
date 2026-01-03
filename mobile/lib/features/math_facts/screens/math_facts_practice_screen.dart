// Math Facts Practice Screen - Timed game with MCQ or NumPad modes
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/math_facts_data.dart';

class MathFactsPracticeScreen extends StatefulWidget {
  final PracticeMode mode;
  final PracticeLevel level;

  const MathFactsPracticeScreen({
    super.key,
    required this.mode,
    required this.level,
  });

  @override
  State<MathFactsPracticeScreen> createState() =>
      _MathFactsPracticeScreenState();
}

class _MathFactsPracticeScreenState extends State<MathFactsPracticeScreen>
    with TickerProviderStateMixin {
  // Game state
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _currentLives = 3;
  int _combo = 0;
  int _maxCombo = 0;
  int _timeRemaining = 60; // 60 seconds game
  Timer? _gameTimer;

  // Question state
  MathQuestion? _currentQuestion;
  String _userAnswer = '';
  bool? _lastAnswerCorrect;

  // Animation controllers
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _correctAnimController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _correctAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    _correctAnimController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _correctAnswers = 0;
      _wrongAnswers = 0;
      _currentLives = 3;
      _combo = 0;
      _maxCombo = 0;
      _timeRemaining = 60;
      _userAnswer = '';
      _lastAnswerCorrect = null;
    });
    _generateQuestion();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _generateQuestion() {
    setState(() {
      _currentQuestion = MathFactsGenerator.generateQuestion(widget.mode);
      _userAnswer = '';
      _lastAnswerCorrect = null;
    });
  }

  void _checkAnswer(int answer) {
    if (_currentQuestion == null || !_isPlaying) return;

    final isCorrect = answer == _currentQuestion!.correctAnswer;
    HapticFeedback.mediumImpact();

    setState(() {
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;

        // Score: base 10 + combo bonus + time bonus
        int points = 10 + (_combo * 2);
        if (_timeRemaining > 30) points += 5; // Time bonus
        _score += points;

        _correctAnimController.forward(from: 0);
      } else {
        _wrongAnswers++;
        _combo = 0;
        _currentLives--;
        _shakeController.forward(from: 0);

        if (_currentLives <= 0) {
          _endGame();
          return;
        }
      }
    });

    // Delay then next question
    Future.delayed(Duration(milliseconds: isCorrect ? 300 : 800), () {
      if (_isPlaying && mounted) {
        _generateQuestion();
      }
    });
  }

  void _submitNumPadAnswer() {
    if (_userAnswer.isEmpty) return;
    final answer = int.tryParse(_userAnswer);
    if (answer != null) {
      _checkAnswer(answer);
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    HapticFeedback.heavyImpact();
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quit Game?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Quit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return PopScope(
      canPop: !_isPlaying,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isPlaying) {
          _showQuitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        body: SafeArea(
          child: _isGameOver
              ? _buildGameOver(isDark, isSmallScreen)
              : Column(
                  children: [
                    _buildTopBar(isDark, isSmallScreen),
                    Expanded(child: _buildGameContent(isDark, isSmallScreen)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Close button
              IconButton(
                onPressed: _showQuitDialog,
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  size: isSmallScreen ? 22 : 26,
                ),
              ),

              // Mode indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getModeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.mode.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    color: _getModeColor(),
                  ),
                ),
              ),

              const Spacer(),

              // Score
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 16 : 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),

          // Stats row: Lives, Timer, Combo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Lives
              Row(
                children: List.generate(3, (index) {
                  final hasLife = index < _currentLives;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      hasLife
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: hasLife ? AppColors.error : AppColors.textHint,
                      size: isSmallScreen ? 22 : 26,
                    ),
                  );
                }),
              ),

              // Timer
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 14 : 18,
                  vertical: isSmallScreen ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: _timeRemaining <= 10
                      ? AppColors.error.withOpacity(0.1)
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _timeRemaining <= 10
                        ? AppColors.error.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: _timeRemaining <= 10
                          ? AppColors.error
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      size: isSmallScreen ? 16 : 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_timeRemaining',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: _timeRemaining <= 10
                            ? AppColors.error
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      's',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Combo
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: _combo > 0
                      ? AppColors.accentYellow.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: _combo > 0
                          ? AppColors.accentYellow
                          : AppColors.textHint,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_combo}x',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: _combo > 0
                            ? AppColors.accentYellow
                            : (isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(bool isDark, bool isSmallScreen) {
    if (_currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = sin(_shakeController.value * pi * 4) * 10;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          children: [
            const Spacer(),

            // Question Card
            _buildQuestionCard(isDark, isSmallScreen),

            SizedBox(height: isSmallScreen ? 24 : 32),

            // Answer Area (MCQ or NumPad)
            widget.level == PracticeLevel.level1
                ? _buildMCQOptions(isDark, isSmallScreen)
                : _buildNumPadInput(isDark, isSmallScreen),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(bool isDark, bool isSmallScreen) {
    return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getModeColor().withOpacity(0.15),
                _getModeColor().withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _lastAnswerCorrect == true
                  ? AppColors.success
                  : _lastAnswerCorrect == false
                  ? AppColors.error
                  : _getModeColor().withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Type indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getModeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getQuestionTypeLabel(),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: _getModeColor(),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              // Question
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _currentQuestion!.question,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 36 : 48,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),

              // Feedback indicator
              if (_lastAnswerCorrect != null) ...[
                SizedBox(height: isSmallScreen ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _lastAnswerCorrect!
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: _lastAnswerCorrect!
                          ? AppColors.success
                          : AppColors.error,
                      size: isSmallScreen ? 24 : 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _lastAnswerCorrect!
                          ? '+${10 + (_combo * 2)} pts'
                          : 'Answer: ${_currentQuestion!.correctAnswer}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: _lastAnswerCorrect!
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        )
        .animate(target: _lastAnswerCorrect == true ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 200.ms,
        );
  }

  Widget _buildMCQOptions(bool isDark, bool isSmallScreen) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: isSmallScreen ? 10 : 12,
      crossAxisSpacing: isSmallScreen ? 10 : 12,
      childAspectRatio: isSmallScreen ? 2.2 : 2.5,
      children: _currentQuestion!.options.map((option) {
        final isCorrect = option == _currentQuestion!.correctAnswer;
        final showFeedback = _lastAnswerCorrect != null;

        Color bgColor;
        Color textColor;
        Color borderColor;

        if (showFeedback && isCorrect) {
          bgColor = AppColors.success.withOpacity(0.2);
          textColor = AppColors.success;
          borderColor = AppColors.success;
        } else if (showFeedback && !isCorrect && _lastAnswerCorrect == false) {
          bgColor = isDark ? AppColors.cardDark : Colors.white;
          textColor = isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary;
          borderColor = Colors.transparent;
        } else {
          bgColor = isDark ? AppColors.cardDark : Colors.white;
          textColor = isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimary;
          borderColor = _getModeColor().withOpacity(0.3);
        }

        return GestureDetector(
          onTap: _lastAnswerCorrect == null ? () => _checkAnswer(option) : null,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '$option',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumPadInput(bool isDark, bool isSmallScreen) {
    return Column(
      children: [
        // Answer display
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 20,
            vertical: isSmallScreen ? 14 : 18,
          ),
          margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getModeColor().withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _userAnswer.isEmpty ? '?' : _userAnswer,
                style: TextStyle(
                  fontSize: isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _userAnswer.isEmpty
                      ? (isDark ? AppColors.textHintDark : AppColors.textHint)
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                ),
              ),
              if (_userAnswer.isNotEmpty)
                Container(
                      width: 2,
                      height: isSmallScreen ? 28 : 36,
                      margin: const EdgeInsets.only(left: 2),
                      color: _getModeColor(),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .fade(begin: 1, end: 0, duration: 500.ms),
            ],
          ),
        ),

        // Number pad
        SizedBox(
          width: isSmallScreen ? 260 : 300,
          child: Column(
            children: [
              // Row 1: 1, 2, 3
              _buildNumPadRow(['1', '2', '3'], isDark, isSmallScreen),
              SizedBox(height: isSmallScreen ? 8 : 10),
              // Row 2: 4, 5, 6
              _buildNumPadRow(['4', '5', '6'], isDark, isSmallScreen),
              SizedBox(height: isSmallScreen ? 8 : 10),
              // Row 3: 7, 8, 9
              _buildNumPadRow(['7', '8', '9'], isDark, isSmallScreen),
              SizedBox(height: isSmallScreen ? 8 : 10),
              // Row 4: Clear, 0, Submit
              Row(
                children: [
                  _buildNumPadButton(
                    'C',
                    isDark,
                    isSmallScreen,
                    isAction: true,
                    actionColor: AppColors.error,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  _buildNumPadButton('0', isDark, isSmallScreen),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  _buildNumPadButton(
                    '✓',
                    isDark,
                    isSmallScreen,
                    isAction: true,
                    actionColor: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumPadRow(
    List<String> numbers,
    bool isDark,
    bool isSmallScreen,
  ) {
    return Row(
      children: numbers.asMap().entries.map((entry) {
        return Expanded(
          child: Row(
            children: [
              if (entry.key > 0) SizedBox(width: isSmallScreen ? 8 : 10),
              Expanded(
                child: _buildNumPadButton(entry.value, isDark, isSmallScreen),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumPadButton(
    String label,
    bool isDark,
    bool isSmallScreen, {
    bool isAction = false,
    Color? actionColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (label == 'C') {
            setState(() {
              _userAnswer = '';
            });
          } else if (label == '✓') {
            _submitNumPadAnswer();
          } else {
            if (_userAnswer.length < 6) {
              setState(() {
                _userAnswer += label;
              });
            }
          }
        },
        child: Container(
          height: isSmallScreen ? 52 : 60,
          decoration: BoxDecoration(
            color: isAction
                ? actionColor?.withOpacity(0.1)
                : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAction
                  ? actionColor!.withOpacity(0.3)
                  : (isDark ? AppColors.dividerDark : AppColors.divider),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: isAction
                    ? actionColor
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver(bool isDark, bool isSmallScreen) {
    final accuracy = _correctAnswers + _wrongAnswers > 0
        ? ((_correctAnswers / (_correctAnswers + _wrongAnswers)) * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        children: [
          SizedBox(height: isSmallScreen ? 20 : 40),

          // Game Over Header
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_getModeColor(), _getModeColor().withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _getModeColor().withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  _currentLives > 0
                      ? Icons.timer_off_rounded
                      : Icons.heart_broken_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 48 : 60,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  _currentLives > 0 ? 'Time\'s Up!' : 'Game Over',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 26 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.mode.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

          SizedBox(height: isSmallScreen ? 24 : 32),

          // Score Display
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Final Score',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 48 : 60,
                    fontWeight: FontWeight.bold,
                    color: _getModeColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Stats Grid
          Row(
            children: [
              _buildStatCard(
                icon: Icons.check_circle_rounded,
                value: '$_correctAnswers',
                label: 'Correct',
                color: AppColors.success,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              _buildStatCard(
                icon: Icons.cancel_rounded,
                value: '$_wrongAnswers',
                label: 'Wrong',
                color: AppColors.error,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: isSmallScreen ? 10 : 12),

          Row(
            children: [
              _buildStatCard(
                icon: Icons.percent_rounded,
                value: '$accuracy%',
                label: 'Accuracy',
                color: AppColors.primary,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              _buildStatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${_maxCombo}x',
                label: 'Max Combo',
                color: AppColors.accentYellow,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: isSmallScreen ? 28 : 36),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getModeColor(),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getModeColor() {
    switch (widget.mode) {
      case PracticeMode.squares:
        return const Color(0xFF00B894);
      case PracticeMode.cubes:
        return const Color(0xFFE17055);
      case PracticeMode.mixed:
        return const Color(0xFF6C5CE7);
    }
  }

  String _getQuestionTypeLabel() {
    switch (_currentQuestion!.type) {
      case MathFactType.table:
        return 'Table';
      case MathFactType.square:
        return 'Square';
      case MathFactType.cube:
        return 'Cube';
    }
  }
}
