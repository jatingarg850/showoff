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
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: Image.asset(
                            'assets/navbar/2.png',
                            width: 24,
                            height: 24,
                            color: Colors.black,
                          ),
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
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  // Background stairs image
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 40,
                    bottom: 0,
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

                  // Users positioned above/on the stairs
                  // 2nd place (Jackson - left side, middle height)
                  Positioned(
                    left: 35,
                    top: 75,
                    child: _buildPodiumUser(
                      leaderboardData[1],
                      2,
                    ),
                  ),

                  // 1st place (Eiden - center, highest position)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -3,
                    child: Center(
                      child: _buildPodiumUser(
                        leaderboardData[0],
                        1,
                      ),
                    ),
                  ),

                  // 3rd place (Emma Aria - right side, lowest position)
                  Positioned(
                    right: 35,
                    top: 75,
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
                margin: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  0,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF701CF5,
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
                  padding: const EdgeInsets.all(
                    20,
                  ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
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
    // Make profile pictures bigger with smaller borders
    final ringSize = isWinner
        ? 85.0
        : 70.0;
    final profileSize = isWinner
        ? 75.0
        : 62.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for winner positioned above everything
        if (isWinner)
          Column(
            children: [
              Image.asset(
                'assets/leaderboard2/crown.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ),

        // User avatar with position badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Profile picture with PNG ring border
            SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                children: [
                  // Profile picture - positioned slightly above center to fit better in ring
                  Positioned(
                    left:
                        (ringSize -
                            profileSize) /
                        2,
                    top:
                        (ringSize -
                                profileSize) /
                            2 -
                        5, // Move up by 5px to fit better in ring
                    child: Container(
                      width: profileSize,
                      height: profileSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size:
                              profileSize *
                              0.6,
                        ),
                      ),
                    ),
                  ),
                  // PNG ring border overlay - sized to match container
                  Positioned.fill(
                    child: Image.asset(
                      'assets/leaderboard2/$position.png',
                      width: ringSize,
                      height: ringSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
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
        ),

        // White separator line between items - full width and thicker
        Container(
          height: 2,
          width: double.infinity,
          color: Colors.white.withOpacity(
            0.3,
          ),
          margin: const EdgeInsets.only(
            top: 12,
          ),
        ),
      ],
    );
  }
}
