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
  testWidgets('nav: four fixed items, tap fires, live badge on zap',
      (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(PPBottomNavBar(
        index: 0, onChanged: (i) => tapped = i, challengesLive: true)));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Challenges'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(PPLiveDot), findsOneWidget);
    await tester.tap(find.text('Challenges'));
    expect(tapped, 2);
  });

  testWidgets('active item is accentText, idle faint', (tester) async {
    await tester.pumpWidget(
        wrap(PPBottomNavBar(index: 1, onChanged: (_) {})));
    final active = tester.widget<Text>(find.text('History'));
    final idle = tester.widget<Text>(find.text('Home'));
    expect(active.style!.color, PPColors.dark.accentText);
    expect(idle.style!.color, PPColors.dark.onSurfaceFaint);
  });

  testWidgets('app bars: heights and variants', (tester) async {
    await tester.pumpWidget(wrap(Column(children: [
      PPAppBar.standard(title: 'Settings', onBack: () {}),
      const PPAppBar.large(title: 'Challenges'),
      PPAppBar.live(title: 'Saturday 5K', onClose: () {}),
    ])));
    final bars = find.byType(PPAppBar);
    expect(tester.getSize(bars.at(0)).height, 56);
    expect(tester.getSize(bars.at(1)).height, 96);
    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('scrolledUnder shows surface bg (dark hairline)',
      (tester) async {
    await tester.pumpWidget(wrap(
        PPAppBar.standard(title: 'History', scrolledUnder: true)));
    final deco = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_app_bar_box')))
        .decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.surface);
    expect(deco.border, isNotNull);
  });
}
