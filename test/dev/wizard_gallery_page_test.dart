import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/dev/gallery/gallery.dart';
import 'package:pacepulse/dev/gallery/pages/wizard_page.dart';

/// Every GallerySection title in wizard_page.dart, in order (GallerySection
/// uppercases them). The test walks to each in turn, which is what forces
/// the lazy ListView to actually BUILD each specimen — scrolling straight
/// to the last one would leave most of them never constructed, and
/// takeException() a no-op for those. That mistake already bit the
/// onboarding gallery.
///
/// Append here whenever you append a section, or the check silently covers
/// less than it claims.
const _sections = [
  'PPSTEPPER - METRIC DEFAULT',
  'PPSTEPPER - AT THE LOWER BOUND',
  'PPCHOICEPILLS - ONE SELECTED',
  'PPCHOICEPILLS - NOTHING SELECTED',
  'WIZARD - STEP 1',
  'WIZARD - STEP 2',
  'WIZARD - STEP 3 METRIC',
  'WIZARD - STEP 3 IMPERIAL',
  'WIZARD - STEP 4 FOUND',
  'WIZARD - STEP 4 SCANNING',
  'WIZARD - STEP 4 EMPTY',
  'WIZARD - STEP 4 BLUETOOTH OFF',
  'PRIMING - LOCATION',
  'PRIMING - NOTIFICATIONS',
  'PRIMING - HEALTH',
  'PRIMING - BLUETOOTH',
];

void main() {
  test('is registered in the gallery', () {
    expect(galleryPages.containsKey('Wizard'), isTrue);
  });

  testWidgets('renders every specimen in both themes', (tester) async {
    // A tall viewport instead of scrolling. The page is a ListView, which
    // builds lazily: with a phone-sized window most specimens are never
    // constructed, so takeException() is a no-op for them and the test
    // passes vacuously. Sizing the window to cover the whole list forces
    // every specimen to build. (scrollUntilVisible is the other option,
    // but the step-4 "scanning" specimen holds a never-ending PPSpinner,
    // so nothing here can pumpAndSettle.)
    tester.view.physicalSize = const Size(500, 30000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final dark in [true, false]) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: dark ? ppDarkTheme() : ppLightTheme(),
            home: const Scaffold(body: WizardGalleryPage()),
          ),
        ),
      );
      await tester.pump();

      for (final section in _sections) {
        expect(
          find.text(section),
          findsOneWidget,
          reason: '$section dark=$dark',
        );
      }
      expect(tester.takeException(), isNull, reason: 'dark=$dark');
    }
  });
}
