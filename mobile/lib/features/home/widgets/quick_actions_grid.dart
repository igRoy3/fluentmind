// Quick Actions Grid - Main practice entry points
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  final bool isDark;

  const QuickActionsGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _ActionCard(
          title: 'Speak',
          subtitle: 'Practice fluency',
          icon: Icons.mic_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5CF5), Color(0xFF9D7FE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isDark: isDark,
          onTap: () => context.push('/practice'),
        ),
        _ActionCard(
          title: 'Vocabulary',
          subtitle: 'Learn new words',
          icon: Icons.menu_book_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF4DD0E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isDark: isDark,
          onTap: () => context.push('/vocabulary'),
        ),
        _ActionCard(
          title: 'Mind Games',
          subtitle: 'Cognitive skills',
          icon: Icons.psychology_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isDark: isDark,
          onTap: () => context.push('/games'),
        ),
        _ActionCard(
          title: 'Progress',
          subtitle: 'Track growth',
          icon: Icons.insights_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isDark: isDark,
          onTap: () => context.push('/progress'),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
