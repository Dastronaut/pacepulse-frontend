import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/dev/gallery/gallery.dart';
import 'package:pacepulse/dev/gallery/pages/auth_page.dart';

// No simulator/device is available in this environment, so this test
// substitutes for the brief's manual both-themes device pass: it pumps
// AuthGalleryPage in both dark and light and asserts it builds without
// throwing and without overflow. The manual pass (hero ring color,
// Apple pill inversion, accent text legibility on light, live toggling)
// remains an outstanding manual check — see task-8-report.md.
void main() {
  // AuthGalleryPage is a ListView of 844px-tall frames; the default test
  // viewport (800x600) plus ListView's lazy build + cache extent means a
  // single pump only ever constructs the first section or two. Every
  // section — including the reset-sent state, whose seeded controller is
  // the one under a no-timer obligation — must be scrolled into the
  // viewport to actually build it (and thus to actually exercise a
  // dangling Timer, which the test framework would flag as a pending
  // timer at teardown). pumpAndSettle is avoided throughout: the
  // "submitting: true" section holds a loading spinner that never
  // settles.
  Future<void> pumpAuthPage(WidgetTester tester, {required bool dark}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? ppDarkTheme() : ppLightTheme(),
        home: const Scaffold(body: AuthGalleryPage()),
      ),
    );
    await tester.pump();
    // Drag the ListView to the bottom, pumping after each drag, until the
    // final section's title is on screen — this forces every seeded
    // state to build at least once. GallerySection upper-cases its title,
    // hence the SHOUTING match.
    final lastSectionTitle =
        find.text('RESETPASSWORDSCREEN - SENT, COOLDOWN ELAPSED '
            '(GHOST RESEND)');
    for (var i = 0; i < 20 && lastSectionTitle.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();
    }
    expect(lastSectionTitle, findsOneWidget,
        reason: 'the last gallery section never scrolled into view — '
            'not every seeded state was built');
  }

  testWidgets('AuthGalleryPage builds cleanly in dark theme',
      (tester) async {
    await pumpAuthPage(tester, dark: true);
    expect(tester.takeException(), isNull);
    expect(find.byType(AuthGalleryPage), findsOneWidget);
  });

  testWidgets('AuthGalleryPage builds cleanly in light theme',
      (tester) async {
    await pumpAuthPage(tester, dark: false);
    expect(tester.takeException(), isNull);
    expect(find.byType(AuthGalleryPage), findsOneWidget);
  });

  testWidgets('the Auth page is reachable through the gallery screen',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
    await tester.tap(find.text('Auth'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(AuthGalleryPage), findsOneWidget);
    // Toggle theme while the Auth page is showing.
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    // Scroll every section into view under the toggled theme too.
    final lastSectionTitle =
        find.text('RESETPASSWORDSCREEN - SENT, COOLDOWN ELAPSED '
            '(GHOST RESEND)');
    for (var i = 0; i < 20 && lastSectionTitle.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();
    }
    expect(lastSectionTitle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
