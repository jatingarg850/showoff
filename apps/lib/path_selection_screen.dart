import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'daily_selfie_screen.dart';

class PathSelectionScreen
    extends
        StatefulWidget {
  const PathSelectionScreen({
    super.key,
  });

  @override
  State<
    PathSelectionScreen
  >
  createState() => _PathSelectionScreenState();
}

class _PathSelectionScreenState
    extends
        State<
          PathSelectionScreen
        > {
  String?
  selectedPath;

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),

              // Title
              ShaderMask(
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
                              0xFF701CF5,
                            ),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                          bounds,
                        ),
                child: const Text(
                  'Select a path',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Where will you like to upload to?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 60,
              ),

              // Path Options - Three columns
              Column(
                children: [
                  // First row - Reels and SYT
                  Row(
                    children: [
                      // Reels Option
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                selectedPath = 'reels';
                              },
                            );
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              gradient:
                                  selectedPath ==
                                      'reels'
                                  ? const LinearGradient(
                                      colors: [
                                        Color(
                                          0xFF701CF5,
                                        ),
                                        Color(
                                          0xFF701CF5,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color:
                                  selectedPath ==
                                      'reels'
                                  ? null
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                              border:
                                  selectedPath ==
                                      'reels'
                                  ? null
                                  : Border.all(
                                      color: const Color.fromRGBO(
                                        68,
                                        138,
                                        255,
                                        1,
                                      ),
                                      width: 2,
                                    ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                16,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/navbar/1.png',
                                    width: 32,
                                    height: 32,
                                    color:
                                        selectedPath ==
                                            'reels'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    'Reels',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          selectedPath ==
                                              'reels'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'Post like other members',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          selectedPath ==
                                              'reels'
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      // SYT Option
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                selectedPath = 'SYT';
                              },
                            );
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              gradient:
                                  selectedPath ==
                                      'SYT'
                                  ? const LinearGradient(
                                      colors: [
                                        Color(
                                          0xFF701CF5,
                                        ),
                                        Color(
                                          0xFF701CF5,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color:
                                  selectedPath ==
                                      'SYT'
                                  ? null
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                              border: Border.all(
                                color:
                                    selectedPath ==
                                        'SYT'
                                    ? Colors.transparent
                                    : const Color.fromRGBO(
                                        68,
                                        138,
                                        255,
                                        1,
                                      ),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                16,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/navbar/2.png',
                                    width: 32,
                                    height: 32,
                                    color:
                                        selectedPath ==
                                            'SYT'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    'SYT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          selectedPath ==
                                              'SYT'
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    'Compete to win prizes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          selectedPath ==
                                              'SYT'
                                          ? Colors.white70
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // Second row - Daily Selfie Challenge (full width)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const DailySelfieScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(
                              0xFFFF6B35,
                            ),
                            Color(
                              0xFFFF8E53,
                            ),
                            Color(
                              0xFFFFB366,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(
                                  0xFFFF6B35,
                                ).withValues(
                                  alpha: 0.4,
                                ),
                            blurRadius: 20,
                            offset: const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 20,
                            bottom: -30,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),
                          ),

                          // Main content
                          Padding(
                            padding: const EdgeInsets.all(
                              20,
                            ),
                            child: Row(
                              children: [
                                // Icon container with enhanced design
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_front_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title with HOT badge
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Daily Selfie Challenge',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.local_fire_department,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  'HOT',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'Build streaks, earn achievements,\nand compete with friends!',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      // Stats row with flexible layout
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.emoji_events,
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  '5 Levels',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.leaderboard,
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  'Leaderboard',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow with enhanced design
                                Container(
                                  padding: const EdgeInsets.all(
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 80,
              ),

              // Continue Button
              Center(
                child: Container(
                  width: 299,
                  height: 56,

                  decoration: BoxDecoration(
                    gradient:
                        selectedPath !=
                            null
                        ? const LinearGradient(
                            colors: [
                              Color(
                                0xFF701CF5,
                              ),
                              Color(
                                0xFF701CF5,
                              ),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color:
                        selectedPath !=
                            null
                        ? null
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        selectedPath !=
                            null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => CameraScreen(
                                      selectedPath: selectedPath!,
                                    ),
                              ),
                            );
                          }
                        : null,
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
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 80,
              ), // Space for bottom navbar
            ],
          ),
        ),
      ),
    );
  }
}
