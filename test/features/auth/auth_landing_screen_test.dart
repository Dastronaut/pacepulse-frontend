import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';
import 'package:pacepulse/features/auth/presentation/auth_landing_screen.dart';
import 'package:pacepulse/features/auth/presentation/widgets/social_auth_button.dart';

Widget harness({bool dark = true}) => ProviderScope(
      child: MaterialApp(
        theme: ppLightTheme(),
        darkTheme: ppDarkTheme(),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: const AuthLandingScreen(),
      ),
    );

void main() {
  testWidgets('renders the headline, both social pills and the legal line',
      (tester) async {
    await tester.pumpWidget(harness());
    expect(find.text(AuthCopy.landingHeadline), findsOneWidget);
    expect(find.text(AuthCopy.landingSubhead), findsOneWidget);
    expect(find.byType(SocialAuthButton), findsNWidgets(2));
    expect(find.text(AuthCopy.signUpWithEmail), findsOneWidget);
    expect(find.text(AuthCopy.legal), findsOneWidget);
  });

  testWidgets('hero ring is primary on dark and ringMove on light',
      (tester) async {
    await tester.pumpWidget(harness());
    var ring = tester.widget<PPActivityRing>(find.byType(PPActivityRing));
    // NOTE: this dark assertion cannot discriminate — PPColors.dark
    // .ringMove and ppDarkColorScheme.primary are BOTH 0xFFFF9B51, so it
    // passes whichever of the two the screen picks. The LIGHT assertion
    // below is the one that actually catches a wrong implementation.
    expect(ring.color, ppDarkColorScheme.primary);

    await tester.pumpWidget(harness(dark: false));
    await tester.pumpAndSettle();
    ring = tester.widget<PPActivityRing>(find.byType(PPActivityRing));
    expect(ring.color, PPColors.light.ringMove);
  });

  testWidgets('the sign-in link is a 44px target', (tester) async {
    await tester.pumpWidget(harness());
    final size = tester.getSize(find.byKey(const Key('pp_auth_sign_in_link')));
    expect(size.height, greaterThanOrEqualTo(PPSpacing.tapMin));
  });
}
