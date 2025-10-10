import 'package:flutter/material.dart';

class NewPasswordScreen
    extends
        StatefulWidget {
  const NewPasswordScreen({
    super.key,
  });

  @override
  State<
    NewPasswordScreen
  >
  createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState
    extends
        State<
          NewPasswordScreen
        > {
  final TextEditingController
  _passwordController = TextEditingController();
  final TextEditingController
  _confirmPasswordController = TextEditingController();

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'New Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Underline
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 32,
              ),
              height: 3,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF701CF5,
                ),
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            ),

            // Enter New Password label
            const Text(
              'Enter New Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // New Password input field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF701CF5,
                    ),
                    Color(
                      0xFF3E98E4,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(
                  2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter your New password',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(
                      16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Re-enter New Password label
            const Text(
              'Re-enter New Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Confirm Password input field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF701CF5,
                    ),
                    Color(
                      0xFF3E98E4,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(
                  2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your New password',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(
                      16,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Continue button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 40,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF701CF5,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_passwordController.text.trim().isNotEmpty &&
                      _confirmPasswordController.text.trim().isNotEmpty) {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      // Password reset successful
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password reset successful!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Navigate back to login or main screen
                      Navigator.popUntil(
                        context,
                        (
                          route,
                        ) => route.isFirst,
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Passwords do not match',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill in both password fields',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
          ],
        ),
      ),
    );
  }

  @override
  void
  dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
