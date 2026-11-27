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

const _body = ['Female', 'Male', 'Prefer not to say'];

void main() {
  testWidgets('renders every option and reports taps by index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      wrap(
        PPChoicePills(
          options: _body,
          selectedIndex: null,
          onChanged: (i) => tapped = i,
        ),
      ),
    );
    for (final label in _body) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Male'));
    expect(tapped, 1);
  });

  testWidgets('selected pill fills with primary and onPrimary content', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(PPChoicePills(options: _body, selectedIndex: 0, onChanged: (_) {})),
    );
    final selected = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('pp_choice_pill_0')),
        matching: find.byType(Container),
      ),
    );
    final deco = selected.decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.primary);
    expect(deco.border, isNull);
    // Token law: content on Ember is Slate, never white.
    expect(
      tester.widget<Text>(find.text('Female')).style!.color,
      ppDarkColorScheme.onPrimary,
    );
  });

  testWidgets('unselected pill is an outline ring, not a fill', (tester) async {
    await tester.pumpWidget(
      wrap(PPChoicePills(options: _body, selectedIndex: 0, onChanged: (_) {})),
    );
    final unselected = tester.widget<Container>(
      find.descendant(
        of: find.byKey(const Key('pp_choice_pill_1')),
        matching: find.byType(Container),
      ),
    );
    final deco = unselected.decoration! as BoxDecoration;
    expect(deco.color, isNull);
    expect((deco.border! as Border).top.width, PPBorders.regular);
    expect((deco.border! as Border).top.color, ppDarkColorScheme.outline);
  });

  testWidgets('every pill has a 44px tap target', (tester) async {
    // The handoff draws these at 36px. Token law mandates 44, so the hit
    // area is taller than the painted pill — the same solution
    // PPSegmentedControl uses.
    await tester.pumpWidget(
      wrap(PPChoicePills(options: _body, selectedIndex: 0, onChanged: (_) {})),
    );
    for (var i = 0; i < _body.length; i++) {
      expect(
        tester.getSize(find.byKey(Key('pp_choice_pill_$i'))).height,
        PPSpacing.tapMin,
        reason: 'pill $i',
      );
    }
  });

  testWidgets('announces as a mutually exclusive group', (tester) async {
    await tester.pumpWidget(
      wrap(PPChoicePills(options: _body, selectedIndex: 0, onChanged: (_) {})),
    );
    // Scoped to the GestureDetector where PPPressable's config merges —
    // see pp_pressable_test.dart:66-74 for why a finder on the pressable
    // itself walks up past the real node.
    final flags = tester
        .getSemantics(
          find.descendant(
            of: find.byKey(const Key('pp_choice_pill_0')),
            matching: find.byType(GestureDetector),
          ),
        )
        .flagsCollection;
    expect(flags.isInMutuallyExclusiveGroup, isTrue);
    expect(flags.isSelected, Tristate.isTrue);
  });

  testWidgets('wraps rather than overflowing at large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ppDarkTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: PPChoicePills(
                options: _body,
                selectedIndex: 0,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
