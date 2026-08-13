import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../actions/pp_button.dart';
import '../assets/pp_illustration.dart';
import '../foundations/pp_icon.dart';

/// Empty state (D1-E5): invites action with a PRIMARY button.
class PPEmptyState extends StatelessWidget {
  const PPEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.illustrationName = 'empty',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String illustrationName;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      top: PPIllustration(name: illustrationName),
      title: title,
      body: body,
      button: actionLabel == null
          ? null
          : PPButton(label: actionLabel!, onPressed: onAction),
    );
  }
}

/// Error state (D1-E5): says what broke + how to fix, SECONDARY retry.
/// Error icon: 32px per D1-E5, human ruling 2026-08-03.
class PPErrorState extends StatelessWidget {
  const PPErrorState({
    super.key,
    required this.title,
    required this.body,
    this.retryLabel = 'Try again',
    this.onRetry,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _StateScaffold(
      top: Icon(PPIcons.triangleAlert, size: 32, color: scheme.error),
      title: title,
      body: body,
      button: onRetry == null
          ? null
          : PPButton(
              label: retryLabel,
              variant: PPButtonVariant.secondary,
              onPressed: onRetry),
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold(
      {required this.top,
      required this.title,
      required this.body,
      required this.button});

  final Widget top;
  final String title;
  final String body;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        key: const Key('pp_state_constraint'),
        // max-w 280: D1-E5 empty/error column width (human ruling 2026-08-03)
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            top,
            const SizedBox(height: PPSpacing.s4),
            Text(title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: PPSpacing.s4),
            Text(
              body,
              style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (button != null) ...[
              const SizedBox(height: PPSpacing.s4),
              button!,
            ],
          ],
        ),
      ),
    );
  }
}
