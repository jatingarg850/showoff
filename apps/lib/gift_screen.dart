import 'package:flutter/material.dart';

class GiftScreen
    extends
        StatefulWidget {
  const GiftScreen({
    super.key,
  });

  @override
  State<
    GiftScreen
  >
  createState() => _GiftScreenState();
}

class _GiftScreenState
    extends
        State<
          GiftScreen
        > {
  int
  selectedGiftIndex = -1;

  final List<
    Map<
      String,
      dynamic
    >
  >
  gifts = [
    {
      'value': 5,
      'icon': 'assets/gift/5.png',
    },
    {
      'value': 10,
      'icon': 'assets/gift/10.png',
    },
    {
      'value': 20,
      'icon': 'assets/gift/20.png',
    },
    {
      'value': 50,
      'icon': 'assets/gift/50.png',
    },
    {
      'value': 70,
      'icon': 'assets/gift/70.png',
    },
    {
      'value': 500,
      'icon': 'assets/gift/500.png',
    },
  ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Container(
      height:
          MediaQuery.of(
            context,
          ).size.height *
          0.4,
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
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(
              top: 12,
            ),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                2,
              ),
            ),
          ),

          // Header with Gift title and balance
          Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gift',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/setup/coins.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '500',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gift options horizontal scroll
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gifts.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final gift = gifts[index];
                    final isSelected =
                        selectedGiftIndex ==
                        index;

                    return GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            selectedGiftIndex = index;
                          },
                        );
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(
                          right: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue[50]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: isSelected
                                ? 2
                                : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Gift icon
                            Image.asset(
                              gift['icon'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            // Gift value
                            Text(
                              '${gift['value']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
            ),
          ),

          const Spacer(),

          // Send gift button
          Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedGiftIndex !=
                        -1
                    ? () {
                        // Handle gift sending
                        final selectedGift = gifts[selectedGiftIndex];
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sent gift worth ${selectedGift['value']} coins!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(
                          context,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedGiftIndex !=
                          -1
                      ? const Color(
                          0xFF6C5CE7,
                        )
                      : Colors.grey[300],
                  foregroundColor:
                      selectedGiftIndex !=
                          -1
                      ? Colors.white
                      : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: Text(
                  selectedGiftIndex !=
                          -1
                      ? 'Send Gift (${gifts[selectedGiftIndex]['value']} coins)'
                      : 'Select a Gift',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
