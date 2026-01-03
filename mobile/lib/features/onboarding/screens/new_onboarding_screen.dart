// New Onboarding Flow - Captures user baseline and goals
// This creates a personalized experience from Day 1

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';
import '../../../core/services/user_journey_service.dart';
import '../../../core/services/audio_service.dart';

class NewOnboardingScreen extends ConsumerStatefulWidget {
  const NewOnboardingScreen({super.key});

  @override
  ConsumerState<NewOnboardingScreen> createState() =>
      _NewOnboardingScreenState();
}

class _NewOnboardingScreenState extends ConsumerState<NewOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // User selections
  String? _userName;
  LearningGoal? _selectedGoal;
  DailyCommitment? _selectedCommitment;

  // Recording state
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  File? _baselineRecording;
  final AudioService _audioService = AudioService();

  final int _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedGoal == null || _selectedCommitment == null) return;

    final journeyService = ref.read(userJourneyServiceProvider);

    // Create user profile
    await journeyService.createProfile(
      name: _userName,
      goal: _selectedGoal!,
      commitment: _selectedCommitment!,
    );

    // Save baseline recording if exists
    if (_baselineRecording != null) {
      await journeyService.addVoiceRecording(
        filePath: _baselineRecording!.path,
        duration: Duration(seconds: _recordingSeconds),
        isBaseline: true,
      );
    }

    // Mark onboarding as complete
    await journeyService.setOnboardingComplete(true);

    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioService.requestPermission();
      if (!hasPermission) {
        _showError('Microphone permission is required');
        return;
      }

      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });

        // Auto-stop after 30 seconds
        if (_recordingSeconds >= 30) {
          _stopRecording();
        }
      });
    } catch (e) {
      _showError('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();

    try {
      final file = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _baselineRecording = file;
      });
    } catch (e) {
      setState(() => _isRecording = false);
      _showError('Failed to save recording');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(_totalSteps, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.divider),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildWelcomeStep(isDark),
                  _buildNameStep(isDark),
                  _buildGoalStep(isDark),
                  _buildCommitmentStep(isDark),
                  _buildBaselineStep(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Welcome
  Widget _buildWelcomeStep(bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return _OnboardingStepContainer(
      isDark: isDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isSmallScreen ? 20 : 60),
          Container(
            width: isSmallScreen ? 100 : 120,
            height: isSmallScreen ? 100 : 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: isSmallScreen ? 50 : 60,
              color: Colors.white,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          SizedBox(height: isSmallScreen ? 24 : 40),
          Text(
            'Welcome to FluentMind',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: isSmallScreen ? 24 : null,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your brain training companion! Sharpen your focus with fun games, expand your vocabulary, and master confident speaking.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: isSmallScreen ? 14 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: 400.ms),
          SizedBox(height: isSmallScreen ? 32 : 48),
          _PrimaryButton(
            text: 'Let\'s Get Started',
            onPressed: _nextStep,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Step 2: Name (optional)
  Widget _buildNameStep(bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return _OnboardingStepContainer(
      isDark: isDark,
      showBack: true,
      onBack: _previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 20 : 40),
          Text(
            'What should we call you?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: isSmallScreen ? 24 : 32),
          TextField(
            onChanged: (value) => setState(() => _userName = value.trim()),
            decoration: InputDecoration(
              hintText: 'Your name (optional)',
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: isSmallScreen ? 32 : 48),
          _PrimaryButton(
            text: 'Continue',
            onPressed: _nextStep,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _nextStep,
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Step 3: Learning Goal
  Widget _buildGoalStep(bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return _OnboardingStepContainer(
      isDark: isDark,
      showBack: true,
      onBack: _previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 16 : 40),
          Text(
            'What would you like to improve?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: isSmallScreen ? 20 : null,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'We\'ll customize your experience based on your goals.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: isSmallScreen ? 14 : null,
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: isSmallScreen ? 16 : 24),
          ...LearningGoal.values.asMap().entries.map((entry) {
            final goal = entry.value;
            final isSelected = _selectedGoal == goal;
            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              child: _GoalCard(
                icon: _getGoalIcon(goal),
                title: goal.description,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedGoal = goal),
                isDark: isDark,
                isCompact: isSmallScreen,
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 150 * entry.key));
          }),
          SizedBox(height: isSmallScreen ? 16 : 24),
          _PrimaryButton(
            text: 'Continue',
            onPressed: _selectedGoal != null ? _nextStep : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getGoalIcon(LearningGoal goal) {
    switch (goal) {
      case LearningGoal.expandVocabulary:
        return Icons.menu_book_rounded;
      case LearningGoal.sharpenFocus:
        return Icons.lightbulb_rounded;
      case LearningGoal.thinkFaster:
        return Icons.psychology_rounded;
      case LearningGoal.speakConfidently:
        return Icons.record_voice_over_rounded;
    }
  }

  // Step 4: Daily Commitment
  Widget _buildCommitmentStep(bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return _OnboardingStepContainer(
      isDark: isDark,
      showBack: true,
      onBack: _previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 16 : 40),
          Text(
            'How much time can you practice daily?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: isSmallScreen ? 20 : null,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Consistency matters more than duration.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: isSmallScreen ? 14 : null,
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: isSmallScreen ? 16 : 24),
          ...DailyCommitment.values.asMap().entries.map((entry) {
            final commitment = entry.value;
            final isSelected = _selectedCommitment == commitment;
            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              child: _CommitmentCard(
                minutes: commitment.minutes,
                label: commitment.label,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCommitment = commitment),
                isDark: isDark,
                isCompact: isSmallScreen,
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 150 * entry.key));
          }),
          if (_selectedCommitment != null) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'At ${_selectedCommitment!.minutes} min/day, you\'ll see real progress in 7 days!',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ],
          SizedBox(height: isSmallScreen ? 16 : 24),
          _PrimaryButton(
            text: 'Continue',
            onPressed: _selectedCommitment != null ? _nextStep : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Step 5: Voice Baseline Recording
  Widget _buildBaselineStep(bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return _OnboardingStepContainer(
      isDark: isDark,
      showBack: true,
      onBack: _previousStep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallScreen ? 16 : 40),
          Text(
            'Record Your Starting Point',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: isSmallScreen ? 20 : null,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'This quick recording becomes your baseline. Compare future recordings to see your amazing progress!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: isSmallScreen ? 14 : null,
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.accentYellow,
                  size: isSmallScreen ? 28 : 32,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  'Speak about: "Describe your ideal day"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: isSmallScreen ? 15 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'Don\'t worry about being perfect—just speak naturally!',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: isSmallScreen ? 13 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: isSmallScreen ? 20 : 32),
          Center(
            child: _RecordButton(
              isRecording: _isRecording,
              seconds: _recordingSeconds,
              hasRecording: _baselineRecording != null,
              onTap: _isRecording ? _stopRecording : _startRecording,
              isDark: isDark,
              isCompact: isSmallScreen,
            ),
          ).animate().fadeIn(delay: 300.ms),
          if (_baselineRecording != null) ...[
            SizedBox(height: isSmallScreen ? 12 : 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recording saved! (${_recordingSeconds}s)',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),
          ],
          SizedBox(height: isSmallScreen ? 24 : 32),
          _PrimaryButton(
            text: 'Start My Journey',
            onPressed: _completeOnboarding,
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Center(
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip recording for now',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Supporting Widgets

class _OnboardingStepContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final bool showBack;
  final VoidCallback? onBack;

  const _OnboardingStepContainer({
    required this.child,
    required this.isDark,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCompact;

  const _GoalCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isCompact ? 40 : 48,
              height: isCompact ? 40 : 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: isCompact ? 20 : 24,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: isCompact ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _CommitmentCard extends StatelessWidget {
  final int minutes;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCompact;

  const _CommitmentCard({
    required this.minutes,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isCompact ? 14 : 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isCompact ? 48 : 56,
              height: isCompact ? 48 : 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$minutes',
                  style: TextStyle(
                    fontSize: isCompact ? 17 : 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$minutes minutes/day',
                    style: TextStyle(
                      fontSize: isCompact ? 15 : 17,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: isCompact ? 2 : 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: isCompact ? 20 : 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final int seconds;
  final bool hasRecording;
  final VoidCallback onTap;
  final bool isDark;
  final bool isCompact;

  const _RecordButton({
    required this.isRecording,
    required this.seconds,
    required this.hasRecording,
    required this.onTap,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalSize = isCompact ? 70.0 : 80.0;
    final recordingSize = isCompact ? 88.0 : 100.0;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? recordingSize : normalSize,
            height: isRecording ? recordingSize : normalSize,
            decoration: BoxDecoration(
              gradient: isRecording
                  ? LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.error.withOpacity(0.8),
                      ],
                    )
                  : AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isRecording ? AppColors.error : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: isRecording ? (isCompact ? 36 : 40) : (isCompact ? 32 : 36),
            ),
          ),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        Text(
          isRecording
              ? '${seconds}s / 30s'
              : (hasRecording ? 'Tap to re-record' : 'Tap to start'),
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
