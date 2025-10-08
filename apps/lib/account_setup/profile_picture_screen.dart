import 'package:flutter/material.dart';
import 'display_name_screen.dart';

class ProfilePictureScreen
    extends
        StatefulWidget {
  const ProfilePictureScreen({
    super.key,
  });

  @override
  State<
    ProfilePictureScreen
  >
  createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState
    extends
        State<
          ProfilePictureScreen
        > {
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
                widthFactor: 0.0, // 0% progress (1 of 4 steps)
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF6C5CE7,
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
              'Profile Picture',
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
              width: 140,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF6C5CE7,
                ),
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            ),

            // Subtitle
            const Text(
              'Upload a picture of yourself',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 60,
            ),

            // Profile picture placeholder
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(
                        0xFF6C5CE7,
                      ), // Purple
                      Color(
                        0xFF74B9FF,
                      ), // Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 60,
            ),

            // Take a photo button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 16,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle take photo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(
                    0xFF6C5CE7,
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.camera_alt,
                  color: Color(
                    0xFF6C5CE7,
                  ),
                ),
                label: const Text(
                  'Take a photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF6C5CE7,
                    ),
                  ),
                ),
              ),
            ),

            // Choose from gallery button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 60,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle choose from gallery
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(
                    0xFF74B9FF,
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.photo_library,
                  color: Color(
                    0xFF74B9FF,
                  ),
                ),
                label: const Text(
                  'Choose from gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF74B9FF,
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
                bottom: 16,
              ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const DisplayNameScreen(),
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
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Skip button
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to main app
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account setup completed!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
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
}
