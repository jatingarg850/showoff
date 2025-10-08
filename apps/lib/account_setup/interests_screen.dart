import 'package:flutter/material.dart';
import 'bio_screen.dart';

class InterestsScreen
    extends
        StatefulWidget {
  const InterestsScreen({
    super.key,
  });

  @override
  State<
    InterestsScreen
  >
  createState() => _InterestsScreenState();
}

class _InterestsScreenState
    extends
        State<
          InterestsScreen
        > {
  final List<
    String
  >
  _interests = [
    'Music',
    'Sports',
    'Art',
    'Technology',
    'Travel',
    'Food',
    'Fashion',
    'Gaming',
    'Photography',
    'Reading',
    'Movies',
    'Fitness',
    'Dancing',
    'Cooking',
    'Nature',
  ];

  final List<
    String
  >
  _selectedInterests = [];

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
                  2,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75, // 75% progress (3 of 4 steps)
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF6C5CE7,
                    ),
                    borderRadius: BorderRadius.circular(
                      2,
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
              'Interests',
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

            // Subtitle
            const Text(
              'Select up to 5 interests',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Interests grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _interests.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final interest = _interests[index];
                      final isSelected = _selectedInterests.contains(
                        interest,
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              if (isSelected) {
                                _selectedInterests.remove(
                                  interest,
                                );
                              } else if (_selectedInterests.length <
                                  5) {
                                _selectedInterests.add(
                                  interest,
                                );
                              }
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF6C5CE7,
                                  )
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(
                                      0xFF6C5CE7,
                                    )
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              25,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ),

            // Continue button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 40,
              ),
              decoration: BoxDecoration(
                color: _selectedInterests.isNotEmpty
                    ? const Color(
                        0xFF6C5CE7,
                      )
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: _selectedInterests.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (
                                  context,
                                ) => const BioScreen(),
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
}
