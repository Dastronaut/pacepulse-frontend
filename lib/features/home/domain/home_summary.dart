import 'activity.dart';
import 'daily_rings.dart';
import 'home_copy.dart';

enum TrendDirection { up, down, steady }

class WeekTrend {
  const WeekTrend({required this.distanceKm, this.deltaPercent});

  final double distanceKm;

  final int? deltaPercent;

  TrendDirection get direction {
    final delta = deltaPercent;
    if (delta == null || delta == 0) return TrendDirection.steady;
    return delta > 0 ? TrendDirection.up : TrendDirection.down;
  }

  String get label => switch (direction) {
        TrendDirection.steady => HomeCopy.trendNoComparison,
        TrendDirection.up => '▲ ${deltaPercent!.abs()}% ${HomeCopy.vsLastWeek}',
        TrendDirection.down =>
          '▼ ${deltaPercent!.abs()}% ${HomeCopy.vsLastWeek}',
      };
}

class RestingHr {
  const RestingHr({required this.bpm, this.direction = TrendDirection.steady});

  final int bpm;
  final TrendDirection direction;

  String get label => switch (direction) {
        TrendDirection.steady => HomeCopy.hrSteady,
        TrendDirection.up => HomeCopy.hrUp,
        TrendDirection.down => HomeCopy.hrDown,
      };
}

class StreakInfo {
  const StreakInfo({required this.days});

  final int days;

  static StreakInfo? fromDays(int days) =>
      days > 0 ? StreakInfo(days: days) : null;
}

class HomeSummary {
  const HomeSummary({
    required this.displayName,
    required this.initials,
    required this.date,
    required this.rings,
    required this.recent,
    this.week,
    this.restingHr,
    this.streak,
    this.lastSyncedAt,
  });

  final String displayName;

  final String initials;
  final DateTime date;
  final DailyRings rings;
  final List<Activity> recent;
  final WeekTrend? week;
  final RestingHr? restingHr;
  final StreakInfo? streak;
  final DateTime? lastSyncedAt;

  bool get isFirstLaunch => recent.isEmpty;
  bool get hasStats => week != null || restingHr != null;
}
