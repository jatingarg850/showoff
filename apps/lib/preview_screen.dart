import 'package:flutter/material.dart';
import 'dart:io';

class PreviewScreen
    extends
        StatelessWidget {
  final String
  selectedPath;
  final String?
  mediaPath;
  final String?
  category;
  final String
  caption;

  const PreviewScreen({
    super.key,
    required this.selectedPath,
    this.mediaPath,
    this.category,
    required this.caption,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: ShaderMask(
          shaderCallback:
              (
                bounds,
              ) =>
                  const LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF3E98E4,
                      ),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                    bounds,
                  ),
          child: const Text(
            'Preview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background media
          if (mediaPath !=
              null)
            Positioned.fill(
              child: Image.file(
                File(
                  mediaPath!,
                ),
                fit: BoxFit.cover,
              ),
            )
          else
            // Placeholder if no media
            Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.white54,
                ),
              ),
            ),

          // Black gradient overlay for bottom content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  stops: [
                    0.0,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // Overlay content
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Competition badge
                if (selectedPath ==
                    'arena')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: const Text(
                      'In competition',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 8,
                ),

                // Category badge
                if (category !=
                    null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF701CF5,
                      ),
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: Text(
                      category!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 16,
                ),

                // Username
                const Row(
                  children: [
                    Text(
                      '@james9898',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                // Follow button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF701CF5,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // Caption
                if (caption.isNotEmpty)
                  Text(
                    caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Upload button
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF701CF5,
                    ),
                    Color(
                      0xFF74B9FF,
                    ),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Handle upload
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Content uploaded to ${selectedPath == 'arena' ? 'Arena' : 'Reels'}!',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      duration: const Duration(
                        seconds: 2,
                      ),
                    ),
                  );

                  // Navigate back to main screen or home
                  Navigator.popUntil(
                    context,
                    (
                      route,
                    ) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
