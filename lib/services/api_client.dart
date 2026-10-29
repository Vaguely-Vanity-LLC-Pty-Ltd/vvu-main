// VVU Unified Roof — HTTP API client for the four real backends.
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Endpoint configuration for the estate's four microservices.
class ApiConfig {
  ApiConfig._();

  static const String fluidStudio = 'http://localhost:3001';
  static const String proofbridge = 'http://localhost:3002';
  static const String ubuntuPools = 'http://localhost:3003';
  static const String safegrid = 'http://localhost:3004';
}

/// A discriminated result wrapper for API calls.
class ApiResult<T> {
  final T? data;
  final String? error;

  const ApiResult._({this.data, this.error});

  const ApiResult.ok(this.data) : error = null;
  const ApiResult.fail(this.error) : data = null;

  bool get ok => error == null;

  @override
  String toString() => ok ? 'ApiResult.ok($data)' : 'ApiResult.fail($error)';
}

Uri _u(String base, String path) => Uri.parse('$base$path');

Map<String, String> get _jsonHeaders => const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

/// Fluid Studio (creative asset pipeline) — :3001
class FluidStudioApi {
  FluidStudioApi._();

  static Future<ApiResult<Map<String, dynamic>>> health() async {
    try {
      final r = await http.get(_u(ApiConfig.fluidStudio, '/')).timeout(
        const Duration(seconds: 4),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }
}

/// Proof Bridge (evidence notarisation) — :3002
class ProofBridgeApi {
  ProofBridgeApi._();

  static Future<ApiResult<Map<String, dynamic>>> health() async {
    try {
      final r = await http.get(_u(ApiConfig.proofbridge, '/')).timeout(
        const Duration(seconds: 4),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }
}

/// Ubuntu Pools (ROSCA savings) — :3003
class UbuntuPoolsApi {
  UbuntuPoolsApi._();

  static Future<ApiResult<Map<String, dynamic>>> health() async {
    try {
      final r = await http.get(_u(ApiConfig.ubuntuPools, '/')).timeout(
        const Duration(seconds: 4),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getPools() async {
    try {
      final r = await http.get(_u(ApiConfig.ubuntuPools, '/pools')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> joinPool(String id) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.ubuntuPools, '/pools/$id/join'),
            headers: _jsonHeaders,
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> leavePool(String id) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.ubuntuPools, '/pools/$id/leave'),
            headers: _jsonHeaders,
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> createPool({
    required String name,
    required int contributionCents,
    required int cycleDays,
  }) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.ubuntuPools, '/pools'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'name': name,
              'contributionCents': contributionCents,
              'cycleDays': cycleDays,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getPosts() async {
    try {
      final r = await http.get(_u(ApiConfig.ubuntuPools, '/posts')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> createPost({
    required String author,
    required String body,
  }) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.ubuntuPools, '/posts'),
            headers: _jsonHeaders,
            body: jsonEncode({'author': author, 'body': body}),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getWormLog() async {
    try {
      final r = await http.get(_u(ApiConfig.ubuntuPools, '/worm')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }
}

/// Safe Grid (asset registry, telemetry, store) — :3004
class SafeGridApi {
  SafeGridApi._();

  static Future<ApiResult<Map<String, dynamic>>> health() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/')).timeout(
        const Duration(seconds: 4),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getAssets() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/assets')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> createAsset({
    required String name,
    required String kind,
    required double lat,
    required double lng,
  }) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.safegrid, '/assets'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'name': name,
              'kind': kind,
              'lat': lat,
              'lng': lng,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getFeeds() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/feeds')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getTraces() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/traces')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getFlags() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/flags')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> toggleFlag(
    String id,
    bool value,
  ) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.safegrid, '/flags/$id'),
            headers: _jsonHeaders,
            body: jsonEncode({'value': value}),
          )
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as Map<String, dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getDoctorChecks() async {
    try {
      final r = await http
          .get(_u(ApiConfig.safegrid, '/doctor'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<List<dynamic>>> getProducts() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/products')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> checkout({
    required List<Map<String, dynamic>> items,
    required String payerName,
    String? payerEmail,
  }) async {
    try {
      final r = await http
          .post(
            _u(ApiConfig.safegrid, '/checkout'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'items': items,
              'payerName': payerName,
              'payerEmail': payerEmail,
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

  static Future<ApiResult<List<dynamic>>> getOrders() async {
    try {
      final r = await http.get(_u(ApiConfig.safegrid, '/orders')).timeout(
        const Duration(seconds: 5),
      );
      if (r.statusCode >= 200 && r.statusCode < 300) {
        return ApiResult.ok(jsonDecode(r.body) as List<dynamic>);
      }
      return ApiResult.fail('HTTP ${r.statusCode}');
    } catch (e) {
      return ApiResult.fail(e.toString());
    }
  }
}
