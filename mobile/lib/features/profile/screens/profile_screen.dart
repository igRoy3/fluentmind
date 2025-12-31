import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    ref.watch(themeModeProvider); // Watch to trigger rebuilds on theme change
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: user?.photoURL != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user?.email ?? 'Not signed in',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Member Since
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user != null
                                ? 'Member since Dec 2024'
                                : 'Sign in to save progress',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Settings Section
              _SectionTitle(title: 'Settings', isDark: isDark),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.translate_rounded,
                      title: 'Target Language',
                      subtitle: 'English (US)',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      subtitle: 'Enabled',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    _ThemeToggleTile(
                      isDark: isDark,
                      onToggle: () {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    _SettingsTile(
                      icon: Icons.volume_up_rounded,
                      title: 'Sound Effects',
                      subtitle: 'On',
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // Support Section
              _SectionTitle(title: 'Support', isDark: isDark),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    _SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      isDark: isDark,
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 20),

              // App Version
              Text(
                'FluentMind v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textHintDark : AppColors.textHint,
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggleTile({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onToggle,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        isDark ? 'On' : 'Off',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (_) => onToggle(),
        activeColor: AppColors.primary,
      ),
    );
  }
}
