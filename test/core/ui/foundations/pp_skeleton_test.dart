// test/core/ui/foundations/pp_skeleton_test.dart
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

Color _skeletonColor(WidgetTester tester) {
  final box = tester.widget<Container>(find.byType(Container));
  return (box.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('sizes to given dims and starts on skeletonBase (dark)',
      (tester) async {
    await tester
        .pumpWidget(wrap(const PPSkeleton(width: 120, height: 16)));
    final size = tester.getSize(find.byType(PPSkeleton));
    expect(size, const Size(120, 16));
    expect(_skeletonColor(tester), PPColors.dark.skeletonBase);
  });

  testWidgets('shimmers toward skeletonHighlight mid-cycle', (tester) async {
    await tester
        .pumpWidget(wrap(const PPSkeleton(width: 120, height: 16)));
    await tester.pump(const Duration(milliseconds: 700)); // half of 1400ms
    expect(_skeletonColor(tester), isNot(PPColors.dark.skeletonBase));
  });

  testWidgets('reduced motion: stays on static base color', (tester) async {
    await tester.pumpWidget(
        wrap(const PPSkeleton(width: 120, height: 16), reducedMotion: true));
    await tester.pump(const Duration(milliseconds: 700));
    expect(_skeletonColor(tester), PPColors.dark.skeletonBase);
  });
}
