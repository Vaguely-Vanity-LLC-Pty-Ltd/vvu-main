// VVU Unified Roof - Entry point.
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'models/estate.dart';
import 'services/hostafrica_api.dart';
import 'services/stitch_api.dart';
import 'views/app_shell.dart';
import 'widgets/tokens.dart';

void main() {
  // Initialise external SDK credentials before the app boots.
  StitchApi.init(
    clientId: 'test-cd2ee283-aa85-4e12-a259-519982e9bc68',
    clientSecret:
        'fmUzQfqz3QlEILlOyRJ4qh2MeufBYLB5QFFiyi3Bnzv7g9wAhE9XeF911HLQVGsD',
  );
  HostAfricaConfig.init(
    '9rFlg2kusu3HQWbnWSTbEtEPSX4koscpxWKrORG6LJjSmtPYuzLLfijgEvXP',
  );

  // Use path-based URLs for clean deep linking (no # in URL)
  setPathUrlStrategy();

  runApp(const VvuUnifiedRoofApp());
}

/// Root [MaterialApp].
class VvuUnifiedRoofApp extends StatelessWidget {
  const VvuUnifiedRoofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VVU Unified Roof',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: VvuColors.background,
        colorScheme: const ColorScheme.dark(
          primary: VvuColors.twin,
          onPrimary: VvuColors.background,
          secondary: VvuColors.studio,
          onSecondary: VvuColors.background,
          surface: VvuColors.panel,
          onSurface: VvuColors.text,
          error: VvuColors.danger,
          onError: VvuColors.text,
        ),
        fontFamily: VvuTypography.sans,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: VvuTypography.sans,
            color: VvuColors.text,
          ),
        ),
        dividerColor: VvuColors.line,
        canvasColor: VvuColors.panel,
        popupMenuTheme: PopupMenuThemeData(
          color: VvuColors.panelRaised,
          surfaceTintColor: Colors.transparent,
          textStyle: const TextStyle(
            fontFamily: VvuTypography.sans,
            fontSize: 12,
            color: VvuColors.text,
          ),
        ),
        iconTheme: const IconThemeData(
          color: VvuColors.textMuted,
          size: 18,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return VvuColors.studio;
            }
            return VvuColors.textFaint;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return VvuColors.studio.withOpacity(0.4);
            }
            return VvuColors.line;
          }),
        ),
      ),
      home: const VvuUnifiedRoof(),
    );
  }
}
