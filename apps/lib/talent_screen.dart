import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';
import 'chat_screen.dart';
import 'notification_screen.dart';
import 'syt_reel_screen.dart';
import 'camera_screen.dart';
import 'services/api_service.dart';

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

  final List<
    String
  >
  periods = [
    'Weekly',
  ];

  List<
    Map<
      String,
      dynamic
    >
  >
  _entries = [];
  bool
  _isLoading = true;
  bool
  _hasSubmittedThisWeek = false;

  @override
  void
  initState() {
    super.initState();
    _loadEntries();
    _checkUserWeeklySubmission();
  }

  Future<
    void
  >
  _loadEntries() async {
    try {
      final filter = selectedPeriod.toLowerCase();
      final response = await ApiService.getSYTEntries(
        filter: filter,
      );
      if (response['success']) {
        setState(
          () {
            _entries =
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
        'Error loading SYT entries: $e',
      );
      setState(
        () => _isLoading = false,
      );
    }
  }

  Future<
    void
  >
  _checkUserWeeklySubmission() async {
    try {
      final response = await ApiService.checkUserWeeklySubmission();
      if (response['success']) {
        setState(
          () {
            _hasSubmittedThisWeek =
                response['data']['hasSubmitted'] ??
                false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error checking weekly submission: $e',
      );
      // Default to false if there's an error
      setState(
        () {
          _hasSubmittedThisWeek = false;
        },
      );
    }
  }

  Future<
    void
  >
  _refreshData() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    await Future.wait(
      [
        _loadEntries(),
        _checkUserWeeklySubmission(),
      ],
    );
  }

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
      'gradient': [
        const Color(
          0xFFE8A87C,
        ),
        const Color(
          0xFFC27D38,
        ),
      ],
    },
    {
      'username': '@yuyttt666',
      'category': 'Art',
      'likes': '23624',
      'gradient': [
        const Color(
          0xFF8B4513,
        ),
        const Color(
          0xFFD2691E,
        ),
      ],
    },
    {
      'username': 'Fr',
      'category': 'Dance',
      'likes': '23424',
      'gradient': [
        const Color(
          0xFF1E90FF,
        ),
        const Color(
          0xFF000080,
        ),
      ],
    },
    {
      'username': '@yuyttt666',
      'category': 'Art',
      'likes': '23624',
      'gradient': [
        const Color(
          0xFF228B22,
        ),
        const Color(
          0xFF006400,
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
                          child: Image.asset(
                            'assets/syttop/trophy.png',
                            width: 24,
                            height: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => ChatScreen(
                                      userId: 'talent_user_id',
                                      username: 'talent_user',
                                      displayName: 'Talent User',
                                      isVerified: false,
                                    ),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/syttop/comment.png',
                            width: 24,
                            height: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => const NotificationScreen(),
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/syttop/notification.png',
                            width: 24,
                            height: 24,
                            color: Colors.black,
                          ),
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

            // Message Box - Show only if user hasn't submitted this week
            if (!_hasSubmittedThisWeek)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(
                        0xFF701CF5,
                      ),
                      Color(
                        0xFF74B9FF,
                      ),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(
                    2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                    child: Stack(
                      children: [
                        // White background
                        Positioned.fill(
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        // Subtle background pattern
                        Positioned.fill(
                          child: Opacity(
                            opacity: 1,
                            child: Image.asset(
                              'assets/syt/uploadbg.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Content
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                              0xFF74B9FF,
                                            ),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(
                                          bounds,
                                        ),
                                child: const Text(
                                  'You have not shared your\ntalent to the world',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'Click the button below to showoff',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(
                                        0xFF701CF5,
                                      ),
                                      Color(
                                        0xFF74B9FF,
                                      ),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    25,
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
                                            ) => const CameraScreen(
                                              selectedPath: 'SYT',
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        25,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Show off',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                ),
              ),

            SizedBox(
              height: _hasSubmittedThisWeek
                  ? 0
                  : 20,
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
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<
                                    Color
                                  >(
                                    Color(
                                      0xFF701CF5,
                                    ),
                                  ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refreshData,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _entries.isEmpty
                                  ? 4
                                  : _entries.length,
                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {
                                    // Use loaded entries if available, otherwise use dummy data
                                    final competition =
                                        _entries.isNotEmpty &&
                                            index <
                                                _entries.length
                                        ? {
                                            'username': '@${_entries[index]['user']?['username'] ?? 'user'}',
                                            'category':
                                                _entries[index]['category'] ??
                                                'Other',
                                            'likes':
                                                _entries[index]['likesCount']?.toString() ??
                                                '0',
                                            'gradient':
                                                competitions[index %
                                                    competitions.length]['gradient'],
                                            'entryId': _entries[index]['_id'],
                                            'thumbnailUrl': _entries[index]['thumbnailUrl'],
                                            'videoUrl': _entries[index]['videoUrl'],
                                          }
                                        : competitions[index];

                                    return GestureDetector(
                                      onTap: () {
                                        // Only navigate if we have real entries
                                        if (_entries.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No entries available yet',
                                              ),
                                              duration: Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        // Create real competition data for reel screen
                                        final realCompetitions = _entries
                                            .map(
                                              (
                                                entry,
                                              ) => {
                                                'username': '@${entry['user']?['username'] ?? 'user'}',
                                                'category':
                                                    entry['category'] ??
                                                    'Other',
                                                'likes':
                                                    entry['likesCount']?.toString() ??
                                                    '0',
                                                'gradient':
                                                    competitions[_entries.indexOf(
                                                          entry,
                                                        ) %
                                                        competitions.length]['gradient'],
                                                'entryId': entry['_id'],
                                                'user': entry['user'],
                                                'title': entry['title'],
                                                'description': entry['description'],
                                                'thumbnailUrl': entry['thumbnailUrl'],
                                                'videoUrl': entry['videoUrl'],
                                                '_id': entry['_id'],
                                              },
                                            )
                                            .toList();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => SYTReelScreen(
                                                  competitions: realCompetitions,
                                                  initialIndex: index,
                                                ),
                                          ),
                                        );
                                      },
                                      child: _buildCompetitionCard(
                                        competition,
                                        index,
                                      ),
                                    );
                                  },
                            ),
                          ),
                  ),

                  // Floating Join SYT Button
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => const CameraScreen(
                                    selectedPath: 'SYT',
                                  ),
                            ),
                          );
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
                          'Show Your Talent : SYT',
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
            _isLoading = true;
          },
        );
        _loadEntries();
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
    int index,
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
          // Thumbnail image if available
          if (competition['thumbnailUrl'] !=
              null)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                16,
              ),
              child: Image.network(
                ApiService.getImageUrl(
                  competition['thumbnailUrl'],
                ),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                          color: Colors.black.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      );
                    },
              ),
            )
          else
            // Background pattern/texture fallback
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

          // Dark overlay for text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(
                    alpha: 0.7,
                  ),
                ],
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
                  child: ShaderMask(
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
                                  0xFF74B9FF,
                                ),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                              bounds,
                            ),
                    child: const Text(
                      'In competition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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
