import 'package:flutter/material.dart';

class LeaderboardScreen
    extends
        StatefulWidget {
  const LeaderboardScreen({
    super.key,
  });

  @override
  State<
    LeaderboardScreen
  >
  createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState
    extends
        State<
          LeaderboardScreen
        > {
  String
  selectedPeriod = 'Weekly';
  final List<
    String
  >
  periods = [
    'Weekly',
    'Monthly',
    'Mega',
  ];

  final List<
    Map<
      String,
      dynamic
    >
  >
  leaderboardData = [
    {
      'name': 'Eiden',
      'score': '2430',
      'username': '@username',
      'position': 1,
      'avatar': 'assets/avatars/eiden.jpg',
      'isWinner': true,
    },
    {
      'name': 'Jackson',
      'score': '847',
      'username': '@username',
      'position': 2,
      'avatar': 'assets/avatars/jackson.jpg',
      'isWinner': false,
    },
    {
      'name': 'Emma Aria',
      'score': '1674',
      'username': '@username',
      'position': 3,
      'avatar': 'assets/avatars/emma.jpg',
      'isWinner': false,
    },
    {
      'name': 'Jati',
      'score': '1124',
      'username': '',
      'position': 4,
      'avatar': 'assets/avatars/sebastian.jpg',
      'isWinner': false,
    },
    {
      'name': 'Jason',
      'score': '875',
      'username': '',
      'position': 5,
      'avatar': 'assets/avatars/jason.jpg',
      'isWinner': false,
    },
    {
      'name': 'Natalie',
      'score': '774',
      'username': '',
      'position': 6,
      'avatar': 'assets/avatars/natalie.jpg',
      'isWinner': false,
    },
    {
      'name': 'Serenity',
      'score': '723',
      'username': '',
      'position': 7,
      'avatar': 'assets/avatars/serenity.jpg',
      'isWinner': false,
    },
    {
      'name': 'Hannah',
      'score': '559',
      'username': '',
      'position': 8,
      'avatar': 'assets/avatars/hannah1.jpg',
      'isWinner': false,
    },
    {
      'name': 'Hannah',
      'score': '559',
      'username': '',
      'position': 9,
      'avatar': 'assets/avatars/hannah2.jpg',
      'isWinner': false,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(
                          context,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
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
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/syttop/back.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/syttop/trophy.png',
                          width: 24,
                          height: 24,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Image.asset(
                          'assets/syttop/comment.png',
                          width: 24,
                          height: 24,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Image.asset(
                          'assets/syttop/notification.png',
                          width: 24,
                          height: 24,
                          color: Colors.black,
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
                children: periods
                    .map(
                      (
                        period,
                      ) => _buildPeriodTab(
                        period,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // Top 3 Winners Podium with Stairs
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: Stack(
                children: [
                  // Background stairs image
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      child: Image.asset(
                        'assets/leaderboard/image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Gradient overlay to maintain the purple theme
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(
                              0xFF701CF5,
                            ).withValues(
                              alpha: 0.7,
                            ),
                            const Color(
                              0xFF8B7ED8,
                            ).withValues(
                              alpha: 0.7,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                  ),

                  // Users positioned on the stairs at specific positions
                  // 2nd place (left side, middle height)
                  Positioned(
                    left: 40,
                    top: 80,
                    child: _buildPodiumUser(
                      leaderboardData[1],
                      2,
                    ),
                  ),

                  // 1st place (center, highest position)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 40,
                    child: Center(
                      child: _buildPodiumUser(
                        leaderboardData[0],
                        1,
                      ),
                    ),
                  ),

                  // 3rd place (right side, lowest position)
                  Positioned(
                    right: 40,
                    top: 100,
                    child: _buildPodiumUser(
                      leaderboardData[2],
                      3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Leaderboard List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: const EdgeInsets.all(
                  20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF8B7ED8,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: ListView.builder(
                  itemCount:
                      leaderboardData.length -
                      3, // Exclude top 3
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                        final user =
                            leaderboardData[index +
                                3]; // Start from 4th position
                        return _buildLeaderboardItem(
                          user,
                          index ==
                              0,
                        );
                      },
                ),
              ),
            ),

            const SizedBox(
              height: 120,
            ), // Space for bottom navigation
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
  _buildPodiumUser(
    Map<
      String,
      dynamic
    >
    user,
    int position,
  ) {
    final isWinner =
        position ==
        1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for winner
        if (isWinner)
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
        if (isWinner)
          const SizedBox(
            height: 4,
          ),

        // User avatar with position badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isWinner
                  ? 70
                  : 55,
              height: isWinner
                  ? 70
                  : 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      position ==
                          1
                      ? Colors.amber
                      : position ==
                            2
                      ? Colors.blue
                      : Colors.green,
                  width: 3,
                ),
                color: Colors.grey[300],
              ),
              child: ClipOval(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: isWinner
                      ? 35
                      : 28,
                ),
              ),
            ),

            // Position badge
            Positioned(
              bottom: -3,
              right: -3,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color:
                      position ==
                          1
                      ? Colors.amber
                      : position ==
                            2
                      ? Colors.blue
                      : Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        // User name
        Text(
          user['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),

        // Score
        Text(
          user['score'],
          style: TextStyle(
            color: isWinner
                ? Colors.amber
                : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isWinner
                ? 18
                : 16,
          ),
        ),

        // Username (only for top 3)
        if (user['username'].isNotEmpty)
          Text(
            user['username'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  Widget
  _buildLeaderboardItem(
    Map<
      String,
      dynamic
    >
    user,
    bool isFirst,
  ) {
    // Determine arrow color based on position trend (green for up, red for down)
    final isUpTrend =
        user['position'] <=
        5; // Top 5 get green arrows

    return Container(
      margin: EdgeInsets.only(
        bottom: isFirst
            ? 0
            : 16,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: ClipOval(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // Name
          Expanded(
            child: Text(
              user['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Score
          Text(
            user['score'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // Triangular arrow indicator (green up or red down)
          Icon(
            isUpTrend
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: isUpTrend
                ? Colors.green
                : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
