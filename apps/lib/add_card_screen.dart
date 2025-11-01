import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';

class AddCardScreen
    extends
        StatefulWidget {
  const AddCardScreen({
    super.key,
  });

  @override
  State<
    AddCardScreen
  >
  createState() => _AddCardScreenState();
}

class _AddCardScreenState
    extends
        State<
          AddCardScreen
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _cardNumberController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool
  _isLoading = false;
  bool
  _isDefault = false;
  String
  _cardType = '';

  @override
  void
  initState() {
    super.initState();
    _cardNumberController.addListener(
      _onCardNumberChanged,
    );
  }

  @override
  void
  dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void
  _onCardNumberChanged() {
    final cardNumber = _cardNumberController.text.replaceAll(
      ' ',
      '',
    );
    String newCardType = '';

    if (cardNumber.isNotEmpty) {
      if (cardNumber.startsWith(
        '4',
      )) {
        newCardType = 'visa';
      } else if (cardNumber.startsWith(
            RegExp(
              r'^5[1-5]',
            ),
          ) ||
          cardNumber.startsWith(
            RegExp(
              r'^2[2-7]',
            ),
          )) {
        newCardType = 'mastercard';
      } else if (cardNumber.startsWith(
        RegExp(
          r'^3[47]',
        ),
      )) {
        newCardType = 'amex';
      } else if (cardNumber.startsWith(
            '6011',
          ) ||
          cardNumber.startsWith(
            '65',
          )) {
        newCardType = 'discover';
      }
    }

    if (newCardType !=
        _cardType) {
      setState(
        () {
          _cardType = newCardType;
        },
      );
    }
  }

  Future<
    void
  >
  _addCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(
      () {
        _isLoading = true;
      },
    );

    try {
      final cardNumber = _cardNumberController.text.replaceAll(
        ' ',
        '',
      );
      final expiry = _expiryController.text.split(
        '/',
      );

      final response = await ApiService.addPaymentCard(
        cardNumber: cardNumber,
        expiryMonth: expiry[0],
        expiryYear: '20${expiry[1]}',
        cvv: _cvvController.text,
        cardholderName: _cardholderNameController.text,
        isDefault: _isDefault,
      );

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Card added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate success
        }
      } else {
        _showError(
          response['message'] ??
              'Failed to add card',
        );
      }
    } catch (
      e
    ) {
      _showError(
        'Error: $e',
      );
    } finally {
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  void
  _showError(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  String?
  _validateCardNumber(
    String? value,
  ) {
    if (value ==
            null ||
        value.isEmpty) {
      return 'Please enter card number';
    }

    final cardNumber = value.replaceAll(
      ' ',
      '',
    );
    if (cardNumber.length <
            13 ||
        cardNumber.length >
            19) {
      return 'Invalid card number';
    }

    if (_cardType.isEmpty) {
      return 'Unsupported card type';
    }

    return null;
  }

  String?
  _validateExpiry(
    String? value,
  ) {
    if (value ==
            null ||
        value.isEmpty) {
      return 'Please enter expiry date';
    }

    if (!RegExp(
      r'^\d{2}/\d{2}$',
    ).hasMatch(
      value,
    )) {
      return 'Invalid format (MM/YY)';
    }

    final parts = value.split(
      '/',
    );
    final month = int.tryParse(
      parts[0],
    );
    final year = int.tryParse(
      parts[1],
    );

    if (month ==
            null ||
        month <
            1 ||
        month >
            12) {
      return 'Invalid month';
    }

    final currentYear =
        DateTime.now().year %
        100;
    if (year ==
            null ||
        year <
            currentYear) {
      return 'Card expired';
    }

    return null;
  }

  String?
  _validateCVV(
    String? value,
  ) {
    if (value ==
            null ||
        value.isEmpty) {
      return 'Please enter CVV';
    }

    final expectedLength =
        _cardType ==
            'amex'
        ? 4
        : 3;
    if (value.length !=
        expectedLength) {
      return 'Invalid CVV';
    }

    return null;
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
          'Add Payment Card',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              Container(
                width: double.infinity,
                height: 200,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SHOWOFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_cardType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ),
                              ),
                              child: Text(
                                _cardType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _formatCardNumber(
                          _cardNumberController.text,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _cardholderNameController.text.isEmpty
                                ? 'CARDHOLDER NAME'
                                : _cardholderNameController.text.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _expiryController.text.isEmpty
                                ? 'MM/YY'
                                : _expiryController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              // Card Number
              const Text(
                'Card Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
                validator: _validateCardNumber,
                decoration: InputDecoration(
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    borderSide: const BorderSide(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                    ),
                  ),
                  suffixIcon: _cardType.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(
                            12,
                          ),
                          child: _getCardIcon(
                            _cardType,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // Cardholder Name
              const Text(
                'Cardholder Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextFormField(
                controller: _cardholderNameController,
                textCapitalization: TextCapitalization.words,
                validator:
                    (
                      value,
                    ) {
                      if (value ==
                              null ||
                          value.isEmpty) {
                        return 'Please enter cardholder name';
                      }
                      return null;
                    },
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    borderSide: const BorderSide(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ExpiryDateInputFormatter(),
                          ],
                          validator: _validateExpiry,
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
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
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CVV',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              _cardType ==
                                      'amex'
                                  ? 4
                                  : 3,
                            ),
                          ],
                          validator: _validateCVV,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText:
                                _cardType ==
                                    'amex'
                                ? '1234'
                                : '123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              borderSide: const BorderSide(
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
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              // Set as default
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged:
                        (
                          value,
                        ) {
                          setState(
                            () {
                              _isDefault =
                                  value ??
                                  false;
                            },
                          );
                        },
                    activeColor: const Color(
                      0xFF8B5CF6,
                    ),
                  ),
                  const Text(
                    'Set as default payment method',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 32,
              ),

              // Add Card Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF8B5CF6,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<
                                Color
                              >(
                                Colors.white,
                              ),
                        )
                      : const Text(
                          'Add Card',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String
  _formatCardNumber(
    String cardNumber,
  ) {
    if (cardNumber.isEmpty) return '•••• •••• •••• ••••';

    final formatted = cardNumber.replaceAll(
      ' ',
      '',
    );
    String result = '';

    for (
      int i = 0;
      i <
          formatted.length;
      i++
    ) {
      if (i >
              0 &&
          i %
                  4 ==
              0) {
        result += ' ';
      }
      result += formatted[i];
    }

    // Pad with dots if needed
    while (result
            .replaceAll(
              ' ',
              '',
            )
            .length <
        16) {
      if (result
                      .replaceAll(
                        ' ',
                        '',
                      )
                      .length %
                  4 ==
              0 &&
          result.isNotEmpty) {
        result += ' ';
      }
      result += '•';
    }

    return result;
  }

  Widget
  _getCardIcon(
    String cardType,
  ) {
    switch (cardType) {
      case 'visa':
        return Container(
          width: 32,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(
              0xFF1A1F71,
            ),
            borderRadius: BorderRadius.circular(
              4,
            ),
          ),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'mastercard':
        return Container(
          width: 32,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(
              0xFFEB001B,
            ),
            borderRadius: BorderRadius.circular(
              4,
            ),
          ),
          child: const Center(
            child: Text(
              'MC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case 'amex':
        return Container(
          width: 32,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(
              0xFF006FCF,
            ),
            borderRadius: BorderRadius.circular(
              4,
            ),
          ),
          child: const Center(
            child: Text(
              'AMEX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      default:
        return const Icon(
          Icons.credit_card,
          color: Colors.grey,
        );
    }
  }
}

// Input formatters
class CardNumberInputFormatter
    extends
        TextInputFormatter {
  @override
  TextEditingValue
  formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(
      ' ',
      '',
    );
    final buffer = StringBuffer();

    for (
      int i = 0;
      i <
          text.length;
      i++
    ) {
      if (i >
              0 &&
          i %
                  4 ==
              0) {
        buffer.write(
          ' ',
        );
      }
      buffer.write(
        text[i],
      );
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.length,
      ),
    );
  }
}

class ExpiryDateInputFormatter
    extends
        TextInputFormatter {
  @override
  TextEditingValue
  formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(
      '/',
      '',
    );
    final buffer = StringBuffer();

    for (
      int i = 0;
      i <
              text.length &&
          i <
              4;
      i++
    ) {
      if (i ==
          2) {
        buffer.write(
          '/',
        );
      }
      buffer.write(
        text[i],
      );
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(
        offset: buffer.length,
      ),
    );
  }
}
