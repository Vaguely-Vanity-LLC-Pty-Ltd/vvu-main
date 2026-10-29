// VVU Unified Roof — Central estate state.
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/estate.dart';
import '../services/api_client.dart';
import '../services/stitch_api.dart';
import '../services/hostafrica_api.dart';

/// A single entry in the WORM (write-once, read-many) audit chain.
class WormLogEntry {
  final int seq;
  final DateTime ts;
  final String message;
  final String hash;
  final String prevHash;

  const WormLogEntry({
    required this.seq,
    required this.ts,
    required this.message,
    required this.hash,
    required this.prevHash,
  });
}

/// Layout mode for the body region.
enum LayoutMode {
  single,
  split4,
}

extension LayoutModeX on LayoutMode {
  String get label {
    switch (this) {
      case LayoutMode.single:
        return 'SINGLE';
      case LayoutMode.split4:
        return 'SPLIT-4';
    }
  }
}

/// Build channel.
enum Environment {
  production,
  staging,
  development,
}

extension EnvironmentX on Environment {
  String get label {
    switch (this) {
      case Environment.production:
        return 'PRODUCTION';
      case Environment.staging:
        return 'STAGING';
      case Environment.development:
        return 'DEVELOPMENT';
    }
  }
}

/// Doctor check health state.
enum CheckState {
  healthy,
  degraded,
  blocked,
  running,
  unknown,
}

extension CheckStateX on CheckState {
  String get label {
    switch (this) {
      case CheckState.healthy:
        return 'HEALTHY';
      case CheckState.degraded:
        return 'DEGRADED';
      case CheckState.blocked:
        return 'BLOCKED';
      case CheckState.running:
        return 'RUNNING';
      case CheckState.unknown:
        return 'UNKNOWN';
    }
  }
}

/// Trace span status.
enum TraceStatus {
  ok,
  warn,
  error,
}

extension TraceStatusX on TraceStatus {
  String get label {
    switch (this) {
      case TraceStatus.ok:
        return 'OK';
      case TraceStatus.warn:
        return 'WARN';
      case TraceStatus.error:
        return 'ERROR';
    }
  }
}

/// A derived trace span from the WORM log.
class TraceSpan {
  final String traceId;
  final String spanId;
  final String service;
  final String operation;
  final DateTime ts;
  final TraceStatus status;

  const TraceSpan({
    required this.traceId,
    required this.spanId,
    required this.service,
    required this.operation,
    required this.ts,
    required this.status,
  });
}

/// Admin user (RBAC).
class AdminUser {
  final String id;
  final String email;
  final String role;
  final String tenant;
  final bool active;

  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.tenant,
    required this.active,
  });

  AdminUser copyWith({
    String? id,
    String? email,
    String? role,
    String? tenant,
    bool? active,
  }) =>
      AdminUser(
        id: id ?? this.id,
        email: email ?? this.email,
        role: role ?? this.role,
        tenant: tenant ?? this.tenant,
        active: active ?? this.active,
      );
}

/// Central estate state, exposed via [ChangeNotifier].
class EstateState extends ChangeNotifier {
  EstateState() {
    _seedGates();
    _seedFlags();
    _seedDoctorChecks();
    _seedUsers();
    _buildHash = _randomHash();
    _startHeartbeat();
    _startHealthTimer();
    _startFlagSyncTimer();
    _syncFromBackends();
    _appendLog('VVU UNIFIED ROOF booted · v$appVersion · $wormAnchor');
  }

  final Random _rng = Random();

  // ── Active surface & map view ───────────────────────────────────────────
  String _activeSurface = 'twin';
  String get activeSurface => _activeSurface;

  void setActiveSurface(String id) {
    if (_activeSurface == id) return;
    _activeSurface = id;
    _appendLog('surface select → $id');
    notifyListeners();
  }

  String _activeMapView = 'satellite';
  String get activeMapView => _activeMapView;

  void setMapView(String id) {
    _activeMapView = id;
    _appendLog('map view → $id');
    notifyListeners();
  }

  // ── Map controller ──────────────────────────────────────────────────────
  final MapController mapController = MapController();
  final LatLng mapCenter = const LatLng(-33.9608, 25.6022);

