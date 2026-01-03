import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'user_journey_service.dart';

/// Keys for SharedPreferences
class _PrefsKeys {
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastUserId = 'last_user_id';
}

/// Persistent auth service provider
final persistentAuthServiceProvider = Provider<PersistentAuthService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return PersistentAuthService(authService, firebaseAuth);
});

/// Service to handle persistent authentication state
class PersistentAuthService {
  final AuthService _authService;
  final FirebaseAuth _firebaseAuth;
  SharedPreferences? _prefs;

  PersistentAuthService(this._authService, this._firebaseAuth);

  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    await _initPrefs();
    return _prefs?.getBool(_PrefsKeys.hasCompletedOnboarding) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    await _initPrefs();
    await _prefs?.setBool(_PrefsKeys.hasCompletedOnboarding, true);
  }

  /// Check if user is logged in (from local storage)
  Future<bool> isLoggedIn() async {
    await _initPrefs();
    // Check both SharedPreferences and Firebase auth state
    final localLoginState = _prefs?.getBool(_PrefsKeys.isLoggedIn) ?? false;
    final firebaseUser = _firebaseAuth.currentUser;

    // If Firebase says user is logged in, trust that
    if (firebaseUser != null) {
      // Sync local state with Firebase state
      await _setLoginState(true, firebaseUser.uid);
      return true;
    }

    return localLoginState;
  }

  /// Set login state
  Future<void> _setLoginState(bool loggedIn, String? userId) async {
    await _initPrefs();
    await _prefs?.setBool(_PrefsKeys.isLoggedIn, loggedIn);
    if (userId != null) {
      await _prefs?.setString(_PrefsKeys.lastUserId, userId);
    } else {
      await _prefs?.remove(_PrefsKeys.lastUserId);
    }
  }

  /// Mark user as logged in
  Future<void> markLoggedIn(String userId) async {
    await _setLoginState(true, userId);
  }

  /// Clear login state (for logout)
  Future<void> clearLoginState() async {
    await _initPrefs();
    await _prefs?.setBool(_PrefsKeys.isLoggedIn, false);
    await _prefs?.remove(_PrefsKeys.lastUserId);
  }

  /// Sign out and clear persistent state
  Future<void> signOut() async {
    await _authService.signOut();
    await clearLoginState();
  }

  /// Get the initial route based on auth state
  Future<String> getInitialRoute() async {
    await _initPrefs();

    // CRITICAL: Wait for Firebase Auth to fully initialize
    // On cold start, currentUser might be null until Firebase restores the session
    User? firebaseUser = _firebaseAuth.currentUser;

    // If no user immediately available, we need to wait for Firebase to restore
    if (firebaseUser == null) {
      // Give Firebase time to restore the session from disk
      // Use a completer to properly wait for auth state
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        firebaseUser = _firebaseAuth.currentUser;

        // If still null, wait a bit more and try listening to auth changes
        if (firebaseUser == null) {
          await Future.delayed(const Duration(milliseconds: 500));
          firebaseUser = _firebaseAuth.currentUser;
        }

        // Final attempt - listen to stream with timeout
        if (firebaseUser == null) {
          firebaseUser = await _firebaseAuth
              .authStateChanges()
              .where((user) => user != null) // Skip initial null
              .first
              .timeout(
                const Duration(seconds: 2),
                onTimeout: () => _firebaseAuth.currentUser,
              );
        }
      } catch (_) {
        // Last resort - check currentUser
        firebaseUser = _firebaseAuth.currentUser;
      }
    }

    // Check if the new personalized onboarding has been completed
    final journeyService = UserJourneyService();
    final hasCompletedNewOnboarding = await journeyService
        .isOnboardingComplete();

    if (firebaseUser != null) {
      // User is authenticated with Firebase - save to local storage
      await markLoggedIn(firebaseUser.uid);
      await markOnboardingCompleted(); // Mark basic onboarding as done

      // Check if they've completed the new personalized onboarding
      if (!hasCompletedNewOnboarding) {
        return '/new-onboarding';
      }

      return '/home';
    }

    // No Firebase user found - check local preferences
    final hasOnboarded = await hasCompletedOnboarding();

    if (!hasOnboarded) {
      // First time user - show onboarding
      return '/onboarding';
    } else {
      // Has onboarded but not logged in - show login
      return '/login';
    }
  }

  /// Reset all persistent data (for testing/debugging)
  Future<void> resetAll() async {
    await _initPrefs();
    await _prefs?.clear();
  }
}
