// VVU Unified Roof — Estate data models.
import 'package:flutter/material.dart';
import '../widgets/tokens.dart';

/// A foundation model (inference gate) powering the estate.
class FoundationModel {
  final String id;
  final String name;
  final String shortName;
  final String classLabel;
  final String job;
  final String threshold;
  final IconData icon;
  final Color iconColor;

  const FoundationModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.classLabel,
    required this.job,
    required this.threshold,
    required this.icon,
    required this.iconColor,
  });
}

/// The 5 canonical foundation models powering the estate's inference gates.
const List<FoundationModel> kFoundationModels = [
  FoundationModel(
    id: 'dtc',
    name: 'DTC',
    shortName: 'DTC',
    classLabel: 'VISUAL',
    job: 'Photorealistic 3D mesh retrieval',
    threshold: '0.90 confidence',
    icon: Icons.view_in_ar_rounded,
    iconColor: Color(0xFF4DD2FF),
  ),
  FoundationModel(
    id: 'prithvi',
    name: 'PRITHVI-EO-2.0-600M',
    shortName: 'PRITHVI',
    classLabel: 'MACRO',
    job: 'Flood, wildfire, crop prediction from satellite',
    threshold: '0.85 flood probability',
    icon: Icons.public_rounded,
    iconColor: Color(0xFF3DD68C),
  ),
  FoundationModel(
    id: 'msfmamba',
    name: 'MSFMAMBA-TINY',
    shortName: 'MSFMAMBA',
    classLabel: 'TACTICAL',
    job: 'Fuses HSI, LiDAR, SAR at 60 FPS',
    threshold: '0.95 confidence',
    icon: Icons.gps_fixed_rounded,
    iconColor: Color(0xFFFFB84D),
  ),
  FoundationModel(
    id: 'iride',
    name: 'IRIDE NIMBUS (DInSAR)',
    shortName: 'IRIDE',
    classLabel: 'STRUCTURAL',
    job: 'Millimetre-level structural deformation',
    threshold: '1.5 mm displacement',
    icon: Icons.graphic_eq_rounded,
    iconColor: Color(0xFFB388FF),
  ),
  FoundationModel(
    id: 'vfms_survey',
    name: 'Vision Foundation Models Survey',
    shortName: 'VFMS',
    classLabel: 'REGISTRY',
    job: 'Tech radar and benchmark catalogue',
    threshold: 'n/a',
    icon: Icons.menu_book_rounded,
    iconColor: Color(0xFFFF8A80),
  ),
];

/// Lifecycle of a single inference gate.
enum InferenceState {
  off,
  armed,
  running,
  verdict,
}

extension InferenceStateX on InferenceState {
  String get label {
    switch (this) {
      case InferenceState.off:
        return 'OFF';
      case InferenceState.armed:
        return 'ARMED';
      case InferenceState.running:
        return 'RUNNING';
      case InferenceState.verdict:
        return 'VERDICT';
    }
  }

  Color get color {
    switch (this) {
      case InferenceState.off:
        return VvuColors.textFaint;
      case InferenceState.armed:
        return VvuColors.armed;
      case InferenceState.running:
        return VvuColors.beat;
      case InferenceState.verdict:
        return VvuColors.studio;
    }
  }
}

/// Verdict returned by an inference gate.
enum VerdictKind {
  proven,
  inconclusive,
  blocked,
  none,
}

extension VerdictKindX on VerdictKind {
  String get label {
    switch (this) {
      case VerdictKind.proven:
        return 'PROVEN';
      case VerdictKind.inconclusive:
        return 'INCONCLUSIVE';
      case VerdictKind.blocked:
        return 'BLOCKED';
      case VerdictKind.none:
        return '—';
    }
  }

  Color get color {
    switch (this) {
      case VerdictKind.proven:
        return VvuColors.armed;
      case VerdictKind.inconclusive:
        return VvuColors.warn;
      case VerdictKind.blocked:
        return VvuColors.danger;
      case VerdictKind.none:
        return VvuColors.textFaint;
    }
  }
}

/// A map view (basemap) selectable from the map dropdown.
class MapViewEntry {
  final String id;
  final String name;
  final String tile;
  final String epistemics;
  final IconData icon;
  final String tileUrlPattern;
  final String attribution;
  final bool synthetic;

  const MapViewEntry({
    required this.id,
    required this.name,
    required this.tile,
    required this.epistemics,
    required this.icon,
    required this.tileUrlPattern,
    required this.attribution,
    this.synthetic = false,
  });
}

