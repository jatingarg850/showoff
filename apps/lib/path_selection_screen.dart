import 'package:flutter/material.dart';
import 'camera_screen.dart';

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

              // Path Options
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
                        height: 180,
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
                                  color: Color.fromRGBO(
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
                            20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/navbar/1.png',
                                width: 40,
                                height: 40,
                                color:
                                    selectedPath ==
                                        'reels'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                'Reels',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      selectedPath ==
                                          'reels'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Post like other members of the app',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
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
                    width: 20,
                  ),

                  // Arena Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            selectedPath = 'arena';
                          },
                        );
                      },
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient:
                              selectedPath ==
                                  'arena'
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
                                  'arena'
                              ? null
                              : Colors.white,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                          border: Border.all(
                            color:
                                selectedPath ==
                                    'arena'
                                ? Colors.transparent
                                : const Color.fromRGBO(
                                    68,
                                    138,
                                    255,
                                    1,
                                  ), // Blue border when not selected
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/navbar/2.png',
                                width: 40,
                                height: 40,
                                color:
                                    selectedPath ==
                                        'arena'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                'Arena',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      selectedPath ==
                                          'arena'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Compete with other users to win prizes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      selectedPath ==
                                          'arena'
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
