import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/home/data/stub_home_repository.dart';

void main() {
  test('the populated fixture matches the default artboard', () async {
    final repo = StubHomeRepository();
    final summary = await repo.load();

    expect(summary.displayName, 'Dana');
    expect(summary.initials, 'DN');
    expect(summary.rings.moveKcal, 486);
    expect(summary.rings.exerciseMin, 22);
    expect(summary.rings.steps, 8214);
    expect(summary.streak!.days, 12);
    expect(summary.week!.distanceKm, 32.6);
    expect(summary.week!.deltaPercent, 12);
    expect(summary.restingHr!.bpm, 54);
    expect(summary.recent, hasLength(2));
    expect(summary.recent.first.isPr, isTrue);
  });

  test('the first-launch fixture has no history and no streak', () async {
    final repo = StubHomeRepository(summary: StubHomeFixtures.firstLaunch);
    final summary = await repo.load();

    expect(summary.isFirstLaunch, isTrue);
    expect(summary.streak, isNull);
    expect(summary.hasStats, isFalse);
    expect(summary.rings.moveKcal, 0);
  });

  test('the health-declined fixture nulls steps and resting HR', () async {
    final repo = StubHomeRepository(summary: StubHomeFixtures.healthDeclined);
    final summary = await repo.load();

    expect(summary.rings.hasSteps, isFalse);
    expect(summary.restingHr, isNull);
    expect(summary.week, isNotNull);
  });

  test('the offline-cached fixture carries an unsynced workout', () async {
    final repo = StubHomeRepository(summary: StubHomeFixtures.offlineCached);
    final summary = await repo.load();

    expect(summary.lastSyncedAt, isNotNull);
    expect(summary.recent.any((a) => !a.isSynced), isTrue);
  });

  test('latency is honoured', () async {
    const latency = Duration(milliseconds: 50);
    final repo = StubHomeRepository(latency: latency);

    final stopwatch = Stopwatch()..start();
    await repo.load();
    stopwatch.stop();

    // Future.delayed guarantees the lower bound, so this asserts a floor and
    // never a ceiling — no flake on a slow machine.
    expect(stopwatch.elapsed, greaterThanOrEqualTo(latency));
  });

  test('failWith makes load throw', () {
    final repo = StubHomeRepository(failWith: StateError('boom'));
    expect(repo.load(), throwsStateError);
  });
}
