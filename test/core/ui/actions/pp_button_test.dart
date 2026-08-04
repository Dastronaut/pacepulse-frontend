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

BoxDecoration _decoOf(WidgetTester tester) {
  final box = tester.widget<AnimatedContainer>(
      find.byKey(const Key('pp_button_box')));
  return box.decoration! as BoxDecoration;
}

void main() {
  testWidgets('primary: Ember fill, Slate label, md height 44',
      (tester) async {
    await tester.pumpWidget(
        wrap(PPButton(label: 'Start run', onPressed: () {})));
    expect(_decoOf(tester).color, ppDarkColorScheme.primary);
    final label = tester.widget<Text>(find.text('Start run'));
    expect(label.style!.color, ppDarkColorScheme.onPrimary);
    expect(label.style!.fontWeight, FontWeight.w700);
    expect(
        tester.getSize(find.byKey(const Key('pp_button_box'))).height, 44);
  });

  testWidgets('sizes: sm 36 / lg 54', (tester) async {
    await tester.pumpWidget(wrap(Column(mainAxisSize: MainAxisSize.min,
        children: [
          PPButton(label: 'a', size: PPButtonSize.sm, onPressed: () {}),
          PPButton(label: 'b', size: PPButtonSize.lg, onPressed: () {}),
        ])));
    final boxes =
        tester.widgetList(find.byKey(const Key('pp_button_box'))).toList();
    expect(tester.getSize(find.byKey(const Key('pp_button_box')).first).height, 36);
    expect(tester.getSize(find.byKey(const Key('pp_button_box')).last).height, 54);
    expect(boxes.length, 2);
  });

  testWidgets('ghost light theme: label is emberStrong accentText',
      (tester) async {
    await tester.pumpWidget(wrap(
        PPButton(label: 'Skip', variant: PPButtonVariant.ghost, onPressed: () {}),
        dark: false));
    final label = tester.widget<Text>(find.text('Skip'));
    expect(label.style!.color, PPColors.light.accentText); // 0xFFA24A0C
  });

  testWidgets('disabled danger uses errorDisabled fill and blocks taps',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PPButton(
      label: 'Delete',
      variant: PPButtonVariant.danger,
      onPressed: null,
    )));
    expect(_decoOf(tester).color, PPColors.dark.errorDisabled);
    await tester.tap(find.byType(PPButton));
    expect(taps, 0);
  });

  testWidgets('loading: spinner shown, label hidden, tap ignored',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PPButton(
        label: 'Save', loading: true, onPressed: () => taps++)));
    expect(find.byType(PPSpinner), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.byType(PPButton));
    await tester.pump(const Duration(seconds: 2));
    expect(taps, 0);
    // Kill the spinner animation before test teardown.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('secondary pressed swaps fill via onHighlightChanged',
      (tester) async {
    await tester.pumpWidget(wrap(PPButton(
        label: 'Later', variant: PPButtonVariant.secondary, onPressed: () {})));
    final g = await tester.startGesture(
        tester.getCenter(find.byType(PPButton)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_decoOf(tester).color, ppDarkColorScheme.surfaceContainerHigh);
    await g.up();
    await tester.pumpAndSettle();
  });
}
