import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
                      color: AppColors.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FluentMind Privacy Policy',
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

            const SizedBox(height: 16),

            // Privacy Highlights
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGreen.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Privacy Highlights',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HighlightItem(
                    icon: Icons.lock_rounded,
                    text: 'Your data is encrypted in transit and at rest',
                    isDark: isDark,
                  ),
                  _HighlightItem(
                    icon: Icons.delete_forever_rounded,
                    text: 'Request deletion of your data anytime',
                    isDark: isDark,
                  ),
                  _HighlightItem(
                    icon: Icons.visibility_off_rounded,
                    text: 'We never sell your personal information',
                    isDark: isDark,
                  ),
                  _HighlightItem(
                    icon: Icons.mic_off_rounded,
                    text: 'Voice recordings processed securely',
                    isDark: isDark,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 50.ms, duration: 400.ms),

            const SizedBox(height: 24),

            _Section(
              title: '1. Information We Collect',
              content: '''
We collect information you provide directly:
• Account information (name, email, profile photo)
• Voice recordings during practice sessions
• Learning progress and performance data
• Device information and usage statistics
• Feedback and support communications

We automatically collect:
• Device identifiers and operating system
• App usage patterns and session duration
• Error logs and performance data
• IP address (anonymized for analytics)
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            _Section(
              title: '2. How We Use Your Information',
              content: '''
We use your information to:
• Provide and improve our language learning services
• Analyze your speech and provide feedback
• Track your progress and customize lessons
• Send notifications about your learning goals
• Respond to support requests
• Improve our AI models (with anonymized data)
• Prevent fraud and ensure security

We do NOT use your data for:
• Selling to third parties
• Targeted advertising
• Profiling for non-educational purposes
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            _Section(
              title: '3. Voice Data and AI Processing',
              content: '''
Your voice recordings are:
• Processed by our AI to provide pronunciation feedback
• Temporarily stored for analysis (typically < 24 hours)
• Not used to identify you personally
• Optionally contributed to improve our AI (with consent)

You can:
• Opt out of AI improvement programs in settings
• Request deletion of all voice data
• Download your voice recording history
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            _Section(
              title: '4. Data Sharing',
              content: '''
We may share your information with:
• Service providers who assist our operations
• Analytics partners (anonymized data only)
• Law enforcement when legally required

We require all partners to:
• Maintain equivalent privacy protections
• Use data only for specified purposes
• Delete data when no longer needed
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

            _Section(
              title: '5. Data Security',
              content: '''
We protect your data with:
• TLS encryption for all data in transit
• AES-256 encryption for data at rest
• Regular security audits and testing
• Access controls and authentication
• Incident response procedures

No system is 100% secure. We promptly notify affected users of any breaches.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            _Section(
              title: '6. Your Rights',
              content: '''
You have the right to:
• Access your personal data
• Correct inaccurate information
• Delete your account and data
• Export your data in a portable format
• Opt out of certain processing
• Withdraw consent at any time

To exercise these rights, contact us at roy.dev.official@gmail.com
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

            _Section(
              title: '7. Children\'s Privacy',
              content: '''
FluentMind is not intended for children under 13. We do not knowingly collect information from children under 13.

If you believe a child has provided us with personal information, please contact us immediately.

For users 13-17, we recommend parental supervision and consent before use.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            _Section(
              title: '8. International Data Transfers',
              content: '''
Your data may be processed in countries outside your residence. We ensure appropriate safeguards:
• Standard contractual clauses
• Privacy Shield certification (where applicable)
• Equivalent privacy protections
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

            _Section(
              title: '9. Changes to This Policy',
              content: '''
We may update this Privacy Policy periodically. We will notify you of significant changes via:
• In-app notifications
• Email notifications
• Prominent notice in the App

Continued use after changes constitutes acceptance.
''',
              isDark: isDark,
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            _Section(
              title: '10. Contact Us',
              content: '''
For privacy questions or to exercise your rights:

Email: roy.dev.official@gmail.com

FluentMind Privacy Team
Response time: Within 30 days

For urgent privacy concerns, include "URGENT" in your subject line.
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

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _HighlightItem({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
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
