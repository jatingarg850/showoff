import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Instagram-style background music service for reels
/// Handles music playback with proper scroll handling
class BackgroundMusicService {
  static final BackgroundMusicService _instance =
      BackgroundMusicService._internal();

  late AudioPlayer _audioPlayer;
  String? _currentMusicId;
  String? _currentMusicUrl;
  bool _isPlaying = false;
  bool _isPaused = false;

  // Prevent rapid music changes during scroll
  DateTime? _lastMusicChange;
  static const int _musicChangeDebounceMs = 100;

  factory BackgroundMusicService() {
    return _instance;
  }

  BackgroundMusicService._internal() {
    _audioPlayer = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
    });

    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        // Loop the music
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      }
    });
  }

  /// Load and play background music
  /// Returns true if music started playing, false otherwise
  Future<bool> playBackgroundMusic(String musicUrl, String musicId) async {
    try {
      debugPrint('🎵 BackgroundMusicService: Playing $musicUrl');

      // Debounce rapid music changes
      final now = DateTime.now();
      if (_lastMusicChange != null &&
          now.difference(_lastMusicChange!).inMilliseconds <
              _musicChangeDebounceMs) {
        debugPrint('🎵 BackgroundMusicService: Debounced, skipping');
        return false;
      }
      _lastMusicChange = now;

      // Same music already playing
      if (_currentMusicId == musicId && _isPlaying) {
        debugPrint('🎵 BackgroundMusicService: Same music already playing');
        return true;
      }

      // Stop current music first
      if (_isPlaying || _currentMusicUrl != null) {
        debugPrint('🎵 BackgroundMusicService: Stopping current music');
        await _audioPlayer.stop();
      }

      _currentMusicId = musicId;
      _currentMusicUrl = musicUrl;
      _isPaused = false;

      // Set audio source
      debugPrint('🎵 BackgroundMusicService: Setting audio source');
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(musicUrl)));

      // Set volume to 85% so music is prominent but not overwhelming
      await _audioPlayer.setVolume(0.85);

      // Play the music
      debugPrint('🎵 BackgroundMusicService: Starting playback');
      await _audioPlayer.play();

      debugPrint('🎵 BackgroundMusicService: Playback started successfully');
      return true;
    } catch (e) {
      debugPrint('🎵 BackgroundMusicService ERROR: $e');
      _currentMusicId = null;
      _currentMusicUrl = null;
      return false;
    }
  }

  /// Stop background music immediately
  /// Call this when scrolling starts
  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
      _currentMusicId = null;
      _currentMusicUrl = null;
      _isPaused = false;
    } catch (e) {
      // Ignore errors during stop
    }
  }

  /// Pause background music (keeps position)
  /// Call this when app goes to background
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPaused = true;
      }
    } catch (e) {
      // Ignore errors during pause
    }
  }

  /// Resume background music from paused position
  /// Call this when app comes back to foreground
  Future<void> resumeBackgroundMusic() async {
    try {
      if (_isPaused && _currentMusicUrl != null) {
        await _audioPlayer.play();
        _isPaused = false;
      }
    } catch (e) {
      // Ignore errors during resume
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get current music ID
  String? getCurrentMusicId() => _currentMusicId;

  /// Check if music is playing
  bool isPlaying() => _isPlaying;

  /// Check if music is paused
  bool isPaused() => _isPaused;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      // Ignore errors during dispose
    }
  }

  /// Get duration stream
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Get position stream
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Get player state stream
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
}
