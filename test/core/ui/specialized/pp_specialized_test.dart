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
  testWidgets('map card: 140 map area + stats footer', (tester) async {
    await tester.pumpWidget(wrap(const SizedBox(
        width: 350,
        child: PPMapPreviewCard(
            route: [Offset(0.1, 0.8), Offset(0.5, 0.4), Offset(0.9, 0.6)],
            statsLine: '5.21 km · 28:41 · 5:31 /km'))));
    expect(
        tester.getSize(find.byKey(const Key('pp_map_area'))).height, 140);
    expect(find.text('5.21 km · 28:41 · 5:31 /km'), findsOneWidget);
  });

  testWidgets('device tile states: weak rssi warns, connecting spins, '
      'connected shows pill', (tester) async {
    await tester.pumpWidget(wrap(Column(children: [
      PPDeviceTile(
          name: 'Polar H10', rssiDbm: -85, onConnect: () {}),
      const PPDeviceTile(
          name: 'Wahoo TICKR',
          rssiDbm: -60,
          state: PPDeviceState.connecting),
      const PPDeviceTile(
          name: 'Garmin HRM',
          rssiDbm: -55,
          batteryPct: 80,
          state: PPDeviceState.connected),
    ])));
    final weak = tester.widget<Text>(find.textContaining('-85'));
    expect(weak.style!.color, PPColors.dark.warning);
    expect(find.byType(PPSpinner), findsOneWidget);
    expect(find.text('CONNECTED'), findsOneWidget);
    expect(find.widgetWithText(PPButton, 'Connect'), findsOneWidget);
  });

  testWidgets('paywall card: selection border + padding compensation',
      (tester) async {
    var selected = 0;
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, set) => Column(children: [
        PPPaywallPlanCard(
            plan: 'Yearly',
            price: '\$4.99',
            billedNote: 'Billed \$59.88 yearly',
            bestValue: true,
            selected: selected == 0,
            onSelected: () => set(() => selected = 0)),
        PPPaywallPlanCard(
            plan: 'Monthly',
            price: '\$7.99',
            billedNote: 'Billed monthly',
            selected: selected == 1,
            onSelected: () => set(() => selected = 1)),
      ]),
    )));
    Container boxAt(int i) => tester
        .widgetList<Container>(find.byKey(const Key('pp_plan_box')))
        .elementAt(i);
    var deco = boxAt(0).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.width, PPBorders.strong);
    expect(boxAt(0).padding, const EdgeInsets.all(15));
    expect(boxAt(1).padding, const EdgeInsets.all(16));
    expect(find.text('BEST VALUE'), findsOneWidget);
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    deco = boxAt(1).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.width, PPBorders.strong);
  });
}
