class DailyChallenge {
  final String
  id;
  final String
  title;
  final String
  description;
  final String
  emoji;
  final List<
    String
  >
  tips;
  final int
  bonusPoints;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.tips,
    this.bonusPoints = 10,
  });
}

class DailyChallengeManager {
  static final DailyChallengeManager
  _instance = DailyChallengeManager._internal();
  factory DailyChallengeManager() => _instance;
  DailyChallengeManager._internal();

  final List<
    DailyChallenge
  >
  _challenges = [
    const DailyChallenge(
      id: 'golden_hour',
      title: 'Golden Hour Magic',
      description: 'Take a selfie during golden hour (sunrise or sunset)',
      emoji: '🌅',
      tips: [
        'Best time: 1 hour after sunrise or before sunset',
        'Face the light source for warm glow',
        'Use natural lighting for best results',
      ],
      bonusPoints: 15,
    ),
    const DailyChallenge(
      id: 'mirror_selfie',
      title: 'Mirror Mirror',
      description: 'Capture a creative mirror selfie',
      emoji: '🪞',
      tips: [
        'Clean the mirror first',
        'Try different angles',
        'Watch out for reflections',
      ],
    ),
    const DailyChallenge(
      id: 'nature_backdrop',
      title: 'Nature\'s Frame',
      description: 'Take a selfie with nature as your backdrop',
      emoji: '🌿',
      tips: [
        'Find interesting natural backgrounds',
        'Use the rule of thirds',
        'Natural light works best',
      ],
    ),
    const DailyChallenge(
      id: 'black_white',
      title: 'Monochrome Mood',
      description: 'Create a stunning black and white selfie',
      emoji: '⚫',
      tips: [
        'Focus on contrast and shadows',
        'Strong lighting creates drama',
        'Expressions matter more in B&W',
      ],
    ),
    const DailyChallenge(
      id: 'smile_challenge',
      title: 'Smile Bright',
      description: 'Share your brightest, most genuine smile',
      emoji: '😊',
      tips: [
        'Think of something that makes you happy',
        'Smile with your eyes too',
        'Natural smiles are the best',
      ],
    ),
    const DailyChallenge(
      id: 'creative_angle',
      title: 'Angle Explorer',
      description: 'Experiment with unique camera angles',
      emoji: '📐',
      tips: [
        'Try high and low angles',
        'Use leading lines',
        'Break the traditional selfie rules',
      ],
    ),
    const DailyChallenge(
      id: 'outfit_of_day',
      title: 'Style Statement',
      description: 'Show off your outfit of the day',
      emoji: '👗',
      tips: [
        'Include your full outfit',
        'Good lighting shows colors better',
        'Confidence is your best accessory',
      ],
    ),
  ];

  DailyChallenge
  getTodaysChallenge() {
    // Use current day to determine challenge (ensures consistency)
    final today = DateTime.now();
    final dayOfYear = today
        .difference(
          DateTime(
            today.year,
            1,
            1,
          ),
        )
        .inDays;
    final challengeIndex =
        dayOfYear %
        _challenges.length;

    return _challenges[challengeIndex];
  }

  List<
    DailyChallenge
  >
  get allChallenges => List.unmodifiable(
    _challenges,
  );

  DailyChallenge
  getChallengeById(
    String id,
  ) {
    return _challenges.firstWhere(
      (
        challenge,
      ) =>
          challenge.id ==
          id,
    );
  }

  List<
    DailyChallenge
  >
  getUpcomingChallenges({
    int days = 7,
  }) {
    final today = DateTime.now();
    final upcoming =
        <
          DailyChallenge
        >[];

    for (
      int i = 1;
      i <=
          days;
      i++
    ) {
      final futureDate = today.add(
        Duration(
          days: i,
        ),
      );
      final dayOfYear = futureDate
          .difference(
            DateTime(
              futureDate.year,
              1,
              1,
            ),
          )
          .inDays;
      final challengeIndex =
          dayOfYear %
          _challenges.length;
      upcoming.add(
        _challenges[challengeIndex],
      );
    }

    return upcoming;
  }
}
