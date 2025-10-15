import 'package:flutter/material.dart';

class SubscriptionScreen
    extends
        StatefulWidget {
  const SubscriptionScreen({
    super.key,
  });

  @override
  State<
    SubscriptionScreen
  >
  createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends
        State<
          SubscriptionScreen
        > {
  final PageController
  _pageController = PageController();
  int
  _currentPage = 0;

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(
                0xFF8B5CF6,
              ),
              Color(
                0xFF7C3AED,
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(
                        context,
                      ),
                    ),
                  ],
                ),
              ),

              // Title and subtitle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Get Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'Unlock all the power of this mobile tool and enjoy digital experience like never before!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              // Subscription cards with PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged:
                      (
                        index,
                      ) {
                        setState(
                          () {
                            _currentPage = index;
                          },
                        );
                      },
                  children: [
                    _buildSubscriptionCard(
                      planName: 'BASIC',
                      price: '\$0',
                      description: 'Start free, join weekly contests, earn coins, and unlock the core ShowOff.life experience.',
                      features: [
                        'Upload 1 video per week in the Weekly Showcase',
                        'Cast 1 vote per day (1 coin deducted, 1 coin given to creator)',
                        '1 free Fortune Wheel spin/day',
                        'Ads appear every 5-7 Reels',
                        'Earn coins from uploads, votes, ads, and referrals',
                        'Limited ad rewards: watch up to 5 ads/day for coins',
                      ],
                      buttonText: 'Start 7-day free trial',
                      isCurrentPlan: true,
                    ),
                    _buildSubscriptionCard(
                      planName: 'COMMON',
                      price: '\$4.99',
                      description: 'Enhanced features for regular users who want more engagement and fewer restrictions.',
                      features: [
                        'Upload 3 videos per week in the Weekly Showcase',
                        'Cast 5 votes per day with reduced coin cost',
                        '3 free Fortune Wheel spins/day',
                        'Ads appear every 10-12 Reels',
                        'Priority support and faster processing',
                        'Unlimited ad rewards: watch unlimited ads for coins',
                        'Access to exclusive community features',
                      ],
                      buttonText: 'Upgrade to Common',
                      isCurrentPlan: false,
                    ),
                    _buildSubscriptionCard(
                      planName: 'ADVANCED',
                      price: '\$9.99',
                      description: 'Premium experience with maximum features, no ads, and exclusive content access.',
                      features: [
                        'Unlimited video uploads in Weekly Showcase',
                        'Unlimited voting with bonus coins for creators',
                        '10 free Fortune Wheel spins/day',
                        'Completely ad-free experience',
                        'VIP support and instant processing',
                        'Exclusive premium content and early access',
                        'Advanced analytics and insights',
                        'Custom profile badges and themes',
                      ],
                      buttonText: 'Go Premium',
                      isCurrentPlan: false,
                    ),
                  ],
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (
                      index,
                    ) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        width:
                            _currentPage ==
                                index
                            ? 32
                            : 8,
                        height:
                            _currentPage ==
                                index
                            ? 4
                            : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage ==
                                  index
                              ? Colors.white
                              : Colors.white54,
                          borderRadius:
                              _currentPage ==
                                  index
                              ? BorderRadius.circular(
                                  2,
                                )
                              : null,
                          shape:
                              _currentPage ==
                                  index
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Terms text
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'By placing this order, you agree to the ',
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(
                        text: '. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildSubscriptionCard({
    required String planName,
    required String price,
    required String description,
    required List<
      String
    >
    features,
    required String buttonText,
    required bool isCurrentPlan,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(
                      0xFF8B5CF6,
                    ),
                    width: 3,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    planName,
                    style: const TextStyle(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (isCurrentPlan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF8B5CF6,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Text(
                    'Current plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // Plan title and description
          Text(
            planName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // Price
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFF8B5CF6,
                    ),
                  ),
                ),
                const TextSpan(
                  text: '/month',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // Features list
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: features
                    .map(
                      (
                        feature,
                      ) => _buildFeatureItem(
                        feature,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // Action button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(
                0xFF8B5CF6,
              ),
              borderRadius: BorderRadius.circular(
                28,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    28,
                  ),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildFeatureItem(
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check,
            color: Color(
              0xFF10B981,
            ),
            size: 20,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
