import 'package:flutter/material.dart';
import 'dart:async';
import 'new_password_screen.dart';

class OTPScreen
    extends
        StatefulWidget {
  final String
  email;

  const OTPScreen({
    super.key,
    required this.email,
  });

  @override
  State<
    OTPScreen
  >
  createState() => _OTPScreenState();
}

class _OTPScreenState
    extends
        State<
          OTPScreen
        > {
  final List<
    TextEditingController
  >
  _controllers = List.generate(
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
  _seconds = 20;

  @override
  void
  initState() {
    super.initState();
    _startTimer();
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
        if (_seconds >
            0) {
          setState(
            () {
              _seconds--;
            },
          );
        } else {
          timer.cancel();
        }
      },
    );
  }

  void
  _resendOTP() {
    setState(
      () {
        _seconds = 20;
      },
    );
    _startTimer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'OTP resent successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );
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
              'Forgot password',
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
                  0xFF6C5CE7,
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

            // Email display field
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF6C5CE7,
                    ),
                    Color(
                      0xFF74B9FF,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(
                  2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    14,
                  ),
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
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
                  topLeft: Radius.circular(
                    24,
                  ),
                  topRight: Radius.circular(
                    24,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(
                      0,
                      -5,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  32,
                ),
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

                    const SizedBox(
                      height: 16,
                    ),

                    // OTP Description
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Enter the OTP code sent to your email\n',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: Color(
                                0xFF6C5CE7,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // OTP Input Fields
                    Row(
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
                              border: Border.all(
                                color: const Color(
                                  0xFF6C5CE7,
                                ),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
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
                              onChanged:
                                  (
                                    value,
                                  ) {
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
                                  },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // Timer
                    Text(
                      '0:${_seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              _seconds ==
                                  0
                              ? _resendOTP
                              : null,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  _seconds ==
                                      0
                                  ? const Color(
                                      0xFF6C5CE7,
                                    )
                                  : Colors.grey,
                              decoration: TextDecoration.underline,
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
                        Navigator.pop(
                          context,
                        );
                      },
                      child: const Text(
                        'Use another number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(
                            0xFF6C5CE7,
                          ),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 32,
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
                          String otp = _controllers
                              .map(
                                (
                                  c,
                                ) => c.text,
                              )
                              .join();
                          if (otp.length ==
                              6) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => const NewPasswordScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter complete OTP',
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
