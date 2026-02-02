import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AppLinks _appLinks;
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _appLinks = AppLinks();
    _initializeDeepLinking();
    _checkAuthAndNavigate();
  }

  /// Initialize deep link listening
  void _initializeDeepLinking() {
    try {
      // Listen for deep links
      _deepLinkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          if (mounted) {
            print('🔗 Deep link received: $uri');
            _handleDeepLink(uri.toString());
          }
        },
        onError: (err) {
          print('❌ Deep link error: $err');
        },
      );
    } catch (e) {
      print('⚠️ Deep link initialization failed: $e');
    }
  }

  /// Parse and handle deep links
  Map<String, dynamic>? _parseDeepLink(String link) {
    try {
      // Handle showofflife://syt/entryId
      if (link.startsWith('showofflife://syt/')) {
        final entryId = link.replaceFirst('showofflife://syt/', '');
        return {'type': 'syt', 'entryId': entryId};
      }

      // Handle showofflife://reel/postId
      if (link.startsWith('showofflife://reel/')) {
        final postId = link.replaceFirst('showofflife://reel/', '');
        return {'type': 'reel', 'postId': postId};
      }

      // Handle https://showoff.life/syt/entryId
      if (link.contains('/syt/')) {
        final entryId = link.split('/syt/').last.split('?').first;
        return {'type': 'syt', 'entryId': entryId};
      }

      // Handle https://showoff.life/reel/postId
      if (link.contains('/reel/')) {
        final postId = link.split('/reel/').last.split('?').first;
        return {'type': 'reel', 'postId': postId};
      }

      return null;
    } catch (e) {
      print('❌ Error parsing deep link: $e');
      return null;
    }
  }

  /// Handle deep link navigation
  Future<void> _handleDeepLink(String link) async {
    try {
      final deepLinkData = _parseDeepLink(link);

      if (deepLinkData == null) {
        print('⚠️ Could not parse deep link: $link');
        return;
      }

      print('✅ Parsed deep link: $deepLinkData');

      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // If not authenticated, navigate to onboarding first
      if (!authProvider.isAuthenticated) {
        print('⚠️ User not authenticated, navigating to onboarding');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
        return;
      }

      // Navigate based on deep link type
      if (deepLinkData['type'] == 'syt') {
        print('🎭 Navigating to SYT entry: ${deepLinkData['entryId']}');
        // Navigate to talent screen (index 1) which shows SYT entries
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainScreen(
              initialIndex: 1, // Talent screen
              sytEntryId: deepLinkData['entryId'],
            ),
          ),
        );
      } else if (deepLinkData['type'] == 'reel') {
        print('🎬 Navigating to reel: ${deepLinkData['postId']}');
        // Navigate to reel screen (index 0) with post ID
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainScreen(
              initialIndex: 0,
              initialPostId: deepLinkData['postId'],
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Initialize auth provider with timeout
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️ Auth initialization timed out');
        },
      );

      // Initialize notification provider only if user is authenticated
      if (authProvider.isAuthenticated) {
        final notificationProvider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        // Initialize notifications in background (don't await)
        notificationProvider.initialize().catchError((e) {
          print('⚠️ Notification initialization failed: $e');
        });
      }

      // Wait for animation (reduced to 2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate based on auth status
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen(initialIndex: 0)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      print('❌ Error during initialization: $e');
      // On error, go to onboarding
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area with logo and text
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/splash/splash.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // App name
                      const Text(
                        'ShowOff.life',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Loading indicator at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
