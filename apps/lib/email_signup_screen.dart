import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import 'services/api_service.dart';

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
                    0xFF701CF5,
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
                        0xFF701CF5,
                      ), // Purple
                      Color(
                        0xFF3E98E4,
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
                    0xFF701CF5,
                  ),
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Handle email verification with OTP
                    if (_emailController.text.isNotEmpty) {
                      // Validate email format
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );

                      if (!emailRegex.hasMatch(
                        _emailController.text.trim(),
                      )) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid email address',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (
                              context,
                            ) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        // Send OTP to email
                        final response = await ApiService.sendOTP(
                          email: _emailController.text.trim(),
                        );

                        // Close loading
                        if (context.mounted) {
                          Navigator.pop(
                            context,
                          );
                        }

                        if (response['success']) {
                          // Show OTP verification modal
                          if (context.mounted) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              isDismissible: false,
                              enableDrag: false,
                              builder:
                                  (
                                    context,
                                  ) => OTPVerificationScreen(
                                    email: _emailController.text.trim(),
                                  ),
                            );
                          }
                        } else {
                          // Show error
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response['message'] ??
                                      'Failed to send OTP',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (
                        e
                      ) {
                        // Close loading
                        if (context.mounted) {
                          Navigator.pop(
                            context,
                          );
                        }

                        // Show error
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${e.toString()}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
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
