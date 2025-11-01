import 'package:flutter/material.dart';
import 'services/api_service.dart';

class HallOfFameScreen
    extends
        StatefulWidget {
  const HallOfFameScreen({
    super.key,
  });

  @override
  State<
    HallOfFameScreen
  >
  createState() => _HallOfFameScreenState();
}

class _HallOfFameScreenState
    extends
        State<
          HallOfFameScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _hallOfFameData = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadHallOfFame();
  }

  Future<
    void
  >
  _loadHallOfFame() async {
    try {
      setState(
        () => _isLoading = true,
      );

      // Load last week's winners
      final response = await ApiService.getSYTLeaderboard(
        type: 'weekly',
      );

      if (response['success']) {
        setState(
          () {
            _hallOfFameData =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'] ??
                      [],
                );
            _isLoading = false;
          },
        );
      } else {
        setState(
          () {
            _hallOfFameData = [];
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading Hall of Fame: $e',
      );
      setState(
        () {
          _hallOfFameData = [];
          _isLoading = false;
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Row(
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
                  const Icon(
                    Icons.emoji_events,
                    color: Color(
                      0xFFFFD700,
                    ),
                    size: 28,
                  ),
                  const SizedBox(
                    width: 8,
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
                      'Hall of Fame',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Text(
                    'Last Week\'s Champions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // Top 3 Winners with Crown
            if (!_isLoading &&
                _hallOfFameData.isNotEmpty)
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Golden background
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(
                              0xFFFFD700,
                            ),
                            Color(
                              0xFFFFA500,
                            ),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),

                    // Winners positioned on golden background
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 2nd place
                        if (_hallOfFameData.length >
                            1)
                          _buildHallOfFameUser(
                            _hallOfFameData[1],
                            2,
                          ),
                        // 1st place
                        if (_hallOfFameData.isNotEmpty)
                          _buildHallOfFameUser(
                            _hallOfFameData[0],
                            1,
                          ),
                        // 3rd place
                        if (_hallOfFameData.length >
                            2)
                          _buildHallOfFameUser(
                            _hallOfFameData[2],
                            3,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(
              height: 30,
            ),

            // Hall of Fame List
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
                        0xFF3E98E4,
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
                    : _hallOfFameData.length <=
                          3
                    ? const Center(
                        child: Text(
                          'No additional champions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(
                              20,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.military_tech,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  'Other Champions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount:
                                  _hallOfFameData.length -
                                  3,
                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {
                                    final user =
                                        _hallOfFameData[index +
                                            3];
                                    return _buildHallOfFameItem(
                                      user,
                                      index +
                                          4,
                                    );
                                  },
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

  Widget
  _buildHallOfFameUser(
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
    final avatarSize = isWinner
        ? 70.0
        : 60.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crown for winner
        if (isWinner)
          Column(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(
                  0xFFFFD700,
                ),
                size: 32,
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),

        // Avatar with border
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
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.2,
                ),
                blurRadius: 8,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
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
                            size: 35,
                          );
                        },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        // Name
        Text(
          user['user']?['displayName'] ??
              user['user']?['username'] ??
              'Champion',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        // Score
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.2,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Text(
            user['votesCount']?.toString() ??
                '0',
            style: TextStyle(
              fontSize: isWinner
                  ? 16
                  : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget
  _buildHallOfFameItem(
    Map<
      String,
      dynamic
    >
    user,
    int position,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.2,
          ),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.1,
                  ),
                  blurRadius: 4,
                  offset: const Offset(
                    0,
                    2,
                  ),
                ),
              ],
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: const TextStyle(
                  color: Color(
                    0xFF701CF5,
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
            width: 45,
            height: 45,
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
                              size: 22,
                            );
                          },
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 22,
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
                      'Champion',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${user['user']?['username'] ?? 'champion'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                      0.7,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Score with trophy icon
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(
                  0xFFFFD700,
                ),
                size: 16,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
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
    );
  }
}
