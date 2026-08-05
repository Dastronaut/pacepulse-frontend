import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../actions/pp_button.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';
import '../foundations/pp_spinner.dart';

enum PPDeviceState { connect, connecting, connected }

/// BLE device row (D1-F2: weak-signal threshold −80 dBm — human ruling
/// 2026-08-03: spec literals with documented provenance).
class PPDeviceTile extends StatelessWidget {
  const PPDeviceTile({
    super.key,
    required this.name,
    required this.rssiDbm,
    this.batteryPct,
    this.state = PPDeviceState.connect,
    this.onConnect,
    this.onTap,
  });

  final String name;
  final int rssiDbm;
  final int? batteryPct;
  final PPDeviceState state;
  final VoidCallback? onConnect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    final weak = rssiDbm < -80;

    final meta = [
      '$rssiDbm dBm',
      if (batteryPct != null) '$batteryPct%',
    ].join(' · ');

    final tile = Container(
      padding: const EdgeInsets.all(PPSpacing.s4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PPRadius.lg),
        boxShadow: dark ? null : pp.shadow1,
      ),
      child: Row(
        children: [
          Container(
            width: PPSpacing.tapMin,
            height: PPSpacing.tapMin,
            decoration: BoxDecoration(
              color: dark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(PPRadius.md),
            ),
            child: Center(
              child: PPIcon(PPIcons.bluetooth,
                  color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: PPSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                Text(
                  meta,
                  style: PPTextStyles.monoS.copyWith(
                      fontSize: 11,
                      color: weak ? pp.warning : pp.onSurfaceFaint),
                ),
              ],
            ),
          ),
          switch (state) {
            PPDeviceState.connect => PPButton(
                label: 'Connect',
                variant: PPButtonVariant.secondary,
                size: PPButtonSize.sm,
                onPressed: onConnect),
            PPDeviceState.connecting =>
              PPSpinner(color: pp.accentText),
            PPDeviceState.connected => Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 5, horizontal: 12),
                decoration: BoxDecoration(
                  color: pp.successContainer,
                  borderRadius: BorderRadius.circular(PPRadius.pill),
                ),
                child: Text('CONNECTED',
                    style: theme.textTheme.labelSmall!
                        .copyWith(color: pp.onSuccessContainer)),
              ),
          },
        ],
      ),
    );

    if (onTap == null) return tile;
    return PPPressable(onPressed: onTap, semanticLabel: name, child: tile);
  }
}
