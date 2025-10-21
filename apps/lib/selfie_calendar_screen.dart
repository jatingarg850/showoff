import 'package:flutter/material.dart';
import 'models/selfie_streak_manager.dart';
import 'models/daily_challenges.dart';

class SelfieCalendarScreen
    extends
        StatefulWidget {
  const SelfieCalendarScreen({
    super.key,
  });

  @override
  State<
    SelfieCalendarScreen
  >
  createState() => _SelfieCalendarScreenState();
}

class _SelfieCalendarScreenState
    extends
        State<
          SelfieCalendarScreen
        > {
  final SelfieStreakManager
  _streakManager = SelfieStreakManager();
  final DailyChallengeManager
  _challengeManager = DailyChallengeManager();

  DateTime
  _selectedMonth = DateTime.now();

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
          'Selfie Calendar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month selector
          _buildMonthSelector(),

          // Calendar grid
          Expanded(
            child: _buildCalendarGrid(),
          ),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget
  _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(
                () {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month -
                        1,
                  );
                },
              );
            },
            icon: const Icon(
              Icons.chevron_left,
              size: 30,
            ),
          ),
          Text(
            '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            onPressed: () {
              final nextMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month +
                    1,
              );
              if (nextMonth.isBefore(
                DateTime.now().add(
                  const Duration(
                    days: 30,
                  ),
                ),
              )) {
                setState(
                  () {
                    _selectedMonth = nextMonth;
                  },
                );
              }
            },
            icon: const Icon(
              Icons.chevron_right,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month +
          1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final firstWeekday =
        firstDayOfMonth.weekday %
        7; // 0 = Sunday

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children:
                [
                      'Sun',
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                    ]
                    .map(
                      (
                        day,
                      ) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(
            height: 10,
          ),

          // Calendar days
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final dayNumber =
                        index -
                        firstWeekday +
                        1;

                    if (dayNumber <
                            1 ||
                        dayNumber >
                            daysInMonth) {
                      return const SizedBox(); // Empty cell
                    }

                    final date = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month,
                      dayNumber,
                    );
                    final isCompleted = _streakManager.isDateCompleted(
                      date,
                    );
                    final isToday = _isSameDay(
                      date,
                      DateTime.now(),
                    );
                    final isFuture = date.isAfter(
                      DateTime.now(),
                    );

                    return _buildCalendarDay(
                      dayNumber,
                      isCompleted,
                      isToday,
                      isFuture,
                      date,
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildCalendarDay(
    int day,
    bool isCompleted,
    bool isToday,
    bool isFuture,
    DateTime date,
  ) {
    Color backgroundColor;
    Color textColor;
    Widget? icon;

    if (isFuture) {
      backgroundColor = Colors.grey[100]!;
      textColor = Colors.grey[400]!;
    } else if (isCompleted) {
      backgroundColor = const Color(
        0xFF4CAF50,
      );
      textColor = Colors.white;
      icon = const Icon(
        Icons.check,
        color: Colors.white,
        size: 12,
      );
    } else if (isToday) {
      backgroundColor = const Color(
        0xFF701CF5,
      );
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey[600]!;
      icon = const Icon(
        Icons.close,
        color: Colors.grey,
        size: 12,
      );
    }

    return GestureDetector(
      onTap: isFuture
          ? null
          : () => _showDayDetails(
              date,
              isCompleted,
            ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            8,
          ),
          border: isToday
              ? Border.all(
                  color: const Color(
                    0xFF701CF5,
                  ),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (icon !=
                null) ...[
              const SizedBox(
                height: 2,
              ),
              icon,
            ],
          ],
        ),
      ),
    );
  }

  Widget
  _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            const Color(
              0xFF4CAF50,
            ),
            'Completed',
            Icons.check,
          ),
          _buildLegendItem(
            Colors.grey[200]!,
            'Missed',
            Icons.close,
          ),
          _buildLegendItem(
            const Color(
              0xFF701CF5,
            ),
            'Today',
            Icons.today,
          ),
          _buildLegendItem(
            Colors.grey[100]!,
            'Future',
            Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget
  _buildLegendItem(
    Color color,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              6,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color:
                color ==
                    Colors.grey[100]
                ? Colors.grey[400]
                : Colors.white,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void
  _showDayDetails(
    DateTime date,
    bool isCompleted,
  ) {
    final challenge = _challengeManager.getTodaysChallenge(); // In real app, get challenge for specific date

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (
            context,
          ) => Container(
            height:
                MediaQuery.of(
                  context,
                ).size.height *
                0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  20,
                ),
                topRight: Radius.circular(
                  20,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(
                          2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // Date header
                  Text(
                    '${_getMonthName(date.month)} ${date.day}, ${date.year}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(
                              0xFF4CAF50,
                            ).withValues(
                              alpha: 0.1,
                            )
                          : Colors.red.withValues(
                              alpha: 0.1,
                            ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      isCompleted
                          ? 'Selfie Completed ✅'
                          : 'Selfie Missed ❌',
                      style: TextStyle(
                        color: isCompleted
                            ? const Color(
                                0xFF4CAF50,
                              )
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // Challenge details
                  Text(
                    'Challenge: ${challenge.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  if (isCompleted) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            const Color(
                              0xFF4CAF50,
                            ).withValues(
                              alpha: 0.1,
                            ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Color(
                              0xFF4CAF50,
                            ),
                            size: 32,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Great job completing your daily selfie!',
                            style: TextStyle(
                              color: Color(
                                0xFF4CAF50,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  String
  _getMonthName(
    int month,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month -
        1];
  }

  bool
  _isSameDay(
    DateTime date1,
    DateTime date2,
  ) {
    return date1.year ==
            date2.year &&
        date1.month ==
            date2.month &&
        date1.day ==
            date2.day;
  }
}
