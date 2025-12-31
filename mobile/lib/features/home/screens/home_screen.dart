import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/streak_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_sessions_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load stats when home screen is first displayed
    Future.microtask(() => ref.read(statsProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning! 👋',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to practice?',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

                    // Profile Avatar
                    GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ),

            // Streak Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const StreakCard()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Start Practice Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    _StartPracticeCard(onTap: () => context.push('/practice'))
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    QuickActionCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Conversation',
                      subtitle: 'Practice dialogue',
                      color: AppColors.primary,
                      onTap: () => context.push('/practice'),
                    ),
                    const SizedBox(width: 12),
                    QuickActionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Vocabulary',
                      subtitle: 'Learn new words',
                      color: AppColors.secondary,
                      onTap: () => context.push('/vocabulary'),
                    ),
                    const SizedBox(width: 12),
                    QuickActionCard(
                      icon: Icons.psychology_rounded,
                      title: 'Brain Games',
                      subtitle: 'Train your mind',
                      color: AppColors.accent,
                      onTap: () => context.push('/games'),
                    ),
                    const SizedBox(width: 12),
                    QuickActionCard(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Pronunciation',
                      subtitle: 'Perfect your accent',
                      color: AppColors.accentYellow,
                      onTap: () => context.push('/practice'),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recent Sessions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Sessions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/progress'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const RecentSessionsList().animate().fadeIn(
                  delay: 500.ms,
                  duration: 500.ms,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StartPracticeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _StartPracticeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Speaking',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Practice your pronunciation with AI feedback',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
