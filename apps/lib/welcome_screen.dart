import 'package:flutter/material.dart';
import 'main_screen.dart';

class WelcomeScreen
    extends
        StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(
              flex: 2,
            ),

            // Welcome title
            const Text(
              'Welcome to Showoff.Life',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Description text
            const Text(
              'Collect coins from votes, gifts, and views. Spin the fortune wheel, redeem in the store, or withdraw cash.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 60,
            ),

            // Continue button positioned in middle
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF6C5CE7,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const MainScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