/// The 9 selectable map views.
const List<MapViewEntry> kMapViews = [
  MapViewEntry(
    id: 'street',
    name: 'STREET',
    tile: 'OpenStreetMap',
    epistemics: 'CROWD-SOURCED · BASELINE',
    icon: Icons.map_rounded,
    tileUrlPattern: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
  ),
  MapViewEntry(
    id: 'satellite',
    name: 'SATELLITE',
    tile: 'Esri World Imagery',
    epistemics: 'OPTICAL · VHR',
    icon: Icons.satellite_alt_rounded,
    tileUrlPattern:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '© Esri, Maxar, Earthstar Geographics',
  ),
  MapViewEntry(
    id: 'terrain',
    name: 'TERRAIN',
    tile: 'OpenTopoMap',
    epistemics: 'DEM · CARTOGRAPHIC',
    icon: Icons.terrain_rounded,
    tileUrlPattern: 'https://a.tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: '© OpenTopoMap (CC-BY-SA)',
  ),
  MapViewEntry(
    id: 'google-street',
    name: 'GOOGLE STREET',
    tile: 'Google Roads',
    epistemics: 'COMMERCIAL · ROADS',
    icon: Icons.directions_rounded,
    tileUrlPattern: 'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}',
    attribution: '© Google',
  ),
  MapViewEntry(
    id: 'google-sat',
    name: 'GOOGLE SAT',
    tile: 'Google Satellite',
    epistemics: 'COMMERCIAL · OPTICAL',
    icon: Icons.satellite_rounded,
    tileUrlPattern: 'https://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}',
    attribution: '© Google',
  ),
  MapViewEntry(
    id: 'openlayers',
    name: 'OPENLAYERS',
    tile: 'OpenLayers WMS',
    epistemics: 'OPEN · PROTOCOL',
    icon: Icons.layers_rounded,
    tileUrlPattern: 'https://ows.mundialis.de/services/service?',
    attribution: '© OpenLayers contributors',
  ),
  MapViewEntry(
    id: 'twin-mesh',
    name: 'TWIN-MESH',
    tile: 'Synthetic photogrammetric mesh',
    epistemics: 'SYNTHETIC · DTC',
    icon: Icons.threed_rotation_rounded,
    tileUrlPattern: '',
    attribution: 'VVU Synthetic Mesh',
    synthetic: true,
  ),
  MapViewEntry(
    id: 'dinsar-overlay',
    name: 'DInSAR OVERLAY',
    tile: 'Synthetic interferogram',
    epistemics: 'SYNTHETIC · IRIDE',
    icon: Icons.graphic_eq_rounded,
    tileUrlPattern: '',
    attribution: 'VVU Synthetic Interferogram',
    synthetic: true,
  ),
  MapViewEntry(
    id: 'fused-tactical',
    name: 'FUSED TACTICAL',
    tile: 'Synthetic sensor fusion',
    epistemics: 'SYNTHETIC · MSFMAMBA',
    icon: Icons.gps_fixed_rounded,
    tileUrlPattern: '',
    attribution: 'VVU Synthetic Fusion',
    synthetic: true,
  ),
];

/// The four functional sides of the estate rail.
enum SurfaceSide {
  trust,
  ops,
  scada,
  ide,
}

extension SurfaceSideX on SurfaceSide {
  String get label {
    switch (this) {
      case SurfaceSide.trust:
        return 'TRUST UI';
      case SurfaceSide.ops:
        return 'OPS TOOLING';
      case SurfaceSide.scada:
        return 'SCADA';
      case SurfaceSide.ide:
        return 'IDE';
    }
  }
}

/// A single surface (page) in the estate.
class Surface {
  final String id;
  final String name;
  final String blurb;
  final IconData icon;
  final SurfaceSide side;
  final CanonicalMode mode;
  final Color? accentOverride;

  const Surface({
    required this.id,
    required this.name,
    required this.blurb,
    required this.icon,
    required this.side,
    required this.mode,
    this.accentOverride,
  });

  Color get accent => accentOverride ?? mode.accent;
}

