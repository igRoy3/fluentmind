// Enhanced Practice Screen with Voice Progress Tracking
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';
import '../../../core/services/user_journey_service.dart';
import '../../../core/services/audio_service.dart';

// Speaking prompts for practice
final speakingPrompts = [
  {
    'topic': 'Self Introduction',
    'prompt':
        'Introduce yourself in 30 seconds. Include your name, where you\'re from, and what you do.',
    'tips': [
      'Speak clearly',
      'Maintain a steady pace',
      'Make eye contact (imagine it)',
    ],
    'duration': 30,
  },
  {
    'topic': 'Daily Routine',
    'prompt': 'Describe what you did yesterday from morning to evening.',
    'tips': [
      'Use past tense correctly',
      'Connect sentences smoothly',
      'Include time markers',
    ],
    'duration': 45,
  },
  {
    'topic': 'Opinion Sharing',
    'prompt': 'What is your favorite book or movie? Explain why you like it.',
    'tips': [
      'State your opinion clearly',
      'Give 2-3 reasons',
      'Use descriptive words',
    ],
    'duration': 45,
  },
  {
    'topic': 'Problem Solving',
    'prompt': 'Describe a challenge you faced and how you overcame it.',
    'tips': [
      'Structure: Problem → Action → Result',
      'Use varied sentence structures',
      'Show reflection',
    ],
    'duration': 60,
  },
  {
    'topic': 'Future Plans',
    'prompt':
        'What are your goals for the next year? How will you achieve them?',
    'tips': ['Use future tense', 'Be specific about plans', 'Show enthusiasm'],
    'duration': 45,
  },
];

class EnhancedPracticeScreen extends ConsumerStatefulWidget {
  const EnhancedPracticeScreen({super.key});

  @override
  ConsumerState<EnhancedPracticeScreen> createState() =>
      _EnhancedPracticeScreenState();
}

