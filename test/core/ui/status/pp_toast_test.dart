import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';

Widget host({bool dark = true}) {
  return MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => showPPToast(context,
                message: 'Workout saved',
                actionLabel: 'View',
                onAction: () {}),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
}

BoxDecoration _deco(WidgetTester tester) =>
    tester.widget<Container>(find.byKey(const Key('pp_toast_box'))).decoration!
        as BoxDecoration;

void main() {
  testWidgets('shows, then auto-dismisses after 4s', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Workout saved'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Workout saved'), findsNothing);
  });

  testWidgets('dark: surfaceContainerHighest bg', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(_deco(tester).color, ppDarkColorScheme.surfaceContainerHighest);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('light: INVERSE slate bg, mist text, ember action',
      (tester) async {
    await tester.pumpWidget(host(dark: false));
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(_deco(tester).color, PPPalette.slate);
    expect(tester.widget<Text>(find.text('Workout saved')).style!.color,
        PPPalette.mist);
    expect(tester.widget<Text>(find.text('View')).style!.color,
        PPPalette.ember);
    await tester.pump(const Duration(seconds: 5));
  });
}
