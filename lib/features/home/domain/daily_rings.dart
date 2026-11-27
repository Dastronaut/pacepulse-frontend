abstract final class HomeGoals {
  // TODO(flow6): source these from the profile once health integrations land.
  static const moveKcal = 600;
  static const exerciseMin = 40;
  static const steps = 10000;
}

class DailyRings {
  const DailyRings({
    required this.moveKcal,
    required this.exerciseMin,
    this.steps,
    this.moveGoalKcal = HomeGoals.moveKcal,
    this.exerciseGoalMin = HomeGoals.exerciseMin,
    this.stepsGoal = HomeGoals.steps,
  });

  final int moveKcal;
  final int exerciseMin;
  final int? steps;
  final int moveGoalKcal;
  final int exerciseGoalMin;
  final int stepsGoal;

  static const empty = DailyRings(moveKcal: 0, exerciseMin: 0, steps: 0);

  bool get hasSteps => steps != null;

  double get moveProgress => _ratio(moveKcal, moveGoalKcal);
  double get exerciseProgress => _ratio(exerciseMin, exerciseGoalMin);
  double get stepsProgress =>
      steps == null ? 0.0 : _ratio(steps!, stepsGoal);

  static double _ratio(int value, int goal) =>
      goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
}
