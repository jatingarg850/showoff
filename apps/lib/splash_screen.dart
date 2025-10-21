import 'package:flutter/material.dart';

class SplashScreen
    extends
        StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<
    SplashScreen
  >
  createState() => _SplashScreenState();
}

class _SplashScreenState
    extends
        State<
          SplashScreen
        >
    with
        SingleTickerProviderStateMixin {
  late AnimationController
  _animationController;
  late Animation<
    double
  >
  _fadeAnimation;

  @override
  void
  initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 1500,
      ),
      vsync: this,
    );

    _fadeAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
            );

    _animationController.forward();

    // Navigate to next screen after 3 seconds
    Future.delayed(
      const Duration(
        seconds: 3,
      ),
      () {
        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacementNamed(
            '/onboarding',
          );
        }
      },
    );
  }

  @override
  void
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
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
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/splash/splash.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
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
              padding: const EdgeInsets.only(
                bottom: 80,
              ),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<
                        Color
                      >(
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