/// All 25 surfaces of the VVU Unified Roof.
const List<Surface> kSurfaces = [
  // ── TRUST UI (11) ──────────────────────────────────────────────────────
  Surface(
    id: 'landing',
    name: 'Landing',
    blurb: 'Public marketing & pilot entry.',
    icon: Icons.rocket_launch_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFF4DD2FF),
  ),
  Surface(
    id: 'stitch',
    name: 'Stitch',
    blurb: 'Payment orchestration surface.',
    icon: Icons.credit_card_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.studio,
    accentOverride: Color(0xFFFFB84D),
  ),
  Surface(
    id: 'hostafrica',
    name: 'HostAfrica',
    blurb: 'VPS, backups, scheduling.',
    icon: Icons.dns_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.studio,
    accentOverride: Color(0xFFFFB84D),
  ),
  Surface(
    id: 'forge',
    name: 'Forge',
    blurb: 'Claim & mint verified receipts.',
    icon: Icons.build_circle_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFF00E5FF),
  ),
  Surface(
    id: 'fire',
    name: 'Fire',
    blurb: 'ROSCA savings pools in ZAR.',
    icon: Icons.local_fire_department_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.studio,
    accentOverride: Color(0xFFFFB224),
  ),
  Surface(
    id: 'press',
    name: 'Press',
    blurb: 'Creator publishing in ZAR.',
    icon: Icons.rate_review_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.ink,
    accentOverride: Color(0xFFE5484D),
  ),
  Surface(
    id: 'bench',
    name: 'Bench',
    blurb: 'Node-locked licenses & studio.',
    icon: Icons.vpn_key_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.ink,
    accentOverride: Color(0xFFE5484D),
  ),
  Surface(
    id: 'field',
    name: 'Field',
    blurb: 'Dual-tier resilient storage.',
    icon: Icons.storage_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFF00E5FF),
  ),
  Surface(
    id: 'spatial',
    name: 'Spatial',
    blurb: 'Lemon-tree asset register.',
    icon: Icons.park_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFFA3E635),
  ),
  Surface(
    id: 'surv',
    name: 'Surv',
    blurb: 'Surv & tamper telemetry.',
    icon: Icons.videocam_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFFA3E635),
  ),
  Surface(
    id: 'twin-hologram',
    name: 'Twin Hologram',
    blurb: 'Fresnel lifecycle visualiser.',
    icon: Icons.threed_rotation_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFFA3E635),
  ),

  // ── OPS (3) ────────────────────────────────────────────────────────────
  Surface(
    id: 'admin',
    name: 'Admin',
    blurb: 'Flags, RBAC, tenants, audit.',
    icon: Icons.admin_panel_settings_rounded,
    side: SurfaceSide.ops,
    mode: CanonicalMode.studio,
    accentOverride: Color(0xFFFFB84D),
  ),
  Surface(
    id: 'doctor',
    name: 'Doctor',
    blurb: '4-state health diagnostics.',
    icon: Icons.health_and_safety_rounded,
    side: SurfaceSide.ops,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFF3DD68C),
  ),
  Surface(
    id: 'observe',
    name: 'Observe',
    blurb: 'Remote state & trace inspector.',
    icon: Icons.insights_rounded,
    side: SurfaceSide.ops,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFF4DD2FF),
  ),

  // ── SCADA (4) ──────────────────────────────────────────────────────────
  Surface(
    id: 'twin',
    name: 'Twin',
    blurb: 'Live digital-twin roof.',
    icon: Icons.public_rounded,
    side: SurfaceSide.scada,
    mode: CanonicalMode.twin,
  ),
  Surface(
    id: 'overview',
    name: 'Overview',
    blurb: 'Estate KPI overview.',
    icon: Icons.dashboard_outlined,
    side: SurfaceSide.scada,
    mode: CanonicalMode.ink,
  ),
  Surface(
    id: 'tactical',
    name: 'Tactical',
    blurb: 'Pipeline trace & nodes.',
    icon: Icons.map_outlined,
    side: SurfaceSide.scada,
    mode: CanonicalMode.twin,
  ),
  Surface(
    id: 'replay',
    name: 'Replay',
    blurb: '31-day timeline replay.',
    icon: Icons.history_rounded,
    side: SurfaceSide.scada,
    mode: CanonicalMode.twin,
  ),

  // ── IDE (5) ────────────────────────────────────────────────────────────
  Surface(
    id: 'documents',
    name: 'Documents',
    blurb: 'Markdown document editor.',
    icon: Icons.description_outlined,
    side: SurfaceSide.ide,
    mode: CanonicalMode.ink,
  ),
  Surface(
    id: 'spreadsheets',
    name: 'Spreadsheets',
    blurb: 'Telemetry table view.',
    icon: Icons.table_view_outlined,
    side: SurfaceSide.ide,
    mode: CanonicalMode.studio,
  ),
  Surface(
    id: 'publications',
    name: 'Publications',
    blurb: 'Published artefact cards.',
    icon: Icons.menu_book_outlined,
    side: SurfaceSide.ide,
    mode: CanonicalMode.studio,
  ),
  Surface(
    id: 'ledger',
    name: 'Ledger',
    blurb: 'WORM chain ledger viewer.',
    icon: Icons.link_rounded,
    side: SurfaceSide.ide,
    mode: CanonicalMode.ink,
  ),
  Surface(
    id: 'settings',
    name: 'Settings',
    blurb: 'Gateway thresholds & identity.',
    icon: Icons.tune_rounded,
    side: SurfaceSide.ide,
    mode: CanonicalMode.studio,
  ),

  // ── NEW (2) ────────────────────────────────────────────────────────────
  Surface(
    id: 'play',
    name: 'Play',
    blurb: 'Gameplay launcher & phases.',
    icon: Icons.sports_esports_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.twin,
    accentOverride: Color(0xFF00E5FF),
  ),
  Surface(
    id: 'store',
    name: 'Store',
    blurb: 'Subscriptions, products, cart.',
    icon: Icons.storefront_rounded,
    side: SurfaceSide.trust,
    mode: CanonicalMode.studio,
    accentOverride: Color(0xFFFFB84D),
  ),
];
