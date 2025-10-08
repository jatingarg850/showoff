import 'package:flutter/material.dart';
import 'reel_screen.dart';
import 'talent_screen.dart';

class MainScreen
    extends
        StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<
    MainScreen
  >
  createState() => _MainScreenState();
}

class _MainScreenState
    extends
        State<
          MainScreen
        > {
  int
  _currentIndex = 0;

  final List<
    Widget
  >
  _screens = [
    const ReelScreen(),
    const TalentScreen(),
    const Center(
      child: Text(
        'Add Screen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
    const Center(
      child: Text(
        'Folder Screen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
    const Center(
      child: Text(
        'Profile Screen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    ),
  ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          _currentIndex ==
              0
          ? Colors.black
          : Colors.white,
      body: Stack(
        children: [
          // Current screen content
          _screens[_currentIndex],

          // Floating bottom navigation bar (consistent across all screens)
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF6C5CE7,
                ),
                borderRadius: BorderRadius.circular(
                  25,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.15,
                    ),
                    blurRadius: 20,
                    offset: const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reels icon
                  _buildNavItem(
                    0,
                    Icons.play_arrow,
                    26,
                  ),

                  // Talent/Competition icon
                  _buildNavItem(
                    1,
                    Icons.card_giftcard_outlined,
                    26,
                  ),

                  // Add icon
                  _buildNavItem(
                    2,
                    Icons.add,
                    30,
                  ),

                  // Folder icon
                  _buildNavItem(
                    3,
                    Icons.folder_outlined,
                    26,
                  ),

                  // Profile icon
                  _buildNavItem(
                    4,
                    Icons.person_outline,
                    26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildNavItem(
    int index,
    IconData icon,
    double size,
  ) {
    final isActive =
        _currentIndex ==
        index;

    return GestureDetector(
      onTap: () {
        setState(
          () {
            _currentIndex = index;
          },
        );
      },
      child: isActive
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(
                      0xFF6C5CE7,
                    ),
                    size:
                        size ==
                            30
                        ? 20
                        : 20,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      2,
                    ),
                  ),
                ),
              ],
            )
          : Icon(
              icon,
              color: Colors.white,
              size: size,
            ),
    );
  }
}