  // ── Inference gates ─────────────────────────────────────────────────────
  final Map<String, InferenceState> _gateState = {};
  final Map<String, VerdictKind> _gateVerdict = {};
  final Map<String, String> _gateReason = {};
  final Map<String, int> _gateRuns = {};
  final Map<String, DateTime?> _gateLastRun = {};

  void _seedGates() {
    for (final m in kFoundationModels) {
      _gateState[m.id] = InferenceState.off;
      _gateVerdict[m.id] = VerdictKind.none;
      _gateReason[m.id] = '—';
      _gateRuns[m.id] = 0;
      _gateLastRun[m.id] = null;
    }
  }

  InferenceState gateState(String id) => _gateState[id] ?? InferenceState.off;
  VerdictKind gateVerdict(String id) =>
      _gateVerdict[id] ?? VerdictKind.none;
  String gateReason(String id) => _gateReason[id] ?? '—';
  int gateRuns(String id) => _gateRuns[id] ?? 0;
  DateTime? gateLastRun(String id) => _gateLastRun[id];

  void toggleGate(String id) {
    final s = _gateState[id] ?? InferenceState.off;
    _gateState[id] =
        s == InferenceState.off ? InferenceState.armed : InferenceState.off;
    if (_gateState[id] == InferenceState.off) {
      _gateVerdict[id] = VerdictKind.none;
      _gateReason[id] = '—';
    }
    _appendLog('gate $id ${_gateState[id]!.label}');
    notifyListeners();
  }

