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
  testWidgets('display face: 72 w800 with tabular figures', (tester) async {
    await tester.pumpWidget(wrap(const PPMetricDisplay(
        label: 'Distance', value: '4.62', unit: 'km')));
    final v = tester.widget<Text>(find.text('4.62'));
    expect(v.style!.fontSize, 72);
    expect(v.style!.fontWeight, FontWeight.w800);
    expect(v.style!.fontFeatures, isNotEmpty);
    expect(find.text('DISTANCE'), findsOneWidget);
  });

  testWidgets('mono face uses JetBrains Mono w700; live shows dot',
      (tester) async {
    await tester.pumpWidget(wrap(const PPMetricDisplay(
        label: 'Time',
        value: '28:41',
        face: PPMetricFace.mono,
        live: true)));
    final v = tester.widget<Text>(find.text('28:41'));
    expect(v.style!.fontFamily, PPTextStyles.monoXl.fontFamily);
    expect(v.style!.fontWeight, FontWeight.w700);
    expect(find.byType(PPLiveDot), findsOneWidget);
  });

  testWidgets('stat tile: dark bg surfaceContainerHigh, accent icon',
      (tester) async {
    await tester.pumpWidget(wrap(const PPStatTile(
        icon: PPIcons.flame, label: 'Calories', value: '486')));
    final deco = tester
        .widget<Container>(find.byKey(const Key('pp_stat_tile_box')))
        .decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.surfaceContainerHigh);
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, PPColors.dark.accentText);
  });

  testWidgets('no overflow at 1.3x scale', (tester) async {
    await tester.pumpWidget(wrap(
        const SizedBox(
            width: 390,
            child: PPMetricDisplay(
                label: 'Heart rate', value: '152', unit: 'bpm')),
        textScale: 1.3));
    expect(tester.takeException(), isNull);
  });

  group('PPStatTile sub-line', () {
    Widget wrapTile(Widget child, {Brightness brightness = Brightness.dark}) =>
        MaterialApp(
          theme: brightness == Brightness.dark ? ppDarkTheme() : ppLightTheme(),
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('no sub-line renders when sub is omitted', (tester) async {
      await tester.pumpWidget(wrapTile(const PPStatTile(
        icon: PPIcons.route,
        label: 'This week',
        value: '32.6',
        unit: 'km',
      )));
      expect(find.byKey(const Key('pp_stat_tile_sub')), findsNothing);
    });

    testWidgets('the sub-line renders its text', (tester) async {
      await tester.pumpWidget(wrapTile(const PPStatTile(
        icon: PPIcons.route,
        label: 'This week',
        value: '32.6',
        unit: 'km',
        sub: '▲ 12% vs last week',
        subTone: PPStatTone.positive,
      )));
      expect(find.text('▲ 12% vs last week'), findsOneWidget);
    });

    testWidgets('tone selects the token colour, not the direction', (tester) async {
      for (final (tone, expected) in <(PPStatTone, Color)>[
        (PPStatTone.positive, PPColors.dark.success),
        (PPStatTone.negative, PPColors.dark.warning),
        (PPStatTone.neutral, PPColors.dark.onSurfaceFaint),
      ]) {
        await tester.pumpWidget(wrapTile(PPStatTile(
          icon: PPIcons.heartPulse,
          label: 'Resting HR',
          value: '54',
          unit: 'bpm',
          sub: 'moved',
          subTone: tone,
        )));
        final text =
            tester.widget<Text>(find.byKey(const Key('pp_stat_tile_sub')));
        expect(text.style!.color, expected, reason: '$tone');
      }
    });

    testWidgets('the sub-line uses tabular figures so the number does not jitter',
        (tester) async {
      await tester.pumpWidget(wrapTile(const PPStatTile(
        icon: PPIcons.route,
        label: 'This week',
        value: '32.6',
        unit: 'km',
        sub: '▲ 12% vs last week',
        subTone: PPStatTone.positive,
      )));
      final text =
          tester.widget<Text>(find.byKey(const Key('pp_stat_tile_sub')));
      expect(text.style!.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('the sub-line survives the light theme', (tester) async {
      await tester.pumpWidget(wrapTile(
        const PPStatTile(
          icon: PPIcons.route,
          label: 'This week',
          value: '32.6',
          sub: '– steady',
        ),
        brightness: Brightness.light,
      ));
      final text =
          tester.widget<Text>(find.byKey(const Key('pp_stat_tile_sub')));
      expect(text.style!.color, PPColors.light.onSurfaceFaint);
    });
  });
}
