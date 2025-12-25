import 'package:just_audio/just_audio.dart';

class BackgroundMusicService {
  static final BackgroundMusicService _instance =
      BackgroundMusicService._internal();

  late AudioPlayer _audioPlayer;
  String? _currentMusicId;
  String? _currentMusicUrl;
  bool _isPlaying = false;

  factory BackgroundMusicService() {
    return _instance;
  }

  BackgroundMusicService._internal() {
    _audioPlayer = AudioPlayer();
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _isPlaying = true;
        print('🎵 Background music playing');
      } else {
        _isPlaying = false;
        print('⏸️ Background music paused');
      }
    });

    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        print('✅ Background music completed');
        // Loop the music
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      }
    });
  }

  /// Load and play background music
  Future<void> playBackgroundMusic(String musicUrl, String musicId) async {
    try {
      print('🎵 Loading background music: $musicUrl');

      // Stop current music if playing
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      _currentMusicId = musicId;
      _currentMusicUrl = musicUrl;

      // Set audio source
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(musicUrl)));

      // Set volume to 0.85 (85%) so music is prominent
      await _audioPlayer.setVolume(0.85);

      // Play the music
      await _audioPlayer.play();

      print('✅ Background music started playing at 85% volume');
    } catch (e) {
      print('❌ Error playing background music: $e');
      rethrow;
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      // CRITICAL: Always stop, don't check _isPlaying flag
      // The flag might be out of sync with actual playback state
      await _audioPlayer.stop();
      print('⏹️ Background music stopped');

      // Reset current music tracking
      _currentMusicId = null;
      _currentMusicUrl = null;
    } catch (e) {
      print('❌ Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        print('⏸️ Background music paused');
      }
    } catch (e) {
      print('❌ Error pausing background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    try {
      if (!_isPlaying && _currentMusicUrl != null) {
        await _audioPlayer.play();
        print('▶️ Background music resumed');
      }
    } catch (e) {
      print('❌ Error resuming background music: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      print(
        '🔊 Background music volume set to: ${(volume * 100).toStringAsFixed(0)}%',
      );
    } catch (e) {
      print('❌ Error setting volume: $e');
    }
  }

  /// Get current music ID
  String? getCurrentMusicId() => _currentMusicId;

  /// Get current music URL
  String? getCurrentMusicUrl() => _currentMusicUrl;

  /// Check if music is playing
  bool isPlaying() => _isPlaying;

  /// Get audio player for advanced control
  AudioPlayer getAudioPlayer() => _audioPlayer;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      print('🗑️ Background music service disposed');
    } catch (e) {
      print('❌ Error disposing background music service: $e');
    }
  }

  /// Get duration stream
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Get position stream
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Get player state stream
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
}
