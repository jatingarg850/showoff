import 'package:flutter/material.dart';
import 'services/api_service.dart';

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
  List<
    Map<
      String,
      dynamic
    >
  >
  _plans = [];
  bool
  _isLoading = true;
  String?
  _currentPlanId;

  @override
  void
  initState() {
    super.initState();
    _loadPlans();
    _loadCurrentSubscription();
  }

  Future<
    void
  >
  _loadPlans() async {
    try {
      final response = await ApiService.getSubscriptionPlans();
      if (response['success']) {
        setState(
          () {
            _plans =
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
      }
    } catch (
      e
    ) {
      print(
        'Error loading plans: $e',
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  Future<
    void
  >
  _loadCurrentSubscription() async {
    try {
      final response = await ApiService.getMySubscription();
      if (response['success'] &&
          response['data'] !=
              null) {
        setState(
          () {
            _currentPlanId = response['data']['plan']?['_id'];
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'No active subscription: $e',
      );
    }
  }

  Future<
    void
  >
  _subscribeToPlan(
    String planId,
    String planName,
  ) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (
              context,
            ) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
      );

      final response = await ApiService.subscribeToPlan(
        planId: planId,
        billingCycle: 'monthly',
        paymentMethod: 'coins',
      );

      Navigator.pop(
        context,
      ); // Close loading dialog

      if (response['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully subscribed to $planName!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Reload subscription status
        await _loadCurrentSubscription();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Failed to subscribe',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (
      e
    ) {
      Navigator.pop(
        context,
      ); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
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
                child: _plans.isEmpty
                    ? const Center(
                        child: Text(
                          'No plans available',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : PageView(
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
                        children: _plans
                            .map(
                              (
                                plan,
                              ) => _buildSubscriptionCard(
                                planId: plan['_id'],
                                planName:
                                    plan['name']?.toUpperCase() ??
                                    'PLAN',
                                price: '\$${plan['price']?['monthly'] ?? 0}',
                                description:
                                    plan['description'] ??
                                    '',
                                features:
                                    List<
                                      String
                                    >.from(
                                      plan['highlightedFeatures'] ??
                                          [],
                                    ),
                                buttonText:
                                    _currentPlanId ==
                                        plan['_id']
                                    ? 'Current Plan'
                                    : 'Subscribe',
                                isCurrentPlan:
                                    _currentPlanId ==
                                    plan['_id'],
                              ),
                            )
                            .toList(),
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
                    _plans.length,
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
    required String planId,
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
              color: isCurrentPlan
                  ? Colors.grey
                  : const Color(
                      0xFF8B5CF6,
                    ),
              borderRadius: BorderRadius.circular(
                28,
              ),
            ),
            child: ElevatedButton(
              onPressed: isCurrentPlan
                  ? null
                  : () => _subscribeToPlan(
                      planId,
                      planName,
                    ),
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
