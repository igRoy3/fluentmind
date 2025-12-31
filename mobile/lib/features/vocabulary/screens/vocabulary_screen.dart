import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabState = ref.watch(vocabularyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Vocabulary',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_outline,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            onPressed: () {
              // Show saved words
            },
          ),
        ],
      ),
      body: vocabState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Progress Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Today's Words",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${vocabState.todayWords.length} words',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${vocabState.reviewCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Reviewed',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  ),

                  // Word Card
                  Expanded(
                    child: vocabState.currentWord == null
                        ? const Center(child: Text('No words for today!'))
                        : PageView.builder(
                            itemCount: vocabState.todayWords.length,
                            itemBuilder: (context, index) {
                              final word = vocabState.todayWords[index];
                              return _WordCard(
                                word: word,
                                onMarkLearned: () {
                                  ref
                                      .read(vocabularyProvider.notifier)
                                      .markAsLearned(word.id);
                                },
                                onToggleFavorite: () {
                                  ref
                                      .read(vocabularyProvider.notifier)
                                      .toggleFavorite(word.id);
                                },
                              );
                            },
                          ),
                  ),

                  // Navigation Dots
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(vocabState.todayWords.length, (
                        index,
                      ) {
                        final isActive =
                            vocabState.todayWords.indexOf(
                              vocabState.currentWord!,
                            ) ==
                            index;
                        return Container(
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WordCard extends StatefulWidget {
  final VocabularyWord word;
  final VoidCallback onMarkLearned;
  final VoidCallback onToggleFavorite;

  const _WordCard({
    required this.word,
    required this.onMarkLearned,
    required this.onToggleFavorite,
  });

  @override
  State<_WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<_WordCard> {
  bool _showDefinition = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showDefinition = !_showDefinition;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Favorite Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    widget.word.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.word.isFavorite
                        ? Colors.red
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                  ),
                  onPressed: widget.onToggleFavorite,
                ),
              ),

              const Spacer(),

              // Word
              Text(
                widget.word.word,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // Pronunciation
              Text(
                widget.word.pronunciation,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 4),

              // Part of Speech
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.word.partOfSpeech,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Definition (revealed on tap)
              AnimatedCrossFade(
                firstChild: Text(
                  'Tap to reveal definition',
                  style: TextStyle(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    fontSize: 16,
                  ),
                ),
                secondChild: Column(
                  children: [
                    Text(
                      widget.word.definition,
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
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"${widget.word.example}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                crossFadeState: _showDefinition
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              const Spacer(),

              // Mastery Level
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mastery: ',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  ...List.generate(5, (index) {
                    return Icon(
                      index < widget.word.masteryLevel
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.accentYellow,
                      size: 20,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Mark as Learned Button
              if (_showDefinition)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onMarkLearned,
                    child: const Text('Got it!'),
                  ),
                ).animate().fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
  }
}
