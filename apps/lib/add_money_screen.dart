import 'package:flutter/material.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedAmount = '';

  // Static coin packages
  final List<Map<String, dynamic>> _coinPackages = [
    {'amount': '10', 'coins': '10', 'display': '₹10'},
    {'amount': '20', 'coins': '20', 'display': '₹20'},
    {'amount': '50', 'coins': '50', 'display': '₹50'},
    {'amount': '100', 'coins': '100', 'display': '₹100'},
    {'amount': '200', 'coins': '200', 'display': '₹200'},
    {'amount': '500', 'coins': '500', 'display': '₹500'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount;
    });
  }

  void _handleGooglePlayPurchase() {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Purchase Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully purchased ₹$amount coins!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add Money',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Amount label
              const Text(
                'Amount (INR)',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Amount input field
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),

              const SizedBox(height: 20),

              // Quick amount buttons - First row (5 buttons)
              Row(
                children: _coinPackages.sublist(0, 5).map((package) {
                  final isSelected = _selectedAmount == package['amount'];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _selectAmount(package['amount']),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF8B5CF6),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                package['display'],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                package['display'],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Quick amount buttons - Second row (2 larger buttons)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectAmount('200'),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: _selectedAmount == '200'
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedAmount == '200'
                              ? Border.all(
                                  color: const Color(0xFF8B5CF6),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹200 Coins',
                              style: TextStyle(
                                color: _selectedAmount == '200'
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹200',
                              style: TextStyle(
                                color: _selectedAmount == '200'
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectAmount('500'),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: _selectedAmount == '500'
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedAmount == '500'
                              ? Border.all(
                                  color: const Color(0xFF8B5CF6),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹500 Coins',
                              style: TextStyle(
                                color: _selectedAmount == '500'
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹500',
                              style: TextStyle(
                                color: _selectedAmount == '500'
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Conversion info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '1 INR = 1 Coin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Google Play button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleGooglePlayPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/google_play_logo.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.shopping_cart, size: 24);
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Buy with Google Play',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
