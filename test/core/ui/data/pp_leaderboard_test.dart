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
  testWidgets('self row: primaryContainer bg, delta label, pulse wrapper',
      (tester) async {
    await tester.pumpWidget(wrap(const PPLeaderboardRow(
      rank: 2,
      name: 'You',
      pace: '5:08',
      progress: 0.46,
      isSelf: true,
      selfDeltaLabel: '+0:04',
    )));
    final deco = tester
        .widget<Container>(find.byKey(const Key('pp_leader_row_box')))
        .decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.primaryContainer);
    expect(find.text('+0:04'), findsOneWidget);
    expect(find.byType(PPLivePulse), findsOneWidget);
    expect(tester.getSize(find.byType(PPLeaderboardRow)).height, 64);
  });

  testWidgets('rank deltas: up success, down error', (tester) async {
    await tester.pumpWidget(wrap(const Column(children: [
      PPLeaderboardRow(
          rank: 1, name: 'Marta', pace: '5:02', progress: 0.5, rankDelta: 1),
      PPLeaderboardRow(
          rank: 4, name: 'Ben', pace: '5:40', progress: 0.3, rankDelta: -2),
    ])));
    expect(tester.widget<Text>(find.text('▲1')).style!.color,
        PPColors.dark.success);
    expect(tester.widget<Text>(find.text('▼2')).style!.color,
        ppDarkColorScheme.error);
  });

  testWidgets('dropped: dimmed, em-dash pace, reconnecting caption',
      (tester) async {
    await tester.pumpWidget(wrap(const PPLeaderboardRow(
        rank: 5, name: 'Rosa', pace: '5:12', progress: 0.2,
        isDropped: true)));
    final o = tester.widget<Opacity>(
        find.byKey(const Key('pp_leader_row_opacity')));
    expect(o.opacity, 0.55);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('reconnecting…'), findsOneWidget);
    expect(find.byType(PPLiveDot), findsNothing);
  });
}
