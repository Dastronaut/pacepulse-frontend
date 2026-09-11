import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import '../domain/daily_rings.dart';
import '../domain/home_repository.dart';
import '../domain/home_summary.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => const StubHomeRepository(),
);

class StubHomeRepository implements HomeRepository {
  const StubHomeRepository({
    this.summary,
    this.latency = const Duration(milliseconds: 700),
    this.failWith,
  });

  final HomeSummary? summary;
  final Duration latency;
  final Object? failWith;

  @override
  Future<HomeSummary> load() async {
    await Future<void>.delayed(latency);
    final failure = failWith;
    if (failure != null) throw failure;
    return summary ?? StubHomeFixtures.populated;
  }
}

abstract final class StubHomeFixtures {
  // TODO(flow2): replace with real reads once workouts are recorded.
  // 11 June 2026 is genuinely a Thursday (verified: date.strftime('%A')),
  // matching the handoff artboard's "Thursday 12 June" caption intent — the
  // artboard's date, not the weekday math, was the thing that was wrong.
  static final _today = DateTime(2026, 6, 11, 9, 41);

  static final _morningRun = Activity(
    id: 'a1',
    type: ActivityType.run,
    title: 'Morning run',
    startedAt: DateTime(2026, 6, 11, 7, 12),
    distanceM: 5210,
    durationS: 1721,
    avgPaceSPerKm: 331,
    calories: 412,
    isPr: true,
    syncedAt: DateTime(2026, 6, 11, 7, 45),
  );

  static final _gymSession = Activity(
    id: 'a2',
    type: ActivityType.gym,
    title: 'Gym session',
    startedAt: DateTime(2026, 6, 10, 18, 30),
    durationS: 2700,
    calories: 312,
    syncedAt: DateTime(2026, 6, 10, 19, 20),
  );

  static final _unsyncedRun = Activity(
    id: 'a1',
    type: ActivityType.run,
    title: 'Morning run',
    startedAt: DateTime(2026, 6, 11, 7, 12),
    distanceM: 5210,
    durationS: 1721,
    avgPaceSPerKm: 331,
    calories: 412,
    isPr: true,
  );

  static final populated = HomeSummary(
    displayName: 'Dana',
    initials: 'DN',
    date: _today,
    rings: const DailyRings(moveKcal: 486, exerciseMin: 22, steps: 8214),
    recent: [_morningRun, _gymSession],
    week: const WeekTrend(distanceKm: 32.6, deltaPercent: 12),
    restingHr: const RestingHr(bpm: 54),
    streak: StreakInfo.fromDays(12),
    lastSyncedAt: _today,
  );

  static final firstLaunch = HomeSummary(
    displayName: 'Dana',
    initials: 'DN',
    date: _today,
    rings: DailyRings.empty,
    recent: const [],
    streak: StreakInfo.fromDays(0),
  );

  static final healthDeclined = HomeSummary(
    displayName: 'Dana',
    initials: 'DN',
    date: _today,
    rings: const DailyRings(moveKcal: 486, exerciseMin: 22),
    recent: [_morningRun, _gymSession],
    week: const WeekTrend(distanceKm: 32.6, deltaPercent: 12),
    streak: StreakInfo.fromDays(12),
    lastSyncedAt: _today,
  );

  static final offlineCached = HomeSummary(
    displayName: 'Dana',
    initials: 'DN',
    date: _today,
    rings: const DailyRings(moveKcal: 486, exerciseMin: 22, steps: 8214),
    recent: [_unsyncedRun],
    week: const WeekTrend(distanceKm: 32.6, deltaPercent: 12),
    restingHr: const RestingHr(bpm: 54),
    streak: StreakInfo.fromDays(12),
    lastSyncedAt: _today.subtract(const Duration(hours: 2)),
  );
}
