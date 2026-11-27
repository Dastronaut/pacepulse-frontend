import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/home/domain/activity.dart';
import 'package:pacepulse/features/home/domain/daily_rings.dart';
import 'package:pacepulse/features/home/domain/home_copy.dart';
import 'package:pacepulse/features/home/domain/home_summary.dart';

void main() {
  group('DailyRings', () {
    test('progress is the value over the goal', () {
      const rings = DailyRings(moveKcal: 300, exerciseMin: 20, steps: 5000);
      expect(rings.moveProgress, closeTo(0.5, 0.001));
      expect(rings.exerciseProgress, closeTo(0.5, 0.001));
      expect(rings.stepsProgress, closeTo(0.5, 0.001));
    });

    test('progress clamps at 1 when the goal is beaten', () {
      const rings = DailyRings(moveKcal: 900, exerciseMin: 90, steps: 30000);
      expect(rings.moveProgress, 1.0);
      expect(rings.exerciseProgress, 1.0);
      expect(rings.stepsProgress, 1.0);
    });

    test('null steps reads as no progress and no data', () {
      const rings = DailyRings(moveKcal: 300, exerciseMin: 20);
      expect(rings.hasSteps, isFalse);
      expect(rings.stepsProgress, 0.0);
    });

    test('empty is all zeroes with steps present', () {
      expect(DailyRings.empty.moveProgress, 0.0);
      expect(DailyRings.empty.hasSteps, isTrue);
      expect(DailyRings.empty.steps, 0);
    });
  });

  group('StreakInfo', () {
    test('a zero streak is null, never a zero chip', () {
      expect(StreakInfo.fromDays(0), isNull);
      expect(StreakInfo.fromDays(-3), isNull);
    });

    test('a real streak survives', () {
      expect(StreakInfo.fromDays(12)!.days, 12);
    });
  });

  group('WeekTrend', () {
    test('direction follows the sign of the delta', () {
      expect(const WeekTrend(distanceKm: 32.6, deltaPercent: 12).direction,
          TrendDirection.up);
      expect(const WeekTrend(distanceKm: 32.6, deltaPercent: -4).direction,
          TrendDirection.down);
      expect(const WeekTrend(distanceKm: 32.6, deltaPercent: 0).direction,
          TrendDirection.steady);
    });

    test('no prior week means steady, not a fake zero', () {
      const trend = WeekTrend(distanceKm: 32.6);
      expect(trend.deltaPercent, isNull);
      expect(trend.direction, TrendDirection.steady);
      expect(trend.label, HomeCopy.trendNoComparison);
    });

    test('the label carries the glyph the artboard draws', () {
      expect(const WeekTrend(distanceKm: 32.6, deltaPercent: 12).label,
          '▲ 12% vs last week');
      expect(const WeekTrend(distanceKm: 30.0, deltaPercent: -4).label,
          '▼ 4% vs last week');
    });
  });

  group('HomeSummary', () {
    HomeSummary summary({
      List<Activity> recent = const [],
      WeekTrend? week,
      RestingHr? restingHr,
    }) =>
        HomeSummary(
          displayName: 'Dana',
          initials: 'DN',
          date: DateTime(2026, 6, 12),
          rings: DailyRings.empty,
          recent: recent,
          week: week,
          restingHr: restingHr,
        );

    test('no recent workouts is the first-launch shape', () {
      expect(summary().isFirstLaunch, isTrue);
    });

    test('the stat row hides only when it has nothing at all', () {
      expect(summary().hasStats, isFalse);
      expect(summary(week: const WeekTrend(distanceKm: 1)).hasStats, isTrue);
      expect(summary(restingHr: const RestingHr(bpm: 54)).hasStats, isTrue);
    });
  });

  group('Activity', () {
    test('a workout with no syncedAt is not synced', () {
      final a = Activity(
        id: '1',
        type: ActivityType.run,
        title: 'Morning run',
        startedAt: DateTime(2026, 6, 12, 7),
      );
      expect(a.isSynced, isFalse);
      expect(a.copyWith(syncedAt: DateTime(2026, 6, 12, 8)).isSynced, isTrue);
    });
  });

  group('HomeDateFormat', () {
    test('the day line matches the artboard', () {
      expect(HomeDateFormat.dayLine(DateTime(2026, 6, 12)), 'Friday 12 June');
    });

    test('a Sunday does not overrun the zero-indexed weekday array', () {
      // Verified independently: date(2026, 6, 7).strftime('%A') == 'Sunday'.
      expect(HomeDateFormat.dayLine(DateTime(2026, 6, 7)), 'Sunday 7 June');
    });

    test('December does not overrun the zero-indexed month array', () {
      // Verified independently: date(2026, 12, 1).strftime('%A') == 'Tuesday'.
      expect(
          HomeDateFormat.dayLine(DateTime(2026, 12, 1)), 'Tuesday 1 December');
    });

    test('sync age reads in the largest whole unit', () {
      expect(HomeDateFormat.syncedAgo(const Duration(seconds: 20)),
          'synced just now');
      expect(HomeDateFormat.syncedAgo(const Duration(minutes: 9)),
          'synced 9 min ago');
      expect(HomeDateFormat.syncedAgo(const Duration(hours: 2)),
          'synced 2 h ago');
      expect(HomeDateFormat.syncedAgo(const Duration(days: 3)),
          'synced 3 d ago');
    });

    test('relative day is used for recent workouts', () {
      final now = DateTime(2026, 6, 12, 9);
      expect(HomeDateFormat.relativeDay(DateTime(2026, 6, 12, 7), now), 'today');
      expect(HomeDateFormat.relativeDay(DateTime(2026, 6, 11, 7), now),
          'yesterday');
      expect(HomeDateFormat.relativeDay(DateTime(2026, 6, 8, 7), now),
          'Monday');
    });
  });
}
