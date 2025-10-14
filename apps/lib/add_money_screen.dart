import 'package:flutter/material.dart';
import 'add_card_screen.dart';

class AddMoneyScreen
    extends
        StatefulWidget {
  const AddMoneyScreen({
    super.key,
  });

  @override
  State<
    AddMoneyScreen
  >
  createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState
    extends
        State<
          AddMoneyScreen
        > {
  final TextEditingController
  _amountController = TextEditingController();
  String
  _selectedAmount = '';

  final List<
    String
  >
  _quickAmounts = [
    '\$20',
    '\$50',
    '\$100',
    '\$200',
  ];

  @override
  void
  dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void
  _selectAmount(
    String amount,
  ) {
    setState(
      () {
        _selectedAmount = amount;
        _amountController.text = amount.substring(
          1,
        ); // Remove $ sign
      },
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Text(
                    'Add money',
                    style: TextStyle(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // Add Card section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const AddCardScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background card image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        child: Image.asset(
                          'assets/addmoney/card.png',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Overlay with + icon and text
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Add Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // Amount label
              const Text(
                'Amount',
                style: TextStyle(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // Amount input field
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // Quick amount buttons
              Row(
                children: _quickAmounts.map(
                  (
                    amount,
                  ) {
                    final isSelected =
                        _selectedAmount ==
                        amount;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        child: GestureDetector(
                          onTap: () => _selectAmount(
                            amount,
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF8B5CF6,
                                      // ignore: deprecated_member_use
                                    ).withOpacity(
                                      0.1,
                                    )
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                amount,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(
                                          0xFF8B5CF6,
                                        )
                                      : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),

              const Spacer(),

              // Top Up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle top up
                    final amount = _amountController.text;
                    if (amount.isNotEmpty) {
                      // Process payment
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Processing payment of \$$amount',
                          ),
                          backgroundColor: const Color(
                            0xFF8B5CF6,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF8B5CF6,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Top Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
