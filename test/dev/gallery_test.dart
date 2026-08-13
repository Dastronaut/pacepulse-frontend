import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/dev/gallery/gallery.dart';

void main() {
  testWidgets('gallery lists pages and toggles theme brightness',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GalleryScreen()));
    expect(find.text('Foundations'), findsOneWidget);
    await tester.tap(find.text('Foundations'));
    // FoundationsGalleryPage hosts continuously looping animations
    // (PPSkeleton, PPLivePulse(loop: true)) that never settle, so a
    // fixed pump is used here instead of pumpAndSettle.
    await tester.pump();
    // Default frame is dark.
    BuildContext ctx = tester.element(find.byType(GallerySection).first);
    expect(Theme.of(ctx).brightness, Brightness.dark);
    // Toggle to light.
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pump();
    ctx = tester.element(find.byType(GallerySection).first);
    expect(Theme.of(ctx).brightness, Brightness.light);
  });
}
