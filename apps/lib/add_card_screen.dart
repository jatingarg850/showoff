import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController
  _cardNumberController = TextEditingController();
  final TextEditingController
  _cardNameController = TextEditingController();
  final TextEditingController
  _expiryDateController = TextEditingController();
  final TextEditingController
  _cvvController = TextEditingController();
  bool
  _setAsDefault = false;

  @override
  void
  initState() {
    super.initState();
    _cardNumberController.addListener(
      _updateCardDisplay,
    );
    _cardNameController.addListener(
      _updateCardDisplay,
    );
  }

  @override
  void
  dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void
  _updateCardDisplay() {
    setState(
      () {},
    );
  }

  String
  _formatCardNumber(
    String value,
  ) {
    value = value.replaceAll(
      ' ',
      '',
    );
    String formatted = '';
    for (
      int i = 0;
      i <
          value.length;
      i++
    ) {
      if (i >
              0 &&
          i %
                  4 ==
              0) {
        formatted += ' - ';
      }
      formatted += value[i];
    }
    return formatted;
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
                    'Add Card',
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

              // Card Preview
              Container(
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
                    // Card content overlay
                    Padding(
                      padding: const EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Credit and VISA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Credit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'VISA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Card holder name
                          Text(
                            _cardNameController.text.isEmpty
                                ? 'Luis Fonsi'
                                : _cardNameController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          // Card number
                          Text(
                            _cardNumberController.text.isEmpty
                                ? '4802 - 2215 - 1183 - 4289'
                                : _formatCardNumber(
                                    _cardNumberController.text,
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // Card Number field
              const Text(
                'Card Number',
                style: TextStyle(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    16,
                  ),
                ],
                decoration: InputDecoration(
                  hintText: '4802 2215 1183 4289',
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

              // Card Name field
              const Text(
                'Card Name',
                style: TextStyle(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              TextField(
                controller: _cardNameController,
                decoration: InputDecoration(
                  hintText: 'Luis Fonsi',
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

              // Expiry Date and CVV row
              Row(
                children: [
                  // Expiry Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Date',
                          style: TextStyle(
                            color: Color(
                              0xFF8B5CF6,
                            ),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: _expiryDateController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              4,
                            ),
                            _ExpiryDateFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: '11/25',
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
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 20,
                  ),

                  // CVV
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CVV',
                          style: TextStyle(
                            color: Color(
                              0xFF8B5CF6,
                            ),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              3,
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: '11/25',
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
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              // Set as default checkbox
              Row(
                children: [
                  Checkbox(
                    value: _setAsDefault,
                    onChanged:
                        (
                          value,
                        ) {
                          setState(
                            () {
                              _setAsDefault =
                                  value ??
                                  false;
                            },
                          );
                        },
                    activeColor: const Color(
                      0xFF8B5CF6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        4,
                      ),
                    ),
                  ),
                  const Text(
                    'Set as default',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Add card button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle add card
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Card added successfully!',
                        ),
                        backgroundColor: Color(
                          0xFF8B5CF6,
                        ),
                      ),
                    );
                    Navigator.pop(
                      context,
                    );
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
                    'Add card',
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

class _ExpiryDateFormatter
    extends
        TextInputFormatter {
  @override
  TextEditingValue
  formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.length ==
            2 &&
        oldValue.text.length ==
            1) {
      text = '$text/';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}
