import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms of Service',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FluentMind Terms of Service',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                        ),
                        Text(
                          'Last updated: January 1, 2026',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.textHintDark
                                    : AppColors.textHint,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            _Section(
              title: '1. Acceptance of Terms',
              content: '''
By downloading, installing, or using FluentMind ("the App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, please do not use the App.

These Terms constitute a legally binding agreement between you and FluentMind regarding your use of the App and any related services.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            _Section(
              title: '2. Description of Service',
              content: '''
FluentMind is an AI-powered language learning application that provides:
• Speech recognition and pronunciation feedback
• Vocabulary building games and exercises
• Conversation practice simulations
• Progress tracking and analytics
• Personalized learning recommendations

The App uses artificial intelligence to analyze your speech patterns and provide educational feedback. Results may vary based on audio quality, accent, and other factors.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            _Section(
              title: '3. User Accounts',
              content: '''
To access certain features, you may need to create an account. You agree to:
• Provide accurate and complete information
• Maintain the security of your account credentials
• Notify us immediately of any unauthorized access
• Accept responsibility for all activities under your account

We reserve the right to suspend or terminate accounts that violate these Terms or engage in fraudulent activity.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            _Section(
              title: '4. User Content',
              content: '''
When using the App, you may submit voice recordings and other content ("User Content"). You retain ownership of your User Content, but grant us a worldwide, non-exclusive, royalty-free license to:
• Process and analyze your recordings for feedback
• Improve our AI models and services
• Store data necessary for App functionality

You represent that you have the right to submit any User Content and that it does not violate any third-party rights.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

            _Section(
              title: '5. Prohibited Conduct',
              content: '''
You agree NOT to:
• Use the App for any illegal purpose
• Attempt to reverse engineer or hack the App
• Upload malicious content or viruses
• Impersonate others or provide false information
• Interfere with the App's operation or servers
• Use automated systems to access the App
• Share your account with others
• Circumvent any security measures
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            _Section(
              title: '6. Intellectual Property',
              content: '''
The App and its original content, features, and functionality are owned by FluentMind and are protected by international copyright, trademark, and other intellectual property laws.

Our trademarks and trade dress may not be used in connection with any product or service without prior written consent.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

            _Section(
              title: '7. Disclaimers',
              content: '''
THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. WE DO NOT GUARANTEE:
• Uninterrupted or error-free service
• Accuracy of AI-generated feedback
• Specific learning outcomes
• Compatibility with all devices

Language learning results depend on individual effort and practice. The App is a tool to assist learning, not a guarantee of fluency.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            _Section(
              title: '8. Limitation of Liability',
              content: '''
TO THE MAXIMUM EXTENT PERMITTED BY LAW, FLUENTMIND SHALL NOT BE LIABLE FOR:
• Any indirect, incidental, or consequential damages
• Loss of data or profits
• Service interruptions
• Third-party actions

Our total liability shall not exceed the amount you paid for the App in the past 12 months.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

            _Section(
              title: '9. Changes to Terms',
              content: '''
We may update these Terms from time to time. We will notify you of significant changes through:
• In-app notifications
• Email to your registered address
• Updates on our website

Continued use of the App after changes constitutes acceptance of the new Terms.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            _Section(
              title: '10. Contact Information',
              content: '''
If you have questions about these Terms, please contact us:

Email: roy.dev.official@gmail.com

FluentMind
Language Learning Solutions

Thank you for using FluentMind!
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _Section({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
