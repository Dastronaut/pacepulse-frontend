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
  testWidgets('icon button is 44x44; tonal has surface fill', (tester) async {
    await tester.pumpWidget(wrap(PPIconButton(
        icon: PPIcons.share2,
        style: PPIconButtonStyle.tonal,
        semanticLabel: 'Share',
        onPressed: () {})));
    expect(tester.getSize(find.byKey(const Key('pp_icon_button_box'))),
        const Size(44, 44));
    final deco = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_icon_button_box')))
        .decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.surfaceContainerHigh);
  });

  testWidgets('filled style: Ember bg, onPrimary icon', (tester) async {
    await tester.pumpWidget(wrap(PPIconButton(
        icon: PPIcons.plus,
        style: PPIconButtonStyle.filled,
        onPressed: () {})));
    final deco = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_icon_button_box')))
        .decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.primary);
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, ppDarkColorScheme.onPrimary);
  });

  testWidgets('disabled filled PPIconButton dims colors (dark theme)',
      (tester) async {
    await tester.pumpWidget(wrap(const PPIconButton(
        icon: PPIcons.plus,
        style: PPIconButtonStyle.filled,
        onPressed: null)));
    final deco = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_icon_button_box')))
        .decoration! as BoxDecoration;
    expect(deco.color,
        ppDarkColorScheme.primary.withValues(alpha: 0.30));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color,
        ppDarkColorScheme.onPrimary.withValues(alpha: 0.55));
  });

  testWidgets('FAB circular is 64 with shadow in dark theme too',
      (tester) async {
    await tester.pumpWidget(wrap(PPStartFab(onPressed: () {})));
    expect(tester.getSize(find.byKey(const Key('pp_fab_box'))),
        const Size(64, 64));
    final deco = tester
        .widget<Container>(find.byKey(const Key('pp_fab_box')))
        .decoration! as BoxDecoration;
    expect(deco.boxShadow, isNotEmpty); // dark keeps shadow2 (floating UI)
  });

  testWidgets('FAB extended is 54 tall with label', (tester) async {
    await tester.pumpWidget(
        wrap(PPStartFab(onPressed: () {}, extendedLabel: 'Start workout')));
    expect(
        tester.getSize(find.byKey(const Key('pp_fab_box'))).height, 54);
    expect(find.text('Start workout'), findsOneWidget);
  });
}
