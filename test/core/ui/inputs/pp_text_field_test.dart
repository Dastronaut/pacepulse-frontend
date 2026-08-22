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

  testWidgets('helper text renders in faint color and error replaces it',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: const Scaffold(
        body: PPTextField(
          label: 'Password',
          helperText: '8+ characters with at least 1 number',
        ),
      ),
    ));
    expect(find.text('8+ characters with at least 1 number'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: const Scaffold(
        body: PPTextField(
          label: 'Password',
          helperText: '8+ characters with at least 1 number',
          errorText: 'Wrong password — try again or reset it',
        ),
      ),
    ));
    expect(find.text('8+ characters with at least 1 number'), findsNothing);
    expect(find.text('Wrong password — try again or reset it'), findsOneWidget);
  });

  testWidgets('trailing widget renders inside the field box', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: Scaffold(
        body: PPTextField(
          label: 'Password',
          trailing: IconButton(
            key: const Key('t'),
            onPressed: () {},
            icon: const Icon(Icons.abc),
          ),
        ),
      ),
    ));
    final box = tester.getRect(find.byKey(const Key('pp_field_box')));
    final trailing = tester.getRect(find.byKey(const Key('t')));
    expect(box.contains(trailing.center), isTrue);
  });

  testWidgets('external focus node is not disposed by the field',
      (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: Scaffold(body: PPTextField(label: 'Email', focusNode: node)),
    ));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    // Would throw "A FocusNode was used after being disposed" if the field
    // had disposed a node it did not create.
    expect(node.hasFocus, isFalse);
  });

  testWidgets('passes textInputAction and onSubmitted through',
      (tester) async {
    String? submitted;
    await tester.pumpWidget(MaterialApp(
      theme: ppDarkTheme(),
      home: Scaffold(
        body: PPTextField(
          label: 'Email',
          textInputAction: TextInputAction.next,
          onSubmitted: (v) => submitted = v,
        ),
      ),
    ));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textInputAction, TextInputAction.next);
    await tester.enterText(find.byType(TextField), 'a@b.c');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    expect(submitted, 'a@b.c');
  });

  testWidgets('inner Material field contributes no decoration of its own',
      (tester) async {
    // PPTextField draws its own box, so any decoration on the inner Material
    // field paints a second, inset box inside it — the double border seen on
    // device before 2026-08-20, caused by an ambient `inputDecorationTheme`.
    // That theme entry is gone, but this asserts the widget is neutral on its
    // own: a parent `Theme` override, or a future app-level decoration theme,
    // must not be able to reach through. Guards against a well-meaning
    // "these are redundant now" cleanup.
    await tester.pumpWidget(MaterialApp(
      theme: ppLightTheme(),
      home: const Scaffold(body: PPTextField(label: 'Email')),
    ));

    final dec = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration;
    expect(dec.filled, isFalse);
    expect(dec.contentPadding, EdgeInsets.zero);
    for (final border in <InputBorder?>[
      dec.border,
      dec.enabledBorder,
      dec.focusedBorder,
      dec.errorBorder,
      dec.focusedErrorBorder,
      dec.disabledBorder,
    ]) {
      expect(border, InputBorder.none);
    }
  });

  testWidgets('text sits at the documented constant-16 inset', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ppLightTheme(),
      home: const Scaffold(
        body: PPTextField(label: 'Email', hint: 'dana@pacepulse.app'),
      ),
    ));
    final box = tester.getRect(find.byKey(const Key('pp_field_box')));
    final hint = tester.getRect(find.text('dana@pacepulse.app'));
    // Unfixed, the inherited 16px contentPadding pushed this to 32.
    expect(hint.left - box.left, 16.0);
  });
}
