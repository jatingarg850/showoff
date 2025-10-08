import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';

class EmailSignUpScreen
    extends
        StatefulWidget {
  const EmailSignUpScreen({
    super.key,
  });

  @override
  State<
    EmailSignUpScreen
  >
  createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState
    extends
        State<
          EmailSignUpScreen
        > {
  final TextEditingController
  _emailController = TextEditingController();

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
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top spacing
              const SizedBox(
                height: 20,
              ),

              // Illustration
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/signup/image.png',
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),

              // Title
              const Text(
                'Sign Up',
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
                  bottom: 40,
                ),
                height: 3,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF6C5CE7,
                  ),
                  borderRadius: BorderRadius.circular(
                    2,
                  ),
                ),
              ),

              // Enter Email label
              const Text(
                'Enter Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // Email input field
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(
                        0xFF6C5CE7,
                      ), // Purple
                      Color(
                        0xFF74B9FF,
                      ), // Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(
                    2,
                  ), // Border width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Sathonpro@gmail.com',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(
                          0xFF999999,
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              // Continue button
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
                    // Handle email verification
                    if (_emailController.text.isNotEmpty) {
                      // Show OTP verification bottom sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                        backgroundColor: Colors.transparent,
                        builder:
                            (
                              BuildContext context,
                            ) {
                              return OTPVerificationScreen(
                                phoneNumber: _emailController.text,
                                countryCode: '', // No country code for email
                              );
                            },
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your email address',
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

              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void
  dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
