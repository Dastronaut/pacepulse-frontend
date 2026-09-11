enum ActivityType { run, ride, walk, gym }

class Activity {
  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.startedAt,
    this.distanceM,
    this.durationS,
    this.avgPaceSPerKm,
    this.calories,
    this.isPr = false,
    this.syncedAt,
  });

  final String id;
  final ActivityType type;
  final String title;
  final DateTime startedAt;
  final double? distanceM;
  final int? durationS;
  final double? avgPaceSPerKm;
  final int? calories;
  final bool isPr;
  final DateTime? syncedAt;

  bool get isSynced => syncedAt != null;

  Activity copyWith({DateTime? syncedAt}) => Activity(
    id: id,
    type: type,
    title: title,
    startedAt: startedAt,
    distanceM: distanceM,
    durationS: durationS,
    avgPaceSPerKm: avgPaceSPerKm,
    calories: calories,
    isPr: isPr,
    syncedAt: syncedAt ?? this.syncedAt,
  );
}
