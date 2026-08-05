import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Splits table header: KM · PACE · DELTA overline (D1-B8).
///
/// Geometry specs: row height 36px (D1-B8), column widths 40/64px (D1-B8),
/// label text labelSmall with onSurfaceFaint color; human ruling 2026-08-03 confirms these are final.
class PPSplitsHeader extends StatelessWidget {
  const PPSplitsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = Theme.of(context).extension<PPColors>()!;
    final style = Theme.of(context)
        .textTheme
        .labelSmall!
        .copyWith(color: pp.onSurfaceFaint);
    return SizedBox(
      height: 36,
      child: Row(children: [
        SizedBox(width: 40, child: Text('KM', style: style)),
        Expanded(
            child: Text('PACE', style: style, textAlign: TextAlign.right)),
        SizedBox(
            width: 64,
            child: Text('DELTA', style: style, textAlign: TextAlign.right)),
      ]),
    );
  }
}

/// One split row: mono 13, delta vs the PREVIOUS split (not average).
///
/// Geometry specs: row height 36px (D1-B8), column widths 40/64px (D1-B8),
/// hairline top border (D1-B8); fastest pace rendered in accentText w700 (human ruling 2026-08-03);
/// delta colors: success for negative (faster), error for positive (slower).
class PPSplitsRow extends StatelessWidget {
  const PPSplitsRow({
    super.key,
    required this.km,
    required this.pace,
    this.deltaSeconds,
    this.fastest = false,
  });

  final String km;
  final String pace;
  final int? deltaSeconds;
  final bool fastest;

  String get _delta {
    final d = deltaSeconds;
    if (d == null) return '—';
    final sign = d < 0 ? '-' : '+';
    final abs = d.abs();
    return '$sign${abs ~/ 60}:${(abs % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final deltaColor = deltaSeconds == null
        ? pp.onSurfaceFaint
        : deltaSeconds! < 0
            ? pp.success
            : scheme.error;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: scheme.outlineVariant, width: PPBorders.hairline),
        ),
      ),
      child: Row(children: [
        SizedBox(
            width: 40,
            child: Text(km,
                style:
                    PPTextStyles.monoS.copyWith(color: scheme.onSurfaceVariant))),
        Expanded(
          child: Text(
            pace,
            textAlign: TextAlign.right,
            style: PPTextStyles.monoS.copyWith(
              color: fastest ? pp.accentText : scheme.onSurface,
              fontWeight: fastest ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(_delta,
              textAlign: TextAlign.right,
              style: PPTextStyles.monoS.copyWith(color: deltaColor)),
        ),
      ]),
    );
  }
}
