import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';

Widget host(void Function(BuildContext) onGo) {
  return MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: ThemeMode.dark,
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
              onPressed: () => onGo(context), child: const Text('go')),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('sheet: opens over scrim with grabber, dismisses on scrim tap',
      (tester) async {
    await tester.pumpWidget(host((c) => showPPSheet<void>(c,
        title: 'Filters',
        builder: (_) => const SizedBox(height: 120))));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));
    expect(find.text('Filters'), findsOneWidget);
    expect(find.byKey(const Key('pp_sheet_grabber')), findsOneWidget);
    final barrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last);
    expect(barrier.color, ppDarkColorScheme.scrim);
    await tester.tapAt(const Offset(200, 50)); // scrim area
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsNothing);
  });

  testWidgets('dialog: 300 wide, destructive confirm resolves true',
      (tester) async {
    bool? result;
    await tester.pumpWidget(host((c) async {
      result = await showPPDialog<bool>(c,
          title: 'Discard run?',
          body: 'This deletes the recording — it cannot be undone.',
          confirmLabel: 'Discard',
          destructive: true);
    }));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(
        tester.getSize(find.byKey(const Key('pp_dialog_box'))).width, 300);
    final confirm = tester.widget<PPButton>(
        find.widgetWithText(PPButton, 'Discard'));
    expect(confirm.variant, PPButtonVariant.danger);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('dialog cancel resolves null', (tester) async {
    bool? result = true;
    await tester.pumpWidget(host((c) async {
      result = await showPPDialog<bool>(c,
          title: 'Sign out?',
          body: 'You can sign back in anytime.',
          confirmLabel: 'Sign out');
    }));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
