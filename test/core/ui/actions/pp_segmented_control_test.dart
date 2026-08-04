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
  test('asserts on more than 4 segments', () {
    expect(
      () => PPSegmentedControl(
          segments: const ['a', 'b', 'c', 'd', 'e'],
          selectedIndex: 0,
          onChanged: (_) {}),
      throwsAssertionError,
    );
  });

  testWidgets('tap fires onChanged with tapped index', (tester) async {
    int? changed;
    await tester.pumpWidget(wrap(PPSegmentedControl(
        segments: const ['Run', 'Ride', 'Gym'],
        selectedIndex: 0,
        onChanged: (i) => changed = i)));
    await tester.tap(find.text('Gym'));
    expect(changed, 2);
  });

  testWidgets('thumb aligns to the selected segment', (tester) async {
    await tester.pumpWidget(wrap(SizedBox(
        width: 300,
        child: PPSegmentedControl(
            segments: const ['A', 'B'],
            selectedIndex: 1,
            onChanged: (_) {}))));
    await tester.pumpAndSettle();
    final align =
        tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
    expect(align.alignment, const Alignment(1, 0)); // rightmost of 2
  });

  testWidgets('selected label 600 onSurface, unselected onSurfaceVariant',
      (tester) async {
    await tester.pumpWidget(wrap(PPSegmentedControl(
        segments: const ['Active', 'Past'],
        selectedIndex: 0,
        onChanged: (_) {})));
    final sel = tester.widget<Text>(find.text('Active'));
    final unsel = tester.widget<Text>(find.text('Past'));
    expect(sel.style!.color, ppDarkColorScheme.onSurface);
    expect(sel.style!.fontWeight, FontWeight.w600);
    expect(unsel.style!.color, ppDarkColorScheme.onSurfaceVariant);
  });

  testWidgets('small variant thumb renders at bounded height in Column',
      (tester) async {
    await tester.pumpWidget(wrap(Column(
      children: [
        SizedBox(
          width: 300,
          child: PPSegmentedControl(
            segments: const ['W', 'M', '6M', 'Y'],
            selectedIndex: 0,
            onChanged: (_) {},
            small: true,
          ),
        ),
      ],
    )));
    await tester.pumpAndSettle();
    final thumb = tester.widget<Container>(find.byKey(const Key('pp_segmented_thumb')));
    expect(thumb.constraints!.maxHeight, greaterThanOrEqualTo(20));
  });

  testWidgets('small variant tap target inflated to 44px', (tester) async {
    int? changed;
    await tester.pumpWidget(wrap(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: PPSegmentedControl(
            segments: const ['W', 'M', '6M', 'Y'],
            selectedIndex: 0,
            onChanged: (i) => changed = i,
            small: true,
          ),
        ),
      ],
    )));
    // Tap at a position that would be outside the ~20px visual height
    // but within the 44px inflated hit target (PPTapTarget clamps to center)
    final centerOfM = tester.getCenter(find.text('M'));
    await tester.tapAt(centerOfM + const Offset(0, 10));
    expect(changed, 1); // M is at index 1
  });
}
