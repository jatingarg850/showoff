import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VotingReelScreen
    extends
        StatefulWidget {
  final Map<
    String,
    dynamic
  >
  competition;

  const VotingReelScreen({
    super.key,
    required this.competition,
  });

  @override
  State<
    VotingReelScreen
  >
  createState() => _VotingReelScreenState();
}

class _VotingReelScreenState
    extends
        State<
          VotingReelScreen
        >
    with
        TickerProviderStateMixin {
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

  bool
  hasVoted = false;
  int
  voteCount = 0;

  @override
  void
  initState() {
    super.initState();

    // Parse initial vote count
    voteCount =
        int.tryParse(
          widget.competition['likes']
              .replaceAll(
                'K',
                '000',
              )
              .replaceAll(
                '.',
                '',
              ),
        ) ??
        0;

    _fadeController = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ),
      vsync: this,
    );

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

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void
  dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void
  _handleVote() {
    if (!hasVoted) {
      setState(
        () {
          hasVoted = true;
          voteCount += 1;
        },
      );

      HapticFeedback.mediumImpact();

      // Show vote confirmation
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Voted for ${widget.competition['username']}!',
          ),
          backgroundColor: const Color(
            0xFF701CF5,
          ),
          duration: const Duration(
            seconds: 2,
          ),
        ),
      );
    }
  }

  String
  _formatVoteCount(
    int count,
  ) {
    if (count >=
        1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background with gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    widget.competition['gradient']
                        as List<
                          Color
                        >,
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(
                          context,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(
                            8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(
                              alpha: 0.5,
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

                      // SYT Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(
                            20,
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
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Play icon
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),

                            // Category
                            Text(
                              widget.competition['category'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom section with user info and vote button
                Container(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(
                          alpha: 0.8,
                        ),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // User info
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors:
                                    widget.competition['gradient']
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
                              size: 24,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.competition['username'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Competing in ${widget.competition['category']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vote count
                          Column(
                            children: [
                              Icon(
                                hasVoted
                                    ? Icons.how_to_vote
                                    : Icons.how_to_vote_outlined,
                                color: hasVoted
                                    ? Colors.amber
                                    : Colors.white,
                                size: 24,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _formatVoteCount(
                                  voteCount,
                                ),
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

                      const SizedBox(
                        height: 20,
                      ),

                      // Vote button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: hasVoted
                              ? null
                              : _handleVote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasVoted
                                ? Colors.grey[600]
                                : const Color(
                                    0xFF701CF5,
                                  ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                28,
                              ),
                            ),
                            elevation: hasVoted
                                ? 0
                                : 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasVoted
                                    ? Icons.check_circle
                                    : Icons.how_to_vote,
                                size: 24,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                hasVoted
                                    ? 'Voted!'
                                    : 'Vote for this talent',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // SYT info text
                      Text(
                        'Show Your Talent - Vote for your favorite performers!',
                        textAlign: TextAlign.center,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
