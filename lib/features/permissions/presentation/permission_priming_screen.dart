import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../domain/permission_kind.dart';

const double _ringSize = 130;
const double _ringThickness = 12;
const double _glyphSize = 40;
const double _stackGap = 10;
const double _bodyMaxWidth = 300;
const double _screenBottomPad = 28;

class PermissionPrimingScreen extends StatelessWidget {
  const PermissionPrimingScreen({
    super.key,
    required this.kind,
    required this.onAllow,
    required this.onNotNow,
  });

  final PermissionKind kind;
  final VoidCallback onAllow;
  final VoidCallback onNotNow;

  static const path = '/permission/:kind';

  static String routeFor(PermissionKind kind) => '/permission/${kind.name}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PPActivityRing(
                        value: 1,
                        color: dark ? scheme.primary : pp.ringMove,
                        size: _ringSize,
                        thickness: _ringThickness,
                        child: Icon(
                          kind.glyph,
                          size: _glyphSize,
                          color: pp.accentText,
                        ),
                      ),
                      const SizedBox(height: PPSpacing.s6),
                      Text(
                        kind.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: _stackGap),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _bodyMaxWidth,
                        ),
                        child: Text(
                          kind.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: PPSpacing.s5,
                right: PPSpacing.s5,
                bottom: _screenBottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PPButton(
                    key: const Key('permission_allow'),
                    label: kind.allowLabel,
                    size: PPButtonSize.lg,
                    fullWidth: true,
                    onPressed: onAllow,
                  ),
                  const SizedBox(height: _stackGap),
                  PPButton(
                    key: const Key('permission_not_now'),
                    label: PermissionCopy.notNow,
                    variant: PPButtonVariant.ghost,
                    onPressed: onNotNow,
                  ),
                  const SizedBox(height: _stackGap),
                  Text(
                    kind.footnote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: pp.onSurfaceFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
