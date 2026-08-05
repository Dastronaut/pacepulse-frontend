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
  test('bandWidths: proportional with 4px floor and 2px gaps', () {
    final w = PPHRZoneBar.bandWidths(
        fractions: [0.5, 0.5, 0, 0, 0], totalWidth: 108);
    // usable = 108 - 4*2 = 100; zones 3-5 clamp to 4 → 12 reserved,
    // 88 split between the two 0.5s.
    expect(w.length, 5);
    expect(w[2], 4);
    expect(w[3], 4);
    expect(w[4], 4);
    expect(w[0], closeTo(44, 0.01));
    expect(w[1], closeTo(44, 0.01));
    expect(w.reduce((a, b) => a + b), closeTo(100, 0.01));
  });

  test('bandWidths: degenerate narrow width (floors cannot fit)', () {
    final w = PPHRZoneBar.bandWidths(
        fractions: [0.34, 0.165, 0.165, 0.165, 0.165], totalWidth: 20);
    // usable = 20 - 4*2 = 12; 5 floors * 4 = 20 > usable → equal split 12/5 = 2.4
    expect(w.length, 5);
    expect(w.every((x) => x >= 0), true); // no negative values
    expect(w.reduce((a, b) => a + b), closeTo(12, 0.01));
  });

  test('bandWidths: sum of fractions > 1 (scaled to unit weights)', () {
    final w = PPHRZoneBar.bandWidths(
        fractions: [1, 1, 1, 1, 1], totalWidth: 108);
    // usable = 100; weights = [0.2, 0.2, 0.2, 0.2, 0.2]; each gets 20
    expect(w.length, 5);
    expect(w[0], closeTo(20, 0.01));
    expect(w[1], closeTo(20, 0.01));
    expect(w[2], closeTo(20, 0.01));
    expect(w[3], closeTo(20, 0.01));
    expect(w[4], closeTo(20, 0.01));
    expect(w.reduce((a, b) => a + b), closeTo(100, 0.01));
  });

  test('bandWidths: all fractions zero (equal split, full-width bar)', () {
    final w = PPHRZoneBar.bandWidths(
        fractions: [0, 0, 0, 0, 0], totalWidth: 108);
    // usable = 100; all zero → equal weights → each 20
    expect(w.length, 5);
    expect(w[0], closeTo(20, 0.01));
    expect(w[1], closeTo(20, 0.01));
    expect(w[2], closeTo(20, 0.01));
    expect(w[3], closeTo(20, 0.01));
    expect(w[4], closeTo(20, 0.01));
    expect(w.reduce((a, b) => a + b), closeTo(100, 0.01));
  });

  testWidgets('bandWidths: widget render with extreme weights (no exception)',
      (tester) async {
    await tester.pumpWidget(wrap(SizedBox(
        width: 200,
        child: PPHRZoneBar(
            fractions: const [0.03, 0.01, 0.01, 0.01, 0.01]))));
    // Should render without exception; widths computed correctly.
    final bands =
        tester.widgetList<Container>(find.byKey(const Key('pp_zone_band')));
    expect(bands.length, 5);
    // All widths should be positive and non-zero.
    expect(bands.every((b) => b.constraints!.maxWidth > 0), true);
  });

  testWidgets('active zone is taller and full-opacity, others dimmed',
      (tester) async {
    await tester.pumpWidget(wrap(SizedBox(
        width: 300,
        child: PPHRZoneBar(
            fractions: const [0.1, 0.2, 0.3, 0.3, 0.1], activeZone: 4))));
    final bands =
        tester.widgetList<Container>(find.byKey(const Key('pp_zone_band')));
    expect(bands.length, 5);
    final heights = [for (final b in bands) b.constraints!.maxHeight];
    expect(heights[3], 16); // active grows 12 -> 16
    expect(heights[0], 12);
    final opacities =
        tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities.where((o) => o.opacity == 0.5).length, 4);
  });

  testWidgets('splits: fastest pace in accentText w700; delta colors',
      (tester) async {
    await tester.pumpWidget(wrap(const Column(children: [
      PPSplitsRow(km: '1', pace: '5:42'),
      PPSplitsRow(km: '2', pace: '5:31', deltaSeconds: -11, fastest: true),
      PPSplitsRow(km: '3', pace: '5:50', deltaSeconds: 19),
    ])));
    final fast = tester.widget<Text>(find.text('5:31'));
    expect(fast.style!.color, PPColors.dark.accentText);
    expect(fast.style!.fontWeight, FontWeight.w700);
    expect(tester.widget<Text>(find.text('-0:11')).style!.color,
        PPColors.dark.success);
    expect(tester.widget<Text>(find.text('+0:19')).style!.color,
        ppDarkColorScheme.error);
    expect(find.text('—'), findsOneWidget);
  });
}
