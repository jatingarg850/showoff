import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';

class GiftScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const GiftScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  int selectedGiftIndex = -1;
  bool _isSending = false;

  final List<Map<String, dynamic>> gifts = [
    {'value': 5, 'icon': 'assets/gift/5.png'},
    {'value': 10, 'icon': 'assets/gift/10.png'},
    {'value': 20, 'icon': 'assets/gift/20.png'},
    {'value': 50, 'icon': 'assets/gift/50.png'},
    {'value': 70, 'icon': 'assets/gift/70.png'},
    {'value': 500, 'icon': 'assets/gift/500.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive height - allow up to 60% of screen for scrollable content
    final minHeight = 320.0;
    final maxHeight = screenHeight * 0.6;
    final calculatedHeight = screenHeight * 0.4; // Base 40%
    final responsiveHeight = calculatedHeight.clamp(minHeight, maxHeight);

    return Container(
      height: responsiveHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with Gift title and balance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gift',
                    style: TextStyle(
                      fontSize: 20,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/setup/coins.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 4),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final coinBalance =
                                authProvider.user?['coinBalance'] ?? 0;
                            return Text(
                              coinBalance.toString(),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Gift options horizontal scroll
            SizedBox(
              height: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    final isSelected = selectedGiftIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGiftIndex = index;
                        });
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue[50]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Gift icon
                            Image.asset(
                              gift['icon'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 6),
                            // Gift value
                            Text(
                              '${gift['value']}',
                              style: TextStyle(
                                fontSize: 14,
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
            ),

            // Send gift button - with responsive padding
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedGiftIndex != -1 && !_isSending
                      ? () async {
                          setState(() => _isSending = true);

                          final selectedGift = gifts[selectedGiftIndex];

                          try {
                            final response = await ApiService.sendGift(
                              recipientId: widget.recipientId,
                              amount: selectedGift['value'],
                              message: 'Gift from ShowOff.life',
                            );

                            if (!mounted) return;

                            if (response['success']) {
                              // Update user's coin balance in AuthProvider
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );

                              // Refresh user data to get updated coin balance
                              await authProvider.refreshUser();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Sent ${selectedGift['value']} coins to ${widget.recipientName}!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              throw Exception(response['message']);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSending = false);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGiftIndex != -1
                        ? const Color(0xFF701CF5)
                        : Colors.grey[300],
                    foregroundColor: selectedGiftIndex != -1
                        ? Colors.white
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    selectedGiftIndex != -1
                        ? 'Send Gift (${gifts[selectedGiftIndex]['value']} coins)'
                        : 'Select a Gift',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
