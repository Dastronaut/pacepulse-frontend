import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/permissions/domain/permission_kind.dart';
import 'package:pacepulse/features/permissions/presentation/permission_priming_screen.dart';
import 'package:pacepulse/features/permissions/presentation/primed_this_session.dart';

Widget wrap(Widget child, {bool dark = true}) => ProviderScope(
  child: MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: child,
  ),
);

void main() {
  test('every kind carries complete copy', () {
    // A kind added later without copy would render blank rather than fail
    // loudly, so assert the whole set here.
    for (final kind in PermissionKind.values) {
      expect(kind.title, isNotEmpty, reason: kind.name);
      expect(kind.body, isNotEmpty, reason: kind.name);
      expect(kind.allowLabel, isNotEmpty, reason: kind.name);
      expect(kind.footnote, isNotEmpty, reason: kind.name);
    }
  });

  test('kind names round-trip and unknown names resolve to null', () {
    // A deep link is untrusted input; an unknown kind must not throw.
    for (final kind in PermissionKind.values) {
      expect(permissionKindFromName(kind.name), kind);
    }
    expect(permissionKindFromName('camera'), isNull);
    expect(permissionKindFromName(null), isNull);
    expect(permissionKindFromName(''), isNull);
  });

  testWidgets('renders the location copy verbatim from S10', (tester) async {
    await tester.pumpWidget(
      wrap(
        PermissionPrimingScreen(
          kind: PermissionKind.location,
          onAllow: () {},
          onNotNow: () {},
        ),
      ),
    );
    expect(find.text('See your route and distance'), findsOneWidget);
    expect(
      find.text(
        'PacePulse uses your location only while you work out — never in the background.',
      ),
      findsOneWidget,
    );
    expect(find.text('Allow location'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(
      find.text('Your phone will confirm — choose "While using the app"'),
      findsOneWidget,
    );
  });

  testWidgets('renders the bluetooth copy verbatim from S10', (tester) async {
    await tester.pumpWidget(
      wrap(
        PermissionPrimingScreen(
          kind: PermissionKind.bluetooth,
          onAllow: () {},
          onNotNow: () {},
        ),
      ),
    );
    expect(find.text('Connect your heart-rate strap'), findsOneWidget);
    expect(find.text('Allow Bluetooth'), findsOneWidget);
    expect(
      find.text('You can pair a strap later in Settings → Devices'),
      findsOneWidget,
    );
  });

  testWidgets('both actions report out — Not now is a real choice', (
    tester,
  ) async {
    var allowed = false;
    var declined = false;
    await tester.pumpWidget(
      wrap(
        PermissionPrimingScreen(
          kind: PermissionKind.location,
          onAllow: () => allowed = true,
          onNotNow: () => declined = true,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('permission_allow')));
    await tester.tap(find.byKey(const Key('permission_not_now')));
    expect(allowed, isTrue);
    expect(declined, isTrue);
  });

  testWidgets('the ring takes the per-theme accent colour', (tester) async {
    await tester.pumpWidget(
      wrap(
        PermissionPrimingScreen(
          kind: PermissionKind.location,
          onAllow: () {},
          onNotNow: () {},
        ),
      ),
    );
    expect(
      tester.widget<PPActivityRing>(find.byType(PPActivityRing)).color,
      ppDarkColorScheme.primary,
    );

    await tester.pumpWidget(
      wrap(
        PermissionPrimingScreen(
          kind: PermissionKind.location,
          onAllow: () {},
          onNotNow: () {},
        ),
        dark: false,
      ),
    );
    // MaterialApp wraps content in AnimatedTheme, so the new theme is not
    // applied at t=0 — settle before reading it.
    await tester.pumpAndSettle();
    expect(
      tester.widget<PPActivityRing>(find.byType(PPActivityRing)).color,
      PPColors.light.ringMove,
    );
  });

  testWidgets('all four kinds render in both themes', (tester) async {
    for (final kind in PermissionKind.values) {
      for (final dark in [true, false]) {
        await tester.pumpWidget(
          wrap(
            PermissionPrimingScreen(
              kind: kind,
              onAllow: () {},
              onNotNow: () {},
            ),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${kind.name} dark=$dark',
        );
      }
    }
  });

  test('the session set records a prime and never nags twice', () {
    final c = ProviderContainer.test();
    expect(c.read(primedThisSessionProvider), isEmpty);
    c.read(primedThisSessionProvider.notifier).mark(PermissionKind.bluetooth);
    expect(
      c.read(primedThisSessionProvider),
      contains(PermissionKind.bluetooth),
    );
    // Marking twice is idempotent — a Set, not a counter.
    c.read(primedThisSessionProvider.notifier).mark(PermissionKind.bluetooth);
    expect(c.read(primedThisSessionProvider), hasLength(1));
  });
}
