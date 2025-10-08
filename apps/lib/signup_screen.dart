import 'package:flutter/material.dart';
import 'phone_signup_screen.dart';
import 'email_signup_screen.dart';
import 'auth/login_screen.dart';

class SignUpScreen
    extends
        StatelessWidget {
  const SignUpScreen({
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
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            children: [
              // Top spacing
              const SizedBox(
                height: 40,
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

              // Continue with mail button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF6C5CE7,
                  ), // Solid Purple
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const EmailSignUpScreen(),
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
                  icon: const Icon(
                    Icons.mail_outline,
                    size: 20,
                  ),
                  label: const Text(
                    'Continue with mail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // Continue with phone button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF74B9FF,
                  ), // Solid Blue
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const PhoneSignUpScreen(),
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
                  icon: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                  ),
                  label: const Text(
                    'Continue with phone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // Continue with Gmail button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF2D3436,
                  ), // Solid Dark Gray
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle Gmail signup
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
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              // Divider line
              Container(
                height: 1,
                width: double.infinity,
                color: const Color(
                  0xFFE0E0E0,
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
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
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(
                          0xFF6C5CE7,
                        ),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(
                          0xFF6C5CE7,
                        ),
                      ),
                    ),
                  ),
                ],
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
