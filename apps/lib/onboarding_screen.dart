import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'auth/login_screen.dart';

class OnboardingScreen
    extends
        StatefulWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  State<
    OnboardingScreen
  >
  createState() => _OnboardingScreenState();
}

class _OnboardingScreenState
    extends
        State<
          OnboardingScreen
        > {
  final PageController
  _pageController = PageController();
  int
  _currentPage = 0;

  final List<
    OnboardingData
  >
  _onboardingData = [
    OnboardingData(
      image: 'assets/onboarding/1.png',
      title: 'Earn Coins, Unlock Rewards',
      description: 'Collect coins from votes, gifts, and views. Spin the fortune wheel, redeem in the store, or withdraw cash.',
    ),
    OnboardingData(
      image: 'assets/onboarding/2.png',
      title: 'Join Arena Competitions',
      description: 'Battle weekly, monthly, and mega challenges. Get votes, climb leaderboards, and win badges',
    ),
    OnboardingData(
      image: 'assets/onboarding/3.png',
      title: 'Create & Show Off Your Talent',
      description: 'Upload short videos, photos, or join daily challenges to showcase your skills.',
    ),
  ];

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
            // Main content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged:
                    (
                      index,
                    ) {
                      setState(
                        () {
                          _currentPage = index;
                        },
                      );
                    },
                itemCount: _onboardingData.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      return _buildOnboardingPage(
                        _onboardingData[index],
                      );
                    },
              ),
            ),

            // Page indicators
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (
                    index,
                  ) => _buildPageIndicator(
                    index,
                  ),
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  // Sign In button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  context,
                                ) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6C5CE7,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            28,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  context,
                                ) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF74B9FF,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            28,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildOnboardingPage(
    OnboardingData data,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                height: 300,
              ),
            ),
          ),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(
            height: 16,
          ),

          // Description
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(
                0xFF666666,
              ),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget
  _buildPageIndicator(
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(
            milliseconds: 300,
          ),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        width:
            index ==
                _currentPage
            ? 24
            : 8,
        height: 8,
        decoration: BoxDecoration(
          color:
              index ==
                  _currentPage
              ? const Color(
                  0xFF6C5CE7,
                )
              : const Color(
                  0xFFDDDDDD,
                ),
          borderRadius: BorderRadius.circular(
            4,
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String
  image;
  final String
  title;
  final String
  description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
