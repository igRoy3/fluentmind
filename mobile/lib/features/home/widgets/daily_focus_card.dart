// Daily Focus Card - Shows today's personalized focus area
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';

class DailyFocusCard extends StatelessWidget {
  final DailyFocus focus;
  final bool isDark;
  final VoidCallback onStartPressed;

  const DailyFocusCard({
    super.key,
    required this.focus,
    required this.isDark,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    final focusInfo = _getFocusInfo(focus.type);

    return Container(
      decoration: BoxDecoration(
        gradient: focusInfo.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: focusInfo.shadowColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onStartPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "TODAY'S FOCUS",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        focus.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        focus.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Start Now',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: focusInfo.buttonTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '~${focus.estimatedMinutes} min',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        focusInfo.icon,
                        size: 36,
                        color: Colors.white,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 1500.ms,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _FocusInfo _getFocusInfo(FocusType type) {
    switch (type) {
      case FocusType.vocabulary:
        return _FocusInfo(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B5CF5), Color(0xFF6D4AE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.menu_book_rounded,
          shadowColor: AppColors.primary,
          buttonTextColor: AppColors.primary,
        );
      case FocusType.fluency:
        return _FocusInfo(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.graphic_eq_rounded,
          shadowColor: AppColors.secondary,
          buttonTextColor: AppColors.secondary,
        );
      case FocusType.pronunciation:
        return _FocusInfo(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5253)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.record_voice_over_rounded,
          shadowColor: AppColors.error,
          buttonTextColor: AppColors.error,
        );
      case FocusType.cognitive:
        return _FocusInfo(
          gradient: const LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.psychology_rounded,
          shadowColor: AppColors.success,
          buttonTextColor: const Color(0xFF11998E),
        );
      case FocusType.hesitation:
        return _FocusInfo(
          gradient: const LinearGradient(
            colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.speed_rounded,
          shadowColor: AppColors.accentYellow,
          buttonTextColor: const Color(0xFFF7971E),
        );
    }
  }
}

class _FocusInfo {
  final LinearGradient gradient;
  final IconData icon;
  final Color shadowColor;
  final Color buttonTextColor;

  _FocusInfo({
    required this.gradient,
    required this.icon,
    required this.shadowColor,
    required this.buttonTextColor,
  });
}
