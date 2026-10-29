// VVU Unified Roof — Design Tokens
// Dark theme, mobile-first, desktop-native operational control room.
import 'package:flutter/material.dart';

/// Canonical colour palette for the VVU Unified Roof.
class VvuColors {
  VvuColors._();

  static const Color background = Color(0xFF06070B);
  static const Color panel = Color(0xFF0D0F16);
  static const Color panelRaised = Color(0xFF12141D);
  static const Color line = Color(0xFF222734);
  static const Color lineStrong = Color(0xFF2E3445);
  static const Color text = Color(0xFFE8E8EA);
  static const Color textMuted = Color(0xFF8A8D96);
  static const Color textFaint = Color(0xFF555862);
  static const Color ink = Color(0xFF1B1E27);
  static const Color studio = Color(0xFFFFB84D);
  static const Color twin = Color(0xFF4DD2FF);
  static const Color armed = Color(0xFF3DD68C);
  static const Color warn = Color(0xFFFFB84D);
  static const Color danger = Color(0xFFFF5C5C);
  static const Color beat = Color(0xFF4DD2FF);
}

/// Canonical operating mode for a surface.
enum CanonicalMode {
  ink,
  studio,
  twin,
}

extension CanonicalModeX on CanonicalMode {
  Color get accent {
    switch (this) {
      case CanonicalMode.ink:
        // Ink mode is the hardened/low-emission surface — its accent is a
        // hard red to signal serious / audit-grade controls.
        return const Color(0xFFE5484D);
      case CanonicalMode.studio:
        return VvuColors.studio;
      case CanonicalMode.twin:
        return VvuColors.twin;
    }
  }

  String get label {
    switch (this) {
      case CanonicalMode.ink:
        return 'INK';
      case CanonicalMode.studio:
        return 'STUDIO';
      case CanonicalMode.twin:
        return 'TWIN';
    }
  }

  String get blurb {
    switch (this) {
      case CanonicalMode.ink:
        return 'Hardened, low-emission control surface.';
      case CanonicalMode.studio:
        return 'Authoring, capture, monetisation surface.';
      case CanonicalMode.twin:
        return 'Live digital-twin sensing surface.';
    }
  }
}

/// Typography tokens.
class VvuTypography {
  VvuTypography._();

  static const String mono = 'RobotoMono';
  static const String sans = 'Inter';

  static const TextStyle label = TextStyle(
    fontFamily: mono,
    fontSize: 11,
    letterSpacing: 2.4,
    fontWeight: FontWeight.w500,
    color: VvuColors.text,
  );

  static const TextStyle labelMuted = TextStyle(
    fontFamily: mono,
    fontSize: 10,
    letterSpacing: 1.8,
    color: VvuColors.textMuted,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: mono,
    fontSize: 9,
    letterSpacing: 1.6,
    color: VvuColors.textFaint,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    color: VvuColors.text,
    height: 1.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: mono,
    fontSize: 14,
    letterSpacing: 2.4,
    fontWeight: FontWeight.w600,
    color: VvuColors.text,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: mono,
    fontSize: 18,
    letterSpacing: 3.2,
    fontWeight: FontWeight.w600,
    color: VvuColors.text,
  );
}

/// Corner radii.
class VvuRadii {
  VvuRadii._();

  static const double sm = 2;
  static const double md = 4;
  static const double lg = 6;
}
