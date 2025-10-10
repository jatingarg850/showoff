import 'package:flutter/material.dart';
import 'interests_screen.dart';

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
              'Display Name',
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
              width: 120,
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
              'Choose a unique username',
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
                    26,
                  ),
                ),
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter your unique username',
                    hintStyle: TextStyle(
                      fontSize: 16,
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
                onPressed: () {
                  if (_usernameController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (
                              context,
                            ) => const InterestsScreen(),
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
    );
  }

  @override
  void
  dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
