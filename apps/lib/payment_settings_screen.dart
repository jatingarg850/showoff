import 'package:flutter/material.dart';

class PaymentSettingsScreen
    extends
        StatefulWidget {
  const PaymentSettingsScreen({
    super.key,
  });

  @override
  State<
    PaymentSettingsScreen
  >
  createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState
    extends
        State<
          PaymentSettingsScreen
        > {
  String
  selectedPaymentMethod = 'visa';

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
          'Payment Settings',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildPaymentMethodCard(
              'visa',
              'Visa',
              '**** **** **** 2143',
              'Expires 12/26',
              const Color(
                0xFF1A1F71,
              ),
              Colors.white,
            ),

            _buildPaymentMethodCard(
              'mastercard',
              'Mastercard',
              '**** **** **** 8765',
              'Expires 08/27',
              const Color(
                0xFFEB001B,
              ),
              Colors.white,
            ),

            _buildPaymentMethodCard(
              'paypal',
              'PayPal',
              'user@example.com',
              'Verified Account',
              const Color(
                0xFF0070BA,
              ),
              Colors.white,
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(
                    0xFF8B5CF6,
                  ),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _showAddPaymentMethodDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Color(
                        0xFF8B5CF6,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Add Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(
                          0xFF8B5CF6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              'Billing Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildBillingInfoItem(
              Icons.person,
              'Full Name',
              'John Doe',
              () {
                // Handle edit name
              },
            ),

            _buildBillingInfoItem(
              Icons.email,
              'Email Address',
              'john.doe@example.com',
              () {
                // Handle edit email
              },
            ),

            _buildBillingInfoItem(
              Icons.location_on,
              'Billing Address',
              '123 Main St, City, State 12345',
              () {
                // Handle edit address
              },
            ),

            _buildBillingInfoItem(
              Icons.phone,
              'Phone Number',
              '+1 (555) 123-4567',
              () {
                // Handle edit phone
              },
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildTransactionItem(
              'Premium Subscription',
              'Oct 15, 2025',
              '\$9.99',
              true,
            ),

            _buildTransactionItem(
              'Coin Purchase',
              'Oct 10, 2025',
              '\$4.99',
              true,
            ),

            _buildTransactionItem(
              'Premium Subscription',
              'Sep 15, 2025',
              '\$9.99',
              true,
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  // Handle view all transactions
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(
                      0xFF8B5CF6,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      24,
                    ),
                  ),
                ),
                child: const Text(
                  'View All Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF8B5CF6,
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

  Widget
  _buildPaymentMethodCard(
    String id,
    String name,
    String number,
    String expiry,
    Color bgColor,
    Color textColor,
  ) {
    final isSelected =
        selectedPaymentMethod ==
        id;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        onTap: () {
          setState(
            () {
              selectedPaymentMethod = id;
            },
          );
        },
        borderRadius: BorderRadius.circular(
          12,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            16,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: isSelected
                  ? const Color(
                      0xFF8B5CF6,
                    )
                  : Colors.grey[200]!,
              width: isSelected
                  ? 2
                  : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      expiry,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(
                    0xFF8B5CF6,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildBillingInfoItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          12,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            16,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(
                        0xFF8B5CF6,
                      ).withValues(
                        alpha: 0.1,
                      ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Icon(
                  icon,
                  color: const Color(
                    0xFF8B5CF6,
                  ),
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildTransactionItem(
    String title,
    String date,
    String amount,
    bool isSuccess,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              8,
            ),
            decoration: BoxDecoration(
              color:
                  (isSuccess
                          ? Colors.green
                          : Colors.red)
                      .withValues(
                        alpha: 0.1,
                      ),
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            child: Icon(
              isSuccess
                  ? Icons.check
                  : Icons.close,
              color: isSuccess
                  ? Colors.green
                  : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void
  _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder:
          (
            BuildContext context,
          ) {
            return AlertDialog(
              title: const Text(
                'Add Payment Method',
              ),
              content: const Text(
                'Choose a payment method to add to your account.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                  ),
                  child: const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                    // Handle add payment method
                  },
                  child: const Text(
                    'Add Card',
                  ),
                ),
              ],
            );
          },
    );
  }
}
