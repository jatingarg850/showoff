import 'package:flutter/material.dart';
import 'reel_screen.dart';
import 'talent_screen.dart';
import 'path_selection_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final String? initialPostId;

  const MainScreen({super.key, this.initialIndex = 0, this.initialPostId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late String? _currentInitialPostId;

  // Global key to access reel screen state
  final GlobalKey<ReelScreenState> _reelScreenKey =
      GlobalKey<ReelScreenState>();

  // Keep screen instances to preserve state
  late Widget _reelScreen;
  late final Widget _talentScreen;
  late final Widget _pathScreen;
  late final Widget _walletScreen;
  late final Widget _profileScreen;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentInitialPostId = widget.initialPostId;

    // Create screens once and reuse them
    _reelScreen = ReelScreen(
      key: _reelScreenKey,
      initialPostId: widget.initialPostId,
    );
    _talentScreen = TalentScreen(key: const ValueKey('talent_screen'));
    _pathScreen = PathSelectionScreen(key: const ValueKey('path_screen'));
    _walletScreen = WalletScreen(key: const ValueKey('wallet_screen'));
    _profileScreen = ProfileScreen(key: const ValueKey('profile_screen'));
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If initialPostId changed, recreate the ReelScreen
    if (oldWidget.initialPostId != widget.initialPostId) {
      print(
        '🔄 MainScreen: initialPostId changed from ${oldWidget.initialPostId} to ${widget.initialPostId}',
      );
      _currentInitialPostId = widget.initialPostId;
      _reelScreen = ReelScreen(
        key: _reelScreenKey,
        initialPostId: widget.initialPostId,
      );
    }
  }

  Widget _getCurrentScreen() {
    // Use IndexedStack to keep all screens alive and control visibility
    return IndexedStack(
      index: _currentIndex,
      children: [
        _reelScreen,
        _talentScreen,
        _pathScreen,
        _walletScreen,
        _profileScreen,
      ],
    );
  }

  void _onNavItemTapped(int index) {
    print('Navigation: $_currentIndex to $index');

    // Pause reel video when navigating away from reel screen
    if (_currentIndex == 0 && index != 0) {
      print('Navigating away from reels - stopping all videos');
      _reelScreenKey.currentState?.stopAllVideosCompletely();

      // Triple check - force stop after delays
      Future.delayed(const Duration(milliseconds: 50), () {
        _reelScreenKey.currentState?.stopAllVideosCompletely();
      });
      Future.delayed(const Duration(milliseconds: 150), () {
        _reelScreenKey.currentState?.stopAllVideosCompletely();
        print('Triple-check stop executed');
      });
    }
    // Resume reel video when navigating back to reel screen
    else if (_currentIndex != 0 && index == 0) {
      print('Navigating to reels - resuming video');
      _reelScreenKey.currentState?.resumeVideo();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 0 ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Current screen content - gets rebuilt on navigation
          _getCurrentScreen(),

          // Floating bottom navigation bar (consistent across all screens)
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF701CF5),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reels icon
                  _buildNavItem(0, 'assets/navbar/1.png', 26),

                  // Talent/Competition icon
                  _buildNavItem(1, 'assets/navbar/2.png', 26),

                  // Add icon
                  _buildNavItem(2, 'assets/navbar/3.png', 30),

                  // Folder icon
                  _buildNavItem(3, 'assets/navbar/4.png', 26),

                  // Profile icon
                  _buildNavItem(4, 'assets/navbar/5.png', 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String imagePath,
    double size, {
    IconData? icon,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: isActive
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: icon != null
                      ? Icon(icon, size: 20, color: const Color(0xFF701CF5))
                      : Image.asset(
                          imagePath,
                          width: size == 30 ? 20 : 20,
                          height: size == 30 ? 20 : 20,
                          color: const Color(0xFF701CF5),
                        ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            )
          : icon != null
          ? Icon(icon, size: size, color: Colors.white)
          : Image.asset(
              imagePath,
              width: size,
              height: size,
              color: Colors.white,
            ),
    );
  }
}