  Future<void> runGate(String id) async {
    if (_gateState[id] != InferenceState.armed) return;
    _gateState[id] = InferenceState.running;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    final roll = _rng.nextDouble();
    VerdictKind v;
    String reason;
    if (roll > 0.66) {
      v = VerdictKind.proven;
      reason = 'Evidence sealed to WORM chain';
    } else if (roll > 0.33) {
      v = VerdictKind.inconclusive;
      reason = 'Below threshold — more samples required';
    } else {
      v = VerdictKind.blocked;
      reason = 'Sensor occlusion — operator override';
    }

    _gateState[id] = InferenceState.verdict;
    _gateVerdict[id] = v;
    _gateReason[id] = reason;
    _gateRuns[id] = (_gateRuns[id] ?? 0) + 1;
    _gateLastRun[id] = DateTime.now();
    _appendLog('gate $id verdict ${v.label} · $reason');
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (_gateState[id] == InferenceState.verdict) {
        _gateState[id] = InferenceState.armed;
        notifyListeners();
      }
    });
  }

  void armAll() {
    for (final m in kFoundationModels) {
      if (_gateState[m.id] == InferenceState.off) {
        _gateState[m.id] = InferenceState.armed;
      }
    }
    _appendLog('ARM ALL gates');
    notifyListeners();
  }

  void disarmAll() {
    for (final m in kFoundationModels) {
      _gateState[m.id] = InferenceState.off;
      _gateVerdict[m.id] = VerdictKind.none;
      _gateReason[m.id] = '—';
    }
    _appendLog('DISARM ALL gates');
    notifyListeners();
  }

  int get armedCount =>
      _gateState.values.where((s) => s != InferenceState.off).length;
  int get totalCount => kFoundationModels.length;

  // ── Takeoff posture ─────────────────────────────────────────────────────
  bool _takeoffArmed = false;
  bool get takeoffArmed => _takeoffArmed;

  void toggleTakeoff() {
    _takeoffArmed = !_takeoffArmed;
    if (_takeoffArmed) {
      armAll();
    } else {
      disarmAll();
    }
    _appendLog(_takeoffArmed ? 'TAKEOFF ARMED' : 'STAND DOWN');
    notifyListeners();
  }

  // ── Heartbeat telemetry ─────────────────────────────────────────────────
  int beat = 0;
  double pipelinePressure = 4.62;
  double flow = 187.4;
  int nodes = 1284;
  int evidenceCount = 0;
  bool chainIntact = true;

  Timer? _beatTimer;
  void _startHeartbeat() {
    _beatTimer = Timer.periodic(const Duration(milliseconds: 1100), (_) {
      beat = (beat + 1) % 1000000;
      pipelinePressure =
          4.40 + _rng.nextDouble() * 0.55; // 4.40 – 4.95
      flow = 180.0 + _rng.nextDouble() * 30.0; // 180 – 210
      nodes = 1280 + _rng.nextInt(20);
      evidenceCount += _rng.nextInt(3);
      notifyListeners();
    });
  }

  // ── WORM log ────────────────────────────────────────────────────────────
  final List<WormLogEntry> _wormLog = [];
  int _wormSeq = 0;
  String _wormPrevHash = '0000000000000000';

  String _fnv1a(String s) {
    int h = 0x811C9DC5;
    for (int i = 0; i < s.length; i++) {
      h ^= s.codeUnitAt(i);
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  void _appendLog(String message) {
    _wormSeq += 1;
    final payload = '$_wormSeq|${DateTime.now().toIso8601String()}|$message|$_wormPrevHash';
    final hash = _fnv1a(payload);
    _wormLog.add(WormLogEntry(
      seq: _wormSeq,
      ts: DateTime.now(),
      message: message,
      hash: hash,
      prevHash: _wormPrevHash,
    ));
    _wormPrevHash = hash;
    if (_wormLog.length > 500) {
      _wormLog.removeAt(0);
    }
  }

  /// Public hook for views to append to the WORM log.
  void appendLogPublic(String message) => _appendLog(message);

  List<WormLogEntry> get wormLog =>
      List.unmodifiable(_wormLog.reversed.take(200));

  // ── Feature flags ───────────────────────────────────────────────────────
  final Map<String, bool> _flags = {};
  final Map<String, String> _flagActors = {};

  static const List<String> kFlagIds = [
    'experimental_scada_grid',
    'forge_receipt_minting',
    'press_pricing_zar',
    'field_dual_tier_storage',
    'surv_clean_badges',
    'twin_hologram_mode',
    'store_live_checkout',
    'obs_remote_inspector',
  ];

  void _seedFlags() {
    for (final id in kFlagIds) {
      _flags[id] = false;
      _flagActors[id] = '—';
    }
    // Sensible defaults for a demo estate.
    _flags['experimental_scada_grid'] = false;
    _flags['store_live_checkout'] = true;
  }

  bool flag(String id) => _flags[id] ?? false;
  String flagActor(String id) => _flagActors[id] ?? '—';

  Future<void> toggleFlag(String id, String actor) async {
    final next = !(_flags[id] ?? false);
    _flags[id] = next;
    _flagActors[id] = actor;
    _appendLog('flag $id → ${next ? 'ON' : 'OFF'} by $actor');
    notifyListeners();
    // Fire-and-forget push to SafeGrid.
    SafeGridApi.toggleFlag(id, next).then((r) {
      if (!r.ok) {
        _appendLog('flag sync FAIL $id · ${r.error}');
      }
    });
  }

  Future<void> _syncFlags() async {
    final r = await SafeGridApi.getFlags();
    if (!r.ok || r.data == null) return;
    try {
      for (final item in r.data!) {
        final m = item as Map<String, dynamic>;
        final id = m['id'] as String?;
        final value = m['value'] as bool?;
        if (id != null && value != null && _flags.containsKey(id)) {
          _flags[id] = value;
        }
      }
      notifyListeners();
    } catch (_) {
      // Ignore malformed payload.
    }
  }

  // ── Version ─────────────────────────────────────────────────────────────
  final String appVersion = '2.4.1';
  final String appChannel = 'Stable';
  final String wormAnchor = 'E965B01D';
  late final String _buildHash;
  String get buildHash => _buildHash;

  Environment _environment = Environment.production;
  Environment get environment => _environment;
  void setEnvironment(Environment e) {
    _environment = e;
    _appendLog('environment → ${e.label}');
    notifyListeners();
  }

  bool _updateAvailable = false;
  bool get updateAvailable => _updateAvailable;

  void forceFrontendUpdate() {
    _updateAvailable = true;
    _buildHash = _randomHash();
    _appendLog('FORCE FRONTEND UPDATE · build ${_buildHash}');
    notifyListeners();
  }

  void acknowledgeUpdate() {
    _updateAvailable = false;
    _appendLog('update acknowledged');
    notifyListeners();
  }

  String _randomHash() {
    final b = List<int>.generate(4, (_) => _rng.nextInt(256));
    return b
        .map((x) => x.toRadixString(16).toUpperCase().padLeft(2, '0'))
        .join();
  }

  // ── Layout ──────────────────────────────────────────────────────────────
  LayoutMode _layout = LayoutMode.single;
  LayoutMode get layout => _layout;

  void setLayout(LayoutMode m) {
    _layout = m;
    _appendLog('layout → ${m.label}');
    notifyListeners();
  }

  // ── Doctor ──────────────────────────────────────────────────────────────
  final Map<String, CheckState> _doctorChecks = {};

  static const List<String> kDoctorCheckIds = [
    'fluid_studio',
    'proof_bridge',
    'ubuntu_pools',
    'safegrid',
    'flutter_runtime',
    'worm_chain',
    'stitch_gateway',
    'hostafrica_gateway',
  ];

  void _seedDoctorChecks() {
    for (final id in kDoctorCheckIds) {
      _doctorChecks[id] = CheckState.unknown;
    }
  }

  CheckState doctorCheck(String id) => _doctorChecks[id] ?? CheckState.unknown;
  Map<String, CheckState> get doctorChecks => Map.unmodifiable(_doctorChecks);

  Future<void> runDoctor() async {
    for (final id in kDoctorCheckIds) {
      _doctorChecks[id] = CheckState.running;
    }
    notifyListeners();

    final results = await Future.wait([
      _pingBackend('fluid_studio', () => FluidStudioApi.health()),
      _pingBackend('proof_bridge', () => ProofBridgeApi.health()),
      _pingBackend('ubuntu_pools', () => UbuntuPoolsApi.health()),
      _pingBackend('safegrid', () => SafeGridApi.health()),
    ]);

    // The four pings already wrote their state. Now resolve derived checks.
    _doctorChecks['flutter_runtime'] = CheckState.healthy;
    _doctorChecks['worm_chain'] =
        chainIntact ? CheckState.healthy : CheckState.degraded;
    _doctorChecks['stitch_gateway'] =
        StitchApi.isConfigured ? CheckState.healthy : CheckState.degraded;
    _doctorChecks['hostafrica_gateway'] =
        HostAfricaConfig.isConfigured ? CheckState.healthy : CheckState.degraded;

    // Record the 4 ping results (they were written in _pingBackend already).
    for (final r in results) {
      _doctorChecks[r.$1] = r.$2;
    }

    _appendLog('doctor run complete · ${_countHealthy()} healthy');
    notifyListeners();
  }

  int _countHealthy() =>
      _doctorChecks.values.where((s) => s == CheckState.healthy).length;

  Future<(String, CheckState)> _pingBackend(
    String id,
    Future<ApiResult<dynamic>> Function() ping,
  ) async {
    final r = await ping();
    final state = r.ok ? CheckState.healthy : CheckState.blocked;
    return (id, state);
  }

  // ── Canary ──────────────────────────────────────────────────────────────
  int canaryRuns = 0;
  String canaryLastStatus = 'IDLE';
  Timer? _canaryTimer;

  void startCanary() {
    if (_canaryTimer != null) return;
    _canaryTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      canaryRuns += 1;
      final results = await Future.wait([
        FluidStudioApi.health(),
        ProofBridgeApi.health(),
        UbuntuPoolsApi.health(),
        SafeGridApi.health(),
      ]);
      final okCount = results.where((r) => r.ok).length;
      canaryLastStatus = '$okCount/4 UP';
      _appendLog('canary #$canaryRuns · $canaryLastStatus');
      notifyListeners();
    });
    canaryLastStatus = 'RUNNING';
    _appendLog('canary START');
    notifyListeners();
  }

  void stopCanary() {
    _canaryTimer?.cancel();
    _canaryTimer = null;
    canaryLastStatus = 'STOPPED';
    _appendLog('canary STOP');
    notifyListeners();
  }

  bool get canaryRunning => _canaryTimer != null;

  // ── Traces (derived from worm log) ──────────────────────────────────────
  List<TraceSpan> get traces {
    final out = <TraceSpan>[];
    final recent = wormLog.take(40).toList().reversed;
    for (final e in recent) {
      final parts = e.message.split(' ');
      final op = parts.isNotEmpty ? parts.first : 'unknown';
      final svc = _inferService(e.message);
      final status = e.message.contains('FAIL') || e.message.contains('BLOCKED')
          ? TraceStatus.error
          : e.message.contains('warn') || e.message.contains('DEGRADED')
              ? TraceStatus.warn
              : TraceStatus.ok;
      out.add(TraceSpan(
        traceId: 'T-${e.seq.toRadixString(16).toUpperCase().padLeft(4, '0')}',
        spanId: 'S-${e.hash}',
        service: svc,
        operation: op,
        ts: e.ts,
        status: status,
      ));
    }
    return out;
  }

  String _inferService(String message) {
    final m = message.toLowerCase();
    if (m.contains('gate')) return 'inference-gateway';
    if (m.contains('flag')) return 'safegrid';
    if (m.contains('canary') || m.contains('doctor')) return 'ops';
    if (m.contains('surface')) return 'navigator';
    if (m.contains('payment') || m.contains('stitch')) return 'stitch';
    if (m.contains('backup') || m.contains('vps')) return 'hostafrica';
    if (m.contains('pool') || m.contains('rosca')) return 'ubuntu-pools';
    if (m.contains('environment')) return 'config';
    return 'estate';
  }

  // ── Admin ───────────────────────────────────────────────────────────────
  final List<AdminUser> _users = [];

  void _seedUsers() {
    _users.addAll([
      const AdminUser(
        id: 'u1',
        email: 'ops@vvu.za',
        role: 'ADMIN',
        tenant: 'gqeberha',
        active: true,
      ),
      const AdminUser(
        id: 'u2',
        email: 'surveyor@vvu.za',
        role: 'EDITOR',
        tenant: 'gqeberha',
        active: true,
      ),
      const AdminUser(
        id: 'u3',
        email: 'viewer@vvu.za',
        role: 'VIEWER',
        tenant: 'gqeberha',
        active: true,
      ),
      const AdminUser(
        id: 'u4',
        email: 'tenant@vvu.za',
        role: 'TENANT',
        tenant: 'jozi',
        active: false,
      ),
    ]);
  }

  List<AdminUser> get users => List.unmodifiable(_users);

  void provisionTenant({required String email, required String tenant}) {
    final id = 'u${_users.length + 1}';
    _users.add(AdminUser(
      id: id,
      email: email,
      role: 'TENANT',
      tenant: tenant,
      active: true,
    ));
    _appendLog('tenant provisioned · $email @ $tenant');
    notifyListeners();
  }

  void toggleUserActive(String id) {
    final i = _users.indexWhere((u) => u.id == id);
    if (i < 0) return;
    _users[i] = _users[i].copyWith(active: !_users[i].active);
    _appendLog('user $id ${_users[i].active ? 'ACTIVATED' : 'DEACTIVATED'}');
    notifyListeners();
  }

  // ── Backend health ──────────────────────────────────────────────────────
  final Map<String, bool> _backendHealth = {
    'fluid_studio': false,
    'proof_bridge': false,
    'ubuntu_pools': false,
    'safegrid': false,
  };

  Map<String, bool> get backendHealth => Map.unmodifiable(_backendHealth);

  int get backendsOnline => _backendHealth.values.where((v) => v).length;

  Future<void> _checkBackendHealth() async {
    final results = await Future.wait([
      FluidStudioApi.health(),
      ProofBridgeApi.health(),
      UbuntuPoolsApi.health(),
      SafeGridApi.health(),
    ]);
    _backendHealth['fluid_studio'] = results[0].ok;
    _backendHealth['proof_bridge'] = results[1].ok;
    _backendHealth['ubuntu_pools'] = results[2].ok;
    _backendHealth['safegrid'] = results[3].ok;
    notifyListeners();
  }

  Future<void> _syncFromBackends() async {
    await _checkBackendHealth();
    await _syncFlags();
  }

  Timer? _healthTimer;
  void _startHealthTimer() {
    _healthTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkBackendHealth();
    });
  }

  Timer? _flagSyncTimer;
  void _startFlagSyncTimer() {
    _flagSyncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _syncFlags();
    });
  }

  // ── Dispose ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _beatTimer?.cancel();
    _healthTimer?.cancel();
    _flagSyncTimer?.cancel();
    _canaryTimer?.cancel();
    super.dispose();
  }
}
