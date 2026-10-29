// VVU Unified Roof — Map view dropdown.
import 'package:flutter/material.dart';
import '../models/estate.dart';
import 'tokens.dart';

/// Dropdown for selecting among the 9 map views.
class MapViewDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  final Color accent;
  final List<MapViewEntry> views;

  const MapViewDropdown({
    super.key,
    required this.value,
    required this.onChange,
    required this.accent,
    this.views = kMapViews,
  });

  @override
  Widget build(BuildContext context) {
    final current = views.firstWhere(
      (v) => v.id == value,
      orElse: () => views.first,
    );
    return PopupMenuButton<String>(
      tooltip: 'Map view',
      color: VvuColors.panelRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VvuRadii.md),
        side: const BorderSide(color: VvuColors.lineStrong),
      ),
      onSelected: onChange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: VvuColors.panelRaised,
          borderRadius: BorderRadius.circular(VvuRadii.sm),
          border: Border.all(color: accent.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(current.icon, size: 14, color: accent),
            const SizedBox(width: 6),
            Text(
              current.name,
              style: TextStyle(
                fontFamily: VvuTypography.mono,
                fontSize: 11,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600,
                color: VvuColors.text,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_drop_down_rounded,
                size: 14, color: VvuColors.textMuted),
          ],
        ),
      ),
      itemBuilder: (context) => views
          .map(
            (v) => PopupMenuItem<String>(
              value: v.id,
              child: Row(
                children: [
                  Icon(v.icon, size: 16, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.name,
                          style: TextStyle(
                            fontFamily: VvuTypography.mono,
                            fontSize: 11,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: v.id == value
                                ? accent
                                : VvuColors.text,
                          ),
                        ),
                        Text(
                          v.tile,
                          style: TextStyle(
                            fontFamily: VvuTypography.sans,
                            fontSize: 11,
                            color: VvuColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    v.epistemics,
                    style: VvuTypography.micro,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
