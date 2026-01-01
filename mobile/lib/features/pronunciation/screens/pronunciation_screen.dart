import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/audio_service.dart';
// Sound service removed - not currently used
import '../../practice/widgets/dynamic_waveform.dart';

// Word data with phonetic pronunciation
class PronunciationWord {
  final String word;
  final String phonetic;
  final String difficulty;
  final String audioTip;
  final List<String> syllables;
  final String exampleSentence;
  final String category;

  const PronunciationWord({
    required this.word,
    required this.phonetic,
    required this.difficulty,
    required this.audioTip,
    required this.syllables,
    required this.exampleSentence,
    required this.category,
  });
}

// Pronunciation data
final _pronunciationCategories = {
  'Tricky Sounds': [
    const PronunciationWord(
      word: 'Through',
      phonetic: '/θruː/',
      difficulty: 'Hard',
      audioTip: 'Put your tongue between your teeth for "th" sound',
      syllables: ['Through'],
      exampleSentence: 'We walked through the park.',
      category: 'Tricky Sounds',
    ),
    const PronunciationWord(
      word: 'Clothes',
      phonetic: '/kloʊðz/',
      difficulty: 'Medium',
      audioTip: 'The "th" is voiced - feel your throat vibrate',
      syllables: ['Clothes'],
      exampleSentence: 'She bought new clothes for the trip.',
      category: 'Tricky Sounds',
    ),
    const PronunciationWord(
      word: 'Thought',
      phonetic: '/θɔːt/',
      difficulty: 'Hard',
      audioTip: 'Silent "gh" - focus on the "th" at the start',
      syllables: ['Thought'],
      exampleSentence: 'I thought about it carefully.',
      category: 'Tricky Sounds',
    ),
    const PronunciationWord(
      word: 'Comfortable',
      phonetic: '/ˈkʌmftəbəl/',
      difficulty: 'Hard',
      audioTip: 'Only 3 syllables! Say "CUMF-ter-bul"',
      syllables: ['Comf', 'ta', 'ble'],
      exampleSentence: 'This chair is very comfortable.',
      category: 'Tricky Sounds',
    ),
    const PronunciationWord(
      word: 'Schedule',
      phonetic: '/ˈskedʒuːl/',
      difficulty: 'Medium',
      audioTip: 'American: SKED-jool, British: SHED-yool',
      syllables: ['Sched', 'ule'],
      exampleSentence: 'Check your schedule for tomorrow.',
      category: 'Tricky Sounds',
    ),
  ],
  'Silent Letters': [
    const PronunciationWord(
      word: 'Knight',
      phonetic: '/naɪt/',
      difficulty: 'Easy',
      audioTip: 'Silent "k" and "gh" - sounds like "night"',
      syllables: ['Knight'],
      exampleSentence: 'The knight saved the princess.',
      category: 'Silent Letters',
    ),
    const PronunciationWord(
      word: 'Wednesday',
      phonetic: '/ˈwenzdeɪ/',
      difficulty: 'Medium',
      audioTip: 'Skip the first "d" - say "WENZ-day"',
      syllables: ['Wednes', 'day'],
      exampleSentence: 'See you on Wednesday!',
      category: 'Silent Letters',
    ),
    const PronunciationWord(
      word: 'Receipt',
      phonetic: '/rɪˈsiːt/',
      difficulty: 'Medium',
      audioTip: 'Silent "p" - rhymes with "deceit"',
      syllables: ['Re', 'ceipt'],
      exampleSentence: 'Keep the receipt for returns.',
      category: 'Silent Letters',
    ),
    const PronunciationWord(
      word: 'Subtle',
      phonetic: '/ˈsʌtəl/',
      difficulty: 'Medium',
      audioTip: 'Silent "b" - say "SUT-ul"',
      syllables: ['Sub', 'tle'],
      exampleSentence: 'There was a subtle difference.',
      category: 'Silent Letters',
    ),
    const PronunciationWord(
      word: 'Debris',
      phonetic: '/dəˈbriː/',
      difficulty: 'Hard',
      audioTip: 'Silent "s" - French origin, say "duh-BREE"',
      syllables: ['De', 'bris'],
      exampleSentence: 'Clear the debris from the road.',
      category: 'Silent Letters',
    ),
  ],
  'Common Mistakes': [
    const PronunciationWord(
      word: 'February',
      phonetic: '/ˈfebruəri/',
      difficulty: 'Hard',
      audioTip: 'Don\'t skip the first "r" - FEB-roo-air-ee',
      syllables: ['Feb', 'ru', 'ar', 'y'],
      exampleSentence: 'My birthday is in February.',
      category: 'Common Mistakes',
    ),
    const PronunciationWord(
      word: 'Library',
      phonetic: '/ˈlaɪbrəri/',
      difficulty: 'Medium',
      audioTip: 'Two "r" sounds - LIE-brar-ee, not LIE-berry',
      syllables: ['Li', 'brar', 'y'],
      exampleSentence: 'I\'m going to the library.',
      category: 'Common Mistakes',
    ),
    const PronunciationWord(
      word: 'Pronunciation',
      phonetic: '/prəˌnʌnsiˈeɪʃən/',
      difficulty: 'Hard',
      audioTip: 'It\'s "nun" not "noun" in the middle!',
      syllables: ['Pro', 'nun', 'ci', 'a', 'tion'],
      exampleSentence: 'Work on your pronunciation.',
      category: 'Common Mistakes',
    ),
    const PronunciationWord(
      word: 'Espresso',
      phonetic: '/eˈspresəʊ/',
      difficulty: 'Easy',
      audioTip: 'No "x" - it\'s "es" not "ex"',
      syllables: ['Es', 'pres', 'so'],
      exampleSentence: 'I\'ll have an espresso, please.',
      category: 'Common Mistakes',
    ),
    const PronunciationWord(
      word: 'Asterisk',
      phonetic: '/ˈæstərɪsk/',
      difficulty: 'Medium',
      audioTip: 'Ends in "isk" not "ix" - AS-ter-isk',
      syllables: ['As', 'ter', 'isk'],
      exampleSentence: 'Put an asterisk next to that.',
      category: 'Common Mistakes',
    ),
  ],
  'Business English': [
    const PronunciationWord(
      word: 'Entrepreneur',
      phonetic: '/ˌɒntrəprəˈnɜː/',
      difficulty: 'Hard',
      audioTip: 'ON-truh-pruh-NUR - stress on last syllable',
      syllables: ['En', 'tre', 'pre', 'neur'],
      exampleSentence: 'She\'s a successful entrepreneur.',
      category: 'Business English',
    ),
    const PronunciationWord(
      word: 'Hierarchy',
      phonetic: '/ˈhaɪərɑːki/',
      difficulty: 'Medium',
      audioTip: 'HIGH-uh-rar-kee - four syllables',
      syllables: ['Hi', 'er', 'ar', 'chy'],
      exampleSentence: 'The company has a strict hierarchy.',
      category: 'Business English',
    ),
    const PronunciationWord(
      word: 'Colleague',
      phonetic: '/ˈkɒliːɡ/',
      difficulty: 'Easy',
      audioTip: 'COL-eeg - silent "u"',
      syllables: ['Col', 'league'],
      exampleSentence: 'My colleague helped with the project.',
      category: 'Business English',
    ),
    const PronunciationWord(
      word: 'Revenue',
      phonetic: '/ˈrevənjuː/',
      difficulty: 'Medium',
      audioTip: 'REV-uh-new - not "re-VEN-ue"',
      syllables: ['Rev', 'e', 'nue'],
      exampleSentence: 'The company increased its revenue.',
      category: 'Business English',
    ),
    const PronunciationWord(
      word: 'Negotiate',
      phonetic: '/nɪˈɡəʊʃieɪt/',
      difficulty: 'Medium',
      audioTip: 'nuh-GO-she-ate - stress on second syllable',
      syllables: ['Ne', 'go', 'ti', 'ate'],
      exampleSentence: 'Let\'s negotiate the terms.',
      category: 'Business English',
    ),
  ],
  'Travel Words': [
    const PronunciationWord(
      word: 'Itinerary',
      phonetic: '/aɪˈtɪnərəri/',
      difficulty: 'Hard',
      audioTip: 'eye-TIN-er-air-ee - five syllables',
      syllables: ['I', 'tin', 'er', 'ar', 'y'],
      exampleSentence: 'Check your travel itinerary.',
      category: 'Travel Words',
    ),
    const PronunciationWord(
      word: 'Reservoir',
      phonetic: '/ˈrezəvwɑː/',
      difficulty: 'Medium',
      audioTip: 'REZ-er-vwar - French ending',
      syllables: ['Res', 'er', 'voir'],
      exampleSentence: 'We visited the reservoir.',
      category: 'Travel Words',
    ),
    const PronunciationWord(
      word: 'Aisle',
      phonetic: '/aɪl/',
      difficulty: 'Easy',
      audioTip: 'Sounds like "I\'ll" - silent "s"',
      syllables: ['Aisle'],
      exampleSentence: 'Would you like an aisle seat?',
      category: 'Travel Words',
    ),
    const PronunciationWord(
      word: 'Quay',
      phonetic: '/kiː/',
      difficulty: 'Hard',
      audioTip: 'Sounds like "key" - not "kway"!',
      syllables: ['Quay'],
      exampleSentence: 'The boat docked at the quay.',
      category: 'Travel Words',
    ),
    const PronunciationWord(
      word: 'Queue',
      phonetic: '/kjuː/',
      difficulty: 'Easy',
      audioTip: 'Sounds like the letter "Q"',
      syllables: ['Queue'],
      exampleSentence: 'There\'s a long queue at customs.',
      category: 'Travel Words',
    ),
  ],
};

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen>
    with TickerProviderStateMixin {
  String? _selectedCategory;
  int _currentWordIndex = 0;
  List<PronunciationWord> _currentWords = [];
  bool _isRecording = false;
  bool _showFeedback = false;
  int _recordingSeconds = 0;
  Timer? _timer;
  final AudioService _audioService = AudioService();

  // Gamification
  int _totalXp = 0;
  int _wordsCompleted = 0;
  int _streak = 0;
  int _bestStreak = 0;
  List<bool> _results = [];

  late AnimationController _scoreAnimController;
  late AnimationController _pulseController;
  late AnimationController _syllableController;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _syllableController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _checkPermissions();
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    _pulseController.dispose();
    _syllableController.dispose();
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    await _audioService.requestPermission();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _currentWords = List.from(_pronunciationCategories[category]!);
      _currentWords.shuffle(Random());
      _currentWordIndex = 0;
      _results = [];
      _wordsCompleted = 0;
    });
    _syllableController.forward(from: 0);
  }

  void _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _showFeedback = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _recordingSeconds++);
          if (_recordingSeconds >= 10) _stopRecording();
        }
      });
    } catch (e) {
      _showSnackBar('Failed to start recording: $e');
    }
  }

  void _stopRecording() async {
    _timer?.cancel();

    try {
      await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _showFeedback = true;
      });
    } catch (e) {
      setState(() => _isRecording = false);
      _showSnackBar('Error: $e');
    }
  }

  void _submitResult(bool correct) {
    setState(() {
      _results.add(correct);
      _wordsCompleted++;

      if (correct) {
        _streak++;
        _bestStreak = max(_streak, _bestStreak);
        _totalXp += 15 + (_streak * 5); // Bonus XP for streaks
      } else {
        _streak = 0;
      }

      _showFeedback = false;
    });

    _scoreAnimController.forward(from: 0);

    // Move to next word or show completion
    if (_currentWordIndex < _currentWords.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _currentWordIndex++);
          _syllableController.forward(from: 0);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCompletionDialog();
      });
    }
  }

  void _skipWord() {
    setState(() {
      _results.add(false);
      _streak = 0;
      _showFeedback = false;
    });

    if (_currentWordIndex < _currentWords.length - 1) {
      setState(() => _currentWordIndex++);
      _syllableController.forward(from: 0);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final correctCount = _results.where((r) => r).length;
    final accuracy = _results.isEmpty
        ? 0
        : (correctCount / _results.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.cardDark
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                accuracy >= 80
                    ? 'Excellent! 🎉'
                    : accuracy >= 60
                    ? 'Good Job! 👍'
                    : 'Keep Practicing! 💪',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_selectedCategory Complete',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompletionStat(
                    icon: Icons.check_circle_outline_rounded,
                    value: '$correctCount/${_results.length}',
                    label: 'Correct',
                    color: AppColors.success,
                  ),
                  _buildCompletionStat(
                    icon: Icons.percent_rounded,
                    value: '$accuracy%',
                    label: 'Accuracy',
                    color: AppColors.primary,
                  ),
                  _buildCompletionStat(
                    icon: Icons.local_fire_department_rounded,
                    value: '$_bestStreak',
                    label: 'Best Streak',
                    color: AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.accentYellow,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+$_totalXp XP',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentYellow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedCategory = null;
                          _totalXp = 0;
                          _bestStreak = 0;
                        });
                      },
                      child: const Text('Categories'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectCategory(_selectedCategory!);
                        setState(() {
                          _totalXp = 0;
                          _bestStreak = 0;
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _selectedCategory ?? 'Pronunciation Practice',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedCategory != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _selectedCategory == null
            ? _buildCategorySelection(isDark)
            : _buildPracticeView(isDark),
      ),
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Master Pronunciation 🎯',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Focus on sounds that trip up most learners',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _pronunciationCategories.keys.length,
            itemBuilder: (context, index) {
              final category = _pronunciationCategories.keys.elementAt(index);
              final words = _pronunciationCategories[category]!;
              final icon = _getCategoryIcon(category);
              final color = _getCategoryColor(index);

              return _CategoryCard(
                    title: category,
                    wordCount: words.length,
                    icon: icon,
                    color: color,
                    onTap: () => _selectCategory(category),
                  )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tricky Sounds':
        return Icons.waves_rounded;
      case 'Silent Letters':
        return Icons.visibility_off_rounded;
      case 'Common Mistakes':
        return Icons.warning_amber_rounded;
      case 'Business English':
        return Icons.business_center_rounded;
      case 'Travel Words':
        return Icons.flight_rounded;
      default:
        return Icons.record_voice_over_rounded;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFF00CEC9),
      const Color(0xFFE17055),
      const Color(0xFF2E86AB),
      const Color(0xFF00B894),
    ];
    return colors[index % colors.length];
  }

  Widget _buildPracticeView(bool isDark) {
    final currentWord = _currentWords[_currentWordIndex];

    return Column(
      children: [
        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '${_currentWordIndex + 1}/${_currentWords.length}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentWordIndex + 1) / _currentWords.length,
                    backgroundColor: isDark
                        ? AppColors.dividerDark
                        : AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.accentYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalXp',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Word Card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Main word card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            currentWord.difficulty,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentWord.difficulty,
                          style: TextStyle(
                            color: _getDifficultyColor(currentWord.difficulty),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // The word
                      Text(
                        currentWord.word,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Phonetic
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentWord.phonetic,
                          style: TextStyle(
                            fontSize: 22,
                            color: AppColors.primary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Syllables
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: currentWord.syllables.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final syllable = entry.value;
                          return AnimatedBuilder(
                            animation: _syllableController,
                            builder: (context, child) {
                              final delay =
                                  index / currentWord.syllables.length;
                              final value =
                                  (_syllableController.value - delay).clamp(
                                    0.0,
                                    1.0,
                                  ) *
                                  2;
                              final scale = value > 1 ? 2 - value : value;

                              return Transform.scale(
                                scale: 0.8 + (0.2 * scale),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scale > 0.5
                                        ? AppColors.primary.withOpacity(0.2)
                                        : (isDark
                                              ? AppColors.surfaceDark
                                              : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: scale > 0.5
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    syllable,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: scale > 0.5
                                          ? AppColors.primary
                                          : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Audio tip
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppColors.info,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentWord.audioTip,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

                const SizedBox(height: 16),

                // Example sentence
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${currentWord.exampleSentence}"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Feedback area
                if (_showFeedback)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'How did you do?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _FeedbackButton(
                                icon: Icons.replay_rounded,
                                label: 'Try Again',
                                color: AppColors.textSecondary,
                                onTap: () {
                                  setState(() => _showFeedback = false);
                                  _syllableController.forward(from: 0);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _FeedbackButton(
                                icon: Icons.close_rounded,
                                label: 'Needs Work',
                                color: AppColors.error,
                                onTap: () => _submitResult(false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _FeedbackButton(
                                icon: Icons.check_rounded,
                                label: 'Got It!',
                                color: AppColors.success,
                                onTap: () => _submitResult(true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),

        // Bottom controls
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip button
              TextButton(onPressed: _skipWord, child: const Text('Skip')),
              const SizedBox(width: 24),

              // Record button
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : AppColors.primary,
                        boxShadow: _isRecording
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(
                                    0.3 + 0.2 * _pulseController.value,
                                  ),
                                  blurRadius: 20 + 10 * _pulseController.value,
                                  spreadRadius: 5 * _pulseController.value,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          if (_isRecording)
                            Text(
                              '${_recordingSeconds}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 24),

              // Replay syllables
              TextButton.icon(
                onPressed: () => _syllableController.forward(from: 0),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Replay'),
              ),
            ],
          ),
        ),

        // Waveform when recording
        if (_isRecording)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DynamicWaveformVisualizer(
              amplitudeStream: _audioService.amplitudeStream,
              isRecording: true,
            ),
          ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.success;
      case 'Medium':
        return AppColors.accentYellow;
      case 'Hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final int wordCount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.wordCount,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$wordCount words to practice',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, color: color, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
