import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';

class TalentScreen
    extends
        StatefulWidget {
  const TalentScreen({
    super.key,
  });

  @override
  State<
    TalentScreen
  >
  createState() => _TalentScreenState();
}

class _TalentScreenState
    extends
        State<
          TalentScreen
        > {
  String
  selectedPeriod = 'Weekly';
  String
  selectedCategory = 'Dance';

  final List<
    String
  >
  periods = [
    'Weekly',
  ];
  final List<
    String
  >
  categories = [
    'Dance',
    'Art',
    'Music',
    'Acting',
    'Improv',
  ];

  final List<
    Map<
      String,
      dynamic
    >
  >
  competitions = [
    {
      'username': '@james9898',
      'category': 'Dance',
      'likes': '23424',
      'image': 'assets/reel/dance1.jpg',
      'gradient': [
        const Color(
          0xFFD2691E,
        ),
        const Color(
          0xFFDC143C,
        ),
      ],
    },
    {
      'username': '@yuyttt666',
      'category': 'Art',
      'likes': '23624',
      'image': 'assets/reel/art1.jpg',
      'gradient': [
        const Color(
          0xFF20B2AA,
        ),
        const Color(
          0xFF4682B4,
        ),
      ],
    },
    {
      'username': '@james9898',
      'category': 'Dance',
      'likes': '23424',
      'image': 'assets/reel/dance2.jpg',
      'gradient': [
        const Color(
          0xFF1E90FF,
        ),
        const Color(
          0xFF00CED1,
        ),
      ],
    },
    {
      'username': '@yuyttt666',
      'category': 'Art',
      'likes': '23624',
      'image': 'assets/reel/art2.jpg',
      'gradient': [
        const Color(
          0xFF228B22,
        ),
        const Color(
          0xFFDC143C,
        ),
      ],
    },
    {
      'username': '@alex_music',
      'category': 'Music',
      'likes': '18956',
      'image': 'assets/reel/music1.jpg',
      'gradient': [
        const Color(
          0xFF8A2BE2,
        ),
        const Color(
          0xFF4B0082,
        ),
      ],
    },
    {
      'username': '@sara_act',
      'category': 'Acting',
      'likes': '15632',
      'image': 'assets/reel/acting1.jpg',
      'gradient': [
        const Color(
          0xFFDAA520,
        ),
        const Color(
          0xFFFF8C00,
        ),
      ],
    },
  ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (
                          bounds,
                        ) =>
                            const LinearGradient(
                              colors: [
                                Color(
                                  0xFF701CF5,
                                ),
                                Color(
                                  0xFF3E98E4,
                                ),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                              bounds,
                            ),
                    child: const Text(
                      'Show your Talent',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => const LeaderboardScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.black54,
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.black54,
                          size: 20,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.notifications_outlined,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Period Selection
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  ...periods.map(
                    (
                      period,
                    ) => _buildPeriodTab(
                      period,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF701CF5,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Text(
                      'Ends 3days 17hrs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Category Selection
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final category = categories[index];
                      final isSelected =
                          category ==
                          selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              selectedCategory = category;
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            right: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF701CF5,
                                  )
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(
                              25,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Competition Grid with Floating Button
            Expanded(
              child: Stack(
                children: [
                  // Competition Grid
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      120,
                    ),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: competitions.length,
                      itemBuilder:
                          (
                            context,
                            index,
                          ) {
                            final competition = competitions[index];
                            return _buildCompetitionCard(
                              competition,
                            );
                          },
                    ),
                  ),

                  // Floating Join Arena Button
                  Positioned(
                    left: 40,
                    right: 40,
                    bottom: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(
                              0xFF5A9FFF,
                            ),
                            Color(
                              0xFF701CF5,
                            ),
                            Color(
                              0xFF4A7FFF,
                            ),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 10,
                            offset: const Offset(
                              0,
                              4,
                            ),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle join arena
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Show Your Talent (SYT)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildPeriodTab(
    String period,
  ) {
    final isSelected =
        period ==
        selectedPeriod;
    return GestureDetector(
      onTap: () {
        setState(
          () {
            selectedPeriod = period;
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          right: 24,
        ),
        padding: const EdgeInsets.only(
          bottom: 8,
        ),
        decoration: isSelected
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: Column(
          children: [
            Text(
              period,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(
                        0xFF701CF5,
                      )
                    : Colors.black54,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(
                  top: 8,
                ),
                height: 2,
                width: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF3E98E4,
                      ),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildCompetitionCard(
    Map<
      String,
      dynamic
    >
    competition,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          16,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: competition['gradient'],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern/texture
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ),
              color: Colors.black.withValues(
                alpha: 0.3,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // In competition badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.9,
                    ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    'In competition',
                    style: TextStyle(
                      color: Color(
                        0xFF701CF5,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                // User info
                Text(
                  competition['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  competition['category'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // Likes
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      competition['likes'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
