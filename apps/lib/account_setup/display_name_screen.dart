import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'interests_screen.dart';
import '../services/api_service.dart';

class DisplayNameScreen
    extends
        StatefulWidget {
  const DisplayNameScreen({
    super.key,
  });

  @override
  State<
    DisplayNameScreen
  >
  createState() => _DisplayNameScreenState();
}

class _DisplayNameScreenState
    extends
        State<
          DisplayNameScreen
        > {
  final TextEditingController
  _usernameController = TextEditingController();
  final TextEditingController
  _displayNameController = TextEditingController();

  bool
  _isChecking = false;
  bool?
  _isAvailable;
  List<
    String
  >
  _suggestions = [];
  Timer?
  _debounce;

  @override
  void
  initState() {
    super.initState();
    _usernameController.addListener(
      _onUsernameChanged,
    );
    _displayNameController.addListener(
      _onDisplayNameChanged,
    );
  }

  void
  _onDisplayNameChanged() {
    // Trigger rebuild when display name changes
    setState(
      () {},
    );
  }

  void
  _onUsernameChanged() {
    if (_debounce?.isActive ??
        false)
      _debounce!.cancel();
    _debounce = Timer(
      const Duration(
        milliseconds: 500,
      ),
      () {
        if (_usernameController.text.isNotEmpty) {
          _checkUsername(
            _usernameController.text,
          );
        } else {
          setState(
            () {
              _isAvailable = null;
              _suggestions = [];
            },
          );
        }
      },
    );
  }

  Future<
    void
  >
  _checkUsername(
    String username,
  ) async {
    setState(
      () {
        _isChecking = true;
      },
    );

    try {
      final response = await ApiService.checkUsername(
        username,
      );

      setState(
        () {
          _isChecking = false;
          _isAvailable =
              response['available'] ??
              false;
          _suggestions =
              response['suggestions'] !=
                  null
              ? List<
                  String
                >.from(
                  response['suggestions'],
                )
              : [];
        },
      );
    } catch (
      e
    ) {
      setState(
        () {
          _isChecking = false;
          _isAvailable = null;
        },
      );
    }
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
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  4,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5, // 50% progress (2 of 4 steps)
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF701CF5,
                    ),
                    borderRadius: BorderRadius.circular(
                      4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Title
            const Text(
              'Username',
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
                bottom: 16,
              ),
              height: 3,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF701CF5,
                ),
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            ),

            // Subtitle
            const Text(
              'Choose your unique username (lowercase, no spaces)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Username label
            const Text(
              'Username',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Username input
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  28,
                ),
                gradient: LinearGradient(
                  colors:
                      _isAvailable ==
                          false
                      ? [
                          Colors.red,
                          Colors.red.shade700,
                        ]
                      : _isAvailable ==
                            true
                      ? [
                          Colors.green,
                          Colors.green.shade700,
                        ]
                      : [
                          const Color(
                            0xFF701CF5,
                          ),
                          const Color(
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
                ), // Border width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    26,
                  ),
                ),
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  inputFormatters: [
                    // Only allow lowercase letters, numbers, and underscores
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        r'[a-z0-9_]',
                      ),
                    ),
                    // Convert to lowercase automatically
                    LowerCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'username (lowercase, no spaces)',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: _isChecking
                        ? const Padding(
                            padding: EdgeInsets.all(
                              12,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : _isAvailable ==
                              true
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : _isAvailable ==
                              false
                        ? const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          )
                        : null,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // Status message
            if (_isAvailable ==
                false)
              const Text(
                'Username already taken',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (_isAvailable ==
                true)
              const Text(
                'Username is available!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),

            // Suggestions
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Suggestions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions.map(
                  (
                    suggestion,
                  ) {
                    return GestureDetector(
                      onTap: () {
                        _usernameController.text = suggestion;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(
                                0xFF701CF5,
                              ).withOpacity(
                                0.1,
                              ),
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFF701CF5,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(
                              0xFF701CF5,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],

            const SizedBox(
              height: 32,
            ),

            // Display Name label
            const Text(
              'Display Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // Display Name input
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  28,
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
                    26,
                  ),
                ),
                child: TextField(
                  controller: _displayNameController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Your name (e.g., John Doe)',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'This is your public display name (can contain spaces, capitals)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
                onPressed:
                    _isAvailable ==
                            true &&
                        _displayNameController.text.trim().isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  context,
                                ) => InterestsScreen(
                                  username: _usernameController.text.trim(),
                                  displayName: _displayNameController.text.trim(),
                                ),
                          ),
                        );
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

  @override
  void
  dispose() {
    _debounce?.cancel();
    _usernameController.removeListener(
      _onUsernameChanged,
    );
    _displayNameController.removeListener(
      _onDisplayNameChanged,
    );
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
}

// Custom text formatter to convert input to lowercase
class LowerCaseTextFormatter
    extends
        TextInputFormatter {
  @override
  TextEditingValue
  formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
