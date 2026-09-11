import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/features/home/domain/activity.dart';
import 'package:pacepulse/features/home/domain/daily_rings.dart';
import 'package:pacepulse/features/home/domain/home_copy.dart';
import 'package:pacepulse/features/home/domain/home_summary.dart';
import 'package:pacepulse/features/home/presentation/widgets/home_header.dart';
import 'package:pacepulse/features/home/presentation/widgets/rings_card.dart';

Widget wrap(Widget child, {Brightness brightness = Brightness.dark}) =>
    MaterialApp(
      theme: brightness == Brightness.dark ? ppDarkTheme() : ppLightTheme(),
      home: Scaffold(body: child),
    );

final _aWorkout = Activity(
  id: 'a1',
  type: ActivityType.run,
  title: 'Morning run',
  startedAt: DateTime(2026, 6, 12, 7, 12),
  syncedAt: DateTime(2026, 6, 12, 7, 45),
);

HomeSummary summaryWith({
  StreakInfo? streak,
  List<Activity> recent = const [],
  DateTime? lastSyncedAt,
}) =>
    HomeSummary(
      displayName: 'Dana',
      initials: 'DN',
      date: DateTime(2026, 6, 12),
      rings: DailyRings.empty,
      recent: recent,
      streak: streak,
      lastSyncedAt: lastSyncedAt,
    );

void main() {
  group('HomeHeader', () {
    testWidgets('the caption is the day line when online', (tester) async {
      await tester.pumpWidget(wrap(HomeHeader(
        summary: summaryWith(
          streak: StreakInfo.fromDays(12),
          recent: [_aWorkout],
        ),
        offline: false,
      )));
      expect(find.text('Friday 12 June'), findsOneWidget);
      expect(find.text(HomeCopy.title), findsOneWidget);
    });

    testWidgets('offline appends the sync age', (tester) async {
      await tester.pumpWidget(wrap(HomeHeader(
        summary: summaryWith(
          streak: StreakInfo.fromDays(12),
          recent: [_aWorkout],
          lastSyncedAt: DateTime(2026, 6, 12).subtract(const Duration(hours: 2)),
        ),
        offline: true,
        now: DateTime(2026, 6, 12),
      )));
      final caption = tester.widget<Text>(find.byKey(const Key('home_caption')));
      expect(caption.data, 'Friday 12 June · synced 2 h ago');
    });

    testWidgets('first launch greets by name instead of dating the day',
        (tester) async {
      await tester.pumpWidget(wrap(HomeHeader(
        summary: summaryWith(),
        offline: false,
      )));
      final caption = tester.widget<Text>(find.byKey(const Key('home_caption')));
      expect(caption.data, 'Welcome, Dana');
    });

    testWidgets('a zero streak hides the chip entirely', (tester) async {
      await tester.pumpWidget(wrap(HomeHeader(
        summary: summaryWith(streak: StreakInfo.fromDays(0)),
        offline: false,
      )));
      expect(find.byKey(const Key('home_streak_chip')), findsNothing);
    });

    testWidgets('a real streak renders its day count', (tester) async {
      await tester.pumpWidget(wrap(HomeHeader(
        summary: summaryWith(streak: StreakInfo.fromDays(12)),
        offline: false,
      )));
      expect(find.byKey(const Key('home_streak_chip')), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('the avatar reports its initials and is tappable',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(HomeHeader(
        summary: summaryWith(),
        offline: false,
        onAvatarTap: () => tapped = true,
      )));
      await tester.tap(find.byKey(const Key('home_avatar')));
      expect(tapped, isTrue);
    });
  });

  group('RingsCard', () {
    testWidgets('all three rings render their values', (tester) async {
      await tester.pumpWidget(wrap(const RingsCard(
        rings: DailyRings(moveKcal: 486, exerciseMin: 22, steps: 8214),
      )));
      await tester.pump(PPMotion.deliberate);

      expect(find.text('486'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('8,214'), findsOneWidget);
      expect(find.text('/600 kcal'), findsOneWidget);
      expect(find.text('/40 min'), findsOneWidget);
      expect(find.text('/10,000'), findsOneWidget);
    });

    testWidgets('live-updating values render with tabular figures',
        (tester) async {
      await tester.pumpWidget(wrap(const RingsCard(
        rings: DailyRings(moveKcal: 486, exerciseMin: 22, steps: 8214),
      )));
      await tester.pump(PPMotion.deliberate);

      final value = tester.widget<Text>(find.text('486'));
      expect(value.style?.fontFeatures, contains(const FontFeature.tabularFigures()));

      final goal = tester.widget<Text>(find.text('/600 kcal'));
      expect(goal.style?.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('declined health shows an em dash, not a zero', (tester) async {
      await tester.pumpWidget(wrap(const RingsCard(
        rings: DailyRings(moveKcal: 486, exerciseMin: 22),
      )));
      await tester.pump(PPMotion.deliberate);

      final steps =
          tester.widget<Text>(find.byKey(const Key('home_steps_value')));
      expect(steps.data, HomeCopy.noSteps);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('the card is tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(RingsCard(
        rings: DailyRings.empty,
        onTap: () => tapped = true,
      )));
      await tester.pump(PPMotion.deliberate);
      await tester.tap(find.byKey(const Key('home_rings_card')));
      expect(tapped, isTrue);
    });

    testWidgets('renders in the light theme', (tester) async {
      await tester.pumpWidget(wrap(
        const RingsCard(rings: DailyRings(moveKcal: 486, exerciseMin: 22)),
        brightness: Brightness.light,
      ));
      await tester.pump(PPMotion.deliberate);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the light theme uses surface + a hairline border, not dark\'s bare surfaceContainer',
        (tester) async {
      await tester.pumpWidget(wrap(
        const RingsCard(rings: DailyRings(moveKcal: 486, exerciseMin: 22)),
        brightness: Brightness.light,
      ));
      await tester.pump(PPMotion.deliberate);

      final scheme = ppLightColorScheme;
      final box = tester
          .widget<Container>(find.byKey(const Key('home_rings_card')));
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, scheme.surface);
      expect(decoration.border, isA<Border>());
      expect((decoration.border! as Border).top.color, scheme.outlineVariant);
    });
  });
}
