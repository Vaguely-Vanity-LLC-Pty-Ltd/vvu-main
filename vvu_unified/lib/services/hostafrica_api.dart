// VVU Unified Roof — HostAfrica VPS API client.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

const String _baseUrl = 'https://api.hostafrica.com';

/// HostAfrica API key configuration.
class HostAfricaConfig {
  static String? _apiKey;

  static String? get apiKey => _apiKey;

  static bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  static void init(String key) {
    _apiKey = key;
  }
}

Map<String, String> _headers() => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (HostAfricaConfig.isConfigured)
        'Authorization': 'Bearer ${HostAfricaConfig.apiKey}',
    };

/// Client for the HostAfrica VPS/backup API.
class HostAfricaApi {
  HostAfricaApi._();

  static Future<ApiResult<Map<String, dynamic>>> health() async {
    try {
      final r = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> listVps() async {
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/vps/list'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final body = jsonDecode(r.body);
        if (body is List) return ApiResult.ok(body);
        if (body is Map && body['vps'] is List) {
          return ApiResult.ok(body['vps'] as List<dynamic>);
        }
        return ApiResult.ok([body]);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> createBackup(
    String vpsId,
  ) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/vps/create-backup'),
            headers: _headers(),
            body: jsonEncode({'vpsId': vpsId}),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> listBackups(String vpsId) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/vps/list-backups'),
            headers: _headers(),
            body: jsonEncode({'vpsId': vpsId}),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final body = jsonDecode(r.body);
        if (body is List) return ApiResult.ok(body);
        if (body is Map && body['backups'] is List) {
          return ApiResult.ok(body['backups'] as List<dynamic>);
        }
        return ApiResult.ok([body]);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> restoreBackup(
    String backupId,
  ) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/vps/restore-backup'),
            headers: _headers(),
            body: jsonEncode({'backupId': backupId}),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> createBackupSchedule(
    String vpsId,
    String frequency,
    int retention,
  ) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/vps/create-backup-schedule'),
            headers: _headers(),
            body: jsonEncode({
              'vpsId': vpsId,
              'frequency': frequency,
              'retention': retention,
            }),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> listBackupSchedules(
    String vpsId,
  ) async {
    try {
      final r = await http
          .post(
            Uri.parse('$_baseUrl/vps/list-backup-schedules'),
            headers: _headers(),
            body: jsonEncode({'vpsId': vpsId}),
          )
          .timeout(const Duration(seconds: 6));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final body = jsonDecode(r.body);
        if (body is List) return ApiResult.ok(body);
        if (body is Map && body['schedules'] is List) {
          return ApiResult.ok(body['schedules'] as List<dynamic>);
        }
        return ApiResult.ok([body]);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }
}
