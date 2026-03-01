import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'new_password_screen.dart';
import '../main_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isSignIn;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    this.isSignIn = false,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _timer;
  int _seconds = 20;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOTP() async {
    try {
      // Extract phone number and country code from phoneNumber
      // Format: +1234567890
      String countryCode = '';
      String phone = '';

      if (widget.phoneNumber.startsWith('+')) {
        String withoutPlus = widget.phoneNumber.substring(1);

        // Try to match country code
        if (withoutPlus.startsWith('358')) {
          countryCode = '+358';
          phone = withoutPlus.substring(3);
        } else if (withoutPlus.length > 2 &&
            (withoutPlus.startsWith('1') || withoutPlus.startsWith('7'))) {
          countryCode = '+${withoutPlus.substring(0, 1)}';
          phone = withoutPlus.substring(1);
        } else if (withoutPlus.length > 2) {
          countryCode = '+${withoutPlus.substring(0, 2)}';
          phone = withoutPlus.substring(2);
        }
      }

      final response = await ApiService.sendOTP(
        phone: phone,
        countryCode: countryCode,
      );

      if (response['success']) {
        setState(() {
          _seconds = 20;
        });
        _startTimer();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to resend OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifySignInOTP(String otp) async {
    try {
      // Extract phone number and country code from phoneNumber
      // Format: +1234567890
      String countryCode = '';
      String phone = '';

      if (widget.phoneNumber.startsWith('+')) {
        String withoutPlus = widget.phoneNumber.substring(1);

        // Try to match country code
        if (withoutPlus.startsWith('358')) {
          countryCode = '+358';
          phone = withoutPlus.substring(3);
        } else if (withoutPlus.length > 2 &&
            (withoutPlus.startsWith('1') || withoutPlus.startsWith('7'))) {
          countryCode = '+${withoutPlus.substring(0, 1)}';
          phone = withoutPlus.substring(1);
        } else if (withoutPlus.length > 2) {
          countryCode = '+${withoutPlus.substring(0, 2)}';
          phone = withoutPlus.substring(2);
        }
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Step 1: Verify OTP with backend
      final verifyResponse = await ApiService.verifyOTP(
        phone: phone,
        countryCode: countryCode,
        otp: otp,
      );

      if (!verifyResponse['success']) {
        // Close loading
        if (context.mounted) {
          Navigator.pop(context);
        }

        // Show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verifyResponse['message'] ?? 'Invalid OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Clear OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        return;
      }

      // Step 2: Sign in with phone OTP (creates/finds user and returns token)
      final signInResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/signin-phone-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'countryCode': countryCode}),
      );

      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      final signInData = jsonDecode(signInResponse.body);

      if (signInData['success']) {
        // Save token and user data
        final token = signInData['data']['token'];

        await StorageService.saveToken(token);
        await StorageService.saveUser(signInData['data']['user']);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate to main screen
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      } else {
        // Check if account not found
        if (signInData['code'] == 'ACCOUNT_NOT_FOUND') {
          // Show dialog asking user to sign up
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Account Not Found'),
                content: const Text(
                  'No account found with this phone number. Please sign up first.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to phone input
                    },
                    child: const Text('Go Back'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to phone input
                      Navigator.pop(context); // Go back to signin choice
                      // Navigate to signup
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Show generic error
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(signInData['message'] ?? 'Sign-in failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.isSignIn ? 'Verify Phone' : 'Forgot password',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Underline
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 32),
              height: 3,
              width: widget.isSignIn ? 100 : 120,
              decoration: BoxDecoration(
                color: const Color(0xFF701CF5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Phone Number label
            Text(
              widget.isSignIn ? 'Phone Number' : 'Email Address',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // Phone/Email display field
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
              ),
              child: Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // OTP Bottom Sheet
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // OTP Title
                    const Text(
                      'OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // OTP Description
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: widget.isSignIn
                                ? 'Enter the OTP code sent to your phone\n'
                                : 'Enter the OTP code sent to your email\n',
                          ),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(
                              color: Color(0xFF701CF5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF701CF5),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Timer
                    Text(
                      '0:${_seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resend and Use another number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No code? ',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: _seconds == 0 ? _resendOTP : null,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _seconds == 0
                                  ? const Color(0xFF701CF5)
                                  : Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Use another number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF701CF5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF701CF5),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          String otp = _controllers.map((c) => c.text).join();
                          if (otp.length == 6) {
                            if (widget.isSignIn) {
                              // Verify OTP with backend for sign-in
                              await _verifySignInOTP(otp);
                            } else {
                              // Navigate to new password screen for forgot password
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NewPasswordScreen(),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter complete OTP'),
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
                            borderRadius: BorderRadius.circular(28),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
