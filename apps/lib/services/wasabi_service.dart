import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class WasabiService {
  static final WasabiService _instance = WasabiService._internal();
  factory WasabiService() => _instance;
  WasabiService._internal();

  bool _initialized = false;

  // Wasabi credentials
  static const String _accessKey = 'LZ4Q3024I5KUQPLT9FDO';
  static const String _secretKey = 'tzMQuJKnHQXjCeis6ZKZb5HNjDFGsXi4KsG6A5C4';
  static const String _bucketName = 'showofforiginal';
  static const String _region = 'ap-southeast-1';
  static const String _endpoint = 's3.ap-southeast-1.wasabisys.com';

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    print('✅ Wasabi S3 initialized');
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.mp4':
      case '.mov':
        return 'video/mp4';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  List<int> _hmacSha256(List<int> key, String data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(data)).bytes;
  }

  String _generateSignatureV4({
    required String method,
    required String canonicalUri,
    required String dateStamp,
    required String amzDate,
    required String contentType,
    required String payloadHash,
  }) {
    // Step 1: Create canonical request
    final canonicalHeaders =
        'host:$_endpoint\nx-amz-acl:public-read\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';
    final signedHeaders = 'host;x-amz-acl;x-amz-content-sha256;x-amz-date';

    final canonicalRequest =
        '$method\n$canonicalUri\n\n$canonicalHeaders\n$signedHeaders\n$payloadHash';

    // Step 2: Create string to sign
    final algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$_region/s3/aws4_request';
    final canonicalRequestHash = sha256
        .convert(utf8.encode(canonicalRequest))
        .toString();

    final stringToSign =
        '$algorithm\n$amzDate\n$credentialScope\n$canonicalRequestHash';

    // Step 3: Calculate signature
    final kDate = _hmacSha256(utf8.encode('AWS4$_secretKey'), dateStamp);
    final kRegion = _hmacSha256(kDate, _region);
    final kService = _hmacSha256(kRegion, 's3');
    final kSigning = _hmacSha256(kService, 'aws4_request');
    final signature = Hmac(
      sha256,
      kSigning,
    ).convert(utf8.encode(stringToSign)).toString();

    return signature;
  }

  Future<String> uploadFile({
    required File file,
    required String folder, // 'videos' or 'images'
  }) async {
    if (!_initialized) initialize();

    try {
      // Generate unique filename
      final uuid = const Uuid().v4();
      final extension = path.extension(file.path);
      final fileName = '$folder/$uuid$extension';
      final contentType = _getContentType(extension);

      print('📤 Uploading to Wasabi: $fileName');

      // Read file bytes
      final fileBytes = await file.readAsBytes();

      // Calculate payload hash
      final payloadHash = sha256.convert(fileBytes).toString();

      // Create date for signature
      final now = DateTime.now().toUtc();
      final dateStamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final amzDate =
          '${dateStamp}T${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z';

      // Generate signature
      final signature = _generateSignatureV4(
        method: 'PUT',
        canonicalUri: '/$_bucketName/$fileName',
        dateStamp: dateStamp,
        amzDate: amzDate,
        contentType: contentType,
        payloadHash: payloadHash,
      );

      // Create authorization header
      final credentialScope = '$dateStamp/$_region/s3/aws4_request';
      final authorization =
          'AWS4-HMAC-SHA256 Credential=$_accessKey/$credentialScope, SignedHeaders=host;x-amz-acl;x-amz-content-sha256;x-amz-date, Signature=$signature';

      // Upload using PUT request with AWS Signature V4
      final url = 'https://$_endpoint/$_bucketName/$fileName';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Host': _endpoint,
          'Content-Type': contentType,
          'x-amz-acl': 'public-read',
          'x-amz-content-sha256': payloadHash,
          'x-amz-date': amzDate,
          'Authorization': authorization,
        },
        body: fileBytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Upload successful: $url');
        return url;
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Wasabi upload error: $e');
      rethrow;
    }
  }

  Future<String> uploadVideo(File videoFile) async {
    return await uploadFile(file: videoFile, folder: 'videos');
  }

  Future<String> uploadImage(File imageFile) async {
    return await uploadFile(file: imageFile, folder: 'images');
  }
}
