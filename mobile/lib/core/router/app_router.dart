import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/new_onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/new_home_screen.dart';
import '../../features/practice/screens/enhanced_practice_screen.dart';
import '../../features/progress/screens/enhanced_progress_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/vocabulary/screens/vocabulary_screen_new.dart';
import '../../features/vocabulary/screens/vocabulary_review_screen.dart';
import '../../features/conversation/screens/conversation_screen.dart';
import '../../features/pronunciation/screens/pronunciation_screen.dart';
import '../../features/games/screens/games_screen.dart';
import '../../features/games/screens/game_play_screen.dart';
import '../../features/word_association/screens/word_association_home_screen.dart';
import '../../features/word_association/screens/word_association_play_screen.dart';
import '../../features/word_association/models/word_association_models.dart';
import '../gamification/screens/progress_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // New Onboarding (personalized)
      GoRoute(
        path: '/new-onboarding',
        name: 'new_onboarding',
        builder: (context, state) => const NewOnboardingScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main App with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: NewHomeScreen()),
          ),
          GoRoute(
            path: '/progress',
            name: 'progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EnhancedProgressScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Practice Screen (full screen, no bottom nav)
      GoRoute(
        path: '/practice',
        name: 'practice',
        builder: (context, state) => const EnhancedPracticeScreen(),
      ),

      // Vocabulary Screen
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        builder: (context, state) => const VocabularyScreenNew(),
      ),

      // Vocabulary Review Screen
      GoRoute(
        path: '/vocabulary-review',
        name: 'vocabulary_review',
        builder: (context, state) => const VocabularyReviewScreen(),
      ),

      // Conversation Screen
      GoRoute(
        path: '/conversation',
        name: 'conversation',
        builder: (context, state) => const ConversationScreen(),
      ),

      // Pronunciation Screen
      GoRoute(
        path: '/pronunciation',
        name: 'pronunciation',
        builder: (context, state) => const PronunciationScreen(),
      ),

      // Games Screen
      GoRoute(
        path: '/games',
        name: 'games',
        builder: (context, state) => const GamesScreen(),
      ),

      // Game Play Screen
      GoRoute(
        path: '/games/:gameId',
        name: 'game_play',
        builder: (context, state) =>
            GamePlayScreen(gameId: state.pathParameters['gameId']!),
      ),

      // Word Association Game
      GoRoute(
        path: '/word-association',
        name: 'word_association',
        builder: (context, state) => const WordAssociationHomeScreen(),
      ),
      GoRoute(
        path: '/word-association/play',
        name: 'word_association_play',
        builder: (context, state) {
          final mode = state.extra as GameMode? ?? GameMode.association;
          return WordAssociationPlayScreen(mode: mode);
        },
      ),

      // Progress Dashboard (Gamification)
      GoRoute(
        path: '/progress-dashboard',
        name: 'progress_dashboard',
        builder: (context, state) => const ProgressDashboardScreen(),
      ),
    ],
  );
});
