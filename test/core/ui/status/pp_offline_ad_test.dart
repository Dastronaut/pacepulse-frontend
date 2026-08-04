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
  testWidgets('offline banner: 44 tall, warning icon color', (tester) async {
    await tester.pumpWidget(wrap(const PPOfflineBanner()));
    expect(
        tester.getSize(find.byType(PPOfflineBanner)).height, 44);
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, PPColors.dark.warning);
  });

  testWidgets('ad slot reserves 320x50 + 8 vertical padding always',
      (tester) async {
    await tester.pumpWidget(wrap(const PPBannerAdSlot()));
    expect(tester.getSize(find.byType(PPBannerAdSlot)).height, 66);
    expect(
        tester.getSize(find.byKey(const Key('pp_ad_inner'))),
        const Size(320, 50));
    expect(find.text('AD'), findsOneWidget); // tag renders uppercase
  });

  testWidgets('ad slot with ad child keeps identical dims (zero shift)',
      (tester) async {
    await tester.pumpWidget(wrap(
        const PPBannerAdSlot(ad: ColoredBox(color: Colors.green))));
    expect(tester.getSize(find.byType(PPBannerAdSlot)).height, 66);
    expect(tester.getSize(find.byKey(const Key('pp_ad_inner'))),
        const Size(320, 50));
  });
}
