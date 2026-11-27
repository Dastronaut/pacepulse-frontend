import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';

class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.visible,
    required this.onToggle,
  });

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PPSpacing.tapMin,
      height: PPSpacing.tapMin,
      child: PPIconButton(
        icon: visible ? PPIcons.eyeOff : PPIcons.eye,
        onPressed: onToggle,
        semanticLabel: visible ? 'Hide password' : 'Show password',
      ),
    );
  }
}
