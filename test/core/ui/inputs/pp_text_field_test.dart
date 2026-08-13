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

AnimatedContainer _box(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find.byKey(const Key('pp_field_box')));

void main() {
  testWidgets('52 tall; focus grows accent border and compensates padding',
      (tester) async {
    await tester
        .pumpWidget(wrap(const PPTextField(label: 'Email')));
    expect(tester.getSize(find.byKey(const Key('pp_field_box'))).height, 52);
    var deco = _box(tester).decoration! as BoxDecoration;
    expect(deco.border, isNull); // dark rest = borderless

    // Record TextField horizontal position at rest (dark theme, no border)
    final restX = tester.getTopLeft(find.byType(TextField)).dx;

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    deco = _box(tester).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.width, PPBorders.strong);
    expect((deco.border! as Border).top.color, PPColors.dark.accentText);

    // Verify TextField position unchanged (constant 16 inset: 16 + 0 = 14 + 2)
    final focusX = tester.getTopLeft(find.byType(TextField)).dx;
    expect(focusX, restX);
  });

  testWidgets('error: 2px error border + helper text + zero shift',
      (tester) async {
    // Light theme at rest has hairline (1px) with hPad=15, inset=16
    await tester.pumpWidget(
        wrap(const PPTextField(label: 'Username'), dark: false));
    var deco = _box(tester).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.width, PPBorders.hairline);
    final restX = tester.getTopLeft(find.byType(TextField)).dx;

    // Trigger error (2px with hPad=14, inset=16)
    await tester.pumpWidget(wrap(
        const PPTextField(
            label: 'Username',
            errorText: 'At least 8 characters — add a few more.'),
        dark: false));
    deco = _box(tester).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.width, PPBorders.strong);
    expect((deco.border! as Border).top.color, ppLightColorScheme.error);
    final errorX = tester.getTopLeft(find.byType(TextField)).dx;
    expect(errorX, restX); // zero shift

    final helper = tester.widget<Text>(
        find.text('At least 8 characters — add a few more.'));
    expect(helper.style!.color, ppLightColorScheme.error);
  });

  testWidgets('disabled: outlineVariant fill, disabled text color',
      (tester) async {
    await tester.pumpWidget(
        wrap(const PPTextField(label: 'Code', enabled: false)));
    final deco = _box(tester).decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.outlineVariant);
  });

  testWidgets('label is programmatically associated for screen readers',
      (tester) async {
    await tester.pumpWidget(wrap(const PPTextField(label: 'Email')));
    final semantics = tester.getSemantics(find.byType(PPTextField));
    expect(semantics.label, contains('Email'));
  });

  testWidgets('errorText is appended to the semantic label so it is announced',
      (tester) async {
    await tester.pumpWidget(wrap(const PPTextField(
      label: 'Email',
      errorText: 'Enter a valid email address',
    )));
    final semantics = tester.getSemantics(find.byType(PPTextField));
    expect(semantics.label, contains('Enter a valid email address'));
  });
}
