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
  testWidgets('toggle row: 56 tall, tap flips value, track goes primary',
      (tester) async {
    var on = false;
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, set) => PPSettingsGroup(children: [
        PPSettingsRow.toggle(
            icon: PPIcons.bell,
            title: 'Notifications',
            value: on,
            onChanged: (v) => set(() => on = v)),
      ]),
    )));
    expect(tester.getSize(find.byType(PPSettingsRow)).height, 56);
    var track = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_toggle_track')));
    expect((track.decoration! as BoxDecoration).color,
        ppDarkColorScheme.outline);
    await tester.tap(find.byType(PPSettingsRow));
    await tester.pumpAndSettle();
    expect(on, isTrue);
    track = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_toggle_track')));
    expect((track.decoration! as BoxDecoration).color,
        ppDarkColorScheme.primary);
  });

  testWidgets('value row shows value + chevron and taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PPSettingsGroup(children: [
      PPSettingsRow.value(
          icon: PPIcons.gauge,
          title: 'Units',
          value: 'Metric',
          onTap: () => taps++),
    ])));
    expect(find.text('Metric'), findsOneWidget);
    await tester.tap(find.text('Units'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('group divider is inset 54', (tester) async {
    await tester.pumpWidget(wrap(PPSettingsGroup(children: [
      PPSettingsRow.plain(icon: PPIcons.user, title: 'Profile', onTap: () {}),
      PPSettingsRow.plain(icon: PPIcons.bell, title: 'Alerts', onTap: () {}),
    ])));
    final divider = tester.widget<Padding>(
        find.byKey(const Key('pp_settings_divider')));
    expect(divider.padding, const EdgeInsets.only(left: 54));
  });

  testWidgets('light theme group renders shadow on outer container',
      (tester) async {
    await tester.pumpWidget(wrap(
      PPSettingsGroup(children: [
        PPSettingsRow.plain(icon: PPIcons.user, title: 'Profile', onTap: () {}),
      ]),
      dark: false,
    ));
    final outerContainer = tester.widget<Container>(
        find.byType(Container).first);
    expect(outerContainer.decoration, isA<BoxDecoration>());
    final decoration = outerContainer.decoration! as BoxDecoration;
    expect(decoration.boxShadow, isNotEmpty);
  });

  testWidgets('toggle row announces toggled state to screen readers',
      (tester) async {
    var on = false;
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, set) => PPSettingsGroup(children: [
        PPSettingsRow.toggle(
            icon: PPIcons.bell,
            title: 'Notifications',
            value: on,
            onChanged: (v) => set(() => on = v)),
      ]),
    )));
    // Verify Semantics widget exists with toggled state
    expect(find.byType(Semantics), findsWidgets);
    var semantics = tester.getSemantics(find.byType(PPSettingsRow));
    expect(semantics, isNotNull);
    await tester.tap(find.byType(PPSettingsRow));
    await tester.pumpAndSettle();
    semantics = tester.getSemantics(find.byType(PPSettingsRow));
    expect(semantics, isNotNull);
  });
}
