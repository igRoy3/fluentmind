import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/persistent_auth_service.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.psychology_rounded,
      iconColor: AppColors.primary,
      title: 'Fun Brain Games',
      description:
          'Challenge yourself with engaging games designed to sharpen your focus, boost memory, and improve cognitive skills.',
      gradient: AppColors.primaryGradient,
    ),
    OnboardingPageData(
      icon: Icons.menu_book_rounded,
      iconColor: AppColors.secondary,
      title: 'Build Your Vocabulary',
      description:
          'Learn new words every day with smart flashcards, quizzes, and contextual examples that make learning stick.',
      gradient: AppColors.accentGradient,
    ),
    OnboardingPageData(
      icon: Icons.mic_rounded,
      iconColor: AppColors.accentGreen,
      title: 'Practice Self-Speaking',
      description:
          'Record your voice, practice speaking confidently, and track your improvement over time with personalized feedback.',
      gradient: LinearGradient(
        colors: [AppColors.accentGreen, const Color(0xFF55EFC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingPageData(
      icon: Icons.shield_rounded,
      iconColor: const Color(0xFF6C5CE7),
      title: 'Your Privacy Matters',
      description:
          'Your data stays with you. All recordings and progress are stored securely on your device with end-to-end encryption. We never share your personal information.',
      gradient: const LinearGradient(
        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      final persistentAuthService = ref.read(persistentAuthServiceProvider);
      await persistentAuthService.markOnboardingCompleted();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _skip() async {
    // Mark onboarding as completed even when skipped
    final persistentAuthService = ref.read(persistentAuthServiceProvider);
    await persistentAuthService.markOnboardingCompleted();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.dividerDark
                                    : AppColors.divider),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
