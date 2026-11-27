import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

const double _screenBottomPad = 28;

class WizardStepScaffold extends StatelessWidget {
  const WizardStepScaffold({
    super.key,
    required this.overline,
    required this.title,
    required this.body,
    required this.fields,
    required this.footer,
  });

  final String overline;
  final String title;
  final String body;

  final List<Widget> fields;

  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: PPSpacing.s3,
              left: PPSpacing.s5,
              right: PPSpacing.s5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  overline.toUpperCase(),
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: pp.onSurfaceFaint,
                  ),
                ),
                const SizedBox(height: PPSpacing.s1),
                Text(title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: PPSpacing.s1),
                Text(
                  body,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                for (final field in fields) ...[
                  const SizedBox(height: PPSpacing.s4),
                  field,
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: PPSpacing.s4,
            left: PPSpacing.s5,
            right: PPSpacing.s5,
            bottom: _screenBottomPad,
          ),
          child: footer,
        ),
      ],
    );
  }
}
