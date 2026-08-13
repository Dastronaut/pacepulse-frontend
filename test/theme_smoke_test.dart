import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacepulse/core/theme/theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('warm-up: every style resolves its font from bundled assets', () async {
    ppTextTheme;
    PPTextStyles.countdown;
    PPTextStyles.monoXl;
    PPTextStyles.monoL;
    PPTextStyles.monoM;
    PPTextStyles.monoS;
    await GoogleFonts.pendingFonts();
  });

  test('both themes assemble with the PPColors extension attached', () {
    expect(ppDarkTheme().extension<PPColors>(), isNotNull);
    expect(ppLightTheme().extension<PPColors>(), isNotNull);
  });

  test('accent text resolves per theme (Ember dark, ember-strong light)', () {
    expect(
      ppDarkTheme().extension<PPColors>()!.accentText,
      const Color(0xFFFF9B51),
    );
    expect(
      ppLightTheme().extension<PPColors>()!.accentText,
      const Color(0xFFA24A0C),
    );
  });

  test('content on Ember is Slate in both themes — never white', () {
    expect(ppDarkColorScheme.onPrimary, const Color(0xFF25343F));
    expect(ppLightColorScheme.onPrimary, const Color(0xFF25343F));
  });

  test('scrim (T2) is the same dark value in both themes', () {
    expect(ppDarkColorScheme.scrim, const Color(0xD916212B));
    expect(ppLightColorScheme.scrim, const Color(0xD916212B));
  });

  test('display face is Inter at weight 800 with tabular figures', () {
    final style = ppTextTheme.displayLarge!;
    expect(style.fontWeight, FontWeight.w800);
    expect(style.fontFamily, contains('Inter'));
    expect(style.fontFeatures, isNotEmpty);
  });

  test('countdown style (T7) is 160px at weight 900', () {
    expect(PPTextStyles.countdown.fontSize, 160);
    expect(PPTextStyles.countdown.fontWeight, FontWeight.w900);
  });

  test('T3–T6 roles are present with per-theme values', () {
    final dark = ppDarkTheme().extension<PPColors>()!;
    final light = ppLightTheme().extension<PPColors>()!;
    expect(dark.warningContainer, const Color(0xFF2A2103));
    expect(light.warningContainer, const Color(0xFFF4E9CE));
    expect(dark.skeletonBase, const Color(0xFF2A3A46));
    expect(light.skeletonBase, const Color(0xFFD6DEE2));
    expect(dark.errorDisabled, const Color(0x4DFF7088));
    expect(light.errorDisabled, const Color(0x59C81E43));
    expect(PPColors.chartFillAlpha, 0.14);
  });

  test('light theme carries multi-layer shadows; zone/chart lists enumerate',
      () {
    final light = ppLightTheme().extension<PPColors>()!;
    expect(light.shadow1.length, 2);
    expect(light.shadow2.length, 2);
    expect(light.shadow3.length, 2);
    expect(light.hrZones.length, 5);
    expect(light.chartSeries.length, 5);
  });

  testWidgets('app boots with the dark theme and renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ppLightTheme(),
        darkTheme: ppDarkTheme(),
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Center(child: Text('PacePulse'))),
      ),
    );
    expect(find.text('PacePulse'), findsOneWidget);
  });
}
