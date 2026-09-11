import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/home/domain/activity.dart';
import 'package:pacepulse/features/home/domain/daily_rings.dart';
import 'package:pacepulse/features/home/domain/home_copy.dart';
import 'package:pacepulse/features/home/domain/home_summary.dart';
import 'package:pacepulse/features/home/presentation/widgets/quick_start.dart';
import 'package:pacepulse/features/home/presentation/widgets/stats_row.dart';

Widget wrap(Widget child, {Brightness brightness = Brightness.dark}) =>
    MaterialApp(
      theme: brightness == Brightness.dark ? ppDarkTheme() : ppLightTheme(),
      home: Scaffold(body: child),
    );

HomeSummary summaryWith({WeekTrend? week, RestingHr? restingHr}) => HomeSummary(
      displayName: 'Dana',
      initials: 'DN',
      date: DateTime(2026, 6, 12),
      rings: DailyRings.empty,
      recent: const [],
      week: week,
      restingHr: restingHr,
    );

void main() {
  group('StatsRow', () {
    testWidgets('the row vanishes when there is nothing to show',
        (tester) async {
      await tester.pumpWidget(wrap(StatsRow(summary: summaryWith())));
      expect(find.byKey(const Key('home_stats_row')), findsNothing);
    });

    testWidgets('the week tile shows distance, unit and trend', (tester) async {
      await tester.pumpWidget(wrap(StatsRow(
        summary: summaryWith(
          week: const WeekTrend(distanceKm: 32.6, deltaPercent: 12),
        ),
      )));
      expect(find.byKey(const Key('home_stats_row')), findsOneWidget);
      expect(find.text(HomeCopy.thisWeek), findsOneWidget);
      expect(find.text('32.6'), findsOneWidget);
      expect(find.text(HomeCopy.km), findsOneWidget);
      expect(find.text('▲ 12% vs last week'), findsOneWidget);
    });

    testWidgets('rising distance is positive, rising heart rate is not',
        (tester) async {
      await tester.pumpWidget(wrap(StatsRow(
        summary: summaryWith(
          week: const WeekTrend(distanceKm: 32.6, deltaPercent: 12),
          restingHr: const RestingHr(bpm: 61, direction: TrendDirection.up),
        ),
      )));

      final week = tester.widget<PPStatTile>(find.byKey(const Key('home_week_tile')));
      final hr = tester.widget<PPStatTile>(find.byKey(const Key('home_hr_tile')));

      expect(week.subTone, PPStatTone.positive);
      expect(hr.subTone, PPStatTone.negative);
    });

    testWidgets('declined health swaps the HR tile for a prompt',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(StatsRow(
        summary: summaryWith(
          week: const WeekTrend(distanceKm: 32.6, deltaPercent: 12),
        ),
        onConnectHealth: () => tapped = true,
      )));

      expect(find.byKey(const Key('home_hr_tile')), findsNothing);
      expect(find.text(HomeCopy.connectHealth), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_connect_health')));
      expect(tapped, isTrue);
    });

    testWidgets('the row renders in the light theme', (tester) async {
      await tester.pumpWidget(wrap(
        StatsRow(
          summary: summaryWith(restingHr: const RestingHr(bpm: 54)),
        ),
        brightness: Brightness.light,
      ));
      expect(tester.takeException(), isNull);
    });
  });

  group('QuickStart', () {
    testWidgets('three tiles, each reporting its type', (tester) async {
      final started = <ActivityType>[];
      await tester.pumpWidget(wrap(QuickStart(onStart: started.add)));

      expect(find.text(HomeCopy.quickStart), findsOneWidget);

      for (final key in ['run', 'ride', 'gym']) {
        await tester.tap(find.byKey(Key('home_quick_start_$key')));
      }

      expect(started,
          [ActivityType.run, ActivityType.ride, ActivityType.gym]);
    });

    testWidgets('every tile clears the 44px tap minimum', (tester) async {
      await tester.pumpWidget(wrap(QuickStart(onStart: (_) {})));

      for (final key in ['run', 'ride', 'gym']) {
        final size = tester.getSize(find.byKey(Key('home_quick_start_$key')));
        expect(size.height, greaterThanOrEqualTo(PPSpacing.tapMin),
            reason: key);
      }
    });
  });
}
