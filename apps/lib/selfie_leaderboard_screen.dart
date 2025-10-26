import 'package:flutter/material.dart';
import 'services/api_service.dart';

class SelfieLeaderboardScreen
    extends
        StatefulWidget {
  const SelfieLeaderboardScreen({
    super.key,
  });

  @override
  State<
    SelfieLeaderboardScreen
  >
  createState() => _SelfieLeaderboardScreenState();
}

class _SelfieLeaderboardScreenState
    extends
        State<
          SelfieLeaderboardScreen
        > {
  String
  selectedPeriod = 'Daily';
  List<
    Map<
      String,
      dynamic
    >
  >
  _leaderboardData = [];
  bool
  _isLoading = true;

  final List<
    String
  >
  periods = [
    'Daily',
    'Weekly',
    'Monthly',
  ];

  @override
  void
  initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<
    void
  >
  _loadLeaderboard() async {
    try {
      setState(
        () => _isLoading = true,
      );

      final response = await ApiService.getDailySelfieLeaderboard(
        type: selectedPeriod.toLowerCase(),
      );

      if (response['success']) {
        setState(
          () {
            _leaderboardData =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'],
                );
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading selfie leaderboard: $e',
      );
      setState(
        () => _isLoading = false,
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
                          'Selfie Challenge',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.local_fire_department,
                    color: Color(
                      0xFFFF6B35,
                    ),
                    size: 28,
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

            // Top 3 Winners
            if (!_isLoading &&
                _leaderboardData.isNotEmpty)
              _buildTopThree(),

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
                        0xFFFF6B35,
                      ),
                      Color(
                        0xFFFF8A50,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<
                                Color
                              >(
                                Colors.white,
                              ),
                        ),
                      )
                    : _leaderboardData.length <=
                          3
                    ? const Center(
                        child: Text(
                          'No additional entries',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(
                          20,
                        ),
                        itemCount:
                            _leaderboardData.length -
                            3,
                        itemBuilder:
                            (
                              context,
                              index,
                            ) {
                              final user =
                                  _leaderboardData[index +
                                      3];
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
        _loadLeaderboard();
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
                        0xFFFF6B35,
                      ),
                      Color(
                        0xFFFF8A50,
                      ),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildTopThree() {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (_leaderboardData.length >
              1)
            _buildPodiumUser(
              _leaderboardData[1],
              2,
            ),
          // 1st place
          if (_leaderboardData.isNotEmpty)
            _buildPodiumUser(
              _leaderboardData[0],
              1,
            ),
          // 3rd place
          if (_leaderboardData.length >
              2)
            _buildPodiumUser(
              _leaderboardData[2],
              3,
            ),
        ],
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
    final height =
        position ==
            1
        ? 160.0
        : position ==
              2
        ? 120.0
        : 100.0;
    final avatarSize =
        position ==
            1
        ? 60.0
        : 50.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crown for winner
        if (isWinner)
          const Icon(
            Icons.emoji_events,
            color: Color(
              0xFFFFD700,
            ),
            size: 24,
          ),

        const SizedBox(
          height: 8,
        ),

        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  position ==
                      1
                  ? const Color(
                      0xFFFFD700,
                    )
                  : position ==
                        2
                  ? const Color(
                      0xFFC0C0C0,
                    )
                  : const Color(
                      0xFFCD7F32,
                    ),
              width: 3,
            ),
          ),
          child: ClipOval(
            child:
                user['user']?['profilePicture'] !=
                        null &&
                    user['user']['profilePicture'].isNotEmpty
                ? Image.network(
                    ApiService.getImageUrl(
                      user['user']['profilePicture'],
                    ),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 30,
                          );
                        },
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 30,
                  ),
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        // Name
        Text(
          user['user']?['displayName'] ??
              user['user']?['username'] ??
              'User',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        // Score with fire icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Color(
                0xFFFF6B35,
              ),
              size: 14,
            ),
            const SizedBox(
              width: 2,
            ),
            Text(
              user['streak']?.toString() ??
                  user['votesCount']?.toString() ??
                  '0',
              style: TextStyle(
                fontSize: isWinner
                    ? 16
                    : 14,
                fontWeight: FontWeight.bold,
                color: const Color(
                  0xFFFF6B35,
                ),
              ),
            ),
          ],
        ),

        // Podium
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  position ==
                      1
                  ? [
                      const Color(
                        0xFFFFD700,
                      ),
                      const Color(
                        0xFFFFA500,
                      ),
                    ]
                  : position ==
                        2
                  ? [
                      const Color(
                        0xFFC0C0C0,
                      ),
                      const Color(
                        0xFF999999,
                      ),
                    ]
                  : [
                      const Color(
                        0xFFCD7F32,
                      ),
                      const Color(
                        0xFF8B4513,
                      ),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(
                8,
              ),
              topRight: Radius.circular(
                8,
              ),
            ),
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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
    final position =
        _leaderboardData.indexOf(
          user,
        ) +
        1;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Row(
            children: [
              // Position
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      color: Color(
                        0xFFFF6B35,
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: ClipOval(
                  child:
                      user['user']?['profilePicture'] !=
                              null &&
                          user['user']['profilePicture'].isNotEmpty
                      ? Image.network(
                          ApiService.getImageUrl(
                            user['user']['profilePicture'],
                          ),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                );
                              },
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              // Name and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['user']?['displayName'] ??
                          user['user']?['username'] ??
                          'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '@${user['user']?['username'] ?? 'user'}',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Score with fire icon
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    user['streak']?.toString() ??
                        user['votesCount']?.toString() ??
                        '0',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Separator line
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.white.withValues(
            alpha: 0.3,
          ),
          margin: const EdgeInsets.only(
            top: 8,
          ),
        ),
      ],
    );
  }
}
