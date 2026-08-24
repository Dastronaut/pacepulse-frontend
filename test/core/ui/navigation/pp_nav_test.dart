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

  testWidgets('standard app bar clears the status bar inset', (tester) async {
    // iPhone-class inset: 59 logical points at devicePixelRatio 3.
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 177);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: Scaffold(
        appBar: PPAppBar.standard(title: 'Sign in', onBack: () {}),
        body: const SizedBox(),
      ),
    ));

    // The decorated box grows to cover the inset, so the `scrolledUnder`
    // background keeps painting behind the status bar...
    expect(
      tester.getSize(find.byKey(const Key('pp_app_bar_box'))).height,
      56 + 59,
    );
    // ...while the content sits entirely below it. Unfixed, the title renders
    // at y 16.5-39.5 — under the notch, which is what shipped to the device.
    expect(tester.getRect(find.text('Sign in')).top, greaterThanOrEqualTo(59.0));
    expect(
      tester.getRect(find.bySemanticsLabel('Back')).top,
      greaterThanOrEqualTo(59.0),
    );
  });

  testWidgets('app bar adds no height when there is no inset', (tester) async {
    // Inline uses (the dev gallery specimens) and every existing test sit
    // inside a body whose padding is already consumed, so nothing shifts.
    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: Scaffold(
        appBar: PPAppBar.standard(title: 'Sign in', onBack: () {}),
        body: const SizedBox(),
      ),
    ));
    expect(tester.getSize(find.byKey(const Key('pp_app_bar_box'))).height, 56);
  });
}
