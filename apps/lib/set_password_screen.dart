import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_setup/profile_picture_screen.dart';
import 'providers/auth_provider.dart';

class SetPasswordScreen
    extends
        StatefulWidget {
  final String?
  email;
  final String?
  phone;
  final String?
  countryCode;

  const SetPasswordScreen({
    super.key,
    this.email,
    this.phone,
    this.countryCode,
  });

  @override
  State<
    SetPasswordScreen
  >
  createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState
    extends
        State<
          SetPasswordScreen
        > {
  final TextEditingController
  _passwordController = TextEditingController();
  final TextEditingController
  _confirmPasswordController = TextEditingController();
  bool
  _isPasswordVisible = false;
  bool
  _isConfirmPasswordVisible = false;
  bool
  _isPasswordValid = false;
  bool
  _doPasswordsMatch = false;

  @override
  void
  initState() {
    super.initState();
    _passwordController.addListener(
      _validatePassword,
    );
    _confirmPasswordController.addListener(
      _validatePassword,
    );
  }

  @override
  void
  dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void
  _validatePassword() {
    setState(
      () {
        _isPasswordValid =
            _passwordController.text.length >=
            8;
        _doPasswordsMatch =
            _passwordController.text ==
            _confirmPasswordController.text;
      },
    );
  }

  bool
  get _canProceed =>
      _isPasswordValid &&
      _doPasswordsMatch &&
      _confirmPasswordController.text.isNotEmpty;

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
              'Set Password',
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

            // Password label
            const Text(
              'Password',
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
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(
                      16,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            _isPasswordVisible = !_isPasswordVisible;
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16,
                        ),
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // Password requirements
            Row(
              children: [
                Icon(
                  _isPasswordValid
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 16,
                  color: _isPasswordValid
                      ? Colors.green
                      : Colors.grey[400],
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  'At least 8 characters',
                  style: TextStyle(
                    color: _isPasswordValid
                        ? Colors.green
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

            // Confirm Password label
            const Text(
              'Confirm Password',
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
                  obscureText: !_isConfirmPasswordVisible,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(
                      16,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16,
                        ),
                        child: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // Password match indicator
            if (_confirmPasswordController.text.isNotEmpty)
              Row(
                children: [
                  Icon(
                    _doPasswordsMatch
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: _doPasswordsMatch
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _doPasswordsMatch
                        ? 'Passwords match'
                        : 'Passwords do not match',
                    style: TextStyle(
                      color: _doPasswordsMatch
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
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
                color: _canProceed
                    ? const Color(
                        0xFF701CF5,
                      )
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: _canProceed
                    ? () async {
                        final authProvider =
                            Provider.of<
                              AuthProvider
                            >(
                              context,
                              listen: false,
                            );

                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (
                                context,
                              ) => const Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<
                                        Color
                                      >(
                                        Color(
                                          0xFF701CF5,
                                        ),
                                      ),
                                ),
                              ),
                        );

                        // Generate temporary username and display name
                        final timestamp = DateTime.now().millisecondsSinceEpoch;
                        final tempUsername = 'user$timestamp';

                        // Register user
                        final success = await authProvider.register(
                          username: tempUsername,
                          displayName: 'User',
                          password: _passwordController.text,
                          email: widget.email,
                          phone:
                              widget.phone !=
                                  null
                              ? '${widget.countryCode}${widget.phone}'
                              : null,
                        );

                        if (!mounted) return;
                        Navigator.pop(
                          context,
                        ); // Close loading dialog

                        if (success) {
                          // Navigate to profile picture setup
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => const ProfilePictureScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider.error ??
                                    'Registration failed',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
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
}
