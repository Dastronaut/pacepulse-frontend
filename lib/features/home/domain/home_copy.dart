abstract final class HomeCopy {
  static const title = 'Home';
  static const welcome = 'Welcome';

  static const move = 'Move';
  static const exercise = 'Exercise';
  static const steps = 'Steps';
  static const kcal = 'kcal';
  static const min = 'min';

  static const thisWeek = 'This week';
  static const restingHr = 'Resting HR';
  static const km = 'km';
  static const bpm = 'bpm';
  static const vsLastWeek = 'vs last week';
  static const trendNoComparison = '– steady';
  static const hrSteady = '– steady';
  static const hrUp = '▲ trending up';
  static const hrDown = '▼ trending down';

  static const quickStart = 'Quick start';
  static const run = 'Run';
  static const ride = 'Ride';
  static const gym = 'Gym';

  static const recent = 'Recent';
  static const viewAll = 'View all';
  static const notSynced = 'not synced';

  static const offlineBanner = "You're offline — workouts will sync later";
  static const backOnline = 'Back online';

  static const emptyTitle = 'Ready when you are';
  static const emptyBody =
      'Your first workout starts your streak and fills these rings.';
  static const emptyAction = 'Start your first run';

  // ⚠ awaiting design sign-off — no artboard.
  static const noSteps = '—';
  static const connectHealth = 'Connect Health';
  static const errorTitle = "Couldn't load your day";
  static const errorBody = 'Check your connection and try again.';
  static const refreshFailed = "Couldn't refresh — showing saved data";
}

abstract final class HomeDateFormat {
  // TODO(l10n): English-only until localization lands; intl is not a dependency.
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String dayLine(DateTime date) =>
      '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

  static String syncedAgo(Duration age) {
    if (age.inMinutes < 1) return 'synced just now';
    if (age.inHours < 1) return 'synced ${age.inMinutes} min ago';
    if (age.inDays < 1) return 'synced ${age.inHours} h ago';
    return 'synced ${age.inDays} d ago';
  }

  static String relativeDay(DateTime at, DateTime now) {
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(at.year, at.month, at.day))
        .inDays;
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 7) return _weekdays[at.weekday - 1];
    return dayLine(at);
  }
}
