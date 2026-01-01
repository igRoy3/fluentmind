import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound effect types available in the app
enum SoundEffect {
  tap,
  success,
  error,
  complete,
  levelUp,
  reward,
  correct,
  incorrect,
  notification,
  swoosh,
}

/// Sound settings state
class SoundSettings {
  final bool soundEnabled;
  final double volume;

  const SoundSettings({this.soundEnabled = true, this.volume = 1.0});

  SoundSettings copyWith({bool? soundEnabled, double? volume}) {
    return SoundSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
    );
  }
}

/// Sound settings provider
final soundSettingsProvider =
    StateNotifierProvider<SoundSettingsNotifier, SoundSettings>((ref) {
      return SoundSettingsNotifier();
    });

/// Sound service provider
final soundServiceProvider = Provider<SoundService>((ref) {
  final settings = ref.watch(soundSettingsProvider);
  return SoundService(settings);
});

/// Notifier for sound settings
class SoundSettingsNotifier extends StateNotifier<SoundSettings> {
  static const _soundEnabledKey = 'sound_enabled';
  static const _volumeKey = 'sound_volume';

  SoundSettingsNotifier() : super(const SoundSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_soundEnabledKey) ?? true;
    final volume = prefs.getDouble(_volumeKey) ?? 1.0;
    state = SoundSettings(soundEnabled: enabled, volume: volume);
  }

  Future<void> toggleSound() async {
    final prefs = await SharedPreferences.getInstance();
    final newEnabled = !state.soundEnabled;
    await prefs.setBool(_soundEnabledKey, newEnabled);
    state = state.copyWith(soundEnabled: newEnabled);
  }

  Future<void> setVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
    state = state.copyWith(volume: volume);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
    state = state.copyWith(soundEnabled: enabled);
  }
}

/// Service for playing sound effects
class SoundService {
  final SoundSettings _settings;
  final AudioPlayer _player = AudioPlayer();

  SoundService(this._settings);

  /// Play a sound effect
  Future<void> play(SoundEffect effect) async {
    if (!_settings.soundEnabled) return;

    try {
      await _player.setVolume(_settings.volume);

      // Use system sounds via tone generation
      // In production, you'd use actual audio files
      await _playTone(effect);
    } catch (e) {
      // Silently fail - sound is not critical
    }
  }

  Future<void> _playTone(SoundEffect effect) async {
    // Generate simple tones based on effect type
    // These are placeholder implementations using system feedback
    final source = _getAssetSource(effect);
    if (source != null) {
      await _player.play(source);
    }
  }

  AssetSource? _getAssetSource(SoundEffect effect) {
    // Map effects to audio files
    // For now, we'll use a simple approach with generated tones
    // In production, add actual audio files to assets/sounds/
    switch (effect) {
      case SoundEffect.tap:
        return null; // Use haptic feedback instead
      case SoundEffect.success:
        return null;
      case SoundEffect.error:
        return null;
      case SoundEffect.complete:
        return null;
      case SoundEffect.levelUp:
        return null;
      case SoundEffect.reward:
        return null;
      case SoundEffect.correct:
        return null;
      case SoundEffect.incorrect:
        return null;
      case SoundEffect.notification:
        return null;
      case SoundEffect.swoosh:
        return null;
    }
  }

  /// Play tap sound with haptic feedback
  Future<void> playTap() async {
    await play(SoundEffect.tap);
  }

  /// Play success sound
  Future<void> playSuccess() async {
    await play(SoundEffect.success);
  }

  /// Play error sound
  Future<void> playError() async {
    await play(SoundEffect.error);
  }

  /// Play completion sound
  Future<void> playComplete() async {
    await play(SoundEffect.complete);
  }

  /// Play level up sound
  Future<void> playLevelUp() async {
    await play(SoundEffect.levelUp);
  }

  /// Play reward sound
  Future<void> playReward() async {
    await play(SoundEffect.reward);
  }

  /// Play correct answer sound
  Future<void> playCorrect() async {
    await play(SoundEffect.correct);
  }

  /// Play incorrect answer sound
  Future<void> playIncorrect() async {
    await play(SoundEffect.incorrect);
  }

  void dispose() {
    _player.dispose();
  }
}

/// Extension to easily play sounds from BuildContext
extension SoundServiceExtension on WidgetRef {
  SoundService get soundService => read(soundServiceProvider);

  void playTap() => soundService.playTap();
  void playSuccess() => soundService.playSuccess();
  void playError() => soundService.playError();
  void playComplete() => soundService.playComplete();
  void playLevelUp() => soundService.playLevelUp();
  void playReward() => soundService.playReward();
  void playCorrect() => soundService.playCorrect();
  void playIncorrect() => soundService.playIncorrect();
}
