library;

enum BodyOption { female, male, unspecified }

enum UnitSystem { metric, imperial }

enum WeekStart { monday, sunday }

abstract final class ProfileRules {
  static const int maxHrBase = 220;

  static const int minAge = 10;
  static const int maxAge = 100;

  static int? maxHrFor(int? birthYear, int currentYear) {
    if (birthYear == null) return null;
    final age = currentYear - birthYear;
    if (age < minAge || age > maxAge) return null;
    return maxHrBase - age;
  }

  static int? parseBirthYear(String raw) {
    final text = raw.trim();
    if (text.length != 4) return null;
    return int.tryParse(text);
  }
}

abstract final class GoalRules {
  static const double metricStep = 2.5;
  static const double metricDefault = 20;
  static const double metricMin = 2.5;
  static const double metricMax = 150;

  static const double imperialStep = 2;
  static const double imperialDefault = 12;
  static const double imperialMin = 2;
  static const double imperialMax = 90;

  static double step(UnitSystem u) =>
      u == UnitSystem.metric ? metricStep : imperialStep;

  static double defaultFor(UnitSystem u) =>
      u == UnitSystem.metric ? metricDefault : imperialDefault;

  static double minFor(UnitSystem u) =>
      u == UnitSystem.metric ? metricMin : imperialMin;

  static double maxFor(UnitSystem u) =>
      u == UnitSystem.metric ? metricMax : imperialMax;

  static String unitLabel(UnitSystem u) => u == UnitSystem.metric ? 'km' : 'mi';

  static String format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  static double clamp(double value, UnitSystem u) =>
      value.clamp(minFor(u), maxFor(u));
}

class ProfileDraft {
  const ProfileDraft({
    this.name = '',
    this.birthYear,
    this.body,
    this.unitSystem = UnitSystem.metric,
    this.weekStart = WeekStart.monday,
    this.maxHrBpm,
    this.weeklyGoal,
  });

  final String name;
  final int? birthYear;
  final BodyOption? body;
  final UnitSystem unitSystem;
  final WeekStart weekStart;

  final int? maxHrBpm;

  final double? weeklyGoal;

  int? effectiveMaxHr(int currentYear) =>
      maxHrBpm ?? ProfileRules.maxHrFor(birthYear, currentYear);

  double get effectiveWeeklyGoal =>
      weeklyGoal ?? GoalRules.defaultFor(unitSystem);

  ProfileDraft copyWith({
    String? name,
    int? birthYear,
    bool clearBirthYear = false,
    BodyOption? body,
    UnitSystem? unitSystem,
    WeekStart? weekStart,
    int? maxHrBpm,
    bool clearMaxHrBpm = false,
    double? weeklyGoal,
    bool clearWeeklyGoal = false,
  }) {
    return ProfileDraft(
      name: name ?? this.name,
      birthYear: clearBirthYear ? null : (birthYear ?? this.birthYear),
      body: body ?? this.body,
      unitSystem: unitSystem ?? this.unitSystem,
      weekStart: weekStart ?? this.weekStart,
      maxHrBpm: clearMaxHrBpm ? null : (maxHrBpm ?? this.maxHrBpm),
      weeklyGoal: clearWeeklyGoal ? null : (weeklyGoal ?? this.weeklyGoal),
    );
  }
}

abstract final class WizardCopy {
  static const back = 'Back';
  static const continueLabel = 'Continue';

  // Step 1
  static const step1Overline = 'Step 1 of 4';
  static const step1Title = 'Tell us about you';
  static const step1Body = 'Used only for calorie and heart-rate zone math.';
  static const nameLabel = 'Name';
  static const birthYearLabel = 'Birth year';
  static const bodyLabel = 'Body';
  static const bodyFemale = 'Female';
  static const bodyMale = 'Male';
  static const bodyUnspecified = 'Prefer not to say';

  // Step 2
  static const step2Overline = 'Step 2 of 4';
  static const step2Title = 'Units & measures';
  static const step2Body = 'Pulled from your device — change anything.';
  static const unitsLabel = 'Units';
  static const unitsMetric = 'Metric';
  static const unitsImperial = 'Imperial';
  static const weekStartLabel = 'Week starts on';
  static const weekMonday = 'Monday';
  static const weekSunday = 'Sunday';
  static const maxHrLabel = 'Max heart rate';
  static const maxHrUnit = 'bpm';
  static const maxHrHelper = 'Estimated from your age — edit if you know yours';

  // Step 3
  static const step3Overline = 'Step 3 of 4';
  static const step3Title = 'Set your weekly goal';
  static const step3Body = 'You can change this anytime.';
  static const goalNudgeMetric = 'Most runners start between 15 and 25 km';
  static const goalNudgeImperial = 'Most runners start between 9 and 16 miles';
  static const goalDecrease = 'Decrease weekly goal';
  static const goalIncrease = 'Increase weekly goal';

  // Step 4
  static const step4Overline = 'Step 4 of 4';
  static const step4Title = 'Connect your gear';
  static const step4Scanning = 'Scanning for heart-rate straps nearby…';
  static const step4Found = 'Tap Connect to pair a strap.';
  static const finishLabel = 'Finish setup';
  static const skipLabel = 'Skip for now';
  static const gearEmptyTitle = 'No straps found';
  static const gearEmptyBody =
      'Make sure your strap is awake and close by, then scan again.';
  static const gearEmptyAction = 'Scan again';
  static const gearErrorTitle = 'Bluetooth is off';
  static const gearErrorBody =
      'Turn on Bluetooth to find your heart-rate strap.';
}
