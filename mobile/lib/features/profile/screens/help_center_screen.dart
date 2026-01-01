import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Center',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // Quick Help Section
            Text(
              'Popular Topics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // FAQ Cards
            _HelpTopicCard(
                  icon: Icons.mic_rounded,
                  title: 'How to use Speech Practice',
                  description:
                      'Learn how to record your voice and get AI feedback',
                  isDark: isDark,
                  onTap: () =>
                      _showHelpDetail(context, 'How to use Speech Practice', '''
1. Tap the microphone button to start recording
2. Speak clearly in your target language
3. Tap again to stop recording
4. Wait for AI analysis
5. Review your pronunciation score and tips

Tips for better results:
• Find a quiet environment
• Speak at a normal pace
• Hold your phone 6-12 inches from your mouth
• Try to speak complete sentences
                ''', isDark),
                )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideX(begin: -0.1),

            const SizedBox(height: 12),

            _HelpTopicCard(
                  icon: Icons.games_rounded,
                  title: 'Playing Vocabulary Games',
                  description: 'Master new words through interactive games',
                  isDark: isDark,
                  onTap: () =>
                      _showHelpDetail(context, 'Playing Vocabulary Games', '''
FluentMind offers several game modes:

📚 Flashcards
Swipe through cards to learn new words. Tap to flip and see translations.

🎯 Quiz Mode
Test your knowledge with multiple choice questions. Build streaks for bonus XP!

🔗 Matching Game
Match words with their meanings before time runs out.

✍️ Spelling Challenge
Type the correct spelling of words you hear.

Progress Tips:
• Complete daily challenges for bonus rewards
• Focus on categories relevant to your goals
• Review missed words in your personal dictionary
                ''', isDark),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideX(begin: -0.1),

            const SizedBox(height: 12),

            _HelpTopicCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Conversation Practice',
                  description: 'Practice real-world dialogues with AI',
                  isDark: isDark,
                  onTap: () =>
                      _showHelpDetail(context, 'Conversation Practice', '''
Practice realistic conversations in various scenarios:

☕ Coffee Shop - Order drinks and small talk
🏨 Hotel Check-in - Book rooms and ask for amenities
💼 Job Interview - Professional communication skills
🏥 Doctor's Visit - Describe symptoms and understand advice
🍽️ Restaurant - Order food and handle dining situations
✈️ Travel - Navigate airports and ask for directions

How it works:
1. Choose a scenario
2. Read the context and your role
3. Use suggested responses or record your own
4. Get feedback on your pronunciation and grammar
                ''', isDark),
                )
                .animate()
                .fadeIn(delay: 250.ms, duration: 400.ms)
                .slideX(begin: -0.1),

            const SizedBox(height: 12),

            _HelpTopicCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'XP and Achievements',
                  description: 'Understanding your progress and rewards',
                  isDark: isDark,
                  onTap: () =>
                      _showHelpDetail(context, 'XP and Achievements', '''
Earn XP (Experience Points) by:
• Completing practice sessions: +10-50 XP
• Finishing games: +20-100 XP
• Daily login streak: +25 XP per day
• Perfect scores: +50 bonus XP

Level Up System:
• Level 1-10: 100 XP per level
• Level 11-25: 250 XP per level
• Level 26-50: 500 XP per level
• Level 51+: 1000 XP per level

Achievements unlock special badges:
🔥 Streak Master - 7 day streak
⭐ Perfect Score - 100% on any game
📚 Word Collector - Learn 100 words
🎯 Sharpshooter - 10 perfect rounds
                ''', isDark),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideX(begin: -0.1),

            const SizedBox(height: 32),

            // Contact Section
            Text(
              'Need More Help?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

            const SizedBox(height: 16),

            Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Contact Support',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our team is here to help you 24/7',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          // Navigate to feedback screen
                        },
                        icon: const Icon(
                          Icons.email_rounded,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'Send us a message',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

            const SizedBox(height: 16),

            _FAQItem(
              question: 'Is FluentMind free to use?',
              answer:
                  'Yes! FluentMind offers a free tier with access to basic features. Premium features are available with a subscription.',
              isDark: isDark,
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            _FAQItem(
              question: 'How does the AI feedback work?',
              answer:
                  'We use advanced speech recognition to analyze your pronunciation, grammar, and fluency. Our AI provides personalized tips to help you improve.',
              isDark: isDark,
            ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

            _FAQItem(
              question: 'Can I use FluentMind offline?',
              answer:
                  'Some features like flashcards and saved lessons work offline. Speech analysis and AI feedback require an internet connection.',
              isDark: isDark,
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

            _FAQItem(
              question: 'How do I reset my progress?',
              answer:
                  'Go to Profile > Settings > Reset Progress. Note: This action cannot be undone.',
              isDark: isDark,
            ).animate().fadeIn(delay: 650.ms, duration: 400.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showHelpDetail(
    BuildContext context,
    String title,
    String content,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              // Close Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Got it!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;
  final VoidCallback onTap;

  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDark;

  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isDark,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isExpanded = !_isExpanded);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.answer,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
