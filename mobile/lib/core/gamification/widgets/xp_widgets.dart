import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

/// Animated XP gain popup that shows when user earns XP
class XPGainAnimation extends StatefulWidget {
  final int amount;
  final VoidCallback onComplete;
  final Offset? position;

  const XPGainAnimation({
    super.key,
    required this.amount,
    required this.onComplete,
    this.position,
  });

  @override
  State<XPGainAnimation> createState() => _XPGainAnimationState();
}

class _XPGainAnimationState extends State<XPGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -50),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _positionAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentYellow,
                      AppColors.accentYellow.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentYellow.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 18),
                    Text(
                      '${widget.amount} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating XP particles that burst when XP is earned
class XPParticles extends StatefulWidget {
  final int count;
  final VoidCallback onComplete;

  const XPParticles({super.key, this.count = 8, required this.onComplete});

  @override
  State<XPParticles> createState() => _XPParticlesState();
}

class _XPParticlesState extends State<XPParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final random = math.Random();
    _particles = List.generate(widget.count, (index) {
      final angle = (index / widget.count) * 2 * math.pi;
      final velocity = 50 + random.nextDouble() * 100;
      return _Particle(
        angle: angle,
        velocity: velocity,
        size: 6 + random.nextDouble() * 6,
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final progress = _controller.value;
            final dx = math.cos(particle.angle) * particle.velocity * progress;
            final dy =
                math.sin(particle.angle) * particle.velocity * progress -
                (50 * progress * progress); // Gravity effect
            final opacity = 1.0 - progress;

            return Transform.translate(
              offset: Offset(dx, dy),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentYellow.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double velocity;
  final double size;

  _Particle({required this.angle, required this.velocity, required this.size});
}

/// Compact XP display widget for app bars and headers
class XPDisplay extends StatelessWidget {
  final int totalXP;
  final int? pendingXP;
  final bool compact;
  final bool isDark;

  const XPDisplay({
    super.key,
    required this.totalXP,
    this.pendingXP,
    this.compact = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: AppColors.accentYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            color: AppColors.accentYellow,
            size: compact ? 16 : 20,
          ),
          const SizedBox(width: 6),
          Text(
            _formatXP(totalXP),
            style: TextStyle(
              color: AppColors.accentYellow,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (pendingXP != null && pendingXP! > 0) ...[
            const SizedBox(width: 4),
            Text(
                  '+$pendingXP',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate(onComplete: (controller) => controller.repeat())
                .shimmer(
                  duration: 1000.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
          ],
        ],
      ),
    );
  }

  String _formatXP(int xp) {
    if (xp >= 10000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return xp.toString();
  }
}

/// Level up celebration overlay
class LevelUpCelebration extends StatefulWidget {
  final int newLevel;
  final String levelTitle;
  final VoidCallback onComplete;
  final bool isDark;

  const LevelUpCelebration({
    super.key,
    required this.newLevel,
    required this.levelTitle,
    required this.onComplete,
    required this.isDark,
  });

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level badge
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'LV',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${widget.newLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .shimmer(delay: 600.ms, duration: 1000.ms),

            const SizedBox(height: 24),

            // Level up text
            const Text(
                  'LEVEL UP!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 12),

            // Title
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.levelTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}

/// Progress bar that shows XP progress to next level
class LevelProgressBar extends StatelessWidget {
  final int currentXP;
  final int currentLevel;
  final int xpForNextLevel;
  final double progress;
  final bool showDetails;
  final bool isDark;

  const LevelProgressBar({
    super.key,
    required this.currentXP,
    required this.currentLevel,
    required this.xpForNextLevel,
    required this.progress,
    this.showDetails = true,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDetails)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level $currentLevel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentXP / $xpForNextLevel XP',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

        if (showDetails) const SizedBox(height: 8),

        // Progress bar
        Stack(
          children: [
            // Background
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            // Progress fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              height: 10,
              width:
                  MediaQuery.of(context).size.width *
                  progress *
                  0.85, // Account for padding
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Combo counter widget that appears during games
class ComboCounter extends StatelessWidget {
  final int combo;
  final bool isDark;

  const ComboCounter({super.key, required this.combo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox.shrink();

    Color comboColor;
    String comboText;

    if (combo >= 15) {
      comboColor = AppColors.error;
      comboText = 'UNSTOPPABLE!';
    } else if (combo >= 10) {
      comboColor = AppColors.warning;
      comboText = 'ON FIRE!';
    } else if (combo >= 5) {
      comboColor = AppColors.accentGreen;
      comboText = 'Great combo!';
    } else {
      comboColor = AppColors.primary;
      comboText = 'Combo';
    }

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: comboColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: comboColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: comboColor, size: 18),
              const SizedBox(width: 4),
              Text(
                '$combo',
                style: TextStyle(
                  color: comboColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                comboText,
                style: TextStyle(
                  color: comboColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
        .animate(onComplete: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 500.ms,
        );
  }
}
