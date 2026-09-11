import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/dev/gallery/pages/home_page.dart';

void main() {
  testWidgets('renders every specimen in both themes', (tester) async {
    // The lazy ListView only builds what fits, and the skeleton specimen
    // shimmers forever so pumpAndSettle cannot be used to scroll. A tall
    // viewport builds every specimen in one pass.
    tester.view.physicalSize = const Size(500, 30000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final theme in [ppDarkTheme(), ppLightTheme()]) {
      // Fully unmount before the next theme's pumpWidget. Reusing the same
      // Element tree across themes leaves PPWorkoutCard's AnimatedContainer /
      // PPPressable ScaleTransition State alive mid-implicit-animation,
      // which paints a RenderParagraph with stale layout and trips
      // TextPainter's debugSize assertion.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(theme: theme, home: const HomeGalleryPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      for (final title in HomeGalleryPage.sectionTitles) {
        expect(find.text(title.toUpperCase()), findsOneWidget,
            reason: '$title missing in ${theme.brightness}');
      }
      expect(tester.takeException(), isNull);
    }
  });
}
