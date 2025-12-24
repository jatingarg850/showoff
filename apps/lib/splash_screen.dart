import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Initialize auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

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

      // Wait for animation
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Check for deep link from intent
      String? initialPostId;
      try {
        // Get the intent data from the platform channel
        // This will be set by Android when the app is launched from a deep link
        final Map<String, dynamic>? intentData =
            WidgetsBinding.instance.window.defaultRouteName != '/'
            ? _parseDeepLink(WidgetsBinding.instance.window.defaultRouteName)
            : null;

        if (intentData != null && intentData['postId'] != null) {
          initialPostId = intentData['postId'];
          print('🔗 Deep link detected: $initialPostId');
        }
      } catch (e) {
        print('⚠️ Error parsing deep link: $e');
      }

      // Navigate based on auth status
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                MainScreen(initialIndex: 0, initialPostId: initialPostId),
          ),
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

  Map<String, dynamic>? _parseDeepLink(String route) {
    // Parse deep link format: /reel/{postId}
    if (route.contains('/reel/')) {
      final postId = route.split('/reel/').last;
      return {'postId': postId};
    }
    return null;
  }

  @override
  void dispose() {
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
