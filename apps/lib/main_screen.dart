import 'package:flutter/material.dart';
import 'reel_screen.dart';
import 'talent_screen.dart';
import 'path_selection_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

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
    const PathSelectionScreen(),
    const WalletScreen(),
    const ProfileScreen(),
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
                  0xFF701CF5,
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
                    'assets/navbar/1.png',
                    26,
                  ),

                  // Talent/Competition icon
                  _buildNavItem(
                    1,
                    'assets/navbar/2.png',
                    26,
                  ),

                  // Add icon
                  _buildNavItem(
                    2,
                    'assets/navbar/3.png',
                    30,
                  ),

                  // Folder icon
                  _buildNavItem(
                    3,
                    'assets/navbar/4.png',
                    26,
                  ),

                  // Profile icon
                  _buildNavItem(
                    4,
                    'assets/navbar/5.png',
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
    String imagePath,
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
                  child: Image.asset(
                    imagePath,
                    width:
                        size ==
                            30
                        ? 20
                        : 20,
                    height:
                        size ==
                            30
                        ? 20
                        : 20,
                    color: const Color(
                      0xFF701CF5,
                    ),
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
          : Image.asset(
              imagePath,
              width: size,
              height: size,
              color: Colors.white,
            ),
    );
  }
}
