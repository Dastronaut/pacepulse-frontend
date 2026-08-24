import 'package:flutter/material.dart';

class WizardFieldLabel extends StatelessWidget {
  const WizardFieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelMedium!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
