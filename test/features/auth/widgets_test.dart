import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/auth/presentation/widgets/password_visibility_toggle.dart';
import 'package:pacepulse/features/auth/presentation/widgets/social_auth_button.dart';

Widget wrap(Widget child, {bool dark = true}) => MaterialApp(
      theme: dark ? ppDarkTheme() : ppLightTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('PasswordVisibilityToggle', () {
    testWidgets('shows eye when hidden, eyeOff when visible', (tester) async {
      await tester.pumpWidget(
          wrap(PasswordVisibilityToggle(visible: false, onToggle: () {})));
      expect(find.byIcon(PPIcons.eye), findsOneWidget);

      await tester.pumpWidget(
          wrap(PasswordVisibilityToggle(visible: true, onToggle: () {})));
      expect(find.byIcon(PPIcons.eyeOff), findsOneWidget);
    });

    testWidgets('meets the 44px tap target', (tester) async {
      await tester.pumpWidget(
          wrap(PasswordVisibilityToggle(visible: false, onToggle: () {})));
      final size = tester.getSize(find.byType(PasswordVisibilityToggle));
      expect(size.width, greaterThanOrEqualTo(PPSpacing.tapMin));
      expect(size.height, greaterThanOrEqualTo(PPSpacing.tapMin));
    });

    testWidgets('semantic label describes the action, not the state',
        (tester) async {
      await tester.pumpWidget(
          wrap(PasswordVisibilityToggle(visible: false, onToggle: () {})));
      expect(find.bySemanticsLabel('Show password'), findsOneWidget);

      await tester.pumpWidget(
          wrap(PasswordVisibilityToggle(visible: true, onToggle: () {})));
      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
    });

    testWidgets('fires onToggle when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
          wrap(PasswordVisibilityToggle(visible: false, onToggle: () => taps++)));
      await tester.tap(find.byType(PasswordVisibilityToggle));
      expect(taps, 1);
    });
  });

  group('SocialAuthButton', () {
    testWidgets('apple uses mist fill on dark and slate on light',
        (tester) async {
      await tester.pumpWidget(
          wrap(SocialAuthButton.apple(onPressed: () {})));
      var box = tester.widget<DecoratedBox>(
          find.byKey(const Key('pp_social_box')).first);
      expect((box.decoration as ShapeDecoration).color, PPPalette.mist);

      await tester.pumpWidget(
          wrap(SocialAuthButton.apple(onPressed: () {}), dark: false));
      await tester.pumpAndSettle();
      box = tester.widget<DecoratedBox>(
          find.byKey(const Key('pp_social_box')).first);
      expect((box.decoration as ShapeDecoration).color, PPPalette.slate);
    });

    testWidgets('google has no fill and renders its label', (tester) async {
      await tester.pumpWidget(
          wrap(SocialAuthButton.google(onPressed: () {})));
      final box = tester.widget<DecoratedBox>(
          find.byKey(const Key('pp_social_box')).first);
      expect((box.decoration as ShapeDecoration).color, isNull);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('is 54 tall per PPButtonSize.lg', (tester) async {
      await tester.pumpWidget(
          wrap(SocialAuthButton.apple(onPressed: () {})));
      expect(
          tester.getSize(find.byKey(const Key('pp_social_box')).first).height,
          PPButtonSize.lg.height);
    });
  });
}
