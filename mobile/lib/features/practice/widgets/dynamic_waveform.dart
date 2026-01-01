import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Dynamic waveform visualizer that responds to audio amplitude
class DynamicWaveformVisualizer extends StatefulWidget {
  final Stream<double>? amplitudeStream;
  final bool isRecording;
  final Color? primaryColor;
  final Color? secondaryColor;

  const DynamicWaveformVisualizer({
    super.key,
    this.amplitudeStream,
    this.isRecording = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<DynamicWaveformVisualizer> createState() =>
      _DynamicWaveformVisualizerState();
}

class _DynamicWaveformVisualizerState extends State<DynamicWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  StreamSubscription<double>? _amplitudeSubscription;

  final int _barCount = 50;
  late List<double> _barHeights;
  late List<double> _targetHeights;
  double _currentAmplitude = 0.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(_barCount, (_) => 0.1);
    _targetHeights = List.generate(_barCount, (_) => 0.1);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateBars);

    _animationController.repeat();
    _subscribeToAmplitude();
  }

  @override
  void didUpdateWidget(DynamicWaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amplitudeStream != widget.amplitudeStream) {
      _subscribeToAmplitude();
    }
  }

  void _subscribeToAmplitude() {
    _amplitudeSubscription?.cancel();
    if (widget.amplitudeStream != null) {
      _amplitudeSubscription = widget.amplitudeStream!.listen((amplitude) {
        setState(() {
          _currentAmplitude = amplitude.clamp(0.0, 1.0);
        });
      });
    }
  }

  void _updateBars() {
    if (!mounted) return;

    setState(() {
      // Generate new target heights based on amplitude
      for (int i = 0; i < _barCount; i++) {
        if (widget.isRecording && _currentAmplitude > 0.05) {
          // Create wave-like pattern based on amplitude
          final wave = sin(
            (i / _barCount) * pi * 2 +
                DateTime.now().millisecondsSinceEpoch / 100,
          );
          final noise = _random.nextDouble() * 0.2;
          _targetHeights[i] = (_currentAmplitude * 0.8 + wave * 0.3 + noise)
              .clamp(0.1, 1.0);
        } else {
          // Idle state - small ambient animation
          _targetHeights[i] = 0.1 + _random.nextDouble() * 0.05;
        }

        // Smooth transition to target height
        _barHeights[i] =
            _barHeights[i] + (_targetHeights[i] - _barHeights[i]) * 0.3;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amplitudeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? AppColors.primary;
    final secondary = widget.secondaryColor ?? AppColors.accent;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          final height = _barHeights[index];
          final isCenter = (index - _barCount / 2).abs() < _barCount / 4;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 30),
            width: 3,
            height: height * 100,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  primary.withOpacity(0.6 + height * 0.4),
                  isCenter ? secondary : primary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: widget.isRecording && height > 0.3
                  ? [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}

/// Recording indicator with pulsing animation
class RecordingIndicator extends StatefulWidget {
  final bool isRecording;
  final int seconds;

  const RecordingIndicator({
    super.key,
    required this.isRecording,
    required this.seconds,
  });

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RecordingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isRecording ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.isRecording ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: widget.isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Text(
          _formatTime(widget.seconds),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        if (widget.isRecording)
          Text(
            'Recording...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
