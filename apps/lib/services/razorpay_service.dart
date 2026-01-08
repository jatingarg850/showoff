import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

class RazorpayService {
  static RazorpayService? _instance;
  static RazorpayService get instance => _instance ??= RazorpayService._();

  RazorpayService._();

  late Razorpay _razorpay;
  bool _isInitialized = false;

  // Callbacks
  Function(String message)? onSuccess;
  Function(String error)? onError;
  Function(String message)? onExternalWallet;

  // Current payment data
  String? _currentOrderId;
  double? _currentAmount;
  String? _currentDescription;
  String? _paymentType; // 'add_money' or 'subscription'

  void initialize() {
    if (_isInitialized) return;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isInitialized = true;
    print('✅ Razorpay service initialized');
  }

  void dispose() {
    if (_isInitialized) {
      _razorpay.clear();
      _isInitialized = false;
    }
  }

  Future<void> startPayment({
    required String orderId,
    required double amount,
    required String description,
    String? userEmail,
    String? userPhone,
    String paymentType = 'add_money', // 'add_money' or 'subscription'
  }) async {
    if (!_isInitialized) {
      initialize();
    }

    _currentOrderId = orderId;
    _currentAmount = amount;
    _currentDescription = description;
    _paymentType = paymentType;

    print('🔍 RazorpayService DEBUG - Received amount: $amount');
    print('🔍 RazorpayService DEBUG - Converting to int: ${amount.toInt()}');
    print('🔍 RazorpayService DEBUG - This should be in paise already');

    var options = {
      'key': 'rzp_live_S0WAY0u3f7QBho', // Live Razorpay key - matches backend
      'amount': amount.toInt(), // Amount already in paise from backend
      'name': 'ShowOff.life',
      'order_id': orderId,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': userPhone ?? '9999999999',
        'email': userEmail ?? 'user@showoff.life',
      },
      'external': {
        'wallets': ['paytm'],
      },
      'theme': {'color': '#8B5CF6'},
    };

    try {
      print('🚀 Starting Razorpay payment with options: $options');
      _razorpay.open(options);
    } catch (e) {
      print('❌ Error starting Razorpay payment: $e');
      onError?.call('Failed to start payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('✅ Payment Success!');
    print('Payment ID: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');

    _verifyPayment(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Payment Error!');
    print('Code: ${response.code}');
    print('Message: ${response.message}');

    String errorMessage = 'Payment failed';
    if (response.message != null && response.message!.isNotEmpty) {
      errorMessage = response.message!;
    } else if (response.code != null) {
      switch (response.code) {
        case Razorpay.PAYMENT_CANCELLED:
          errorMessage = 'Payment was cancelled';
          break;
        case Razorpay.NETWORK_ERROR:
          errorMessage = 'Network error occurred';
          break;
        default:
          errorMessage = 'Payment failed with code: ${response.code}';
      }
    }

    onError?.call(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('🔗 External Wallet Selected: ${response.walletName}');
    onExternalWallet?.call('External wallet selected: ${response.walletName}');
  }

  Future<void> _verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      print('🔐 Verifying payment...');
      print('Order ID: $orderId');
      print('Payment ID: $paymentId');
      print('Signature: $signature');
      print('Amount: $_currentAmount');
      print('Payment Type: $_paymentType');

      // Convert paise back to rupees for verification
      final amountInRupees = _currentAmount! / 100;

      print('🔍 VERIFICATION DEBUG - Amount in paise: $_currentAmount');
      print('🔍 VERIFICATION DEBUG - Converting to rupees: $amountInRupees');

      // Handle subscription payment
      if (_paymentType == 'subscription') {
        final response = await ApiService.verifySubscriptionPayment(
          razorpayOrderId: orderId,
          razorpayPaymentId: paymentId,
          razorpaySignature: signature,
        );

        if (response['success']) {
          print('✅ Subscription payment verified successfully');
          onSuccess?.call(
            'Subscription activated! You now have premium benefits.',
          );
        } else {
          print('❌ Subscription verification failed: ${response['message']}');
          onError?.call(
            'Subscription verification failed: ${response['message']}',
          );
        }
      } else {
        // Handle add money payment
        final response = await ApiService.addMoney(
          amount: amountInRupees,
          gateway: 'razorpay',
          paymentData: {
            'razorpayOrderId': orderId,
            'razorpayPaymentId': paymentId,
            'razorpaySignature': signature,
          },
        );

        if (response['success']) {
          print('✅ Payment verified successfully');
          print('Coins added: ${response['coinsAdded']}');
          onSuccess?.call(
            'Payment successful! ${response['coinsAdded']} coins added to your account.',
          );
        } else {
          print('❌ Payment verification failed: ${response['message']}');
          onError?.call('Payment verification failed: ${response['message']}');
        }
      }
    } catch (e) {
      print('❌ Error verifying payment: $e');
      onError?.call('Payment verification failed: $e');
    }
  }

  // Set callbacks
  void setCallbacks({
    Function(String message)? onSuccess,
    Function(String error)? onError,
    Function(String message)? onExternalWallet,
  }) {
    this.onSuccess = onSuccess;
    this.onError = onError;
    this.onExternalWallet = onExternalWallet;
  }

  // Clear callbacks
  void clearCallbacks() {
    onSuccess = null;
    onError = null;
    onExternalWallet = null;
  }
}
