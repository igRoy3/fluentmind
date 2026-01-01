import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Subtle feedback overlay for incorrect answers
/// Shows a quick visual feedback without interrupting gameplay
class SubtleFeedbackOverlay extends StatefulWidget {
  final Widget child;
  final bool showIncorrect;
  final bool showCorrect;
  final VoidCallback? onFeedbackComplete;

  const SubtleFeedbackOverlay({
    super.key,
    required this.child,
    this.showIncorrect = false,
    this.showCorrect = false,
    this.onFeedbackComplete,
  });

  @override
  SubtleFeedbackOverlayState createState() => SubtleFeedbackOverlayState();
}

class SubtleFeedbackOverlayState extends State<SubtleFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;
  bool _showFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _showFeedback = false;
        });
        widget.onFeedbackComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SubtleFeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIncorrect && !oldWidget.showIncorrect) {
      _triggerFeedback(false);
    } else if (widget.showCorrect && !oldWidget.showCorrect) {
      _triggerFeedback(true);
    }
  }

  void _triggerFeedback(bool isCorrect) {
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
    });

    // Haptic feedback
    if (!isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    _controller.forward();
  }

  /// Public method to show incorrect feedback
  void showIncorrect() {
    _triggerFeedback(false);
  }

  /// Public method to show correct feedback
  void showCorrect() {
    _triggerFeedback(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shake animation for incorrect
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final offset = _showFeedback && !_isCorrect
                ? sin(_shakeAnimation.value * 3 * 3.14159) * 8
                : 0.0;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: widget.child,
            );
          },
        ),

        // Feedback overlay
        if (_showFeedback)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          (_isCorrect ? AppColors.success : AppColors.error)
                              .withOpacity(0.0),
                          (_isCorrect ? AppColors.success : AppColors.error)
                              .withOpacity(0.15 * _fadeAnimation.value),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Edge indicator
        if (_showFeedback)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: (_isCorrect ? AppColors.success : AppColors.error)
                        .withOpacity(_fadeAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isCorrect ? AppColors.success : AppColors.error)
                                .withOpacity(_fadeAnimation.value * 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Quick feedback toast that appears and disappears
class QuickFeedbackToast extends StatefulWidget {
  final String message;
  final bool isCorrect;
  final VoidCallback? onDismiss;

  const QuickFeedbackToast({
    super.key,
    required this.message,
    required this.isCorrect,
    this.onDismiss,
  });

  @override
  State<QuickFeedbackToast> createState() => _QuickFeedbackToastState();
}

class _QuickFeedbackToastState extends State<QuickFeedbackToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isCorrect
                    ? AppColors.success.withOpacity(0.9)
                    : AppColors.error.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.isCorrect ? AppColors.success : AppColors.error)
                            .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isCorrect
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Button that shows subtle feedback on tap
class FeedbackButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isCorrect;
  final bool showFeedback;

  const FeedbackButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isCorrect = true,
    this.showFeedback = false,
  });

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showingFeedback = false;
  bool _feedbackIsCorrect = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(FeedbackButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFeedback && !oldWidget.showFeedback) {
      setState(() {
        _showingFeedback = true;
        _feedbackIsCorrect = widget.isCorrect;
      });
      _controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _controller.reverse().then((_) {
              setState(() {
                _showingFeedback = false;
              });
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Color? overlayColor;
          if (_showingFeedback) {
            overlayColor =
                (_feedbackIsCorrect ? AppColors.success : AppColors.error)
                    .withOpacity(0.3 * _controller.value);
          }

          return Container(
            decoration: BoxDecoration(
              color: overlayColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Helper mixin to add sin function
double sin(double x) {
  return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
}
