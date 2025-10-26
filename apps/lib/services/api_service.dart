import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'storage_service.dart';
import '../config/api_config.dart';

class ApiService {
  static String
  get baseUrl => ApiConfig.baseUrl;

  // Helper function to construct full image URLs
  static String
  getImageUrl(
    String? path,
  ) {
    if (path ==
            null ||
        path.isEmpty)
      return '';
    if (path.startsWith(
          'http://',
        ) ||
        path.startsWith(
          'https://',
        )) {
      return path;
    }
    if (path.startsWith(
      '/',
    )) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }

  static Future<
    Map<
      String,
      String
    >
  >
  _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token !=
          null)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<
    Map<
      String,
      String
    >
  >
  _getMultipartHeaders() async {
    final token = await StorageService.getToken();
    return {
      if (token !=
          null)
        'Authorization': 'Bearer $token',
    };
  }

  // Auth APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  register({
    required String username,
    required String displayName,
    required String password,
    String? email,
    String? phone,
    String? referralCode,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/register',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'username': username,
          'displayName': displayName,
          'password': password,
          if (email !=
              null)
            'email': email,
          if (phone !=
              null)
            'phone': phone,
          if (referralCode !=
              null)
            'referralCode': referralCode,
        },
      ),
    );

    final data = jsonDecode(
      response.body,
    );
    if (response.statusCode ==
        201) {
      await StorageService.saveToken(
        data['data']['token'],
      );
      await StorageService.saveUser(
        data['data']['user'],
      );
    }
    return data;
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/login',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      ),
    );

    final data = jsonDecode(
      response.body,
    );
    if (response.statusCode ==
        200) {
      await StorageService.saveToken(
        data['data']['token'],
      );
      await StorageService.saveUser(
        data['data']['user'],
      );
    }
    return data;
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getMe() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/auth/me',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  sendOTP({
    String? phone,
    String? email,
    String? countryCode,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/send-otp',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          if (phone !=
              null)
            'phone': phone,
          if (email !=
              null)
            'email': email,
          if (countryCode !=
              null)
            'countryCode': countryCode,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  verifyOTP({
    String? phone,
    String? email,
    String? countryCode,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/verify-otp',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          if (phone !=
              null)
            'phone': phone,
          if (email !=
              null)
            'email': email,
          if (countryCode !=
              null)
            'countryCode': countryCode,
          'otp': otp,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  checkUsername(
    String username,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/check-username',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'username': username,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Profile APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  updateProfile({
    String? username,
    String? displayName,
    String? bio,
    List<
      String
    >?
    interests,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/profile',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          if (username !=
              null)
            'username': username,
          if (displayName !=
              null)
            'displayName': displayName,
          if (bio !=
              null)
            'bio': bio,
          if (interests !=
              null)
            'interests': interests,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  uploadProfilePicture(
    File imageFile,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/profile/picture',
      ),
    );

    request.headers.addAll(
      await _getMultipartHeaders(),
    );

    // Get file extension to determine content type
    final extension = imageFile.path
        .split(
          '.',
        )
        .last
        .toLowerCase();
    String contentType = 'image/jpeg';
    if (extension ==
        'png') {
      contentType = 'image/png';
    } else if (extension ==
        'webp') {
      contentType = 'image/webp';
    } else if (extension ==
            'jpg' ||
        extension ==
            'jpeg') {
      contentType = 'image/jpeg';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http_parser.MediaType.parse(
          contentType,
        ),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getUserProfile(
    String username,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/profile/$username',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getMyStats() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/profile/stats',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  searchUsers(
    String query,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/users/search?q=$query',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Post APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  createPost({
    required File mediaFile,
    String? caption,
    List<
      String
    >?
    hashtags,
    String? type,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/posts',
      ),
    );

    request.headers.addAll(
      await _getMultipartHeaders(),
    );

    // Determine content type from file extension
    final extension = mediaFile.path
        .split(
          '.',
        )
        .last
        .toLowerCase();
    String contentType;
    if (extension ==
            'mp4' ||
        extension ==
            'mov' ||
        extension ==
            'avi') {
      contentType = 'video/mp4';
    } else if (extension ==
        'png') {
      contentType = 'image/png';
    } else if (extension ==
        'webp') {
      contentType = 'image/webp';
    } else {
      contentType = 'image/jpeg';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'media',
        mediaFile.path,
        contentType: http_parser.MediaType.parse(
          contentType,
        ),
      ),
    );

    if (caption !=
        null)
      request.fields['caption'] = caption;
    if (hashtags !=
        null)
      request.fields['hashtags'] = hashtags.join(
        ',',
      );
    if (type !=
        null)
      request.fields['type'] = type;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getFeed({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts/feed?page=$page&limit=$limit',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getUserPosts(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts/user/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  toggleLike(
    String postId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/posts/$postId/like',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  addComment(
    String postId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/posts/$postId/comment',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'text': text,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getComments(
    String postId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts/$postId/comments',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  incrementView(
    String postId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/posts/$postId/view',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Follow APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  followUser(
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/follow/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  unfollowUser(
    String userId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/follow/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getFollowers(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/follow/followers/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getFollowing(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/follow/following/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  checkFollowing(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/follow/check/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // SYT APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  submitSYTEntry({
    required File videoFile,
    required String title,
    required String category,
    required String competitionType,
    String? description,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/syt/submit',
      ),
    );

    request.headers.addAll(
      await _getMultipartHeaders(),
    );

    // Set video content type
    request.files.add(
      await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
        contentType: http_parser.MediaType.parse(
          'video/mp4',
        ),
      ),
    );
    request.fields['title'] = title;
    request.fields['category'] = category;
    request.fields['competitionType'] = competitionType;
    if (description !=
        null)
      request.fields['description'] = description;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getSYTEntries({
    String? type,
    String? period,
    String? filter,
  }) async {
    String url = '$baseUrl/syt/entries?';
    if (type !=
        null)
      url += 'type=$type&';
    if (period !=
        null)
      url += 'period=$period&';
    if (filter !=
        null)
      url += 'filter=$filter&';

    final response = await http.get(
      Uri.parse(
        url,
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  voteSYTEntry(
    String entryId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/syt/$entryId/vote',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getSYTLeaderboard({
    String type = 'weekly',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/syt/leaderboard?type=$type',
        ),
        headers: await _getHeaders(),
      );

      print(
        'SYT Leaderboard API Response: ${response.statusCode}',
      );
      print(
        'SYT Leaderboard API Body: ${response.body}',
      );

      if (response.statusCode ==
          200) {
        return jsonDecode(
          response.body,
        );
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (
      e
    ) {
      print(
        'SYT Leaderboard API Error: $e',
      );
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Chat APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  getMessages(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/chat/$userId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  sendMessage(
    String userId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/chat/$userId',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'text': text,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getConversations() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/chat/conversations',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Coin APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  watchAd() async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/coins/watch-ad',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  spinWheel() async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/coins/spin-wheel',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/coins/transactions?page=$page&limit=$limit',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  sendGift({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/coins/gift',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'recipientId': recipientId,
          'amount': amount,
          if (message !=
              null)
            'message': message,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getCoinBalance() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/coins/balance',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Withdrawal APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  requestWithdrawal({
    required int coinAmount,
    required String method,
    Map<
      String,
      dynamic
    >?
    bankDetails,
    String? walletAddress,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/withdrawal/request',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'coinAmount': coinAmount,
          'method': method,
          if (bankDetails !=
              null)
            'bankDetails': bankDetails,
          if (walletAddress !=
              null)
            'walletAddress': walletAddress,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getWithdrawalHistory() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/withdrawal/history',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  submitKYC({
    required String fullName,
    required String dateOfBirth,
    required String address,
    required String documentType,
    required String documentNumber,
    List<
      File
    >?
    documentImages,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/withdrawal/kyc',
      ),
    );

    request.headers.addAll(
      await _getMultipartHeaders(),
    );
    request.fields['fullName'] = fullName;
    request.fields['dateOfBirth'] = dateOfBirth;
    request.fields['address'] = address;
    request.fields['documentType'] = documentType;
    request.fields['documentNumber'] = documentNumber;

    if (documentImages !=
        null) {
      for (var image in documentImages) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documents',
            image.path,
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getKYCStatus() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/withdrawal/kyc-status',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Daily Selfie APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  submitDailySelfie(
    File imageFile,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/dailyselfie/submit',
      ),
    );

    request.headers.addAll(
      await _getMultipartHeaders(),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getDailySelfies({
    String? date,
    int limit = 20,
  }) async {
    String url = '$baseUrl/dailyselfie/entries?limit=$limit';
    if (date !=
        null) {
      url += '&date=$date';
    }

    final response = await http.get(
      Uri.parse(
        url,
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  voteDailySelfie(
    String selfieId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/dailyselfie/$selfieId/vote',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getDailySelfieLeaderboard({
    String type = 'daily',
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/dailyselfie/leaderboard?type=$type&limit=$limit',
        ),
        headers: await _getHeaders(),
      );

      print(
        'Daily Selfie Leaderboard API Response: ${response.statusCode}',
      );
      print(
        'Daily Selfie Leaderboard API Body: ${response.body}',
      );

      if (response.statusCode ==
          200) {
        return jsonDecode(
          response.body,
        );
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (
      e
    ) {
      print(
        'Daily Selfie Leaderboard API Error: $e',
      );
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getUserSelfieStreak() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/dailyselfie/streak',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getTodayChallenge() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/dailyselfie/today',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Post interaction APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  toggleBookmark(
    String postId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/posts/$postId/bookmark',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  sharePost(
    String postId, {
    String shareType = 'link',
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/posts/$postId/share',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'shareType': shareType,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getUserBookmarks() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts/bookmarks',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getPostStats(
    String postId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts/$postId/stats',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Store/Product APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  getProducts({
    String? category,
    String? badge,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    String url = '$baseUrl/products?page=$page&limit=$limit';
    if (category !=
        null)
      url += '&category=$category';
    if (badge !=
        null)
      url += '&badge=$badge';
    if (search !=
        null)
      url += '&search=$search';

    final response = await http.get(
      Uri.parse(
        url,
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getProduct(
    String productId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/$productId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getNewProducts() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/section/new',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getPopularProducts() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/section/popular',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getProductsByCategory(
    String category,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/products/category/$category',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Cart APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  getCart() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/cart',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  addToCart({
    required String productId,
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/cart/add',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'productId': productId,
          'quantity': quantity,
          if (size !=
              null)
            'size': size,
          if (color !=
              null)
            'color': color,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  updateCartItem(
    String itemId,
    int quantity,
  ) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/cart/update/$itemId',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'quantity': quantity,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  removeFromCart(
    String itemId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/cart/remove/$itemId',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  // Order APIs
  static Future<
    Map<
      String,
      dynamic
    >
  >
  createRazorpayOrder(
    double amount,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/orders/create-razorpay-order',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'amount': amount,
          'currency': 'INR',
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/orders/verify-payment',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  createOrder({
    required List<
      Map<
        String,
        dynamic
      >
    >
    items,
    required Map<
      String,
      dynamic
    >
    shippingAddress,
    String paymentMethod = 'razorpay',
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/orders',
      ),
      headers: await _getHeaders(),
      body: jsonEncode(
        {
          'items': items,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
          if (razorpayOrderId !=
              null)
            'razorpayOrderId': razorpayOrderId,
          if (razorpayPaymentId !=
              null)
            'razorpayPaymentId': razorpayPaymentId,
          if (razorpaySignature !=
              null)
            'razorpaySignature': razorpaySignature,
        },
      ),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  getOrders() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/orders',
      ),
      headers: await _getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }
}
