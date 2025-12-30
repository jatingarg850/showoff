import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

/// HLS (HTTP Live Streaming) Service
/// Handles adaptive bitrate streaming and HLS playlist management
class HlsService {
  static const String _tag = '🎬 HLS';

  /// Check if a URL is already in HLS format
  static bool isHlsUrl(String url) {
    return url.endsWith('.m3u8');
  }

  /// Convert a video URL to HLS format
  /// Supports Wasabi, local servers, and generic URLs
  static String convertToHlsUrl(String videoUrl) {
    // If already HLS, return as-is
    if (isHlsUrl(videoUrl)) {
      debugPrint('$_tag URL is already HLS: $videoUrl');
      return videoUrl;
    }

    // Replace file extension with .m3u8
    final baseUrl = videoUrl.replaceAll(RegExp(r'\.[^.]+$'), '');
    final hlsUrl = '$baseUrl.m3u8';

    debugPrint('$_tag Converted to HLS: $videoUrl -> $hlsUrl');
    return hlsUrl;
  }

  /// Fetch and parse HLS playlist
  /// Returns list of segment URLs with their bitrates
  static Future<HlsPlaylist?> fetchPlaylist(String playlistUrl) async {
    try {
      debugPrint('$_tag Fetching playlist: $playlistUrl');

      final response = await http
          .get(Uri.parse(playlistUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Playlist fetch timeout');
            },
          );

      if (response.statusCode != 200) {
        debugPrint('$_tag Failed to fetch playlist: ${response.statusCode}');
        return null;
      }

      final playlist = HlsPlaylist.parse(response.body, playlistUrl);
      debugPrint('$_tag Playlist parsed: ${playlist.variants.length} variants');
      return playlist;
    } catch (e) {
      debugPrint('$_tag Error fetching playlist: $e');
      return null;
    }
  }

  /// Get recommended bitrate based on network conditions
  /// Returns bitrate in kbps
  static int getRecommendedBitrate({
    required bool isWifi,
    required int signalStrength, // 0-4
  }) {
    if (isWifi) {
      // WiFi: use highest quality
      return 5000; // 5 Mbps
    }

    // Mobile network: adapt based on signal strength
    switch (signalStrength) {
      case 4:
        return 2500; // 2.5 Mbps - excellent signal
      case 3:
        return 1500; // 1.5 Mbps - good signal
      case 2:
        return 800; // 800 kbps - fair signal
      case 1:
      default:
        return 400; // 400 kbps - poor signal
    }
  }

  /// Calculate buffer duration based on bitrate
  /// Higher bitrate = longer buffer needed
  static Duration getBufferDuration(int bitratekbps) {
    if (bitratekbps > 3000) {
      return const Duration(seconds: 10);
    } else if (bitratekbps > 1500) {
      return const Duration(seconds: 8);
    } else if (bitratekbps > 800) {
      return const Duration(seconds: 6);
    } else {
      return const Duration(seconds: 4);
    }
  }
}

/// HLS Playlist model
class HlsPlaylist {
  final String url;
  final bool isLive;
  final Duration targetDuration;
  final List<HlsVariant> variants;
  final List<HlsSegment> segments;

  HlsPlaylist({
    required this.url,
    required this.isLive,
    required this.targetDuration,
    required this.variants,
    required this.segments,
  });

  /// Parse M3U8 playlist content
  static HlsPlaylist parse(String content, String baseUrl) {
    final lines = content.split('\n');
    final variants = <HlsVariant>[];
    final segments = <HlsSegment>[];

    bool isLive = false;
    Duration targetDuration = const Duration(seconds: 10);
    int? bandwidth;
    int? resolution;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty || line.startsWith('#')) {
        // Parse metadata
        if (line.startsWith('#EXT-X-TARGETDURATION:')) {
          targetDuration = Duration(seconds: int.parse(line.split(':')[1]));
        } else if (line.startsWith('#EXT-X-STREAM-INF:')) {
          // Master playlist variant
          bandwidth = _parseAttribute(line, 'BANDWIDTH');
          resolution = _parseResolution(line);
        } else if (line.startsWith('#EXTINF:')) {
          // Segment duration
          final duration = double.parse(line.split(':')[1].split(',')[0]);
          if (i + 1 < lines.length) {
            final segmentUrl = lines[i + 1].trim();
            if (segmentUrl.isNotEmpty && !segmentUrl.startsWith('#')) {
              segments.add(
                HlsSegment(
                  url: _resolveUrl(segmentUrl, baseUrl),
                  duration: Duration(milliseconds: (duration * 1000).toInt()),
                ),
              );
            }
          }
        } else if (line.contains('EXT-X-ENDLIST')) {
          isLive = false;
        } else if (line.contains('EXT-X-LIVE')) {
          isLive = true;
        }
        continue;
      }

      // This is a variant URL
      if (bandwidth != null) {
        variants.add(
          HlsVariant(
            url: _resolveUrl(line, baseUrl),
            bandwidth: bandwidth,
            resolution: resolution,
          ),
        );
        bandwidth = null;
        resolution = null;
      }
    }

    return HlsPlaylist(
      url: baseUrl,
      isLive: isLive,
      targetDuration: targetDuration,
      variants: variants,
      segments: segments,
    );
  }

  /// Get best variant for given bitrate
  HlsVariant? getBestVariant(int maxBitrate) {
    HlsVariant? best;
    for (final variant in variants) {
      if (variant.bandwidth <= maxBitrate) {
        if (best == null || variant.bandwidth > best.bandwidth) {
          best = variant;
        }
      }
    }
    return best ?? (variants.isNotEmpty ? variants.first : null);
  }

  static int? _parseAttribute(String line, String attribute) {
    final regex = RegExp('$attribute=(\\d+)');
    final match = regex.firstMatch(line);
    return match != null ? int.parse(match.group(1)!) : null;
  }

  static int? _parseResolution(String line) {
    final regex = RegExp(r'RESOLUTION=(\d+)x(\d+)');
    final match = regex.firstMatch(line);
    if (match != null) {
      final width = int.parse(match.group(1)!);
      final height = int.parse(match.group(2)!);
      return width * height;
    }
    return null;
  }

  static String _resolveUrl(String url, String baseUrl) {
    if (url.startsWith('http')) {
      return url;
    }
    if (url.startsWith('/')) {
      final uri = Uri.parse(baseUrl);
      return '${uri.scheme}://${uri.host}$url';
    }
    return '$baseUrl/$url';
  }
}

/// HLS Variant (different quality/bitrate)
class HlsVariant {
  final String url;
  final int bandwidth; // in kbps
  final int? resolution; // width * height

  HlsVariant({required this.url, required this.bandwidth, this.resolution});

  String get qualityLabel {
    if (resolution == null) {
      return '${(bandwidth / 1000).toStringAsFixed(1)} Mbps';
    }
    final height = sqrt(resolution! / (16 / 9)).toInt();
    return '${height}p';
  }
}

/// HLS Segment (video chunk)
class HlsSegment {
  final String url;
  final Duration duration;

  HlsSegment({required this.url, required this.duration});
}
