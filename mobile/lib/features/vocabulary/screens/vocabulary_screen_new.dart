import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/sound_service.dart';

// Vocabulary word model
class VocabWord {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String example;
  final List<String> synonyms;
  final String difficulty;
  final int masteryLevel;
  bool isFavorite;
  bool isLearned;

  VocabWord({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    this.synonyms = const [],
    required this.difficulty,
    this.masteryLevel = 0,
    this.isFavorite = false,
    this.isLearned = false,
  });
}

// Vocabulary categories
class VocabCategory {
  final String name;
  final String emoji;
  final Color color;
  final List<VocabWord> words;

  const VocabCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.words,
  });
}

// Sample vocabulary data
final _vocabCategories = [
  VocabCategory(
    name: 'Essential Verbs',
    emoji: '⚡',
    color: const Color(0xFF6C5CE7),
    words: [
      VocabWord(
        word: 'Accomplish',
        pronunciation: '/əˈkɒmplɪʃ/',
        partOfSpeech: 'verb',
        definition: 'To successfully complete or achieve something',
        example: 'She accomplished all her goals for the year.',
        synonyms: ['achieve', 'complete', 'fulfill'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Demonstrate',
        pronunciation: '/ˈdemənstreɪt/',
        partOfSpeech: 'verb',
        definition: 'To show or prove something clearly',
        example: 'The experiment demonstrates the principle.',
        synonyms: ['show', 'prove', 'illustrate'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Elaborate',
        pronunciation: '/ɪˈlæbəreɪt/',
        partOfSpeech: 'verb',
        definition: 'To explain or describe in more detail',
        example: 'Could you elaborate on your idea?',
        synonyms: ['expand', 'explain', 'develop'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Persevere',
        pronunciation: '/ˌpɜːsɪˈvɪə/',
        partOfSpeech: 'verb',
        definition: 'To continue despite difficulties',
        example: 'She persevered through all challenges.',
        synonyms: ['persist', 'endure', 'continue'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Contemplate',
        pronunciation: '/ˈkɒntəmpleɪt/',
        partOfSpeech: 'verb',
        definition: 'To think about something carefully',
        example: 'He contemplated his next move.',
        synonyms: ['consider', 'ponder', 'reflect'],
        difficulty: 'Advanced',
      ),
    ],
  ),
  VocabCategory(
    name: 'Descriptive Words',
    emoji: '🎨',
    color: const Color(0xFFE17055),
    words: [
      VocabWord(
        word: 'Magnificent',
        pronunciation: '/mæɡˈnɪfɪsənt/',
        partOfSpeech: 'adjective',
        definition: 'Extremely beautiful, impressive, or excellent',
        example: 'The view from the mountain was magnificent.',
        synonyms: ['splendid', 'grand', 'stunning'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Peculiar',
        pronunciation: '/pɪˈkjuːliə/',
        partOfSpeech: 'adjective',
        definition: 'Strange or unusual in an interesting way',
        example: 'She has a peculiar sense of humor.',
        synonyms: ['strange', 'odd', 'unusual'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Serene',
        pronunciation: '/sɪˈriːn/',
        partOfSpeech: 'adjective',
        definition: 'Calm, peaceful, and untroubled',
        example: 'The lake was serene in the morning.',
        synonyms: ['peaceful', 'tranquil', 'calm'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Resilient',
        pronunciation: '/rɪˈzɪliənt/',
        partOfSpeech: 'adjective',
        definition: 'Able to recover quickly from difficulties',
        example: 'Children are often incredibly resilient.',
        synonyms: ['tough', 'adaptable', 'strong'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ubiquitous',
        pronunciation: '/juːˈbɪkwɪtəs/',
        partOfSpeech: 'adjective',
        definition: 'Present or found everywhere',
        example: 'Smartphones have become ubiquitous.',
        synonyms: ['everywhere', 'universal', 'omnipresent'],
        difficulty: 'Advanced',
      ),
    ],
  ),
  VocabCategory(
    name: 'Academic Words',
    emoji: '📚',
    color: const Color(0xFF2E86AB),
    words: [
      VocabWord(
        word: 'Hypothesis',
        pronunciation: '/haɪˈpɒθəsɪs/',
        partOfSpeech: 'noun',
        definition: 'A proposed explanation for something',
        example: 'The scientist tested her hypothesis.',
        synonyms: ['theory', 'assumption', 'premise'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Paradigm',
        pronunciation: '/ˈpærədaɪm/',
        partOfSpeech: 'noun',
        definition: 'A typical example or pattern of something',
        example: 'This represents a paradigm shift in thinking.',
        synonyms: ['model', 'pattern', 'example'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Synthesis',
        pronunciation: '/ˈsɪnθəsɪs/',
        partOfSpeech: 'noun',
        definition: 'Combination of parts to form a whole',
        example: 'The paper provides a synthesis of research.',
        synonyms: ['combination', 'blend', 'fusion'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Empirical',
        pronunciation: '/ɪmˈpɪrɪkəl/',
        partOfSpeech: 'adjective',
        definition: 'Based on observation or experience',
        example: 'We need empirical evidence to support this.',
        synonyms: ['observed', 'experimental', 'practical'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Methodology',
        pronunciation: '/ˌmeθəˈdɒlədʒi/',
        partOfSpeech: 'noun',
        definition: 'A system of methods used in a field',
        example: 'The research methodology was rigorous.',
        synonyms: ['method', 'approach', 'system'],
        difficulty: 'Advanced',
      ),
    ],
  ),
  VocabCategory(
    name: 'Business Vocabulary',
    emoji: '💼',
    color: const Color(0xFF00B894),
    words: [
      VocabWord(
        word: 'Leverage',
        pronunciation: '/ˈlevərɪdʒ/',
        partOfSpeech: 'verb',
        definition: 'To use something to maximum advantage',
        example: 'We can leverage our connections.',
        synonyms: ['utilize', 'exploit', 'capitalize'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Synergy',
        pronunciation: '/ˈsɪnədʒi/',
        partOfSpeech: 'noun',
        definition: 'Combined effect greater than separate parts',
        example: 'The merger created real synergy.',
        synonyms: ['cooperation', 'collaboration', 'teamwork'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Scalable',
        pronunciation: '/ˈskeɪləbəl/',
        partOfSpeech: 'adjective',
        definition: 'Able to grow or be made larger',
        example: 'Is this business model scalable?',
        synonyms: ['expandable', 'flexible', 'adaptable'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Stakeholder',
        pronunciation: '/ˈsteɪkhəʊldə/',
        partOfSpeech: 'noun',
        definition: 'Someone with an interest in something',
        example: 'All stakeholders were consulted.',
        synonyms: ['investor', 'participant', 'shareholder'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Streamline',
        pronunciation: '/ˈstriːmlaɪn/',
        partOfSpeech: 'verb',
        definition: 'To make more efficient',
        example: 'We need to streamline our processes.',
        synonyms: ['simplify', 'optimize', 'improve'],
        difficulty: 'Intermediate',
      ),
    ],
  ),
  VocabCategory(
    name: 'Emotional Expressions',
    emoji: '💭',
    color: const Color(0xFFFF6B6B),
    words: [
      VocabWord(
        word: 'Ecstatic',
        pronunciation: '/ɪkˈstætɪk/',
        partOfSpeech: 'adjective',
        definition: 'Extremely happy or excited',
        example: 'She was ecstatic about the news.',
        synonyms: ['overjoyed', 'thrilled', 'elated'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Apprehensive',
        pronunciation: '/ˌæprɪˈhensɪv/',
        partOfSpeech: 'adjective',
        definition: 'Anxious or fearful about the future',
        example: 'I feel apprehensive about the interview.',
        synonyms: ['worried', 'anxious', 'nervous'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Melancholy',
        pronunciation: '/ˈmelənkɒli/',
        partOfSpeech: 'adjective',
        definition: 'A deep sadness or depression',
        example: 'The song has a melancholy tone.',
        synonyms: ['sad', 'sorrowful', 'gloomy'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Exhilarated',
        pronunciation: '/ɪɡˈzɪləreɪtɪd/',
        partOfSpeech: 'adjective',
        definition: 'Feeling very happy and excited',
        example: 'I felt exhilarated after the race.',
        synonyms: ['thrilled', 'elated', 'euphoric'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Nostalgic',
        pronunciation: '/nɒˈstældʒɪk/',
        partOfSpeech: 'adjective',
        definition: 'Longing for the past',
        example: 'Old photos make me nostalgic.',
        synonyms: ['wistful', 'sentimental', 'longing'],
        difficulty: 'Intermediate',
      ),
    ],
  ),
];

// Game modes
enum VocabGameMode { flashcard, quiz, matching, spelling }

class VocabularyScreenNew extends ConsumerStatefulWidget {
  const VocabularyScreenNew({super.key});

  @override
  ConsumerState<VocabularyScreenNew> createState() =>
      _VocabularyScreenNewState();
}

class _VocabularyScreenNewState extends ConsumerState<VocabularyScreenNew>
    with TickerProviderStateMixin {
  VocabCategory? _selectedCategory;
  VocabGameMode _gameMode = VocabGameMode.flashcard;
  int _currentWordIndex = 0;
  bool _showDefinition = false;

  // Gamification
  int _xpEarned = 0;
  int _wordsLearned = 0;
  int _correctAnswers = 0;
  int _streak = 0;
  int _bestStreak = 0;

  // Quiz mode
  List<String> _quizOptions = [];
  String? _selectedAnswer;
  bool? _isCorrect;

  // Matching mode
  List<VocabWord> _matchingWords = [];
  List<String> _matchingDefinitions = [];
  int? _selectedWordIndex;
  int? _selectedDefIndex;
  List<int> _matchedWords = [];
  List<int> _matchedDefs = [];

  // Spelling mode
  final TextEditingController _spellingController = TextEditingController();
  bool _spellingChecked = false;
  bool _spellingCorrect = false;

  late AnimationController _cardController;
  late AnimationController _streakController;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _streakController.dispose();
    _spellingController.dispose();
    super.dispose();
  }

  void _selectCategory(VocabCategory category) {
    setState(() {
      _selectedCategory = category;
      _currentWordIndex = 0;
      _showDefinition = false;
      _xpEarned = 0;
      _wordsLearned = 0;
      _streak = 0;
      _bestStreak = 0;
    });
    _setupGameMode();
  }

  void _selectGameMode(VocabGameMode mode) {
    setState(() {
      _gameMode = mode;
      _currentWordIndex = 0;
      _correctAnswers = 0;
    });
    _setupGameMode();
  }

  void _setupGameMode() {
    switch (_gameMode) {
      case VocabGameMode.quiz:
        _generateQuizOptions();
        break;
      case VocabGameMode.matching:
        _setupMatchingGame();
        break;
      case VocabGameMode.spelling:
        _spellingController.clear();
        _spellingChecked = false;
        break;
      default:
        break;
    }
  }

  void _generateQuizOptions() {
    final currentWord = _selectedCategory!.words[_currentWordIndex];
    final allDefinitions = _selectedCategory!.words
        .map((w) => w.definition)
        .toList();
    allDefinitions.shuffle();

    _quizOptions = allDefinitions.take(4).toList();
    if (!_quizOptions.contains(currentWord.definition)) {
      _quizOptions[Random().nextInt(4)] = currentWord.definition;
    }
    _selectedAnswer = null;
    _isCorrect = null;
  }

  void _setupMatchingGame() {
    _matchingWords = List.from(_selectedCategory!.words)..shuffle();
    _matchingWords = _matchingWords.take(5).toList();
    _matchingDefinitions = _matchingWords.map((w) => w.definition).toList()
      ..shuffle();
    _selectedWordIndex = null;
    _selectedDefIndex = null;
    _matchedWords = [];
    _matchedDefs = [];
  }

  void _handleFlashcardGotIt() {
    setState(() {
      _wordsLearned++;
      _streak++;
      _bestStreak = max(_streak, _bestStreak);
      _xpEarned += 10 + (_streak * 2);
      _showDefinition = false;
    });
    _streakController.forward(from: 0);
    _nextWord();
  }

  void _handleFlashcardStudyAgain() {
    setState(() {
      _streak = 0;
      _showDefinition = false;
    });
    _nextWord();
  }

  void _handleQuizAnswer(String answer) {
    final currentWord = _selectedCategory!.words[_currentWordIndex];
    final correct = answer == currentWord.definition;

    setState(() {
      _selectedAnswer = answer;
      _isCorrect = correct;
      if (correct) {
        _correctAnswers++;
        _streak++;
        _bestStreak = max(_streak, _bestStreak);
        _xpEarned += 15 + (_streak * 3);
        _wordsLearned++;
      } else {
        _streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _nextWord();
    });
  }

  void _handleMatchSelection(bool isWord, int index) {
    if (isWord && _matchedWords.contains(index)) return;
    if (!isWord && _matchedDefs.contains(index)) return;

    setState(() {
      if (isWord) {
        _selectedWordIndex = index;
      } else {
        _selectedDefIndex = index;
      }
    });

    // Check for match
    if (_selectedWordIndex != null && _selectedDefIndex != null) {
      final word = _matchingWords[_selectedWordIndex!];
      final def = _matchingDefinitions[_selectedDefIndex!];

      if (word.definition == def) {
        // Match!
        setState(() {
          _matchedWords.add(_selectedWordIndex!);
          _matchedDefs.add(_selectedDefIndex!);
          _correctAnswers++;
          _streak++;
          _bestStreak = max(_streak, _bestStreak);
          _xpEarned += 20 + (_streak * 5);
          _wordsLearned++;
        });
        _streakController.forward(from: 0);
      } else {
        _streak = 0;
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _selectedWordIndex = null;
            _selectedDefIndex = null;
          });
        }
      });

      // Check completion
      if (_matchedWords.length == _matchingWords.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCompletionDialog();
        });
      }
    }
  }

  void _checkSpelling() {
    final currentWord = _selectedCategory!.words[_currentWordIndex];
    final userInput = _spellingController.text.trim().toLowerCase();
    final correct = userInput == currentWord.word.toLowerCase();

    setState(() {
      _spellingChecked = true;
      _spellingCorrect = correct;
      if (correct) {
        _correctAnswers++;
        _streak++;
        _bestStreak = max(_streak, _bestStreak);
        _xpEarned += 25 + (_streak * 5);
        _wordsLearned++;
      } else {
        _streak = 0;
      }
    });

    if (correct) _streakController.forward(from: 0);
  }

  void _nextSpellingWord() {
    setState(() {
      _spellingController.clear();
      _spellingChecked = false;
      _spellingCorrect = false;
    });
    _nextWord();
  }

  void _nextWord() {
    if (_currentWordIndex < _selectedCategory!.words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _showDefinition = false;
      });
      _cardController.forward(from: 0);
      _setupGameMode();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final totalWords = _gameMode == VocabGameMode.matching
        ? _matchingWords.length
        : _selectedCategory!.words.length;
    final accuracy = totalWords > 0
        ? (_wordsLearned / totalWords * 100).round()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _selectedCategory!.color,
                        _selectedCategory!.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _selectedCategory!.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  accuracy >= 80
                      ? 'Outstanding! 🌟'
                      : accuracy >= 60
                      ? 'Great Work! 🎉'
                      : 'Keep Learning! 💪',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory!.name,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompletionStat(
                      icon: Icons.check_circle_outline_rounded,
                      value: '$_wordsLearned',
                      label: 'Learned',
                      color: AppColors.success,
                    ),
                    _CompletionStat(
                      icon: Icons.local_fire_department_rounded,
                      value: '$_bestStreak',
                      label: 'Best Streak',
                      color: AppColors.error,
                    ),
                    _CompletionStat(
                      icon: Icons.percent_rounded,
                      value: '$accuracy%',
                      label: 'Accuracy',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.accentYellow,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '+$_xpEarned XP',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Categories'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
          onPressed: () {
            if (_selectedCategory != null) {
              setState(() => _selectedCategory = null);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _selectedCategory?.name ?? 'Vocabulary Builder',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedCategory != null) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentYellow,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$_xpEarned',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: _selectedCategory == null
            ? _buildCategorySelection(isDark)
            : _buildGameView(isDark),
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
                'Build Your Vocabulary 📖',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a category to start learning',
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
            itemCount: _vocabCategories.length,
            itemBuilder: (context, index) {
              final category = _vocabCategories[index];
              return _VocabCategoryCard(
                    category: category,
                    onTap: () => _selectCategory(category),
                  )
                  .animate(delay: Duration(milliseconds: 80 * index))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameView(bool isDark) {
    return Column(
      children: [
        // Game mode selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: VocabGameMode.values.map((mode) {
                final isSelected = _gameMode == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_getModeName(mode)),
                    selected: isSelected,
                    onSelected: (_) => _selectGameMode(mode),
                    selectedColor: _selectedCategory!.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    avatar: Icon(
                      _getModeIcon(mode),
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : _selectedCategory!.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Progress
        if (_gameMode != VocabGameMode.matching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_currentWordIndex + 1}/${_selectedCategory!.words.length}',
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
                      value:
                          (_currentWordIndex + 1) /
                          _selectedCategory!.words.length,
                      backgroundColor: isDark
                          ? AppColors.dividerDark
                          : AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        _selectedCategory!.color,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Game content
        Expanded(child: _buildGameContent(isDark)),
      ],
    );
  }

  Widget _buildGameContent(bool isDark) {
    switch (_gameMode) {
      case VocabGameMode.flashcard:
        return _buildFlashcardMode(isDark);
      case VocabGameMode.quiz:
        return _buildQuizMode(isDark);
      case VocabGameMode.matching:
        return _buildMatchingMode(isDark);
      case VocabGameMode.spelling:
        return _buildSpellingMode(isDark);
    }
  }

  Widget _buildFlashcardMode(bool isDark) {
    final currentWord = _selectedCategory!.words[_currentWordIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showDefinition = !_showDefinition),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedCategory!.color.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const Spacer(),

                    // Word
                    Text(
                      currentWord.word,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Pronunciation
                    Text(
                      currentWord.pronunciation,
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedCategory!.color,
                        fontFamily: 'monospace',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Part of speech
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedCategory!.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentWord.partOfSpeech,
                        style: TextStyle(
                          color: _selectedCategory!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Definition (revealed)
                    AnimatedCrossFade(
                      firstChild: Column(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.textHint,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to reveal definition',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      secondChild: Column(
                        children: [
                          Text(
                            currentWord.definition,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '"${currentWord.example}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: currentWord.synonyms
                                .map(
                                  (s) => Chip(
                                    label: Text(
                                      s,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _selectedCategory!.color
                                        .withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: _selectedCategory!.color,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      crossFadeState: _showDefinition
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          const SizedBox(height: 20),

          // Buttons
          if (_showDefinition)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleFlashcardStudyAgain,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Study Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleFlashcardGotIt,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Got It!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory!.color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildQuizMode(bool isDark) {
    final currentWord = _selectedCategory!.words[_currentWordIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Word to guess
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _selectedCategory!.color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'What does this word mean?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentWord.word,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _selectedCategory!.color,
                  ),
                ),
                Text(
                  currentWord.pronunciation,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: _quizOptions.length,
              itemBuilder: (context, index) {
                final option = _quizOptions[index];
                final isSelected = _selectedAnswer == option;
                final isCorrectAnswer = option == currentWord.definition;

                Color? backgroundColor;
                Color? borderColor;

                if (_selectedAnswer != null) {
                  if (isCorrectAnswer) {
                    backgroundColor = AppColors.success.withOpacity(0.15);
                    borderColor = AppColors.success;
                  } else if (isSelected && !_isCorrect!) {
                    backgroundColor = AppColors.error.withOpacity(0.15);
                    borderColor = AppColors.error;
                  }
                }

                return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _selectedAnswer == null
                            ? () => _handleQuizAnswer(option)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                backgroundColor ??
                                (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  borderColor ??
                                  (isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _selectedCategory!.color.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedCategory!.color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_selectedAnswer != null && isCorrectAnswer)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                ),
                              if (isSelected && !(_isCorrect ?? true))
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.error,
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 100 * index))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingMode(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match words with their definitions',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '${_matchedWords.length}/${_matchingWords.length} matched',
            style: TextStyle(
              color: _selectedCategory!.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Words column
                Expanded(
                  child: ListView.builder(
                    itemCount: _matchingWords.length,
                    itemBuilder: (context, index) {
                      final word = _matchingWords[index];
                      final isMatched = _matchedWords.contains(index);
                      final isSelected = _selectedWordIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: isMatched
                              ? null
                              : () => _handleMatchSelection(true, index),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? AppColors.success.withOpacity(0.15)
                                  : (isSelected
                                        ? _selectedCategory!.color.withOpacity(
                                            0.15,
                                          )
                                        : (isDark
                                              ? AppColors.cardDark
                                              : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? AppColors.success
                                    : (isSelected
                                          ? _selectedCategory!.color
                                          : Colors.transparent),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              word.word,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMatched
                                    ? AppColors.success
                                    : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Definitions column
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _matchingDefinitions.length,
                    itemBuilder: (context, index) {
                      final def = _matchingDefinitions[index];
                      final isMatched = _matchedDefs.contains(index);
                      final isSelected = _selectedDefIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: isMatched
                              ? null
                              : () => _handleMatchSelection(false, index),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? AppColors.success.withOpacity(0.15)
                                  : (isSelected
                                        ? _selectedCategory!.color.withOpacity(
                                            0.15,
                                          )
                                        : (isDark
                                              ? AppColors.cardDark
                                              : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? AppColors.success
                                    : (isSelected
                                          ? _selectedCategory!.color
                                          : Colors.transparent),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              def,
                              style: TextStyle(
                                fontSize: 13,
                                color: isMatched
                                    ? AppColors.success
                                    : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellingMode(bool isDark) {
    final currentWord = _selectedCategory!.words[_currentWordIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Definition card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _selectedCategory!.color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: _selectedCategory!.color,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Spell the word that means:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentWord.definition,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hint: ${currentWord.partOfSpeech} • ${currentWord.word.length} letters',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),

          // Text input
          TextField(
            controller: _spellingController,
            enabled: !_spellingChecked,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: _spellingChecked
                  ? (_spellingCorrect ? AppColors.success : AppColors.error)
                  : null,
            ),
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: 20,
                letterSpacing: 0,
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedCategory!.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedCategory!.color,
                  width: 2,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _checkSpelling(),
          ),

          const SizedBox(height: 24),

          // Result
          if (_spellingChecked)
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _spellingCorrect
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _spellingCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _spellingCorrect
                            ? AppColors.success
                            : AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _spellingCorrect ? 'Correct!' : 'The answer is:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _spellingCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      if (!_spellingCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          currentWord.word,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9)),

          const Spacer(),

          // Buttons
          if (!_spellingChecked)
            ElevatedButton(
              onPressed: _checkSpelling,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory!.color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Check'),
            )
          else
            ElevatedButton(
              onPressed: _nextSpellingWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory!.color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Next Word'),
            ),
        ],
      ),
    );
  }

  String _getModeName(VocabGameMode mode) {
    switch (mode) {
      case VocabGameMode.flashcard:
        return 'Flashcards';
      case VocabGameMode.quiz:
        return 'Quiz';
      case VocabGameMode.matching:
        return 'Matching';
      case VocabGameMode.spelling:
        return 'Spelling';
    }
  }

  IconData _getModeIcon(VocabGameMode mode) {
    switch (mode) {
      case VocabGameMode.flashcard:
        return Icons.style_rounded;
      case VocabGameMode.quiz:
        return Icons.quiz_rounded;
      case VocabGameMode.matching:
        return Icons.compare_arrows_rounded;
      case VocabGameMode.spelling:
        return Icons.edit_rounded;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.success;
      case 'Intermediate':
        return AppColors.accentYellow;
      case 'Advanced':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

class _VocabCategoryCard extends StatelessWidget {
  final VocabCategory category;
  final VoidCallback onTap;

  const _VocabCategoryCard({required this.category, required this.onTap});

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
              color: category.color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.words.length} words to learn',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.3, // Placeholder
                      backgroundColor: category.color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(category.color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: category.color,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _CompletionStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
