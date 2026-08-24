import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/profile_draft.dart';
import '../wizard_controller.dart';
import 'wizard_step_scaffold.dart';

class WizardStepGear extends ConsumerWidget {
  const WizardStepGear({
    super.key,
    required this.onFinish,
    required this.onSkip,
    required this.onConnect,
  });

  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final ValueChanged<GearDevice> onConnect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pp = Theme.of(context).extension<PPColors>()!;
    final scan = ref.watch(gearScanProvider);

    return WizardStepScaffold(
      overline: WizardCopy.step4Overline,
      title: WizardCopy.step4Title,
      body: scan.status == GearScanStatus.scanning
          ? WizardCopy.step4Scanning
          : WizardCopy.step4Found,
      fields: [
        if (scan.status == GearScanStatus.scanning)
          Align(
            alignment: Alignment.centerLeft,
            child: PPSpinner(color: pp.accentText),
          )
        else if (scan.status == GearScanStatus.empty)
          PPEmptyState(
            title: WizardCopy.gearEmptyTitle,
            body: WizardCopy.gearEmptyBody,
            actionLabel: WizardCopy.gearEmptyAction,
            onAction: ref.read(gearScanProvider.notifier).rescan,
          )
        else if (scan.status == GearScanStatus.bluetoothOff)
          PPErrorState(
            title: WizardCopy.gearErrorTitle,
            body: WizardCopy.gearErrorBody,
            onRetry: ref.read(gearScanProvider.notifier).rescan,
          )
        else
          for (final (i, device) in scan.devices.indexed) ...[
            if (i > 0) const SizedBox(height: PPSpacing.s3),
            PPDeviceTile(
              key: Key('wizard_gear_${device.name}'),
              name: device.name,
              rssiDbm: device.rssiDbm,
              onConnect: () => onConnect(device),
            ),
          ],
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PPButton(
            key: const Key('wizard_step4_finish'),
            label: WizardCopy.finishLabel,
            size: PPButtonSize.lg,
            fullWidth: true,
            onPressed: onFinish,
          ),
          const SizedBox(height: PPSpacing.s3),
          PPButton(
            key: const Key('wizard_step4_skip'),
            label: WizardCopy.skipLabel,
            variant: PPButtonVariant.ghost,
            onPressed: onSkip,
          ),
        ],
      ),
    );
  }
}
