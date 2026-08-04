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

BoxDecoration _deco(WidgetTester tester) =>
    tester.widget<Container>(find.byKey(const Key('pp_chip_box'))).decoration!
        as BoxDecoration;

void main() {
  testWidgets('live chip: primaryContainer bg + PPLiveDot', (tester) async {
    await tester.pumpWidget(
        wrap(const PPChip(label: 'LIVE', variant: PPChipVariant.live)));
    expect(_deco(tester).color, ppDarkColorScheme.primaryContainer);
    expect(find.byType(PPLiveDot), findsOneWidget);
  });

  testWidgets('success chip uses success container pair', (tester) async {
    await tester.pumpWidget(
        wrap(const PPChip(label: 'READY', variant: PPChipVariant.success)));
    expect(_deco(tester).color, PPColors.dark.successContainer);
    final t = tester.widget<Text>(find.text('READY'));
    expect(t.style!.color, PPColors.dark.onSuccessContainer);
  });

  testWidgets('tag shape uses radius-xs corners', (tester) async {
    await tester.pumpWidget(wrap(const PPChip(
        label: 'Ad', variant: PPChipVariant.pr, shape: PPChipShape.tag)));
    final radius = _deco(tester).borderRadius! as BorderRadius;
    expect(radius.topLeft.x, PPRadius.xs);
  });

  testWidgets('tappable chip fires despite small visual', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(
        PPChip(label: 'PR', onTap: () => taps++)));
    await tester.tapAt(
        tester.getCenter(find.byType(PPChip)) + const Offset(0, 16));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
