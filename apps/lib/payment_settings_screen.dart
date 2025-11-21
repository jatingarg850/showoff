import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'add_card_screen.dart';
import 'coin_purchase_screen.dart';

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
  selectedPaymentMethod = '';
  List<
    Map<
      String,
      dynamic
    >
  >
  _paymentCards = [];
  Map<
    String,
    dynamic
  >
  _billingInfo = {};
  List<
    Map<
      String,
      dynamic
    >
  >
  _transactions = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<
    void
  >
  _loadPaymentData() async {
    setState(
      () {
        _isLoading = true;
      },
    );

    try {
      // Load payment cards
      final cardsResponse = await ApiService.getPaymentCards();
      if (cardsResponse['success']) {
        _paymentCards =
            List<
              Map<
                String,
                dynamic
              >
            >.from(
              cardsResponse['data'] ??
                  [],
            );
        // Set default selected card
        final defaultCard = _paymentCards.firstWhere(
          (
            card,
          ) =>
              card['isDefault'] ==
              true,
          orElse: () => _paymentCards.isNotEmpty
              ? _paymentCards.first
              : {},
        );
        if (defaultCard.isNotEmpty) {
          selectedPaymentMethod = defaultCard['_id'];
        }
      }

      // Load billing info
      final billingResponse = await ApiService.getBillingInfo();
      if (billingResponse['success']) {
        _billingInfo =
            billingResponse['data'] ??
            {};
      }

      // Load transactions
      final transactionsResponse = await ApiService.getTransactions();
      if (transactionsResponse['success']) {
        _transactions =
            List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  transactionsResponse['data'] ??
                      [],
                )
                .take(
                  3,
                )
                .toList(); // Show only recent 3
      }
    } catch (
      e
    ) {
      print(
        'Error loading payment data: $e',
      );
    } finally {
      setState(
        () {
          _isLoading = false;
        },
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
        body: const Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<
                  Color
                >(
                  Color(
                    0xFF8B5CF6,
                  ),
                ),
          ),
        ),
      );
    }
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
            // Buy Coins Button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF8B5CF6,
                    ),
                    Color(
                      0xFF3B82F6,
                    ),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const CoinPurchaseScreen(),
                    ),
                  );
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
                      Icons.monetization_on,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Buy Coins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

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

            // Dynamic payment cards
            ..._paymentCards
                .map(
                  (
                    card,
                  ) => _buildPaymentMethodCard(
                    card['_id'],
                    _getCardDisplayName(
                      card['cardType'],
                    ),
                    '**** **** **** ${card['lastFourDigits']}',
                    'Expires ${card['expiryMonth']}/${card['expiryYear'].toString().substring(2)}',
                    _getCardColor(
                      card['cardType'],
                    ),
                    Colors.white,
                    onDelete: () => _deleteCard(
                      card['_id'],
                    ),
                  ),
                )
                ,

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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const AddCardScreen(),
                    ),
                  );
                  if (result ==
                      true) {
                    _loadPaymentData(); // Refresh data
                  }
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
              _billingInfo['fullName'] ??
                  'Not set',
              () => _editBillingInfo(
                'fullName',
              ),
            ),

            _buildBillingInfoItem(
              Icons.email,
              'Email Address',
              _billingInfo['email'] ??
                  'Not set',
              () => _editBillingInfo(
                'email',
              ),
            ),

            _buildBillingInfoItem(
              Icons.location_on,
              'Billing Address',
              _formatAddress(),
              () => _editBillingInfo(
                'address',
              ),
            ),

            _buildBillingInfoItem(
              Icons.phone,
              'Phone Number',
              _billingInfo['phone'] ??
                  'Not set',
              () => _editBillingInfo(
                'phone',
              ),
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

            // Dynamic transactions
            ..._transactions
                .map(
                  (
                    transaction,
                  ) => _buildTransactionItem(
                    _getTransactionTitle(
                      transaction['type'],
                    ),
                    _formatDate(
                      transaction['createdAt'],
                    ),
                    '${transaction['amount'] > 0 ? '+' : ''}${transaction['amount']} coins',
                    true,
                  ),
                )
                ,

            const SizedBox(
              height: 16,
            ),

            SizedBox(
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

  String
  _getCardDisplayName(
    String cardType,
  ) {
    switch (cardType) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'discover':
        return 'Discover';
      default:
        return 'Card';
    }
  }

  Color
  _getCardColor(
    String cardType,
  ) {
    switch (cardType) {
      case 'visa':
        return const Color(
          0xFF1A1F71,
        );
      case 'mastercard':
        return const Color(
          0xFFEB001B,
        );
      case 'amex':
        return const Color(
          0xFF006FCF,
        );
      case 'discover':
        return const Color(
          0xFFFF6000,
        );
      default:
        return Colors.grey;
    }
  }

  String
  _formatAddress() {
    final parts =
        <
          String
        >[];
    if (_billingInfo['address']?.isNotEmpty ==
        true) {
      parts.add(
        _billingInfo['address'],
      );
    }
    if (_billingInfo['city']?.isNotEmpty ==
        true) {
      parts.add(
        _billingInfo['city'],
      );
    }
    if (_billingInfo['state']?.isNotEmpty ==
        true) {
      parts.add(
        _billingInfo['state'],
      );
    }
    if (_billingInfo['zipCode']?.isNotEmpty ==
        true) {
      parts.add(
        _billingInfo['zipCode'],
      );
    }
    return parts.isEmpty
        ? 'Not set'
        : parts.join(
            ', ',
          );
  }

  String
  _getTransactionTitle(
    String type,
  ) {
    switch (type) {
      case 'purchase':
        return 'Coin Purchase';
      case 'ad_watch':
        return 'Ad Reward';
      case 'spin_wheel':
        return 'Spin Wheel';
      case 'upload_reward':
        return 'Upload Reward';
      case 'view_reward':
        return 'View Reward';
      case 'gift_sent':
        return 'Gift Sent';
      case 'gift_received':
        return 'Gift Received';
      default:
        return 'Transaction';
    }
  }

  String
  _formatDate(
    String dateString,
  ) {
    try {
      final date = DateTime.parse(
        dateString,
      );
      return '${date.day}/${date.month}/${date.year}';
    } catch (
      e
    ) {
      return dateString;
    }
  }

  Future<
    void
  >
  _deleteCard(
    String cardId,
  ) async {
    try {
      final response = await ApiService.deletePaymentCard(
        cardId,
      );
      if (response['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Card deleted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadPaymentData(); // Refresh data
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Failed to delete card',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (
      e
    ) {
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

  void
  _editBillingInfo(
    String field,
  ) {
    // For now, show a simple dialog. In a real app, you'd have a proper form
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: Text(
              'Edit ${field.toUpperCase()}',
            ),
            content: const Text(
              'Billing info editing will be implemented in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'OK',
                ),
              ),
            ],
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
    Color textColor, {
    VoidCallback? onDelete,
  }) {
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
              Row(
                children: [
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(
                        0xFF8B5CF6,
                      ),
                    ),
                  if (onDelete !=
                      null) ...[
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
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
}
