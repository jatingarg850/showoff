import 'package:flutter/material.dart';
import 'main_screen.dart';

class WithdrawalSuccessfulScreen
    extends
        StatelessWidget {
  const WithdrawalSuccessfulScreen({
    super.key,
  });

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(
                flex: 2,
              ),

              // Success title
              const Text(
                'Withdrawal successful',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ),

              // Success message
              const Text(
                'Collect coins from votes, gifts, and views. Spin the fortune wheel, redeem in the store, or withdraw cash.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(
                flex: 2,
              ),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to main screen with wallet tab selected
                    Navigator.of(
                      context,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const MainScreen(
                              initialIndex: 3,
                            ),
                      ),
                      (
                        route,
                      ) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF8B5CF6,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),
                    elevation: 0,
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

              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
