// Math Facts Hub Screen - Entry point for learning and practice
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/math_facts_data.dart';

class MathFactsScreen extends StatelessWidget {
  const MathFactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: isSmallScreen ? 140 : 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.calculate_rounded,
                                color: Colors.white,
                                size: isSmallScreen ? 28 : 36,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 12 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Math Facts',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 22 : 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Tables • Squares • Cubes',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // LEARN Section
                _SectionHeader(
                  title: '📚 Learn',
                  subtitle: 'Master the fundamentals',
                  isDark: isDark,
                  isSmallScreen: isSmallScreen,
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Learning Cards
                _LearnCard(
                      title: 'Tables 11-20',
                      subtitle: 'Multiplication tables',
                      icon: Icons.grid_view_rounded,
                      color: const Color(0xFF6C5CE7),
                      factCount: '100 facts',
                      isDark: isDark,
                      isSmallScreen: isSmallScreen,
                      onTap: () =>
                          context.push('/math-facts/learn', extra: 'tables'),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1),

                SizedBox(height: isSmallScreen ? 10 : 12),

                Row(
                      children: [
                        Expanded(
                          child: _LearnCard(
                            title: 'Squares',
                            subtitle: '1² to 25²',
                            icon: Icons.crop_square_rounded,
                            color: const Color(0xFF00B894),
                            factCount: '25 facts',
                            isDark: isDark,
                            isSmallScreen: isSmallScreen,
                            compact: true,
                            onTap: () => context.push(
                              '/math-facts/learn',
                              extra: 'squares',
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 12),
                        Expanded(
                          child: _LearnCard(
                            title: 'Cubes',
                            subtitle: '1³ to 15³',
                            icon: Icons.view_in_ar_rounded,
                            color: const Color(0xFFE17055),
                            factCount: '15 facts',
                            isDark: isDark,
                            isSmallScreen: isSmallScreen,
                            compact: true,
                            onTap: () => context.push(
                              '/math-facts/learn',
                              extra: 'cubes',
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1),

                SizedBox(height: isSmallScreen ? 28 : 36),

                // PRACTICE Section
                _SectionHeader(
                      title: '🎮 Practice',
                      subtitle: 'Test your skills with timed challenges',
                      isDark: isDark,
                      isSmallScreen: isSmallScreen,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideX(begin: -0.1),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Practice Mode Cards
                ...PracticeMode.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mode = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
                    child:
                        _PracticeModeCard(
                              mode: mode,
                              isDark: isDark,
                              isSmallScreen: isSmallScreen,
                              onTap: () => _showLevelSelection(
                                context,
                                mode,
                                isDark,
                                isSmallScreen,
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 400 + index * 100),
                              duration: 400.ms,
                            )
                            .slideY(begin: 0.1),
                  );
                }),

                SizedBox(height: isSmallScreen ? 16 : 24),

                // Quick Tips
                _TipsCard(isDark: isDark, isSmallScreen: isSmallScreen)
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelSelection(
    BuildContext context,
    PracticeMode mode,
    bool isDark,
    bool isSmallScreen,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Title
            Text(
              'Select Level',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode.title,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Level options
            ...PracticeLevel.values.map(
              (level) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LevelOptionCard(
                  level: level,
                  isDark: isDark,
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/math-facts/practice',
                      extra: {'mode': mode, 'level': level},
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 8 : 16),
          ],
        ),
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final bool isSmallScreen;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Learn Card Widget
class _LearnCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String factCount;
  final bool isDark;
  final bool isSmallScreen;
  final bool compact;
  final VoidCallback onTap;

  const _LearnCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.factCount,
    required this.isDark,
    required this.isSmallScreen,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isSmallScreen ? 22 : 26,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      factCount,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isSmallScreen ? 26 : 32,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 14 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      factCount,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ],
              ),
      ),
    );
  }
}

// Practice Mode Card Widget
class _PracticeModeCard extends StatelessWidget {
  final PracticeMode mode;
  final bool isDark;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const _PracticeModeCard({
    required this.mode,
    required this.isDark,
    required this.isSmallScreen,
    required this.onTap,
  });

  Color get _color {
    switch (mode) {
      case PracticeMode.squares:
        return const Color(0xFF00B894);
      case PracticeMode.cubes:
        return const Color(0xFFE17055);
      case PracticeMode.mixed:
        return const Color(0xFF6C5CE7);
    }
  }

  IconData get _icon {
    switch (mode) {
      case PracticeMode.squares:
        return Icons.crop_square_rounded;
      case PracticeMode.cubes:
        return Icons.view_in_ar_rounded;
      case PracticeMode.mixed:
        return Icons.shuffle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_color.withOpacity(0.15), _color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _color, size: isSmallScreen ? 24 : 28),
            ),
            SizedBox(width: isSmallScreen ? 14 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Level Option Card Widget
class _LevelOptionCard extends StatelessWidget {
  final PracticeLevel level;
  final bool isDark;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const _LevelOptionCard({
    required this.level,
    required this.isDark,
    required this.isSmallScreen,
    required this.onTap,
  });

  Color get _color {
    return level == PracticeLevel.level1
        ? const Color(0xFF00B894)
        : const Color(0xFFE17055);
  }

  IconData get _icon {
    return level == PracticeLevel.level1
        ? Icons.touch_app_rounded
        : Icons.dialpad_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color, size: isSmallScreen ? 22 : 26),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        level.title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          level.subtitle,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            fontWeight: FontWeight.w600,
                            color: _color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _color,
              size: isSmallScreen ? 16 : 18,
            ),
          ],
        ),
      ),
    );
  }
}

// Tips Card Widget
class _TipsCard extends StatelessWidget {
  final bool isDark;
  final bool isSmallScreen;

  const _TipsCard({required this.isDark, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentYellow.withOpacity(0.1)
            : AppColors.accentYellow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentYellow.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: AppColors.accentYellow,
            size: isSmallScreen ? 22 : 26,
          ),
          SizedBox(width: isSmallScreen ? 12 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Learn the facts first, then practice to build speed and accuracy!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
