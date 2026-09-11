import 'activity.dart';
import 'home_copy.dart';

abstract final class ActivityFormat {
  static String stats(Activity activity) {
    final parts = <String>[];
    final distanceM = activity.distanceM;
    final durationS = activity.durationS;
    final pace = activity.avgPaceSPerKm;
    final calories = activity.calories;

    if (distanceM != null) {
      parts.add('${(distanceM / 1000).toStringAsFixed(2)} ${HomeCopy.km}');
    }
    if (durationS != null) {
      parts.add(distanceM == null
          ? '${(durationS / 60).round()} ${HomeCopy.min}'
          : clock(durationS));
    }
    if (pace != null) parts.add('${clock(pace.round())} /${HomeCopy.km}');
    if (calories != null && distanceM == null) {
      parts.add('$calories ${HomeCopy.kcal}');
    }
    return parts.join(' · ');
  }

  static String meta(Activity activity, DateTime now) => activity.isSynced
      ? HomeDateFormat.relativeDay(activity.startedAt, now)
      : HomeCopy.notSynced;

  static String clock(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = h > 0 ? m.toString().padLeft(2, '0') : m.toString();
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }
}
