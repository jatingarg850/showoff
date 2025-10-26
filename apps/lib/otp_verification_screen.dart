import 'package:flutter/material.dart';
import 'dart:async';
import 'set_password_screen.dart';
import 'services/api_service.dart';

class OTPVerificationScreen
    extends
        StatefulWidget {
  final String
  phoneNumber;
  final String
  countryCode;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<
    OTPVerificationScreen
  >
  createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState
    extends
        State<
          OTPVerificationScreen
        >
    with
        SingleTickerProviderStateMixin {
  final List<
    TextEditingController
  >
  _otpControllers = List.generate(
    6,
    (
      index,
    ) => TextEditingController(),
  );
  final List<
    FocusNode
  >
  _focusNodes = List.generate(
    6,
    (
      index,
    ) => FocusNode(),
  );

  Timer?
  _timer;
  int
  _remainingTime = 20;
  bool
  _hasError = false;
  late AnimationController
  _shakeController;
  late Animation<
    double
  >
  _shakeAnimation;

  @override
  void
  initState() {
    super.initState();
    _startTimer();

    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(
        milliseconds: 500,
      ),
      vsync: this,
    );
    _shakeAnimation =
        Tween<
              double
            >(
              begin: 0,
              end: 10,
            )
            .chain(
              CurveTween(
                curve: Curves.elasticIn,
              ),
            )
            .animate(
              _shakeController,
            )
          ..addStatusListener(
            (
              status,
            ) {
              if (status ==
                  AnimationStatus.completed) {
                _shakeController.reverse();
              }
            },
          );
  }

  void
  _startTimer() {
    _timer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (
        timer,
      ) {
        if (_remainingTime >
            0) {
          setState(
            () {
              _remainingTime--;
            },
          );
        } else {
          timer.cancel();
        }
      },
    );
  }

  void
  _resendOTP() async {
    try {
      // Send OTP again
      final response = await ApiService.sendOTP(
        phone: widget.phoneNumber,
        countryCode: widget.countryCode,
      );

      if (response['success']) {
        setState(
          () {
            _remainingTime = 20;
          },
        );
        _startTimer();
        // Clear all OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        // Show resend message
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'OTP code resent successfully',
              ),
              backgroundColor: Color(
                0xFF701CF5,
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ??
                    'Failed to resend OTP',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (
      e
    ) {
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
  }

  void
  _onOTPChanged(
    String value,
    int index,
  ) {
    // Clear error state when user types
    if (_hasError) {
      setState(
        () {
          _hasError = false;
        },
      );
    }

    if (value.isNotEmpty &&
        index <
            5) {
      _focusNodes[index +
              1]
          .requestFocus();
    } else if (value.isEmpty &&
        index >
            0) {
      _focusNodes[index -
              1]
          .requestFocus();
    }

    // Check if all fields are filled
    bool allFilled = _otpControllers.every(
      (
        controller,
      ) => controller.text.isNotEmpty,
    );
    if (allFilled) {
      // Auto-verify when all fields are filled
      _verifyOTP();
    }
  }

  void
  _verifyOTP() async {
    String otp = _otpControllers
        .map(
          (
            controller,
          ) => controller.text,
        )
        .join();
    if (otp.length ==
        6) {
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
        // Verify OTP with backend
        final response = await ApiService.verifyOTP(
          phone: widget.phoneNumber,
          countryCode: widget.countryCode,
          otp: otp,
        );

        // Close loading
        if (context.mounted)
          Navigator.pop(
            context,
          );

        if (response['success']) {
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Phone number verified successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Navigate to password setup
          if (context.mounted) {
            Navigator.of(
              context,
            ).pop(); // Close OTP modal
            Navigator.of(
              context,
            ).push(
              MaterialPageRoute(
                builder:
                    (
                      context,
                    ) => SetPasswordScreen(
                      phone: widget.phoneNumber,
                      countryCode: widget.countryCode,
                    ),
              ),
            );
          }
        } else {
          // Trigger shake animation and show error state
          setState(
            () {
              _hasError = true;
            },
          );
          _shakeController.forward(
            from: 0,
          );

          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();

          // Show error
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ??
                      'Invalid OTP',
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
        if (context.mounted)
          Navigator.pop(
            context,
          );

        // Trigger shake animation
        setState(
          () {
            _hasError = true;
          },
        );
        _shakeController.forward(
          from: 0,
        );

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
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Container(
      height:
          MediaQuery.of(
            context,
          ).size.height *
          0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            20,
          ),
          topRight: Radius.circular(
            20,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(
                bottom: 20,
              ),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            ),

            // OTP Title
            const Text(
              'OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Underline
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 24,
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

            // Description
            const Text(
              'Enter the OTP code sent to your email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            // Phone number or email
            Text(
              widget.countryCode.isEmpty
                  ? widget
                        .phoneNumber // Show email if no country code
                  : '${widget.countryCode}${widget.phoneNumber}', // Show phone with country code
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(
                  0xFF701CF5,
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // OTP Input Fields with shake animation
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder:
                  (
                    context,
                    child,
                  ) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeAnimation.value,
                        0,
                      ),
                      child: child,
                    );
                  },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (
                    index,
                  ) {
                    return Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        gradient: LinearGradient(
                          colors: _hasError
                              ? [
                                  Colors.red,
                                  Colors.red.shade700,
                                ]
                              : [
                                  const Color(
                                    0xFF701CF5,
                                  ), // Purple
                                  const Color(
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
                            6,
                          ),
                        ),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _hasError
                                ? Colors.red
                                : Colors.black,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.all(
                              0,
                            ),
                          ),
                          onChanged:
                              (
                                value,
                              ) => _onOTPChanged(
                                value,
                                index,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Timer
            Text(
              '0:${_remainingTime.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // Resend and Use another number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No code? ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap:
                      _remainingTime ==
                          0
                      ? _resendOTP
                      : null,
                  child: Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          _remainingTime ==
                              0
                          ? const Color(
                              0xFF701CF5,
                            )
                          : Colors.grey,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          _remainingTime ==
                              0
                          ? const Color(
                              0xFF701CF5,
                            )
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).pop(); // Go back to phone input
              },
              child: const Text(
                'Use another number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(
                    0xFF701CF5,
                  ),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(
                    0xFF701CF5,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF701CF5,
                  ),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void
  dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
