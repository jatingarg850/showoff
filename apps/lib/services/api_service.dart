import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'storage_service.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Helper function to construct full image URLs
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await StorageService.getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  // Video APIs - Pre-signed URLs for faster loading
  static Future<Map<String, dynamic>> getPresignedUrl(String videoUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/presigned-url'),
        headers: await _getHeaders(),
        body: jsonEncode({'videoUrl': videoUrl}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Error getting pre-signed URL: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPresignedUrlsBatch(
    List<String> videoUrls,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/videos/presigned-urls-batch'),
        headers: await _getHeaders(),
        body: jsonEncode({'videoUrls': videoUrls}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Error getting batch pre-signed URLs: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Auth APIs
  static Future<Map<String, dynamic>> register({
    required String username,
    required String displayName,
    required String password,
    String? email,
    String? phone,
    String? referralCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'username': username,
        'displayName': displayName,
        'password': password,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (referralCode != null) 'referralCode': referralCode,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await StorageService.saveToken(data['data']['token']);
      await StorageService.saveUser(data['data']['user']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: jsonEncode({'emailOrPhone': emailOrPhone, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await StorageService.saveToken(data['data']['token']);
      await StorageService.saveUser(data['data']['user']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> phoneLogin({
    required String phoneNumber,
    required String countryCode,
    String? firstName,
    String? lastName,
    required String accessToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/phone-login'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        'accessToken': accessToken,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await StorageService.saveToken(data['data']['token']);
      await StorageService.saveUser(data['data']['user']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendOTP({
    String? phone,
    String? email,
    String? countryCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (countryCode != null) 'countryCode': countryCode,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyOTP({
    String? phone,
    String? email,
    String? countryCode,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (countryCode != null) 'countryCode': countryCode,
        'otp': otp,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkUsername(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/check-username'),
      headers: await _getHeaders(),
      body: jsonEncode({'username': username}),
    );
    return jsonDecode(response.body);
  }

  // Profile APIs
  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    List<String>? interests,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (username != null) 'username': username,
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (interests != null) 'interests': interests,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> applyReferralCode(
    String referralCode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/apply-referral'),
        headers: await _getHeaders(),
        body: jsonEncode({'referralCode': referralCode}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Error applying referral code: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadProfilePicture(
    File imageFile,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile/picture'),
    );

    request.headers.addAll(await _getMultipartHeaders());

    // Get file extension to determine content type
    final extension = imageFile.path.split('.').last.toLowerCase();
    String contentType = 'image/jpeg';
    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      contentType = 'image/jpeg';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http_parser.MediaType.parse(contentType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserProfile(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$username'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/stats'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=$query'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Post APIs
  static Future<Map<String, dynamic>> createPostWithUrl({
    required String mediaUrl,
    required String mediaType, // 'video' or 'image'
    String? thumbnailUrl,
    String? caption,
    String? location,
    List<String>? hashtags,
    String? musicId,
    bool isPublic = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/create-with-url'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'mediaUrl': mediaUrl,
          'mediaType': mediaType,
          'thumbnailUrl': thumbnailUrl,
          'caption': caption ?? '',
          'location': location ?? '',
          'hashtags': hashtags ?? [],
          'musicId': musicId,
          'isPublic': isPublic,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      print('❌ Create post error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required File mediaFile,
    String? caption,
    List<String>? hashtags,
    String? type,
    File? thumbnailFile,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));

    request.headers.addAll(await _getMultipartHeaders());

    // Determine content type from file extension
    final extension = mediaFile.path.split('.').last.toLowerCase();
    String contentType;
    bool isVideo = false;
    if (extension == 'mp4' || extension == 'mov' || extension == 'avi') {
      contentType = 'video/mp4';
      isVideo = true;
    } else if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    } else {
      contentType = 'image/jpeg';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'media',
        mediaFile.path,
        contentType: http_parser.MediaType.parse(contentType),
      ),
    );

    // Upload thumbnail if provided, or auto-generate for videos
    if (thumbnailFile != null) {
      // Use provided thumbnail file
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnailFile.path,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ),
      );
    } else if (isVideo) {
      // Auto-generate thumbnail as fallback
      try {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: mediaFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 640,
          quality: 75,
        );

        if (thumbnailPath != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'thumbnail',
              thumbnailPath,
              contentType: http_parser.MediaType.parse('image/jpeg'),
            ),
          );
        }
      } catch (e) {
        print('Error generating thumbnail: $e');
        // Continue without thumbnail if generation fails
      }
    }

    if (caption != null) {
      request.fields['caption'] = caption;
    }
    if (hashtags != null) {
      request.fields['hashtags'] = hashtags.join(',');
    }
    if (type != null) {
      request.fields['type'] = type;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFeed({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/feed?page=$page&limit=$limit'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserPosts(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/user/$userId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addComment(
    String postId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comment'),
      headers: await _getHeaders(),
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getComments(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> incrementView(String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/view'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Follow APIs
  static Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final url = '$baseUrl/follow/$userId';
      final headers = await _getHeaders();
      print('📤 Follow User API: POST $url');
      print('📤 Headers: $headers');

      final response = await http.post(Uri.parse(url), headers: headers);

      print('📥 Follow Response Status: ${response.statusCode}');
      print('📥 Follow Response Body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Follow User Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final url = '$baseUrl/follow/$userId';
      final headers = await _getHeaders();
      print('📤 Unfollow User API: DELETE $url');
      print('📤 Headers: $headers');

      final response = await http.delete(Uri.parse(url), headers: headers);

      print('📥 Unfollow Response Status: ${response.statusCode}');
      print('📥 Unfollow Response Body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Unfollow User Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFollowers(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/follow/followers/$userId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFollowing(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/follow/following/$userId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkFollowing(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/follow/check/$userId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Check Following Error: $e');
      return {'success': false, 'isFollowing': false};
    }
  }

  // SYT APIs
  static Future<Map<String, dynamic>> submitSYTEntry({
    required File videoFile,
    File? thumbnailFile,
    required String title,
    required String category,
    required String competitionType,
    String? description,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/syt/submit'),
    );

    request.headers.addAll(await _getMultipartHeaders());

    // Set video content type
    request.files.add(
      await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
        contentType: http_parser.MediaType.parse('video/mp4'),
      ),
    );

    // Upload thumbnail if provided
    if (thumbnailFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'thumbnail',
          thumbnailFile.path,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ),
      );
    }

    request.fields['title'] = title;
    request.fields['category'] = category;
    request.fields['competitionType'] = competitionType;
    if (description != null) {
      request.fields['description'] = description;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSYTEntries({
    String? type,
    String? period,
    String? filter,
  }) async {
    String url = '$baseUrl/syt/entries?';
    if (type != null) {
      url += 'type=$type&';
    }
    if (period != null) {
      url += 'period=$period&';
    }
    if (filter != null) {
      url += 'filter=$filter&';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> voteSYTEntry(String entryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/syt/$entryId/vote'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleSYTLike(String entryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/syt/$entryId/like'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSYTEntryStats(String entryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/syt/$entryId/stats'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleSYTBookmark(String entryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/syt/$entryId/bookmark'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSYTLeaderboard({
    String type = 'weekly',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/syt/leaderboard?type=$type'),
        headers: await _getHeaders(),
      );

      print('SYT Leaderboard API Response: ${response.statusCode}');
      print('SYT Leaderboard API Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('SYT Leaderboard API Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Chat APIs
  static Future<Map<String, dynamic>> getMessages(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/$userId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendMessage(
    String userId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/$userId'),
      headers: await _getHeaders(),
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getConversations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Coin APIs
  static Future<Map<String, dynamic>> watchAd() async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/watch-ad'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/transactions?page=$page&limit=$limit'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendGift({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/gift'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'recipientId': recipientId,
        'amount': amount,
        if (message != null) 'message': message,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCoinBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/coins/balance'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Create coin purchase order
  static Future<Map<String, dynamic>> createCoinPurchaseOrder({
    required String packageId,
    required int amount,
    required int coins,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/create-purchase-order'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'packageId': packageId,
        'amount': amount,
        'coins': coins,
      }),
    );
    return jsonDecode(response.body);
  }

  // Purchase coins after payment
  static Future<Map<String, dynamic>> purchaseCoins({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String packageId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/purchase'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        'packageId': packageId,
      }),
    );
    return jsonDecode(response.body);
  }

  // Create Stripe payment intent
  static Future<Map<String, dynamic>> createStripePaymentIntent({
    required double amount,
    String currency = 'usd',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/create-stripe-intent'),
      headers: await _getHeaders(),
      body: jsonEncode({'amount': amount, 'currency': currency}),
    );
    return jsonDecode(response.body);
  }

  // Confirm Stripe payment
  static Future<Map<String, dynamic>> confirmStripePayment({
    required String paymentIntentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/confirm-stripe-payment'),
      headers: await _getHeaders(),
      body: jsonEncode({'paymentIntentId': paymentIntentId}),
    );
    return jsonDecode(response.body);
  }

  // Add money (generic endpoint)
  static Future<Map<String, dynamic>> addMoney({
    required double amount,
    required String gateway,
    required Map<String, dynamic> paymentData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coins/add-money'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'amount': amount,
        'gateway': gateway,
        'paymentData': paymentData,
      }),
    );
    return jsonDecode(response.body);
  }

  // Create Razorpay order for add money
  static Future<Map<String, dynamic>> createRazorpayOrderForAddMoney({
    required double amount,
  }) async {
    final requestBody = {
      'packageId': 'add_money',
      'amount': amount, // Send amount in rupees, backend will convert to paise
      'coins': (amount * 1).round(), // 1 INR = 1 coin
    };

    print('🌐 API Service DEBUG - Sending to backend: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/coins/create-purchase-order'),
      headers: await _getHeaders(),
      body: jsonEncode(requestBody),
    );
    return jsonDecode(response.body);
  }

  // Payment Card APIs
  static Future<Map<String, dynamic>> addPaymentCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardholderName,
    bool isDefault = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/cards'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        'cardholderName': cardholderName,
        'isDefault': isDefault,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPaymentCards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/cards'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePaymentCard(String cardId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/payments/cards/$cardId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> setDefaultCard(String cardId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/payments/cards/$cardId/default'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateBillingInfo({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/payments/billing'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (zipCode != null) 'zipCode': zipCode,
        if (country != null) 'country': country,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getBillingInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/billing'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Withdrawal APIs
  static Future<Map<String, dynamic>> requestWithdrawal({
    required int coinAmount,
    required String method,
    Map<String, dynamic>? bankDetails,
    String? sofftAddress,
    String? upiId,
    List<File>? idDocuments,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/withdrawal/request'),
    );

    request.headers.addAll(await _getMultipartHeaders());

    request.fields['coinAmount'] = coinAmount.toString();
    request.fields['method'] = method;

    if (bankDetails != null) {
      request.fields['bankDetails'] = jsonEncode(bankDetails);
    }

    if (sofftAddress != null) {
      request.fields['sofftAddress'] = sofftAddress;
    }

    if (upiId != null) {
      request.fields['upiId'] = upiId;
    }

    // Add ID documents
    if (idDocuments != null && idDocuments.isNotEmpty) {
      for (var doc in idDocuments) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'idDocuments',
            doc.path,
            contentType: http_parser.MediaType.parse('image/jpeg'),
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWithdrawalSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/withdrawal/settings'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWithdrawalHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/withdrawal/history'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitKYC({
    required String fullName,
    required String dateOfBirth,
    required String address,
    required String documentType,
    required String documentNumber,
    List<File>? documentImages,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/withdrawal/kyc'),
    );

    request.headers.addAll(await _getMultipartHeaders());
    request.fields['fullName'] = fullName;
    request.fields['dateOfBirth'] = dateOfBirth;
    request.fields['address'] = address;
    request.fields['documentType'] = documentType;
    request.fields['documentNumber'] = documentNumber;

    if (documentImages != null) {
      for (var image in documentImages) {
        request.files.add(
          await http.MultipartFile.fromPath('documents', image.path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getKYCStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/withdrawal/kyc-status'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Daily Selfie APIs
  static Future<Map<String, dynamic>> submitDailySelfie(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/dailyselfie/submit'),
    );

    request.headers.addAll(await _getMultipartHeaders());
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getDailySelfies({
    String? date,
    int limit = 20,
  }) async {
    String url = '$baseUrl/dailyselfie/entries?limit=$limit';
    if (date != null) {
      url += '&date=$date';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> voteDailySelfie(String selfieId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dailyselfie/$selfieId/vote'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getDailySelfieLeaderboard({
    String type = 'daily',
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dailyselfie/leaderboard?type=$type&limit=$limit'),
        headers: await _getHeaders(),
      );

      print('Daily Selfie Leaderboard API Response: ${response.statusCode}');
      print('Daily Selfie Leaderboard API Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Daily Selfie Leaderboard API Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserSelfieStreak() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dailyselfie/streak'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getTodayChallenge() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dailyselfie/today'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Post interaction APIs
  static Future<Map<String, dynamic>> toggleBookmark(String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/bookmark'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sharePost(
    String postId, {
    String shareType = 'link',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/share'),
      headers: await _getHeaders(),
      body: jsonEncode({'shareType': shareType}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserBookmarks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/bookmarks'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPostStats(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/stats'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Store/Product APIs
  static Future<Map<String, dynamic>> getProducts({
    String? category,
    String? badge,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    String url = '$baseUrl/products?page=$page&limit=$limit';
    if (category != null) {
      url += '&category=$category';
    }
    if (badge != null) {
      url += '&badge=$badge';
    }
    if (search != null) {
      url += '&search=$search';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProduct(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getNewProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/section/new'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPopularProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/section/popular'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProductsByCategory(
    String category,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$category'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Cart APIs
  static Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
        if (size != null) 'size': size,
        if (color != null) 'color': color,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateCartItem(
    String itemId,
    int quantity,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/update/$itemId'),
      headers: await _getHeaders(),
      body: jsonEncode({'quantity': quantity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$itemId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Order APIs
  static Future<Map<String, dynamic>> createRazorpayOrder(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/create-razorpay-order'),
      headers: await _getHeaders(),
      body: jsonEncode({'amount': amount, 'currency': 'INR'}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/verify-payment'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String paymentMethod = 'razorpay',
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'items': items,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
        if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
        if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Group/Community APIs
  static Future<Map<String, dynamic>> getGroups({
    String? category,
    String? search,
  }) async {
    String url = '$baseUrl/groups?';
    if (category != null) {
      url += 'category=$category&';
    }
    if (search != null) {
      url += 'search=$search&';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getGroup(String groupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required String category,
    File? bannerImage,
    File? logoImage,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/groups'));

    request.headers.addAll(await _getMultipartHeaders());

    // Add text fields
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category'] = category;

    // Add banner image if provided
    if (bannerImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'banner',
          bannerImage.path,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ),
      );
    }

    // Add logo image if provided
    if (logoImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          logoImage.path,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> joinGroup(String groupId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/$groupId/join'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkGroupMembership(
    String groupId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/membership'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/$groupId/leave'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendGroupMessage(
    String groupId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/groups/$groupId/messages'),
      headers: await _getHeaders(),
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getGroupMessages(
    String groupId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/$groupId/messages?page=$page&limit=$limit'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMyGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/groups/my/groups'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Spin Wheel APIs
  static Future<Map<String, dynamic>> getSpinWheelStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/spin-wheel/status'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> spinWheel() async {
    final response = await http.post(
      Uri.parse('$baseUrl/spin-wheel/spin'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Achievement APIs
  static Future<Map<String, dynamic>> getUserAchievements() async {
    final response = await http.get(
      Uri.parse('$baseUrl/achievements'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkAndUnlockAchievements() async {
    final response = await http.post(
      Uri.parse('$baseUrl/achievements/check'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> initializeAchievements() async {
    final response = await http.post(
      Uri.parse('$baseUrl/achievements/init'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // SYT Weekly Submission Check
  static Future<Map<String, dynamic>> checkUserWeeklySubmission() async {
    final response = await http.get(
      Uri.parse('$baseUrl/syt/check-submission?type=weekly'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Get current competition info
  static Future<Map<String, dynamic>> getCurrentCompetition({
    String type = 'weekly',
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/syt/current-competition?type=$type'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Get user's SYT entries
  static Future<Map<String, dynamic>> getUserSYTEntries(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/syt/user/$userId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting user SYT entries: $e');
      return {'success': false, 'message': 'Failed to load SYT entries'};
    }
  }

  // Get user's liked posts
  static Future<Map<String, dynamic>> getUserLikedPosts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/user/$userId/liked'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting user liked posts: $e');
      return {'success': false, 'message': 'Failed to load liked posts'};
    }
  }

  // Get categories with product counts
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        final products = List<Map<String, dynamic>>.from(data['data']);

        // Count products by category
        final categoryCount = <String, int>{};
        for (final product in products) {
          final category = product['category'] ?? 'other';
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }

        return {'success': true, 'data': categoryCount};
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Error fetching categories: $e'};
    }
  }

  // Notification APIs
  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?page=$page&limit=$limit'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread-count'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    String notificationId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/mark-all-read'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteNotification(
    String notificationId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateNotificationSettings({
    required bool push,
    required bool email,
    required bool sms,
    required bool referral,
    required bool transaction,
    required bool community,
    required bool marketing,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/notification-settings'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'push': push,
        'email': email,
        'sms': sms,
        'referral': referral,
        'transaction': transaction,
        'community': community,
        'marketing': marketing,
      }),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }

  // Checkout APIs
  static Future<Map<String, dynamic>> checkout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/checkout'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCartRazorpayOrder() async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/create-razorpay-order'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> processPayment({
    required String paymentMethod,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart/process-payment'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'paymentMethod': paymentMethod,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      }),
    );
    return jsonDecode(response.body);
  }

  // ============ SUBSCRIPTION METHODS ============

  // Get user's subscription status
  static Future<Map<String, dynamic>> getMySubscription() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/my-subscription'),
      headers: await _getHeaders(),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }

  // Get subscription plans
  static Future<Map<String, dynamic>> getSubscriptionPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/plans'),
      headers: await _getHeaders(),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }

  // Subscribe to a plan
  static Future<Map<String, dynamic>> subscribeToPlan({
    required String planId,
    required String billingCycle,
    String? paymentMethod,
    String? transactionId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions/subscribe'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'planId': planId,
        'billingCycle': billingCycle,
        'paymentMethod': paymentMethod ?? 'coins',
        'transactionId': transactionId,
      }),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }

  // ============ PRIVACY & SECURITY METHODS ============

  // Update privacy settings
  static Future<Map<String, dynamic>> updatePrivacySettings({
    required bool profileVisibility,
    required bool dataSharing,
    required bool locationTracking,
    required bool twoFactorAuth,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/privacy-settings'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'profileVisibility': profileVisibility,
        'dataSharing': dataSharing,
        'locationTracking': locationTracking,
        'twoFactorAuth': twoFactorAuth,
      }),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }

  // Delete account
  static Future<Map<String, dynamic>> deleteAccount(String password) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/delete-account'),
      headers: await _getHeaders(),
      body: jsonEncode({'password': password}),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }

  // Download user data
  static Future<Map<String, dynamic>> downloadUserData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/download-data'),
      headers: await _getHeaders(),
    );
    final decoded = jsonDecode(response.body);
    return Map<String, dynamic>.from(decoded);
  }
}
