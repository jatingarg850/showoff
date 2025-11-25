import 'package:flutter/material.dart';
import 'phone_signup_screen.dart';
import 'email_signup_screen.dart';
import 'auth/signin_choice_screen.dart';
import 'services/google_auth_service.dart';
import 'account_setup/display_name_screen.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 40),

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
                margin: const EdgeInsets.only(top: 8, bottom: 40),
                height: 3,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF701CF5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Continue with mail button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF701CF5), // Solid Purple
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmailSignUpScreen(),
                      ),
                    );
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
                  icon: const Icon(Icons.mail_outline, size: 20),
                  label: const Text(
                    'Continue with mail',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Continue with phone button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3E98E4), // Solid Blue
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneSignUpScreen(),
                      ),
                    );
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
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  label: const Text(
                    'Continue with phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Continue with Gmail button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3436), // Solid Dark Gray
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF701CF5),
                            ),
                          ),
                        );
                      },
                    );

                    try {
                      // Sign up with Google
                      final result = await GoogleAuthService.signInWithGoogle();

                      // Close loading dialog
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      if (result != null) {
                        // Save token
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('auth_token', result['token']);
                        await prefs.setString('user_id', result['user']['id']);
                        await prefs.setString(
                          'username',
                          result['user']['username'],
                        );

                        print('✅ Token saved');

                        // Check if user already exists and profile is complete
                        final isProfileComplete =
                            result['user']['isProfileComplete'] ?? false;

                        if (context.mounted) {
                          if (isProfileComplete) {
                            // User already exists with complete profile - go to reels
                            print(
                              '✅ Existing user with complete profile, navigating to reels...',
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            // New user or incomplete profile - go to account setup
                            print(
                              '📝 New user or incomplete profile, navigating to account setup...',
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const DisplayNameScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      } else {
                        // Show error
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Google sign-up failed. Please try again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (error) {
                      // Close loading dialog
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      print('❌ Error: $error');

                      // Show error
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${error.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  label: const Text(
                    'Continue with Gmail',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Divider line
              Container(
                height: 1,
                width: double.infinity,
                color: const Color(0xFFE0E0E0),
              ),

              const SizedBox(height: 32),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInChoiceScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF701CF5),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF701CF5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
