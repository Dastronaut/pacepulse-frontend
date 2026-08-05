import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../actions/pp_button.dart';

/// Modal dialog (D1-D4): w 300, title says the OUTCOME, body says the
/// COST. Confirm resolves the future with true.
///
/// The 300 fixed width is design-specified geometry with no CSS custom
/// property (D1-D4; human ruling 2026-08-03: spec literals with
/// documented provenance — see pp_pressable.dart:6-11). Note this
/// differs deliberately from theme.dart's Material `dialogTheme`, which
/// keeps radius-xl for stock (non-PP) dialogs; OUR dialog follows
/// D1-D4's 300-wide / radius-lg spec instead.
Future<T?> showPPDialog<T>(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final pp = theme.extension<PPColors>()!;
  final dark = theme.brightness == Brightness.dark;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: scheme.scrim,
    transitionDuration: PPMotion.base,
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity:
          CurvedAnimation(parent: animation, curve: PPMotion.decelerate),
      child: child,
    ),
    pageBuilder: (context, _, _) => Center(
      child: Container(
        key: const Key('pp_dialog_box'),
        width: 300,
        padding: const EdgeInsets.all(PPSpacing.padCard),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(PPRadius.lg),
          boxShadow: dark ? null : pp.shadow3,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: PPSpacing.s3),
              Text(body,
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: PPSpacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PPButton(
                    label: cancelLabel,
                    variant: PPButtonVariant.ghost,
                    size: PPButtonSize.md,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: PPSpacing.s2),
                  PPButton(
                    label: confirmLabel,
                    variant: destructive
                        ? PPButtonVariant.danger
                        : PPButtonVariant.primary,
                    size: PPButtonSize.md,
                    onPressed: () =>
                        Navigator.of(context).pop(true as T),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
