import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/recording_button.dart';
import '../widgets/dynamic_waveform.dart';
import '../widgets/feedback_card.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  PracticeState _state = PracticeState.idle;
  int _recordingSeconds = 0;
  Timer? _timer;
  final AudioService _audioService = AudioService();
  File? _recordedFile;
  bool _isPlaying = false;
  String? _transcription;
  FeedbackResult? _feedbackResult;

  // Mock feedback data (will be replaced with API response later)
  final _feedback = PracticeFeedback(
    transcription:
        "Hello, my name is John and I would like to order a coffee please.",
    correctedText:
        "Hello, my name is John, and I would like to order a coffee, please.",
    score: 85,
    feedback:
        "Great job! Your pronunciation is clear and natural. Just remember to add commas for better pacing.",
    pronunciationTips: [
      "The 'th' sound in 'the' could be slightly more emphasized",
      "Good stress on 'coffee' - keep it up!",
    ],
    grammarNotes: [
      "Add a comma before 'and' when joining independent clauses",
      "Add a comma before 'please' for politeness emphasis",
    ],
  );

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await _audioService.requestPermission();
    if (!hasPermission && mounted) {
      _showErrorSnackBar(
        'Microphone permission is required for speech practice',
      );
    }
  }

  void _startRecording() async {
    try {
      await _audioService.startRecording();

      setState(() {
        _state = PracticeState.recording;
        _recordingSeconds = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _recordingSeconds++;
        });

        // Auto-stop after 60 seconds
        if (_recordingSeconds >= 60) {
          _stopRecording();
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to start recording: $e');
    }
  }

  void _stopRecording() async {
    _timer?.cancel();

    try {
      final file = await _audioService.stopRecording();
      _recordedFile = file;

      setState(() {
        _state = PracticeState.processing;
      });

      // Use Riverpod provider to send to backend API
      if (file != null) {
        print('🚀 Submitting audio file to API via provider...');
        await ref.read(practiceProvider.notifier).stopRecording();

        if (!mounted) return;

        // Wait a short moment then check the state
        await Future.delayed(const Duration(milliseconds: 100));

        final practiceState = ref.read(practiceProvider);

        if (practiceState.status == PracticeStatus.completed) {
          setState(() {
            _transcription = practiceState.transcription;
            _feedbackResult = practiceState.feedback;
            _state = PracticeState.feedback;
          });
          print('✅ Feedback received successfully');
        } else if (practiceState.status == PracticeStatus.error) {
          _showErrorSnackBar(practiceState.error ?? 'Unknown error occurred');
          print('❌ Error: ${practiceState.error}');
          _reset();
        } else if (practiceState.status == PracticeStatus.processing) {
          // Still processing - backend may take longer, show timeout message
          await Future.delayed(const Duration(seconds: 10));
          if (!mounted) return;
          final updatedState = ref.read(practiceProvider);
          if (updatedState.status == PracticeStatus.completed) {
            setState(() {
              _transcription = updatedState.transcription;
              _feedbackResult = updatedState.feedback;
              _state = PracticeState.feedback;
            });
          } else {
            _showErrorSnackBar(
              'Speech analysis is taking too long. Please check your backend connection.',
            );
            _reset();
          }
        }
      } else {
        throw Exception('No recording file created');
      }
    } catch (e) {
      print('❌ Exception in _stopRecording: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to process recording: $e');
        _reset();
      }
    }
  }

  void _cancelRecording() async {
    _timer?.cancel();
    await _audioService.cancelRecording();
    _reset();
  }

  void _playRecording() async {
    if (_recordedFile == null) return;

    try {
      setState(() => _isPlaying = true);
      await _audioService.playRecording(_recordedFile!.path);

      // Listen for playback completion
      _audioService.playerStateStream.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _showErrorSnackBar('Failed to play recording: $e');
      }
    }
  }

  void _stopPlayback() async {
    await _audioService.stopPlayback();
    setState(() => _isPlaying = false);
  }

  void _reset() {
    _timer?.cancel();
    ref.read(practiceProvider.notifier).reset();
    setState(() {
      _state = PracticeState.idle;
      _recordingSeconds = 0;
      _recordedFile = null;
      _isPlaying = false;
      _transcription = null;
      _feedbackResult = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Practice',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_state == PracticeState.feedback)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              onPressed: _reset,
            ),
        ],
      ),
      body: SafeArea(child: _buildBody(isDark)),
    );
  }

  Widget _buildBody(bool isDark) {
    switch (_state) {
      case PracticeState.idle:
        return _buildIdleState(isDark);
      case PracticeState.recording:
        return _buildRecordingState(isDark);
      case PracticeState.processing:
        return _buildProcessingState(isDark);
      case PracticeState.feedback:
        return _buildFeedbackState(isDark);
    }
  }

  Widget _buildIdleState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Prompt Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Today\'s Prompt',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Order a coffee at a café',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try saying: "Hello, I would like to order a large latte with oat milk, please."',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

          const Spacer(),

          // Instructions
          Text(
            'Tap the microphone to start',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

          const SizedBox(height: 32),

          // Recording Button
          RecordingButton(isRecording: false, onTap: _startRecording)
              .animate()
              .fadeIn(delay: 500.ms, duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildRecordingState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),

          // Recording Indicator with time
          RecordingIndicator(isRecording: true, seconds: _recordingSeconds),

          const SizedBox(height: 24),

          Text(
            'Listening...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 48),

          // Dynamic Waveform that responds to voice
          DynamicWaveformVisualizer(
            amplitudeStream: _audioService.amplitudeStream,
            isRecording: true,
          ),

          const Spacer(),

          // Stop instruction
          Text(
            'Tap to stop recording',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          // Recording Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel Button
              IconButton(
                onPressed: _cancelRecording,
                icon: const Icon(Icons.close_rounded),
                iconSize: 32,
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.grey.shade200,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(width: 32),
              // Stop Recording Button
              RecordingButton(isRecording: true, onTap: _stopRecording),
              const SizedBox(width: 32),
              // Placeholder for symmetry
              const SizedBox(width: 64),
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildProcessingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 800.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(1, 1),
                duration: 800.ms,
              ),

          const SizedBox(height: 32),

          Text(
            'Analyzing your speech...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'This may take a moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Playback Controls
          if (_recordedFile != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isPlaying ? _stopPlayback : _playRecording,
                    icon: Icon(
                      _isPlaying
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.primary,
                    ),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Recording',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _isPlaying ? 'Playing...' : 'Tap to listen',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(_recordingSeconds),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 16),

          // Show feedback from API or fallback to mock
          if (_feedbackResult != null)
            FeedbackCard(
              feedback: PracticeFeedback(
                transcription: _transcription ?? _feedbackResult!.originalText,
                correctedText: _feedbackResult!.correctedText,
                score: _feedbackResult!.overallScore,
                feedback:
                    'Overall Score: ${_feedbackResult!.overallScore}/100\n'
                    'Pronunciation: ${_feedbackResult!.pronunciationScore}/100\n'
                    'Grammar: ${_feedbackResult!.grammarScore}/100\n'
                    'Fluency: ${_feedbackResult!.fluencyScore}/100',
                pronunciationTips: _feedbackResult!.pronunciationTips,
                grammarNotes: _feedbackResult!.grammarCorrections,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1)
          else
            FeedbackCard(
              feedback: _feedback,
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

enum PracticeState { idle, recording, processing, feedback }

class PracticeFeedback {
  final String transcription;
  final String correctedText;
  final int score;
  final String feedback;
  final List<String> pronunciationTips;
  final List<String> grammarNotes;

  PracticeFeedback({
    required this.transcription,
    required this.correctedText,
    required this.score,
    required this.feedback,
    required this.pronunciationTips,
    required this.grammarNotes,
  });
}
