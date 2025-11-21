import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phone_email_auth/phone_email_auth.dart';
import 'forgot_password_screen.dart';
import '../main_screen.dart';
import '../signup_screen.dart';
import '../providers/auth_provider.dart';
import '../services/phone_auth_service.dart';
import '../services/api_service.dart';

class LoginScreen
    extends
        StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<
    LoginScreen
  >
  createState() => _LoginScreenState();
}

class _LoginScreenState
    extends
        State<
          LoginScreen
        > {
  final TextEditingController
  _emailController = TextEditingController();
  final TextEditingController
  _passwordController = TextEditingController();

  bool
  _isPhoneLoginLoading = false;

  @override
  void
  initState() {
    super.initState();
    // Initialize Phone Email Auth
    PhoneAuthService.initialize();
  }

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
              'Login',
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
              width: 40,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF701CF5,
                ),
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            ),

            // Email Address label
            const Text(
              'Email Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Email input field
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
                  controller: _emailController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter your Email Address',
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

            // Password label
            const Text(
              'Enter Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Password input field
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
                    hintText: 'Enter your password',
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
              height: 16,
            ),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // OR divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

            // Phone Login Button
            if (_isPhoneLoginLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              PhoneLoginButton(
                borderRadius: 10,
                buttonColor: const Color(
                  0xFF3E98E4,
                ),
                label: 'Login with Phone',
                onSuccess:
                    (
                      String accessToken,
                      String jwtToken,
                    ) async {
                      if (accessToken.isNotEmpty) {
                        setState(
                          () {
                            _isPhoneLoginLoading = true;
                          },
                        );

                        // Get user info from phone auth
                        final userData = await PhoneAuthService.getUserInfo(
                          accessToken,
                        );

                        if (userData !=
                                null &&
                            mounted) {
                          // Login/Register user with verified phone number
                          try {
                            final response = await ApiService.phoneLogin(
                              phoneNumber:
                                  userData.phoneNumber ??
                                  '',
                              countryCode:
                                  userData.countryCode ??
                                  '',
                              firstName: userData.firstName,
                              lastName: userData.lastName,
                              accessToken: accessToken,
                            );

                            setState(
                              () {
                                _isPhoneLoginLoading = false;
                              },
                            );

                            if (mounted) {
                              if (response['success']) {
                                // Update auth provider
                                final authProvider =
                                    Provider.of<
                                      AuthProvider
                                    >(
                                      context,
                                      listen: false,
                                    );
                                authProvider.updateUser(
                                  response['data']['user'],
                                );

                                // Navigate to main screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (
                                          context,
                                        ) => const MainScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response['message'] ??
                                          'Login failed',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (
                            e
                          ) {
                            setState(
                              () {
                                _isPhoneLoginLoading = false;
                              },
                            );

                            if (mounted) {
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
                          setState(
                            () {
                              _isPhoneLoginLoading = false;
                            },
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to get phone number',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              ),

            const SizedBox(
              height: 24,
            ),

            // Continue button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 16,
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
                onPressed: () async {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter email and password',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final authProvider =
                      Provider.of<
                        AuthProvider
                      >(
                        context,
                        listen: false,
                      );
                  final success = await authProvider.login(
                    emailOrPhone: _emailController.text.trim(),
                    password: _passwordController.text,
                  );

                  if (!mounted) return;

                  if (success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const MainScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          authProvider.error ??
                              'Login failed',
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
                child:
                    Consumer<
                      AuthProvider
                    >(
                      builder:
                          (
                            context,
                            auth,
                            _,
                          ) {
                            if (auth.isLoading) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                        Color
                                      >(
                                        Colors.white,
                                      ),
                                ),
                              );
                            }
                            return const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                    ),
              ),
            ),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to sign up screen
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
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF701CF5,
                      ),
                      decoration: TextDecoration.underline,
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
    );
  }

  @override
  void
  dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
