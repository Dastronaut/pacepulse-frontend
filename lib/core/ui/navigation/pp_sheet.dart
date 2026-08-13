import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Modal bottom sheet (D1-D3) with the spec's ASYMMETRIC curves:
/// enter 360ms decelerate, exit 220ms accelerate — hence a custom route
/// instead of showModalBottomSheet.
///
/// The 36×4 grabber and the sheet's interior paddings (top gap above
/// the title, gap below it, bottom inset) are design-specified geometry
/// with no CSS custom property (D1-D3/D4; human ruling 2026-08-03: spec
/// literals with documented provenance — see pp_pressable.dart:6-11).
Future<T?> showPPSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) {
  final scheme = Theme.of(context).colorScheme;
  return Navigator.of(context).push(_PPSheetRoute<T>(
    builder: builder,
    title: title,
    barrierColor: scheme.scrim,
  ));
}

class _PPSheetRoute<T> extends PopupRoute<T> {
  _PPSheetRoute({
    required this.builder,
    required this.title,
    required this.barrierColor,
  });

  final WidgetBuilder builder;
  final String? title;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => PPMotion.slow;

  @override
  Duration get reverseTransitionDuration => PPMotion.base;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: dark ? scheme.surfaceContainerHigh : scheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(PPRadius.xl)),
          boxShadow: dark ? null : pp.shadow3,
        ),
        // A PopupRoute's overlay entry sits outside the page Scaffold's
        // Material ancestor, so Material-dependent builder content
        // (PPTextField, Switch, ...) would assert debugCheckHasMaterial
        // without this. Decoration stays on the Container above.
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag-to-dismiss is scoped to the grabber/title zone
                // only. Wrapping the whole sheet (as the brief's Step-3
                // draft did) would put the gesture in the same arena as
                // any scrollable builder content — misdismiss or dead
                // scroll.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0) > 300) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          key: const Key('pp_sheet_grabber'),
                          margin: const EdgeInsets.only(top: PPSpacing.s3),
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.outline,
                            borderRadius:
                                BorderRadius.circular(PPRadius.pill),
                          ),
                        ),
                      ),
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              PPSpacing.padCard,
                              PPSpacing.s3,
                              PPSpacing.padCard,
                              0),
                          child: Text(title!,
                              style: theme.textTheme.headlineSmall),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(PPSpacing.padCard,
                      PPSpacing.s3, PPSpacing.padCard, PPSpacing.s6),
                  child: Builder(builder: builder),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: PPMotion.decelerate,
      reverseCurve: PPMotion.accelerate.flipped,
    );
    return SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero)
          .animate(curved),
      child: child,
    );
  }
}
