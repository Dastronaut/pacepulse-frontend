import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';

Widget wrap(Widget child,
    {bool dark = true, bool reducedMotion = false, double textScale = 1.0}) {
  return MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, w) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reducedMotion,
        textScaler: TextScaler.linear(textScale),
      ),
      child: w!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('sizes render; premium adds 2px primary ring',
      (tester) async {
    await tester.pumpWidget(wrap(const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PPAvatar(initials: 'TL', size: PPAvatarSize.s48, premium: true),
          PPAvatar(initials: 'MK', size: PPAvatarSize.s24),
        ])));
    expect(tester.getSize(find.byType(PPAvatar).first).width, 48);
    expect(tester.getSize(find.byType(PPAvatar).last).width, 24);
    final deco = tester
        .widget<Container>(find.byKey(const Key('pp_avatar_TL')))
        .decoration! as BoxDecoration;
    final border = deco.border! as Border;
    expect(border.top.color, ppDarkColorScheme.primary);
    expect(border.top.width, PPBorders.strong);
  });

  testWidgets('stack overlaps -8 and shows +N overflow', (tester) async {
    await tester.pumpWidget(wrap(const PPAvatarStack(
        initials: ['MK', 'JT', 'AL'], overflow: 3)));
    expect(find.text('+3'), findsOneWidget);
    // 3 avatars + overflow, 32px each, -8 overlap:
    // width = 32 + 3*(32-8) + ring allowance (4 per side edge).
    final w = tester.getSize(find.byType(PPAvatarStack)).width;
    expect(w, lessThan(4 * 36)); // strictly narrower than unoverlapped
    // Verify tabular figures on overflow count (CLAUDE.md: live-updating numbers)
    final overflowText = tester.widget<Text>(find.text('+3'));
    expect(
        overflowText.style!.fontFeatures,
        contains(const FontFeature.tabularFigures()));
  });
}
