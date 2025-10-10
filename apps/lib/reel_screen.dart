import 'package:flutter/material.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';

class ReelScreen
    extends
        StatefulWidget {
  const ReelScreen({
    super.key,
  });

  @override
  State<
    ReelScreen
  >
  createState() => _ReelScreenState();
}

class _ReelScreenState
    extends
        State<
          ReelScreen
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

  @override
  void
  initState() {
    super.initState();

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

  // Sample reel data
  final List<
    Map<
      String,
      dynamic
    >
  >
  _reels = [
    {
      'username': 'Sathon',
      'description': 'A bird flying in the sky soaring high in the sky scouting for its prey....😍',
      'likes': '8976',
      'comments': '4576',
      'shares': '200',
      'bookmarks': '200',
      'isAd': false,
      'duration': '00:15',
    },
    {
      'username': 'Yada',
      'description': 'MEET NEW FRIENDS EVERYDAY',
      'likes': '5432',
      'comments': '2341',
      'shares': '156',
      'bookmarks': '89',
      'isAd': true,
      'duration': '00:30',
    },
    {
      'username': 'Alex',
      'description': 'Amazing sunset view from the mountains 🌅',
      'likes': '12.5K',
      'comments': '892',
      'shares': '445',
      'bookmarks': '1.2K',
      'isAd': false,
      'duration': '00:22',
    },
    {
      'username': 'Maria',
      'description': 'Dancing in the rain! Life is beautiful ☔💃',
      'likes': '9876',
      'comments': '3456',
      'shares': '678',
      'bookmarks': '543',
      'isAd': false,
      'duration': '00:18',
    },
  ];

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
        itemCount: _reels.length,
        itemBuilder:
            (
              context,
              index,
            ) {
              final reel = _reels[index];
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
                            reel,
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
        // Animated background with smooth transitions
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
              colors: reel['isAd']
                  ? [
                      Colors.purple[800]!,
                      Colors.purple[600]!,
                    ]
                  : [
                      Colors.grey[800]!,
                      Colors.grey[600]!,
                    ],
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
                        child: reel['isAd']
                            ? TweenAnimationBuilder<
                                double
                              >(
                                duration: const Duration(
                                  milliseconds: 600,
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
                                        child: Opacity(
                                          opacity: value,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.ads_click,
                                                color: Colors.white54,
                                                size: 60,
                                              ),
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Text(
                                                'Advertisement',
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                              )
                            : TweenAnimationBuilder<
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
                                            child: Icon(
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

        // Top bar
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
              image: const DecorationImage(
                image: AssetImage(
                  'assets/reel/up.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/upreel/search.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 16,
                ),
                Image.asset(
                  'assets/upreel/coment.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 16,
                ),
                Image.asset(
                  'assets/upreel/notbell.png',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ],
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
          left: 20,
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

        // Right side action buttons with staggered animation
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
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/reel/side.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildActionButton(
                                'assets/sidereel/like.png',
                                reel['likes'],
                                Colors.red,
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
                                Colors.white,
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

        // Bottom user info with slide-in animation
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
                                      color: Colors.grey[400],
                                    ),
                                    child: reel['isAd']
                                        ? ClipOval(
                                            child: Image.asset(
                                              'assets/setup/coins.png',
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
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

                                  // Follow/Ads button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: reel['isAd']
                                            ? [
                                                const Color(
                                                  0xFF701CF5,
                                                ),
                                                const Color(
                                                  0xFF8B7ED8,
                                                ),
                                              ]
                                            : [
                                                const Color(
                                                  0xFF701CF5,
                                                ),
                                                const Color.fromRGBO(
                                                  68,
                                                  138,
                                                  255,
                                                  1,
                                                ),
                                              ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    child: Text(
                                      reel['isAd']
                                          ? 'Ads'
                                          : 'Follow',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              // Description with safe typewriter effect
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
                                child: Image.asset(
                                  imagePath,
                                  width: 28,
                                  height: 28,
                                  color: iconColor,
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
}
