import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/auth_validators.dart';

const _glyphSize = 18.0;
const _glyphStroke = 2.0;
const _glyphAlphaOnFill = 0.4;
const _glyphAlphaOnInverse = 0.5;

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton._({
    required this.label,
    required this.inverseFill,
    required this.onPressed,
  });

  const SocialAuthButton.apple({VoidCallback? onPressed})
    : this._(
        label: AuthCopy.continueWithApple,
        inverseFill: true,
        onPressed: onPressed,
      );

  const SocialAuthButton.google({VoidCallback? onPressed})
    : this._(
        label: AuthCopy.continueWithGoogle,
        inverseFill: false,
        onPressed: onPressed,
      );

  final String label;
  final bool inverseFill;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final Color? fill = inverseFill
        ? (dark ? PPPalette.mist : PPPalette.slate)
        : null;
    final Color content = inverseFill
        ? (dark ? PPPalette.slate : PPPalette.mist)
        : scheme.onSurface;
    final alpha = inverseFill ? _glyphAlphaOnFill : _glyphAlphaOnInverse;

    return PPPressable(
      onPressed: onPressed,
      enabled: onPressed != null,
      semanticLabel: label,
      child: DecoratedBox(
        key: const Key('pp_social_box'),
        decoration: ShapeDecoration(
          color: fill,
          shape: StadiumBorder(
            side: inverseFill
                ? BorderSide.none
                : BorderSide(color: scheme.outline, width: PPBorders.regular),
          ),
        ),
        child: SizedBox(
          height: PPButtonSize.lg.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GlyphPlaceholder(color: content.withValues(alpha: alpha)),
              const SizedBox(width: PPSpacing.gapInline),
              Text(
                label,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: content,
                  fontSize: PPButtonSize.lg.fontSize,
                  letterSpacing: PPButtonSize.lg.fontSize * 0.01,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlyphPlaceholder extends StatelessWidget {
  const _GlyphPlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: _glyphSize,
    height: _glyphSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: _glyphStroke),
    ),
  );
}
