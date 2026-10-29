// VVU Unified Roof — Stitch Express API client.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

const String _baseUrl = 'https://express.stitch.money';

/// Stitch OAuth client credentials.
class StitchConfig {
  final String clientId;
  final String clientSecret;

  const StitchConfig({required this.clientId, required this.clientSecret});
}

/// A cached Stitch access token with expiry.
class StitchToken {
  final String accessToken;
  final DateTime expiresAt;

  const StitchToken({required this.accessToken, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Singleton client for the Stitch Express API.
class StitchApi {
  StitchApi._();

  static StitchConfig? _config;
  static StitchToken? _cachedToken;

  static void init({
    required String clientId,
    required String clientSecret,
  }) {
    _config = StitchConfig(
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }

  static bool get isConfigured => _config != null;

  /// Obtain (or return cached) Stitch client-credentials access token.
  static Future<String?> _getToken() async {
    if (_config == null) return null;
    if (_cachedToken != null && !_cachedToken!.isExpired) {
      return _cachedToken!.accessToken;
    }
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/token'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'clientId': _config!.clientId,
              'clientSecret': _config!.clientSecret,
              'grantType': 'client_credentials',
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode < 200 || r.statusCode >= 300) return null;
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final token = body['accessToken'] as String?;
      if (token == null) return null;
      _cachedToken = StitchToken(
        accessToken: token,
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );
      return token;
    } catch (_) {
      return null;
    }
  }

  static Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Create a Stitch payment link.
  static Future<ApiResult<Map<String, dynamic>>> createPaymentLink({
    required int amountCents,
    required String payerName,
    required String merchantReference,
    String? payerEmail,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return const ApiResult.fail('Stitch not configured or token request failed');
    }
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/payment-links'),
            headers: _authHeaders(token),
            body: jsonEncode({
              'amountCents': amountCents,
              'payerName': payerName,
              'merchantReference': merchantReference,
              'payerEmail': payerEmail,
              'currency': 'ZAR',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return ApiResult.fail('HTTP ${r.statusCode}: ${r.body}');
      }
      return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  /// Fetch account balance.
  static Future<ApiResult<Map<String, dynamic>>> getBalance() async {
    final token = await _getToken();
    if (token == null) {
      return const ApiResult.fail('Stitch not configured or token request failed');
    }
    try {
      final r = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/balance'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return ApiResult.fail('HTTP ${r.statusCode}');
      }
      return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  /// List recent payments.
  static Future<ApiResult<List<dynamic>>> listPayments() async {
    final token = await _getToken();
    if (token == null) {
      return const ApiResult.fail('Stitch not configured or token request failed');
    }
    try {
      final r = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/payments'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return ApiResult.fail('HTTP ${r.statusCode}');
      }
      return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  /// Create a recurring subscription.
  static Future<ApiResult<Map<String, dynamic>>> createSubscription({
    required int amountCents,
    required String payerName,
    required String planId,
    String? payerEmail,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return const ApiResult.fail('Stitch not configured or token request failed');
    }
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/subscriptions'),
            headers: _authHeaders(token),
            body: jsonEncode({
              'amountCents': amountCents,
              'payerName': payerName,
              'planId': planId,
              'payerEmail': payerEmail,
              'currency': 'ZAR',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return ApiResult.fail('HTTP ${r.statusCode}: ${r.body}');
      }
      return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  /// Refund a payment.
  static Future<ApiResult<Map<String, dynamic>>> refund(
    String paymentId,
    int amountCents,
    String reason,
  ) async {
    final token = await _getToken();
    if (token == null) {
      return const ApiResult.fail('Stitch not configured or token request failed');
    }
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/payments/$paymentId/refund'),
            headers: _authHeaders(token),
            body: jsonEncode({
              'amountCents': amountCents,
              'reason': reason,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return ApiResult.fail('HTTP ${r.statusCode}: ${r.body}');
      }
      return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  /// Register a webhook endpoint.
  static Future<ApiResult<Map<String, dynamic>>> registerWebhook(
    String url,
  ) async {
    final token = await _getToken();
    if (token == null) {
      return const ApiResult.fail('Stitch not configured or token request failed');
    }
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/api/v1/webhooks'),
            headers: _authHeaders(token),
            body: jsonEncode({'url': url}),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return ApiResult.fail('HTTP ${r.statusCode}: ${r.body}');
      }
      return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }
}
