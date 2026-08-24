import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';

Widget wrap(Widget child, {bool dark = true}) => MaterialApp(
  theme: ppLightTheme(),
  darkTheme: ppDarkTheme(),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(body: Center(child: child)),
);

/// The value is a `Text.rich` (numeral plus a smaller unit suffix), so its
/// `data` is null and `find.text('20')` never matches it. Read it by key.
Text valueText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('pp_stepper_value')));

void main() {
  testWidgets('renders value, unit and caption', (tester) async {
    await tester.pumpWidget(
      wrap(
        const PPStepper(
          valueLabel: '20',
          unit: ' km',
          caption: 'Most runners start between 15 and 25 km',
        ),
      ),
    );
    final rich = valueText(tester);
    expect((rich.textSpan! as TextSpan).text, '20');
    expect(rich.textSpan!.toPlainText(), '20 km');
    expect(
      find.text('Most runners start between 15 and 25 km'),
      findsOneWidget,
    );
  });

  testWidgets('the value carries tabular figures', (tester) async {
    // A goal that changes under the user's thumb must not shift width.
    await tester.pumpWidget(
      wrap(const PPStepper(valueLabel: '22.5', unit: ' km')),
    );
    expect(
      valueText(tester).style!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('both controls are 44px and fire their callbacks', (
    tester,
  ) async {
    var down = 0;
    var up = 0;
    await tester.pumpWidget(
      wrap(
        PPStepper(
          valueLabel: '20',
          unit: ' km',
          onDecrement: () => down++,
          onIncrement: () => up++,
        ),
      ),
    );
    for (final key in ['pp_stepper_minus', 'pp_stepper_plus']) {
      final size = tester.getSize(find.byKey(Key(key)));
      expect(size.width, PPSpacing.tapMin, reason: key);
      expect(size.height, PPSpacing.tapMin, reason: key);
    }
    await tester.tap(find.byKey(const Key('pp_stepper_minus')));
    await tester.tap(find.byKey(const Key('pp_stepper_plus')));
    expect(down, 1);
    expect(up, 1);
  });

  testWidgets('a null callback disables that control at the bound', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const PPStepper(
          valueLabel: '2.5',
          unit: ' km',
          onIncrement: null,
          onDecrement: null,
        ),
      ),
    );
    // PPPressable(enabled: false) must announce as disabled, not merely
    // ignore taps — a screen reader user needs to know it is at the bound.
    //
    // PPTapTarget is PPPressable's outermost render object and carries no
    // semantics config, so a finder on the PPPressable itself walks *up*
    // past the merged node to an ancestor. Scope to the GestureDetector
    // where button/enabled/label actually merge — the same reason
    // pp_pressable_test.dart:66-74 documents.
    final semantics = tester.getSemantics(
      find.descendant(
        of: find.byKey(const Key('pp_stepper_minus')),
        matching: find.byType(GestureDetector),
      ),
    );
    // Tristate.isFalse rather than .none proves the enabled-state is
    // reported at all: the node keeps a "disabled control" role instead of
    // dropping the state and reading as "not a control".
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
  });

  testWidgets('light theme gives the circles a hairline outline', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const PPStepper(valueLabel: '20', unit: ' km'), dark: false),
    );
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('pp_stepper_minus')),
        matching: find.byType(Container),
      ),
    );
    final deco = box.decoration! as BoxDecoration;
    expect(deco.color, ppLightColorScheme.surfaceContainer);
    expect((deco.border! as Border).top.width, PPBorders.hairline);
  });
}
