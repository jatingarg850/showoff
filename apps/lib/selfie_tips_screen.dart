import 'package:flutter/material.dart';

class SelfieTip {
  final String
  title;
  final String
  description;
  final String
  emoji;
  final List<
    String
  >
  steps;
  final String
  category;

  const SelfieTip({
    required this.title,
    required this.description,
    required this.emoji,
    required this.steps,
    required this.category,
  });
}

class SelfieTipsScreen
    extends
        StatefulWidget {
  const SelfieTipsScreen({
    super.key,
  });

  @override
  State<
    SelfieTipsScreen
  >
  createState() => _SelfieTipsScreenState();
}

class _SelfieTipsScreenState
    extends
        State<
          SelfieTipsScreen
        >
    with
        TickerProviderStateMixin {
  late TabController
  _tabController;

  final List<
    String
  >
  categories = [
    'Lighting',
    'Angles',
    'Poses',
    'Editing',
  ];

  final List<
    SelfieTip
  >
  tips = [
    // Lighting Tips
    const SelfieTip(
      title: 'Golden Hour Magic',
      description: 'Use natural golden hour lighting for warm, flattering selfies',
      emoji: '🌅',
      category: 'Lighting',
      steps: [
        'Take selfies 1 hour after sunrise or before sunset',
        'Face the light source directly',
        'Avoid harsh shadows by finding soft, diffused light',
        'Use a reflector (or white paper) to bounce light onto your face',
      ],
    ),
    const SelfieTip(
      title: 'Window Light Wonder',
      description: 'Master indoor lighting using window light',
      emoji: '🪟',
      category: 'Lighting',
      steps: [
        'Position yourself facing a large window',
        'Avoid direct sunlight - use sheer curtains to diffuse',
        'Turn slightly to avoid flat lighting',
        'Use the window as your main light source',
      ],
    ),

    // Angle Tips
    const SelfieTip(
      title: 'The Perfect Angle',
      description: 'Find your most flattering camera angle',
      emoji: '📐',
      category: 'Angles',
      steps: [
        'Hold camera slightly above eye level',
        'Tilt your head slightly down and look up at camera',
        'Try the 45-degree angle for a slimming effect',
        'Experiment with left vs right side of your face',
      ],
    ),
    const SelfieTip(
      title: 'Rule of Thirds',
      description: 'Use composition rules for better selfies',
      emoji: '📏',
      category: 'Angles',
      steps: [
        'Enable grid lines on your camera',
        'Place your eyes on the upper third line',
        'Don\'t always center yourself in the frame',
        'Leave some space above your head',
      ],
    ),

    // Pose Tips
    const SelfieTip(
      title: 'Natural Expressions',
      description: 'Look natural and confident in your selfies',
      emoji: '😊',
      category: 'Poses',
      steps: [
        'Think of something that makes you genuinely happy',
        'Relax your shoulders and jaw',
        'Try the "squinch" - slightly squint your eyes',
        'Practice your smile in the mirror first',
      ],
    ),
    const SelfieTip(
      title: 'Hand Placement',
      description: 'Use your hands to create interesting compositions',
      emoji: '✋',
      category: 'Poses',
      steps: [
        'Rest your chin on your hand for a thoughtful look',
        'Run fingers through your hair naturally',
        'Use hands to frame your face',
        'Keep hand gestures simple and natural',
      ],
    ),

    // Editing Tips
    const SelfieTip(
      title: 'Subtle Enhancement',
      description: 'Edit your selfies without overdoing it',
      emoji: '✨',
      category: 'Editing',
      steps: [
        'Adjust brightness and contrast first',
        'Use subtle filters that enhance, don\'t change',
        'Avoid over-smoothing your skin',
        'Keep edits natural and true to yourself',
      ],
    ),
    const SelfieTip(
      title: 'Color Correction',
      description: 'Fix colors and white balance in your selfies',
      emoji: '🎨',
      category: 'Editing',
      steps: [
        'Adjust white balance if colors look off',
        'Increase vibrance slightly for more life',
        'Use selective editing to enhance eyes',
        'Don\'t over-saturate skin tones',
      ],
    ),
  ];

  @override
  void
  initState() {
    super.initState();
    _tabController = TabController(
      length: categories.length,
      vsync: this,
    );
  }

  @override
  void
  dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Selfie Tips & Tricks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(
            0xFF701CF5,
          ),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(
            0xFF701CF5,
          ),
          tabs: categories
              .map(
                (
                  category,
                ) => Tab(
                  text: category,
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories
            .map(
              (
                category,
              ) => _buildTipsForCategory(
                category,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget
  _buildTipsForCategory(
    String category,
  ) {
    final categoryTips = tips
        .where(
          (
            tip,
          ) =>
              tip.category ==
              category,
        )
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(
        20,
      ),
      itemCount: categoryTips.length,
      itemBuilder:
          (
            context,
            index,
          ) {
            final tip = categoryTips[index];
            return _buildTipCard(
              tip,
            );
          },
    );
  }

  Widget
  _buildTipCard(
    SelfieTip tip,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          15,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color:
                const Color(
                  0xFF701CF5,
                ).withValues(
                  alpha: 0.1,
                ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Center(
            child: Text(
              tip.emoji,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          ),
        ),
        title: Text(
          tip.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          tip.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Steps:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF701CF5,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                ...tip.steps.asMap().entries.map(
                  (
                    entry,
                  ) {
                    final index = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF701CF5,
                              ),
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