class _EnhancedPracticeScreenState
    extends ConsumerState<EnhancedPracticeScreen> {
  final AudioService _audioService = AudioService();
  int _currentPromptIndex = 0;
  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordingSeconds = 0;
  Timer? _timer;
  String? _lastRecordingPath;
  List<VoiceRecording> _previousRecordings = [];
  VoiceRecording? _baselineRecording;
  bool _showComparison = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    final service = ref.read(userJourneyServiceProvider);
    final recordings = await service.getVoiceRecordings();
    final baseline = await service.getBaselineRecording();

    setState(() {
      _previousRecordings = recordings;
      _baselineRecording = baseline;
      _isLoading = false;
    });
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
    final prompt = speakingPrompts[_currentPromptIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Speaking Practice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _showRecordingsHistory(context),
            tooltip: 'Recording History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Header
                  if (_baselineRecording != null)
                    _ProgressHeader(
                      totalRecordings: _previousRecordings.length,
                      baselineDate: _baselineRecording!.recordedAt,
                      isDark: isDark,
                    ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Topic Selector
                  _TopicSelector(
                    prompts: speakingPrompts,
                    currentIndex: _currentPromptIndex,
                    onSelect: (index) =>
                        setState(() => _currentPromptIndex = index),
                    isDark: isDark,
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Prompt Card
                  _PromptCard(
                    topic: prompt['topic'] as String,
                    prompt: prompt['prompt'] as String,
                    tips: prompt['tips'] as List<String>,
                    suggestedDuration: prompt['duration'] as int,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // Recording Controls
                  _RecordingControls(
                    isRecording: _isRecording,
                    isPlaying: _isPlaying,
                    recordingSeconds: _recordingSeconds,
                    maxSeconds: prompt['duration'] as int,
                    hasRecording: _lastRecordingPath != null,
                    onStartRecording: _startRecording,
                    onStopRecording: _stopRecording,
                    onPlayRecording: _playRecording,
                    onSaveRecording: _saveRecording,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Comparison with baseline
                  if (_showComparison && _baselineRecording != null)
                    _ComparisonCard(
                      baseline: _baselineRecording!,
                      currentDuration: _recordingSeconds,
                      isDark: isDark,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Future<void> _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _showComparison = false;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingSeconds++);

        // Auto-stop at max duration
        final maxDuration =
            speakingPrompts[_currentPromptIndex]['duration'] as int;
        if (_recordingSeconds >= maxDuration + 10) {
          _stopRecording();
        }
      });
    } catch (e) {
      // Permission denied or other error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final file = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
      _lastRecordingPath = file?.path;
      _showComparison = true;
    });

    // Auto-save the recording if minimum duration is met
    if (file != null && _recordingSeconds >= 3) {
      await _autoSaveRecording();
    }
  }

  Future<void> _autoSaveRecording() async {
    if (_lastRecordingPath == null) return;

    try {
      final service = ref.read(userJourneyServiceProvider);
      final recording = await service.addVoiceRecording(
        filePath: _lastRecordingPath!,
        duration: Duration(seconds: _recordingSeconds),
      );

      // Update session with recording
      await service.updateTodaySession(
        addMinutes: (_recordingSeconds / 60).ceil(),
        recordingId: recording.id,
      );

      await _loadRecordings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recording saved automatically!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to auto-save recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_lastRecordingPath == null) return;

    setState(() => _isPlaying = true);
    await _audioService.playRecording(_lastRecordingPath!);

    // Simple timer to reset playing state
    Future.delayed(Duration(seconds: _recordingSeconds), () {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _saveRecording() async {
    if (_lastRecordingPath == null) return;

    final service = ref.read(userJourneyServiceProvider);

    final recording = await service.addVoiceRecording(
      filePath: _lastRecordingPath!,
      duration: Duration(seconds: _recordingSeconds),
    );

    // Update session with recording
    await service.updateTodaySession(
      addMinutes: (_recordingSeconds / 60).ceil(),
      recordingId: recording.id,
    );

    await _loadRecordings();

    setState(() {
      _lastRecordingPath = null;
      _showComparison = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recording saved! Keep practicing to improve.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showRecordingsHistory(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recording History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_previousRecordings.length} recordings',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _previousRecordings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_off_rounded,
                              size: 48,
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No recordings yet',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _previousRecordings.length,
                        itemBuilder: (context, index) {
                          final recording = _previousRecordings[index];
                          return _RecordingHistoryItem(
                            recording: recording,
                            isBaseline: recording.isBaseline,
                            isDark: isDark,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Progress Header Widget
class _ProgressHeader extends StatelessWidget {
  final int totalRecordings;
  final DateTime baselineDate;
  final bool isDark;

  const _ProgressHeader({
    required this.totalRecordings,
    required this.baselineDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final daysSinceBaseline = DateTime.now().difference(baselineDate).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Voice Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalRecordings recordings • $daysSinceBaseline days of practice',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
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

// Topic Selector
class _TopicSelector extends StatelessWidget {
  final List<Map<String, dynamic>> prompts;
  final int currentIndex;
  final Function(int) onSelect;
  final bool isDark;

  const _TopicSelector({
    required this.prompts,
    required this.currentIndex,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                      ),
              ),
              child: Center(
                child: Text(
                  prompts[index]['topic'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Prompt Card
class _PromptCard extends StatelessWidget {
  final String topic;
  final String prompt;
  final List<String> tips;
  final int suggestedDuration;
  final bool isDark;

  const _PromptCard({
    required this.topic,
    required this.prompt,
    required this.tips,
    required this.suggestedDuration,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '~$suggestedDuration sec',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textHintDark
                          : AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prompt,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tips',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: AppColors.primary)),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// Recording Controls
class _RecordingControls extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final int recordingSeconds;
  final int maxSeconds;
  final bool hasRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onPlayRecording;
  final VoidCallback onSaveRecording;
  final bool isDark;

  const _RecordingControls({
    required this.isRecording,
    required this.isPlaying,
    required this.recordingSeconds,
    required this.maxSeconds,
    required this.hasRecording,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPlayRecording,
    required this.onSaveRecording,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer display - centered
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecording)
                  Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(begin: 1, end: 0.3, duration: 500.ms),
                if (isRecording) const SizedBox(width: 8),
                Text(
                  _formatTime(recordingSeconds),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  ' / ${_formatTime(maxSeconds)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Dynamic waveform visualizer (Google Recorder style) - centered
        if (isRecording) ...[
          Center(child: _DynamicRecordingWaveform(isDark: isDark)),
          const SizedBox(height: 24),
        ],

        // Main record button - centered
        Center(
          child:
              GestureDetector(
                    onTap: isRecording ? onStopRecording : onStartRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRecording
                            ? AppColors.error
                            : AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isRecording
                                        ? AppColors.error
                                        : AppColors.primary)
                                    .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  )
                  .animate(target: isRecording ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 200.ms,
                  ),
        ),

        const SizedBox(height: 16),

        Center(
          child: Text(
            isRecording ? 'Tap to stop' : 'Tap to record',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),

        if (hasRecording && !isRecording) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: isPlaying ? null : onPlayRecording,
                icon: Icon(
                  isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(isPlaying ? 'Playing...' : 'Play'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onSaveRecording,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

// Comparison Card
class _ComparisonCard extends StatelessWidget {
  final VoiceRecording baseline;
  final int currentDuration;
  final bool isDark;

  const _ComparisonCard({
    required this.baseline,
    required this.currentDuration,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final durationDiff = currentDuration - baseline.duration.inSeconds;
    final isLonger = durationDiff > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Compared to Baseline',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ComparisonStat(
                  label: 'Baseline',
                  value: '${baseline.duration.inSeconds}s',
                  isDark: isDark,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
              Expanded(
                child: _ComparisonStat(
                  label: 'This recording',
                  value: '${currentDuration}s',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isLonger ? AppColors.success : AppColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLonger
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isLonger ? AppColors.success : AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isLonger
                      ? 'Great! You spoke ${durationDiff}s longer'
                      : 'You spoke ${durationDiff.abs()}s shorter',
                  style: TextStyle(
                    color: isLonger ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
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

class _ComparisonStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _ComparisonStat({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Recording History Item
class _RecordingHistoryItem extends StatelessWidget {
  final VoiceRecording recording;
  final bool isBaseline;
  final bool isDark;

  const _RecordingHistoryItem({
    required this.recording,
    required this.isBaseline,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBaseline
            ? AppColors.primary.withOpacity(0.05)
            : (isDark ? AppColors.surfaceDark : AppColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: isBaseline
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isBaseline
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isBaseline ? Icons.flag_rounded : Icons.mic_rounded,
              color: isBaseline ? AppColors.primary : AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isBaseline
                            ? 'Baseline Recording'
                            : _formatDate(recording.recordedAt),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isBaseline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BASELINE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${recording.duration.inSeconds}s • Practice recording',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

// Dynamic Recording Waveform - Google Recorder style
class _DynamicRecordingWaveform extends StatefulWidget {
  final bool isDark;

  const _DynamicRecordingWaveform({required this.isDark});

  @override
  State<_DynamicRecordingWaveform> createState() =>
      _DynamicRecordingWaveformState();
}

class _DynamicRecordingWaveformState extends State<_DynamicRecordingWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _barCount = 50;
  late List<double> _barHeights;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(
      _barCount,
      (_) => _random.nextDouble() * 0.3 + 0.1,
    );

    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 80),
        )..addListener(() {
          setState(() {
            for (int i = 0; i < _barCount; i++) {
              // Smooth transition with some randomness
              final targetHeight = _random.nextDouble() * 0.7 + 0.15;
              _barHeights[i] =
                  _barHeights[i] + (targetHeight - _barHeights[i]) * 0.3;
            }
          });
        });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          // Create a wave-like pattern with center being tallest
          final centerIndex = _barCount ~/ 2;
          final distanceFromCenter = (index - centerIndex).abs();
          final centerFactor = 1.0 - (distanceFromCenter / centerIndex) * 0.3;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            width: 3,
            height: (_barHeights[index] * centerFactor * 60).clamp(4.0, 60.0),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.error.withOpacity(0.7),
                  AppColors.error,
                  AppColors.accentYellow,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
