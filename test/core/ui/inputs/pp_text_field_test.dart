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
    expect((deco.border! as Border).top.width, PPBorders.hairline);
    expect(_box(tester).padding,
        const EdgeInsets.symmetric(horizontal: 16));

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    deco = _box(tester).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.width, PPBorders.strong);
    expect((deco.border! as Border).top.color, PPColors.dark.accentText);
    expect(_box(tester).padding,
        const EdgeInsets.symmetric(horizontal: 14));
  });

  testWidgets('error: 2px error border + helper text', (tester) async {
    await tester.pumpWidget(wrap(const PPTextField(
        label: 'Password',
        errorText: 'At least 8 characters — add a few more.')));
    final deco = _box(tester).decoration! as BoxDecoration;
    expect((deco.border! as Border).top.color, ppDarkColorScheme.error);
    expect((deco.border! as Border).top.width, PPBorders.strong);
    final helper = tester.widget<Text>(
        find.text('At least 8 characters — add a few more.'));
    expect(helper.style!.color, ppDarkColorScheme.error);
  });

  testWidgets('disabled: outlineVariant fill, disabled text color',
      (tester) async {
    await tester.pumpWidget(
        wrap(const PPTextField(label: 'Code', enabled: false)));
    final deco = _box(tester).decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.outlineVariant);
  });
}
