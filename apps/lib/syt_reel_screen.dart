import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';

class SYTReelScreen
    extends
        StatefulWidget {
  final List<
    Map<
      String,
      dynamic
    >
  >
  competitions;
  final int
  initialIndex;

  const SYTReelScreen({
    super.key,
    required this.competitions,
    this.initialIndex = 0,
  });

  @override
  State<
    SYTReelScreen
  >
  createState() => _SYTReelScreenState();
}

class _SYTReelScreenState
    extends
        State<
          SYTReelScreen
        >
    with
        TickerProviderStateMixin {
  final PageController
  _pageController = PageController();

  late AnimationController
  _fadeController;
  late AnimationController
  _scaleController;
  late Animation<
    double
  >
  _fadeAnimation;
  late Animation<
    double
  >
  _scaleAnimation;

  int
  _currentIndex = 0;

  // Track liked, voted and saved states for each reel
  final Map<
    int,
    bool
  >
  _likedReels = {};
  final Map<
    int,
    bool
  >
  _votedReels = {};
  final Map<
    int,
    bool
  >
  _savedReels = {};

  @override
  void
  initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(
        milliseconds: 400,
      ),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeInOut,
              ),
            );

    _scaleAnimation =
        Tween<
              double
            >(
              begin: 0.8,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              ),
            );

    // Start initial animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void
  dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Convert competition data to reel format
  Map<
    String,
    dynamic
  >
  _convertToReelData(
    Map<
      String,
      dynamic
    >
    competition,
  ) => {
    'username': competition['username'],
    'description': 'Competing in ${competition['category']} - Show Your Talent! 🎭',
    'likes': competition['likes'],
    'comments': '${(int.tryParse(competition['likes'].replaceAll('K', '000')) ?? 1000) ~/ 4}',
    'shares': '${(int.tryParse(competition['likes'].replaceAll('K', '000')) ?? 1000) ~/ 10}',
    'bookmarks': '${(int.tryParse(competition['likes'].replaceAll('K', '000')) ?? 1000) ~/ 20}',
    'isAd': false,
    'duration': '00:30',
    'category': competition['category'],
    'gradient': competition['gradient'],
  };

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        onPageChanged:
            (
              index,
            ) {
              setState(
                () {
                  _currentIndex = index;
                },
              );

              // Trigger animations on page change
              _fadeController.reset();
              _scaleController.reset();
              _fadeController.forward();
              _scaleController.forward();
            },
        itemCount: widget.competitions.length,
        itemBuilder:
            (
              context,
              index,
            ) {
              final competition = widget.competitions[index];
              final reelData = _convertToReelData(
                competition,
              );

              return AnimatedBuilder(
                animation: _pageController,
                builder:
                    (
                      context,
                      child,
                    ) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value =
                            _pageController.page! -
                            index;
                        value =
                            (1 -
                                    (value.abs() *
                                        0.3))
                                .clamp(
                                  0.0,
                                  1.0,
                                );
                      }

                      return Transform.scale(
                        scale: Curves.easeOut.transform(
                          value,
                        ),
                        child: Opacity(
                          opacity: value,
                          child: _buildReelItem(
                            reelData,
                            index,
                          ),
                        ),
                      );
                    },
              );
            },
      ),
    );
  }

  Widget
  _buildReelItem(
    Map<
      String,
      dynamic
    >
    reel,
    int index,
  ) {
    return Stack(
      children: [
        // Animated background with competition gradient
        AnimatedContainer(
          duration: const Duration(
            milliseconds: 500,
          ),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  reel['gradient']
                      as List<
                        Color
                      >,
            ),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge(
              [
                _fadeAnimation,
                _scaleAnimation,
              ],
            ),
            builder:
                (
                  context,
                  child,
                ) {
                  final isCurrentReel =
                      index ==
                      _currentIndex;
                  return AnimatedScale(
                    scale: isCurrentReel
                        ? _scaleAnimation.value
                        : 0.95,
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    curve: Curves.elasticOut,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Center(
                        child:
                            TweenAnimationBuilder<
                              double
                            >(
                              duration: const Duration(
                                milliseconds: 800,
                              ),
                              tween: Tween(
                                begin: 0.0,
                                end: 1.0,
                              ),
                              builder:
                                  (
                                    context,
                                    value,
                                    child,
                                  ) {
                                    return Transform.rotate(
                                      angle:
                                          (1 -
                                              value) *
                                          0.1,
                                      child: Transform.scale(
                                        scale:
                                            0.7 +
                                            (0.3 *
                                                value),
                                        child: Opacity(
                                          opacity: value,
                                          child: const Icon(
                                            Icons.play_circle_outline,
                                            color: Colors.white54,
                                            size: 80,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            ),
                      ),
                    ),
                  );
                },
          ),
        ),

        // Top bar with SYT branding
        Positioned(
          top:
              MediaQuery.of(
                context,
              ).padding.top +
              10,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25,
              ),
              color: Colors.black.withValues(
                alpha: 0.7,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'SYT Competition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Back button
        Positioned(
          top:
              MediaQuery.of(
                context,
              ).padding.top +
              20,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(
              context,
            ),
            child: Container(
              padding: const EdgeInsets.all(
                8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.6,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Duration indicator (top left)
        Positioned(
          top:
              MediaQuery.of(
                context,
              ).padding.top +
              20,
          left: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.6,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Text(
              reel['duration'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Right side action buttons with vote button
        Positioned(
          right: 12,
          top:
              MediaQuery.of(
                context,
              ).size.height *
              0.35,
          child:
              TweenAnimationBuilder<
                Offset
              >(
                duration: const Duration(
                  milliseconds: 800,
                ),
                tween: Tween(
                  begin: const Offset(
                    1,
                    0,
                  ),
                  end: Offset.zero,
                ),
                curve: Curves.elasticOut,
                builder:
                    (
                      context,
                      offset,
                      child,
                    ) {
                      return Transform.translate(
                        offset:
                            offset *
                            100,
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 400,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              30,
                            ),
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Like button (regular like functionality)
                              _buildActionButton(
                                'assets/sidereel/like.png',
                                reel['likes'],
                                _likedReels[index] ==
                                        true
                                    ? Colors.red
                                    : Colors.white,
                                onTap: () {
                                  setState(
                                    () {
                                      _likedReels[index] =
                                          !(_likedReels[index] ??
                                              false);
                                    },
                                  );
                                  HapticFeedback.lightImpact();
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              // Vote button (separate voting functionality)
                              _buildVoteButton(
                                reel,
                                index,
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _buildActionButton(
                                'assets/sidereel/comment.png',
                                reel['comments'],
                                Colors.white,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (
                                          context,
                                        ) => const CommentsScreen(),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _buildActionButton(
                                'assets/sidereel/saved.png',
                                reel['bookmarks'],
                                _savedReels[index] ==
                                        true
                                    ? Colors.yellow
                                    : Colors.white,
                                onTap: () {
                                  setState(
                                    () {
                                      _savedReels[index] =
                                          !(_savedReels[index] ??
                                              false);
                                    },
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _buildActionButton(
                                'assets/sidereel/share.png',
                                reel['shares'],
                                Colors.white,
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (
                                          context,
                                        ) => const GiftScreen(),
                                  );
                                },
                                child: Image.asset(
                                  'assets/sidereel/gift.png',
                                  width: 28,
                                  height: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              ),
        ),

        // Bottom user info with SYT competition details
        Positioned(
          left: 16,
          right: 80,
          bottom: 120,
          child:
              TweenAnimationBuilder<
                Offset
              >(
                duration: const Duration(
                  milliseconds: 600,
                ),
                tween: Tween(
                  begin: const Offset(
                    0,
                    1,
                  ),
                  end: Offset.zero,
                ),
                curve: Curves.easeOutBack,
                builder:
                    (
                      context,
                      offset,
                      child,
                    ) {
                      return Transform.translate(
                        offset:
                            offset *
                            50,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info row
                              Row(
                                children: [
                                  // Profile picture
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      gradient: LinearGradient(
                                        colors:
                                            reel['gradient']
                                                as List<
                                                  Color
                                                >,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),

                                  // Username
                                  Text(
                                    reel['username'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),

                                  // SYT Competition badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.amber,
                                          Colors.orange,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'SYT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              // Description with competition info
                              TweenAnimationBuilder<
                                double
                              >(
                                duration: const Duration(
                                  milliseconds: 1000,
                                ),
                                tween: Tween(
                                  begin: 0.0,
                                  end: 1.0,
                                ),
                                builder:
                                    (
                                      context,
                                      value,
                                      child,
                                    ) {
                                      final description =
                                          reel['description']
                                              as String;
                                      final runes = description.runes.toList();
                                      final displayLength =
                                          (runes.length *
                                                  value)
                                              .round();
                                      final safeText =
                                          displayLength >=
                                              runes.length
                                          ? description
                                          : String.fromCharCodes(
                                              runes.take(
                                                displayLength,
                                              ),
                                            );

                                      return Text(
                                        safeText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              ),
        ),

        // Floating action button
        Positioned(
          right: 20,
          bottom: 110,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget
  _buildActionButton(
    String imagePath,
    String count,
    Color iconColor, {
    VoidCallback? onTap,
    bool isVote = false,
  }) {
    return TweenAnimationBuilder<
      double
    >(
      duration: const Duration(
        milliseconds: 400,
      ),
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ),
      builder:
          (
            context,
            value,
            child,
          ) {
            return Transform.scale(
              scale:
                  0.8 +
                  (0.2 *
                      value),
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<
                        double
                      >(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        tween: Tween(
                          begin: 0.0,
                          end: 1.0,
                        ),
                        builder:
                            (
                              context,
                              iconValue,
                              child,
                            ) {
                              return Transform.rotate(
                                angle:
                                    (1 -
                                        iconValue) *
                                    0.2,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      imagePath,
                                      width: 28,
                                      height: 28,
                                      color: iconColor,
                                    ),
                                    if (isVote &&
                                        iconColor ==
                                            Colors.amber)
                                      const Icon(
                                        Icons.how_to_vote,
                                        size: 28,
                                        color: Colors.amber,
                                      ),
                                  ],
                                ),
                              );
                            },
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          count,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget
  _buildVoteButton(
    Map<
      String,
      dynamic
    >
    reel,
    int index,
  ) {
    final hasVoted =
        _votedReels[index] ==
        true;
    final voteCount =
        int.tryParse(
          reel['likes'].replaceAll(
            'K',
            '000',
          ),
        ) ??
        1000;
    final displayVotes = hasVoted
        ? '${(voteCount + 1) ~/ 1000}K'
        : '${voteCount ~/ 1000}K';

    return TweenAnimationBuilder<
      double
    >(
      duration: const Duration(
        milliseconds: 400,
      ),
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ),
      builder:
          (
            context,
            value,
            child,
          ) {
            return Transform.scale(
              scale:
                  0.8 +
                  (0.2 *
                      value),
              child: GestureDetector(
                onTap: () {
                  setState(
                    () {
                      _votedReels[index] =
                          !(_votedReels[index] ??
                              false);
                    },
                  );
                  HapticFeedback.mediumImpact();
                  if (_votedReels[index] ==
                      true) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Voted for ${reel['username']}!',
                        ),
                        backgroundColor: Colors.amber,
                        duration: const Duration(
                          seconds: 2,
                        ),
                      ),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: hasVoted
                        ? Colors.amber.withValues(
                            alpha: 0.2,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<
                        double
                      >(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        tween: Tween(
                          begin: 0.0,
                          end: 1.0,
                        ),
                        builder:
                            (
                              context,
                              iconValue,
                              child,
                            ) {
                              return Transform.rotate(
                                angle:
                                    (1 -
                                        iconValue) *
                                    0.2,
                                child: Icon(
                                  hasVoted
                                      ? Icons.how_to_vote
                                      : Icons.how_to_vote_outlined,
                                  size: 28,
                                  color: hasVoted
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                              );
                            },
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          displayVotes,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        'VOTE',
                        style: TextStyle(
                          color: hasVoted
                              ? Colors.amber
                              : Colors.white70,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }
}
