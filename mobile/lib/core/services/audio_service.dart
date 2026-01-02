import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  late final Record _recorder = Record();
  final AudioPlayer _player = AudioPlayer();

  String? _recordingPath;
  bool _isRecording = false;
  StreamSubscription? _amplitudeSubscription;

  bool get isRecording => _isRecording;
  String? get lastRecordingPath => _recordingPath;

  // Amplitude stream for visualizations
  Stream<double>? _amplitudeStream;
  Stream<double>? get amplitudeStream => _amplitudeStream;

  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    print('🎤 Requesting microphone permission...');
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      print('❌ Microphone permission denied');
      throw Exception('Microphone permission not granted');
    }
    print('✅ Microphone permission granted');

    // Get temp directory for recording
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _recordingPath = '${directory.path}/recording_$timestamp.m4a';
    print('📁 Recording path: $_recordingPath');

    // Start recording with correct API
    try {
      print('🎙️ Starting recorder...');
      await _recorder.start(
        path: _recordingPath,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _isRecording = true;
      print('✅ Recording started successfully');

      // Create amplitude stream for visualization
      _amplitudeStream = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .map((amp) => (amp.current + 160) / 160); // Normalize to 0-1 range
    } catch (e) {
      print('❌ Failed to start recording: $e');
      _recordingPath = null;
      rethrow;
    }
  }

  Future<File?> stopRecording() async {
    if (!_isRecording) {
      print('⚠️ Recorder is not recording');
      return null;
    }

    print('⏹️ Stopping recorder...');
    await _recorder.stop();
    _isRecording = false;
    _amplitudeStream = null;

    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      print('✅ Recording stopped. File exists: $exists, Size: $size bytes');
      return file;
    }
    print('⚠️ No recording path found');
    return null;
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    await _recorder.stop();
    _isRecording = false;
    _amplitudeStream = null;

    // Delete the recording file
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _recordingPath = null;
  }

  Future<void> playRecording([String? path]) async {
    final filePath = path ?? _recordingPath;
    if (filePath == null) {
      throw Exception('No recording path provided');
    }

    // Check if file exists before attempting to play
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Recording file not found at path: $filePath');
    }

    // Check file size to ensure it's valid
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Recording file is empty');
    }

    // Stop any current playback first to avoid bad state
    try {
      await _player.stop();
    } catch (e) {
      // Ignore stop errors
    }

    // Small delay to ensure player is ready
    await Future.delayed(const Duration(milliseconds: 100));

    await _player.play(DeviceFileSource(filePath));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  Future<void> pausePlayback() async {
    await _player.pause();
  }

  Future<void> resumePlayback() async {
    await _player.resume();
  }

  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<Duration?> get durationStream => _player.onDurationChanged;

  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _amplitudeSubscription?.cancel();
  }
}
